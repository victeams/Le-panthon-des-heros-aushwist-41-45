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

    $output = & $Git @Arguments 2>&1 | Out-String
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0 -and -not $AllowFailure) {
        throw "Commande Git impossible :`r`n$output"
    }
    return [PSCustomObject]@{ ExitCode = $exitCode; Output = $output.Trim() }
}

function Get-SavedRepository {
    if (Test-Path -LiteralPath $ConfigPath) {
        try {
            $config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($config.repository) { return [string]$config.repository }
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
        '<html><body>Matricule 31802</body></html>' | Set-Content -LiteralPath $woman -Encoding UTF8
        '<html><head><meta name="convoi" content="45000"></head></html>' | Set-Content -LiteralPath $man -Encoding UTF8
        '<html><body>Notice</body></html>' | Set-Content -LiteralPath $unknown -Encoding UTF8
        if ((Get-FicheCategory $woman) -ne "femmes") { throw "Test femme en échec" }
        if ((Get-FicheCategory $man) -ne "hommes") { throw "Test homme en échec" }
        if ((Get-FicheCategory $unknown) -ne "a_choisir") { throw "Test fiche ambiguë en échec" }
        if ((Get-FicheCategory $unknown "Hommes 45000") -ne "hommes") { throw "Test choix manuel en échec" }
        Write-Host "Autotest réussi : détection Femmes/Hommes opérationnelle."
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
$repoLabel.Text = "Dossier GitHub sur cet ordinateur"
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
[void]$list.Columns.Add("Fichier", 360)
[void]$list.Columns.Add("Catégorie", 150)
[void]$list.Columns.Add("Destination", 275)
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
    foreach ($path in $script:selectedFiles) {
        $category = Get-FicheCategory -Path $path -ForcedCategory $categoryBox.SelectedItem
        $categoryText = switch ($category) {
            "femmes" { "Femme 31000" }
            "hommes" { "Homme 45000" }
            default { "À choisir" }
        }
        $destination = if ($category -eq "hommes") { "hommes/" + [IO.Path]::GetFileName($path) } elseif ($category -eq "femmes") { [IO.Path]::GetFileName($path) } else { "Choisissez la catégorie ci-dessus" }
        $item = New-Object Windows.Forms.ListViewItem([IO.Path]::GetFileName($path))
        [void]$item.SubItems.Add($categoryText)
        [void]$item.SubItems.Add($destination)
        $item.Tag = $path
        [void]$list.Items.Add($item)
    }
}

function Assert-Repository {
    param([string]$Repository)
    if (-not (Test-Path -LiteralPath (Join-Path $Repository ".git") -PathType Container)) {
        throw "Le dossier GitHub n’est pas encore préparé. Cliquez d’abord sur Préparer."
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
            if ($existing.Count -gt 0) { throw "Le dossier choisi n’est pas vide et n’est pas un dépôt GitHub." }
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
            $entries += [PSCustomObject]@{ Source = $source; Relative = $relative; Category = $category }
        }

        $git = Get-GitExecutable
        $dirty = Invoke-Git $git @("-C", $repository, "status", "--porcelain")
        if ($dirty.Output) { throw "Le dossier GitHub contient déjà des modifications. Envoyez-les ou annulez-les avant d’ajouter de nouvelles fiches." }

        $statusLabel.Text = "Mise à jour depuis GitHub…"
        [void](Invoke-Git $git @("-C", $repository, "switch", "main"))
        Add-Log (Invoke-Git $git @("-C", $repository, "pull", "--rebase", "origin", "main")).Output

        $existing = @($entries | Where-Object { Test-Path -LiteralPath (Join-Path $repository ($_.Relative -replace '/', '\')) })
        if ($existing.Count -gt 0) {
            $names = ($existing | ForEach-Object { $_.Relative }) -join "`r`n"
            $answer = [Windows.Forms.MessageBox]::Show("Ces fiches existent déjà et seront remplacées :`r`n`r`n$names`r`n`r`nContinuer ?", "Confirmation", "YesNo", "Warning")
            if ($answer -ne "Yes") { throw "Envoi annulé : aucune fiche n’a été remplacée." }
        }

        $statusLabel.Text = "Copie et envoi des fiches…"
        foreach ($entry in $entries) {
            $destination = Join-Path $repository ($entry.Relative -replace '/', '\')
            $destinationDirectory = Split-Path -Parent $destination
            New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
            Copy-Item -LiteralPath $entry.Source -Destination $destination -Force
            Add-Log "Ajout : $($entry.Relative)"
        }

        $relativePaths = @($entries | ForEach-Object { $_.Relative })
        [void](Invoke-Git $git (@("-C", $repository, "add", "--") + $relativePaths))
        $staged = Invoke-Git $git @("-C", $repository, "diff", "--cached", "--quiet") -AllowFailure
        if ($staged.ExitCode -eq 0) {
            $statusLabel.Text = "Aucun changement à envoyer."
            [Windows.Forms.MessageBox]::Show("Ces fiches sont déjà identiques sur GitHub.", "Aucun changement", "OK", "Information") | Out-Null
            return
        }

        $message = "Ajouter $($entries.Count) fiche(s) depuis l'outil Windows"
        Add-Log (Invoke-Git $git @("-C", $repository, "commit", "-m", $message)).Output
        Add-Log (Invoke-Git $git @("-C", $repository, "push", "origin", "main")).Output
        $statusLabel.Text = "Envoi réussi. GitHub met maintenant le site à jour."
        $script:selectedFiles.Clear()
        Refresh-FileList
        [Windows.Forms.MessageBox]::Show("Les fiches ont été envoyées sur GitHub.`r`nLe site sera mis à jour automatiquement dans quelques instants.", "Envoi réussi", "OK", "Information") | Out-Null
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
