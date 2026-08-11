# Content model

Canonical collections and frontmatter for the Editorial Systems rebuild.
Implements the REDESIGN-PLAN content types and the publish gate:
**exclude anything that is not explicitly `status: published` and `visibility: public`.**

Open tools (`docs/skills/**`, generated via `scripts/fetch-skills.sh`) are **not** a
Hugo collection. About remains a standalone page (`content/about.md` / future
`content/about/`); it is a content type in the IA, not a collection archetype here.

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

Work body skeleton (8 parts): **BLUF** → **Who was doing the work** → **What was already possible** → **The product boundary** → **The hard choice** → **Athan's ownership** → **What changed** → **What he would change now**.

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
