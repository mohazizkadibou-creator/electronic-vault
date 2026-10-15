#!/usr/bin/env bash
# Build the Electronic Vault web (PWA) product and package it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "[1/3] flutter pub get"
flutter pub get

echo "[2/3] flutter build web --release"
flutter build web --release

echo "[3/3] packaging build/web -> electronic-vault-web.zip"
( cd build/web && zip -r "$ROOT/electronic-vault-web.zip" . )

echo "Done: electronic-vault-web.zip"
