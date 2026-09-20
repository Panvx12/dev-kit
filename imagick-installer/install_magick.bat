@echo off
chcp 65001 >nul
title 自動下載並安裝 ImageMagick

echo ===================================================
echo   正在為您下載並安裝 ImageMagick (magick)...
echo ===================================================
echo.

:: 使用 Windows 內建 winget 工具自動下載安裝
winget install --id ImageMagick.ImageMagick --exact --source winget --accept-package-agreements --accept-source-agreements

echo.
if %errorlevel% equ 0 (
    echo ===================================================
    echo   [成功] ImageMagick 已順利安裝完成！
    echo   提示：請「重啟 VS Code 或 命令提示字元」以套用設定。
    echo ===================================================
) else (
    echo ===================================================
    echo   [失敗] 安裝過程出現問題，請嘗試以系統管理員身分執行。
    echo ===================================================
)

echo.
pause