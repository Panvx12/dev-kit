# Windows 11: MSYS2 + GCC + C++20 + VS Code Setup Guide

This guide sets up a C++20 development environment on Windows 11 using **MSYS2 UCRT64, GCC/G++, GDB, CMake, Ninja, and VS Code**. After completing the steps, you should be able to compile, run, and debug a single C++ source file, as well as build projects with CMake.

> **Recommended installation path:** `C:\msys64`
>
> MSYS2 is best installed in a short, ASCII-only path without spaces. If you choose a different installation location, replace every `C:\msys64` path in this guide consistently.

## 1. Prerequisites

- 64-bit Windows 11.
- An internet connection.
- Sufficient disk space.
- VS Code (you can install it after setting up the toolchain).

MSYS2 provides several environments. This guide uses **UCRT64**, which uses the GCC toolchain, UCRT, and GNU `libstdc++`. Do not mix compilers or libraries from UCRT64, MINGW64, CLANG64, or other environments.

Official references:
- [MSYS2 environments](https://www.msys2.org/docs/environments/)
- [MSYS2 installer](https://www.msys2.org/docs/installer/)

## 2. Download and Install MSYS2

1. Open the [official MSYS2 website](https://www.msys2.org/).
2. Download the 64-bit installer currently provided on the website. The filename may change between releases, so follow the official download page.
3. Run the installer. The recommended installation location is `C:\msys64`.
4. After installation, open **MSYS2 UCRT64** from the Start menu. Do not open the MSYS, MINGW64, or CLANG64 terminal instead.

Confirm that the terminal title or environment indicates UCRT64. Run the package commands below in the **MSYS2 UCRT64 terminal**, not in regular CMD or PowerShell.

## 3. Update MSYS2

Run the following in the MSYS2 UCRT64 terminal:

```bash
pacman -Suy
```

If prompted to close all MSYS2 processes to complete a core update:

1. Enter `Y` and wait for the process to finish.
2. Close all MSYS2 terminal windows.
3. Reopen **MSYS2 UCRT64**.
4. Run the command again:

```bash
pacman -Suy
```

If the update asks you to restart again, follow the prompts to reopen the terminal and repeat the update until it completes. MSYS2 is a rolling-release distribution; the official guidance recommends full system updates rather than updating individual packages while leaving the rest outdated.

Official references:[Updating MSYS2](https://www.msys2.org/docs/updating/)

## 4. Install the C++ Compiler and Build Tools

Run the following in the **MSYS2 UCRT64 terminal**:

```bash
pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja mingw-w64-ucrt-x86_64-clang-tools-extra
```

If a package selection menu appears, select the full toolchain (you can usually press Enter to accept the default selection), then confirm the installation.

The main tools provided by this command are:

- **GCC/G++**: C/C++ compiler.
- **GDB**: GNU debugger, included in the toolchain package group.
- **CMake**: Build-system generator.
- **Ninja**: Build tool.
- **clang-format / clang-tidy**: Code-formatting and static-analysis tools (provided by `clang-tools-extra`).

> Note: The command above installs the GCC toolchain and Clang utilities; it does not install the full Clang compiler. If you need `clang.exe`, run the following additional command:
>
> ```bash
> pacman -S --needed mingw-w64-ucrt-x86_64-clang
> ```

### 4.1 Verify the Tools

Still in the MSYS2 UCRT64 terminal, run:

```bash
g++ --version
gdb --version
cmake --version
ninja --version
clang-format --version
clang-tidy --version
```

If you installed Clang separately, also run:

```bash
clang --version
```

Each command should display version information rather than `command not found`.

## 5. Windows PATH: Avoid Changing the System PATH Initially

To avoid conflicts with other MinGW, Cygwin, or MSYS2 installations, **the VS Code configuration in this guide specifies the full paths to the compiler and debugger**. Therefore, you do not need to add MSYS2 to the system-wide PATH just to use VS Code.

If you want to run commands such as `g++` and `cmake` directly from regular CMD or PowerShell, add the following path to your **user Path**:

```text
C:\msys64\ucrt64\bin
```

Steps:

1. Press `Win + R`, enter `sysdm.cpl`, and press Enter.
2. Open **Advanced** → **Environment Variables**.
3. Under **User variables**, select `Path` → **Edit** → **New**.
4. Add `C:\msys64\ucrt64\bin` and save the changes.
5. Close and reopen CMD, PowerShell, and VS Code.

In general, avoid modifying the system-level Path just for this purpose. If another GCC/MinGW installation is already present, check for version conflicts first.

In a new CMD window, check:

```cmd
where g++
where gdb
where cmake
where ninja
g++ --version
```

If `where g++` displays multiple paths, make sure the first one is the intended `C:\msys64\ucrt64\bin\g++.exe`. If you did not modify PATH, it is normal for these commands to be unavailable in regular CMD; test them in the MSYS2 UCRT64 terminal instead.

## 6. Install and Configure VS Code

1. Install VS Code from the [official VS Code website](https://code.visualstudio.com/).
2. Open the Extensions panel (`Ctrl + Shift + X`) and install:
   - **C/C++** (`ms-vscode.cpptools`)
   - **CMake Tools** (`ms-vscode.cmake-tools`, needed when using CMake)
3. Create a project folder, for example `C:\Users\<your-username>\Projects\CppDemo`.
4. In VS Code, open the project folder using **File → Open Folder**.
5. Create a `.vscode` folder in the project root and add the following configuration files.

### 6.1 `.vscode/c_cpp_properties.json`

```json
{
    "configurations": [
        {
            "name": "Win32 UCRT64",
            "includePath": [
                "${workspaceFolder}/**"
            ],
            "defines": [
                "_DEBUG",
                "UNICODE",
                "_UNICODE"
            ],
            "compilerPath": "C:/msys64/ucrt64/bin/g++.exe",
            "cStandard": "c17",
            "cppStandard": "c++20",
            "intelliSenseMode": "windows-gcc-x64"
        }
    ],
    "version": 4
}
```

`compilerPath` must point to the actual compiler installation. Letting the C/C++ extension query the compiler for system-header information is generally more reliable than manually listing many system include directories.

### 6.2 `.vscode/tasks.json`

This configuration compiles the `.cpp` file currently open in the editor and writes the executable to the same directory.

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "type": "cppbuild",
            "label": "Build C++20 with g++",
            "command": "C:/msys64/ucrt64/bin/g++.exe",
            "args": [
                "-std=c++20",
                "-Wall",
                "-Wextra",
                "-g",
                "${file}",
                "-o",
                "${fileDirname}/${fileBasenameNoExtension}.exe"
            ],
            "options": {
                "cwd": "${fileDirname}"
            },
            "problemMatcher": [
                "$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
    ]
}
```

Keep in mind:

- `-std=c++20` is the option that explicitly tells the compiler to use C++20.
- This task compiles only the currently open source file. For multi-file projects, list all source files explicitly or use CMake.
- The `label` must exactly match the `preLaunchTask` value in `launch.json` below.

### 6.3 `.vscode/launch.json`

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug C++20",
            "type": "cppdbg",
            "request": "launch",
            "program": "${fileDirname}\\${fileBasenameNoExtension}.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerPath": "C:\\msys64\\ucrt64\\bin\\gdb.exe",
            "preLaunchTask": "Build C++20 with g++",
            "setupCommands": [
                {
                    "description": "Enable GDB pretty-printing",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
```

Before debugging with `F5`, make sure the intended `.cpp` file is open and set a breakpoint inside `main()`. If `gdb.exe` is not at the path shown above, update `miDebuggerPath`.

## 7. Test 1: Compile a C++20 Program Directly

Create `main.cpp` in the project folder:

```cpp
#include <iostream>
#include <string>
#include <vector>

int main() {
    const std::vector<std::string> words{
        "Hello", "from", "MSYS2", "UCRT64", "C++20!"
    };

    for (const auto& word : words) {
        std::cout << word << ' ';
    }
    std::cout << '\n';

    return 0;
}
```

### Method A: Use VS Code

1. Save `main.cpp`.
2. Press `Ctrl + Shift + B`.
3. Confirm that `main.exe` appears in the project folder.
4. Run the following in the VS Code terminal:

   ```powershell
   .\main.exe
   ```

5. Expected output:

   ```text
   Hello from MSYS2 UCRT64 C++20!
   ```

6. Set a breakpoint inside `main()` and press `F5`.
7. Confirm that the program pauses at the breakpoint and can be stepped through.

### Method B: Use the MSYS2 UCRT64 Terminal

Change to the directory containing `main.cpp`, then run:

```bash
g++ -std=c++20 -Wall -Wextra -g main.cpp -o main.exe
./main.exe
```

If compilation succeeds but the program reports a DLL error at runtime, first confirm that you are using the same UCRT64 toolchain and that the required runtime DLLs are available in `C:\msys64\ucrt64\bin`. Do not download individual DLLs from unknown websites.

## 8. Test 2: Use CMake + Ninja

Create `CMakeLists.txt` in the project root:

```cmake
cmake_minimum_required(VERSION 3.20)

project(MSYS2Demo LANGUAGES CXX)

add_executable(app main.cpp)

target_compile_features(app PRIVATE cxx_std_20)

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(app PRIVATE -Wall -Wextra)
endif()
```

Make sure `main.cpp` and `CMakeLists.txt` are in the same directory.

Run the following commands in the **MSYS2 UCRT64 terminal** to avoid a regular Windows terminal selecting a different version of CMake, Ninja, or the compiler due to PATH differences:

```bash
cmake -S . -B build -G Ninja
cmake --build build
./build/app.exe
```

If the `build` directory was previously configured with a different compiler or generator, delete that project's `build` directory before running configuration again. CMake does not allow you to freely switch generators or compilers within the same build directory.

## 9. Troubleshooting

### `g++` or `gdb` Is Not Found

- Make sure you ran the package installation command in the **MSYS2 UCRT64** terminal.
- Confirm that the toolchain installation completed and was not cancelled.
- If testing in regular CMD, make sure you added the path and reopened the terminal.
- Run `where g++` to check whether another toolchain appears first.

### VS Code Cannot Find the Compiler or Debugger

- Confirm that `C:/msys64/ucrt64/bin/g++.exe` and `C:\msys64\ucrt64\bin\gdb.exe` exist.
- Confirm that all three JSON files are in the current workspace's `.vscode` folder.
- Make sure the JSON is valid; it must not contain trailing commas or comments.
- Make sure `preLaunchTask` exactly matches the `label` in `tasks.json`.

### Compilation Succeeds but a DLL Is Missing at Runtime

- Confirm that the compiler is the UCRT64 `g++.exe`.
- If running from a regular Windows terminal, temporarily add the toolchain path in that terminal:

  ```cmd
  set "PATH=C:\msys64\ucrt64\bin;%PATH%"
  ```

  This setting affects only the current CMD window and programs launched from it; it does not permanently modify system environment variables.

- Do not mix DLLs from UCRT64, MINGW64, and CLANG64.

### CMake Cannot Find Ninja or Uses the Wrong Compiler

- Run `cmake --version`, `ninja --version`, and `g++ --version` in the MSYS2 UCRT64 terminal.
- Confirm that the commands come from the intended environment.
- Delete that project's `build` directory and run the CMake configuration command again.

### `F5` Does Not Stop at a Breakpoint

- Make sure the program was compiled with `-g`.
- Make sure the breakpoint is on code that will actually execute.
- Make sure `program` in `launch.json` points to the latest compiled `.exe`.
- Make sure `miDebuggerPath` points to the UCRT64 `gdb.exe`.

## 10. Routine Updates and Notes

To update MSYS2, open the MSYS2 UCRT64 terminal and run:

```bash
pacman -Suy
```

If the update asks you to close the terminal, reopen it and repeat the update as described in Section 3.

- Do not move the MSYS2 installation directory after installation; some settings and packages may depend on the original path.
- Do not mix compilers, headers, static libraries, or DLLs from different environments.
- `C++20` is a language-standard option; the features actually supported depend on the GCC version.
- This guide describes a general installation procedure and has not been run on your computer. Use the test steps to verify each stage.

## Official References

- [MSYS2 official website](https://www.msys2.org/)
- [MSYS2 installer documentation](https://www.msys2.org/docs/installer/)
- [MSYS2 environments documentation](https://www.msys2.org/docs/environments/)
- [MSYS2 update documentation](https://www.msys2.org/docs/updating/)
- [VS Code: Compile and debug with MinGW](https://code.visualstudio.com/docs/cpp/config-mingw)
- [VS Code C/C++ configuration documentation](https://code.visualstudio.com/docs/cpp/customize-cpp-settings)
