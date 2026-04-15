#!/usr/bin/env bash
# Pull plugin docs from athan-dial/skills and emit Hugo page bundles under
# content/skills/<plugin>/. Idempotent: safe to run at build time.
#
# Per plugin, the bundle contains:
#   _index.md       ← from plugins/<p>/docs/_index.md if present, else generated from README.md
#   <topic>.md      ← every other plugins/<p>/docs/*.md, copied verbatim
#   commands.md     ← generated from plugins/<p>/commands/*.md frontmatter
#   changelog.md    ← generated from plugins/<p>/CHANGELOG.md
#
# Legacy flat content/skills/<plugin>.md files are deleted so Hugo doesn't
# serve both. content/skills/_index.md (the hub page) is preserved.

set -euo pipefail

SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

REPO="${SKILLS_REPO:-athan-dial/skills}"
REF="${SKILLS_REF:-main}"

# SKILLS_LOCAL_DIR overrides the git clone for local development / dry runs.
if [ -n "${SKILLS_LOCAL_DIR:-}" ]; then
  echo "→ Using local skills dir: $SKILLS_LOCAL_DIR"
  ln -s "$(cd "$SKILLS_LOCAL_DIR" && pwd)" "$TMP/skills"
else
  echo "→ Fetching $REPO@$REF"
  git clone --depth 1 --branch "$REF" "https://github.com/$REPO.git" "$TMP/skills" 2>&1 | tail -2
fi

OUT="$SITE_DIR/content/skills"
mkdir -p "$OUT"

# Extract a single string field from a tiny JSON file. Tolerates whitespace.
json_field() {
  local file="$1" key="$2"
  grep -oE "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$file" | head -1 \
    | sed -E "s/\"$key\"[[:space:]]*:[[:space:]]*\"([^\"]*)\"/\1/"
}

# Pull a YAML frontmatter scalar from a markdown file. Strips surrounding
# single/double quotes if present. Uses sed for portability (macOS awk
# lacks 3-arg match).
fm_field() {
  local file="$1" key="$2"
  awk -v k="$key" '
    /^---[[:space:]]*$/ { fm++; next }
    fm == 1 && index($0, k ":") == 1 { print; exit }
  ' "$file" \
    | sed -E "s/^${key}[[:space:]]*:[[:space:]]*//; s/^['\"]//; s/['\"]$//"
}

# Delete legacy flat plugin pages (preserve _index.md and any non-plugin dirs).
for legacy in "$OUT"/*.md; do
  [ -e "$legacy" ] || continue
  case "$(basename "$legacy")" in
    _index.md) ;;
    *) echo "  ✗ removing legacy $(basename "$legacy")"; rm -f "$legacy" ;;
  esac
done

for plugin_dir in "$TMP/skills/plugins"/*/; do
  [ -d "$plugin_dir" ] || continue
  name="$(basename "$plugin_dir")"
  readme="$plugin_dir/README.md"
  changelog="$plugin_dir/CHANGELOG.md"
  docs_dir="$plugin_dir/docs"
  cmds_dir="$plugin_dir/commands"
  plugin_json="$plugin_dir/.claude-plugin/plugin.json"

  bundle="$OUT/$name"
  rm -rf "$bundle"
  mkdir -p "$bundle"

  desc=""
  version=""
  if [ -f "$plugin_json" ]; then
    desc="$(json_field "$plugin_json" description)"
    version="$(json_field "$plugin_json" version)"
  fi

  # 1. _index.md — prefer docs/_index.md, else synthesize from README.md
  if [ -f "$docs_dir/_index.md" ]; then
    cp "$docs_dir/_index.md" "$bundle/_index.md"
  elif [ -f "$readme" ]; then
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
    } > "$bundle/_index.md"
  else
    echo "  ⚠ $name: no README.md or docs/_index.md, skipping"
    rm -rf "$bundle"
    continue
  fi

  # 2. Mirror other docs/*.md verbatim (preserves their own frontmatter)
  if [ -d "$docs_dir" ]; then
    for doc in "$docs_dir"/*.md; do
      [ -e "$doc" ] || continue
      base="$(basename "$doc")"
      [ "$base" = "_index.md" ] && continue
      cp "$doc" "$bundle/$base"
    done
  fi

  # 3. commands.md — generated from commands/*.md frontmatter
  if [ -d "$cmds_dir" ] && compgen -G "$cmds_dir/*.md" > /dev/null; then
    {
      echo "---"
      echo "title: \"Commands\""
      echo "description: \"All /$name:* slash commands.\""
      echo "weight: 40"
      echo "---"
      echo ""
      echo "Auto-generated from \`plugins/$name/commands/*.md\` frontmatter. Do not edit by hand."
      echo ""
      echo "| Command | Arguments | Description |"
      echo "|---|---|---|"
      for cmd_file in "$cmds_dir"/*.md; do
        cmd_name="$(basename "$cmd_file" .md)"
        cmd_desc="$(fm_field "$cmd_file" description)"
        cmd_args="$(fm_field "$cmd_file" argument-hint)"
        # Pipe-escape any literal pipes in description/args
        cmd_desc="${cmd_desc//|/\\|}"
        cmd_args="${cmd_args//|/\\|}"
        printf "| \`/%s:%s\` | %s | %s |\n" "$name" "$cmd_name" "${cmd_args:-—}" "${cmd_desc:-—}"
      done
    } > "$bundle/commands.md"
  fi

  # 4. changelog.md — copy CHANGELOG.md with a Hugo frontmatter header
  if [ -f "$changelog" ]; then
    {
      echo "---"
      echo "title: \"Changelog\""
      echo "description: \"Release history for the $name plugin${version:+ (current: $version)}.\""
      echo "weight: 50"
      echo "---"
      echo ""
      cat "$changelog"
    } > "$bundle/changelog.md"
  fi

  echo "  ✓ $name → content/skills/$name/ (v${version:-?})"
done

count="$(find "$OUT" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
echo "→ Done. $count plugin bundle(s) generated under content/skills/."
