# Personal Brand Proof Layer

**Status:** approved design, implementation pending  
**Branch:** `brand/personal-fieldnotes-proof-layer`  
**Date:** 2026-09-10

## Purpose

Personal Fieldnotes already has the right surface language. This pass strengthens the evidence architecture underneath it so the site works for two audiences at once:

1. practitioner peers and speaking organizers should discover a useful point of view and want to keep reading;
2. hiring leaders should quietly accumulate evidence that Athan can lead AI, data, and product work in high-judgment environments.

The homepage should feel like the first audience. The deeper pages should prove the second.

## Brand architecture

The site resolves into four public destinations with distinct jobs:

- **Home** → interesting practitioner. Introduce Athan, one current idea, selected work, Fieldnotes, trajectory, operating territory, and context in one scroll.
- **Work** → credible product leader. Evidence-backed product narratives that show ownership, tradeoffs, boundaries, and measured outcomes without overstating adoption.
- **Fieldnotes** → coherent intellectual territory. Essays, field notes, and selected LinkedIn writing around AI, expert work, product judgment, verification, and operating models.
- **About** → research depth + career trajectory + leadership classification. The place where the reader sees the full arc from medical research into data science, product, and AI-enabled expert work.

No separate Skills page, consultancy funnel, generic project zoo, or public resume page in this pass.

## Governing positioning

Keep the existing homepage positioning as the classification line:

> I build AI and data products for people whose work depends on judgment.

Do not replace it with a broader slogan. Supporting copy can clarify the territory, but the site should not stack positioning phrases.

The recurring proof themes are:

- product judgment;
- expert workflows;
- verification and reliability;
- explicit human/machine boundaries;
- ownership and operating models;
- research depth as the foundation for how Athan reasons about evidence.

## What changes

### Home

Keep the seven-chapter architecture already on `main`:

1. Identity
2. Current idea
3. Work
4. Fieldnotes
5. Trajectory
6. Operating territory
7. Context

Do not redesign the homepage from scratch.

#### Current idea / Outer Loop

Replace the hardcoded mini-flow visual in the featured essay block with the actual generated Outer Loop artwork.

Implementation choice:

- commit a lossless PNG at `static/img/outer-loop-highlight.png`;
- use the highest-resolution generated source available, with a minimum of 1200×1200 device pixels and a target of roughly 1800×1800 where generation/export permits;
- remove `static/img/outer-loop-highlight.webp` after the PNG is wired and verified so there is one canonical asset;
- preserve the existing citrus editorial feature treatment around it;
- the artwork carries the visual density, not an alternate `boundary-motif` or forest-field diagram;
- keep the essay title, summary, and CTA outside the image as semantic HTML;
- preserve readability on Retina displays and narrow screens;
- do not shrink the artwork until its labels become decorative noise.

#### Work

Keep Work before Fieldnotes.

Do not fabricate a third item to make the grid symmetrical. Two strong public case studies are preferable to three uneven ones.

The card treatment should make ownership and the governing problem legible quickly. Evidence limitations remain part of the story, not footnotes to hide.

#### Fieldnotes

Treat the current small corpus as deliberate curation rather than an empty archive. Use hierarchy, not filler, to make Essays, Notes, and LinkedIn feel intentional.

#### Trajectory

Keep the chronological research → data science → product/AI arc. Avoid resume-style bullet density on the homepage.

#### Operating territory

Keep the recurring-question framing. The section should connect the writing and the work rather than behaving as a skills taxonomy.

### Work

The existing two public pieces remain the core evidence set:

- `content/work/analog-search-as-a-product.md`
- `content/work/intelligence-platform-for-an-absent-user.md`

Do not broaden the collection merely to increase card count.

Improve the Work index so the reader can understand the evidence model before opening a case:

- these are product narratives, not project summaries;
- measured outcomes are labeled as measured;
- ranges are used where exact figures should not publish;
- missing adoption or outcome instrumentation is stated where relevant;
- Athan's ownership is explicit and separated from engineering/scientific collaborators' ownership.

### Fieldnotes

`/thinking/` remains the canonical writing destination.

Improve the archive so three content sources are legible:

- Essays
- Field Notes
- LinkedIn

The second LinkedIn item currently commented out in `data/linkedin.toml` may only be enabled once its real publication date is known. Do not invent a date. In this PR, leave it commented unless a verified date is supplied from an existing source.

