# CLAUDE.md

Guidance for Claude Code working in this repository.

> **This file was stale until 2026-08-12 and caused real damage.** It described a design
> system ("Clinical Architect") that had already been retired, so an agent briefed from it
> was told to preserve a teal/Manrope/glassmorphic/dark-mode system that no longer exists.
> If you change the design system, typography, or colour model, **update this file in the
> same commit.** A confidently wrong CLAUDE.md is worse than none.

## Project Overview

Personal portfolio site. **Hugo v0.154.3+extended, themeless** — every layout is custom in
`layouts/`, no theme dependency, no Hugo modules. Deployed to GitHub Pages via Actions
(`.github/workflows/deploy.yml`): CI builds fresh with `hugo --gc --minify` on every push to
`main` and uploads `public/` as the Pages artifact. Nothing under the publish dir is committed.

Positioning: "decision evidence, not achievements." Pages carry evidence about product
judgment and applied-AI work rather than achievement lists.

The design system is **Personal Fieldnotes** (2026-09-09), requested by Athan: the existing
Athan Dial wordmark, portrait, Archivo/IBM Plex Mono identity, forest accent and book structure,
combined with spacious serif display, a notebook-first homepage and citrus diagram decisions.
See `DESIGN.md`. Prior prohibitions on serif display and a secondary highlight are superseded
by this explicit redesign. GitHub Pages and Hugo remain unchanged.

## Build & Development

```bash
hugo server -D          # local, live reload, http://localhost:1313
hugo                    # production build into public/
```

### Never commit build output

`publishDir` moved from `docs/` to `public/` on 2026-08-14, and `public/` (like the old
`docs/`) is gitignored. Every deployed file is Hugo output built fresh in CI from source —
nothing under the publish dir is ever committed. This still matters: committing build output
is exactly how three superseded CSS fingerprints and an RSS feed with `http://localhost:1313`
baked into it once ended up served on the public site. `scripts/verify-build.sh` asserts
`docs/` stays untracked (`git ls-files docs` must be empty) so that tree can't come back.

The old orphan-page hazard — "Hugo never prunes its publish dir, so an unpublished page's
`index.html` keeps being served" — no longer applies the same way: CI builds into a fresh
`public/` on every deploy, so nothing from a previous build ever survives into the next one.
The current risk looks different: `data/redirects.toml` + `content/_content.gotmpl` generate
meta-refresh stubs for retired paths (`/agency/**`, `/skills/**` plugin subsites,
`/case-studies/**`), and `scripts/verify-build.sh` specifically asserts those trees stay
**stubs only** — a real page reappearing under a retired path (e.g. a content file's
`draft: true` getting flipped back, or a fetch script resurrected) is the failure mode to
watch for now, not a stale file lingering from a prior build.

This already caused a live incident under the old mechanism: a retired `docs/resume/index.html`
kept serving old copy plus a link to a PDF carrying a personal phone number, months after the
page stopped being generated, because nothing ever pruned the committed `docs/` tree. That
specific recurrence path is closed now that the publish dir is gitignored and rebuilt fresh
every deploy — but the underlying PII lesson stands: see Hard Constraint 1.

## Design System: Personal Fieldnotes

Authority: `DESIGN.md`. Tokens: `assets/css/tokens.css`. Existing base/book implementation:
`assets/css/main.css`. Current editorial layer: `assets/css/fieldnotes.css`, bundled last.

- Keep the personal wordmark, portrait, public contact links, favicon, and canonical URLs.
- Archivo remains the self-hosted identity/body face; IBM Plex Mono is self-hosted metadata.
  Georgia/system serif supplies display without a new dependency or external font request.
- Light only, flat surfaces. Forest stays the brand accent. Citrus carries featured writing
  and explicit human decisions. Color never stands alone as the semantic signal.
