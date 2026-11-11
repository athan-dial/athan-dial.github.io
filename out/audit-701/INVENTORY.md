# AOPS-701 baseline: Personal Fieldnotes, Craft Anything, Nima Radar

Local draft, unpublished. Date 2026-11-04. Labels on every claim: **[I]** inspected (source named), **[A]** assumption. Nothing in either site was modified; no code, text, brand or asset from Nima's site or repo appears here (behavior and architecture notes only, in my own words).

## 0. Inspected-file index (R1)

| Repo / URL | Path or page | Revision |
|---|---|---|
| github.com/athan-dial/athan-dial.github.io (public) | `CLAUDE.md`, `DESIGN.md`, `PRODUCT.md`, `DIAGRAMS.md`, `config/_default/hugo.toml`, `config/_default/menus.en.toml`, `.github/workflows/deploy.yml`, `layouts/index.html`, `layouts/partials/fieldnote-schematic.html`, `data/profile.toml`, `content/**`, `scripts/*.sh`, `assets/css/*`, `assets/js/fieldnotes-home.js` | worktree base `c48bcc365ea932078829d6f35f491846204e9d78`; remote `main` is `3640e693cce18e834b0295ae316d89193c80a287` (differs, see section 1) |
| https://athan-dial.github.io (live) | `/`, `/index.xml`, `/sitemap.xml`, `/thinking/` (HTTP status only) | fetched 2026-11-04 |
| github.com/nimaaksoy/nimaaksoy.com (public) | `docs/RADAR.md` (read in full), `LICENSE` (header), `package.json` (head), `lib/radar.ts` (export list); `lib/radar-shared.ts`, `app/radar/page.tsx`, `app/radar/[slug]/page.tsx` sized and listed only, not read | `ac0cd31f30e4a657fb6b3cca91e4c6705f40056c` (shallow clone in a scratch dir outside every repo) |
| github.com/storytold/craft-anything (public) | `README.md`, `docs/STATUS.md` (sampled), `Cargo.toml` (fields), tree listing | `078cf0c4842c72d0b3d86a8c208515e2223510cc` (shallow clone in the scratch dir) |
| https://nimaaksoy.com/radar and one item page (live) | feed, search, filter, detail, navigation at 1440x900 and 390x844 | observed 2026-11-04 |

## 1. Personal Fieldnotes baseline (R3)

| Entry | Finding | Label, source |
|---|---|---|
| Site URL | https://athan-dial.github.io/ (`baseURL`); `/`, `/thinking/`, `/index.xml`, `/sitemap.xml` return 200 | [I] `hugo.toml`; curl |
| Generator | Hugo 0.154.3 extended, themeless, custom layouts, empty module config | [I] `deploy.yml`, `CLAUDE.md`, `module.toml` |
| Build | `hugo --gc --minify` built 18 content pages in about 0.5 s into a scratch dir; `scripts/verify-fieldnotes-home.sh` PASS (rendered checks skipped, no `public/`) | [I] local run |
| Deployment | GitHub Actions on push to `main` (and manual dispatch): build, `scripts/verify-build.sh`, upload `public/`, `actions/deploy-pages`; `public/` is gitignored | [I] `deploy.yml` |
| Branch state | Audit worktree base is behind remote `main`; the live site may differ from what I inspected | [I] git; live difference [A] |
| SEO | Per-page title, description, canonical, Open Graph, favicon set, manifest, JSON-LD `ProfilePage` on home; `robots.txt` allows all and disallows two retired paths; sitemap lists 15 URLs | [I] built `index.html`, `robots.txt`, `sitemap.xml` |
| RSS | `/index.xml` RSS 2.0, 30 `<item>` entries, site-wide only | [I] built `index.xml`; the 30 count may include repeated entries [A] |
| Design system | "Personal Fieldnotes": tokens in `tokens.css`, shared `fieldnotes.css`, home-only `fieldnotes-home.css`, self-hosted Archivo and IBM Plex Mono, serif display, forest accent, citrus markers, light only, flat; optional JS for chapter index only | [I] `DESIGN.md`, `assets/` |
| Content | 2 essays, 1 note, 2 work pages; `/thinking/` lists them plus a LinkedIn block; `/themes/` taxonomy pages (3 terms) are built; resume and old trees are redirect stubs or drafts | [I] `content/`, built output |
| Navigation | Work, Fieldnotes (`/thinking/`), About | [I] `menus.en.toml` |
| Tests | No test files in the repo; verification is the six shell scripts in `scripts/` (build, home, redirects, render, content-safety, publish gate) | [I] `git ls-files`, `scripts/` |
| Site constraints | Pages must be complete with JS off; no client framework, no third-party embeds or external fonts; never animate layout; no dark mode; flat light surfaces; new content needs source-backed authorship (content-safety contract); no personal data in published files | [I] `CLAUDE.md`, `DESIGN.md` |
| Browser state | One narrow-viewport screenshot of home and `/thinking/` taken; desktop, 200% zoom, JS-off and keyboard checks not run (not required by R3) | [I] evidence folder |

