# Design

Visual system for athan-dial.github.io. Name: **Editorial Systems**.

Origin: Google Stitch project `11570732938641751429`. The token table is mirrored in
`.planning/design/EDITORIAL-SYSTEMS.md`, which stays the source of truth for values; this file
captures how the system is applied and the decisions taken during implementation.

Implementation: `assets/css/tokens.css` (tokens only) + `assets/css/main.css` (system), concatenated
into one fingerprinted bundle. Hugo, no framework, no client JS beyond a small nav script.

## Theme

Ink on warm paper. A rigorous executive brief crossed with a systems diagram: high information
density, structural rules, no ornament. **Strictly flat** — shadows are forbidden and every corner is
square. Depth comes from tonal layering and rules, never from the Z axis.

Light only. A dark variant is deferred rather than half-built.

## Colour

| Role | Token | Value |
|---|---|---|
| Page | `--paper` | `#F6F2EA` |
| Elevated / inset | `--surface` | `#FFFDF8` |
| Primary text | `--ink` | `#14202B` |
| Secondary text | `--ink-secondary` | `#53606A` |
| Structural accent | `--structural-teal` | `#17616A` |
| Evidence / tension | `--evidence-amber` | `#B86B35` |
| Evidence, text-safe | `--evidence-amber-ink` | `#96521F` |
| Evidence, verified | `--evidence-verified` | `#41603F` |
| Rules and dividers | `--rule` | `#D8D1C4` |

Strategy: **restrained**. Three hues, each with exactly one job, none decorative.

| Hue | Job | Where it appears |
|---|---|---|
| Structural teal | Structure and wayfinding: where the reader is, where they can go | Masthead rule, section-rail labels and rules, current nav item, links, arrows, card hover, portrait mount |
| Evidence amber | A claim that needs qualifying, and the in-prose highlighter | `mark`, blockquotes, empty/in-review states |
| Evidence verified | A claim with a traceable source | Reserved for a sourced-claim treatment; no live consumer yet |

Derived tints and rules (`--tint-*`, `--rule-*`, `--highlight`) are `color-mix()` of those three
against `--surface`, so a hue changes in one place. No call site hardcodes a colour.

**`--evidence-amber` currently has no live consumer.** The visible evidence badge that used it
was removed (it read as unexplained jargon to first-time readers). The token stays defined for
`mark`, blockquotes, and empty/in-review states — those CSS paths exist, but no published content
exercises them. Do not treat the unused token as an accidental orphan.

**The accents were previously near-invisible, which is the problem this system had rather than a
shortage of colour.** Both lived almost entirely on elements that render on no page (`.hero__badge`,
`.case-study-card__category`), so the first viewport of
every page was pure ink on paper. Amber additionally could not carry type at all — `#B86B35` is
3.62:1 on paper — so it only ever appeared as a 1px border or a 10% tint. Two fixes: the accents moved
onto elements that always render, and `--evidence-amber-ink` (5.34:1) lets amber be type.

Amber is no longer spent on section furniture. It previously painted every `.section__label`, every
card category, and the hero badge; a highlighter that marks every line marks nothing. Section labels
are wayfinding and took teal; card categories are metadata and took `--ink-secondary`.

Measured contrast (full table, including the canvas-resolved `oklab()` tints, in
`.planning/ACCESSIBILITY-CHECKS.md`): ink on paper 14.8:1, ink-secondary on paper 5.8:1, teal on
paper 6.4:1, amber-ink on paper 5.3:1, verified on paper 6.3:1, amber-ink on its tint 5.2:1, verified
on its tint 5.9:1, ink on highlight 12.2:1. All pass AA for small text. **`--evidence-amber` itself
still fails 4.5:1 and remains a non-text marker only; use `--evidence-amber-ink` for any amber type.**

Colour is never the only channel: the current nav item carries `aria-current="page"` as well as
its teal underline.

Dark mode: still deferred, and there is no toggle in `baseof.html` (the `#theme-toggle` rules in
`main.css` are orphans from the retired Clinical Architect system). `tokens.css` records untested
starting values for the accents so a future dark pass has a starting point, not a shipped theme.

Note: the warm-paper family is a known AI default, and the token is literally named `--paper`. It
survives here because it is a committed identity decision made in Stitch by the owner, not a
greenfield reflex — identity-preservation wins. Do not extend the warmth further.

## Typography

Three families, each with one job.

