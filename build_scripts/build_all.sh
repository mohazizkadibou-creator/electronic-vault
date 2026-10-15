#!/usr/bin/env bash
# Build every product the current machine can produce.
#
#   ./build_all.sh          # all platforms available on this OS
#   ./build_all.sh web      # only web
#   ./build_all.sh android  # only android
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-all}"

run() {
  echo ""
  echo "=============================================="
  echo "  $1"
  echo "=============================================="
  bash "$ROOT/build_scripts/$1" || echo "[WARN] $1 failed (see output above)"
}

case "$TARGET" in
  web)     run build_web.sh ;;
  android) run build_android.sh ;;
  all)
    run build_web.sh
    run build_android.sh
    ;;
  *)
    echo "Unknown target: $TARGET"
    echo "Usage: ./build_all.sh [all|web|android]"
    exit 1
    ;;
esac

echo ""
echo "All requested builds finished."
