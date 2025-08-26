#requires -Version 5.1
<#
  SHA256-Verify-GUI_v2.ps1 (Mizzle edition)
  - Browse or drag a file
  - (Optional) paste the expected SHA-256
  - Click Verify -> shows Actual hash and PASS/FAIL
  - If Expected is empty, we compute Actual only and show "NO EXPECTED"
  Extras: Copy Actual, Clear, Exit, dark Mizzle theme, optional logo.
#>

# --- Self-heal STA only when running as a .ps1 (avoid compiled EXE) ---
if ($PSCommandPath -like '*.ps1' -and -not $env:__MV_Relaunched -and
    [Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    $env:__MV_Relaunched = '1'
    Start-Process -FilePath "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
      -ArgumentList @('-NoLogo','-NoProfile','-WindowStyle','Hidden','-STA','-File',"`"$PSCommandPath`"") `
      -Verb Open
    exit
}

# --- WinForms + Drawing ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Visual styles before creating controls ---
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

# --- Ensure STA (ps2exe will also set -STA; this helps when debugging as a .ps1) ---
if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    try { [System.Threading.Thread]::CurrentThread.ApartmentState = 'STA' } catch {}
}

# --- Create the form ---
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Mizzle Verify'

# --- Use the EXE's own icon for both the window and taskbar ---
$exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
try { $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($exePath) } catch {}

# --- Helpers ---
function Normalize-Hash($s) {
    if ([string]::IsNullOrWhiteSpace($s)) { return '' }
    $clean = -join ($s.ToCharArray() | Where-Object { -not [char]::IsWhiteSpace($_) })
    return $clean.ToUpperInvariant()
}

function Is-Hex64($s) {
    return ($s -match '^[0-9A-F]{64}$')
}

function Compute-FileSHA256($path) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "File not found: $path" }
    return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Show-Result($status) {
    switch ($status)  {
        'PASS'            { $lblResult.Text = 'PASS';             $lblResult.ForeColor = [System.Drawing.Color]::LimeGreen }
        'FAIL'            { $lblResult.Text = 'FAIL';             $lblResult.ForeColor = [System.Drawing.Color]::Crimson }
        'Missing Expected'{ $lblResult.Text = 'Missing Expected'; $lblResult.ForeColor = [System.Drawing.Color]::DeepSkyBlue }
        'ERROR'           { $lblResult.Text = 'ERROR';            $lblResult.ForeColor = [System.Drawing.Color]::OrangeRed }
        default           { $lblResult.Text = '-';                $lblResult.ForeColor = [System.Drawing.Color]::Gray }
    }
}

# --- Config ---
$LogoPath = 'C:\_Local_Dev_Ops\Tools\mizzle-logo.png'  # optional

# --- Optional preselected file from command line (Explorer %1) ---
$InitialFile = $null
if ($args.Count -ge 1) {
    try {
        $cand = $args[0]
        if (Test-Path -LiteralPath $cand -PathType Leaf) {
            $InitialFile = (Resolve-Path -LiteralPath $cand).Path
        }
    } catch { }
}

# --- UI ---
$form                       = New-Object System.Windows.Forms.Form
$form.Text                  = 'Mizzle Verify - SHA-256'
$form.StartPosition         = 'CenterScreen'
$form.FormBorderStyle       = 'FixedDialog'
$form.MaximizeBox           = $false
$form.MinimizeBox           = $true
$form.ClientSize            = New-Object System.Drawing.Size(860, 360)

$baseFont                   = New-Object System.Drawing.Font('Segoe UI', 12)
$titleFont                  = New-Object System.Drawing.Font('Segoe UI Semibold', 18)
$resultFont                 = New-Object System.Drawing.Font('Segoe UI Semibold', 16)
$form.Font                  = $baseFont

