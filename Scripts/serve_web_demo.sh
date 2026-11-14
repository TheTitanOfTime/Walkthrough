#!/usr/bin/env bash
# One site: therapist page at /, game under /play/?level=N for the patient.
# Opens the therapist page in the default browser when ready.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
URL="http://127.0.0.1:8077/"
STAGING="$ROOT/build/web_export_staging"

if ! command -v godot >/dev/null 2>&1; then
  echo "godot not on PATH. Install Godot 4.7.2 and retry." >&2
  exit 1
fi

# Stop a previous demo server on 8077 so it cannot lock play/*.pck during rename.
if command -v lsof >/dev/null 2>&1; then
  PIDS="$(lsof -tiTCP:8077 -sTCP:LISTEN 2>/dev/null || true)"
  if [[ -n "${PIDS}" ]]; then
    echo "Stopping previous server on 8077..."
    # shellcheck disable=SC2086
    kill ${PIDS} 2>/dev/null || true
    sleep 0.4
  fi
fi

rm -rf "$STAGING"
mkdir -p "$STAGING" "$ROOT/build/web"

echo "Exporting Web build (staging) ..."
# Export into an empty staging dir. Godot finishes the .pck with rename(2); exporting
# onto a wiped-in-place play/ folder (or a live http.server) is what triggers
# rename_error / missing index.pck. GodotTogether "Chat" dock lines on exit are noise.
if ! godot --headless --path "$ROOT" --export-release "Web" "$STAGING/index.html"; then
  echo "Godot export exited non-zero. Check the log above." >&2
  exit 1
fi

if [[ ! -f "$STAGING/index.html" || ! -f "$STAGING/index.wasm" || ! -f "$STAGING/index.pck" ]]; then
  echo "Export failed: missing staging engine files under $STAGING" >&2
  ls -la "$STAGING" >&2 || true
  exit 1
fi

# Drop Godot's accidental .import sidecars next to the HTML shell.
find "$STAGING" -maxdepth 1 -name '*.import' -delete 2>/dev/null || true

rm -rf "$ROOT/build/web/play"
mkdir -p "$ROOT/build/web/play"
# Move finished artifacts into place (no mid-write readers).
mv "$STAGING"/* "$ROOT/build/web/play/"
rmdir "$STAGING" 2>/dev/null || rm -rf "$STAGING"

# Therapist page at site root; wipe stray root wasm/js from older layouts.
find "$ROOT/build/web" -mindepth 1 -maxdepth 1 ! -name play -delete 2>/dev/null || true
cp "$ROOT/site/index.html" "$ROOT/build/web/index.html"

echo
echo "Therapist site: $URL"
echo "Pick a mode there. The patient then plays that store level."
echo "Ignore GodotTogether 'Chat' dock messages — they are not export failures."
echo

open_demo() {
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
