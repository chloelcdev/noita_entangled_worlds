@echo off
setlocal

cd /d "%~dp0"

if exist "release.env" (
    for /f "usebackq eol=# tokens=1,* delims==" %%A in ("release.env") do (
        if /i "%%A"=="EW_GITHUB_REPO" set "EW_GITHUB_REPO=%%B"
    )
)
if not defined EW_GITHUB_REPO set "EW_GITHUB_REPO=chloelcdev/noita_entangled_worlds"
set "EW_GITHUB_REPO=%EW_GITHUB_REPO: =%"

set "PATH=C:\Program Files\CMake\bin;%USERPROFILE%\.cargo\bin;%PATH%"
set "CARGO_TARGET_DIR=%LOCALAPPDATA%\noita_proxy_target"
set "CMAKE_POLICY_VERSION_MINIMUM=3.5"
set "OUT=%CARGO_TARGET_DIR%\release"
set "EXE=%OUT%\noita_proxy.exe"

REM Load MSVC environment (cmake + linker need this)
if exist "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>nul
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>nul
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>nul
)

where cargo >nul 2>&1
if errorlevel 1 (
    echo Rust/cargo not found. Install from https://rustup.rs then reopen this window.
    if /i not "%~1"=="nopause" pause
    exit /b 1
)

where cmake >nul 2>&1
if errorlevel 1 (
    echo CMake not found.
    echo Expected: C:\Program Files\CMake\bin\cmake.exe
    if /i not "%~1"=="nopause" pause
    exit /b 1
)

echo Building noita_proxy ^(release^) for GitHub repo: %EW_GITHUB_REPO%
echo Build output: %OUT%
echo.

cd noita_proxy
cargo build --release
if errorlevel 1 (
    echo.
    echo Build failed.
    if /i not "%~1"=="nopause" pause
    exit /b 1
)
cd ..

if not exist "%EXE%" (
    echo Expected exe missing: %EXE%
    if /i not "%~1"=="nopause" pause
    exit /b 1
)

where python >nul 2>&1
if errorlevel 1 (
    echo Python not found - skipping zip packaging. Install Python to package quant.ew.zip.
    goto stage_exe_only
)

set "PROXY_EXE=%EXE%"
python scripts\package_fork_release.py
if errorlevel 1 (
    echo Packaging failed.
    if /i not "%~1"=="nopause" pause
    exit /b 1
)
goto done

:stage_exe_only
set "STAGE=%~dp0release"
if not exist "%STAGE%" mkdir "%STAGE%"
copy /Y "%EXE%" "%STAGE%\noita_proxy.exe" >nul
if exist "redist\steam_api64.dll" copy /Y "redist\steam_api64.dll" "%STAGE%\steam_api64.dll" >nul

:done
echo.
echo Done.
echo   Proxy exe: %EXE%
echo   Staged:    %~dp0release\
echo   Mod/proxy zips download from: https://github.com/%EW_GITHUB_REPO%/releases
echo.
echo Publish to GitHub: publish_release.bat
echo Local dev ^(skip mod download^): set NP_SKIP_MOD_CHECK=1
echo.
if /i not "%~1"=="nopause" pause
