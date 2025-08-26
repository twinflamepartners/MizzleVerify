param(
    [string]$Src  = "$PSScriptRoot\src\SHA256-Verify-GUI.ps1",
    [string]$Out  = "$PSScriptRoot\dist\MizzleVerify.exe",
    [string]$Icon = "$PSScriptRoot\tools\mizzle-logo.ico",
    [string]$Version = "1.0.0.0"
)

Write-Host "Building MizzleVerify..." -ForegroundColor Cyan

# Ensure PS2EXE is available
if (-not (Get-Command Invoke-PS2EXE -ErrorAction SilentlyContinue)) {
    Write-Host "PS2EXE not found. Installing to CurrentUser..." -ForegroundColor Yellow
    Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber
    Import-Module ps2exe -Force
}

Invoke-PS2EXE `
  -InputFile   $Src `
  -OutputFile  $Out `
  -IconFile    $Icon `
  -NoConsole `
  -STA `
  -Title       'Mizzle Verify' `
  -Company     'Twinflame Partners' `
  -Product     'Mizzle Verify' `
  -Version     $Version

Write-Host "Done. Output: $Out" -ForegroundColor Green
