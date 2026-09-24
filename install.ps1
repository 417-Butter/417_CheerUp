# ==========================================================================
#  CheerUp! for Cascadeur ---- Windows Installer
#  install.ps1   (run via install.bat)
# ==========================================================================
#Requires -Version 5.1

[CmdletBinding()]
param(
    [string]$PresetPath = ""
)

# ---------- Constants ----------
$ADDON_ID      = "417_cheerup"
$ADDON_DISPLAY = "CheerUp!"
$ADDON_VERSION = "1.0.0"
$REL_COMMANDS  = "resources\scripts\python\commands"
$REL_MODELS    = "resources\scripts\python\models"
$CASC_EXE_NAMES = @("Cascadeur.exe", "cascadeur.exe", "CascadeurApp.exe")

$SCRIPT_DIR   = Split-Path -Parent (Resolve-Path $MyInvocation.MyCommand.Path)
$SRC_COMMANDS = Join-Path $SCRIPT_DIR "to_cascadeur\commands\$ADDON_ID"
$SRC_MODELS   = Join-Path $SCRIPT_DIR "to_cascadeur\models\$ADDON_ID"

# ---------- .NET / WinForms ----------
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ---------- Colors ----------
$C_BG     = [Drawing.Color]::FromArgb(28, 28, 28)
$C_BG2    = [Drawing.Color]::FromArgb(42, 42, 42)
$C_FG     = [Drawing.Color]::FromArgb(220, 220, 220)
$C_DIM    = [Drawing.Color]::FromArgb(140, 140, 140)
$C_GREEN  = [Drawing.Color]::FromArgb(76, 175, 80)
$C_BLUE   = [Drawing.Color]::FromArgb(33, 150, 243)
$C_YELLOW = [Drawing.Color]::FromArgb(255, 193, 7)
$C_RED    = [Drawing.Color]::FromArgb(244, 67, 54)
$C_ORANGE = [Drawing.Color]::FromArgb(245, 124, 0)
$C_BTN    = [Drawing.Color]::FromArgb(55, 55, 55)
$C_BDRBTN = [Drawing.Color]::FromArgb(88, 88, 88)

# ==========================================================================
#  Helper Functions
# ==========================================================================

function Test-CascadeurPath([string]$Path) {
    if (-not $Path -or -not (Test-Path $Path -PathType Container)) { return $false }
    $hasExe = $CASC_EXE_NAMES | Where-Object { Test-Path (Join-Path $Path $_) }
    if (-not $hasExe) { return $false }
    if (-not (Test-Path (Join-Path $Path $REL_COMMANDS))) { return $false }
    if (-not (Test-Path (Join-Path $Path $REL_MODELS)))   { return $false }
    return $true
}

function Get-InstalledVersion([string]$CascPath) {
    $f = Join-Path $CascPath "$REL_COMMANDS\$ADDON_ID\__init__.py"
    if (-not (Test-Path $f)) { return $null }
    try {
        $txt = [IO.File]::ReadAllText($f, [Text.Encoding]::UTF8)
        $m = [regex]::Match($txt, 'ADDON_VERSION\s*=\s*"([^"]+)"')
        if ($m.Success) { return $m.Groups[1].Value }
        return "< 1.0.0"
    } catch { return "unknown" }
}

function Compare-Versions([string]$a, [string]$b) {
    try   { return ([Version]$a).CompareTo([Version]$b) }
    catch { return [string]::Compare($a, $b, $true) }
}

function Test-CascadeurRunning([string]$CascPath) {
    $procs = Get-Process -Name "Cascadeur","cascadeur","CascadeurApp" -ErrorAction SilentlyContinue
    if (-not $procs) { return $false }
    foreach ($p in $procs) {
        try {
            $exe = $p.MainModule.FileName
            if ($exe -and $exe.StartsWith($CascPath, [StringComparison]::OrdinalIgnoreCase)) {
                return $true
            }
        } catch {}
    }
    return $procs.Count -gt 0
}

