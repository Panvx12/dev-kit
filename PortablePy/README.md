# PortablePy

Portable Python development environment for Windows.

## Quick Start

1. Download this repository.
2. Run `install.bat`.
3. Wait for installation and verification.
4. Use `python.bat` or `pip.bat`.

```text
PortablePy/
├── install.bat
├── install.ps1
├── activate.bat
├── activate.ps1
├── python.bat
├── pip.bat
├── uninstall.bat
├── uninstall.ps1
├── description.md
└── .gitignore
```

## Version

Python 3.14.7.

Python 3.14.7 is currently the latest stable Python 3 release used by this project.

## Examples

```bat
python.bat --version
python.bat main.py
pip.bat install requests
pip.bat list
```

To remove it:

```text
uninstall.bat
```

PortablePy does not permanently modify the Windows PATH.
