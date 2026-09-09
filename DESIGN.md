# Personal Fieldnotes

Current design authority · 2026-09-09. This replaces Hybrid + book architecture as the current
visual direction, following Athan's request to adapt the Fieldnotes aesthetic to his personal site.
The existing book reading structure remains useful and is retained.

## Identity

Athan Dial is the brand. Preserve the wordmark, portrait, public profile links, favicon, canonical
domain and existing article addresses. Fieldnotes names the publication at `/thinking/`; it is
not a second organization or an employer-branded property. The home page introduces Athan,
features The Outer Loop, then offers the notebook, selected work, and brief personal context.

## Visual language

- A spacious editorial composition with a large serif opening, a compact portrait, restrained
  metadata, and thin section rules. Reuse the original personal site body and identity fonts.
- Paper stays `#fbfbfa`; ink `#0b0b0c`; secondary text `#5c6066`; forest `#14543c`.
- Citrus `#e4f17c` is an intentional new highlight for the featured essay and human decisions.
- Thin dividers use `#d9d9ce`. They group content; they are not the sole outline for controls.
- Flat surfaces, square corners, no shadows or dark mode. No external font service.
- Archivo: wordmark, body and interface. IBM Plex Mono: metadata. Georgia/system serif:
  display and editorial headings via `--font-display`. `--font-serif` is a legacy Archivo token
  retained for existing layouts; do not silently change every consumer.
- `fieldnotes.css` follows the legacy base stylesheet. It owns the personal notebook components
  and targeted book-heading/diagram updates. Reduced-motion handling stays at the end.

## Reading and navigation

Native Hugo pages remain the publication unit. All writing works without JavaScript. Existing
book features—running head, margin index, colophon, source/distribution links—remain on long-form
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

## Responsive behavior

At 900px the notebook drops to two columns; at 600px it becomes one. The portrait becomes a compact
identity strip on narrow screens. Featured copy and concept panel stack. Diagram steps and branches
stack; arrows rotate only where the sequence actually becomes vertical. Body copy stays at least
16px, diagram descriptions 15px and metadata 12px. No diagram relies on shrinking fixed SVG text.

## Validation boundary

Hugo production builds and repository publication checks are required. New palette contrast is
calculated from sRGB values and recorded in `.planning/ACCESSIBILITY-CHECKS.md`. Browser layout,
200% text zoom, and computed-color verification still require visual review; do not present the
numerical check or the older measurements as browser verification of this redesign.
