@echo off
setlocal enabledelayedexpansion

echo ===================================================
echo   Configuring ShrinkIt C++ Backend with MSVC...
echo ===================================================

call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 (
    echo [Error] Failed to initialize Visual Studio 2022 x64 environment.
    exit /b 1
)

set CMAKE_EXE="C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
set NINJA_EXE="C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe"

if not exist build (
    mkdir build
)

cd build

%CMAKE_EXE% -G "Ninja" -DCMAKE_MAKE_PROGRAM=%NINJA_EXE% -DCMAKE_BUILD_TYPE=Release ..
if errorlevel 1 (
    echo [Error] CMake configuration failed.
    exit /b 1
)

%NINJA_EXE%
if errorlevel 1 (
    echo [Error] Compilation failed.
    exit /b 1
)

echo.
echo ===================================================
echo   Build Successful! Executables generated in build/bin
echo ===================================================
cd ..
exit /b 0
