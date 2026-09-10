# Personal Fieldnotes

Current design authority · 2026-09-09, extended 2026-09-10. This replaces Hybrid + book
architecture as the current visual direction, following Athan's request to adapt the Fieldnotes
aesthetic to his personal site. The existing book reading structure remains useful and is retained.

## Retired systems — do not revive

Two earlier visual systems exist in this repository's history and one of them still exists as a
file. Neither is authority.

- **The pre-Fieldnotes "Editorial Data Intelligence" asset system** — teal `#2E5C8A`, terracotta
  `#C17A47`, sage, purple, and a 35-asset icon programme. Its plan is archived at
  `.planning/archive/ASSET_GENERATION_PLAN-legacy.md` with a retirement notice on line 1. It is
  kept only as a record of what was rejected. `scripts/verify-proof-layer.sh` asserts those hexes
  stay out of `tokens.css`.
- **Clinical Architect** — teal, Manrope, glassmorphic, dark mode. Removed earlier; CLAUDE.md
  records the damage a stale description of it caused.

If a file in this repository describes a palette that is not warm paper, ink, forest, and citrus,
it is history. `assets/css/tokens.css` is the only place a colour is defined.

## Identity

Athan Dial is the brand. Preserve the wordmark, portrait, public profile links, favicon, canonical
domain and existing article addresses. Fieldnotes names the publication at `/thinking/`; it is
not a second organization or an employer-branded property.

The homepage is a personal site first and a publication surface second. Fieldnotes supplies the
editorial language; the information architecture still needs to explain Athan's work, trajectory,
and recurring problem territory to a first-time reader.

Canonical homepage sequence:

1. Identity
2. Current idea
3. Work in practice
4. Fieldnotes
5. Trajectory
6. Operating territory
7. Context

## Visual language

- A spacious editorial composition with a large serif opening, a compact portrait, restrained
  metadata, and thin section rules. Reuse the original personal site body and identity fonts.
- Paper stays `#fbfbfa`; ink `#0b0b0c`; secondary text `#5c6066`; forest `#14543c`.
- Citrus `#e4f17c` is an intentional highlight for featured writing and human decisions.
- Thin dividers use `#d9d9ce`. They group content; they are not the sole outline for controls.
- Flat surfaces, square corners, no shadows or dark mode. No external font service.
- Archivo: wordmark, body and interface. IBM Plex Mono: metadata. Georgia/system serif:
  display and editorial headings via `--font-display`. `--font-serif` is a legacy Archivo token
  retained for existing layouts; do not silently change every consumer.
- `fieldnotes.css` follows the legacy base stylesheet and owns the shared notebook components,
  plus the proof-layer components for About and the Work index (`.about__*`,
  `.work-card__evidence`, `.work-index__*`). Its reduced-motion block must remain last, so new
  rules go BEFORE it, never appended after.
- `fieldnotes-home.css` is home-only and owns the chapter index, trajectory, territory layout,
  the Outer Loop plate, and homepage progressive motion. Its reduced-motion block must remain
  last.

## Homepage composition

The opening should classify Athan by the problem class he works on, not by a generic personal-brand
motto. The canonical headline lives in `data/profile.toml`:

> I build AI and data products for people whose work depends on judgment.

The featured Outer Loop treatment follows as the current idea. Work appears before the general
Fieldnotes feed so the page establishes practice before widening into the publication archive.
Trajectory then restores the deeper "virtual profile" effect without becoming a resume dump.
Operating territory connects the work and writing through recurring questions rather than a skills
inventory. Context closes with low-pressure paths deeper into the site.

## Trajectory

The homepage trajectory is deliberately sparse. It may render only:

- role;
- company;
- date range;
- the canonical PhD foundation in `data/profile.toml`.

Do not render the `summary` values from `data/experience.json` on the homepage. Those paragraphs are
legacy resume material and contain claims outside this redesign's evidence scope.

The visual purpose is movement, not credential accumulation: research foundation -> data science ->
product leadership -> AI-enabled expert work.

## Scroll and motion

The common visit is one scroll, so the page may use motion to explain progression. It must never use
motion to withhold content.

### Wide-screen chapter index

At wide desktop widths, a fixed marginal chapter index can track the seven homepage chapters. It is
book marginalia, not application navigation.

- Every item is a normal in-page anchor.
- JavaScript may add `aria-current="location"` to the active chapter link.
- The index disappears before it competes with the main column.
- The page remains fully navigable and intelligible without JavaScript.

### Allowed motion

- section rules resolving from a short mark to a full divider on first entry;
- one-time connector emphasis that clarifies diagram direction;
- active-state movement in the chapter index;
- small emphasis shifts that reinforce the move from capability to human judgment.

### Forbidden motion

- parallax;
- scroll-jacking;
- horizontal page translation;
- content hidden at rest and revealed only by JavaScript;
- looping decorative animation;
- animation of layout properties;
- motion required to understand a diagram or navigation state.

