# PortablePy

PortablePy is a self-contained Python development environment for Windows.

## Current Python

PortablePy currently uses **Python 3.14.7**, the latest stable Python 3 release at the time of this version.

The runtime is downloaded from the official Python.org distribution server.

## Features

- Windows 10/11
- AMD64 and ARM64
- Python 3.14.7
- Official Python embeddable package
- Automatic pip installation
- SHA256 verification of the Python archive
- No global Python installation
- No permanent PATH modification
- No Registry modification by PortablePy
- Portable directory
- PowerShell implementation
- BAT launchers for easy use
- Simple uninstall

## Installation

Double-click:

```text
install.bat
```

The installer downloads the appropriate Python package, verifies its SHA256 checksum, extracts it, configures `site-packages`, installs pip, and performs runtime verification.

## Usage

### Direct Python

```text
python.bat --version
```

### Install packages

```text
pip.bat install requests
```

### Run a script

```text
python.bat main.py
```

### Activate a CMD environment

```text
activate.bat
```

### Activate a PowerShell environment

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\activate.ps1
```

## Portability

The `python` directory contains the runtime.

The entire PortablePy directory can be copied to another compatible Windows computer.

## Isolation

PortablePy does not add Python to the Windows system PATH.

`activate.bat` and `activate.ps1` modify PATH only for their current shell/session.

Closing that shell removes the temporary environment changes.

## Uninstall

Run:

```text
uninstall.bat
```

Only the local PortablePy runtime directory is removed.

## Repository

Do not commit the generated `python/` runtime or `.cache/` directory to Git.

The installer downloads the runtime when needed.
