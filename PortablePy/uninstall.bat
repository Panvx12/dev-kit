@echo off
setlocal
chcp 65001 >nul
title PortablePy Uninstaller

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"
set "RC=%ERRORLEVEL%"

echo.
if "%RC%"=="0" (
    echo PortablePy was removed.
) else (
    echo PortablePy uninstall failed. Exit code: %RC%
)
echo.
pause
exit /b %RC%
