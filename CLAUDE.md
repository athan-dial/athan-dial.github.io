# CLAUDE.md

Guidance for Claude Code working in this repository.

> **This file was stale until 2026-08-12 and caused real damage.** It described a design
> system ("Clinical Architect") that had already been retired, so an agent briefed from it
> was told to preserve a teal/Manrope/glassmorphic/dark-mode system that no longer exists.
> If you change the design system, typography, or colour model, **update this file in the
> same commit.** A confidently wrong CLAUDE.md is worse than none.

## Project Overview

Personal portfolio site. **Hugo v0.154.3+extended, themeless** — every layout is custom in
`layouts/`, no theme dependency, no Hugo modules. Deployed to GitHub Pages from `docs/`.

Positioning: "decision evidence, not achievements." Pages carry evidence about product
judgment and applied-AI work rather than achievement lists.

The design system is **Hybrid + book architecture** (2026-08-13): near-white ground, black ink,
Archivo grotesque, one forest-green accent, flat surfaces, and book structure on long-form pages
(running head, margin index, folios, colophon). It replaced *Editorial Systems* (warm paper, serif
display), which an external review found sat in a saturated AI-portfolio lane. See `DESIGN.md` (the design authority) and `PRODUCT.md`.

## Build & Development

```bash
hugo server -D          # local, live reload, http://localhost:1313
hugo                    # production build into docs/
```

### Do NOT use `--cleanDestinationDir` (or `rm -rf docs/`)

`docs/` is a **mixed directory**: Hugo output *plus* a separately synced agency microsite
(127 committed files with its own favicons, CSS bundles, and 404). A clean build deletes the
synced half, and Hugo will not regenerate it. To remove a stale orphan, delete that path
specifically after a plain `hugo` build.

Hugo also never cleans orphans on its own, so a page that stops rendering leaves its old
`index.html` in `docs/` and GitHub Pages keeps serving it. This already caused a live
incident: a retired `docs/resume/index.html` kept serving old copy plus a link to a PDF
carrying a personal phone number, months after the page stopped being generated. **After
removing or unpublishing a page, check `docs/` for its orphan.**

## Design System: Hybrid + book architecture

**Authority:** `DESIGN.md`. Tokens: `assets/css/tokens.css`. Implementation:
`assets/css/main.css`. Measured contrast: `.planning/ACCESSIBILITY-CHECKS.md`.
Zero `!important`, zero border-radius, zero box-shadow — all deliberate.

### Typography

Fonts are **self-hosted woff2** in `static/fonts/`, not a CDN.

| Token | Stack | Role |
|---|---|---|
| `--font-serif` | Archivo | Display and headings (name is legacy; the face is a grotesque) |
| `--font-sans` | Archivo | Body, UI text, summaries |
| `--font-mono` | IBM Plex Mono | Running heads, folios, index, colophon, diagram labels |

### Colour

Light only. **There is no dark mode** — no toggle in `baseof.html`, no `html.dark` block in
`main.css`. It is deferred on purpose ("ship one polished light experience"). The
`#theme-toggle` rules in `main.css` are orphans from the retired system. Untested dark
starting values are recorded in a `tokens.css` comment and are marked do-not-ship-unmeasured.
**Do not invent a dark theme as a side effect of another task.**

```css
--paper: #fbfbfa;            --surface: #ffffff;
--ink: #0b0b0c;              --ink-secondary: #5c6066;
--structural-teal: #14543c;  /* forest green — token name is a misnomer, rename pending */
--evidence-amber: #14543c;   /* collapsed onto the accent; amber is retired */
--evidence-amber-ink: #0e3d2b;  --evidence-verified: #14543c;
--rule: #0b0b0c;             /* same as --ink; name lies, rename pending */
```

**One accent, four jobs.** The three evidence hues have collapsed onto the same forest green;
they survive as separate tokens only so every call site did not have to change at once.

| Token | Job |
|---|---|
| `--structural-teal` | The accent. Masthead rule, current nav item, back link and folios, running-head title |
| `--evidence-amber` | Now identical to the accent. The LinkedIn card's `<mark>` and blockquote rule therefore paint **green, not amber** |
| `--evidence-verified` | Now identical to the accent. No distinct treatment |

Rules that are easy to break by accident:

1. **The accent is safe as small type here — that is new.** Forest `#14543C` on `#fbfbfa`
   measures **8.58:1**, so it carries 10-11px folios and index links. The old amber could not
   (3.62:1) and was marker-only. Do not carry that old caveat forward; do re-measure if the
   accent changes.
2. **No hardcoded colour at call sites.** Every hex lives once, in `:root`. Tints and
   hairlines are `color-mix()` derivations (`--tint-*`, `--rule-*`, `--highlight`) so a hue
   changes in one place.
