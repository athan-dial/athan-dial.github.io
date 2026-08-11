# Accessibility & launch-gate checks

Executable checklist for the Editorial Systems redesign “Verify the experience” pass.
Derived from [.planning/design/REDESIGN-PLAN.md](design/REDESIGN-PLAN.md) (Accessibility,
Performance, Search and sharing) and tokens in
[.planning/design/EDITORIAL-SYSTEMS.md](design/EDITORIAL-SYSTEMS.md).

Do not treat unchecked items as done. Record date, runner, and evidence (screenshot,
CLI output, or Lighthouse JSON path) next to each pass.

---

## Open items (non-blocking for this checklist’s existence)

| Item | Status | Notes |
|---|---|---|
| `docs/agency/**` live but unlisted | Open | Static tree (~127 tracked files) outside Hugo’s page graph. A clean Hugo build does not regenerate it and it does **not** appear in `sitemap.xml`. Decide: keep unlisted, add a curated sitemap entry set, or retire. |
| Duplicate OG tags until baseof cleanup | Open | `layouts/partials/og-image.html` is authoritative. Until another wave deletes `layouts/_default/baseof.html` lines **8–12** (`og:title`, `og:description`, `og:type`, `og:url`, `og:image`), built pages emit two `og:title` (and related) tags. `rel=canonical` must remain sole in baseof (line 14) — do not duplicate in the partial. |
| Evidence-amber text contrast | Fail (recorded) | See contrast table. Amber is used as a non-text marker today; do not silently change `tokens.css` without a design decision. |

---

## WCAG 2.2 AA checklist

