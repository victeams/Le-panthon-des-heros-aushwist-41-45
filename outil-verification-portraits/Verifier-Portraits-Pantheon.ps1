param([switch]$SelfTest)

$ErrorActionPreference = "Stop"
$RepositoryUrl = "https://github.com/victeams/Le-panthon-des-heros-aushwist-41-45.git"
$DefaultRepository = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Le-panthon-des-heros-aushwist-41-45"
$ConfigDirectory = Join-Path $env:APPDATA "EnvoiFichesMemoire"
$ConfigPath = Join-Path $ConfigDirectory "config.json"
$SiteUrl = "https://victeams.github.io/Le-panthon-des-heros-aushwist-41-45/"

function Get-SavedRepository {
    if (Test-Path -LiteralPath $ConfigPath -PathType Leaf) {
        try {
            $config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($config.repository) {
                $saved = [string]$config.repository
                $savedIsRepository = (Test-Path -LiteralPath (Join-Path $saved ".git") -PathType Container) -and
                    (Test-Path -LiteralPath (Join-Path $saved "scripts\build_site.py") -PathType Leaf)
                if ($savedIsRepository) { return $saved }
            }
        } catch { }
    }
    return $DefaultRepository
}

function Save-Repository {
    param([Parameter(Mandatory)] [string]$Path)
    New-Item -ItemType Directory -Path $ConfigDirectory -Force | Out-Null
    @{ repository = $Path } | ConvertTo-Json | Set-Content -LiteralPath $ConfigPath -Encoding UTF8
}

function Get-GitExecutable {
    $command = Get-Command git.exe -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    $known = @(
        (Join-Path $env:ProgramFiles "Git\cmd\git.exe"),
        (Join-Path ${env:ProgramFiles(x86)} "Git\cmd\git.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\Git\cmd\git.exe")
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) }
    if ($known.Count) { return $known[0] }
    throw "Git pour Windows est introuvable. Installez-le depuis https://git-scm.com/download/win."
}

function Invoke-Git {
    param(
        [Parameter(Mandatory)] [string]$Git,
        [Parameter(Mandatory)] [string[]]$Arguments,
        [switch]$AllowFailure
    )
    $previous = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $Git @Arguments 2>&1 | Out-String
        $exitCode = $LASTEXITCODE
    } finally { $ErrorActionPreference = $previous }
    if ($exitCode -ne 0 -and -not $AllowFailure) { throw "Commande Git impossible :`r`n$output" }
    return [PSCustomObject]@{ ExitCode = $exitCode; Output = $output.Trim() }
}

function Set-GitIdentity {
    param([string]$Git, [string]$Repository)
    $name = Invoke-Git $Git @("-C", $Repository, "config", "--local", "--get", "user.name") -AllowFailure
    if ($name.ExitCode -ne 0 -or -not $name.Output) {
        [void](Invoke-Git $Git @("-C", $Repository, "config", "--local", "user.name", "victeams"))
    }
    $email = Invoke-Git $Git @("-C", $Repository, "config", "--local", "--get", "user.email") -AllowFailure
    if ($email.ExitCode -ne 0 -or -not $email.Output) {
        [void](Invoke-Git $Git @("-C", $Repository, "config", "--local", "user.email", "victeams@users.noreply.github.com"))
    }
}

function Get-PythonCommand {
    foreach ($name in @("py.exe", "python.exe")) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($command) { return $command.Source }
    }
    throw "Python est introuvable. Il est nécessaire pour reconstruire les listes du site."
}

function Assert-Repository {
    param([Parameter(Mandatory)] [string]$Repository)
    if (-not (Test-Path -LiteralPath (Join-Path $Repository ".git") -PathType Container)) {
        throw "Le dossier GitHub n'est pas préparé. Gardez le chemin proposé puis cliquez sur Préparer / actualiser."
    }
    if (-not (Test-Path -LiteralPath (Join-Path $Repository "scripts\build_site.py") -PathType Leaf)) {
        throw "Ce dossier n'est pas le dépôt du Panthéon des héros."
    }
}

