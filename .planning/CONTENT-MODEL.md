# Content model

Canonical collections and frontmatter for the Editorial Systems rebuild.
Implements the REDESIGN-PLAN content types and the publish gate:
**exclude anything that is not explicitly `status: published` and `visibility: public`.**

Open tools (`docs/skills/**`, generated via `scripts/fetch-skills.sh`) are **not** a
Hugo collection. About remains a standalone page (`content/about.md` / future
`content/about/`); it is a content type in the IA, not a collection archetype here.

**About renders through `layouts/_default/about.html`**, selected by `layout: about` in its own
front matter (2026-09-10). It is the only page in the repo that composes structured data —
`data/profile.toml`, `data/experience.json` role fields, `data/education.json`,
`data/publications.json` — into reader-facing sections. Its front matter therefore carries
content-bearing keys that no collection archetype has: `trajectory`, `selected_research` (DOIs
resolved against the publication record at build time), `research_note`, `territory`,
`territory_standfirst`, `conversations_intro`, `conversations_note`. Sections 1 and 2 of the page
stay as markdown body prose. See `.planning/specs/2026-09-10-personal-brand-proof-layer-design.md`.

`content/skills/` **no longer exists** (2026-09-10). Both its files were quarantined fixtures, and
deleting only `_index.md` was not safe: that file's `build.render: never` was what let the
`/skills/` redirect stub own the route, so removing it while leaving
`content/skills/case-studies/_index.md` behind made Hugo generate a section index for the
parentless branch, and a real "Skills" page took the route back from the adapter. All five
`/skills/*` routes are now owned solely by `data/redirects.toml`. Same story, same fix, for
`content/writing.md` and `content/advisory.md`: the adapters already won those routes, the files
were dead weight pointing at retired `/case-studies/` URLs.

---

## Content types

| Type | Path | Job |
|---|---|---|
| **Work** | `content/work/` | Evidence-validated product narratives and selected product systems. |
| **Essays** | `content/essays/` | Cornerstone and practice point-of-view pieces (Thinking). |
| **Notes** | `content/notes/` | Field Notes — concise practice observations; Agency migrations land here. |
| **About** | `content/about*` | Trajectory, principles, interests, conversations (not a collection). |

Create new items with:

```bash
hugo new work/my-case.md
hugo new essays/my-essay.md
hugo new notes/my-note.md
```

---

## Frontmatter contract

### Shared (work, essay, note)

| Field | Allowed values | Default (safe) |
|---|---|---|
| `title` | string | from filename |
| `type` | `work` \| `essay` \| `note` | per archetype |
| `date` | date | creation time |
| `summary` | string | `""` |
| `status` | `draft` \| `published` | `draft` |
| `visibility` | `private` \| `public` | `private` |
| `themes` | list from controlled taxonomy (below) | `[]` |
| `draft` | `true` \| `false` (Hugo native) | `true` |

### Work only

| Field | Allowed values | Default (safe) |
|---|---|---|
| `evidence_status` | `needs-verification` \| `verified` \| `range-only` \| `mechanism-only` | `needs-verification` |
| `employer_review` | `pending` \| `cleared` \| `n-a` | `pending` |
| `featured` | bool | `false` |
| `role` | string | `""` |
| `users` | list of strings | `[]` |
| `canonical_url` | string (URL) | `""` |
| `work_kind` | `flagship` \| `proof-note` \| `quarantined` | unset (renders as a case) |
| `narrative_voice` | `documentary` | unset |
| `card_ownership` | string | `""` |
| `card_measured` | string | `""` |
| `card_unmeasured` | string | `""` |

`work_kind` names the DEPTH of the piece, added 2026-09-10 by the content pass. It is not a
category or a tag; it is a claim about how much of the decision the page traces.

