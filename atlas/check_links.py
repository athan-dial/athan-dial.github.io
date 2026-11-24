#!/usr/bin/env python3
"""Link-check every URL in atlas/records/*.toml. Stdlib only. Exit 1 if any URL fails.
Usage: python3 atlas/check_links.py [records-dir]   (network required; logs one line per URL)"""
import sys, tomllib, urllib.request, urllib.error
from pathlib import Path
from datetime import datetime, timezone

def fetch(url):
    req = urllib.request.Request(url.split('#')[0], headers={"User-Agent": "atlas-link-check/1"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code
    except Exception as e:
        return f"error:{type(e).__name__}"

bad = 0
d = Path(sys.argv[1] if len(sys.argv) > 1 else "atlas/records")
print("checked_at", datetime.now(timezone.utc).isoformat(timespec="seconds"))
for f in sorted(d.glob("*.toml")):
    rec = tomllib.loads(f.read_text())
    urls = {rec["canonical_url"], *[s["url"] for s in rec["sources"]]}
    for u in sorted(urls):
        st = fetch(u)
        ok = st == 200
        bad += not ok
        print(f"{'ok  ' if ok else 'FAIL'} {st} {u}  [{rec['id']}]")
print(f"{bad} failing URL(s)")
sys.exit(1 if bad else 0)
