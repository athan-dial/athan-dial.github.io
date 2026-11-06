#!/usr/bin/env python3
"""Deterministic local validator for Systems Atlas records (atlas-record/1).

Usage: python3 atlas/validate.py <dir-or-file> [...]
Exit 0 = all valid. Exit 1 = at least one explicit failure. Standard library only.
"""
import re
import sys
import tomllib
from pathlib import Path

SCHEMA = "atlas-record/1"
TOPICS = {
    "agent-memory", "agent-orchestration", "agent-sandboxing", "agent-tooling",
    "data-lineage", "data-transformation", "data-pipeline-visualization",
    "web-scraping", "code-intelligence", "scientific-agent-skills", "protocol-registry",
}
EVIDENCE = {"inspected", "evaluated", "tested", "adopted"}
STATUS = {"candidate", "reviewed"}
SOURCE_KINDS = {"upstream_repo", "readme", "license_file", "api_metadata"}
REQUIRED = ["schema_version", "id", "canonical_url", "title", "repository_owner", "repository_name",
            "date_observed", "topic", "mechanism", "license_spdx", "evidence_state", "status",
            "last_review_date", "editorial_review", "unavailable", "opinion", "provenance",
            "sources", "facts"]
IMAGE_KINDS = {"screenshot", "diagram", "banner", "logo"}
IMAGE_EXT = {".webp", ".svg"}
ASSET_DIR = Path(__file__).resolve().parent.parent / "assets" / "atlas"
DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
RANGE = re.compile(r"^\d{4}-\d{2}-\d{2}/\d{4}-\d{2}-\d{2}$")
ID = re.compile(r"^github:([a-z0-9][a-z0-9._-]*)/([a-z0-9._-]+)$")
URL = re.compile(r"^https://[^\s]+$")
DENY = [
    (re.compile(r"mon[t]ai", re.I), "employer name"),
    (re.compile(r"atlassian\.net|slack\.com|notion\.so|zoom\.us", re.I), "internal/collab host"),
    (re.compile(r"[\w.+-]+@[\w-]+\.[\w.-]+"), "email address"),
    (re.compile(r"(?i)\b(password|secret|api[_-]?key|token)\s*[:=]\s*\S{6,}"), "credential-like text"),
    (re.compile(r"/Users/|\.obsidian|iCloud", re.I), "local/private path"),
]


def walk_strings(o):
    if isinstance(o, str):
        yield o
    elif isinstance(o, dict):
        for v in o.values():
            yield from walk_strings(v)
    elif isinstance(o, list):
        for v in o:
            yield from walk_strings(v)


