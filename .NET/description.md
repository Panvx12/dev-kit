# .NET Download & Installation Guide

Follow these steps to download and install the .NET SDK or Runtime on your machine.

---

## Step 1: Visit the Official Download Page
Go to the official Microsoft .NET downloads page:  
👉 [https://dotnet.microsoft.com/download](https://dotnet.microsoft.com/download)

---

## Step 2: Choose What You Need
Depending on your goal, select the appropriate package:

* **.NET SDK (Software Development Kit):** Choose this if you are a developer writing, building, and compiling code. The SDK includes everything you need to build apps, including the runtime.
* **.NET Runtime / ASP.NET Core Runtime:** Choose this if you only need to *run* an existing .NET application on a machine or server without developing code.

---

## Step 3: Select Your Version
* **LTS (Long Term Support):** Recommended for production environments and enterprise stability (e.g., .NET 8).
* **Current:** Recommended if you want to experiment with the newest features and latest language updates.

---

## Step 4: Download and Install for Your OS

### Windows
1. Download the `.exe` or `.msi` installer.
2. Run the installer and complete the setup wizard.

### macOS
1. Download the `.pkg` installer or install via Homebrew:
   ```bash
   brew install --cask dotnet-sdk
   ```
2. Follow the on-screen installation prompts.

### Linux
Install via your distribution's package manager (e.g., Ubuntu/Debian):
```bash
sudo apt-get update && \
sudo apt-get install -y dotnet-sdk-8.0
```

---

## Step 5: Verify the Installation
Open a terminal, Command Prompt, or PowerShell window and run:

```bash
dotnet --version
```

If the installation was successful, the terminal will display your installed version number (e.g., `8.0.x`).

---

## Troubleshooting & Useful Commands

* **List all installed SDKs:**
  ```bash
  dotnet --list-sdks
  ```
* **List all installed Runtimes:**
  ```bash
  dotnet --list-runtimes
  ```
* **Check system environment information:**
  ```bash
  dotnet --info
  ```