Target: [WCAG 2.2 Level AA](https://www.w3.org/TR/WCAG22/). Mark each item pass/fail with notes.

### Semantics & structure

- [ ] **Heading order** — One `h1` per page; levels increase by at most one; no skipped levels. Check: browser accessibility tree or `axe` heading order rule.
- [ ] **Landmarks** — `header`/`nav`, one `main`, `footer`; skip link targets `#main-content`. Check: landmarks panel / axe `region` / `bypass`.
- [ ] **Page language** — Root `html[lang]` set (`en`).

### Keyboard & focus

- [ ] **Full keyboard nav** — Tab reaches every interactive control (nav, theme-free links, buttons, skip link, in-page anchors); Enter/Space activate; Esc closes any disclosure.
- [ ] **Visible focus** — Every control shows a clear focus indicator (prefer 2px `structural-teal` outline; no reliance on glow). Meets [Focus Appearance](https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html).
- [ ] **Focus order** — Matches visual reading order; no focus trap.

### Contrast & color

- [ ] **Text contrast ≥ 4.5:1** — Normal text (body, metadata under 18pt / 14pt bold). Use table below.
- [ ] **Large text / non-text ≥ 3:1** — Headings ≥24px (or ≥18.66px bold); UI boundaries, focus rings, icons.
- [ ] **Focus-state contrast** — Focus indicator vs adjacent colors ≥ 3:1.
- [ ] **Nothing by color alone** — Evidence/status is not only amber vs teal; pair with text, rules, or labels.

### Targets, links, media

- [ ] **Pointer targets ≥ 44×44 CSS px** — Preferred; exceptions documented if unavoidable.
- [ ] **Descriptive links** — No “click here”; link text makes sense out of context.
- [ ] **Alt text** — Informative images have descriptive `alt`; decorative images `alt=""`. OG `og:image:alt` set.

### Motion

- [ ] **`prefers-reduced-motion`** — Transitions/animations disabled or reduced under the media query; no essential info only in motion.

---

## Contrast table (Editorial Systems)

Measured 2026-08-11 with relative luminance per WCAG 2.x (`(L1+0.05)/(L2+0.05)`).
Thresholds: **4.5:1** normal text; **3:1** large text and non-text UI.

| Pair | Foreground | Background | Ratio | 4.5:1 text | 3:1 large/non-text | Notes / suggested fix |
|---|---|---|---|---|---|---|
| Ink on paper | `#14202B` | `#F6F2EA` | **14.79:1** | Pass | Pass | Body and UI default |
| Ink on surface | `#14202B` | `#FFFDF8` | **16.25:1** | Pass | Pass | Inset / elevated panels |
| Ink-secondary on paper | `#53606A` | `#F6F2EA` | **5.79:1** | Pass | Pass | Secondary copy |
| Ink-secondary on surface | `#53606A` | `#FFFDF8` | **6.36:1** | Pass | Pass | Secondary on surface |
| Structural-teal on paper | `#17616A` | `#F6F2EA` | **6.37:1** | Pass | Pass | Links / functional UI |
| Evidence-amber on paper | `#B86B35` | `#F6F2EA` | **3.62:1** | **Fail** | Pass | Do not use amber for small body text. Suggested text-safe amber on paper: `#A25E2F` (~4.50:1). |
| Evidence-amber on light amber tint | `#B86B35` | `#FFF5EB` | **3.76:1** | **Fail** | Pass | Tint from `.evidence-label` in `main.css`. Label copy uses `--ink` on this tint (**15.35:1**, Pass). Amber is a non-text marker. Suggested amber if it must be text on this tint: `#A56030` (~4.52:1). |
| Paper on ink (primary button) | `#F6F2EA` | `#14202B` | **14.79:1** | Pass | Pass | Primary button label |

**Recompute locally:**

```bash
python3 - <<'PY'
def rel_lum(h):
    h=h.lstrip('#'); r,g,b=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    f=lambda c: c/12.92 if c<=0.04045 else ((c+0.055)/1.055)**2.4
    R,G,B=f(r),f(g),f(b); return 0.2126*R+0.7152*G+0.0722*B
def contrast(a,b):
    L1,L2=rel_lum(a),rel_lum(b); hi,lo=max(L1,L2),min(L1,L2)
    return (hi+0.05)/(lo+0.05)
pairs=[
 ("ink/paper","#14202B","#F6F2EA"),
 ("ink/surface","#14202B","#FFFDF8"),
 ("ink-secondary/paper","#53606A","#F6F2EA"),
 ("ink-secondary/surface","#53606A","#FFFDF8"),
 ("structural-teal/paper","#17616A","#F6F2EA"),
 ("evidence-amber/paper","#B86B35","#F6F2EA"),
 ("evidence-amber/#FFF5EB","#B86B35","#FFF5EB"),
 ("paper/ink","#F6F2EA","#14202B"),
]
for n,fg,bg in pairs:
    print(f"{n}: {contrast(fg,bg):.2f}:1")
PY
```

Do **not** silently edit `assets/css/tokens.css` from this checklist — flag failures to design and land a deliberate token change.

---

## Core Web Vitals (launch gates @ p75)

| Metric | Gate | Measurement method |
|---|---|---|
| **LCP** | ≤ 2.5 s | Lab: Lighthouse (mobile + desktop) on home, about, and one long-form page. Field: CrUX / Search Console CWV for the origin, p75. |
| **INP** | ≤ 200 ms | Field: CrUX / Search Console (INP replaces FID). Lab proxy: total blocking time + interaction traces in Performance panel — lab alone is not sufficient for INP sign-off. |
| **CLS** | ≤ 0.1 | Lab: Lighthouse CLS; confirm media has width/height (or aspect-ratio) reserved. Field: CrUX p75. |

Reference: [web.dev Core Web Vitals thresholds](https://web.dev/articles/defining-core-web-vitals-thresholds).

**Local lab commands:**

```bash
# Build to a throwaway dir — NEVER hugo bare (writes docs/)
hugo --gc --destination /private/tmp/hugo-guard

# Serve the guard build
python3 -m http.server 8765 --directory /private/tmp/hugo-guard

# Lighthouse (Chrome) — requires network to localhost
npx --yes lighthouse http://127.0.0.1:8765/ \
  --only-categories=performance,accessibility \
  --form-factor=mobile --output=json --output-path=/tmp/lh-home.json
npx --yes lighthouse http://127.0.0.1:8765/about/ \
  --only-categories=performance,accessibility \
  --form-factor=mobile --output=json --output-path=/tmp/lh-about.json
```

Record LCP/CLS from the JSON (`audits["largest-contentful-paint"]`, `audits["cumulative-layout-shift"]`). Treat INP as a field gate.

---

## Responsive capture list

Capture full-page screenshots (light only — no dark mode) at:

| Width | Intent |
|---|---|
| 360px | Small Android |
| 390px | Common phone (e.g. iPhone 14) |
| 768px | Tablet breakpoint |
| 1280px | Desktop |
| 1440px | Wide desktop |

Pages: `/`, `/about/`, one essay or note when published, one work piece when published.

```bash
# Example with Playwright once the guard server is up on 8765
npx --yes playwright screenshot --viewport-size=360,800  http://127.0.0.1:8765/ /tmp/cap-360.png
npx --yes playwright screenshot --viewport-size=390,844  http://127.0.0.1:8765/ /tmp/cap-390.png
npx --yes playwright screenshot --viewport-size=768,1024 http://127.0.0.1:8765/ /tmp/cap-768.png
npx --yes playwright screenshot --viewport-size=1280,800 http://127.0.0.1:8765/ /tmp/cap-1280.png
npx --yes playwright screenshot --viewport-size=1440,900 http://127.0.0.1:8765/ /tmp/cap-1440.png
```

---

## Metadata / SEO verification commands

Run after every metadata change. Build destination must be throwaway; `docs/agency` and `docs/skills` must still exist in the repo tree.

```bash
hugo --gc --destination /private/tmp/hugo-guard \
  && test -f docs/agency/index.html \
  && test -d docs/skills

# Sitemap: no quarantined paths
! grep -E '/case-studies/|/resume/' /private/tmp/hugo-guard/sitemap.xml
echo "sitemap OK if exit 0"
cat /private/tmp/hugo-guard/sitemap.xml

# Canonical: exactly one per page (baseof owns this)
grep -c 'rel="canonical"' /private/tmp/hugo-guard/about/index.html   # expect 1
grep -c 'rel=canonical' /private/tmp/hugo-guard/about/index.html || true

# OG title: expect 1 after baseof cleanup; currently 2 until lines 8–12 removed
grep -c 'property="og:title"' /private/tmp/hugo-guard/about/index.html

# robots
cat /private/tmp/hugo-guard/robots.txt

# JSON-LD well-formed
python3 - <<'PY'
from pathlib import Path
import re, json
html = Path("/private/tmp/hugo-guard/about/index.html").read_text()
blocks = re.findall(r'<script type="application/ld\+json">\s*(.*?)\s*</script>', html, re.S)
assert blocks, "no JSON-LD on /about/"
for i,b in enumerate(blocks):
    json.loads(b)
    print(f"block {i}: OK")
    print(json.dumps(json.loads(b), indent=2)[:500])
PY
```

### Accessibility tooling

```bash
# axe via Lighthouse accessibility category (from guard server above)
npx --yes lighthouse http://127.0.0.1:8765/about/ \
  --only-categories=accessibility --quiet --chrome-flags="--headless"

# Manual keyboard pass
# 1. Open / in Chrome
# 2. Tab: skip link → nav → main links → footer
# 3. Confirm focus ring visible on every stop
# 4. Enable prefers-reduced-motion and re-check nav/disclosure motion
```

---

## Sign-off

| Gate | Owner | Date | Result |
|---|---|---|---|
| WCAG 2.2 AA checklist | | | |
| Contrast table (no untracked fails) | | | |
| CWV p75 (LCP/INP/CLS) | | | |
| Responsive captures (5 widths) | | | |
| Sitemap / robots / JSON-LD / single canonical | | | |