- Hex colors belong in `tokens.css`. Native HTML diagrams inherit tokens, wrap, and reflow.
- Never animate layout properties. Reduced-motion rules terminate the final CSS layer.
- Fieldnotes is the public label at the existing `/thinking/` path. `/notes/` and `/essays/`
  remain archives. Do not redirect or remove existing articles as a redesign side effect.
- Homepage/list cards include only published/public content; drafts stay excluded.
- Signature diagrams use `layouts/partials/fieldnote-schematic.html` and its shortcode.
  `boundary-diagram` remains supported for existing work. See `DIAGRAMS.md` for authoring.
- The September redesign has build/static checks and numeric palette contrast checks.
  Browser viewport and computed-color checks are unverified in this session; do not call
  the historical browser measurements verification of the new layer.

## Architecture

### Content

`content/_index.md` (home) · `about.md` · `advisory.md` (aliases `/consulting`, `/advisory`)
· `writing.md` · `resume.md` · sections `work/`, `thinking/`, `notes/`, `essays/`, `skills/`
· `_content.gotmpl` reads `data/redirects.toml` and generates **redirect stubs only** (a
root content adapter, `layouts/_default/redirect.html`) for retired paths — `/agency/**`,
`/case-studies/**`, and the `/skills/` plugin subsites all resolve this way now, to `/work/`
or `/thinking/`. It does not generate real content pages.

Deliberately unpublished right now — do not "fix" these without asking:
- `content/resume.md` — `draft: true` + `build.render: never`. `/resume/` does **not** exist.
  No résumé link is published anywhere; `data/profile.toml` explains why and both call sites
  guard on the key with `with`.
- `content/skills/_index.md` and `content/skills/case-studies/_index.md` — both
  `draft: true` + `build.render: never` + `build.list: never`. This does **not** 404:
  `/skills/`, `/skills/orc/`, `/skills/folio/`, `/skills/dev/`, and `/skills/case-studies/`
  all build as redirect stubs (via `data/redirects.toml`) to `/thinking/`. The `/skills/`
  plugin subsites themselves (`orc`, `folio`, the fetched dev-plugin docs) were retired
  2026-08-14 when `athan-dial/skills` was deleted; `/skills/case-studies/` was a hidden
  placeholder that had only kept serving because the old committed `docs/` tree held a stale
  copy — untracking that tree is what actually stopped it, not the frontmatter, which was
  already `draft: true`.

### Data

`data/profile.toml` is the **canonical profile source** — name, role, employer, positioning,
and `[links]`. Prefer it over `config/_default/params.toml` for anything a template renders.
`data/experience.json` backs the résumé template.

### Key layouts

`_default/baseof.html` (shell, self-hosted fonts, Hugo Pipes CSS) · `_default/list.html` ·
`_default/single.html` · `_default/redirect.html` (renders the meta-refresh stubs from
`_content.gotmpl`) · `index.html` (home) · `work/{list,single}.html` · `thinking/list.html` ·
`notes/list.html` · `note/single.html` (Hugo singularizes the type for the single template;
the content dir stays `notes/`) · `essay/single.html` (same pattern — content dir is
`essays/`) · `resume/single.html` · `skills/{list,single}.html` (present but unused while
`content/skills/` stays `draft: true` + `render: never`).

Partials worth knowing: `section-rail.html` (vertical rule + one mono label, the core
structural unit), `work-card.html`, `note-card.html`, `linkedin-card.html`, `nav.html`,
`footer.html`, `favicons.html`, `wayfinding.html`, `diagram-boundary.html`, `og-image.html`,
`schema.html`.

### Config

`config/_default/` — `hugo.toml` (baseURL and `publishDir = "public"`; **do not change
either** — `publishDir` moved here from `docs` on 2026-08-14, deliberately, and should not
move again without the same care), `params.toml`, `languages.en.toml`, `menus.en.toml`,
`module.toml` (empty).

## Hard Constraints