function Find-CascadeurInstalls {
    $results = [Collections.Generic.List[string]]::new()

    $candidates = [Collections.Generic.List[string]]@(
        "${env:ProgramFiles}\Cascadeur",
        "${env:ProgramFiles(x86)}\Cascadeur",
        "$env:LOCALAPPDATA\Cascadeur",
        "$env:USERPROFILE\Cascadeur",
        "C:\Cascadeur",
        "D:\Cascadeur"
    )

    foreach ($drive in @("C", "D", "E", "F")) {
        $candidates.Add("${drive}:\Program Files (x86)\Steam\steamapps\common\Cascadeur")
        $candidates.Add("${drive}:\SteamLibrary\steamapps\common\Cascadeur")
        $candidates.Add("${drive}:\Steam\steamapps\common\Cascadeur")
    }

    @(
        "HKLM:\SOFTWARE\Cascadeur",
        "HKLM:\SOFTWARE\WOW6432Node\Cascadeur",
        "HKCU:\SOFTWARE\Cascadeur"
    ) | ForEach-Object {
        if (Test-Path $_) {
            $v = Get-ItemProperty $_ -ErrorAction SilentlyContinue
            foreach ($key in @("InstallPath","Install_Dir","Path")) {
                if ($v.$key) { $candidates.Add($v.$key) }
            }
        }
    }

    foreach ($drive in @("C", "D", "E")) {
        foreach ($root in @("Program Files","Program Files (x86)","Games","Apps","Software")) {
            $dir = "${drive}:\$root"
            if (Test-Path $dir) {
                Get-ChildItem $dir -Directory -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -imatch "cascadeur" } |
                    ForEach-Object { $candidates.Add($_.FullName) }
            }
        }
    }

    foreach ($c in ($candidates | Select-Object -Unique)) {
        if ((Test-CascadeurPath $c) -and ($results -notcontains $c)) {
            $results.Add($c)
        }
    }
    return $results
}

function Invoke-Install([string]$CascPath) {
    function Log([string]$msg) {
        $script:txLog.AppendText("$msg`n")
        $script:txLog.ScrollToCaret()
        [Windows.Forms.Application]::DoEvents()
    }

    $dst_cmd  = Join-Path $CascPath "$REL_COMMANDS\$ADDON_ID"
    $dst_mdl  = Join-Path $CascPath "$REL_MODELS\$ADDON_ID"
    $ts       = Get-Date -Format "yyyyMMdd_HHmmss"
    $backDir  = Join-Path $env:TEMP "CheerUp_backup_$ts"
    $bkCmd    = Join-Path $backDir "commands"
    $bkMdl    = Join-Path $backDir "models"
    $backed   = $false

    try {
        if (Test-Path $dst_cmd) {
            Log "  [backup] commands..."
            New-Item $bkCmd -ItemType Directory -Force | Out-Null
            Copy-Item "$dst_cmd\*" $bkCmd -Recurse -Force -ErrorAction Stop
        }
        if (Test-Path $dst_mdl) {
            Log "  [backup] models..."
            New-Item $bkMdl -ItemType Directory -Force | Out-Null
            Copy-Item "$dst_mdl\*" $bkMdl -Recurse -Force -ErrorAction Stop
        }
        $backed = $true

        Log "  [copy] commands..."
        New-Item $dst_cmd -ItemType Directory -Force | Out-Null
        Copy-Item "$SRC_COMMANDS\*" $dst_cmd -Recurse -Force -ErrorAction Stop

        Log "  [copy] models..."
        New-Item $dst_mdl -ItemType Directory -Force | Out-Null
        Copy-Item "$SRC_MODELS\*" $dst_mdl -Recurse -Force -ErrorAction Stop

        Log "  [verify] checking files..."
        $required = @("$dst_cmd\__init__.py", "$dst_mdl\model.py", "$dst_mdl\view.qml")
        foreach ($r in $required) {
            if (-not (Test-Path $r)) { throw "File missing after copy: $([IO.Path]::GetFileName($r))" }
        }

        Remove-Item $backDir -Recurse -Force -ErrorAction SilentlyContinue
        Log ""
        Log "  [done] Installation complete!"
        return $true

    } catch {
        Log ""
        Log "  [ERROR] $_"
        Log ""

        if ($backed) {
            Log "  [rollback] Restoring previous version..."
            try {
                if (Test-Path $bkCmd) {
                    Remove-Item $dst_cmd -Recurse -Force -ErrorAction SilentlyContinue
                    New-Item $dst_cmd -ItemType Directory -Force | Out-Null
                    Copy-Item "$bkCmd\*" $dst_cmd -Recurse -Force
                    Log "  [rollback] commands restored."
                } elseif (Test-Path $dst_cmd) {
                    Remove-Item $dst_cmd -Recurse -Force -ErrorAction SilentlyContinue
                }
                if (Test-Path $bkMdl) {
                    Remove-Item $dst_mdl -Recurse -Force -ErrorAction SilentlyContinue
                    New-Item $dst_mdl -ItemType Directory -Force | Out-Null
                    Copy-Item "$bkMdl\*" $dst_mdl -Recurse -Force
                    Log "  [rollback] models restored."
                } elseif (Test-Path $dst_mdl) {
                    Remove-Item $dst_mdl -Recurse -Force -ErrorAction SilentlyContinue
                }
                Log "  [rollback] Done."
            } catch {
                Log "  [rollback] FAILED: $_"
                Log "  Backup location: $backDir"
            }
        }
        return $false
    }
}