## 2. Craft Anything (repository identity and behavior)

- **Identity [I, decision by Athan 2026-11-04]:** `storytold/craft-anything` is the Craft Anything repository. Source of the identification is Athan's confirmation, not a C1 search: the C1 search (this repo, local clones under `~/Github` and `~/GitHub`, the 40 public `athan-dial` repos) found no match. No private repository was searched.
- **Inspected [I]:** public shallow clone, revision `078cf0c4842c72d0b3d86a8c208515e2223510cc` (2026-11-04), in a scratch dir outside every repo of ours. Read-only; no code or text copied. Paths read: `README.md` (overview, how-it-works, license sections), `docs/STATUS.md` (feature table, headings only sampled), top-level tree and `crates/`, `apps/`, `docs/`, `packaging/` listings, `Cargo.toml` (name, version, license, repository fields).
- **License [I]:** MIT OR Apache-2.0 (permissive, `LICENSE-MIT`, `LICENSE-APACHE`). Different from Nima's PolyForm Noncommercial. Reuse terms for this repo are not assessed here beyond the stated license; a font and icon asset set ships with its own license files [I, file listing].
- **What it is [I, README]:** an open-source engine written in Rust (version 0.4.0, status early alpha) with a desktop app, a CLI and a web app. A person points it at a website, app or game, says what they want, and it runs four steps: study the original, have a coding agent build a new project, check the build against the original, then refine. It has a clean-room mode (default) and a deep mode, an MCP crate, and a pluggable rebuild workflow (kinds, checks, stacks) documented in `docs/extending.md`.
- **Structure [I, tree listing]:** `apps/` (desktop, CLI, web), `crates/` (ai, analysis, disasm, engine, engines, evidence, formats, js, mcp, platform, setup, testkit, ui-egui), `docs/`, `examples/` (two sample plugins), `packaging/` (per-OS), `xtask/`, `vendor/`.
- **Behavior relevant here [I, README and STATUS]:** the website path compares a start page and up to 12 linked pages at configured widths and lists what still differs; the project view shows per-check similarity and an approval step for anything outside the rules. It is an agent-driven rebuild tool, not a content site or a feed.
- **Not done [A]:** I did not build or run it, did not read its source files, and did not test any claim in the README. Its fit as a "workflow" for Fieldnotes is an assumption; the ticket does not say what role it plays beyond being named.
- **Boundary risk [A]:** a tool whose job is to recreate a site from its public pages could, if pointed at Nima's Radar, produce a derivative of PolyForm-licensed work. Under C2 it must not be run against nimaaksoy.com or its repo for any output that enters a repository, site or public artifact. Using it on Fieldnotes' own pages or on a spec written in our own words is not restricted by C2.

## 3. Nima's Radar behavior (R2)

Measured with Playwright (Chromium) at 1440x900 and 390x844 (touch), because Orca's browser pane cannot be resized past about 639 px wide; Orca's iPhone 12 emulation changed the viewport to 390 but resets on a new tab. Orca-captured 639 px screenshots are labelled "narrow", not phone. Screenshots are in a local folder outside every repo, never committed.

