# .NET SDK Installation Guide for Godot Engine (C#)

This guide provides step-by-step instructions for downloading and installing the **.NET SDK** required to run and build C# projects in **Godot Engine (.NET Version)**.

---

## 📋 Prerequisites

Before setting up .NET for Godot, ensure you have:
- **Godot Engine (.NET / Mono version)** downloaded and extracted.
- An active internet connection.

---

## 🚀 Step 1: Download the .NET SDK

1. Open your web browser and navigate to the official Microsoft .NET download page:
   👉 [https://dotnet.microsoft.com/download](https://dotnet.microsoft.com/download)

2. Under the **.NET SDK** section, locate the latest **LTS (Long Term Support)** version (e.g., **.NET 8.0 SDK** or newer).
   > **Note:** Make sure to download the **SDK (Software Development Kit)**, not just the *Runtime*. The SDK includes the tools and compiler necessary to build C# applications.

3. Select the appropriate installer for your operating system:
   - **Windows:** `x64` Installer (or `Arm64` if on ARM architecture).
   - **macOS:** `x64` or `Arm64` Installer (for Apple Silicon M1/M2/M3 chips).
   - **Linux:** Follow the package manager instructions for your distribution.

---

## ⚙️ Step 2: Install the .NET SDK

1. Run the downloaded installer executable (e.g., `dotnet-sdk-8.x.x-win-x64.exe`).
2. Follow the setup wizard prompts and complete the installation using default options.
3. Once the installation finishes, click **Close**.

---

## 🔍 Step 3: Verify the Installation

To verify that the .NET SDK is properly installed and added to your system's `PATH`:

1. Open your terminal or command prompt:
   - **Windows:** Press `Win + R`, type `cmd`, and press **Enter**.
   - **macOS / Linux:** Open the **Terminal** app.

2. Run the following command:
   ```bash
   dotnet --version
   ```

3. **Expected Result:** The command prompt should display the installed SDK version number (e.g., `8.0.400`).

---

## 🛠️ Step 4: Configure Code Editor (Recommended)

To write C# code efficiently with code completion (IntelliSense) and debugging features, configure a code editor like **VS Code**:

1. Install **[Visual Studio Code](https://code.visualstudio.com/)**.
2. Open VS Code and install the following extensions from the Marketplace:
   - **C# Dev Kit** (Official extension by Microsoft)
   - **Godot C# Tools** (By Ignacio Roldán Etcheverry)

3. Link the editor in Godot Engine:
   - Open Godot.
   - Go to **Editor** $\rightarrow$ **Editor Settings**.
   - Navigate to **Dotnet** $\rightarrow$ **Editor** in the left menu.
   - Set **External Editor** to **Visual Studio Code** (or your preferred editor).

---

## 🎉 You're All Set!

You can now create, open, and run C# scripts inside Godot Engine without compilation errors.