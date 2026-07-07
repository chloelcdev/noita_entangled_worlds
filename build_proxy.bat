@echo off
setlocal

cd /d "%~dp0"

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
    pause
    exit /b 1
)

where cmake >nul 2>&1
if errorlevel 1 (
    echo CMake not found.
    echo Expected: C:\Program Files\CMake\bin\cmake.exe
    echo Install from https://cmake.org/download/ and check "Add to PATH"
    pause
    exit /b 1
)

echo Building noita_proxy ^(release^)...
echo Build output: %OUT%
echo.

cd noita_proxy
cargo build --release
if errorlevel 1 (
    echo.
    echo Build failed.
    pause
    exit /b 1
)
cd ..

if not exist "%EXE%" (
    echo Expected exe missing: %EXE%
    pause
    exit /b 1
)

if exist "redist\steam_api64.dll" (
    copy /Y "redist\steam_api64.dll" "%OUT%\steam_api64.dll" >nul
    echo Copied steam_api64.dll into release folder.
) else (
    echo.
    echo Note: copy steam_api64.dll from noita_proxy-win.zip next to:
    echo   %EXE%
)

echo.
echo Done.
echo   %EXE%
echo.
echo Dev tip - skip auto mod install:
echo   set NP_SKIP_MOD_CHECK=1
echo   "%EXE%"
echo.
pause
