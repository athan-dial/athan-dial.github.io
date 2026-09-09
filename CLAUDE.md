# CLAUDE.md

Guidance for Claude Code working in this repository.

> **This file was stale until 2026-08-12 and caused real damage.** It described a design
> system ("Clinical Architect") that had already been retired, so an agent briefed from it
> was told to preserve a teal/Manrope/glassmorphic/dark-mode system that no longer exists.
> If you change the design system, typography, or colour model, **update this file in the
> same commit.** A confidently wrong CLAUDE.md is worse than none.

## Project Overview

Personal portfolio site. **Hugo v0.154.3+extended, themeless** - every layout is custom in
`layouts/`, no theme dependency, no Hugo modules. Deployed to GitHub Pages via Actions
(`.github/workflows/deploy.yml`): CI builds fresh with `hugo --gc --minify` on every push to
`main` and uploads `public/` as the Pages artifact. Nothing under the publish dir is committed.

Positioning: "decision evidence, not achievements." Pages carry evidence about product
judgment and applied-AI work rather than achievement lists.

The design system is **Personal Fieldnotes** (2026-09-09): the existing Athan Dial wordmark,
portrait, Archivo/IBM Plex Mono identity, forest accent and book structure combined with spacious
serif display, a personal-site homepage, a Fieldnotes publication layer, citrus decision markers,
and native HTML schematics. See `DESIGN.md` and
`.planning/design/PERSONAL-FIELDNOTES-UPDATE-2026-09-09.md`.

## Build & Development

```bash
hugo server -D          # local, live reload, http://localhost:1313
hugo                    # production build into public/
```

### Never commit build output

`publishDir` moved from `docs/` to `public/` on 2026-08-14, and `public/` (like the old
`docs/`) is gitignored. Every deployed file is Hugo output built fresh in CI from source -
nothing under the publish dir is ever committed. This still matters: committing build output
is exactly how three superseded CSS fingerprints and an RSS feed with `http://localhost:1313`
baked into it once ended up served on the public site. `scripts/verify-build.sh` asserts
`docs/` stays untracked (`git ls-files docs` must be empty) so that tree can't come back.

The old orphan-page hazard - "Hugo never prunes its publish dir, so an unpublished page's
`index.html` keeps being served" - no longer applies the same way: CI builds into a fresh
`public/` on every deploy, so nothing from a previous build ever survives into the next one.
The current risk looks different: `data/redirects.toml` + `content/_content.gotmpl` generate
meta-refresh stubs for retired paths (`/agency/**`, `/skills/**` plugin subsites,
`/case-studies/**`), and `scripts/verify-build.sh` specifically asserts those trees stay
**stubs only** - a real page reappearing under a retired path is the failure mode to watch for
now, not a stale file lingering from a prior build.

This already caused a live incident under the old mechanism: a retired `docs/resume/index.html`
kept serving old copy plus a link to a PDF carrying a personal phone number, months after the
page stopped being generated, because nothing ever pruned the committed `docs/` tree. That
specific recurrence path is closed now that the publish dir is gitignored and rebuilt fresh
every deploy, but the underlying PII lesson stands: see Hard Constraint 1.

## Design System: Personal Fieldnotes

Authority: `DESIGN.md`. Tokens: `assets/css/tokens.css`. Existing base/book implementation:
`assets/css/main.css`. Shared editorial layer: `assets/css/fieldnotes.css`. Homepage-only layer:
`assets/css/fieldnotes-home.css`, loaded after the shared Fieldnotes layer.

- Keep the personal wordmark, portrait, public contact links, favicon, and canonical URLs.
- Archivo remains the self-hosted identity/body face; IBM Plex Mono is self-hosted metadata.
  Georgia/system serif supplies display without a new dependency or external font request.
- Light only, flat surfaces. Forest stays the brand accent. Citrus carries featured writing
  and explicit human decisions. Color never stands alone as the semantic signal.
- Hex colors belong in `tokens.css`. Native HTML diagrams inherit tokens, wrap, and reflow.
- Never animate layout properties. Motion must never gate visibility or reading order.
- Reduced-motion rules terminate the final CSS layer.
- Fieldnotes is the public label at the existing `/thinking/` path. `/notes/` and `/essays/`
  remain archives. Do not redirect or remove existing articles as a redesign side effect.
