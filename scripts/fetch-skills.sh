#!/usr/bin/env bash
# Download pre-built plugin subsites from athan-dial/skills releases and extract
# them into docs/skills/<plugin>/ for Hugo to serve as static trees (index.html +
# docs/). No content/ writes.
#
# Env:
#   SKILLS_REPO      — default: athan-dial/skills
#   SKILLS_LOCAL_DIR — if set, skip gh release download; use local marketplace.json
#                      and dist/<plugin>-site-*.tar.gz or bin/build-plugin-site.

set -euo pipefail

SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_REPO="${SKILLS_REPO:-athan-dial/skills}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

DOCS_SKILLS="$SITE_DIR/docs/skills"

die() { echo "error: $*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is required but not installed."
}

require_gh() {
  command -v gh >/dev/null 2>&1 || die \
    "gh (GitHub CLI) is required when SKILLS_LOCAL_DIR is unset. Install: https://cli.github.com/"
}

read_marketplace_json() {
  if [ -n "${SKILLS_LOCAL_DIR:-}" ]; then
    local mp="$SKILLS_LOCAL_DIR/.claude-plugin/marketplace.json"
    [ -f "$mp" ] || die "SKILLS_LOCAL_DIR marketplace missing: $mp"
    cat "$mp"
  else
    require_gh
    gh api "repos/${SKILLS_REPO}/contents/.claude-plugin/marketplace.json" --jq '.content' | base64 -d
  fi
}

# Prefer tags like plugin-v* (first match in list order), else latest plugin-site-* by version sort.
resolve_release_tag() {
  local p="$1"
  local list_json
  list_json="$(gh release list --repo "$SKILLS_REPO" --json tagName --limit 100)"
  local tag
  tag="$(jq -r --arg p "$p" '[.[] | select(.tagName | startswith($p + "-v")) | .tagName] | .[0] // empty' <<<"$list_json")"
  if [ -z "$tag" ]; then
    tag="$(jq -r --arg p "$p" '.[] | select(.tagName | startswith($p + "-site-")) | .tagName' <<<"$list_json" | sort -V | tail -n 1)"
  fi
  printf '%s' "$tag"
}

version_label_from_tag() {
  local p="$1" tag="$2"
  if [ -z "$tag" ]; then
    printf '?'
    return
  fi
  if [[ "$tag" == "$p"-v* ]]; then
    printf '%s' "${tag#"$p"-}"
    return
  fi
  if [[ "$tag" == "$p"-site-* ]]; then
    printf '%s' "${tag#"$p"-site-}"
    return
  fi
  printf '%s' "$tag"
}

pick_local_tarball() {
  local p="$1" dir="$2"
  shopt -s nullglob
  local -a files=( "$dir/${p}-site-"*.tar.gz )
  shopt -u nullglob
  if [ "${#files[@]}" -eq 0 ]; then
    return 1
  fi
  if [ "${#files[@]}" -eq 1 ]; then
    printf '%s' "${files[0]}"
    return 0
  fi
  # Latest semver-ish sort
  printf '%s\n' "${files[@]}" | sort -V | tail -n 1
}

extract_tarball() {
  local p="$1" tb="$2"
  rm -rf "$DOCS_SKILLS/$p"
  mkdir -p "$DOCS_SKILLS/$p"
  if ! tar -xzf "$tb" -C "$DOCS_SKILLS/$p" --strip-components=1; then
    rm -rf "$DOCS_SKILLS/$p"
    die "tar extraction failed for $p (removed partial $DOCS_SKILLS/$p/)"
  fi
}

require_cmd jq

mkdir -p "$DOCS_SKILLS"

MARKETPLACE_JSON="$(read_marketplace_json)"
COUNT=0

while IFS= read -r p; do
  [ -n "$p" ] || continue

  tb=""
  ver_display=""

  if [ -n "${SKILLS_LOCAL_DIR:-}" ]; then
    local_root="$(cd "$SKILLS_LOCAL_DIR" && pwd)"
    dist_dir="$local_root/dist"
    mkdir -p "$dist_dir"

    tb="$(pick_local_tarball "$p" "$dist_dir" || true)"
    if [ -z "${tb:-}" ]; then
      # Skip plugins that don't have a site/ dir yet (e.g. new plugins mid-build-out).
      if [ ! -d "$local_root/plugins/$p/site" ]; then
        echo "  ⚠ $p: no plugins/$p/site/ yet, skipping"
        continue
      fi
      build_script="$local_root/bin/build-plugin-site"
      if [ ! -f "$build_script" ]; then
        die "No tarball at $dist_dir/${p}-site-*.tar.gz and missing build script: $build_script"
      fi
      echo "  … $p: building local site (bin/build-plugin-site)…"
      bash "$build_script" "$p"
      tb="$(pick_local_tarball "$p" "$dist_dir" || true)"
      [ -n "${tb:-}" ] || die "After build, still no $dist_dir/${p}-site-*.tar.gz"
    fi
    vbase="$(basename "$tb" .tar.gz)"
    _pfx="${p}-site-"
    ver_display="${vbase#"$_pfx"}"
    extract_tarball "$p" "$tb"
  else
    require_gh
    tag="$(resolve_release_tag "$p")"
    if [ -z "$tag" ]; then
      echo "  ⚠ $p: no release assets yet, skipping"
      continue
    fi
    shopt -s nullglob
    rm -f "$TMP/${p}-site-"*.tar.gz
    shopt -u nullglob
    if ! gh release download "$tag" --repo "$SKILLS_REPO" --pattern "${p}-site-*.tar.gz" --dir "$TMP" --clobber; then
      echo "  ⚠ $p: no ${p}-site-*.tar.gz on release $tag, skipping"
      continue
    fi
    shopt -s nullglob
    matches=( "$TMP/${p}-site-"*.tar.gz )
    shopt -u nullglob
    if [ "${#matches[@]}" -eq 0 ]; then
      echo "  ⚠ $p: download produced no matching tarball, skipping"
      continue
    fi
    tb="$(printf '%s\n' "${matches[@]}" | sort -V | tail -n 1)"
    ver_display="$(version_label_from_tag "$p" "$tag")"
    extract_tarball "$p" "$tb"
    rm -f "${matches[@]}"
  fi

  COUNT=$((COUNT + 1))
  echo "  ✓ $p → docs/skills/$p/ ($ver_display)"
done < <(jq -r '.plugins[].name' <<<"$MARKETPLACE_JSON")

echo "→ Done. $COUNT plugin subsites slotted in."