1. **No PII in committed or published artifacts.** A phone number shipped for months inside
   a flattened Canva PDF, where no text search could find it. Treat image-only PDFs as
   opaque: render and *read* them before publishing. A phone-free copy lives in gitignored
   `_private/`; the published site links no résumé at all.
2. **Employer safety.** Must not read as running an active consulting business while employed
   at Montai. Use "Advisory & Thought Partnership," never pricing, timeframes, or deliverables.
   Avoid "discovery call," "booking," "investment."
3. **Content authenticity.** Do **not** write new case studies or rewrite the résumé without the
   ChatGPT Deep Research outputs (Voice & Style Guide, Montai Work Archaeology) in
   `2B-new/000 System/01 Inbox`. That rule stands. Structural, design, and technical work is
   fine meanwhile. See `.planning/VOICE-REFERENCE.md` and
   `.planning/CONTENT-SAFETY-CONTRACT.md`.

   **The live prose is no longer the fabricated archive — updated 2026-08-14.** This constraint
   used to open by saying existing portfolio prose was substantially fabricated. That was true
   when seven `/case-studies/` pages and seven `/agency/dispatches/` pages were live. They were
   **retired to redirect stubs, not repaired** — do not go looking for that archive, and do not
   treat its absence as a gap to fill. An audit of the nine remaining real content files found
   zero percentages, zero dollar figures, and zero counts; five long-form pages state their own
   evidence limits in body text (`content/work/analog-search-as-a-product.md` — "We also did not
   instrument adoption. There is no defensible user count…"; `intelligence-platform-for-an-absent-user.md`
   — "The record does not support the milestone count… I do not use them here."); and two pages
   are externally verifiable as his, via a `canonical_url` to his own LinkedIn article and a
   verbatim quote of his own post. **Do not cut a live page on a fabrication assumption.**

   **The one open content risk is the About page's Experience section.** The Data Research Lead
   description was unpublished on 2026-08-14 for claiming unhedged ownership of shared systems
   with no split between his contribution and the team's — the split both `/work/` pages draw
   carefully. The role line stands with no description. That paragraph is **Athan's to rewrite**;
   the verbatim removed copy is preserved in gitignored
   `.planning/private/about-experience-AWAITING-REWRITE.md`. Two "metric theater" and
   self-assessment lines came out of Trajectory in the same pass, for the reasons recorded there.
4. **Never commit internal Montai material.** `.planning/` is tracked and **public**. A prior
   commit put 946 lines of internal evidence material into this public repo; deleting it from
   HEAD did not remove it from history.
5. **Mobile below 768px is not verifiably testable here.** Viewport emulation is unsupported
   in cmux/WKWebView and headless Chrome will not start in this sandbox. Verify at 800px and
   1600px and say plainly that narrow is unverified — do not claim it.

## Common Tasks

**Styles:** edit the appropriate base or `assets/css/fieldnotes.css` layer, consume tokens from `tokens.css`, add no new hex
outside `:root`, re-measure contrast in-browser, update `DESIGN.md` and
`.planning/ACCESSIBILITY-CHECKS.md` in the same commit.

**Navigation:** edit `config/_default/menus.en.toml`. Confirm the target actually renders —
a menu entry pointing at a `draft: true` or unrendered page is a dead link that's easy to
miss since `public/` is rebuilt fresh every time and carries no history to grep.

**Unpublishing a page:** set `draft: true` (+ `build.render: never` / `build.list: never`
to also drop it from lists), rebuild to a throwaway dir, and confirm with
`scripts/verify-build.sh`. There is no `docs/` orphan to delete anymore — `public/` is
gitignored and rebuilt fresh every deploy. If the URL has external inbound links worth
preserving, add a stub in `data/redirects.toml` (see the `/skills/**` and `/case-studies/**`
entries for the pattern) so it 301s instead of 404ing; then `scripts/verify-redirects.sh`
confirms the stub resolves and grep the built output for any surviving internal link to it.
