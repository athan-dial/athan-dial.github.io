#!/usr/bin/env bash
# Pull plugin docs from athan-dial/skills and generate content/skills/<plugin>.md.
# Idempotent: safe to run at build time.

set -euo pipefail

SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

REPO="${SKILLS_REPO:-athan-dial/skills}"
REF="${SKILLS_REF:-main}"

echo "→ Fetching $REPO@$REF"
git clone --depth 1 --branch "$REF" "https://github.com/$REPO.git" "$TMP/skills" 2>&1 | tail -2

OUT="$SITE_DIR/content/skills"
mkdir -p "$OUT"

for plugin_dir in "$TMP/skills/plugins"/*/; do
  [ -d "$plugin_dir" ] || continue
  name="$(basename "$plugin_dir")"
  readme="$plugin_dir/README.md"
  plugin_json="$plugin_dir/.claude-plugin/plugin.json"

  [ -f "$readme" ] || { echo "  ⚠ $name: no README.md, skipping"; continue; }

  # Extract description from plugin.json if available
  desc=""
  if [ -f "$plugin_json" ]; then
    desc="$(grep -oE '"description"\s*:\s*"[^"]*"' "$plugin_json" | head -1 | sed 's/.*"description"[^"]*"\([^"]*\)"/\1/')"
  fi

  out_file="$OUT/$name.md"
  {
    echo "---"
    echo "title: \"$name\""
    echo "description: \"${desc:-Claude Code plugin}\""
    echo "plugin: \"$name\""
    echo "source: \"https://github.com/$REPO/tree/$REF/plugins/$name\""
    echo "---"
    echo ""
    echo "> Install: \`claude plugin install $REPO:$name\`"
    echo ""
    cat "$readme"
  } > "$out_file"

  echo "  ✓ $name → content/skills/$name.md"
done

echo "→ Done. $(ls "$OUT"/*.md 2>/dev/null | grep -v _index | wc -l | tr -d ' ') plugin pages generated."