Do not create placeholder entries to make the archive appear active.

### About

This is the largest content change.

The current About page is accurate but too thin and too resume-like in the Experience section. Replace it with a page that proves depth without becoming a CV.

Canonical structure:

1. **Opening classification** — current role and the transition from research into product/data/AI work.
2. **How I work** — a short practitioner section organized around problem framing, expert judgment, verification, and boundaries.
3. **Trajectory** — concise chronological role history, with enough context to show movement rather than only titles.
4. **Selected work evidence** — two compact links to the public Work narratives, each framed by the decision Athan owned.
5. **Research foundation** — selected research and a compact publication signal. Surface the verified research record without listing fourteen citations inline.
6. **Current territory** — what Athan is actively exploring through Fieldnotes.
7. **Conversations** — low-pressure invitation for panels, peer conversations, or speaking, anchored at `#conversations`. No consulting/service language.

### Research signal

Use the structured publication and education data as real evidence.

The About page communicates:

- PhD in Medical Sciences, McMaster University;
- a verified research publication record;
- a small set of first-author publications selected from `data/publications.json`;
- a compact aggregate signal only where it can be computed from the structured data rather than copied as prose;
- no full fourteen-item bibliography in the primary About reading flow.

If a full-publications expansion adds more interface than value, omit it. The structured source remains in the repo and the selected research is enough for this pass.

Do not turn About into an academic CV.

### GitHub / open-source signal

Do not add a generic Open Source section simply because public repositories exist.

Inspect candidate repositories before surfacing them. A repository belongs on the site only if it strengthens the current brand story around data products, scientific tooling, AI-enabled work, or technical/product judgment.

If no repository clearly improves the story after inspection, ship no GitHub proof module. The existing profile link remains sufficient.

Historical or unrelated repositories stay off-site rather than becoming decorative proof tiles.

## Remove / redirect / archive ledger

### Retire `/writing/`

`data/redirects.toml` already defines `/writing/` → `/thinking/`. Keep that redirect as the sole public behavior.

Delete `content/writing.md`; do not retain obsolete body copy that points at retired `/case-studies/` routes.

### Retire `/advisory/` and `/consulting/`

`data/redirects.toml` already defines both routes → `/about/#conversations`. Keep those redirects as the sole public behavior.

Fold the useful speaking/panel intent into the About `#conversations` section, then delete `content/advisory.md`. Do not retain consultancy-style copy or the old alias in content frontmatter.

### Keep resume unpublished

`content/resume.md` remains draft/non-rendering. Do not publish the old PDF or add resume navigation in this pass.

The existing structured data can inform About, but the public resume is a separate future deliverable that requires a sanitized export and claim review.

### Remove hidden Skills fixture

Delete `content/skills/_index.md`. The `/skills/` and retired plugin-doc routes are already owned by explicit redirects in `data/redirects.toml`.

Do not expose a Skills nav item. Do not modify quarantined child content unless verification shows that it conflicts with the existing redirect/publication rules.

### Archive obsolete asset plan

Move `ASSET_GENERATION_PLAN.md` to `.planning/archive/ASSET_GENERATION_PLAN-legacy.md` and prepend a short archival notice stating that it describes the retired pre-Fieldnotes visual system and is not current design authority.

Delete the root-level `ASSET_GENERATION_PLAN.md` as part of the move.

Add a clear current-authority note in `DESIGN.md` and/or `CLAUDE.md` so an agent does not revive the teal/terracotta/purple system from the archived file.

## Fixtures vs intentional absence

The pass must distinguish three states:

- **real and public** → render it;
- **real but not yet verified / employer-safe** → keep it private;
- **legacy fixture or stale route** → remove, redirect, or archive it.

Do not solve intentional absence by inventing content.

## Voice

Use the public-writing register already documented in the repository and Athan's writing-style guidance.

Key rules:

- concrete mechanism over brand language;
- conclusion early on operational/work surfaces;
- precise uncertainty rather than ambient hedging;
- no generic thought-leadership phrasing;
- no resume throat-clearing;
- one governing distinction at a time;
- research credibility should be shown through real evidence, not adjectives;
- hiring relevance should emerge from what Athan owned and how he reasoned, not from claims that he is "strategic" or "innovative."

## Content safety

