@echo off
setlocal
title Electronic Vault - Setup & Run
cd /d "%~dp0"

echo ==========================================
echo   Electronic Vault - Setup ^& Run
echo ==========================================
echo.

set "FLUTTER_HOME="
if exist "C:\Users\info\flutter\bin\flutter.bat" set "FLUTTER_HOME=C:\Users\info\flutter"
if not defined FLUTTER_HOME if exist "%USERPROFILE%\flutter\bin\flutter.bat" set "FLUTTER_HOME=%USERPROFILE%\flutter"
if not defined FLUTTER_HOME if exist "C:\flutter\bin\flutter.bat" set "FLUTTER_HOME=C:\flutter"
if not defined FLUTTER_HOME if exist "C:\src\flutter\bin\flutter.bat" set "FLUTTER_HOME=C:\src\flutter"

if defined FLUTTER_HOME (
    set "PATH=%FLUTTER_HOME%\bin;%PATH%"
    echo [OK] Flutter found at %FLUTTER_HOME%
) else (
    where flutter >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Flutter not found.
        echo Please run install_flutter.bat or add Flutter to PATH, then try again.
        pause
        exit /b 1
    )
    echo [OK] Flutter found on PATH
)

echo.
echo [1/2] Getting dependencies...
call flutter pub get
if errorlevel 1 ( echo [ERROR] pub get failed & pause & exit /b 1 )

echo.
echo [2/2] Starting Electronic Vault in Chrome...
call flutter run -d chrome

echo.
pause
