@echo off
setlocal
cd /d "%~dp0"

call build_proxy.bat nopause
if errorlevel 1 exit /b 1

where gh >nul 2>&1
if errorlevel 1 (
    echo gh CLI not found. Install from https://cli.github.com/
    pause
    exit /b 1
)

where python >nul 2>&1
if errorlevel 1 (
    echo Python not found.
    pause
    exit /b 1
)

python scripts\publish_release.py
if errorlevel 1 (
    echo Publish failed.
    pause
    exit /b 1
)

pause