def check(path, d):
    e = []
    for k in REQUIRED:
        if k not in d:
            e.append(f"missing required field '{k}'")
    if e:
        return e
    if d["schema_version"] != SCHEMA:
        e.append(f"schema_version must be '{SCHEMA}', got '{d['schema_version']}'")
    m = ID.match(d["id"]) if isinstance(d["id"], str) else None
    if not m:
        e.append(f"id '{d['id']}' must match github:<owner>/<repo> in lowercase")
    else:
        owner, repo = m.groups()
        if path.name != f"{owner}--{repo}.toml":
            e.append(f"file name '{path.name}' must be '{owner}--{repo}.toml' to match id")
        cu = d["canonical_url"]
        if cu.lower() != f"https://github.com/{owner}/{repo}":
            e.append(f"canonical_url '{cu}' does not resolve to id owner/repo (case-insensitive)")
        if d["repository_owner"].lower() != owner or d["repository_name"].lower() != repo:
            e.append("repository_owner/repository_name do not match id")
    if d["topic"] not in TOPICS:
        e.append(f"topic '{d['topic']}' not in allowed list")
    if d["evidence_state"] not in EVIDENCE:
        e.append(f"evidence_state '{d['evidence_state']}' not one of {sorted(EVIDENCE)}")
    elif d["evidence_state"] != "inspected" and not d.get("evidence_note"):
        e.append(f"evidence_state '{d['evidence_state']}' requires evidence_note")
    if d["status"] not in STATUS:
        e.append(f"status '{d['status']}' not one of {sorted(STATUS)}")
    elif d["status"] == "reviewed":
        for k in ("reviewed_by", "reviewed_on"):
            if not d.get(k):
                e.append(f"status 'reviewed' requires '{k}'")
    elif d["editorial_review"] != "pending":
        e.append("candidate records must have editorial_review = 'pending'")
    do = d["date_observed"]
    if not (do == "date_not_recovered" or DATE.match(do) or RANGE.match(do)):
        e.append(f"date_observed '{do}' must be YYYY-MM-DD, a range, or 'date_not_recovered'")
    if not DATE.match(str(d["last_review_date"])):
        e.append("last_review_date must be YYYY-MM-DD")
    if d["license_spdx"] in ("NOASSERTION", "none") and not d.get("license_note"):
        e.append("license_spdx NOASSERTION/none requires license_note")
    op = d["opinion"]
    if not op.get("value_judgment"):
        e.append("opinion.value_judgment is required")
    if not op.get("limitations"):
        e.append("opinion.limitations needs at least one entry")
    pv = d["provenance"]
    for k in ("seed_pointer", "discovery_dates", "source_types"):
        if not pv.get(k):
            e.append(f"provenance.{k} is required")
    if pv.get("visibility") != "public":
        e.append("provenance.visibility must be 'public'")
    if pv.get("private_text_included") is not False:
        e.append("provenance.private_text_included must be false")
    urls = set()
    if not d["sources"]:
        e.append("at least one [[sources]] citation is required")
    for s in d["sources"]:
        if not URL.match(s.get("url", "")):
            e.append(f"source url '{s.get('url')}' must be https")
        if s.get("kind") not in SOURCE_KINDS:
            e.append(f"source kind '{s.get('kind')}' not allowed")
        if not DATE.match(str(s.get("accessed", ""))):
            e.append("source accessed must be YYYY-MM-DD")
        urls.add(s.get("url"))
    if not d["facts"]:
        e.append("at least one [[facts]] entry is required")
    for f in d["facts"]:
        if not f.get("claim"):
            e.append("fact with empty claim")
        if f.get("source_url") not in urls:
            e.append(f"fact source_url '{f.get('source_url')}' is not listed in [[sources]]")
    img = d.get("image")
    if img is not None:
        for k in ("file", "kind", "alt", "credit", "source_url"):
            if not img.get(k):
                e.append(f"image.{k} is required when [image] is present")
        if img.get("kind") and img["kind"] not in IMAGE_KINDS:
            e.append(f"image.kind '{img['kind']}' not allowed")
        if img.get("source_url") and not URL.match(img["source_url"]):
            e.append("image.source_url must be https")
        f = img.get("file", "")
        if f and (Path(f).suffix not in IMAGE_EXT or "/" in f or not (ASSET_DIR / f).is_file()):
            e.append(f"image.file '{f}' must be a .webp or .svg in assets/atlas/")
        if img.get("alt") and len(img["alt"]) < 20:
            e.append("image.alt is too short to describe the image")
    for text in walk_strings(d):
        for rx, why in DENY:
            if rx.search(text):
                e.append(f"safety deny-list hit ({why}): '{text[:60]}'")
    return e


def main(argv):
    files = []
    for a in argv:
        p = Path(a)
        files += sorted(p.glob("*.toml")) if p.is_dir() else [p]
    if not files:
        print("FAIL: no records found")
        return 1
    bad = 0
    seen = {}
    for f in files:
        try:
            d = tomllib.loads(f.read_text(encoding="utf-8"))
        except Exception as ex:  # parse error is a failure with a reason
            print(f"FAIL {f}: TOML parse error: {ex}")
            bad += 1
            continue
        errs = check(f, d)
        rid = str(d.get("id", "")).lower()
        if rid in seen:
            errs.append(f"duplicate canonical identity '{rid}' also in {seen[rid]}")
        elif rid:
            seen[rid] = f.name
        for x in errs:
            print(f"FAIL {f}: {x}")
        if errs:
            bad += 1
        else:
            print(f"ok   {f}")
    print(f"{len(files) - bad} valid, {bad} invalid, {len(files)} total")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