3. **Colour is never the only channel.** The current nav item carries `aria-current` as
   well as a rule.
4. **Verify contrast in-browser, through a canvas.** The `color-mix()` tints compute as
   `oklab()` and cannot be read off a hex table — a naive JS parse silently mis-reads them.
5. **Never animate a layout property on hover.** Text must not reflow under the pointer.
6. **`prefers-reduced-motion` must stay last in `main.css`.** Mid-file, it silently fails to
   zero every transition declared after it.

### Accents render only where content exercises them

`mark` and blockquote have a live instance — `partials/linkedin-card.html` renders both on
`/thinking/` — but since `--evidence-amber` now resolves to the accent, they paint green. There is
currently **no highlighter hue distinct from the structural accent**. If you want one back, choose
it deliberately and measure it against `#fbfbfa`; do not reinstate `#B86B35`.

`evidence_status` remains in front matter and renders nothing: the visible badge was removed as
jargon. Long-form pages get their colour from folios, the running head and the margin index rather
than from prose accents.

## Architecture

### Content

`content/_index.md` (home) · `about.md` · `advisory.md` (aliases `/consulting`, `/advisory`)
· `writing.md` · `resume.md` · sections `work/`, `thinking/`, `notes/`, `essays/`, `skills/`
· `_content.gotmpl` generates the `/agency/` dispatches and `/case-studies/` pages.

Deliberately unpublished right now — do not "fix" these without asking:
- `content/resume.md` — `draft: true` + `build.render: never`. `/resume/` does **not** exist.
  No résumé link is published anywhere; `data/profile.toml` explains why and both call sites
  guard on the key with `with`.
- `content/skills/_index.md` — draft, so `/skills/` 404s.

### Data

`data/profile.toml` is the **canonical profile source** — name, role, employer, positioning,
and `[links]`. Prefer it over `config/_default/params.toml` for anything a template renders.
`data/experience.json` backs the résumé template.

### Key layouts

`_default/baseof.html` (shell, self-hosted fonts, Hugo Pipes CSS) · `index.html` (home) ·
`work/{list,single}.html` · `thinking/list.html` · `notes/{list,single}.html` ·
`essays/single.html` · `resume/single.html`

Partials worth knowing: `section-rail.html` (vertical rule + one mono label, the core
structural unit), `work-card.html`, `note-card.html`, `nav.html`, `footer.html`,
`wayfinding.html`, `diagram-boundary.html`, `og-image.html`, `schema.html`.

### Config

`config/_default/` — `hugo.toml` (baseURL and `publishDir = "docs"`; **do not change
either**), `params.toml`, `languages.en.toml`, `menus.en.toml`, `module.toml` (empty).

## Hard Constraints

1. **No PII in committed or published artifacts.** A phone number shipped for months inside
   a flattened Canva PDF, where no text search could find it. Treat image-only PDFs as
   opaque: render and *read* them before publishing. A phone-free copy lives in gitignored
   `_private/`; the published site links no résumé at all.
2. **Employer safety.** Must not read as running an active consulting business while employed
   at Montai. Use "Advisory & Thought Partnership," never pricing, timeframes, or deliverables.
   Avoid "discovery call," "booking," "investment."
3. **Content authenticity.** Existing portfolio prose is substantially fabricated and does not
   sound like Athan. Do **not** write new case studies or rewrite the résumé without the
   ChatGPT Deep Research outputs (Voice & Style Guide, Montai Work Archaeology) in
   `2B-new/000 System/01 Inbox`. Structural, design, and technical work is fine meanwhile.
   See `.planning/VOICE-REFERENCE.md` and `.planning/CONTENT-SAFETY-CONTRACT.md`.
4. **Never commit internal Montai material.** `.planning/` is tracked and **public**. A prior
   commit put 946 lines of internal evidence material into this public repo; deleting it from
   HEAD did not remove it from history.
5. **Mobile below 768px is not verifiably testable here.** Viewport emulation is unsupported
   in cmux/WKWebView and headless Chrome will not start in this sandbox. Verify at 800px and
   1600px and say plainly that narrow is unverified — do not claim it.

## Common Tasks

**Styles:** edit `assets/css/main.css`, consume tokens from `tokens.css`, add no new hex
outside `:root`, re-measure contrast in-browser, update `DESIGN.md` and
`.planning/ACCESSIBILITY-CHECKS.md` in the same commit.

**Navigation:** edit `config/_default/menus.en.toml`. Confirm the target actually renders —
a menu entry pointing at an unrendered page is a 404 that a stale `docs/` orphan can hide.

**Unpublishing a page:** change the front matter, rebuild, then delete the orphan from
`docs/`, then grep `docs/` for any surviving link to it.
