param(
    [switch]$SelfTest
)

$ErrorActionPreference = "Stop"
$RepositoryUrl = "https://github.com/victeams/Le-panthon-des-heros-aushwist-41-45.git"
$DefaultRepository = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Le-panthon-des-heros-aushwist-41-45"
$ConfigDirectory = Join-Path $env:APPDATA "EnvoiFichesMemoire"
$ConfigPath = Join-Path $ConfigDirectory "config.json"

function Get-FicheCategory {
    param(
        [Parameter(Mandatory)] [string]$Path,
        [string]$ForcedCategory = "Automatique"
    )

    if ($ForcedCategory -eq "Femmes 31000") { return "femmes" }
    if ($ForcedCategory -eq "Hommes 45000") { return "hommes" }

    $name = [IO.Path]::GetFileNameWithoutExtension($Path)
    $content = ""
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    }
    $searchable = "$name`n$content"

    $isWoman = $searchable -match '(?<!\d)31\d{3}(?!\d)' -or
        $searchable -match '(?is)<meta\s+[^>]*name=["'']convoi["''][^>]*content=["'']31000["'']'
    $isMan = $searchable -match '(?<!\d)(?:45|46)\d{3}(?!\d)' -or
        $searchable -match '(?is)<meta\s+[^>]*name=["'']convoi["''][^>]*content=["'']45000["'']'

    if ($isWoman -and -not $isMan) { return "femmes" }
    if ($isMan -and -not $isWoman) { return "hommes" }
    return "a_choisir"
}

function Get-FicheMatricule {
    param(
        [Parameter(Mandatory)] [string]$Path,
        [Parameter(Mandatory)] [string]$Category
    )

    $name = [IO.Path]::GetFileNameWithoutExtension($Path)
    $nameMatches = [regex]::Matches($name, '(?<!\d)(?:31|45|46)\d{3}(?!\d)')
    $numbers = @($nameMatches | ForEach-Object { $_.Value } | Select-Object -Unique)
    if ($Category -eq "femmes") {
        $numbers = @($numbers | Where-Object { $_ -like '31*' -and $_ -ne '31000' })
    } elseif ($Category -eq "hommes") {
        $numbers = @($numbers | Where-Object { ($_ -like '45*' -or $_ -like '46*') -and $_ -ne '45000' })
    }
    if ($numbers.Count -eq 1) { return $numbers[0] }

    $content = ""
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    }
    $contentMatches = [regex]::Matches($content, '(?<!\d)(?:31|45|46)\d{3}(?!\d)')
    $numbers = @($contentMatches | ForEach-Object { $_.Value } | Select-Object -Unique)
    if ($Category -eq "femmes") {
        $numbers = @($numbers | Where-Object { $_ -like '31*' -and $_ -ne '31000' })
    } elseif ($Category -eq "hommes") {
        $numbers = @($numbers | Where-Object { ($_ -like '45*' -or $_ -like '46*') -and $_ -ne '45000' })
    }
    if ($numbers.Count -eq 1) { return $numbers[0] }
    return $null
}

function Get-ExistingFicheMap {
    param([Parameter(Mandatory)] [string]$Repository)

    $map = @{}
    $dataPath = Join-Path $Repository "site-data.json"
    if (-not (Test-Path -LiteralPath $dataPath -PathType Leaf)) { return $map }
    try {
        $records = Get-Content -LiteralPath $dataPath -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($record in $records) {
            if (-not $record.group -or -not $record.matricule -or -not $record.file) { continue }
            $key = "$($record.group)|$($record.matricule)"
            if ($map.ContainsKey($key)) {
                $map[$key] = "$($map[$key]), $($record.file)"
            } else {
                $map[$key] = [string]$record.file
            }
        }
    } catch { }
    return $map
}

