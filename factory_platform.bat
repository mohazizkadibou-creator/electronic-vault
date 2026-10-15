@echo off
setlocal
title Electronic Vault - Build Products (Factory)
cd /d "%~dp0"

echo ==========================================
echo   Electronic Vault - Build Factory
echo ==========================================
echo.

set "FLUTTER_HOME="
if exist "C:\Users\info\flutter\bin\flutter.bat" set "FLUTTER_HOME=C:\Users\info\flutter"
if not defined FLUTTER_HOME if exist "%USERPROFILE%\flutter\bin\flutter.bat" set "FLUTTER_HOME=%USERPROFILE%\flutter"
if not defined FLUTTER_HOME if exist "C:\flutter\bin\flutter.bat" set "FLUTTER_HOME=C:\flutter"
if defined FLUTTER_HOME set "PATH=%FLUTTER_HOME%\bin;%PATH%"

where flutter >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter not found. Run install_flutter.bat first.
    pause
    exit /b 1
)

echo [1/3] Getting dependencies...
call flutter pub get
if errorlevel 1 ( echo [ERROR] pub get failed & pause & exit /b 1 )

echo.
echo [2/3] Building Web (PWA)...
call flutter build web --release
if errorlevel 1 ( echo [WARN] Web build failed. ) else ( echo [OK] Web built: build\web )

echo.
echo [3/3] Building Windows desktop (needs Visual Studio with C++)...
call flutter build windows --release
if errorlevel 1 (
    echo [SKIP] Windows build failed or toolchain missing.
) else (
    echo [OK] Windows built: build\windows\x64\runner\Release
)

echo.
echo ==========================================
echo   Build finished. See the build\ folder.
echo ==========================================
pause
