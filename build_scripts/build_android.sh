#!/usr/bin/env bash
# Build the Electronic Vault Android products (APK + AAB).
# Requires: Flutter SDK + JDK 17.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "[1/3] flutter pub get"
flutter pub get

echo "[2/3] flutter build apk --release"
flutter build apk --release

echo "[3/3] flutter build appbundle --release"
flutter build appbundle --release

echo "Done:"
echo "  build/app/outputs/flutter-apk/app-release.apk"
echo "  build/app/outputs/bundle/release/app-release.aab"
