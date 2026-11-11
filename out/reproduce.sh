#!/bin/bash
# Reproduce both prototypes from a clean checkout of this branch.
# Usage: out/reproduce.sh [workdir]   (default: a fresh temp dir). Needs hugo, node>=22.23, npm, uv, python3.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
W=${1:-$(mktemp -d)}; mkdir -p "$W"; echo "workdir: $W"
# 1. Hugo: base site + slice patch
mkdir -p "$W/hugo" "$W/kit"
git -C "$ROOT" archive HEAD | tar x -C "$W/hugo" --exclude=out
git -C "$ROOT" archive HEAD out | tar x -C "$W/kit"
(cd "$W/hugo" && git init -q && git apply "$W/kit/out/prototypes/hugo-slice.patch" && hugo --gc --minify -d "$W/hugo-public")
# 2. Astro: authored files + shared assets copied from the site and the slice kit
mkdir -p "$W/astro" && cp -R "$W/kit/out/prototypes/astro/." "$W/astro/"
mkdir -p "$W/astro/src/styles" "$W/astro/src/scripts" "$W/astro/src/content" "$W/astro/public"
cp "$W"/hugo/assets/css/{tokens,main,fieldnotes}.css "$W/astro/src/styles/"
cp "$W/kit/out/slice/atlas.css" "$W/astro/src/styles/"; cp "$W/kit/out/slice/atlas.js" "$W/astro/src/scripts/"
cp "$W/kit/out/slice/records.json" "$W/astro/src/content/atlas_sample.json"
cp -R "$W/hugo/static/fonts" "$W/astro/public/fonts"; rm -f "$W/astro/public/fonts/README.md"; cp "$W"/hugo/static/favicon.{svg,ico} "$W/astro/public/"
(cd "$W/astro" && npm ci --silent && npm run build)
# 3. Serve both slices and run the probe
(python3 -m http.server 4201 -d "$W/hugo-public" >/dev/null 2>&1 & echo $! > "$W/s1.pid"); (python3 -m http.server 4202 -d "$W/astro/dist" >/dev/null 2>&1 & echo $! > "$W/s2.pid")
sleep 1
(cd "$W" && npm i --silent axe-core@4 --prefix "$W/tools" >/dev/null 2>&1 || true)
AXE=$(ls "$W/tools/node_modules/axe-core/axe.min.js")
uv run --no-project --with playwright python "$W/kit/out/measure/probe.py" http://localhost:4201 http://localhost:4202 "$AXE" "$W/results"
kill "$(cat "$W/s1.pid")" "$(cat "$W/s2.pid")" || true
echo "results: $W/results/results.json"