| Area | Desktop 1440 | Mobile 390 | Label, evidence |
|---|---|---|---|
| Feed layout | One card per row, 1100 px wide; image block about 26% of card width, beside the text | Card 358 px wide; image about 91% of width, stacked above text | [I] DOM measurement; `radar-desktop-feed.png`, `radar-mobile-feed.png` |
| Feed volume | 139 projects, 50 per page, 3 pages, paging links | same | [I] page text, link list |
| Page overflow | No horizontal scroll | No horizontal scroll | [I] scrollWidth check |
| Per-card parts | Date, title, verdict badge, capability badges, short summary, collapsible rationale, tags, related items, links to the item and its source, share row | same stacked | [I] screenshots, DOM |
| Collapsible rationale | Toggles open inline | Toggles open inline | [I] click test |
| Toolbar | Sticky bar with search plus chip row; a second sticky side element exists, purpose not determined | Sticky bar; chip row scrolls sideways | [I] computed position; side element purpose [A] |
| Search | Typing a term cut 139 to 40 and updated the count and cards; a nonsense term gave 0 with an empty state and a reset control; URL did not change | same | [I] `radar-*-search.png`; searches all pages not only the visible one [A, inferred from 40 results vs 50 per page] |
| Filter and sort | Verdict, capability and sort chips; the top verdict chip gave 82 of 139; changing sort changed the first card; URL did not change | same | [I] `radar-*-filter.png`; chips hide when no data, as RADAR.md states [A, not tested] |
| State in URL | Search and filter state is not in the URL, so a filtered view cannot be linked | same | [I] URL check; consequence for sharing [A] |
| Detail page | Opened from the card's item link to `/radar/{slug}`; own title, canonical URL, per-item social image route; back link to the feed; source link, related-item links and share actions; browser Back returns to feed | same, no overflow | [I] `radar-*-detail.png`; section wording documented in RADAR.md, not independently verified [A] |
| Navigation | Top bar with nine links to the site's sections, the feed, and the repository | Collapsed behind a menu button; opens an overlay containing the same destinations | [I] DOM, `radar-mobile-menu.png` |
| Promo strip | Three promotional links above the feed on both sizes | same | [I] screenshot |
| Content store | One JSON file per day (105 files), flattened newest-first, slug unique across days; weekly generated star-count file | n/a | [I] `docs/RADAR.md`, directory listing |
| Editorial rules | Short summary plus separate rationale; verdict taxonomy; share captions kept in data and not shown on page; English only | n/a | [I] `docs/RADAR.md` |
| JS-off, keyboard, performance | Not tested | Not tested | [A] none stated |

## 4. Reuse, boundary, constraints, integration path (R4)

- **Capabilities worth reusing as ideas [A, derived from sections 1 and 3]:** dated item feed with newest first; verdict taxonomy; short summary plus optional rationale; client search and filter with a live count and empty state; per-item page with its own social image; share actions fed from stored captions.
- **License boundary [I]:** the Radar repo is PolyForm Noncommercial 1.0.0 (Required Notice names Nima Aksoy). Study behavior and architecture only. No code, branding, content or assets may be copied into any repository, site or public artifact. Screenshots stay private audit evidence outside every repo.
- **Site constraints [I]:** section 1 constraints; in particular a feed must render fully with JS disabled, with search and filter as progressive enhancement, and no third-party embeds.
- **Non-copying integration path [A]:** build the feed from Fieldnotes' own content and own data, write original templates, styles and any small script against the existing design tokens, and implement only the behaviors in section 3 described in terms of observed outcomes. Nothing from the Radar repo is imported, vendored or translated line by line. Choosing between this path and a different stack is AOPS-703 and AOPS-704, not decided here.
- **Minimum acceptance slice [A]:** a locally built page that lists dated items newest first with a count, offers search and one filter with an empty state, links each item to its own page, and works with JS off for the list and detail. No deployment. "Atlas" is not defined in the material I was given, so the slice is stated without it.
- **Blockers [I/A]:** (1) Craft Anything's role in the epic is not stated in the ticket, so how it feeds the integration path is open (section 2); (2) audit base differs from remote `main`, so the baseline needs a refresh before AOPS-703 compares; (3) content-safety contract requires source-backed authorship for any new content; (4) Hugo has no built-in client search, so the search behavior needs original script work [A].

## 5. Decisions (Athan, 2026-11-06)
1. Craft Anything (`storytold/craft-anything`) is a study target only. It is not a build tool and not a dependency of the site.
2. The Nima Radar is never used as input to Craft Anything.
