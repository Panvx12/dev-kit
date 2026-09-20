# setup-cpp

A **one-click C++20 development environment installer script** for Windows. When switching to a new computer, simply double-click a single file to set up `g++`, `cmake`, `ninja`, and other tools while automatically configuring your `PATH`.

## Included Software

| Item | Description |
|------|-------------|
| MSYS2 | Installed to `C:\msys64` (skipped if already installed) |
| UCRT64 Toolchain | GCC / G++, GDB, binutils, `mingw32-make` |
| CMake | Build system generator |
| Ninja | High-speed build system |
| PATH | Prepends `C:\msys64\ucrt64\bin` to the **User PATH** (automatically backed up prior to modification) |

## System Requirements

- Windows 10 / 11 (x64)
- [winget](https://learn.microsoft.com/windows/package-manager/winget/) (Windows built-in "App Installer"; update via Microsoft Store if missing)
- Internet connection
- Administrator privileges required (the script will automatically trigger a UAC prompt)

## Usage

1. Download or clone this repository. **Both files must remain in the same folder**:

   ```text
   setup-cpp/
   ├── setup-cpp.bat   # Launcher (double-click this)
   └── setup-cpp.ps1   # Main script
   ```

   ```bash
   git clone https://github.com/<your-username>/setup-cpp.git
   ```

2. Double-click `setup-cpp.bat` and select "Yes" in the UAC window.
3. Wait for the installation and verification to complete until you see "Installation Complete!".
4. **Restart** CMD / PowerShell / VS Code for the new PATH settings to take effect.

You can also run it directly from the terminal:

```bat
setup-cpp.bat
```

> **Note:** It is recommended to copy the folder locally (e.g., to `Downloads`) before running. When run directly from a cloud drive or mapped network drive, elevated command windows might not be able to access the path.

## Execution Flow

1. Check for administrator privileges; if not elevated, restart itself as Administrator.
2. Check for `winget`.
3. Check / install MSYS2.
4. Update MSYS2 (runs twice; the first run updates core packages and may exit prematurely, which is normal behavior).
5. Install GCC, GDB, CMake, and Ninja via `pacman` (automatically retries up to 3 times on network failure).
6. Configure User `PATH`.
7. Verification:
   - Check `gcc`, `g++`, `gdb`, `cmake`, and `ninja` execution sequentially, ensuring that the MSYS2 versions are used.
   - Compile and execute a C++20 test program using `g++ -std=c++20`.
   - Build and execute the test program again using CMake + Ninja.

**Idempotent / Rerunnable**: If a failure occurs midway or when setting up on a new PC, simply run the script again.

## Usage After Installation

```bash
# Direct compilation
g++ -std=c++20 main.cpp -o main.exe

# Using CMake + Ninja
cmake -S . -B build -G Ninja
cmake --build build
```

> Binaries compiled using UCRT64 dynamically link against DLLs inside `ucrt64\bin`. To execute them on a machine without MSYS2 installed, add `-static` during compilation or distribute the necessary DLLs alongside the executable.

## Customization

Open `setup-cpp.ps1` and modify the "Configuration" section at the top:

```powershell
$MsysRoot = 'C:\msys64'          # MSYS2 installation path
$Packages = @(
    'mingw-w64-ucrt-x86_64-toolchain',
    'mingw-w64-ucrt-x86_64-cmake',
    'mingw-w64-ucrt-x86_64-ninja'
    # Add additional packages here, for example:
    # 'mingw-w64-ucrt-x86_64-clang'
)
```

## Logs and Troubleshooting

| File | Location |
|------|----------|
| Installation Log | `%TEMP%\cpp-setup.log` |
| Original PATH Backup | `%TEMP%\user-path-backup-<timestamp>.txt` |

| Issue | Resolution |
|-------|------------|
| `winget` not found | Update "App Installer" in the Microsoft Store, then rerun the script. |
| `pacman` update or installation failed | Usually a network issue; rerun the script. If it still fails, check the log file. |
| Newly opened terminal cannot find `g++` | Close all open terminal windows and VS Code, then reopen them. |
| Verification warns: "Currently executing ... instead of the MSYS2 version" | Other compilers exist in your system PATH with higher priority; adjust or remove them. |
| Error indicating MSYS2 cannot be found | MSYS2 may be installed in a different folder; update `$MsysRoot` in the script. |
| Script blocked by Group Policy on work PC | Execution policy is restricted by GPO; request IT to allow script execution. |

## Uninstallation

1. Run `winget uninstall MSYS2.MSYS2`, or delete `C:\msys64` directly.
2. Navigate to "Edit environment variables for your account" -> "Environment Variables", and remove `C:\msys64\ucrt64\bin` from the User `Path`.

## Security Notes

The script executes with Administrator privileges and performs only three actions: installs MSYS2 via `winget`, installs the required packages via `pacman`, and modifies the **current user's** PATH. Feel free to review the complete code in `setup-cpp.ps1` before executing.

## Development Notes

- Both `.bat` and `.ps1` files must use **CRLF** line endings (batch file `goto` labels may fail under LF line endings); this project uses `.gitattributes` to enforce CRLF.
- Because `setup-cpp.ps1` contains localized text, please save it with **UTF-8 with BOM** encoding; otherwise, Windows PowerShell 5.1 may display garbled characters.
- `setup-cpp.bat` deliberately remains pure ASCII, keeping all complex logic inside `.ps1`.

## Tested Environments

<!-- Fill in after testing, e.g., Windows 11 23H2 x64 (Clean Install), Windows 10 22H2 x64 -->