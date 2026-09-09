# Personal Fieldnotes homepage v2

Design update for `redesign/personal-fieldnotes`, 2026-09-09.

## Why this update exists

The first Fieldnotes pass successfully moved the site away from a conventional portfolio surface. It introduced the editorial serif display, paper/forest/citrus palette, notebook cards, and a reusable schematic grammar.

It also simplified the homepage too far. The current sequence reads primarily as a publication landing page and loses some of the stronger "virtual profile" effect from the prior site. Athan's follow-up direction is to keep the Fieldnotes aesthetic while making the personal site more designed, more legible as a professional trajectory, and more rewarding for the common single-scroll visit.

This update therefore treats Fieldnotes as the surface language and the personal site as the information architecture.

## Product goal

A first-time reader should be able to answer, from one scroll:

1. Who is Athan and what kind of work does he do?
2. What is one current idea worth reading?
3. What has he built or worked on?
4. What does he write about repeatedly?
5. How did his career move from research into data science, product, and AI-enabled expert work?
6. Where can the reader go deeper?

The page should feel authored rather than assembled, but it must remain fast, accessible, and useful with JavaScript disabled.

## Non-goals

- Do not turn the site into a consultancy or lead-generation surface.
- Do not publish the private or currently disabled resume.
- Do not add unsupported metrics, internal Montai details, or experience-summary claims.
- Do not replace the existing work-case architecture, evidence gates, redirects, long-form book layout, or `/thinking/` URL structure.
- Do not add a client framework, animation library, third-party embed, external font request, or dark mode.
- Do not make content depend on animation or scroll position to become readable.

## Homepage narrative

The canonical chapter order is:

### 1. Identity

Lead with Athan's actual problem territory rather than a generic motto.

Canonical headline:

> I build AI and data products for people whose work depends on judgment.

Support copy should position Athan as a data scientist and product leader working on expert work, AI, product judgment, and verification. It should not read as a career objective or consultancy pitch.

Keep the portrait, wordmark, current role/location metadata, and direct paths into work and Fieldnotes.

### 2. Current idea

Keep the featured cornerstone essay treatment for The Outer Loop and the citrus/forest concept panel. This is the first proof that the site contains a point of view rather than only credentials.

### 3. Work in practice

Move Selected Work before the general notebook feed. The site should demonstrate that the ideas are grounded in products and workflows before widening into the publication archive.

Cards remain derived only from published/public work content.

### 4. Fieldnotes

Show the current published notes/essays and a path to `/thinking/`. This is the ongoing notebook, not the whole identity of the site.

### 5. Trajectory

Restore the professional-depth spine as an editorial timeline.

Use only safe canonical fields:

- role
- company
- date range
- PhD foundation from canonical profile data

Do not render `data/experience.json` summary paragraphs on the homepage. The summaries contain legacy claims that are outside this redesign's evidence scope.

The visual story should make the movement legible: research foundation -> data science -> product leadership -> AI-enabled expert work.

### 6. Operating territory

Show the recurring questions that connect the work and writing. This is positioning through problems, not a list of competencies.

Use four compact territories:

- Product judgment: What deserves to exist when building gets cheap?
- Expert work: What should AI do, and what should remain inspectable?
- Verification: How do we know when generated work deserves trust?
- Operating models: When contribution broadens, who owns what?

A compact signature schematic may connect the governing shift: cheaper execution expands candidate work, which increases the importance of judgment, verification, and explicit ownership.

### 7. Context and contact

End with brief human context and low-pressure paths to About, LinkedIn, GitHub, and email where already public. No booking CTA, service menu, pricing, or consulting language.

## Scroll and motion grammar

The page remains fully readable and navigable without JavaScript.

### Chapter index

On large desktop viewports, show a restrained fixed/sticky marginal index for the seven homepage chapters. It should behave like a book's running marginalia, not application navigation.

- Each item is an ordinary anchor link.
- The current chapter receives `aria-current="location"` when JavaScript is available.
- The index disappears below the wide-desktop breakpoint rather than competing with content.
- No section is hidden, collapsed, or repositioned when the active chapter changes.

### Progressive motion

Allowed motion has an explanatory job:

- section rules can resolve from partial to full width on first entry;
- schematic connectors may animate once to show direction;
- chapter-index state can follow the reader;
- small emphasis shifts may reinforce the move from capability to human judgment.