- Homepage/list cards include only published/public content; drafts stay excluded.
- Signature diagrams use `layouts/partials/fieldnote-schematic.html` and its shortcode.
  `boundary-diagram` remains supported for existing work. See `DIAGRAMS.md` for authoring.
- Browser viewport, 200% text zoom, keyboard focus, JavaScript-disabled behavior, and computed
  colors must be checked locally before merge. Source review is not browser verification.

### Homepage v2: do not regress this order

The homepage is a personal site using Fieldnotes as its surface language. It is not a sparse
publication cover. Canonical chapter order:

1. Identity
2. Current idea
3. Work in practice
4. Fieldnotes
5. Trajectory
6. Operating territory
7. Context

The canonical hero headline lives in `data/profile.toml`: "I build AI and data products for
people whose work depends on judgment." Do not restore `Try things. Keep what works.` or replace
the current line with generic personal-brand copy.

`data/experience.json` may be used by the homepage trajectory **only for `role`, `company`, and
`range`**. Do not render its `summary` fields. The foundation line comes from
`data/profile.toml`. This is an explicit evidence boundary, not a styling preference.

`assets/js/fieldnotes-home.js` is optional progressive enhancement. It tracks active chapters and
adds entered state; it must never hide, reorder, or reveal required content. The page must remain
complete with JavaScript disabled. The wide chapter index is supplemental marginalia and disappears
before it competes with the main column.

Before changing homepage behavior, read:

- `.planning/design/PERSONAL-FIELDNOTES-UPDATE-2026-09-09.md`
- `.planning/plans/2026-09-09-personal-fieldnotes-home-v2.md`
- `DESIGN.md`
- `PRODUCT.md`
- `DIAGRAMS.md`

Run `scripts/verify-fieldnotes-home.sh` with the normal repository checks.

## Architecture

### Content

`content/_index.md` (home) · `about.md` · `advisory.md` (aliases `/consulting`, `/advisory`)
· `writing.md` · `resume.md` · sections `work/`, `thinking/`, `notes/`, `essays/`, `skills/`
· `_content.gotmpl` reads `data/redirects.toml` and generates **redirect stubs only** (a
root content adapter, `layouts/_default/redirect.html`) for retired paths - `/agency/**`,
`/case-studies/**`, and the `/skills/` plugin subsites all resolve this way now, to `/work/`
or `/thinking/`. It does not generate real content pages.

Deliberately unpublished right now - do not "fix" these without asking:
- `content/resume.md` - `draft: true` + `build.render: never`. `/resume/` does **not** exist.
  No resume link is published anywhere; `data/profile.toml` explains why and both call sites
  guard on the key with `with`.
- `content/skills/_index.md` and `content/skills/case-studies/_index.md` - both
  `draft: true` + `build.render: never` + `build.list: never`. This does **not** 404:
  `/skills/`, `/skills/orc/`, `/skills/folio/`, `/skills/dev/`, and `/skills/case-studies/`
  all build as redirect stubs (via `data/redirects.toml`) to `/thinking/`. The `/skills/`
  plugin subsites themselves were retired 2026-08-14; do not resurrect them.

### Data

`data/profile.toml` is the **canonical profile source** - name, role, employer, positioning,
foundation, and `[links]`. Prefer it over `config/_default/params.toml` for anything a template
renders. `data/experience.json` backs the resume template and the homepage's safe trajectory fields
(role/company/range only).

### Key layouts

`_default/baseof.html` (shell, self-hosted fonts, Hugo Pipes CSS/JS) · `_default/list.html` ·
`_default/single.html` · `_default/redirect.html` (renders the meta-refresh stubs from
`_content.gotmpl`) · `index.html` (home) · `work/{list,single}.html` · `thinking/list.html` ·
`notes/list.html` · `note/single.html` (Hugo singularizes the type for the single template;
the content dir stays `notes/`) · `essay/single.html` (same pattern - content dir is
`essays/`) · `resume/single.html` · `skills/{list,single}.html` (present but unused while
`content/skills/` stays `draft: true` + `render: never`).