function Write-AlreadyPresentReport {
    param([Parameter(Mandatory)] [object[]]$Entries)

    $reportPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "Fiches deja presentes.txt"
    $lines = @(
        "FICHES DEJA PRESENTES SUR GITHUB",
        "=================================",
        "Controle du $(Get-Date -Format 'dd/MM/yyyy HH:mm')",
        "Nombre : $($Entries.Count)",
        ""
    )
    foreach ($entry in $Entries) {
        $number = if ($entry.Matricule) { "matricule $($entry.Matricule)" } else { "matricule non trouve" }
        $lines += "$([IO.Path]::GetFileName($entry.Source)) | $number | deja sur GitHub : $($entry.ExistingFile)"
    }
    $lines | Set-Content -LiteralPath $reportPath -Encoding UTF8
    return $reportPath
}

function Get-GitExecutable {
    $command = Get-Command git.exe -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }

    $knownPaths = @(
        (Join-Path $env:ProgramFiles "Git\cmd\git.exe"),
        (Join-Path ${env:ProgramFiles(x86)} "Git\cmd\git.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\Git\cmd\git.exe")
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

    if ($knownPaths.Count -gt 0) { return $knownPaths[0] }
    throw "Git pour Windows est introuvable. Installez Git depuis https://git-scm.com/download/win puis relancez l'outil."
}

function Invoke-Git {
    param(
        [Parameter(Mandatory)] [string]$Git,
        [Parameter(Mandatory)] [string[]]$Arguments,
        [switch]$AllowFailure
    )

    # Git écrit certains messages normaux (par exemple « Already on main »)
    # sur la sortie d'erreur. Windows PowerShell ne doit pas les transformer
    # en exception tant que le code de retour de Git est égal à zéro.
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & $Git @Arguments 2>&1 | Out-String
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorAction
    }
    if ($exitCode -ne 0 -and -not $AllowFailure) {
        throw "Commande Git impossible :`r`n$output"
    }
    return [PSCustomObject]@{ ExitCode = $exitCode; Output = $output.Trim() }
}

function Set-GitIdentity {
    param(
        [Parameter(Mandatory)] [string]$Git,
        [Parameter(Mandatory)] [string]$Repository
    )

    $name = Invoke-Git $Git @("-C", $Repository, "config", "--local", "--get", "user.name") -AllowFailure
    if ($name.ExitCode -ne 0 -or -not $name.Output) {
        [void](Invoke-Git $Git @("-C", $Repository, "config", "--local", "user.name", "victeams"))
    }

    $email = Invoke-Git $Git @("-C", $Repository, "config", "--local", "--get", "user.email") -AllowFailure
    if ($email.ExitCode -ne 0 -or -not $email.Output) {
        [void](Invoke-Git $Git @("-C", $Repository, "config", "--local", "user.email", "victeams@users.noreply.github.com"))
    }
}

