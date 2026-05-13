#!/usr/bin/env bash
# Create a small source-only zip (no .dart_tool, build/, Gradle caches, Pods, etc.).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

if command -v flutter >/dev/null 2>&1; then
  (cd "$REPO_ROOT" && flutter clean)
  if [[ -f "$REPO_ROOT/example/pubspec.yaml" ]]; then
    (cd "$REPO_ROOT/example" && flutter clean) || true
  fi
else
  echo "warning: flutter not on PATH; skipping flutter clean" >&2
fi

mkdir -p "$STAGING/archive"
rsync -a \
  --exclude='.dart_tool/' \
  --exclude='**/build/' \
  --exclude='.gradle/' \
  --exclude='**/.gradle/' \
  --exclude='Pods/' \
  --exclude='**/Pods/' \
  --exclude='.symlinks/' \
  --exclude='**/DerivedData/' \
  --exclude='.idea/' \
  --exclude='**/.idea/' \
  --exclude='*.iml' \
  --exclude='.DS_Store' \
  --exclude='**/local.properties' \
  --exclude='.cxx/' \
  --exclude='**/captures/' \
  --exclude='**/Flutter/ephemeral/' \
  --exclude='**/.last_build_id' \
  --exclude='.pub-cache/' \
  --exclude='.pub/' \
  --exclude='**/*.symbols' \
  --exclude='**/*.map.json' \
  "$REPO_ROOT/" "$STAGING/archive/$(basename "$REPO_ROOT")/"

NAME="$(basename "$REPO_ROOT")-source"
OUT_ZIP="${1:-$REPO_ROOT/../${NAME}.zip}"
OUT_DIR="$(dirname "$OUT_ZIP")"
mkdir -p "$OUT_DIR"

( cd "$STAGING/archive" && zip -r -q "$OUT_ZIP" "$(basename "$REPO_ROOT")" )

BYTES="$(wc -c <"$OUT_ZIP" | tr -d ' ')"
echo "Wrote: $OUT_ZIP ($BYTES bytes)"
