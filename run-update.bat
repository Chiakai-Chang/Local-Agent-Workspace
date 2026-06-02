@echo off
chcp 65001 >nul 2>nul

set "SCRIPT_DIR=%~dp0"
set "PS1_FILE=%SCRIPT_DIR%update-llama-cpp.ps1"

echo Running llama.cpp updater...
echo.

if not exist "%PS1_FILE%" (
    echo ERROR: Cannot find PowerShell script:
    echo %PS1_FILE%
    echo.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS1_FILE%"

if errorlevel 1 (
    echo.
    echo ERROR: Update failed.
    echo.
    pause
    exit /b 1
)

echo.
echo Update completed successfully.
echo.
pause