function Get-SavedRepository {
    if (Test-Path -LiteralPath $ConfigPath) {
        try {
            $config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($config.repository) {
                $saved = [string]$config.repository
                $isRepository = Test-Path -LiteralPath (Join-Path $saved ".git") -PathType Container
                $isNewLocation = -not (Test-Path -LiteralPath $saved)
                $isEmptyLocation = (Test-Path -LiteralPath $saved -PathType Container) -and
                    (@(Get-ChildItem -LiteralPath $saved -Force).Count -eq 0)
                if ($isRepository -or $isNewLocation -or $isEmptyLocation) { return $saved }
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

if ($SelfTest) {
    $testDirectory = Join-Path ([IO.Path]::GetTempPath()) ("envoi-fiches-" + [guid]::NewGuid())
    New-Item -ItemType Directory -Path $testDirectory | Out-Null
    try {
        $woman = Join-Path $testDirectory "alice_31802.html"
        $man = Join-Path $testDirectory "pierre.html"
        $unknown = Join-Path $testDirectory "notice.html"
        '<html><body>Matricule 31802. Une source mentionne aussi le matricule 31799.</body></html>' | Set-Content -LiteralPath $woman -Encoding UTF8
        '<html><head><meta name="convoi" content="45000"></head></html>' | Set-Content -LiteralPath $man -Encoding UTF8
        '<html><body>Notice</body></html>' | Set-Content -LiteralPath $unknown -Encoding UTF8
        if ((Get-FicheCategory $woman) -ne "femmes") { throw "Test femme en échec" }
        if ((Get-FicheCategory $man) -ne "hommes") { throw "Test homme en échec" }
        if ((Get-FicheCategory $unknown) -ne "a_choisir") { throw "Test fiche ambiguë en échec" }
        if ((Get-FicheCategory $unknown "Hommes 45000") -ne "hommes") { throw "Test choix manuel en échec" }
        if ((Get-FicheMatricule $woman "femmes") -ne "31802") { throw "Test matricule femme en echec" }
        if ((Get-FicheMatricule $man "hommes") -ne $null) { throw "Test matricule de convoi en echec" }
        @([PSCustomObject]@{ group = "femmes"; matricule = "31802"; file = "alice_31802.html" }) |
            ConvertTo-Json | Set-Content -LiteralPath (Join-Path $testDirectory "site-data.json") -Encoding UTF8
        $existingTest = Get-ExistingFicheMap -Repository $testDirectory
        if (-not $existingTest.ContainsKey("femmes|31802")) { throw "Test liste deja presente en echec" }
        $git = Get-GitExecutable
        $gitTest = Join-Path $testDirectory "depot-test"
        [void](Invoke-Git $git @("init", "-b", "main", $gitTest))
        [void](Invoke-Git $git @("-C", $gitTest, "config", "user.name", "Autotest"))
        [void](Invoke-Git $git @("-C", $gitTest, "config", "user.email", "autotest@example.invalid"))
        "test" | Set-Content -LiteralPath (Join-Path $gitTest "test.txt") -Encoding ASCII
        [void](Invoke-Git $git @("-C", $gitTest, "add", "test.txt"))
        [void](Invoke-Git $git @("-C", $gitTest, "commit", "-m", "Autotest"))
        $normalMessage = Invoke-Git $git @("-C", $gitTest, "switch", "main")
        if ($normalMessage.ExitCode -ne 0) { throw "Test du message Git normal en échec" }
        Write-Host "Autotest réussi : détection et messages Git opérationnels."
        exit 0
    } finally {
        Remove-Item -LiteralPath $testDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object Windows.Forms.Form
$form.Text = "Envoi des fiches vers GitHub"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object Drawing.Size(900, 680)
$form.MinimumSize = New-Object Drawing.Size(820, 600)
$form.Font = New-Object Drawing.Font("Segoe UI", 10)
$form.BackColor = [Drawing.Color]::FromArgb(247, 244, 238)

$title = New-Object Windows.Forms.Label
$title.Text = "Envoyer des fiches Femmes et Hommes"
$title.Font = New-Object Drawing.Font("Segoe UI Semibold", 18)
$title.AutoSize = $true
$title.Location = New-Object Drawing.Point(22, 18)
$form.Controls.Add($title)

$subtitle = New-Object Windows.Forms.Label
$subtitle.Text = "Les femmes vont à la racine du site ; les hommes vont dans le dossier hommes."
$subtitle.AutoSize = $true
$subtitle.ForeColor = [Drawing.Color]::DimGray
$subtitle.Location = New-Object Drawing.Point(25, 57)
$form.Controls.Add($subtitle)

$repoLabel = New-Object Windows.Forms.Label
$repoLabel.Text = "Dossier GitHub sur cet ordinateur (ne pas choisir le dossier contenant vos fiches)"
$repoLabel.AutoSize = $true
$repoLabel.Location = New-Object Drawing.Point(25, 94)
$form.Controls.Add($repoLabel)

$repoText = New-Object Windows.Forms.TextBox
$repoText.Text = Get-SavedRepository
$repoText.Location = New-Object Drawing.Point(25, 119)
$repoText.Size = New-Object Drawing.Size(610, 27)
$repoText.Anchor = "Top,Left,Right"
$form.Controls.Add($repoText)

$browseRepo = New-Object Windows.Forms.Button
$browseRepo.Text = "Choisir…"
$browseRepo.Location = New-Object Drawing.Point(650, 116)
$browseRepo.Size = New-Object Drawing.Size(100, 32)
$browseRepo.Anchor = "Top,Right"
$form.Controls.Add($browseRepo)

$prepareRepo = New-Object Windows.Forms.Button
$prepareRepo.Text = "Préparer"
$prepareRepo.Location = New-Object Drawing.Point(760, 116)
$prepareRepo.Size = New-Object Drawing.Size(100, 32)
$prepareRepo.Anchor = "Top,Right"
$form.Controls.Add($prepareRepo)

$categoryLabel = New-Object Windows.Forms.Label
$categoryLabel.Text = "Classement des fiches"
$categoryLabel.AutoSize = $true
$categoryLabel.Location = New-Object Drawing.Point(25, 164)
$form.Controls.Add($categoryLabel)

$categoryBox = New-Object Windows.Forms.ComboBox
$categoryBox.DropDownStyle = "DropDownList"
[void]$categoryBox.Items.AddRange(@("Automatique", "Femmes 31000", "Hommes 45000"))
$categoryBox.SelectedIndex = 0
$categoryBox.Location = New-Object Drawing.Point(25, 189)
$categoryBox.Size = New-Object Drawing.Size(210, 28)
$form.Controls.Add($categoryBox)

$selectFiles = New-Object Windows.Forms.Button
$selectFiles.Text = "1. Choisir les fiches HTML"
$selectFiles.Location = New-Object Drawing.Point(250, 185)
$selectFiles.Size = New-Object Drawing.Size(230, 36)
$form.Controls.Add($selectFiles)

$clearFiles = New-Object Windows.Forms.Button
$clearFiles.Text = "Effacer la liste"
$clearFiles.Location = New-Object Drawing.Point(492, 185)
$clearFiles.Size = New-Object Drawing.Size(145, 36)
$form.Controls.Add($clearFiles)

$list = New-Object Windows.Forms.ListView
$list.View = "Details"
$list.FullRowSelect = $true
$list.GridLines = $true
$list.Location = New-Object Drawing.Point(25, 235)
$list.Size = New-Object Drawing.Size(835, 220)
$list.Anchor = "Top,Bottom,Left,Right"
[void]$list.Columns.Add("Fichier", 265)
[void]$list.Columns.Add("Catégorie", 120)
[void]$list.Columns.Add("Matricule", 85)
[void]$list.Columns.Add("État", 180)
[void]$list.Columns.Add("Destination", 165)
$form.Controls.Add($list)

$sendButton = New-Object Windows.Forms.Button
$sendButton.Text = "2. Envoyer les fiches sur GitHub"
$sendButton.Font = New-Object Drawing.Font("Segoe UI Semibold", 11)
$sendButton.BackColor = [Drawing.Color]::FromArgb(31, 94, 66)
$sendButton.ForeColor = [Drawing.Color]::White
$sendButton.FlatStyle = "Flat"
$sendButton.Location = New-Object Drawing.Point(25, 470)
$sendButton.Size = New-Object Drawing.Size(315, 45)
$sendButton.Anchor = "Bottom,Left"
$form.Controls.Add($sendButton)

$openSite = New-Object Windows.Forms.Button
$openSite.Text = "Ouvrir le site"
$openSite.Location = New-Object Drawing.Point(350, 474)
$openSite.Size = New-Object Drawing.Size(130, 38)
$openSite.Anchor = "Bottom,Left"
$form.Controls.Add($openSite)

$statusLabel = New-Object Windows.Forms.Label
$statusLabel.Text = "Prêt."
$statusLabel.AutoSize = $true
$statusLabel.Location = New-Object Drawing.Point(25, 525)
$statusLabel.Anchor = "Bottom,Left"
$form.Controls.Add($statusLabel)

$log = New-Object Windows.Forms.TextBox
$log.Multiline = $true
$log.ReadOnly = $true
$log.ScrollBars = "Vertical"
$log.Location = New-Object Drawing.Point(25, 550)
$log.Size = New-Object Drawing.Size(835, 75)
$log.Anchor = "Bottom,Left,Right"
$form.Controls.Add($log)

$script:selectedFiles = New-Object Collections.Generic.List[string]

function Add-Log {
    param([string]$Message)
    $log.AppendText("$Message`r`n")
    $log.SelectionStart = $log.TextLength
    $log.ScrollToCaret()
    [Windows.Forms.Application]::DoEvents()
}

function Refresh-FileList {
    $list.Items.Clear()
    $repository = $repoText.Text.Trim()
    $existingMap = if ($repository -and (Test-Path -LiteralPath (Join-Path $repository "site-data.json"))) {
        Get-ExistingFicheMap -Repository $repository
    } else { @{} }
    foreach ($path in $script:selectedFiles) {
        $category = Get-FicheCategory -Path $path -ForcedCategory $categoryBox.SelectedItem
        $categoryText = switch ($category) {
            "femmes" { "Femme 31000" }
            "hommes" { "Homme 45000" }
            default { "À choisir" }
        }
        $matricule = if ($category -eq "femmes" -or $category -eq "hommes") { Get-FicheMatricule -Path $path -Category $category } else { $null }
        $destination = if ($category -eq "hommes") { "hommes/" + [IO.Path]::GetFileName($path) } elseif ($category -eq "femmes") { [IO.Path]::GetFileName($path) } else { "Choisissez la catégorie ci-dessus" }
        $key = if ($matricule) { "$category|$matricule" } else { $null }
        $exactExists = $repository -and (Test-Path -LiteralPath (Join-Path $repository ($destination -replace '/', '\')) -PathType Leaf)
        $state = if (($key -and $existingMap.ContainsKey($key)) -or $exactExists) { "Déjà présente" } elseif ($category -eq "a_choisir") { "À choisir" } else { "Nouveau" }
        $item = New-Object Windows.Forms.ListViewItem([IO.Path]::GetFileName($path))
        [void]$item.SubItems.Add($categoryText)
        [void]$item.SubItems.Add($(if ($matricule) { $matricule } else { "-" }))
        [void]$item.SubItems.Add($state)
        [void]$item.SubItems.Add($destination)
        $item.Tag = $path
        [void]$list.Items.Add($item)
    }
}

function Assert-Repository {
    param([string]$Repository)
    if (-not (Test-Path -LiteralPath (Join-Path $Repository ".git") -PathType Container)) {
        throw "Le vrai dossier GitHub n’est pas encore préparé. Ne choisissez pas votre dossier de fiches : gardez le chemin proposé dans Documents, puis cliquez sur Préparer."
    }
}

$browseRepo.Add_Click({
    $dialog = New-Object Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Choisissez le dossier local du dépôt GitHub"
    $dialog.SelectedPath = $repoText.Text
    if ($dialog.ShowDialog() -eq "OK") {
        $repoText.Text = $dialog.SelectedPath
        Save-Repository $repoText.Text
    }
})

$prepareRepo.Add_Click({
    try {
        $prepareRepo.Enabled = $false
        $statusLabel.Text = "Préparation du dépôt…"
        $repository = $repoText.Text.Trim()
        if (-not $repository) { throw "Choisissez un dossier GitHub." }
        $git = Get-GitExecutable

        if (-not (Test-Path -LiteralPath $repository)) {
            $parent = Split-Path -Parent $repository
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
            Add-Log "Téléchargement du dépôt GitHub…"
            $result = Invoke-Git $git @("clone", $RepositoryUrl, $repository)
            Add-Log $result.Output
        } elseif (-not (Test-Path -LiteralPath (Join-Path $repository ".git") -PathType Container)) {
            $existing = @(Get-ChildItem -LiteralPath $repository -Force)
            if ($existing.Count -gt 0) { throw "Ce dossier contient vos fichiers mais ce n’est pas le dépôt GitHub. Gardez le chemin proposé dans Documents, puis cliquez sur Préparer." }
            Add-Log "Téléchargement du dépôt GitHub…"
            $result = Invoke-Git $git @("clone", $RepositoryUrl, $repository)
            Add-Log $result.Output
        } else {
            $dirty = Invoke-Git $git @("-C", $repository, "status", "--porcelain")
            if ($dirty.Output) { throw "Le dossier contient déjà des modifications non envoyées. Réglez-les avant de continuer." }
            Add-Log "Mise à jour du dépôt…"
            [void](Invoke-Git $git @("-C", $repository, "switch", "main"))
            $result = Invoke-Git $git @("-C", $repository, "pull", "--rebase", "origin", "main")
            Add-Log $result.Output
        }
        Set-GitIdentity -Git $git -Repository $repository
        Save-Repository $repository
        $statusLabel.Text = "Dépôt prêt. Vous pouvez choisir les fiches."
        [Windows.Forms.MessageBox]::Show("Le dossier GitHub est prêt.", "Préparation réussie", "OK", "Information") | Out-Null
    } catch {
        $statusLabel.Text = "Préparation impossible."
        Add-Log $_.Exception.Message
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, "Erreur", "OK", "Error") | Out-Null
    } finally {
        $prepareRepo.Enabled = $true
    }
})

$selectFiles.Add_Click({
    $dialog = New-Object Windows.Forms.OpenFileDialog
    $dialog.Title = "Choisissez une ou plusieurs fiches HTML"
    $dialog.Filter = "Fiches HTML (*.html)|*.html"
    $dialog.Multiselect = $true
    if ($dialog.ShowDialog() -eq "OK") {
        foreach ($path in $dialog.FileNames) {
            if (-not $script:selectedFiles.Contains($path)) { $script:selectedFiles.Add($path) }
        }
        Refresh-FileList
        $statusLabel.Text = "$($script:selectedFiles.Count) fiche(s) sélectionnée(s)."
    }
})

$clearFiles.Add_Click({
    $script:selectedFiles.Clear()
    Refresh-FileList
    $statusLabel.Text = "Liste effacée."
})

$categoryBox.Add_SelectedIndexChanged({ Refresh-FileList })

$sendButton.Add_Click({
    try {
        $sendButton.Enabled = $false
        $repository = $repoText.Text.Trim()
        Assert-Repository $repository
        if ($script:selectedFiles.Count -eq 0) { throw "Choisissez au moins une fiche HTML." }

        $entries = @()
        foreach ($source in $script:selectedFiles) {
            $category = Get-FicheCategory -Path $source -ForcedCategory $categoryBox.SelectedItem
            if ($category -eq "a_choisir") {
                throw "La catégorie de $([IO.Path]::GetFileName($source)) est inconnue. Choisissez Femmes 31000 ou Hommes 45000 dans la liste."
            }
            $relative = if ($category -eq "hommes") { "hommes/" + [IO.Path]::GetFileName($source) } else { [IO.Path]::GetFileName($source) }
            $matricule = Get-FicheMatricule -Path $source -Category $category
            $entries += [PSCustomObject]@{ Source = $source; Relative = $relative; Category = $category; Matricule = $matricule }
        }

        $git = Get-GitExecutable
        Set-GitIdentity -Git $git -Repository $repository
        $dirty = Invoke-Git $git @("-C", $repository, "status", "--porcelain")
        if ($dirty.Output) { throw "Le dossier GitHub contient déjà des modifications. Envoyez-les ou annulez-les avant d’ajouter de nouvelles fiches." }

        $statusLabel.Text = "Mise à jour depuis GitHub…"
        [void](Invoke-Git $git @("-C", $repository, "switch", "main"))
        Add-Log (Invoke-Git $git @("-C", $repository, "pull", "--rebase", "origin", "main")).Output

        $existingMap = Get-ExistingFicheMap -Repository $repository
        $alreadyPresent = @()
        $newEntries = @()
        $seenSelection = @{}
        foreach ($entry in $entries) {
            $key = if ($entry.Matricule) { "$($entry.Category)|$($entry.Matricule)" } else { $null }
            $exactDestination = Test-Path -LiteralPath (Join-Path $repository ($entry.Relative -replace '/', '\'))
            $existingFile = $null
            if ($key -and $existingMap.ContainsKey($key)) {
                $existingFile = $existingMap[$key]
            } elseif ($exactDestination) {
                $existingFile = $entry.Relative
            } elseif ($key -and $seenSelection.ContainsKey($key)) {
                $existingFile = "déjà dans cette sélection : $($seenSelection[$key])"
            }

            if ($existingFile) {
                $alreadyPresent += [PSCustomObject]@{
                    Source = $entry.Source
                    Relative = $entry.Relative
                    Category = $entry.Category
                    Matricule = $entry.Matricule
                    ExistingFile = $existingFile
                }
                Add-Log "Déjà présente, ignorée : $($entry.Relative)"
            } else {
                $newEntries += $entry
                if ($key) { $seenSelection[$key] = $entry.Relative }
            }
        }

        $reportPath = $null
        if ($alreadyPresent.Count -gt 0) {
            $reportPath = Write-AlreadyPresentReport -Entries $alreadyPresent
            Add-Log "Liste des fiches déjà présentes : $reportPath"
        }
        if ($newEntries.Count -eq 0) {
            $statusLabel.Text = "Toutes les fiches sont déjà présentes."
            Refresh-FileList
            [Windows.Forms.MessageBox]::Show("Aucune fiche n’a été renvoyée car elles sont toutes déjà sur GitHub.`r`n`r`nLa liste a été créée sur le Bureau :`r`n$reportPath", "Fiches déjà faites", "OK", "Information") | Out-Null
            return
        }

        $statusLabel.Text = "Copie et envoi des fiches…"
        foreach ($entry in $newEntries) {
            $destination = Join-Path $repository ($entry.Relative -replace '/', '\')
            $destinationDirectory = Split-Path -Parent $destination
            New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
            Copy-Item -LiteralPath $entry.Source -Destination $destination -Force
            Add-Log "Ajout : $($entry.Relative)"
        }

        $relativePaths = @($newEntries | ForEach-Object { $_.Relative })
        [void](Invoke-Git $git (@("-C", $repository, "add", "--") + $relativePaths))
        $staged = Invoke-Git $git @("-C", $repository, "diff", "--cached", "--quiet") -AllowFailure
        if ($staged.ExitCode -eq 0) {
            $statusLabel.Text = "Aucun changement à envoyer."
            [Windows.Forms.MessageBox]::Show("Ces fiches sont déjà identiques sur GitHub.", "Aucun changement", "OK", "Information") | Out-Null
            return
        }

        $message = "Ajouter $($newEntries.Count) fiche(s) depuis l'outil Windows"
        Add-Log (Invoke-Git $git @("-C", $repository, "commit", "-m", $message)).Output
        Add-Log (Invoke-Git $git @("-C", $repository, "push", "origin", "main")).Output
        $statusLabel.Text = "Envoi réussi. GitHub met maintenant le site à jour."
        $script:selectedFiles.Clear()
        Refresh-FileList
        $skippedMessage = if ($alreadyPresent.Count -gt 0) { "`r`n$($alreadyPresent.Count) fiche(s) déjà faite(s) ont été ignorées.`r`nListe sur le Bureau : Fiches deja presentes.txt" } else { "" }
        [Windows.Forms.MessageBox]::Show("$($newEntries.Count) nouvelle(s) fiche(s) ont été envoyées sur GitHub.$skippedMessage`r`nLe site sera mis à jour automatiquement dans quelques instants.", "Envoi réussi", "OK", "Information") | Out-Null
    } catch {
        $statusLabel.Text = "Envoi interrompu."
        Add-Log $_.Exception.Message
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, "Erreur", "OK", "Error") | Out-Null
    } finally {
        $sendButton.Enabled = $true
    }
})

$openSite.Add_Click({
    Start-Process "https://victeams.github.io/Le-panthon-des-heros-aushwist-41-45/"
})

[void]$form.ShowDialog()
