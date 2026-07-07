@echo off
setlocal EnableDelayedExpansion

cd /d "%~dp0"

echo ============================================================
echo  noita_proxy build dependencies
echo  - Visual Studio 2022 Build Tools ^(C++^)
echo  - CMake
echo ============================================================
echo.
echo Run as Administrator if installs fail.
echo.
pause

set "PATH=%LOCALAPPDATA%\Microsoft\WindowsApps;%PATH%"

set "HAS_WINGET=0"
where winget >nul 2>&1 && set "HAS_WINGET=1"

set "HAS_CHOCO=0"
where choco >nul 2>&1 && set "HAS_CHOCO=1"

if "%HAS_WINGET%"=="0" if "%HAS_CHOCO%"=="0" goto manual

echo.
if "%HAS_WINGET%"=="1" (
    echo Using winget...
    call :install_winget
    if not errorlevel 1 goto done
    echo winget install failed, trying chocolatey...
)

if "%HAS_CHOCO%"=="1" (
    echo Using chocolatey...
    call :install_choco
    if not errorlevel 1 goto done
)

:manual
echo.
echo ============================================================
echo  Automatic install failed or no package manager found.
echo  Install these manually, then restart your terminal:
echo.
echo  1. Visual C++ Build Tools
echo     https://visualstudio.microsoft.com/visual-cpp-build-tools/
echo     Select workload: "Desktop development with C++"
echo.
echo  2. CMake
echo     https://cmake.org/download/
echo     Choose Windows installer, check "Add CMake to PATH"
echo ============================================================
echo.
choice /C YN /M "Open those download pages in your browser now"
if errorlevel 2 goto end
start https://visualstudio.microsoft.com/visual-cpp-build-tools/
start https://cmake.org/download/
goto end

:install_winget
echo.
echo [1/2] Visual Studio Build Tools...
winget install --id Microsoft.VisualStudio.2022.BuildTools -e --accept-package-agreements --accept-source-agreements --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
if errorlevel 1 exit /b 1
echo.
echo [2/2] CMake...
winget install --id Kitware.CMake -e --accept-package-agreements --accept-source-agreements
if errorlevel 1 exit /b 1
exit /b 0

:install_choco
echo.
echo [1/2] Visual Studio Build Tools...
choco install visualstudio2022buildtools -y --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
if errorlevel 1 exit /b 1
echo.
echo [2/2] CMake...
choco install cmake.install -y
if errorlevel 1 exit /b 1
exit /b 0

:done
echo.
echo ============================================================
echo  Done. Close ALL terminals and Cursor, then reopen.
echo  Then run build_proxy.bat
echo ============================================================

:end
echo.
pause
