@echo off
setlocal

set "PORTABLEPY_ROOT=%~dp0"
set "PORTABLEPY_PYTHON=%~dp0python"
set "PATH=%~dp0python;%~dp0python\Scripts;%PATH%"

echo.
echo ==========================================
echo          PortablePy Environment
echo ==========================================
echo.
"%~dp0python\python.exe" --version
echo.
echo PortablePy is active in this CMD window.
echo Close this window to leave the environment.
echo.

cmd /K
endlocal
