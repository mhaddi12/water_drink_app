#!/usr/bin/env bash
# Sync Hydra app icon + splash screens from appicon.co export into this project.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${1:-$HOME/Downloads/splash_screens/splash_screens}"

if [[ ! -d "$SRC" ]]; then
  echo "Source folder not found: $SRC"
  echo "Usage: $0 [/path/to/splash_screens/splash_screens]"
  exit 1
fi

mkdir -p "$ROOT/assets/branding" "$ROOT/tool/branding/device_splashes"

cp "$SRC/icon.png" "$ROOT/assets/branding/app_icon.png"
cp "$SRC/iPhone_16__iPhone_15_Pro__iPhone_15__iPhone_14_Pro_portrait.png" \
  "$ROOT/tool/branding/device_splashes/" 2>/dev/null || true
cp "$SRC"/*.png "$ROOT/tool/branding/device_splashes/" 2>/dev/null || true

python3 "$ROOT/tool/generate_branding_assets.py"

cd "$ROOT"
flutter pub get
dart run flutter_native_splash:create
dart run flutter_launcher_icons

echo "Branding synced. Rebuild the app to see splash + icon changes."
