# setup-cpp

Windows 上的 **C++20 開發環境一鍵安裝腳本**。換電腦時，雙擊一個檔案，就能重建 `g++`、`cmake`、`ninja` 等工具，並自動設定 PATH。

## 會安裝什麼

| 項目 | 說明 |
|------|------|
| MSYS2 | 安裝到 `C:\msys64`（已安裝則略過） |
| UCRT64 工具鏈 | GCC / G++、GDB、binutils、`mingw32-make` |
| CMake | 建置系統產生器 |
| Ninja | 快速建置工具 |
| PATH | 把 `C:\msys64\ucrt64\bin` 放到**使用者 PATH 最前面**（修改前自動備份） |

## 系統需求

- Windows 10 / 11（x64）
- [winget](https://learn.microsoft.com/windows/package-manager/winget/)（Windows 內建的「應用程式安裝程式」，找不到請到 Microsoft Store 更新）
- 網路連線
- 需要系統管理員權限（腳本會自動跳出 UAC 詢問）

## 使用方式

1. 下載或 clone 本專案，**兩個檔案要放在同一個資料夾**：

   ```text
   setup-cpp/
   ├── setup-cpp.bat   # 啟動器（雙擊這個）
   └── setup-cpp.ps1   # 主程式
   ```

   ```bash
   git clone https://github.com/<你的帳號>/setup-cpp.git
   ```

2. 雙擊 `setup-cpp.bat`，在 UAC 視窗按「是」。
3. 等待安裝與驗證完成，看到「安裝完成！」即可。
4. **重新開啟** CMD / PowerShell / VS Code，新的 PATH 才會生效。

也可以從終端機執行：

```bat
setup-cpp.bat
```

> 建議先把資料夾複製到本機（例如 `Downloads`）再執行。放在雲端硬碟或網路磁碟代號上時，提權後的視窗可能看不到該磁碟機。

## 執行流程

1. 檢查是否為系統管理員，不是就以管理員身分重新啟動自己
2. 檢查 winget
3. 檢查 / 安裝 MSYS2
4. 更新 MSYS2（執行兩次；第一次更新核心後可能中途結束，屬正常現象）
5. 以 pacman 安裝 GCC、GDB、CMake、Ninja（網路失敗自動重試 3 次）
6. 設定使用者 PATH
7. 驗證：
   - 逐一檢查 `gcc`、`g++`、`gdb`、`cmake`、`ninja` 能否執行，並確認實際跑到的是 MSYS2 版本
   - 用 `g++ -std=c++20` 編譯並執行一支 C++20 測試程式
   - 用 CMake + Ninja 再建置並執行一次

**可重複執行**：中途失敗、或換新電腦時，直接再跑一次即可。

## 安裝後怎麼用

```bash
# 直接編譯
g++ -std=c++20 main.cpp -o main.exe

# 使用 CMake + Ninja
cmake -S . -B build -G Ninja
cmake --build build
```

> 用 UCRT64 編出的 `.exe` 會動態連結 `ucrt64\bin` 裡的 DLL。要拿到沒有安裝 MSYS2 的電腦執行，請加上 `-static`，或一併附上所需的 DLL。

## 自訂

打開 `setup-cpp.ps1`，只需要修改最上方「設定」區：

```powershell
$MsysRoot = 'C:\msys64'          # MSYS2 安裝位置
$Packages = @(
    'mingw-w64-ucrt-x86_64-toolchain',
    'mingw-w64-ucrt-x86_64-cmake',
    'mingw-w64-ucrt-x86_64-ninja'
    # 想多裝的套件加在這裡，例如：
    # 'mingw-w64-ucrt-x86_64-clang'
)
```

## 記錄檔與疑難排解

| 檔案 | 位置 |
|------|------|
| 安裝記錄 | `%TEMP%\cpp-setup.log` |
| 原 PATH 備份 | `%TEMP%\user-path-backup-<時間>.txt` |

| 問題 | 處理方式 |
|------|----------|
| 找不到 winget | 到 Microsoft Store 更新「應用程式安裝程式」後重跑 |
| pacman 更新或安裝失敗 | 通常是網路問題，直接重跑；仍失敗請看記錄檔 |
| 新開的終端機找不到 `g++` | 關閉所有終端機與 VS Code 後重新開啟 |
| 驗證時出現「目前會先執行 … 而不是 MSYS2 版本」 | 系統 PATH 裡有其他編譯器排在前面，請調整或移除 |
| 提示找不到 MSYS2 | MSYS2 可能裝在別的資料夾，請修改 `$MsysRoot` |
| 公司電腦被群組原則擋下腳本 | 執行原則被 GPO 強制，需請 IT 放行 |

## 解除安裝

1. 執行 `winget uninstall MSYS2.MSYS2`，或直接刪除 `C:\msys64`
2. 在「編輯系統環境變數 → 環境變數」的使用者 `Path` 中，移除 `C:\msys64\ucrt64\bin`

## 安全說明

腳本會以系統管理員身分執行，只做三件事：透過 winget 安裝 MSYS2、透過 pacman 安裝上述套件、修改**目前使用者**的 PATH。執行前歡迎自行閱讀 `setup-cpp.ps1` 全文。

## 開發注意事項

- `.bat` 與 `.ps1` 必須使用 **CRLF** 換行（批次檔的 `goto` 標籤在 LF 換行下可能失效），本專案以 `.gitattributes` 強制設定。
- `setup-cpp.ps1` 含中文訊息，請保持 **UTF-8 with BOM** 編碼，否則 Windows PowerShell 5.1 會亂碼。
- `setup-cpp.bat` 刻意維持純 ASCII，所有邏輯都放在 `.ps1`。

## 測試環境

<!-- 實測後請在此填入，例如：Windows 11 23H2 x64（全新安裝）、Windows 10 22H2 x64 -->