Disallowed motion:

- parallax portrait movement;
- scroll-jacking;
- horizontal page translation;
- content starting invisible and waiting for IntersectionObserver;
- looping decorative animation;
- layout-property animation;
- motion required to understand a diagram or navigation state.

All animation must collapse under `prefers-reduced-motion: reduce`. The reduced-motion path must remain last in the final Fieldnotes CSS layer.

## Signature diagram grammar

Keep the existing visual semantics:

- paper = state or evidence;
- forest = action or tool;
- citrus = human judgment or explicit decision;
- dashed return = feedback or revision;
- text labels carry every semantic distinction so color is never the only channel.

The homepage may add a third named schematic for the abundant-execution / judgment shift. It must use the same native-HTML partial and remain legible under text zoom and narrow stacking.

## Content and voice rules

- Concrete problem territory beats generic personal-brand slogans.
- Avoid biography-first throat-clearing.
- Avoid claims of passion, innovation, transformation, or impact without a mechanism.
- Prefer questions and distinctions Athan actually returns to: user, product shape, judgment, verification, ownership, and boundaries.
- The page can be first person, but it should not narrate Athan's resume back to the reader.
- Keep existing evidence limitations intact.

## Technical architecture

Expected implementation surface:

- `layouts/index.html` - chapter structure, safe trajectory rendering, operating-territory content, marginal index markup.
- `assets/css/fieldnotes.css` - chapter layout, timeline, territory cards, index, progressive motion, responsive and reduced-motion behavior.
- `assets/js/fieldnotes-home.js` - optional IntersectionObserver enhancement for current chapter and one-time motion state. No dependencies.
- `layouts/_default/baseof.html` - fingerprinted home-only script include.
- `data/profile.toml` - canonical headline/support and explicit foundation field if needed.
- `layouts/partials/fieldnote-schematic.html` - optional third named schematic.
- `DESIGN.md`, `PRODUCT.md`, `DIAGRAMS.md`, `CLAUDE.md` - authority updates so future agents do not revert the new decisions.
- `scripts/verify-fieldnotes-home.sh` - focused rendered/source contract for the homepage.

## Accessibility requirements

- Existing WCAG 2.2 AA target remains.
- Chapter links are real anchors with descriptive accessible names.
- Current-chapter color is reinforced by text/rule state and `aria-current`.
- Focus-visible behavior remains obvious.
- Body text remains at least 16px; metadata remains at least 12px.
- No animation is required for content visibility.
- `prefers-reduced-motion` removes non-essential animation and smooth scrolling.
- Wide-only marginal navigation must not become a cramped mobile control.

## Performance requirements

- No client framework.
- No third-party scripts.
- One tiny home-only JavaScript asset, deferred and fingerprinted.
- No new font files or network origins.
- Existing Core Web Vitals gates in `PRODUCT.md` remain unchanged.

## Acceptance criteria

1. The homepage no longer renders `Try things. Keep what works.` as the primary headline.
2. The homepage chapter order is Identity -> Current idea -> Work -> Fieldnotes -> Trajectory -> Operating territory -> Context.
3. Selected Work appears before the general Fieldnotes feed.
4. The trajectory renders only safe canonical role/company/range data plus the PhD foundation, never legacy experience summaries.
5. A large-screen marginal chapter index links to every homepage chapter and is optional-enhanced with current-location state.
6. The static page is complete with JavaScript disabled.
7. Motion never gates visibility or layout and is disabled/reduced under `prefers-reduced-motion`.
8. Existing published URLs, evidence gates, book layouts, redirects, and deployment configuration remain intact.
9. Hugo production build succeeds.
10. Existing repository verification scripts pass.
11. `scripts/verify-fieldnotes-home.sh` passes against the production build.
12. Desktop visual review confirms no overlap at wide and standard desktop widths.
13. Narrow/mobile review is performed where the environment permits; if it cannot be verified, the PR says so explicitly.
14. 200% text zoom and keyboard focus are visually checked before merge.

## Verification boundary

ChatGPT can implement and source-review this change through the GitHub connection, but its current code sandbox cannot reach the repository over the network and does not have Hugo installed. Source-level contract checks can be run here; Hugo/browser verification is therefore an explicit handoff requirement rather than something to claim by inference.
