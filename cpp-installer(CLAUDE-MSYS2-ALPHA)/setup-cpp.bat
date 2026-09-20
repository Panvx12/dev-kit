@echo off
setlocal
rem Launcher for setup-cpp.ps1 (keep both files in the same folder).
rem This file is intentionally ASCII-only; all logic and messages live in the .ps1.

set "PS1=%~dp0setup-cpp.ps1"
set "POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

if not exist "%PS1%" goto :missing

"%POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %*
set "RC=%errorlevel%"

if not "%RC%"=="0" pause
exit /b %RC%

:missing
echo Cannot find setup-cpp.ps1 next to this file:
echo   "%PS1%"
pause
exit /b 1