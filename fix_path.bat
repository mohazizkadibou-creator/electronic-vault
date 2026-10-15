@echo off
setlocal
title Electronic Vault - Add Flutter to PATH

set "FLUTTER_HOME="
if exist "C:\Users\info\flutter\bin\flutter.bat" set "FLUTTER_HOME=C:\Users\info\flutter"
if not defined FLUTTER_HOME if exist "%USERPROFILE%\flutter\bin\flutter.bat" set "FLUTTER_HOME=%USERPROFILE%\flutter"
if not defined FLUTTER_HOME if exist "C:\flutter\bin\flutter.bat" set "FLUTTER_HOME=C:\flutter"

if not defined FLUTTER_HOME (
    echo [ERROR] Flutter folder not found. Run install_flutter.bat first.
    pause
    exit /b 1
)

echo Adding %FLUTTER_HOME%\bin to your user PATH (permanent)...
setx PATH "%FLUTTER_HOME%\bin;%PATH%"
echo.
echo Done. Close this window and open a NEW Command Prompt, then type: flutter --version
pause