`assets/js/fieldnotes-home.js` is an optional enhancement only. It may add entered/current states,
but the server-rendered document is the complete product.

## Reading and navigation

Native Hugo pages remain the publication unit. All writing works without JavaScript. Existing
book features, running head, margin index, colophon, source/distribution links, remain on long-form
pages. All previous work and article URLs are preserved. The Fieldnotes navigation label points
to `/thinking/`, with essays and notes linked as archives. Curated LinkedIn entries stay available.

Do not fill a small archive with placeholder cards. Lists derive only from published/public
content and omit unavailable entries. Keep complete source-backed summaries on article pages;
`card_summary` may provide a shorter, accurate browsing excerpt.

## Schematics

The signature combines a numbered classification, a claim headline, typed blocks, connections,
and a takeaway. Paper cards mean state/evidence; forest blocks mean action; citrus means human
judgment. Dashed returns are feedback. Every meaning has a text label. Native HTML makes labels
selectable, zoomable and reflowable. See `DIAGRAMS.md`. Existing work boundary diagrams remain
supported, with the expert layer highlighted and the shared tool layer in forest.

Schematics are a brand primitive and may appear in articles, work pages, or homepage concept
sections when they make a relationship more legible. They are not decorative filler.

## About and the Work index

Added by the proof-layer pass, 2026-09-10. Authority:
`.planning/specs/2026-09-10-personal-brand-proof-layer-design.md`.

About is the site's proof surface. It renders through `layouts/_default/about.html`, selected by
`layout: about` in `content/about.md`, in seven fixed sections: opening classification, how I work,
trajectory, selected work evidence, research foundation, current territory, conversations. The
`#conversations` anchor is load-bearing beyond the page — `/advisory/` and `/consulting/` both
redirect to it.

Two rules on that page are content boundaries wearing design clothes:

- **The trajectory renders role, company, range, and only already-cleared notes.** The
  `summary` fields in `data/experience.json` are banned here for the same reason DESIGN.md bans
  them from the homepage: they claim unhedged ownership of shared systems. The Data Research Lead
  row deliberately carries no description and points at the Work narratives instead.
- **The research record is computed, never typed.** Totals come from `data/publications.json` at
  build time; the page selects three papers by DOI. A full bibliography inline would turn the page
  into a CV and bury the product argument above it.

The Work index states its evidence model once, above the cases, then each card carries what Athan
owned, what was measured, and what was never measured. Evidence class renders as words —
"Measured, published as a range", not a colour.

Work renders **two depths**, named by `work_kind` (see `.planning/CONTENT-MODEL.md`): full
**Cases**, and narrower **Proof notes** that carry one artifact, one decision, one boundary. They
are separate labelled groups, divided by a dashed rule rather than a solid one, because a proof
note in a flat list beside a full case reads as a case that ran out of material. A group with no
published items does not render at all.

An earlier version of this file said "two published narratives is the whole set on purpose" and the
gate asserted exactly two. Both were retired 2026-09-10: the collection is no longer a fixed pair,
and a count is the wrong invariant — it fails identically whether someone invented a case or
legitimately published one. The gate now derives the expected number from the source frontmatter
and requires the index to agree exactly, which catches a draft leaking onto the page *and* a
published page falling off it.

The Outer Loop plate on the homepage is a finished 1254x1254 lossless artwork with its own
masthead and caption. It is never redrawn, cropped, or captioned by the site, never upscaled past
native, and never squeezed below the width where its inner labels stop being legible. Below 700px
it scrolls inside its own container rather than shrinking.

## No GitHub proof module

Decided 2026-09-10 after inspecting every public non-fork repository. None strengthens the current
positioning: `folio` is archived and points at a deleted repo, `model-citizen` is an unmodified
Quartz v4 tree, and the rest are learning-era. The profile link is sufficient. The full inspection
is recorded in the spec's implementation notes — read it before revisiting.

## Responsive behavior

At 900px the notebook drops to two columns; at 600px it becomes one. The portrait becomes a compact
identity strip on narrow screens. Featured copy and concept panel stack. Diagram steps and branches
stack; arrows rotate only where the sequence actually becomes vertical. The wide chapter index is
not rendered visually at narrower viewports. Body copy stays at least 16px, diagram descriptions
15px and metadata 12px. No diagram relies on shrinking fixed SVG text.

## Accessibility and validation boundary

WCAG 2.2 AA remains the target. Chapter links are real anchors, focus-visible states remain obvious,
and active chapter color is reinforced by `aria-current` and rule state. `prefers-reduced-motion`
removes non-essential motion and smooth scrolling.

Hugo production builds and repository publication checks are required. New palette contrast is
calculated from sRGB values and recorded in `.planning/ACCESSIBILITY-CHECKS.md`. Browser layout,
200% text zoom, keyboard focus, JavaScript-disabled behavior, and computed-color verification require
visual review. Do not present source inspection or historical measurements as browser verification.
