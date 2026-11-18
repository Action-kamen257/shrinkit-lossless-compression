@echo off
setlocal enabledelayedexpansion

REM ================================================================
REM  ShrinkIt — Qt 6 Silent Install Script
REM
REM  Installs only what ShrinkIt needs:
REM    - Qt 6.9  (MSVC 2022 x64)
REM    - Qt Quick / QML / QuickControls2 / Qt5Compat
REM    - CMake (bundled) + Ninja
REM
REM  Requires: Qt account credentials (free)
REM  Installer: qt-online-installer-windows-x64-online.exe
REM
REM  Usage:
REM    install_qt.bat <qt_email> <qt_password>
REM    install_qt.bat          (interactive GUI mode)
REM ================================================================

set INSTALLER=%USERPROFILE%\Downloads\qt-online-installer-windows-x64-online.exe

if not exist "%INSTALLER%" (
    echo [Error] Qt installer not found at: %INSTALLER%
    echo Please download it first from: https://download.qt.io/official_releases/online_installers/
    exit /b 1
)

REM If credentials are provided, do silent install
if not "%1"=="" if not "%2"=="" (
    echo [ShrinkIt] Running Qt 6.9 silent install...
    echo Packages: MSVC 2022 x64, Quick, QML, QuickControls2

    "%INSTALLER%" ^
        --email %1 ^
        --pw %2 ^
        --accept-licenses ^
        --accept-obligations ^
        --default-answer ^
        --confirm-command ^
        install ^
        qt.qt6.690.win64_msvc2022_64 ^
        qt.qt6.690.qtquick ^
        qt.qt6.690.qtquickcontrols2 ^
        qt.qt6.690.qml ^
        qt.qt6.690.qt5compat ^
        qt.qt6.690.addons.qtmultimedia ^
        qt.tools.cmake ^
        qt.tools.ninja

    echo.
    echo [ShrinkIt] Qt 6.9 installation complete!
    echo Now run: scripts\build_qt.bat
    exit /b 0
)

REM No credentials — launch GUI installer with pre-selected ShrinkIt packages
echo [ShrinkIt] Launching Qt Online Installer GUI...
echo.
echo When the installer opens:
echo   1. Sign in (or create a free Qt account at account.qt.io)
echo   2. Choose "Custom Installation"
echo   3. Under Qt 6.x (latest), tick ONLY:
echo        [x] MSVC 2022 64-bit
echo        [x] Qt Quick
echo        [x] Qt Quick Controls 2
echo        [x] Qt 5 Compatibility Module
echo   4. Under Tools, tick:
echo        [x] CMake
echo        [x] Ninja
echo   5. Install to default path: C:\Qt
echo   6. After install, run: scripts\build_qt.bat
echo.

start "" "%INSTALLER%"
exit /b 0
