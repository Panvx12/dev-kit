$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonDir = Join-Path $Root "python"

$env:PORTABLEPY_ROOT = $Root
$env:PORTABLEPY_PYTHON = $PythonDir
$env:PATH = "$PythonDir;$PythonDir\Scripts;$env:PATH"

Write-Host ""
Write-Host "=========================================="
Write-Host "          PortablePy Environment"
Write-Host "=========================================="
& (Join-Path $PythonDir "python.exe") --version
Write-Host ""
Write-Host "PortablePy is active in this PowerShell session."
Write-Host "Close this PowerShell window to leave the environment."
Write-Host ""