- **Source Serif 4** — thesis headings, essay and case titles. Carries the editorial texture.
- **Manrope** — body and UI. Long-form reading.
- **IBM Plex Mono** — metadata only: rail labels, dates, provenance lines.

Self-hosted latin-subset WOFF2 in `static/fonts/`, preloaded, no external font request. (Both Source
Serif 4's companion Newsreader and IBM Plex Mono appear on impeccable's reflex-reject list; they are
retained under identity-preservation, as above.)

| Style | Family | Size / line | Notes |
|---|---|---|---|
| display-lg | Source Serif 4 700 | 56/64, -0.02em | 40/48 on mobile |
| headline-md | Source Serif 4 600 | 32/40 | |
| headline-sm | Source Serif 4 600 | 24/32 | |
| body-lg | Manrope 400 | 19/32 | long-form |
| body-md | Manrope 400 | 17/28 | standard prose |
| metadata-caps | IBM Plex Mono 500 | 12/16, 0.08em | uppercase, rails |
| label-mono | IBM Plex Mono 400 | 14/20 | |

**Measure is enforced in `ch`, on the text elements themselves.** `--reading-column: 720px` yields
~72 characters at 19px but ~82 at 17px. A `ch` value in a `:root` custom property resolves once
against the root font-size and is therefore useless for this; `max-width: 61ch` on the paragraph
holds ~72 characters at both sizes. Verified in-browser.

## Layout

12-column grid, 1240px shell, 720px reading column, 24px gutter. Margins 16px mobile / 40px desktop.
Stack scale 8 / 16 / 32 / 64.

**Section rails.** The outer two columns carry a single mono label per section; the inner ten carry
content, separated by a 1px `--rule` (2px for major anchors). On mobile the rail label moves above
the content.

One label per section, and no numbers. Sequential `01–06` markers were removed: impeccable bans
numbered section markers and repeated uppercase eyebrows as AI scaffolding, and the redesign plan
independently bans decorative counters "unless the numbering communicates a real sequence." A
homepage read order is not that sequence. Numbering is available where order genuinely carries
information; it is not section grammar.

Lists are **grouped fields** — rows separated by rules — not card grids. Cards appear only where a
grid is genuinely the affordance, defined by a 1px border or a shift to `--surface`.

## Components

- **Buttons** — square. Primary: ink fill, paper text. Secondary: 1px rule border, ink text. Active: teal.
- **Highlighter** — `.prose mark`, ink on an amber tint. Amber has always been described as acting like a highlighter; this is the component that does it. No published content uses `<mark>` yet.
- **Grouped-field row** — the default list unit.
- **Section rail** — vertical rule plus one mono label.
- **Empty state** — a quiet mono line inside the rail with a stated intent, on collapsed section padding. Honest that the section exists and is being filled, without reserving dead vertical space.

The visible evidence badge (mono amber pill: "Range only", "Mechanism only", "Verified") was
removed. `evidence_status` remains in front matter as claim-classification data; it is no longer
rendered. The badge read as unexplained jargon to a first-time reader.

## Motion

Minimal and fast: navigation, disclosure, and state changes only. No entrance choreography, no
scroll reveals; content is never gated behind a transition.

Tokens: `--duration-fast` 120ms, `--duration-base` 180ms, `--ease-out-quart`. Everything animated is
colour, text-decoration, or a 4px arrow translate, so the reduced-motion path is an instant state
change rather than a removed one.

Hover never touches layout. `.case-study-card__link` and `.explore-item` used to animate
`padding-inline`, which reflowed every line of the row under the pointer as the reader aimed at it;
the tonal shift now sits on the row container, which already spans its grid cell.

**The `prefers-reduced-motion` block must stay last in `main.css`.** It was mid-file, ahead of the
card and measure-cap rules, so any transition declared after it was never zeroed.

## Imagery

One real portrait, treated as supporting editorial material rather than half the page.

Otherwise **sanitised real artifacts**: boundary diagrams, evidence tables, workflow maps, interface
crops. Hand-authored inline SVG using the system's own tokens, so diagrams inherit the palette and
stay crisp. No stock photography, no AI-generated abstract art, no decorative icon sets, no
hand-drawn or sketchy SVG.

The recurring visual idea is **boundary and shared layer**: local nodes, a common substrate, and the
line where reliability becomes shared responsibility. It belongs in diagrams and dividers, never as a
logo needing explanation.
