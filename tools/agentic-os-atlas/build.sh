#!/usr/bin/env bash
# Rebuild the page-scoped atlas bundle (assets/atlas/agentic-os/) from a pinned, patched Arc.
#
#   bash build.sh              # clone Arc at the pin, apply patches/arc-engine.patch, build, bundle
#   bash build.sh --studio     # also build Arc Studio to .arc/studio-build (local review only)
#
# Needs Node 22+ and git. Nothing here runs in the Hugo build or in CI: the bundle is committed
# and Hugo only publishes it when the atlas page itself is rendered.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
pin=2c4945e27feca763d18d5d8bb1eff0ed73c64726          # hudsonkit/arc, package 0.15.1
work="$here/.arc"; arc="$work/arc"
mkdir -p "$work"
if [[ ! -d "$arc/.git" ]]; then
  git clone --quiet https://github.com/hudsonkit/arc.git "$arc"
fi
git -C "$arc" fetch --quiet origin "$pin" 2>/dev/null || true
git -C "$arc" checkout --quiet --detach "$pin"
git -C "$arc" reset --quiet --hard "$pin"
[[ "$(git -C "$arc" rev-parse HEAD)" == "$pin" ]] || { echo "Arc is not at the pinned revision" >&2; exit 1; }
git -C "$arc" apply "$here/patches/arc-engine.patch"
cp "$here/patches/arc-package-lock.json" "$arc/package-lock.json"     # locked dependency set
( cd "$arc" && PUPPETEER_SKIP_DOWNLOAD=1 npm ci --legacy-peer-deps --no-audit --no-fund && npm run build:lib )
python3 "$here/build_plates.py"          # regenerates data/agentic-os from the authored spec
ARC_DIR="$arc" "$arc/node_modules/.bin/vite" build --config "$here/vite.config.mjs"
if [[ "${1:-}" == "--studio" ]]; then
  ( cd "$arc" && node_modules/.bin/vite build --base /studio/ --outDir "$work/studio-build" --emptyOutDir )
  echo "Studio built. Serve with: python3 $here/studio-serve.py $work/studio-build"
fi
echo "Bundle written to assets/atlas/agentic-os/. Rebuild Hugo to pick it up."