| Value | What it means | How it renders |
|---|---|---|
| `flagship` | The full case: user, constraint, what was already possible, the boundary, the hard choice, ownership, what changed, what I would change. Roughly 1,400 words. | Under **Cases** on the index. No badge — full depth is the default. |
| `proof-note` | One artifact, one decision, one boundary. Roughly 900 words. Narrower on purpose. | Under **Proof notes**, with a "Proof note" badge and a line on the article saying it is shorter by design. |
| `quarantined` | The framing did not survive source review. Kept in the repo as a record, never published. | Never on the index. The article says it is withheld. |
| unset | A page predating the field. | Renders with the cases, so nothing falls out of the index for lacking a field. |

Two render rules follow from this and are enforced by `scripts/verify-proof-layer.sh`:

1. **A group with no published items does not render.** An empty "Proof notes" heading
   advertises a shelf with nothing on it, which is the under-filled-archive failure the
   whole pass exists to avoid.
2. **A proof note must be labelled.** Unlabelled, a 900-word piece next to a 1,400-word
   case reads as a case that ran out of material. The badge is the difference between
   "narrow on purpose" and "thin".

### The in-review shelf is gated on the build, not on the content

`layouts/work/list.html` renders a list of gated pieces (`work-index__review`) when
`site.BuildDrafts` is true — that is, under `hugo server -D` or `hugo -D`, never under a
production `hugo --gc --minify`.

It exists because the review loop had a hole. New stories are deliberately
`draft`/`private`, and the Work index filters on published AND public, so even a `-D`
preview showed the published cases and no proof-note group: the shape of the finished page
could not be reviewed without first publishing the prose, which is backwards. The shelf
shows what is queued and at what depth, and renders titles and classifications only — no
summaries, no ownership fields, no bodies.

Keying it to the build mode rather than to `status` is deliberate: it cannot leak even if
a page's own flags are wrong. `verify-proof-layer.sh` asserts it is absent from production
output.

The three `card_*` fields are optional and drive the Work index evidence ledger (2026-09-10).
Each one must be a **compression of that page's own body** — `card_ownership` from its "My
ownership" section, `card_measured` and `card_unmeasured` from "What changed". They exist so a
reader sees the evidence model before opening a case. A `card_*` value that states more than the
body states is a content-safety breach, not a copywriting liberty. `card_unmeasured` is the one
that matters most: an empty value on a case that never instrumented its outcome reads as a
concealment, which is exactly what CONTENT-SAFETY-CONTRACT.md's "`NO RECORD` gets said out loud"
rule forbids.

Work body skeleton, documentary voice (2026-09-10): **BLUF** → **Who was doing the work** →
**What was already possible** → **The product boundary** → **The hard choice** →
**Role in the case** → **What changed** → **Retrospective**.

Two headings were renamed by the documentary-voice pass, and the rename carries the whole
rhetorical rule:

- **"Athan's ownership" / "My ownership" → "Role in the case."** Ownership is still stated
  explicitly and in full; it is simply no longer stated by making "I" the grammatical
  subject. Fieldnotes says *here is how I think*; Work says *here is what happened*.
- **"What he would change now" → "Retrospective."** This is the one section where first
  person is allowed, because hindsight is genuinely personal. It is last in every
  narrative.

A proof note uses a shorter version of the same grammar — its middle sections are named for
the specific artifact — but `Role in the case` and `Retrospective` are common to both
depths.

`scripts/verify-documentary-voice.sh` enforces this at source: the narratives must declare
`narrative_voice: documentary`, must use `Role in the case` rather than a first-person
ownership heading, and must keep first-person singular confined to a sparse retrospective.

`assets/css/fieldnotes.css` marks the retrospective with a citrus rule, keyed to Hugo's
auto-generated `#retrospective` id. Unmarked, the shift into first person on the final
section reads as the voice slipping rather than as the one place it is permitted. That
selector reaches the sibling paragraphs after the heading and relies on Retrospective being
last; adding a section after it is the one change that would need it revisited.

### Essay only

| Field | Allowed values | Default (safe) |
|---|---|---|
| `tier` | `cornerstone` \| `practice` | `practice` |
| `canonical_url` | string (URL) | `""` |

Reading time is computed in the template — do not store it in frontmatter.

### Note only

| Field | Allowed values | Default (safe) |
|---|---|---|
| `source_url` | string (URL); set when migrating from Agency | `""` |

