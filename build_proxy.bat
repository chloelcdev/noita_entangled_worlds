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
    echo Copied steam_api64.dll into build folder.
) else if not exist "%OUT%\steam_api64.dll" (
    echo.
    echo Note: copy steam_api64.dll from noita_proxy-win.zip into:
    echo   %OUT%
)

set "STAGE=%~dp0release"
if not exist "%STAGE%" mkdir "%STAGE%"

echo.
echo Staging release files to:
echo   %STAGE%
echo.

copy /Y "%EXE%" "%STAGE%\noita_proxy.exe" >nul
if errorlevel 1 (
    echo Failed to copy noita_proxy.exe
    pause
    exit /b 1
)

if exist "%OUT%\steam_api64.dll" (
    copy /Y "%OUT%\steam_api64.dll" "%STAGE%\steam_api64.dll" >nul
) else if exist "redist\steam_api64.dll" (
    copy /Y "redist\steam_api64.dll" "%STAGE%\steam_api64.dll" >nul
) else (
    echo Warning: steam_api64.dll not staged - add it manually.
)

if exist "%OUT%\ew_log.txt" (
    copy /Y "%OUT%\ew_log.txt" "%STAGE%\ew_log.txt" >nul
) else (
    echo Note: ew_log.txt not found in build folder ^(created when you run the proxy^).
)

if exist "%OUT%\ew_log_old.txt" (
    copy /Y "%OUT%\ew_log_old.txt" "%STAGE%\ew_log_old.txt" >nul
) else (
    echo Note: ew_log_old.txt not found in build folder ^(created when you run the proxy^).
)

echo.
echo Done.
echo   %STAGE%\noita_proxy.exe
echo.
echo Dev tip - skip auto mod install:
echo   set NP_SKIP_MOD_CHECK=1
echo   "%STAGE%\noita_proxy.exe"
echo.
pause