`.planning/CONTENT-SAFETY-CONTRACT.md` remains binding.

Do not publish:

- internal Montai program/tool names;
- colleague names;
- private workspace links;
- commercial relationships;
- unsupported adoption claims;
- targets written as outcomes;
- unpublished portfolio counts or sensitive financial figures.

When a case has no measured adoption/outcome, say so rather than filling the gap.

## Visual system

Preserve Personal Fieldnotes:

- warm paper;
- ink;
- forest;
- citrus;
- serif editorial display;
- mono metadata;
- flat, square, rule-based composition;
- signature diagrams only where they explain an idea.

Do not reintroduce the older teal/terracotta/purple asset system.

The site can become richer through composition, evidence, motion, and authored diagrams, not through generic icon sets or more card chrome.

## Motion

Keep the current motion rule: motion should explain progression or state and must never gate content.

Any new About/Work interactions must honor `prefers-reduced-motion` and preserve the complete static document.

## Repository authority updates

Update the relevant authority files so future agents inherit the decisions:

- `PRODUCT.md`
- `DESIGN.md`
- `.planning/CONTENT-MODEL.md` where route/content-type behavior changes
- `CLAUDE.md` for the retired-file and routing guidance

The spec itself is the design authority for this PR.

## Implementation boundaries

Likely files touched:

- `layouts/index.html`
- `assets/css/fieldnotes-home.css`
- `content/about.md`
- About-specific layout/CSS if needed
- `content/work/_index.md` and/or Work list template
- `layouts/thinking/list.html`
- `content/writing.md` (delete)
- `content/advisory.md` (delete)
- `content/skills/_index.md` (delete)
- `data/redirects.toml` (verify existing stubs; change only if tests expose a conflict)
- `ASSET_GENERATION_PLAN.md` (move to archive)
- `.planning/archive/ASSET_GENERATION_PLAN-legacy.md`
- `DESIGN.md`
- `PRODUCT.md`
- `.planning/CONTENT-MODEL.md`
- `CLAUDE.md`
- verification scripts as needed
- `static/img/outer-loop-highlight.png`
- `static/img/outer-loop-highlight.webp` (delete after replacement)

Avoid unrelated refactors.

## Verification

Before merge:

1. `hugo --gc --minify`
2. `bash scripts/verify-build.sh`
3. `bash scripts/verify-render.sh`
4. `bash scripts/publish-gate.sh`
5. any new focused route/content regression tests
6. `git diff --check main...HEAD`
7. desktop and mobile visual inspection
8. keyboard-only navigation
9. 200% text zoom
10. reduced-motion path
11. JavaScript-disabled homepage and About page
12. verify `/writing/` → `/thinking/`
13. verify `/advisory/` and `/consulting/` → `/about/#conversations`
14. verify `/skills/` remains owned by its existing redirect
15. verify no draft/private content enters sitemap or production output
16. verify current public Work and Fieldnotes routes remain stable
17. verify the lossless Outer Loop asset is actually used by the homepage and the old lossy WebP is absent

## Acceptance criteria

- The public IA is clearly Home / Work / Fieldnotes / About.
- A practitioner reader encounters ideas before credentials.
- A hiring reader can establish current role, trajectory, research depth, product ownership, and current AI/data/product territory without needing a public resume.
- No public page reads like a consulting business.
- No stale page points readers toward retired case-study architecture.
- No visible placeholder/fixture copy remains on active public routes.
- Intentional content gaps remain empty rather than being padded with invented cards.
- The two public Work pieces remain evidence-disciplined and prominent.
- The research record becomes visible without turning About into an academic CV.
- The Outer Loop feature uses a crisp high-resolution lossless artwork, not the low-resolution WebP or an alternate motif substitute.
- `/writing/`, `/advisory/`, `/consulting/`, and `/skills/` have one unambiguous redirect owner each.
- The obsolete asset plan exists only under `.planning/archive/` with a visible retirement warning.
- Obsolete design documents cannot plausibly override current Personal Fieldnotes authority.
- Existing content-safety and publication gates still pass.

## Deferred

- public downloadable resume;
- dark mode;
- consultancy/advisory offering;
- generic Skills page;
- auto-synced LinkedIn feed;
- expanding Work before new stories clear evidence and employer-safety review;
- broad GitHub project gallery;
- new visual framework or client-side application layer.