### Controlled `themes` taxonomy

Only these slugs:

- `expert-workflows`
- `product-judgment`
- `reliable-ai-systems`

Registered in `config/_default/hugo.toml` as `theme = "themes"` alongside `tags` and `categories`.

---

## Evidence status ↔ claim classification

Maps `evidence_status` to the REDESIGN-PLAN four-way claim gate:

| `evidence_status` | Plan classification | Meaning |
|---|---|---|
| `verified` | **Public and verified** | Safe to publish with a source or internal confirmation. |
| `range-only` | **Publishable in a range** | Exact number redacted; directional evidence retained. |
| `mechanism-only` | **Publishable as mechanism only** | Decision/system without program names or metrics. |
| `needs-verification` | **Private** (until reclassified) | Not cleared for the public site; default for new work. |

`visibility: private` is the hard public-site kill switch regardless of evidence ladder.
`employer_review` must be `cleared` or `n-a` before a work piece is treated as launch-ready
(process gate; Hugo still keys off `draft` / `status` / `visibility`).

---

## Exclusion mechanism

**Choice: `buildDrafts = false` + `draft: true` convention** (not cascade `build.render: never`).

Hugo cannot filter on arbitrary frontmatter predicates. We therefore:

1. Keep **`buildDrafts = false`** in `config/_default/hugo.toml` (production / bare `hugo` builds).
2. Default every new item to **`status: draft`**, **`visibility: private`**, and **`draft: true`** via archetypes.
3. **Cascade** the same safe defaults from each section `_index.md`, scoped with `_target: kind: page` so the section index itself still publishes for Wave 1 templates. (Without `_target`, Hugo 0.154 applies cascaded `draft: true` to the defining section page too, and the index never ships.)
4. **Publish rule:** set `status: published`, `visibility: public`, **and** `draft: false`. All three are required. If `status` is `draft` or `visibility` is `private`, keep `draft: true`.

**Why not cascade `build: { list: never, render: never }`?** That pattern is used to quarantine the old `case-studies/` tree permanently. For the new collections we need local draft preview (`hugo server -D`). `build.render: never` would hide pages even with `-D`. The draft flag is the Hugo-native lever that matches “preview drafts locally, never ship them.”

### The convention is enforced, not trusted

The invariant is: **every page with `status != published` or `visibility != public` must have
`draft: true`.**

Convention alone does not hold it. A page's own `draft: false` **overrides the section cascade**, so
a single wrong field publishes private content *and* lists it in the sitemap. Verified 2026-08-11:
a test file with `status: draft`, `visibility: private`, `draft: false` rendered to
`/work/_zz-gatetest/` and appeared in `sitemap.xml`.

`scripts/verify-build.sh` therefore asserts the invariant and **exits 5** naming the offending
files. The guard runs locally and as a gate in `.github/workflows/deploy.yml`, so a breach fails
the build instead of shipping. Pages that declare neither `status` nor `visibility` are out of
scope (the pre-existing pages and the quarantined `case-studies/` tree, which uses
`build.render: never` instead).

Re-verify the enforcement after changing the gate:

```bash
printf -- '---\ntitle: "T"\nstatus: draft\nvisibility: private\ndraft: false\n---\nx\n' \
  > content/work/_zz.md
bash scripts/verify-build.sh; echo "expect 5, got $?"
rm content/work/_zz.md
```

---

## Local draft preview

```bash
hugo server -D
```

| | Production build (`hugo` / CI) | `hugo server -D` |
|---|---|---|
| `draft: true` | **Excluded** — no page, no sitemap entry | **Included** — browseable locally |
| `status` / `visibility` alone | Not read by Hugo; only matter via the `draft` convention | Same |
| Section indexes (`work/`, `essays/`, `notes/`) | Rendered (they are not drafts) | Rendered |

`-D` does **not** write `docs/`. For throwaway production-shaped builds use:

```bash
hugo --gc --destination /private/tmp/hugo-guard
```

Never clear `docs/` — `docs/agency/**` has no regenerable source in this repo.