# ==========================================================================
#  Pre-launch Check
# ==========================================================================

if (-not (Test-Path $SRC_COMMANDS) -or -not (Test-Path $SRC_MODELS)) {
    [Windows.Forms.MessageBox]::Show(
        "Installer files not found.`n`n" +
        "Please place install.bat in the 417_CheerUp folder`n" +
        "(same location as the to_cascadeur folder).",
        "Error - Files Not Found",
        [Windows.Forms.MessageBoxButtons]::OK,
        [Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

# ==========================================================================
#  GUI
# ==========================================================================

$form = New-Object Windows.Forms.Form
$form.Text          = "$ADDON_DISPLAY v$ADDON_VERSION  Installer"
$form.Size          = New-Object Drawing.Size(560, 520)
$form.MinimumSize   = $form.Size
$form.MaximumSize   = $form.Size
$form.StartPosition = "CenterScreen"
$form.BackColor     = $C_BG
$form.ForeColor     = $C_FG
$form.Font          = New-Object Drawing.Font("Segoe UI", 10)

$lbTitle = New-Object Windows.Forms.Label
$lbTitle.Text      = "CheerUp!  Cascadeur Add-on Installer"
$lbTitle.Font      = New-Object Drawing.Font("Segoe UI", 13, [Drawing.FontStyle]::Bold)
$lbTitle.ForeColor = $C_GREEN
$lbTitle.Location  = New-Object Drawing.Point(16, 16)
$lbTitle.Size      = New-Object Drawing.Size(520, 30)
$form.Controls.Add($lbTitle)

$lbVer = New-Object Windows.Forms.Label
$lbVer.Text      = "Version  v$ADDON_VERSION"
$lbVer.ForeColor = $C_DIM
$lbVer.Location  = New-Object Drawing.Point(18, 50)
$lbVer.Size      = New-Object Drawing.Size(300, 20)
$form.Controls.Add($lbVer)

$sep1 = New-Object Windows.Forms.Panel
$sep1.BackColor = [Drawing.Color]::FromArgb(58, 58, 58)
$sep1.Location  = New-Object Drawing.Point(16, 76)
$sep1.Size      = New-Object Drawing.Size(520, 1)
$form.Controls.Add($sep1)

$lbPath = New-Object Windows.Forms.Label
$lbPath.Text      = "Cascadeur Installation Folder:"
$lbPath.ForeColor = $C_FG
$lbPath.Location  = New-Object Drawing.Point(16, 88)
$lbPath.Size      = New-Object Drawing.Size(350, 22)
$form.Controls.Add($lbPath)

$script:txPath = New-Object Windows.Forms.TextBox
$script:txPath.Location    = New-Object Drawing.Point(16, 112)
$script:txPath.Size        = New-Object Drawing.Size(412, 28)
$script:txPath.BackColor   = [Drawing.Color]::FromArgb(48, 48, 48)
$script:txPath.ForeColor   = $C_FG
$script:txPath.BorderStyle = "FixedSingle"
$form.Controls.Add($script:txPath)

$btBrowse = New-Object Windows.Forms.Button
$btBrowse.Text      = "Browse..."
$btBrowse.Location  = New-Object Drawing.Point(434, 110)
$btBrowse.Size      = New-Object Drawing.Size(102, 30)
$btBrowse.BackColor = $C_BTN
$btBrowse.ForeColor = $C_FG
$btBrowse.FlatStyle = "Flat"
$btBrowse.FlatAppearance.BorderColor = $C_BDRBTN
$form.Controls.Add($btBrowse)

$lbStatus = New-Object Windows.Forms.Label
$lbStatus.Text      = "Searching for Cascadeur..."
$lbStatus.ForeColor = $C_DIM
$lbStatus.Location  = New-Object Drawing.Point(16, 148)
$lbStatus.Size      = New-Object Drawing.Size(520, 52)
$form.Controls.Add($lbStatus)

$script:txLog = New-Object Windows.Forms.RichTextBox
$script:txLog.Location    = New-Object Drawing.Point(16, 208)
$script:txLog.Size        = New-Object Drawing.Size(520, 176)
$script:txLog.BackColor   = [Drawing.Color]::FromArgb(16, 16, 16)
$script:txLog.ForeColor   = [Drawing.Color]::FromArgb(168, 168, 168)
$script:txLog.Font        = New-Object Drawing.Font("Consolas", 9)
$script:txLog.ReadOnly    = $true
$script:txLog.BorderStyle = "FixedSingle"
$script:txLog.ScrollBars  = "Vertical"
$form.Controls.Add($script:txLog)

$sep2 = New-Object Windows.Forms.Panel
$sep2.BackColor = [Drawing.Color]::FromArgb(58, 58, 58)
$sep2.Location  = New-Object Drawing.Point(16, 396)
$sep2.Size      = New-Object Drawing.Size(520, 1)
$form.Controls.Add($sep2)

$lbNote = New-Object Windows.Forms.Label
$lbNote.Text      = "Your settings in AppData will not be changed."
$lbNote.ForeColor = $C_DIM
$lbNote.Location  = New-Object Drawing.Point(16, 404)
$lbNote.Size      = New-Object Drawing.Size(400, 20)
$form.Controls.Add($lbNote)

$script:btInstall = New-Object Windows.Forms.Button
$script:btInstall.Text      = "Install"
$script:btInstall.Location  = New-Object Drawing.Point(294, 428)
$script:btInstall.Size      = New-Object Drawing.Size(130, 42)
$script:btInstall.BackColor = $C_GREEN
$script:btInstall.ForeColor = [Drawing.Color]::White
$script:btInstall.FlatStyle = "Flat"
$script:btInstall.FlatAppearance.BorderSize = 0
$script:btInstall.Font      = New-Object Drawing.Font("Segoe UI", 11, [Drawing.FontStyle]::Bold)
$script:btInstall.Enabled   = $false
$form.Controls.Add($script:btInstall)

$btClose = New-Object Windows.Forms.Button
$btClose.Text         = "Close"
$btClose.Location     = New-Object Drawing.Point(434, 428)
$btClose.Size         = New-Object Drawing.Size(102, 42)
$btClose.BackColor    = $C_BTN
$btClose.ForeColor    = $C_FG
$btClose.FlatStyle    = "Flat"
$btClose.FlatAppearance.BorderColor = $C_BDRBTN
$btClose.Add_Click({ $form.Close() })
$form.Controls.Add($btClose)
$form.CancelButton = $btClose

# ==========================================================================
#  State
# ==========================================================================
$script:selPath      = ""
$script:installedVer = $null

# ==========================================================================
#  Path Validation & Status Update
# ==========================================================================
function Update-PathStatus([string]$path) {
    $p = $path.Trim()
    if (-not $p) {
        $lbStatus.Text      = "Please enter or Browse to select the Cascadeur folder."
        $lbStatus.ForeColor = $C_YELLOW
        $script:btInstall.Enabled = $false
        $script:selPath = ""
        return
    }
    if (Test-CascadeurPath $p) {
        $script:selPath      = $p
        $script:installedVer = Get-InstalledVersion $p
        if ($null -eq $script:installedVer) {
            $lbStatus.Text      = "Cascadeur found.`n   -> New installation"
            $lbStatus.ForeColor = $C_GREEN
            $script:btInstall.Text      = "Install"
            $script:btInstall.BackColor = $C_GREEN
        } else {
            $cmp = Compare-Versions $ADDON_VERSION $script:installedVer
            if ($cmp -gt 0) {
                $lbStatus.Text      = "Cascadeur found.`n   -> Update: v$($script:installedVer) -> v$ADDON_VERSION"
                $lbStatus.ForeColor = $C_GREEN
                $script:btInstall.Text      = "Update"
                $script:btInstall.BackColor = $C_GREEN
            } elseif ($cmp -eq 0) {
                $lbStatus.Text      = "Same version (v$ADDON_VERSION) already installed.`n   -> Reinstall?"
                $lbStatus.ForeColor = $C_BLUE
                $script:btInstall.Text      = "Reinstall"
                $script:btInstall.BackColor = $C_BLUE
            } else {
                $lbStatus.Text      = "Newer version (v$($script:installedVer)) already installed.`n   -> Downgrade to v$ADDON_VERSION?"
                $lbStatus.ForeColor = $C_YELLOW
                $script:btInstall.Text      = "Downgrade"
                $script:btInstall.BackColor = $C_ORANGE
            }
        }
        $script:btInstall.Enabled = $true
    } else {
        $lbStatus.Text      = "Not a valid Cascadeur folder.`n   (Cascadeur.exe + resources\scripts\python\ required)"
        $lbStatus.ForeColor = $C_RED
        $script:btInstall.Enabled = $false
        $script:selPath = ""
    }
}

# ==========================================================================
#  Events
# ==========================================================================

$script:txPath.Add_TextChanged({ Update-PathStatus $script:txPath.Text })

$btBrowse.Add_Click({
    $dlg = New-Object Windows.Forms.FolderBrowserDialog
    $dlg.Description        = "Select the Cascadeur installation folder`n(e.g. C:\Program Files\Cascadeur)"
    $dlg.ShowNewFolderButton = $false
    if ($script:selPath) { $dlg.SelectedPath = $script:selPath }
    if ($dlg.ShowDialog($form) -eq "OK") {
        $script:txPath.Text = $dlg.SelectedPath
    }
})

$script:btInstall.Add_Click({
    $p    = $script:selPath
    $iVer = $script:installedVer

    if (Test-CascadeurRunning $p) {
        $ans = [Windows.Forms.MessageBox]::Show(
            "Cascadeur appears to be running.`n" +
            "Installing while Cascadeur is open may cause file lock errors.`n`n" +
            "It is recommended to close Cascadeur first.`n`n" +
            "Continue anyway?",
            "Warning - Cascadeur is Running",
            [Windows.Forms.MessageBoxButtons]::YesNo,
            [Windows.Forms.MessageBoxIcon]::Warning,
            [Windows.Forms.MessageBoxDefaultButton]::Button2
        )
        if ($ans -ne "Yes") { return }
    }

    $confirmMsg = if ($iVer) {
        "Update $ADDON_DISPLAY?`n`n" +
        "   Current version :  v$iVer`n" +
        "   New version     :  v$ADDON_VERSION`n`n" +
        "   Install to:`n   $p"
    } else {
        "Install $ADDON_DISPLAY v$ADDON_VERSION?`n`n" +
        "   Install to:`n   $p"
    }
    $ans = [Windows.Forms.MessageBox]::Show(
        $confirmMsg,
        "Confirm Installation",
        [Windows.Forms.MessageBoxButtons]::YesNo,
        [Windows.Forms.MessageBoxIcon]::Question,
        [Windows.Forms.MessageBoxDefaultButton]::Button2
    )
    if ($ans -ne "Yes") { return }

    $script:btInstall.Enabled = $false
    $btBrowse.Enabled         = $false
    $script:txPath.Enabled    = $false
    $script:txLog.Clear()
    $script:txLog.AppendText("Started: $(Get-Date -Format 'HH:mm:ss')`n")
    $script:txLog.AppendText("Install to: $p`n`n")
    [Windows.Forms.Application]::DoEvents()

    $ok = Invoke-Install -CascPath $p

    if ($ok) {
        [Windows.Forms.MessageBox]::Show(
            "$ADDON_DISPLAY v$ADDON_VERSION installed successfully!`n`n" +
            "Next steps:`n" +
            "1. Restart Cascadeur`n" +
            "2. Go to menu: Commands > 417_cheerup > $ADDON_DISPLAY`n`n" +
            "Happy animating!",
            "Installation Complete",
            [Windows.Forms.MessageBoxButtons]::OK,
            [Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
        $lbStatus.Text      = "Installation complete! Please restart Cascadeur."
        $lbStatus.ForeColor = $C_GREEN
        $script:btInstall.Text      = "Done"
        $script:btInstall.BackColor = [Drawing.Color]::FromArgb(50, 50, 50)
        $script:btInstall.ForeColor = $C_DIM
    } else {
        [Windows.Forms.MessageBox]::Show(
            "An error occurred during installation.`n" +
            "Please check the log for details.`n`n" +
            "The previous version has been restored if possible.`n`n" +
            "For manual installation, see the to_cascadeur folder.",
            "Installation Error",
            [Windows.Forms.MessageBoxButtons]::OK,
            [Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
        $script:btInstall.Enabled = $true
        $btBrowse.Enabled         = $true
        $script:txPath.Enabled    = $true
    }
})

# ==========================================================================
#  Auto-detect on Show
# ==========================================================================
$initTimer = New-Object Windows.Forms.Timer
$initTimer.Interval = 150
$initTimer.Add_Tick({
    $initTimer.Stop()

    $script:txLog.AppendText("Searching for Cascadeur installations...`n")
    [Windows.Forms.Application]::DoEvents()

    $found = Find-CascadeurInstalls

    if ($found.Count -gt 0) {
        $script:txLog.AppendText("Found ($($found.Count)):`n")
        foreach ($f in $found) { $script:txLog.AppendText("  $f`n") }
        if ($found.Count -gt 1) {
            $script:txLog.AppendText("`nMultiple found. Use Browse to select the correct one.`n")
        }
        $script:txPath.Text = $found[0]
    } else {
        $script:txLog.AppendText("Auto-detect failed. Use Browse to select manually.`n")
        $lbStatus.Text      = "Cascadeur not found. Please use Browse to select."
        $lbStatus.ForeColor = $C_YELLOW
    }

    if ($PresetPath -and (Test-CascadeurPath $PresetPath)) {
        $script:txPath.Text = $PresetPath
    }
})
$form.Add_Shown({ $initTimer.Start() })

# ==========================================================================
#  Run
# ==========================================================================
[Windows.Forms.Application]::Run($form)
