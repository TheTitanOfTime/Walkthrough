#!/usr/bin/env bash
# Export the Web build, place the therapist page in front of the game, serve on 8077.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p build/web/play
godot --headless --path "$ROOT" --export-release "Web" "$ROOT/build/web/play/index.html"
cp "$ROOT/site/index.html" "$ROOT/build/web/index.html"
echo "Therapist page: http://127.0.0.1:8077/"
echo "Game (menus):   http://127.0.0.1:8077/play/"
cd "$ROOT/build/web"
exec python3 -m http.server 8077
