# Editorial Systems — canonical design tokens

Pulled verbatim from Google Stitch project `11570732938641751429` ("Spec-Based Redesign Revision"),
design system **Editorial Systems**, on 2026-08-11. This file is the source of truth for
implementation. Do not re-derive tokens from the Stitch screen HTML — those are Tailwind-CDN
prototypes and their values drift.

## Brand

Anchored in the **Rigorous Executive Brief**. Rejects tech-portfolio tropes — vibrant gradients,
rounded floating cards, excessive whitespace — in favour of high information density and
professional authority. Prestige editorial (Economist-adjacent) crossed with structured data
visualisation. Corporate/modern with a minimalist editorial focus. Disciplined typography, a
restricted warm-paper palette, structural rules.

## Colors

Simulates ink on high-quality paper.

| Role | Token | Value |
|---|---|---|
| Paper (page background) | `--paper` | `#F6F2EA` |
| Surface (elevated/inset) | `--surface` | `#FFFDF8` |
| Ink (primary text) | `--ink` | `#14202B` |
| Secondary ink | `--ink-secondary` | `#53606A` |
| Structural teal (functional UI, nav paths) | `--structural-teal` | `#17616A` |
| Evidence amber (tension points, citations, verified data) | `--evidence-amber` | `#B86B35` |
| Rule (dividers) | `--rule` | `#D8D1C4` |

Supporting surface ladder: `surface-container-lowest #ffffff`, `surface-container-low #f7f3eb`,
`surface-container #f1ede5`, `surface-container-high #ece8e0`, `surface-container-highest #e6e2da`,
`surface-dim #dddad2`, `outline #74777c`, `outline-variant #c4c6cc`, `error #ba1a1a`.

Evidence amber is reserved for tension points and acts as a digital highlighter. No rainbow of
category colors. All pairs must be contrast-tested to WCAG 2.2 AA (4.5:1 normal text) — the plan
says these values are direction, not final, so **test and record actual ratios**.

## Typography — tri-font strategy

- **Source Serif 4** — editorial headings: thesis statements, essay titles, primary section headers.
- **Manrope** — body and UI. Long-form reading and navigation.
- **IBM Plex Mono** — technical metadata only: annotations, evidence tags, timestamps, diagram labels.

| Style | Family | Size | Weight | Line height | Tracking |
|---|---|---|---|---|---|
| `display-lg` | Source Serif 4 | 56px | 700 | 64px | -0.02em |
| `display-lg-mobile` | Source Serif 4 | 40px | 700 | 48px | -0.01em |
| `headline-md` | Source Serif 4 | 32px | 600 | 40px | — |
| `headline-sm` | Source Serif 4 | 24px | 600 | 32px | — |
| `body-lg` | Manrope | 19px | 400 | 32px | — |
| `body-md` | Manrope | 17px | 400 | 28px | — |
| `metadata-caps` | IBM Plex Mono | 12px | 500 | 16px | 0.08em |
| `label-mono` | IBM Plex Mono | 14px | 400 | 20px | — |

Body measure: 65–75 characters.

## Layout & spacing

12-column fluid grid, hard max width 1240px.

| Token | Value |
|---|---|
| `max-width` | 1240px |
| `reading-column` | 720px |
| `gutter` | 24px |
| `margin-mobile` | 16px |
| `margin-desktop` | 40px |
| `stack-sm` | 8px |
| `stack-md` | 16px |
| `stack-lg` | 32px |
| `stack-xl` | 64px |

- **Information density** — avoid large empty vertical expanses. Content should feel packed but organized.
- **Reading column** — long-form narrative restricted to a centered 720px column.
- **Section rails** — use the outer columns for annotations, citations, evidence labels in the metadata font.
- **Breakpoints** — mobile <768px: single-column stack, 16px margins, monospace metadata moves *above*
  primary content. Desktop 1024px+: full 12-column span for case studies, horizontal rules grouping data sets.

## Elevation — strictly flat

- **No shadows.** Explicitly forbidden. Hierarchy comes from tonal layering and structural lines.
- Tonal layers: `surface` distinguishes inset content/sidebars from the `paper` background.
- Heavy use of horizontal and vertical 1px `rule` lines — financial-report / broadside structure.
  Major section breaks use 2px or 3px rules.
- Interactive depth: hover shifts background (`paper` → `surface`) or reveals an underline. Never a shadow.

## Shapes — sharp

**0px radius everywhere.** All containers, buttons, inputs have square corners. Reinforces the print
metaphor: paper and ink have crisp edges.

## Components

- **Buttons** — sharp. Primary: `ink` background, `paper` text. Secondary: 1px `rule` border, `ink` text.
  Active/pressed: `structural-teal`.
- **Evidence labels** — small monospaced tags, `evidence-amber` text on a very light amber tint.
- **Dividers** — 1px `rule`; 2–3px for major section anchors.
- **Inputs** — square, 1px border; focus is a high-contrast 2px `structural-teal` border.
- **Lists** — data-heavy lists use grouped fields: horizontal rows separated by rules, not floating cards.
- **Cards** — only if a grid demands it, defined by a 1px border or a shift to `surface`. No shadows, no radius.
- **Section rails** — vertical lines separating margin notes from the primary column.

## Motion

Minimal and fast. Restricted to navigation, disclosure, and state changes. Disabled under
`prefers-reduced-motion`. **Dark mode is deferred** — ship one polished light experience.

## Imagery

One real portrait treated as editorial supporting material, not half the product. Sanitized real
artifacts: workflow diagrams, evidence tables, interface crops, system maps. No stock photography,
no AI-generated abstract network art, no decorative icon museum.

Recurring visual idea, used carefully: **boundary and shared layer** — local nodes, a common
substrate, and the line where reliability becomes shared responsibility. For diagrams and section
dividers, never as a logo needing explanation.
