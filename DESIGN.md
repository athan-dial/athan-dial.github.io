# Design

Visual system for athan-dial.github.io. Name: **Editorial Systems**.

Origin: Google Stitch project `11570732938641751429`. The token table is mirrored in
`.planning/design/EDITORIAL-SYSTEMS.md`, which stays the source of truth for values; this file
captures how the system is applied and the decisions taken during implementation.

Implementation: `assets/css/tokens.css` (tokens only) + `assets/css/main.css` (system), concatenated
into one fingerprinted bundle. Hugo, no framework, no client JS beyond a small nav script.

## Theme

Ink on near-white. A technical document crossed with a book: high information density, structural
rules, no ornament. (Through 2026-08-13 this was ink on *warm* paper; see "Direction: Hybrid +
book architecture" below for why that changed and what replaced it.) **Strictly flat** — shadows are forbidden and every corner is
square. Depth comes from tonal layering and rules, never from the Z axis.

Light only. A dark variant is deferred rather than half-built.

## Colour

| Role | Token | Value |
|---|---|---|
| Page | `--paper` | `#FBFBFA` |
| Elevated / inset | `--surface` | `#FFFFFF` |
| Primary text | `--ink` | `#0B0B0C` |
| Secondary text | `--ink-secondary` | `#5C6066` |
| Accent | `--accent` | `#14543C` forest green |
| Highlighter (`mark`) | `--evidence-amber` | `#14543C` — same as accent |
| Evidence, text-safe | `--accent-ink` | `#0E3D2B` |

| Rules and dividers | `--rule` | `#0B0B0C` — deliberately equal to `--ink`; rules are structural here, not hairlines |

Strategy: **restrained**. Ink, paper, and ONE accent. The three separate evidence hues collapsed
into a single forest green when the evidence badge was retired and the palette moved to near-white;
they remain as distinct tokens only so call sites did not all have to change at once.

| Hue | Job | Where it appears |
|---|---|---|
| Structural teal | Structure and wayfinding: where the reader is, where they can go | Masthead rule, section-rail labels and rules, current nav item, links, arrows, card hover, portrait mount |
| Evidence amber | A claim that needs qualifying, and the in-prose highlighter | `mark`, blockquotes, empty/in-review states |
| Evidence verified | A claim with a traceable source | Reserved for a sourced-claim treatment; no live consumer yet |

Derived tints and rules (`--tint-*`, `--rule-*`, `--highlight`) are `color-mix()` of those three
against `--surface`, so a hue changes in one place. No call site hardcodes a colour.

**Amber is gone.** It survived the badge removal as the in-prose highlighter, but the palette move
to near-white retired it: `--evidence-amber` now resolves to the same forest green as the structural
accent. The LinkedIn card's `<mark>` and blockquote rule therefore paint green, not amber. If a
distinct highlighter hue is wanted again, it needs re-choosing and re-measuring against `#fbfbfa` —
do not reinstate `#B86B35`, which was 3.62:1 on the old paper and would be worse on this one.

Colour is never the only channel: the current nav item carries `aria-current="page"` as well as its
underline, and folios pair colour with position and number.

Measured contrast: full canvas-resolved table in `.planning/ACCESSIBILITY-CHECKS.md`, remeasured
2026-08-13. Headline figures — ink on paper 19:1, ink-secondary on paper 6.11:1, forest on paper
8.58:1. All 14 probed elements pass AA.

Dark mode: still deferred. No toggle in `baseof.html`.

## Typography

Three families, each with one job.

- **Archivo** — display, headings AND body. A rationalist grotesque; carries the whole text surface.
  OFL-1.1, self-hosted, 35KB latin variable.
- **IBM Plex Mono** — metadata only: running heads, folios, index, colophon terms, diagram labels.

Source Serif 4 and Manrope are retired from the type scale. Their files remain in `static/fonts/`
and their `@font-face` rules remain in `main.css` until a cleanup pass confirms nothing references
them.

Self-hosted latin-subset WOFF2 in `static/fonts/`, preloaded, no external font request. (Both Source
Serif 4's companion Newsreader and IBM Plex Mono appear on impeccable's reflex-reject list; they are
retained under identity-preservation, as above.)

| Style | Family | Size / line | Notes |
|---|---|---|---|
| display-lg | Archivo 700 | 60/64, -0.035em | 38/40 on mobile |
| headline-md | Archivo 700 | 32/40, -0.02em | |
| headline-sm | Archivo 700 | 22/32, -0.01em | |
| body-lg | Archivo 400 | 17/28 | long-form |
| body-md | Archivo 400 | 16/24 | standard prose |
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

## Direction: Hybrid + book architecture (2026-08-13)

The warm-paper Editorial Systems palette was retired after an external review found the visual
system sat in a saturated lane — warm paper, display serif, small tracked mono, thin rules — that a
reader could reasonably believe an AI had produced. The content passed that review strongly; the
surface did not. A design-philosophy library independently confirmed it: its stock "personal
homepage in the Takram style" sample was almost indistinguishable from the site as built.

The replacement is a deliberate cross of two references.

**From Fathom Information Design** — the typeface and the data manners. Archivo (OFL-1.1,
self-hosted at `static/fonts/archivo-latin-variable.woff2`, 35KB) replaces Source Serif 4 and
Manrope for everything except metadata. Metadata keeps IBM Plex Mono, so data still reads as data.
Tabular figures wherever a number or range appears.

**From Müller-Brockmann** — the scale and the hardness. 60/64 display at 700 and `-0.035em`,
3px black rules, flush left, no tinted bands, one accent.

**From Irma Boom** — the structure, and only the structure. A first attempt to express this as a
palette failed instructively: swapping tokens produced a warmer version of the same page, because
book architecture is not colour. It is running heads, folios, marginalia, and active margins. Those
required rebuilding `layouts/work/single.html`, not repainting it.

### What that means concretely, on a case page

- A **running head** naming the section and the piece, the way a book names itself on every spread.
- The outline moved out of a boxed nav and into the margin as an **index**.
- **Folios** — section numbers in the margin, generated by a CSS counter on `h2`. A counter, not a
  list: the previous hardcoded eight-anchor outline is exactly what rotted.
- A **colophon** at the foot carrying role, users, themes and date, so the opening carries only the
  title and the argument.
- The rail receives only the page. Passing it the metadata too printed everything twice.

### The grid, and the trap in it

`.section-rail` is a 12-column grid driven by `grid-template-areas`
(`"meta meta content content ..."`), **not** by `grid-template-columns`. Overriding the columns
leaves the spanned children to invent implicit tracks — the first attempt produced a 12-track
layout with a 540px index column that looked merely "a bit wide" in a screenshot and was only
caught by reading computed styles. Reshape the **areas**: 2 tracks index, 7 text, 3 left empty.
That empty band is the active outer margin, and it is load-bearing, not padding.

### Accent

One accent, `--accent: #14543C`.
Deep green was chosen over Swiss red, ultramarine and ochre: it is sober, it suits expert-domain
work, and it is genuinely uncommon in this space. It measures **8.58:1** on paper, which is why it
is safe as 10px type in the margin — something the old amber never was.

It carries exactly four jobs: the masthead rule, the current nav item, the back link and folios,
and the running-head title. Everything else is ink on paper.

### Known open items

- The masthead is 96% opaque, so content is faintly visible scrolling under it. Pre-existing and
  possibly wanted; decide deliberately.
- "BLUF" remains undefined for a first-time reader, and the larger type makes it more prominent,
  not less. A content fix, not a CSS one.

## Direction: the expressive layer (2026-08-15)

Hybrid + book fixed the typeface, the scale and the structure. What it did not do was *spend*
them. Every section on every page carried the same weight, no page contained a drawn artifact,
and the one accent appeared once — as a 3px rule above the masthead. On a page with something
to be restrained about that reads as restraint; on a portfolio it reads as an unfinished
template. The `/work/` index was the clearest case: two grey text blocks on the left half of a
1240px shell, with the right half holding nothing at all.

The expressive layer adds three things the system had already named and never built. It adds no
colour, no family, no radius and no shadow — it is scale, field, and drawn artifact, assembled
from tokens that already existed.

Implementation: `assets/css/expressive.css`, concatenated **after** `main.css`.

### 1. The boundary motif, drawn

"Boundary and shared layer" has been the stated recurring visual idea since the Hybrid direction
landed, and it existed only as this sentence. `partials/boundary-motif.html` draws it: unequal
local nodes, dependency drops, one 3px boundary, and a named substrate.

The first version left every box empty and read as a placeholder wireframe — the failure mode of
an abstract mark is that it looks like a diagram of nothing. The substrate cells now carry the
five candidates the homepage copy itself names (shared data, infrastructure, verification,
workflow, interface), so the picture and the paragraph cannot drift apart.

### 2. Artifact diagrams on cases

`partials/diagrams/<name>.html`, dispatched by a `diagram:` key in a case's front matter through
`partials/case-diagram.html`. A page with no key renders nothing: a missing artifact is silence,
never a placeholder and never another case's figure.

Each is hand-authored from that case's own text and draws **only what the text states** — no
figures, no counts, no invented stages. `analog-search` is deliberately narrow because that case
already carries the HTML boundary diagram mid-body; repeating the expert/shared split would print
one argument twice, so the artifact draws what the other cannot: the ranked set with the expert's
threshold cutting it.

SVG is right here and wrong for `diagram-boundary.html`, which is prose-led and needs wrapping
text. These are label-led: every string is one short line. Keep it that way — SVG `<text>` does
not wrap.

### 3. One moment of scale, and one field of colour, per page

- Hero display is fluid to 88px and sits **outside** the two-column grid. Inside it the sentence
  had ~600px and broke over six lines at any size worth calling a display.
- The homepage's Product boundary section is a full-bleed ink band carrying the site's central
  claim, bordered in the accent, with the motif beneath it. **One band per page, maximum** — a
  second makes both of them wallpaper.
- `/work/` rows run ordinal | text | artifact across the full shell, and the homepage's Selected
  work uses the same grammar, so a reader meets one shape for a case study. Metadata moved below
  the title: three rows of uppercase mono used to delay every headline.
- `/thinking/` keeps its four-tier template; it got its date column narrowed from a ~310px empty
  gutter to 9rem, and its entry titles set in ink rather than link-green.

### The invariant that moved

**`prefers-reduced-motion` now lives at the end of `expressive.css`**, not `main.css`, because
`expressive.css` is last in the bundle. The rule was always "last in the cascade"; leaving it in
`main.css` would have put it ahead of every transition this layer declares — which is the exact
bug recorded under Motion below, from the first time it drifted.

Contrast for every new element was measured in-browser through a canvas, compositing alpha
against the resolved background: `.planning/ACCESSIBILITY-CHECKS.md`, 14 of 14 pass. The
statement band's label declares paper at 62% opacity and renders at 7.5:1; reading the declared
colour alone would have reported 19:1.

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
