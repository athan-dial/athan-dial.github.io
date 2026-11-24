#!/usr/bin/env python3
"""Copy lint for Atlas records: the reader-facing rules from the 2026-11-06 copy audits.
Usage: python3 atlas/lint_copy.py <dir-or-file> [...]   Exit 1 on any finding. Standard library only."""
import re, sys, tomllib
from pathlib import Path

BANNED = ["leverage", "seamless", "robust", "powerful", "cutting-edge", "game-changer", "supercharge", "unleash",
          "world-class", "enterprise-grade", "next-generation", "mission-critical", "concrete take", "interesting design bet",
          "worth reading for", "the clearest", "the simplest", "the best ", "revolutionary", "state-of-the-art"]
INTERNAL = re.compile(r"\b(seed|the atlas|atlas entry|goodlinks|reading-list)\b", re.I)
SUPER = re.compile(r"\b(clearest|simplest|best|fastest)\b", re.I)
VENDOR_NUM = re.compile(r"(\d[\d,.]*\s*(k|m|%|x)\b|\bstars?\b|\bdownloads?\b|\busers\b)", re.I)

def sentences(t): return [s for s in re.split(r"(?<=[.!?])\s+", t.strip()) if s]

def check(path, d):
    e = []
    def f(msg): e.append(msg)
    t, mech = d.get("title", ""), d.get("mechanism", "")
    op = d.get("opinion", {})
    read, fit, lims = op.get("value_judgment", ""), op.get("fit", ""), op.get("limitations", [])
    facts = [x.get("claim", "") for x in d.get("facts", [])]
    if ":" not in t or len(t) > 70: f("title must be 'Name: what it is' and under 70 characters")
    if len(mech.split()) > 38: f(f"mechanism too long ({len(mech.split())} words)")
    if not re.search(r"\b(revise|drop|change my mind|doubt|reconsider|rethink|only if|weaker if|until|unless)\b", read, re.I): f("My read has no revise-if condition")
    if not 2 <= len(sentences(read)) <= 4: f(f"My read should be 2 to 4 sentences, is {len(sentences(read))}")
    if not re.match(r"(Use it when|Look at it)\b", fit) or "Skip it" not in fit: f("fit must be 'Use it when ... Skip it if ...'")
    if not lims: f("limitations missing")
    for l in lims:
        if l.lower().startswith("not run"): f("limitation starts with 'Not run.'")
        if not re.search(r"\bI\b", l): f(f"limitation not first person: {l[:50]}")
    if not 2 <= len(facts) <= 4: f(f"facts should be 2 to 4, is {len(facts)}")
    for c in facts:
        if re.match(r"The README (says|describes|lists|states|calls)", c): f(f"fact keeps 'The README says' prefix: {c[:40]}")
        if VENDOR_NUM.search(c) and not c.lower().startswith("the project says"): f(f"possible unflagged vendor number in fact: {c[:60]}")
    text = " ".join([t, mech, read, fit, *lims, *facts])
    if "—" in text or "--" in text or "–" in text: f("em/en dash or double hyphen")
    for w in BANNED:
        if w in text.lower(): f(f"banned phrase '{w.strip()}'")
    if INTERNAL.search(text): f("internal vocabulary leaks (seed/atlas/goodlinks)")
    if re.search(r"licen[cs]e", " ".join([mech, read, fit, *lims, *facts]), re.I): f("licence mentioned in reader text")
    if SUPER.search(read): f("superlative in My read")
    img = d.get("image")
    if img and img.get("alt", "").upper().startswith("PENDING"): f("image alt text still pending")
    return e

def main(a):
    files = []
    for x in a:
        p = Path(x); files += sorted(p.glob("*.toml")) if p.is_dir() else [p]
    bad = 0
    for f in files:
        d = tomllib.loads(f.read_text(encoding="utf-8")); errs = check(f, d)
        for m in errs: print(f"LINT {f.name}: {m}")
        bad += bool(errs)
    print(f"{len(files) - bad} clean, {bad} with findings, {len(files)} total")
    return 1 if bad else 0

if __name__ == "__main__": sys.exit(main(sys.argv[1:]))
