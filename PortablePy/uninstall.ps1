#requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonDir = Join-Path $Root "python"

Write-Host ""
Write-Host "=========================================="
Write-Host "          PortablePy Uninstaller"
Write-Host "=========================================="
Write-Host ""

if (-not (Test-Path $PythonDir)) {
    Write-Host "PortablePy is not installed."
    exit 0
}

Write-Host "The following directory will be deleted:"
Write-Host $PythonDir
Write-Host ""

$answer = Read-Host "Continue? [Y/N]"
if ($answer -notmatch "^(Y|y)$") {
    Write-Host "Cancelled."
    exit 0
}

Remove-Item -LiteralPath $PythonDir -Recurse -Force

if (Test-Path $PythonDir) {
    throw "Failed to remove PortablePy."
}

Write-Host ""
Write-Host "PortablePy has been removed."
Write-Host "Windows system PATH and registry were not modified."
exit 0
