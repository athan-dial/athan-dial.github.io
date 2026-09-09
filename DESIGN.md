# Personal Fieldnotes

Current design authority · 2026-09-09. This replaces Hybrid + book architecture as the current
visual direction, following Athan's request to adapt the Fieldnotes aesthetic to his personal site.
The existing book reading structure remains useful and is retained.

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
- `fieldnotes.css` follows the legacy base stylesheet and owns the shared notebook components.
- `fieldnotes-home.css` is home-only and owns the chapter index, trajectory, territory layout,
  and homepage progressive motion. Its reduced-motion block must remain last.

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
