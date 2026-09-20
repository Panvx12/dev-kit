# 🪄 ImageMagick (magick) Windows 一鍵自動安裝腳本

這個專案提供了一個便利的 Windows 批次檔 (`install_magick.bat`)，讓你能透過一行指令自動下載、安裝 **ImageMagick**，並自動完成系統環境變數 (`PATH`) 的設定。

---

## 🌟 特點與功能

* **一鍵自動化**：自動呼叫 Windows 內建的 `winget` 套件管理工具。
* **免手動設定環境變數**：自動將 `magick` 指令加入系統路徑（PATH），安裝完成即可在 CMD / PowerShell / VS Code 終端機直接使用。
* **靜默/自動授權**：自動接受軟體安裝條款，無需多餘的手動點擊與等待。

---

## 💻 系統需求

* **作業系統**：Windows 10 (1709 以上) 或 Windows 11。
* **必要元件**：系統需內建 **Windows Package Manager (`winget`)**（Windows 10/11 通常已內建）。

---

## 🚀 使用步驟

### 方法一：直接下載執行

1. 將本專案的 `install_magick.bat` 下載或儲存至你的電腦。
2. 找到 `install_magick.bat` 檔案，在檔案上點擊 **右鍵**。
3. 選擇 **「以系統管理員身分執行」**（*重要：安裝軟體與寫入環境變數需要管理員權限*）。
4. 視窗開啟後將自動進行下載與安裝，看到 `[成功] ImageMagick 已順利安裝完成！` 即表示安裝完畢。

### 方法二：透過 Git 複製使用

```cmd
git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY_NAME.git
cd YOUR_REPOSITORY_NAME
install_magick.bat
```

---

## 🔍 驗證安裝結果

1. **關閉並重新開啟** 你的終端機（CMD、PowerShell 或 VS Code）。
2. 輸入以下指令驗證：

```bash
magick -version
```

若正確顯示 ImageMagick 的版本資訊（例如 `Version: ImageMagick 7.x.x...`），即代表安裝成功！

---

## 🛠️ 常見問題 (FAQ)

### Q1: 執行時提示「找不到 winget 指令」？
請確保你的 Windows 系統已更新至最新版本，或至 Microsoft Store 搜尋並更新/安裝 **「App 檢視器 (App Installer)」**。

### Q2: 安裝完後輸入 `magick` 卻提示「不是內部或外部命令」？
請務必**重新啟動**你的命令提示字元 (CMD) 或 VS Code，讓新的系統環境變數生效。

---

## 📝 授權 (License)

本腳本採用 [MIT License](LICENSE) 釋出，歡迎自由修改與分享。