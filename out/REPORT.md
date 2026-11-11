# Hugo vs Astro for the Atlas slice: recommendation

Local draft, unpublished. 2026-11-04. Recommends only; Athan decides (see `DECISION-GATE.md`).

Labels: **[M]** measured by me, reproducible with `out/reproduce.sh`. **[I]** inspected (read, not run). **[A]** assumption or judgment.

## Recommendation

**Keep Hugo for now. Existing Hugo is sufficient for the Atlas slice. Do not migrate on the evidence in hand.** [A, resting on the measurements below]

Why, in one paragraph: I built the same slice twice (one list page with search and two filters, one project card, one detail page, 12 records). The two builds render pixel-identical list pages (detail pages match except one unexplained 30 px band at 390 px), match on all 21 compared behavior and layout keys, and both score 100 on Lighthouse and 0 on axe. Hugo did it in 75 changed lines, one edited existing file and zero new dependencies. Astro needed a new Node project and 139 MB of `node_modules`. Astro's real advantage, a declarative schema that validates records, is worth 7 hand-written lines in Hugo for this size of data.

**Migration trigger (observable, my proposed thresholds; Athan sets the final numbers).** Revisit Astro if any one of these becomes true:

1. **Interactivity outgrows one script.** An Atlas page needs 3 or more interactive pieces sharing state (for example search, a comparison tray and a graph), or the page script passes about 150 lines, or a framework component is wanted. Today it is 1 piece and 25 lines. [A]
2. **Validation outgrows templates.** Atlas gets 2 or more record types that reference each other, or the Hugo validation block passes about 50 lines, or one bad record reaches the live site. Today it is 1 type and 7 lines. [A]
3. **Prose needs components.** More than about 10 content files need interactive embeds inside the text. Today 3 content files use 2 shortcodes (`boundary-diagram`, `fieldnote-schematic`). [I, `content/`]

If none holds, the migration cost below buys nothing the slice needs.

## What was built [M]

| | Hugo slice | Astro slice |
|---|---|---|
| Base | this repo at `c48bcc36` (scratch copy), Hugo 0.154.3 (CI pin) and 0.168.0 | new project, Astro 7.4.5, Node 26 |
| Records | `data/atlas_sample.json`, 12 synthetic records | same file, loaded by a content collection |
| Pages | `/atlas/` and `/atlas/sample-alpha/` ... | same URLs |
| Shared | `records.json`, `atlas.css` (tokens only), `atlas.js` (progressive enhancement) | identical files |
| Code | `out/prototypes/hugo-slice.patch` | `out/prototypes/astro/` |

The records are synthetic because the records step is not finished. Sample slice, labelled as such.

## Evidence

### Same result, both stacks [M]

| Check | Hugo | Astro |
|---|---|---|
| Items rendered with JS off | 12 | 12 |
| Search "alpha" / tag "essay" / nonsense | 1 / 2 / 0 + empty state | 1 / 2 / 0 + empty state |
| Domain=Data / +Status=Shipped / + search "metrics" | 3 / 2 / 1 | 3 / 2 / 1 |
| Reset | 12 | 12 |
| Tab order (8 stops) | identical | identical |
| axe (wcag2a/aa/21aa + best-practice), list and detail | 0 violations | 0 violations |
| Lighthouse (1 run per page) | 100/100/100/100 | 100/100/100/100 |
| Horizontal overflow at 390 px, and at 720 px (200% zoom stand-in) | none | none |
| Screenshot pixel diff: list 1440 and 390, detail 1440 | 0 differing pixels | 0 differing pixels |

Detail at 390 differs in a 30 px band of the nav row; I did not find the cause (possibly font-swap timing). The Astro footer is simplified on purpose (no email or LinkedIn links), so detail pages were compared above the footer. Details: `evidence/results.json`, `evidence/pixel_diff.txt`, `evidence/lighthouse_summary.txt`, `evidence/screens/`.

### Where they differ [M unless marked]

