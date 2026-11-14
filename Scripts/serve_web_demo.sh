#!/usr/bin/env bash
# One site: therapist page at /, game under /play/?level=N for the patient.
# Opens the therapist page in the default browser when ready.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
URL="http://127.0.0.1:8077/"

if ! command -v godot >/dev/null 2>&1; then
  echo "godot not on PATH. Install Godot 4.7.2 and retry." >&2
  exit 1
fi

mkdir -p build/web/play
# Wipe previous demo tree (keep folder). Avoids stale root wasm/js beside the therapist page.
find build/web -mindepth 1 -maxdepth 1 ! -name play -delete 2>/dev/null || true
find build/web/play -mindepth 1 -delete 2>/dev/null || true
mkdir -p build/web/play

echo "Exporting Web build to build/web/play/ ..."
godot --headless --path "$ROOT" --export-release "Web" "$ROOT/build/web/play/index.html" || true

if [[ ! -f build/web/play/index.html || ! -f build/web/play/index.wasm || ! -f build/web/play/index.pck ]]; then
  echo "Export failed: missing build/web/play engine files." >&2
  exit 1
fi

cp "$ROOT/site/index.html" "$ROOT/build/web/index.html"

echo
echo "Therapist site: $URL"
echo "Pick a mode there. The patient then plays that store level."
echo "GodotTogether 'Chat' dock messages on export are harmless."
echo

open_demo() {
  # Give the server a moment to bind the port.
  sleep 0.6
  if command -v open >/dev/null 2>&1; then
    open "$URL"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$URL" >/dev/null 2>&1 || true
  else
    echo "Open $URL in your browser."
  fi
}

open_demo &
cd "$ROOT/build/web"
exec python3 -m http.server 8077
