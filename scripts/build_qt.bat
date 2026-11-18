@echo off
setlocal enabledelayedexpansion

echo ===================================================
echo   ShrinkIt Qt 6 GUI Build Script
echo ===================================================

set QT_ROOT=C:\Qt\6.8.0\msvc2022_64
if not exist "!QT_ROOT!\bin\qmake.exe" (
    for %%V in (6.8.0 6.9.0 6.8 6.7 6.6) do (
        for %%P in (C:\Qt D:\Qt) do (
            if exist "%%P\%%V\msvc2022_64\bin\qmake.exe" (
                set QT_ROOT=%%P\%%V\msvc2022_64
            )
        )
    )
)

if not exist "!QT_ROOT!\bin\qmake.exe" (
    echo [Error] Qt 6 not found at !QT_ROOT!
    exit /b 1
)

echo [Found] Qt 6 at: !QT_ROOT!
set Qt6_DIR=!QT_ROOT!\lib\cmake\Qt6
set PATH=!QT_ROOT!\bin;%PATH%

REM Init MSVC x64 environment
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 (
    echo [Error] Failed to initialize MSVC environment.
    exit /b 1
)

set CMAKE_EXE="C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
set NINJA_EXE="C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe"

REM Get project directory without trailing backslash
set PROJECT_DIR=%~dp0..
pushd "%PROJECT_DIR%"
set PROJECT_DIR=%CD%
popd

echo Project Directory: %PROJECT_DIR%

REM Map virtual drive X: to eliminate space issues in CMake/Qt tool wrappers
subst X: /d >nul 2>&1
subst X: "%PROJECT_DIR%"
if errorlevel 1 (
    echo [Warning] subst X: failed, building directly in %PROJECT_DIR%
    cd /d "%PROJECT_DIR%"
) else (
    echo [Info] Mapped X: to project directory
    cd /d X:\
)

if exist build rmdir /s /q build
mkdir build
cd build

%CMAKE_EXE% -G "Ninja" ^
    -DCMAKE_MAKE_PROGRAM=%NINJA_EXE% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DQt6_DIR="!Qt6_DIR!" ^
    -DCMAKE_PREFIX_PATH="!QT_ROOT!" ^
    ..

if errorlevel 1 (
    echo [Error] CMake configuration failed.
    subst X: /d >nul 2>&1
    exit /b 1
)

%NINJA_EXE%
if errorlevel 1 (
    echo [Error] Compilation failed.
    subst X: /d >nul 2>&1
    exit /b 1
)

echo.
echo ===================================================
echo   BUILD COMPLETE
echo   Executables in: build\bin\
echo     shrinkit_gui.exe   - Qt 6 GUI application
echo     shrinkit_cli.exe   - Command-line tool
echo     shrinkit_tests.exe - Unit test suite
echo ===================================================
echo.

REM Deploy Qt DLLs next to the executable so it runs standalone
echo Deploying Qt runtime DLLs...
"!QT_ROOT!\bin\windeployqt.exe" ^
    --qmldir "..\src\ui\qml" ^
    --release ^
    bin\shrinkit_gui.exe

echo.
echo [Done] Executables ready in build\bin\shrinkit_gui.exe!
cd /d "%PROJECT_DIR%"
subst X: /d >nul 2>&1
exit /b 0