| Dimension | Hugo | Astro | Tradeoff |
|---|---|---|---|
| Change size | 75 lines authored, 6 files, 1 existing file edited (`baseof.html`, +8) | 167 lines authored, 10 files, all new; 87 of them are slice-specific (config, schema, 2 pages, 1 card), the rest is layout, nav, RSS, sitemap, robots that Hugo already has | Hugo is cheaper only because the site shell exists. Slice-only, the two are close (75 vs 87). |
| Dependencies | 0 new | 2 direct, 165 top-level packages, 139 MB `node_modules`, 3,891-line lockfile; needs Node 22.23.4 or newer | Real cost to carry and update. |
| Build time | median 0.30 s for the whole 64-page site (5 runs, cache cleared) | median 9.96 s for 13 pages (5 runs, cache cleared, range 4.0 to 15.1 s; noisy) | Hugo is far faster. Astro warm builds I saw were 1.0 to 3.5 s (single runs, not controlled). Neither is a problem at 12 records. |
| Output | 1,020 KB for whole site | 176 KB for the slice | Not comparable (whole site vs slice). |
| Page weight, list page, gzip | HTML 2,366 B, CSS 7,731 B, JS 354 B (707 B raw, separate file) | HTML 2,151 B, CSS 7,755 B, JS inline in the HTML (823 B raw) | Equal in practice. |
| Content validation | hand-written, 7 lines in the adapter; each check is written by you. Bad domain, missing field, string year each failed the build with the record id and the problem | declarative zod schema (~11 lines); same three cases failed the build, naming the record and field; also gives TypeScript types | Astro is better when records grow. At 12 records and 5 fields the gap is small. Astro stopped at the first bad record in each test. |
| Gotcha found: Hugo | A page param named `status` collided with the site's publish gate (`Params.status == "published"`), so the cards were silently dropped from the sitemap until I renamed it | | Hugo params share one namespace with site rules. |
| Gotcha found: Astro | `<script slot=... src=...>` is not bundled and shipped a broken relative path; fixed with a processed `<script>` block | | Easy to hit, easy to fix. |
| Side effect of adding the section | Hugo auto-added 12 items to the live `/index.xml` (30 to 42) and a new `/atlas/index.xml` | Nothing is added until you write it | In Hugo the real Atlas needs an explicit feed decision. For Astro, the feed and sitemap must be rebuilt at the same URLs. |
| URL, RSS, sitemap compatibility | `/index.xml`, `/sitemap.xml`, trailing-slash URLs exist today | Matched: same `/atlas/<slug>/` URLs, `/index.xml` (14 lines) and `/sitemap.xml` (7 lines) as hand-written endpoints, `robots.txt` carried over. The sitemap integration emits `sitemap-index.xml`, a different URL from the one `robots.txt` names, so I did not use it | Compatible, but you write what Hugo gives free. |
| Redirects | 24 stubs from `data/redirects.toml` through a content adapter | Config `redirects` produced the same meta-refresh stubs; tested 2 of 24 | Not a blocker. |

### Whole-site migration, inspected not built [I]

34 layout files (1,344 lines of Go templates) to rewrite as `.astro`; 5 shortcodes (used in 3 content files) need MDX or a rewrite; `themes` taxonomy (3 terms) needs hand-built routes; 6 verify scripts (1,242 lines, with Hugo-specific checks such as fingerprinted CSS names and template text) need rewriting; `deploy.yml` swaps the Hugo action for Node setup and `npm ci`; Hugo Pipes SRI hashes on CSS and JS have no default Astro equivalent. I give no hour estimate because I did not build any of it; the counts above are the estimate.

## Not covered, so unproven

- Next.js not compared (no concrete requirement found; adding it is Athan's call).
- Client search over a large index. 12 records tell nothing about 1,000. Pagefind or similar might work with either generator; not tested.
- Real records: the slice used synthetic ones, so field shapes may differ from the final schema.
- Screen reader, real-device mobile, Safari and Firefox: not tested. Chromium only; axe is automated only.
- Lighthouse and timings: one run each, local server, no compression. Do not rank on them.
- Hugo checked on 0.154.3 and 0.168.0 (`evidence/hugo_pinned_version_check.txt`); Astro on 7.4.5 only.
- Long-run maintenance cost of Astro's release pace: not measured.

## Reproduce

`out/reproduce.sh` (needs hugo, node 22.23.4+, npm, uv). It builds both slices from a clean `git archive` of this branch and runs `out/measure/probe.py`; I ran it from a clean archive and every probe key matched the recorded run. `out/measure/build_metrics.sh <hugo_dir> <astro_dir>` reproduces timings and sizes on scratch copies.