# Optional logo
$pbLogo = New-Object System.Windows.Forms.PictureBox
$pbLogo.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
$pbLogo.Location = New-Object System.Drawing.Point(16, 12)
$pbLogo.Size     = New-Object System.Drawing.Size(64, 64)
if (Test-Path -LiteralPath $LogoPath) {
    try { $pbLogo.Image = [System.Drawing.Image]::FromFile($LogoPath) } catch { }
}

$title                      = New-Object System.Windows.Forms.Label
$title.Text                 = "Verify the SHA-256 of a file"
$title.Font                 = $titleFont
$title.AutoSize             = $true
$title.Location             = New-Object System.Drawing.Point(80, 16)

# File path row
$lblFile                    = New-Object System.Windows.Forms.Label
$lblFile.Text               = 'File:'
$lblFile.AutoSize           = $true
$lblFile.Location           = New-Object System.Drawing.Point(20, 80)

$txtFile                    = New-Object System.Windows.Forms.TextBox
$txtFile.Size               = New-Object System.Drawing.Size(620, 50)
$txtFile.Location           = New-Object System.Drawing.Point(70, 80)
$txtFile.AllowDrop          = $true

$btnBrowse                  = New-Object System.Windows.Forms.Button
$btnBrowse.Text             = 'Browse...'
$btnBrowse.Size             = New-Object System.Drawing.Size(110, 34)
$btnBrowse.Location         = New-Object System.Drawing.Point(700, 77)

# Expected hash (optional)
$lblExpected                = New-Object System.Windows.Forms.Label
$lblExpected.Text           = 'Expected SHA-256 (optional):'
$lblExpected.AutoSize       = $true
$lblExpected.Location       = New-Object System.Drawing.Point(16, 126)

$txtExpected                = New-Object System.Windows.Forms.TextBox
$txtExpected.Size           = New-Object System.Drawing.Size(620, 50)
$txtExpected.Location       = New-Object System.Drawing.Point(16, 160)

# Actual hash
$lblActual                  = New-Object System.Windows.Forms.Label
$lblActual.Text             = 'Actual SHA-256:'
$lblActual.AutoSize         = $true
$lblActual.Location         = New-Object System.Drawing.Point(16, 201)

$txtActual                  = New-Object System.Windows.Forms.TextBox
$txtActual.Size             = New-Object System.Drawing.Size(620, 50)
$txtActual.Location         = New-Object System.Drawing.Point(16, 235)
$txtActual.ReadOnly         = $true

$lblResult                  = New-Object System.Windows.Forms.Label
$lblResult.Text             = '-'
$lblResult.Font             = $resultFont
$lblResult.AutoSize         = $true
$lblResult.Location         = New-Object System.Drawing.Point(636, 230)
$lblResult.ForeColor        = [System.Drawing.Color]::Gray

# Buttons row
$btnVerify                  = New-Object System.Windows.Forms.Button
$btnVerify.Text             = 'Verify'
$btnVerify.Size             = New-Object System.Drawing.Size(110, 34)
$btnVerify.Location         = New-Object System.Drawing.Point(16, 300)

$btnCopy                    = New-Object System.Windows.Forms.Button
$btnCopy.Text               = 'Copy Actual'
$btnCopy.Size               = New-Object System.Drawing.Size(130, 34)
$btnCopy.Location           = New-Object System.Drawing.Point(140, 300)

$btnClear                   = New-Object System.Windows.Forms.Button
$btnClear.Text              = 'Clear'
$btnClear.Size              = New-Object System.Drawing.Size(110, 34)
$btnClear.Location          = New-Object System.Drawing.Point(284, 300)

$btnExit                    = New-Object System.Windows.Forms.Button
$btnExit.Text               = 'Exit'
$btnExit.Size               = New-Object System.Drawing.Size(110, 34)
$btnExit.Location           = New-Object System.Drawing.Point(700, 300)

