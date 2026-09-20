#requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Version = "3.14.7"
$PythonDir = Join-Path $Root "python"
$DownloadDir = Join-Path $Root ".cache"
$ZipPath = Join-Path $DownloadDir "python-$Version-embeddable.zip"
$PipBootstrap = Join-Path $DownloadDir "get-pip.py"

Write-Host ""
Write-Host "==========================================" 
Write-Host "          PortablePy Installer"
Write-Host "==========================================" 
Write-Host ""
Write-Host "Python version: $Version"

# ------------------------------------------------------------
# Architecture
# ------------------------------------------------------------
$arch = $env:PROCESSOR_ARCHITECTURE
if ($env:PROCESSOR_ARCHITEW6432) {
    $arch = $env:PROCESSOR_ARCHITEW6432
}

switch ($arch.ToUpperInvariant()) {
    "AMD64" {
        $PackageArch = "amd64"
        $ExpectedHash = "76c3c0384ab3f822486f32450f3a4d20f5d65ad0ec32ee34290971aa0eb817e6"
    }
    "ARM64" {
        $PackageArch = "arm64"
        $ExpectedHash = "b777fa08b68a177e350f8730c3e97a2b216d81e3eb5d183b039c65d43a6a2b3e"
    }
    default {
        throw "Unsupported Windows architecture: $arch. PortablePy supports Windows AMD64 and ARM64."
    }
}

$PackageName = "python-$Version-embeddable-$PackageArch.zip"
$DownloadUrl = "https://www.python.org/ftp/python/$Version/$PackageName"

Write-Host "Architecture:   $PackageArch"
Write-Host "Package:        $PackageName"
Write-Host ""

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
function Invoke-DownloadFile {
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$OutFile
    )

    Write-Host "Downloading:"
    Write-Host "  $Url"

    if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
        & curl.exe --fail --location --retry 3 --retry-delay 2 --output $OutFile $Url
        if ($LASTEXITCODE -ne 0) {
            throw "curl failed with exit code $LASTEXITCODE."
        }
    }
    else {
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing
    }
}

function Test-SHA256 {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Expected
    )

    $actual = (Get-FileHash -Path $Path -Algorithm SHA256).Hash.ToLowerInvariant()
    return $actual -eq $Expected.ToLowerInvariant()
}

# ------------------------------------------------------------
# Basic requirements
# ------------------------------------------------------------
if (-not [Environment]::Is64BitOperatingSystem) {
    throw "PortablePy requires a 64-bit version of Windows."
}

if ($PSVersionTable.PSVersion.Major -lt 5) {
    throw "PowerShell 5.1 or newer is required."
}

# ------------------------------------------------------------
# Existing installation
# ------------------------------------------------------------
if (Test-Path (Join-Path $PythonDir "python.exe")) {
    Write-Host "An existing PortablePy installation was found." -ForegroundColor Yellow
    $answer = Read-Host "Reinstall it? [Y/N]"
    if ($answer -notmatch "^(Y|y)$") {
        Write-Host "Installation cancelled."
        exit 0
    }

    Write-Host "Removing existing Python runtime..."
    Remove-Item -LiteralPath $PythonDir -Recurse -Force
}

New-Item -ItemType Directory -Path $DownloadDir -Force | Out-Null

# ------------------------------------------------------------
# Download and verify Python
# ------------------------------------------------------------
Write-Host ""
Write-Host "[1/6] Downloading Python $Version..."

if (Test-Path $ZipPath) {
    Write-Host "Existing download found. Verifying..."
    if (-not (Test-SHA256 -Path $ZipPath -Expected $ExpectedHash)) {
        Write-Host "Cached file hash mismatch. Downloading again..." -ForegroundColor Yellow
        Remove-Item -LiteralPath $ZipPath -Force
    }
}

if (-not (Test-Path $ZipPath)) {
    Invoke-DownloadFile -Url $DownloadUrl -OutFile $ZipPath
}

Write-Host "[2/6] Verifying SHA256..."
if (-not (Test-SHA256 -Path $ZipPath -Expected $ExpectedHash)) {
    Remove-Item -LiteralPath $ZipPath -Force -ErrorAction SilentlyContinue
    throw "SHA256 verification failed. The downloaded Python package does not match the official checksum."
}

Write-Host "SHA256 verification passed." -ForegroundColor Green

# ------------------------------------------------------------
# Extract
# ------------------------------------------------------------
Write-Host ""
Write-Host "[3/6] Extracting Python..."

if (Test-Path $PythonDir) {
    Remove-Item -LiteralPath $PythonDir -Recurse -Force
}
New-Item -ItemType Directory -Path $PythonDir -Force | Out-Null

Expand-Archive -LiteralPath $ZipPath -DestinationPath $PythonDir -Force

if (-not (Test-Path (Join-Path $PythonDir "python.exe"))) {
    throw "python.exe was not found after extraction."
}

# ------------------------------------------------------------
# Configure embeddable Python
# ------------------------------------------------------------
Write-Host "[4/6] Configuring Python..."

$PthFile = Get-ChildItem -LiteralPath $PythonDir -Filter "*._pth" -File |
    Select-Object -First 1

if (-not $PthFile) {
    throw "Python ._pth configuration file was not found."
}

$pthLines = Get-Content -LiteralPath $PthFile.FullName

if ($pthLines -notcontains "import site") {
    Add-Content -LiteralPath $PthFile.FullName -Value "import site"
}

New-Item -ItemType Directory -Path (Join-Path $PythonDir "Lib\site-packages") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $PythonDir "Scripts") -Force | Out-Null

# ------------------------------------------------------------
# Install pip
# ------------------------------------------------------------
Write-Host "[5/6] Installing pip..."

$PipUrl = "https://bootstrap.pypa.io/get-pip.py"
Invoke-DownloadFile -Url $PipUrl -OutFile $PipBootstrap

& (Join-Path $PythonDir "python.exe") $PipBootstrap
if ($LASTEXITCODE -ne 0) {
    throw "pip installation failed with exit code $LASTEXITCODE."
}

# ------------------------------------------------------------
# Cleanup and verification
# ------------------------------------------------------------
Remove-Item -LiteralPath $PipBootstrap -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $ZipPath -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $DownloadDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "[6/6] Verifying installation..."

$PythonExe = Join-Path $PythonDir "python.exe"
$PipExe = Join-Path $PythonDir "Scripts\pip.exe"

& $PythonExe --version
if ($LASTEXITCODE -ne 0) {
    throw "Python verification failed."
}

if (-not (Test-Path $PipExe)) {
    throw "pip.exe was not created."
}

& $PipExe --version
if ($LASTEXITCODE -ne 0) {
    throw "pip verification failed."
}

& $PythonExe -c "import sys; print('Executable:', sys.executable); print('Prefix:', sys.prefix); print('PortablePy OK')"
if ($LASTEXITCODE -ne 0) {
    throw "Python runtime test failed."
}

Write-Host ""
Write-Host "==========================================" 
Write-Host "      PortablePy installation complete"
Write-Host "==========================================" 
Write-Host ""
Write-Host "Python: $PythonExe"
Write-Host ""
Write-Host "Run:"
Write-Host "  python.bat --version"
Write-Host ""
Write-Host "Activate:"
Write-Host "  activate.bat"
Write-Host ""
Write-Host "Install packages:"
Write-Host "  pip.bat install <package>"
Write-Host ""
Write-Host "No permanent Windows PATH was modified."
Write-Host ""
exit 0
