#!/usr/bin/env bash
# Mechanical half of the EDITORIAL.md voice rules, on the prose this editorial pass owns.
# It cannot judge voice. It catches the patterns that are cheap to catch: brand jargon, em dashes
# used as punctuation, and the "not X but Y" frame. Published essays, field notes and Work cases are
# deliberately out of scope: their text changes only with separate owner approval.
#
#   bash scripts/verify-editorial.sh
set -euo pipefail
cd "$(dirname "$0")/.."

fail() { printf 'verify-editorial: FAIL - %s\n' "$*" >&2; exit 1; }
ok() { printf 'verify-editorial:   ok - %s\n' "$*"; }

[ -f EDITORIAL.md ] || fail "EDITORIAL.md is missing"
grep -q 'AI enablement for expert work' EDITORIAL.md || fail "EDITORIAL.md no longer states the approved territory"
ok "EDITORIAL.md present and states the approved territory"

python3 - <<'PY'
import json, pathlib, re, sys

jargon = ["leverage", "unlock", "empower", "seamless", "robust", "holistic", "transformative",
          "best-in-class", "thought leader", "journey", "ecosystem", "synergy", "game-changing",
          "cutting-edge", "world-class", "stakeholders"]
files = ["content/_index.md", "content/about.md", "content/work/_index.md", "content/thinking/_index.md",
         "content/essays/_index.md", "content/notes/_index.md", "content/atlas/_index.md",
         "content/work/agentic-operating-system.md", "data/profile.toml", "data/agentic-os/views.json"]
files += sorted(str(p) for p in pathlib.Path("data/agentic-os/plates").glob("*.json"))
files += sorted(str(p) for p in pathlib.Path("data/agentic-os/workflow-plates").glob("*.json"))
files += ["data/workflows/registry.json"] + sorted(str(p) for p in pathlib.Path("data/workflows/guides").glob("*.json"))
text_lines = []                       # (file, line number, text)
for f in files:
    p = pathlib.Path(f)
    if not p.exists():
        continue
    for n, line in enumerate(p.read_text(encoding="utf-8").splitlines(), 1):
        if line.lstrip().startswith("#"):
            continue                  # comments are for editors, not readers
        text_lines.append((f, n, line))
# Template prose: only lines that carry reader-facing text.
for f in ["layouts/index.html", "layouts/_default/about.html", "layouts/work/list.html",
          "layouts/thinking/list.html", "layouts/atlas/list.html", "layouts/work/atlas.html",
          "layouts/partials/workflow-start.html", "layouts/partials/workflow-guide.html", "layouts/partials/workflow-map.html",
          "layouts/partials/workflow-compare.html", "layouts/partials/workflow-build.html", "layouts/partials/workflow-sources.html",
          "layouts/partials/workflow-skill-status.html", "layouts/partials/workflow-artifact.html"]:
    for n, line in enumerate(pathlib.Path(f).read_text(encoding="utf-8").splitlines(), 1):
        if re.search(r"<(p|h[1-6]|li|summary|strong)\b", line) and not line.lstrip().startswith(("{{-", "{{/*")):
            text_lines.append((f, n, line))

bad = []
for f, n, line in text_lines:
    low = line.lower()
    for w in jargon:
        if re.search(r"\b" + re.escape(w) + r"\b", low):
            bad.append(f"{f}:{n}: jargon '{w}'")
    if "—" in line:
        bad.append(f"{f}:{n}: em dash")
    if re.search(r"\b(?:it'?s|it is|this is|that'?s|isn'?t|is not|are not|aren'?t) (?:just |only )?(?:about|a|an|the|for)\b[^.;]{0,60}\b(?:but|it'?s|rather)\b", low) \
       and re.search(r"\bnot\b|n't", low) and re.search(r"\bbut\b|\brather\b", low) and "rule" not in low:
        bad.append(f"{f}:{n}: 'not X but Y' frame")
if bad:
    print("\n".join(bad[:40]))
    sys.exit(1)
print("ok")
PY
ok "no brand jargon, em dashes or 'not X but Y' frames in the editorial prose"
printf 'verify-editorial: PASS\n'