# Tooltips
$tip = New-Object System.Windows.Forms.ToolTip
$tip.SetToolTip($txtFile, 'Paste a path or drag & drop a file here')
$tip.SetToolTip($btnBrowse, 'Browse for a file')
$tip.SetToolTip($txtExpected, 'Paste the expected SHA-256 (spaces/case ignored). Leave empty to compute only.')
$tip.SetToolTip($txtActual, 'Computed actual SHA-256 (read-only)')
$tip.SetToolTip($btnVerify, 'Compute and compare')
$tip.SetToolTip($btnCopy, 'Copy the actual hash to clipboard')
$tip.SetToolTip($btnClear, 'Clear fields')

# Layout add
$form.Controls.AddRange(@(
    $pbLogo,
    $title,
    $lblFile, $txtFile, $btnBrowse,
    $lblExpected, $txtExpected,
    $lblActual, $txtActual, $lblResult,
    $btnVerify, $btnCopy, $btnClear, $btnExit
))

# Accept/Cancel buttons
$form.AcceptButton = $btnVerify
$form.CancelButton = $btnExit

# --- Events ---
$btnBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.InitialDirectory = [Environment]::GetFolderPath('Downloads')
    $dlg.Title = 'Select file to verify'
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $txtFile.Text = $dlg.FileName }
})

$txtFile.Add_DragEnter({
    if ($_.Data.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) { $_.Effect = [System.Windows.Forms.DragDropEffects]::Copy }
    else { $_.Effect = [System.Windows.Forms.DragDropEffects]::None }
})
$txtFile.Add_DragDrop({
    $files = $_.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
    if ($files -and $files.Length -gt 0) { $txtFile.Text = $files[0] }
})

$btnVerify.Add_Click({
    try {
        Show-Result ''
        $file = $txtFile.Text.Trim()
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            [System.Windows.Forms.MessageBox]::Show('File not found. Choose a valid file.', 'SHA-256 Verifier', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
            return
        }
        $expected = Normalize-Hash $txtExpected.Text
        $actual   = Compute-FileSHA256 $file
        $txtActual.Text = $actual

        if ([string]::IsNullOrWhiteSpace($expected)) {
            Show-Result 'Missing Expected'; return
        }
        if (-not (Is-Hex64 $expected)) {
            [System.Windows.Forms.MessageBox]::Show('Expected hash must be 64 hex characters (0-9, A-F).', 'SHA-256 Verifier', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
            return
        }
        if ($actual -eq $expected) { Show-Result 'PASS' } else { Show-Result 'FAIL' }
    }
    catch {
        Show-Result 'ERROR'
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    }
})

$btnCopy.Add_Click({ if (-not [string]::IsNullOrWhiteSpace($txtActual.Text)) { [System.Windows.Forms.Clipboard]::SetText($txtActual.Text) } })
$btnClear.Add_Click({ $txtFile.Clear(); $txtExpected.Clear(); $txtActual.Clear(); Show-Result '' })
$btnExit.Add_Click({ $form.Close() })
$form.Add_Shown({
    if ($InitialFile) { $txtFile.Text = $InitialFile }
    $txtFile.Focus()
})

# --- Mizzle style (dark / neon) ---
$bg      = [System.Drawing.ColorTranslator]::FromHtml('#0f0f17')
$panel   = [System.Drawing.ColorTranslator]::FromHtml('#1a1b26')
$fg      = [System.Drawing.ColorTranslator]::FromHtml('#e5e7eb')
$accent  = [System.Drawing.ColorTranslator]::FromHtml('#a855f7')  # purple
$accent2 = [System.Drawing.ColorTranslator]::FromHtml('#06b6d4')  # teal

$form.BackColor = $bg
$form.ForeColor = $fg
$title.ForeColor = $accent

foreach ($tb in @($txtFile,$txtExpected,$txtActual)) { $tb.BackColor = $panel; $tb.ForeColor = $fg }
foreach ($btn in @($btnBrowse,$btnVerify,$btnCopy,$btnClear,$btnExit)) {
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.BackColor = $panel
    $btn.ForeColor = $fg
}
$btnVerify.BackColor = $accent;  $btnVerify.ForeColor = [System.Drawing.Color]::White

# Run
[void]$form.ShowDialog()
