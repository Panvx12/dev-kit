# 🚀 ImageMagick Auto-Installer for Windows

A simple, automated batch script (`.bat`) designed to download and install **ImageMagick** on Windows systems effortlessly using `winget`.

---

## ✨ Features

- **One-Click Installation**: Uses Windows Package Manager (`winget`) to fetch and install the official package.
- **Environment Path Setup**: Automatically manages system PATH configurations so you can use the `magick` command immediately in your terminal.
- **Error Handling**: Detects execution status and provides helpful guidance if administrative rights are required.

---

## 📋 Prerequisites

- **OS**: Windows 10 (Version 1809 or later) / Windows 11
- **Tool**: Windows Package Manager (`winget`) — pre-installed on most modern Windows versions.

---

## ⚡ Quick Start

1. **Clone or Download** this repository:
   ```cmd
   git clone --depth 1 --filter=blob:none --sparse https://github.com/Panvx12/dev-kit.git
   cd dev-kit
   git sparse-checkout set imagick-installer
   cd imagick-installer
