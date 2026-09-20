@echo off
setlocal
chcp 65001 >nul
title PortablePy Installer

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
set "RC=%ERRORLEVEL%"

echo.
if not "%RC%"=="0" (
    echo PortablePy installation failed. Exit code: %RC%
) else (
    echo PortablePy installation completed successfully.
)
echo.
pause
exit /b %RC%
