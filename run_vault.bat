@echo off
setlocal
title Electronic Vault
cd /d "%~dp0"

if exist "build\windows\x64\runner\Release\electronic_vault.exe" (
    echo Launching built Electronic Vault...
    start "" "build\windows\x64\runner\Release\electronic_vault.exe"
    goto :eof
)

echo Built Windows version not found - starting in Chrome instead.
call "%~dp0setup_and_run.bat"