Partials worth knowing: `section-rail.html`, `work-card.html`, `note-card.html`,
`fieldnote-card.html`, `fieldnote-schematic.html`, `linkedin-card.html`, `nav.html`, `footer.html`,
`favicons.html`, `wayfinding.html`, `diagram-boundary.html`, `og-image.html`, `schema.html`.

### Config

`config/_default/` - `hugo.toml` (baseURL and `publishDir = "public"`; **do not change
either**), `params.toml`, `languages.en.toml`, `menus.en.toml`, `module.toml` (empty).

## Hard Constraints

1. **No PII in committed or published artifacts.** A phone number shipped for months inside
   a flattened Canva PDF, where no text search could find it. Treat image-only PDFs as opaque:
   render and *read* them before publishing. A phone-free copy lives in gitignored `_private/`;
   the published site links no resume at all.
2. **Employer safety.** Must not read as running an active consulting business while employed
   at Montai. Use "Advisory & Thought Partnership," never pricing, timeframes, or deliverables.
   Avoid "discovery call," "booking," "investment."
3. **Content authenticity.** Do **not** write new case studies or rewrite the resume without the
   ChatGPT Deep Research outputs (Voice & Style Guide, Montai Work Archaeology) in
   `2B-new/000 System/01 Inbox`. That rule stands. Structural, design, and technical work is
   fine meanwhile. See `.planning/VOICE-REFERENCE.md` and
   `.planning/CONTENT-SAFETY-CONTRACT.md`.

   **The live prose is no longer the fabricated archive - updated 2026-08-14.** Seven old
   `/case-studies/` pages and seven `/agency/dispatches/` pages were retired to redirect stubs,
   not repaired. Do not treat their absence as a gap to fill. Remaining live work pages state
   their own evidence limits. Do not cut a live page on a fabrication assumption.

   **The one open content risk is the About page's Experience section.** The Data Research Lead
   description was unpublished on 2026-08-14 for claiming unhedged ownership of shared systems
   with no split between Athan's contribution and the team's. The role line stands with no
   description. That paragraph is Athan's to rewrite. Do not copy legacy experience summaries
   into the homepage as a shortcut around this boundary.
4. **Never commit internal Montai material.** `.planning/` is tracked and **public**. A prior
   commit put internal evidence material into this public repo; deleting it from HEAD did not
   remove it from history.
5. **Mobile below 768px is not verifiably testable in some agent environments.** If viewport
   emulation is unavailable, verify the widths you can and say plainly that narrow is unverified.

## Common Tasks

**Styles:** shared Fieldnotes components belong in `assets/css/fieldnotes.css`; homepage-only
chapter/timeline/territory/index work belongs in `assets/css/fieldnotes-home.css`. Consume tokens
from `tokens.css`, add no new hex outside `:root`, re-measure contrast in-browser, and update
`DESIGN.md` plus `.planning/ACCESSIBILITY-CHECKS.md` when palette behavior changes.

**Homepage verification:** after any homepage/template/style/motion change, run:

```bash
hugo --gc --minify
bash scripts/verify-fieldnotes-home.sh
bash scripts/verify-build.sh
bash scripts/verify-render.sh
bash scripts/publish-gate.sh
git diff --check main...HEAD
```

Then visually inspect `/` at wide desktop and standard desktop, keyboard-only, 200% text zoom,
and with JavaScript disabled. Check narrow/mobile when the local browser supports it. Record any
unverified surface honestly in PR #1.

**Navigation:** edit `config/_default/menus.en.toml`. Confirm the target actually renders - a menu
entry pointing at a draft or unrendered page is a dead link that's easy to miss.

**Unpublishing a page:** set `draft: true` (+ `build.render: never` / `build.list: never` to also
drop it from lists), rebuild to a throwaway dir, and confirm with `scripts/verify-build.sh`. If the
URL has external inbound links worth preserving, add a stub in `data/redirects.toml` and confirm
with `scripts/verify-redirects.sh`.
