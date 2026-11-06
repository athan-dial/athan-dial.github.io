#!/usr/bin/env python3
"""Atlas image helper. Needs Pillow (run with: uv run --no-project --with pillow python atlas/images.py ...).
  candidates <record.toml> <outdir>   download up to 4 README images (skips badges, sponsor ads) as numbered files + print them
  apply <record.toml> <image-file> "<alt text>" [kind] [source-url]   flatten, resize to <=1200w WebP, save assets/atlas/<slug>.webp|.svg, add [image]
AGPL records are refused. Images are the project's own README art; credit and source link are written to the record."""
import io, re, subprocess, sys, tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BAD = re.compile(r"shields\.io|badge|sponsor|star-history|img\.shields|trendshift|badgen|codecov|travis|github\.com/.*/actions|discord|twitter|buymeacoffee|ko-fi|/sponsors?/|avatars\.githubusercontent|contrib\.rocks|visitor|hits\.", re.I)

def sh(*a): return subprocess.run(a, capture_output=True)

def readme(owner, repo):
    r = sh("gh", "api", f"repos/{owner}/{repo}/readme", "-H", "Accept: application/vnd.github.raw")
    return r.stdout.decode("utf-8", "replace") if r.returncode == 0 else ""

def branch(owner, repo):
    r = sh("gh", "api", f"repos/{owner}/{repo}", "--jq", ".default_branch")
    return r.stdout.decode().strip() or "main"

def candidates(rec, out):
    d = tomllib.loads(Path(rec).read_text()); o, r = d["repository_owner"], d["repository_name"]
    if d["license_spdx"].startswith("AGPL"): print("REFUSED: AGPL repo, plate only"); return
    out = Path(out); out.mkdir(parents=True, exist_ok=True)
    text = readme(o, r); br = branch(o, r)
    urls = re.findall(r"!\[[^\]]*\]\(([^)\s]+)", text) + re.findall(r'<img[^>]+src="([^"]+)"', text) + re.findall(r'<source[^>]+srcset="([^"\s]+)', text)
    seen, n = set(), 0
    for u in urls:
        u = u.split("#")[0]
        if BAD.search(u) or u in seen or u.lower().endswith((".ico",)): continue
        seen.add(u)
        if u.startswith("http"): full = u.replace("github.com/", "raw.githubusercontent.com/").replace("/blob/", "/") if "github.com/" in u and "/blob/" in u else u
        else: full = f"https://raw.githubusercontent.com/{o}/{r}/{br}/{u.lstrip('./')}"
        ext = full.split("?")[0].rsplit(".", 1)[-1].lower()
        if ext not in ("png", "jpg", "jpeg", "gif", "webp", "svg"): continue
        data = sh("curl", "-sSL", "--max-time", "20", full).stdout
        if len(data) < 2000 or data[:5] in (b"<!DOC", b"<html", b"404: "): continue
        n += 1; f = out / f"{n}.{ext}"; f.write_bytes(data); print(f"{f}  {len(data)//1024}KB  {u}")
        if n >= 4: break
    if not n: print("none found: plate")

def flatten(im):
    im = im.convert("RGBA"); bg = Image.new("RGBA", im.size, "white"); bg.alpha_composite(im); return bg.convert("RGB")

def apply(rec, img, alt, kind="screenshot", src=None):
    global Image
    from PIL import Image, ImageSequence, ImageStat
    rec = Path(rec); d = tomllib.loads(rec.read_text()); slug = rec.stem
    if d["license_spdx"].startswith("AGPL"): sys.exit("REFUSED: AGPL repo")
    if "image" in d: sys.exit("record already has [image]")
    img = Path(img); o, r = d["repository_owner"], d["repository_name"]
    dest_dir = ROOT / "assets" / "atlas"
    if img.suffix.lower() == ".svg":
        t = img.read_text(errors="replace")
        if re.search(r"<script|onload=|javascript:|<foreignObject", t, re.I): sys.exit("SVG has active content: refused")
        fn = f"{slug}.svg"; (dest_dir / fn).write_bytes(img.read_bytes())
    else:
        im = Image.open(img)
        if getattr(im, "n_frames", 1) > 1:
            fr = [f.copy() for f in ImageSequence.Iterator(im)]
            im = max(fr[:: max(1, len(fr) // 40)], key=lambda f: sum(ImageStat.Stat(f.convert("L")).stddev))
        im = flatten(im)
        if im.width > 1200: im = im.resize((1200, round(im.height * 1200 / im.width)), Image.LANCZOS)
        fn = f"{slug}.webp"; im.save(dest_dir / fn, "WEBP", quality=82, method=6)
    src = src or f"https://github.com/{o}/{r}"
    credit = d["title"].split(":")[0]
    rec.write_text(rec.read_text().rstrip("\n") + f'\n\n[image]\nfile = "{fn}"\nkind = "{kind}"\nalt = "{alt}"\ncredit = "{credit}"\nsource_url = "{src}"\n')
    print("applied", fn)

if __name__ == "__main__":
    c = sys.argv[1]
    if c == "candidates": candidates(sys.argv[2], sys.argv[3])
    elif c == "apply": apply(*sys.argv[2:])
