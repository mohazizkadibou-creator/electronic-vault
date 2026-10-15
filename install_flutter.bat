@echo off
setlocal
title Electronic Vault - Flutter Installer
cd /d "%~dp0"
cls
echo ==========================================
echo   Electronic Vault - Flutter Installer
echo ==========================================
echo.

set "FLUTTER_HOME="
if exist "C:\Users\info\flutter\bin\flutter.bat" set "FLUTTER_HOME=C:\Users\info\flutter"
if not defined FLUTTER_HOME if exist "%USERPROFILE%\flutter\bin\flutter.bat" set "FLUTTER_HOME=%USERPROFILE%\flutter"
if not defined FLUTTER_HOME if exist "C:\flutter\bin\flutter.bat" set "FLUTTER_HOME=C:\flutter"
if not defined FLUTTER_HOME if exist "C:\src\flutter\bin\flutter.bat" set "FLUTTER_HOME=C:\src\flutter"

if defined FLUTTER_HOME (
    echo [OK] Flutter found at %FLUTTER_HOME%
    set "PATH=%FLUTTER_HOME%\bin;%PATH%"
    call flutter --version
    echo.
    echo Starting the app setup...
    call "%~dp0setup_and_run.bat"
    goto :eof
)

echo [MISSING] Flutter not found on this machine.
echo.
echo Download Flutter (stable) for Windows from:
echo    https://docs.flutter.dev/get-started/install/windows
echo Extract it to C:\flutter so this script can find it, then run this script again.
echo.
echo Tip: you can also run this from Git Bash:
echo    git clone --depth 1 -b stable https://github.com/flutter/flutter.git C:\flutter
pause
