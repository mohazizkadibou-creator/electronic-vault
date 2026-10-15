# Build the Electronic Vault Windows desktop product and package it.
# Requires: Flutter SDK + Visual Studio (Desktop development with C++).
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

Write-Host "[1/3] flutter pub get"
flutter pub get

Write-Host "[2/3] flutter build windows --release"
flutter build windows --release

Write-Host "[3/3] packaging build/windows/x64/runner/Release"
$out = Join-Path $Root "electronic-vault-windows.zip"
if (Test-Path $out) { Remove-Item $out -Force }
Compress-Archive -Path "build/windows/x64/runner/Release/*" -DestinationPath $out

Write-Host "Done: electronic-vault-windows.zip"
