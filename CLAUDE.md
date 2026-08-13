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

The design system is **Editorial Systems**: warm paper, near-black ink, serif display,
flat surfaces. See `DESIGN.md` (the design authority) and `PRODUCT.md`.

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

## Design System: Editorial Systems

**Authority:** `DESIGN.md`. Tokens: `assets/css/tokens.css`. Implementation:
`assets/css/main.css`. Measured contrast: `.planning/ACCESSIBILITY-CHECKS.md`.
Zero `!important`, zero border-radius, zero box-shadow — all deliberate.

### Typography

Fonts are **self-hosted woff2** in `static/fonts/`, not a CDN.

| Token | Stack | Role |
|---|---|---|
| `--font-serif` | Source Serif 4 | Display and long-form reading |
| `--font-sans` | Manrope | UI text, summaries |
| `--font-mono` | IBM Plex Mono | Rail labels, metadata |

### Colour

Light only. **There is no dark mode** — no toggle in `baseof.html`, no `html.dark` block in
`main.css`. It is deferred on purpose ("ship one polished light experience"). The
`#theme-toggle` rules in `main.css` are orphans from the retired system. Untested dark
starting values are recorded in a `tokens.css` comment and are marked do-not-ship-unmeasured.
**Do not invent a dark theme as a side effect of another task.**

```css
--paper: #f6f2ea;            --surface: #fffdf8;
--ink: #14202b;              --ink-secondary: #53606a;
--structural-teal: #17616a;  --evidence-amber: #b86b35;
--evidence-amber-ink: #96521f;  --evidence-verified: #41603f;
--rule: #d8d1c4;
```

Three accents, each with exactly one job, none decorative:

| Hue | Job |
|---|---|
| `--structural-teal` | Structure and wayfinding: where the reader is, where they can go |
| `--evidence-amber` | The in-prose highlighter. Live on `/thinking/`: the LinkedIn card's `<mark>` and its blockquote rule. The evidence badge that also used it was removed |
| `--evidence-verified` | A claim with a traceable source. Reserved; no live consumer yet |

Rules that are easy to break by accident:

1. **`--evidence-amber` cannot carry text.** It is 3.62:1 on paper — fine as a non-text
   marker, fails AA as type. Use `--evidence-amber-ink` (5.34:1) for amber type.
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

`mark` and blockquote **do** have a live instance — `partials/linkedin-card.html` renders both,
so amber paints on `/thinking/` (verified in-browser 2026-08-13, not inferred from the CSS).
The verified treatment has none: nothing sets `evidence_status: verified`. The visible evidence
badge was removed on purpose (jargon to first-time readers); `evidence_status` remains in front
matter only. If the site reads monochrome, the fix is usually content that uses the remaining
accents, not more CSS.

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