function Get-ExpectedGroup {
    param([string]$Matricule)
    if ($Matricule -match '^31\d{3}$') { return "femmes" }
    if ($Matricule -match '^(45|46)\d{3}$') { return "hommes" }
    return $null
}

function Get-GroupLabel {
    param([string]$Group)
    if ($Group -eq "femmes") { return "Femme 31000" }
    if ($Group -eq "hommes") { return "Homme 45000" }
    return "À vérifier"
}

function Resolve-SafeRepositoryPath {
    param([string]$Repository, [string]$RelativePath, [switch]$AllowMissing)
    $root = [IO.Path]::GetFullPath($Repository).TrimEnd('\')
    $decoded = [Uri]::UnescapeDataString($RelativePath) -replace '/', '\'
    $candidate = [IO.Path]::GetFullPath((Join-Path $root $decoded))
    if (-not $candidate.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw "Chemin refusé car il sort du dossier GitHub : $RelativePath"
    }
    if (-not $AllowMissing -and -not (Test-Path -LiteralPath $candidate)) { return $null }
    return $candidate
}

function Get-ImageDimensions {
    param([string]$Path)
    try {
        $stream = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
        try {
            $image = [Drawing.Image]::FromStream($stream, $false, $false)
            try { return @($image.Width, $image.Height) } finally { $image.Dispose() }
        } finally { $stream.Dispose() }
    } catch { return @($null, $null) }
}

function Get-PhotoInformation {
    param([string]$Repository, [object]$Record)
    if (-not $Record.portrait) {
        return [PSCustomObject]@{ State = "Sans photo"; Path = $null; Width = $null; Height = $null; IsProblem = $true }
    }
    $portrait = [string]$Record.portrait
    if ($portrait -match '^(https?:)?//') {
        return [PSCustomObject]@{ State = "Photo externe"; Path = $portrait; Width = $null; Height = $null; IsProblem = $true }
    }
    $path = Resolve-SafeRepositoryPath -Repository $Repository -RelativePath $portrait
    if (-not $path) {
        return [PSCustomObject]@{ State = "Fichier photo absent"; Path = $null; Width = $null; Height = $null; IsProblem = $true }
    }
    $dimensions = Get-ImageDimensions -Path $path
    if (-not $dimensions[0]) {
        return [PSCustomObject]@{ State = "Photo illisible"; Path = $path; Width = $null; Height = $null; IsProblem = $true }
    }
    $small = $dimensions[0] -lt 180 -or $dimensions[1] -lt 180
    $state = if ($small) { "Photo trop petite" } else { "Photo présente" }
    return [PSCustomObject]@{ State = $state; Path = $path; Width = $dimensions[0]; Height = $dimensions[1]; IsProblem = $small }
}

function Get-PortraitRecords {
    param([Parameter(Mandatory)] [string]$Repository)
    $dataPath = Join-Path $Repository "site-data.json"
    if (-not (Test-Path -LiteralPath $dataPath -PathType Leaf)) {
        throw "site-data.json est absent. Cliquez sur Préparer / actualiser."
    }
    $raw = @(Get-Content -LiteralPath $dataPath -Raw -Encoding UTF8 | ConvertFrom-Json)
    $duplicates = @{}
    foreach ($record in $raw) {
        if ($record.group -and $record.matricule) {
            $key = "$($record.group)|$($record.matricule)"
            if (-not $duplicates.ContainsKey($key)) { $duplicates[$key] = 0 }
            $duplicates[$key]++
        }
    }
    $rows = New-Object Collections.Generic.List[object]
    foreach ($record in $raw) {
        $photo = Get-PhotoInformation -Repository $Repository -Record $record
        $expected = Get-ExpectedGroup -Matricule ([string]$record.matricule)
        $wrongGroup = $expected -and $expected -ne [string]$record.group
        $duplicate = $record.matricule -and $duplicates["$($record.group)|$($record.matricule)"] -gt 1
        $filePath = Resolve-SafeRepositoryPath -Repository $Repository -RelativePath ([string]$record.file)
        $missingFile = -not $filePath
        $problems = New-Object Collections.Generic.List[string]
        if ($photo.IsProblem) { $problems.Add($photo.State) }
        if ($wrongGroup) { $problems.Add("Classement incompatible avec le matricule") }
        if ($duplicate) { $problems.Add("Matricule en double") }
        if ($missingFile) { $problems.Add("Fiche HTML absente") }
        $state = if ($problems.Count) { $problems -join " ; " } else { "OK" }
        $rows.Add([PSCustomObject]@{
            Name = [string]$record.name
            Matricule = [string]$record.matricule
            Group = [string]$record.group
            GroupLabel = Get-GroupLabel ([string]$record.group)
            File = [string]$record.file
            FilePath = $filePath
            Portrait = [string]$record.portrait
            PhotoPath = $photo.Path
            PhotoState = $photo.State
            Dimensions = $(if ($photo.Width) { "$($photo.Width) × $($photo.Height)" } else { "-" })
            State = $state
            IsProblem = [bool]$problems.Count
        })
    }
    return $rows.ToArray()
}

function Set-ConvoiMeta {
    param([string]$Content, [string]$Group)
    $value = if ($Group -eq "femmes") { "31000" } else { "45000" }
    $meta = '<meta name="convoi" content="' + $value + '">'
    $pattern = '(?is)<meta\s+[^>]*name=["'']convoi["''][^>]*>'
    if ([regex]::IsMatch($Content, $pattern)) { return [regex]::Replace($Content, $pattern, $meta, 1) }
    if ($Content -match '(?is)<head\b[^>]*>') {
        return [regex]::Replace($Content, '(?is)<head\b[^>]*>', { param($match) $match.Value + "`r`n  $meta" }, 1)
    }
    return "$meta`r`n$Content"
}

function Set-FirstImageSource {
    param([string]$Content, [string]$Source, [string]$Alt)
    $encodedSource = [System.Web.HttpUtility]::HtmlAttributeEncode($Source)
    $encodedAlt = [System.Web.HttpUtility]::HtmlAttributeEncode($Alt)
    $pattern = '(?is)(<img\b[^>]*\bsrc\s*=\s*)(["''])(.*?)(\2)'
    if ([regex]::IsMatch($Content, $pattern)) {
        return [regex]::Replace($Content, $pattern, { param($match) $match.Groups[1].Value + '"' + $encodedSource + '"' }, 1)
    }
    $image = '<figure><img src="' + $encodedSource + '" alt="' + $encodedAlt + '" loading="lazy"></figure>'
    if ($Content -match '(?is)<body\b[^>]*>') {
        return [regex]::Replace($Content, '(?is)<body\b[^>]*>', { param($match) $match.Value + "`r`n$image" }, 1)
    }
    return "$image`r`n$Content"
}

function Save-IdentityPhoto {
    param([string]$Repository, [object]$Row, [string]$SourcePath)
    if (-not $Row.FilePath) { throw "La fiche HTML est absente." }
    $portraitRelative = if ($Row.Portrait -and $Row.Portrait -notmatch '^(https?:)?//') {
        [Uri]::UnescapeDataString($Row.Portrait)
    } else { "portraits/$([IO.Path]::GetFileNameWithoutExtension($Row.File)).jpg" }
    $target = Resolve-SafeRepositoryPath -Repository $Repository -RelativePath $portraitRelative -AllowMissing
    New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
    $inputStream = [IO.File]::Open($SourcePath, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
    try {
        $sourceImage = [Drawing.Image]::FromStream($inputStream, $true, $true)
        try { $image = New-Object Drawing.Bitmap($sourceImage) } finally { $sourceImage.Dispose() }
    } finally { $inputStream.Dispose() }
    try {
        if ([IO.Path]::GetExtension($target).ToLowerInvariant() -eq ".png") {
            $image.Save($target, [Drawing.Imaging.ImageFormat]::Png)
        } else {
            $codec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq "image/jpeg" | Select-Object -First 1
            $parameters = New-Object Drawing.Imaging.EncoderParameters(1)
            $parameters.Param[0] = New-Object Drawing.Imaging.EncoderParameter([Drawing.Imaging.Encoder]::Quality, [long]92)
            try { $image.Save($target, $codec, $parameters) } finally { $parameters.Dispose() }
        }
    } finally { $image.Dispose() }
    $relativeFromFiche = if ($Row.File -like "hommes/*") { "../$($portraitRelative -replace '\\','/')" } else { $portraitRelative -replace '\\','/' }
    $content = Get-Content -LiteralPath $Row.FilePath -Raw -Encoding UTF8
    $updated = Set-FirstImageSource -Content $content -Source $relativeFromFiche -Alt "Photographie d'identité de $($Row.Name)"
    Set-Content -LiteralPath $Row.FilePath -Value $updated -Encoding UTF8
}

function Set-BiographyGroup {
    param([string]$Repository, [object]$Row, [string]$Group)
    if (-not $Row.FilePath) { throw "La fiche HTML est absente." }
    $expected = Get-ExpectedGroup -Matricule $Row.Matricule
    if ($expected -and $expected -ne $Group) {
        throw "Le matricule $($Row.Matricule) correspond à $(Get-GroupLabel $expected). Le classement demandé est refusé."
    }
    if ($Row.Group -eq $Group) { return $Row.FilePath }
    $fileName = [IO.Path]::GetFileName($Row.FilePath)
    $destination = if ($Group -eq "hommes") { Join-Path (Join-Path $Repository "hommes") $fileName } else { Join-Path $Repository $fileName }
    if ((Test-Path -LiteralPath $destination) -and $destination -ne $Row.FilePath) { throw "Une fiche portant ce nom existe déjà dans la destination." }
    $content = Get-Content -LiteralPath $Row.FilePath -Raw -Encoding UTF8
    $content = Set-ConvoiMeta -Content $content -Group $Group
    New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
    Set-Content -LiteralPath $Row.FilePath -Value $content -Encoding UTF8
    if ($destination -ne $Row.FilePath) { Move-Item -LiteralPath $Row.FilePath -Destination $destination }
    return $destination
}

function Invoke-SiteRebuild {
    param([string]$Repository)
    $python = Get-PythonCommand
    & $python (Join-Path $Repository "scripts\build_site.py") --root $Repository 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "La reconstruction du site a échoué." }
    & $python (Join-Path $Repository "scripts\verify_catalogs.py") --root $Repository 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Le contrôle des catalogues a échoué." }
}

if ($SelfTest) {
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Web
    if ((Get-ExpectedGroup "31802") -ne "femmes") { throw "Test matricule femme en échec" }
    if ((Get-ExpectedGroup "45437") -ne "hommes") { throw "Test matricule homme en échec" }
    $sample = '<html><head><title>Test</title></head><body><img src="ancienne.jpg"></body></html>'
    $sample = Set-ConvoiMeta -Content $sample -Group "hommes"
    if ($sample -notmatch 'name="convoi" content="45000"') { throw "Test balise convoi en échec" }
    $sample = Set-FirstImageSource -Content $sample -Source "../portraits/test.jpg" -Alt "Test"
    if ($sample -notmatch 'src="\.\./portraits/test\.jpg"') { throw "Test remplacement photo en échec" }
    Write-Host "Autotest réussi : classement, balise convoi et remplacement de photo opérationnels."
    exit 0
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Web
[Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object Windows.Forms.Form
$form.Text = "Vérification des portraits du Panthéon"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object Drawing.Size(1240, 790)
$form.MinimumSize = New-Object Drawing.Size(1100, 700)
$form.Font = New-Object Drawing.Font("Segoe UI", 9.5)
$form.BackColor = [Drawing.Color]::FromArgb(247, 244, 238)

$title = New-Object Windows.Forms.Label
$title.Text = "Vérifier les identités, les photos et le classement"
$title.Font = New-Object Drawing.Font("Segoe UI Semibold", 18)
$title.AutoSize = $true
$title.Location = New-Object Drawing.Point(20, 15)
$form.Controls.Add($title)

$repoText = New-Object Windows.Forms.TextBox
$repoText.Text = Get-SavedRepository
$repoText.Location = New-Object Drawing.Point(22, 58)
$repoText.Size = New-Object Drawing.Size(700, 27)
$repoText.Anchor = "Top,Left,Right"
$form.Controls.Add($repoText)

$browseButton = New-Object Windows.Forms.Button
$browseButton.Text = "Choisir…"
$browseButton.Location = New-Object Drawing.Point(735, 55)
$browseButton.Size = New-Object Drawing.Size(90, 32)
$browseButton.Anchor = "Top,Right"
$form.Controls.Add($browseButton)

$prepareButton = New-Object Windows.Forms.Button
$prepareButton.Text = "Préparer / actualiser"
$prepareButton.Location = New-Object Drawing.Point(835, 55)
$prepareButton.Size = New-Object Drawing.Size(165, 32)
$prepareButton.Anchor = "Top,Right"
$form.Controls.Add($prepareButton)

$filterBox = New-Object Windows.Forms.ComboBox
$filterBox.DropDownStyle = "DropDownList"
[void]$filterBox.Items.AddRange(@("Anomalies seulement", "Tous les portraits", "Femmes 31000", "Hommes 45000", "Sans photo"))
$filterBox.SelectedIndex = 0
$filterBox.Location = New-Object Drawing.Point(1010, 57)
$filterBox.Size = New-Object Drawing.Size(200, 28)
$filterBox.Anchor = "Top,Right"
$form.Controls.Add($filterBox)

$list = New-Object Windows.Forms.ListView
$list.View = "Details"
$list.FullRowSelect = $true
$list.GridLines = $true
$list.HideSelection = $false
$list.Location = New-Object Drawing.Point(22, 102)
$list.Size = New-Object Drawing.Size(780, 520)
$list.Anchor = "Top,Bottom,Left,Right"
[void]$list.Columns.Add("Nom", 210)
[void]$list.Columns.Add("Matricule", 80)
[void]$list.Columns.Add("Section", 115)
[void]$list.Columns.Add("Photo", 120)
[void]$list.Columns.Add("Dimensions", 95)
[void]$list.Columns.Add("Contrôle", 250)
$form.Controls.Add($list)

$previewPanel = New-Object Windows.Forms.Panel
$previewPanel.Location = New-Object Drawing.Point(818, 102)
$previewPanel.Size = New-Object Drawing.Size(392, 520)
$previewPanel.Anchor = "Top,Bottom,Right"
$previewPanel.BorderStyle = "FixedSingle"
$previewPanel.BackColor = [Drawing.Color]::FromArgb(28, 28, 28)
$form.Controls.Add($previewPanel)

$picture = New-Object Windows.Forms.PictureBox
$picture.Location = New-Object Drawing.Point(10, 10)
$picture.Size = New-Object Drawing.Size(370, 350)
$picture.SizeMode = "Zoom"
$picture.Anchor = "Top,Left,Right"
$previewPanel.Controls.Add($picture)

$details = New-Object Windows.Forms.Label
$details.Location = New-Object Drawing.Point(12, 372)
$details.Size = New-Object Drawing.Size(365, 130)
$details.ForeColor = [Drawing.Color]::White
$details.Anchor = "Top,Left,Right,Bottom"
$previewPanel.Controls.Add($details)

$replacePhoto = New-Object Windows.Forms.Button
$replacePhoto.Text = "Remplacer la photo"
$replacePhoto.Location = New-Object Drawing.Point(22, 637)
$replacePhoto.Size = New-Object Drawing.Size(165, 38)
$replacePhoto.Anchor = "Bottom,Left"
$form.Controls.Add($replacePhoto)

$womanButton = New-Object Windows.Forms.Button
$womanButton.Text = "Classer Femme"
$womanButton.Location = New-Object Drawing.Point(197, 637)
$womanButton.Size = New-Object Drawing.Size(135, 38)
$womanButton.Anchor = "Bottom,Left"
$form.Controls.Add($womanButton)

$manButton = New-Object Windows.Forms.Button
$manButton.Text = "Classer Homme"
$manButton.Location = New-Object Drawing.Point(342, 637)
$manButton.Size = New-Object Drawing.Size(135, 38)
$manButton.Anchor = "Bottom,Left"
$form.Controls.Add($manButton)

$editButton = New-Object Windows.Forms.Button
$editButton.Text = "Modifier la fiche"
$editButton.Location = New-Object Drawing.Point(487, 637)
$editButton.Size = New-Object Drawing.Size(135, 38)
$editButton.Anchor = "Bottom,Left"
$form.Controls.Add($editButton)

$refreshButton = New-Object Windows.Forms.Button
$refreshButton.Text = "Recontrôler"
$refreshButton.Location = New-Object Drawing.Point(632, 637)
$refreshButton.Size = New-Object Drawing.Size(120, 38)
$refreshButton.Anchor = "Bottom,Left"
$form.Controls.Add($refreshButton)

$publishButton = New-Object Windows.Forms.Button
$publishButton.Text = "Publier les corrections"
$publishButton.Font = New-Object Drawing.Font("Segoe UI Semibold", 10.5)
$publishButton.BackColor = [Drawing.Color]::FromArgb(31, 94, 66)
$publishButton.ForeColor = [Drawing.Color]::White
$publishButton.FlatStyle = "Flat"
$publishButton.Location = New-Object Drawing.Point(818, 637)
$publishButton.Size = New-Object Drawing.Size(205, 42)
$publishButton.Anchor = "Bottom,Right"
$form.Controls.Add($publishButton)

$openSite = New-Object Windows.Forms.Button
$openSite.Text = "Ouvrir le site"
$openSite.Location = New-Object Drawing.Point(1033, 639)
$openSite.Size = New-Object Drawing.Size(177, 38)
$openSite.Anchor = "Bottom,Right"
$form.Controls.Add($openSite)

$statusLabel = New-Object Windows.Forms.Label
$statusLabel.Text = "Cliquez sur Préparer / actualiser."
$statusLabel.Location = New-Object Drawing.Point(22, 694)
$statusLabel.Size = New-Object Drawing.Size(1188, 38)
$statusLabel.Anchor = "Bottom,Left,Right"
$form.Controls.Add($statusLabel)

$script:records = @()
$script:currentRow = $null

function Set-Status { param([string]$Text) $statusLabel.Text = $Text; [Windows.Forms.Application]::DoEvents() }
function Clear-Preview {
    if ($picture.Image) { $old = $picture.Image; $picture.Image = $null; $old.Dispose() }
    $details.Text = "Sélectionnez un portrait."
    $script:currentRow = $null
}
function Show-Preview {
    param([object]$Row)
    Clear-Preview
    $script:currentRow = $Row
    $number = if ($Row.Matricule) { $Row.Matricule } else { "non trouvé" }
    $details.Text = "$($Row.Name)`r`nMatricule : $number`r`n$($Row.GroupLabel)`r`n$($Row.PhotoState) — $($Row.Dimensions)`r`n$($Row.State)"
    if ($Row.PhotoPath -and (Test-Path -LiteralPath $Row.PhotoPath -PathType Leaf)) {
        try {
            $bytes = [IO.File]::ReadAllBytes($Row.PhotoPath)
            $stream = New-Object IO.MemoryStream(,$bytes)
            try {
                $sourceImage = [Drawing.Image]::FromStream($stream)
                try { $picture.Image = New-Object Drawing.Bitmap($sourceImage) } finally { $sourceImage.Dispose() }
            } finally { $stream.Dispose() }
        } catch { $details.Text += "`r`nAperçu impossible : $($_.Exception.Message)" }
    }
}
function Refresh-List {
    $list.Items.Clear()
    $filter = [string]$filterBox.SelectedItem
    $visible = @($script:records | Where-Object {
        switch ($filter) {
            "Anomalies seulement" { $_.IsProblem }
            "Femmes 31000" { $_.Group -eq "femmes" }
            "Hommes 45000" { $_.Group -eq "hommes" }
            "Sans photo" { $_.PhotoState -ne "Photo présente" }
            default { $true }
        }
    })
    foreach ($row in $visible) {
        $item = New-Object Windows.Forms.ListViewItem($row.Name)
        [void]$item.SubItems.Add($(if ($row.Matricule) { $row.Matricule } else { "-" }))
        [void]$item.SubItems.Add($row.GroupLabel)
        [void]$item.SubItems.Add($row.PhotoState)
        [void]$item.SubItems.Add($row.Dimensions)
        [void]$item.SubItems.Add($row.State)
        $item.Tag = $row
        if ($row.IsProblem) { $item.BackColor = [Drawing.Color]::MistyRose }
        [void]$list.Items.Add($item)
    }
    $problems = @($script:records | Where-Object IsProblem).Count
    Set-Status "$($script:records.Count) fiches contrôlées — $problems anomalie(s) — $($visible.Count) affichée(s)."
    Clear-Preview
}
function Reload-Records {
    $repository = $repoText.Text.Trim()
    Assert-Repository $repository
    Set-Status "Contrôle des fiches et des photographies…"
    $script:records = @(Get-PortraitRecords -Repository $repository)
    Refresh-List
}

$browseButton.Add_Click({
    $dialog = New-Object Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Choisissez le dépôt GitHub local du Panthéon"
    $dialog.SelectedPath = $repoText.Text
    if ($dialog.ShowDialog() -eq "OK") { $repoText.Text = $dialog.SelectedPath; Save-Repository $dialog.SelectedPath }
})
$prepareButton.Add_Click({
    try {
        $prepareButton.Enabled = $false
        $repository = $repoText.Text.Trim()
        if (-not $repository) { throw "Choisissez un dossier GitHub." }
        $git = Get-GitExecutable
        if (-not (Test-Path -LiteralPath $repository)) {
            New-Item -ItemType Directory -Path (Split-Path -Parent $repository) -Force | Out-Null
            Set-Status "Téléchargement du Panthéon depuis GitHub…"
            [void](Invoke-Git $git @("clone", $RepositoryUrl, $repository))
        } elseif (-not (Test-Path -LiteralPath (Join-Path $repository ".git") -PathType Container)) {
            if (@(Get-ChildItem -LiteralPath $repository -Force).Count) { throw "Ce dossier n'est pas vide et n'est pas le dépôt GitHub." }
            Set-Status "Téléchargement du Panthéon depuis GitHub…"
            [void](Invoke-Git $git @("clone", $RepositoryUrl, $repository))
        } else {
            Assert-Repository $repository
            $dirty = Invoke-Git $git @("-C", $repository, "status", "--porcelain")
            if ($dirty.Output) { throw "Des corrections locales ne sont pas encore publiées. Publiez-les avant d'actualiser depuis GitHub." }
            Set-Status "Actualisation depuis GitHub…"
            [void](Invoke-Git $git @("-C", $repository, "switch", "main"))
            [void](Invoke-Git $git @("-C", $repository, "pull", "--rebase", "origin", "main"))
        }
        Set-GitIdentity -Git $git -Repository $repository
        Save-Repository $repository
        Invoke-SiteRebuild -Repository $repository
        Reload-Records
    } catch {
        Set-Status "Préparation impossible."
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, "Erreur", "OK", "Error") | Out-Null
    } finally { $prepareButton.Enabled = $true }
})
$filterBox.Add_SelectedIndexChanged({ if ($script:records.Count) { Refresh-List } })
$list.Add_SelectedIndexChanged({ if ($list.SelectedItems.Count) { Show-Preview $list.SelectedItems[0].Tag } })
$list.Add_DoubleClick({ if ($script:currentRow -and $script:currentRow.FilePath) { Start-Process notepad.exe -ArgumentList @($script:currentRow.FilePath) } })
$replacePhoto.Add_Click({
    try {
        if (-not $script:currentRow) { throw "Sélectionnez d'abord une personne." }
        $dialog = New-Object Windows.Forms.OpenFileDialog
        $dialog.Title = "Choisissez la bonne photographie d'identité"
        $dialog.Filter = "Images (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp"
        if ($dialog.ShowDialog() -ne "OK") { return }
        Save-IdentityPhoto -Repository $repoText.Text.Trim() -Row $script:currentRow -SourcePath $dialog.FileName
        Invoke-SiteRebuild -Repository $repoText.Text.Trim()
        Reload-Records
        Set-Status "Photo remplacée. Vérifiez-la puis cliquez sur Publier les corrections."
    } catch { [Windows.Forms.MessageBox]::Show($_.Exception.Message, "Erreur", "OK", "Error") | Out-Null }
})
function Change-SelectedGroup {
    param([string]$Group)
    try {
        if (-not $script:currentRow) { throw "Sélectionnez d'abord une personne." }
        [void](Set-BiographyGroup -Repository $repoText.Text.Trim() -Row $script:currentRow -Group $Group)
        Invoke-SiteRebuild -Repository $repoText.Text.Trim()
        Reload-Records
        Set-Status "Classement corrigé. Cliquez sur Publier les corrections."
    } catch { [Windows.Forms.MessageBox]::Show($_.Exception.Message, "Classement refusé", "OK", "Error") | Out-Null }
}
$womanButton.Add_Click({ Change-SelectedGroup "femmes" })
$manButton.Add_Click({ Change-SelectedGroup "hommes" })
$editButton.Add_Click({
    if ($script:currentRow -and $script:currentRow.FilePath) { Start-Process notepad.exe -ArgumentList @($script:currentRow.FilePath) }
    else { [Windows.Forms.MessageBox]::Show("Sélectionnez d'abord une personne.", "Information", "OK", "Information") | Out-Null }
})
$refreshButton.Add_Click({
    try { Invoke-SiteRebuild -Repository $repoText.Text.Trim(); Reload-Records } catch { [Windows.Forms.MessageBox]::Show($_.Exception.Message, "Erreur", "OK", "Error") | Out-Null }
})
$publishButton.Add_Click({
    try {
        $publishButton.Enabled = $false
        $repository = $repoText.Text.Trim()
        Assert-Repository $repository
        Set-Status "Contrôle final du site…"
        Invoke-SiteRebuild -Repository $repository
        $git = Get-GitExecutable
        Set-GitIdentity -Git $git -Repository $repository
        $dirty = Invoke-Git $git @("-C", $repository, "status", "--porcelain")
        if (-not $dirty.Output) { throw "Aucune correction n'est à publier." }
        Set-Status "Enregistrement des corrections…"
        [void](Invoke-Git $git @("-C", $repository, "add", "--all"))
        [void](Invoke-Git $git @("-C", $repository, "commit", "-m", "Corriger le classement et les portraits d'identité"))
        Set-Status "Envoi sur GitHub…"
        [void](Invoke-Git $git @("-C", $repository, "pull", "--rebase", "origin", "main"))
        [void](Invoke-Git $git @("-C", $repository, "push", "origin", "main"))
        Reload-Records
        Set-Status "Corrections publiées. GitHub met le site à jour dans quelques instants."
        [Windows.Forms.MessageBox]::Show("Les corrections ont été envoyées sur GitHub.", "Publication réussie", "OK", "Information") | Out-Null
    } catch {
        Set-Status "Publication interrompue."
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, "Erreur", "OK", "Error") | Out-Null
    } finally { $publishButton.Enabled = $true }
})
$openSite.Add_Click({ Start-Process $SiteUrl })
$form.Add_FormClosed({ Clear-Preview })
[void]$form.ShowDialog()

