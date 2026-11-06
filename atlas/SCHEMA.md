# Systems Atlas record format (draft, `atlas-record/1`)

One plain TOML file per record in `atlas/records/`. No database, no paid API, no build step:
edit with any text editor, validate with `python3 atlas/validate.py atlas/records` (Python 3.11+
standard library only). Hugo can read the same files later (`data/` or a content adapter); this
format does not depend on any site stack.

All records are **draft candidates**. Nothing here is published.

## Identity

- `id` = `github:<owner>/<repo>`, lowercase. It is the only identity. The file name is
  `<owner>--<repo>.toml` (lowercase) and must match `id`.
- `canonical_url` = `https://github.com/<owner>/<repo>` and must resolve to the same
  owner/repo as `id` (case-insensitive). Two records with the same `id` fail validation.
- The validator checks identity across the whole set, so duplicates fail even if file names differ.

## Fields

| Field | Type | Rule |
|---|---|---|
| `schema_version` | string | `atlas-record/1` |
| `id`, `canonical_url`, `title` | string | see Identity |
| `repository_owner`, `repository_name` | string | match `id` (case-insensitive) |
| `date_observed` | string | `YYYY-MM-DD`, `YYYY-MM-DD/YYYY-MM-DD`, or the literal `date_not_recovered` |
| `topic` | string | one of the topic list in `validate.py` |
| `mechanism` | string | the architectural mechanism, stated from cited facts |
| `license_spdx` | string | SPDX id read from the upstream repository, `NOASSERTION`, or `none` |
| `license_note` | string | required when `license_spdx` is `NOASSERTION` or `none` |
| `evidence_state` | string | `inspected`, `evaluated`, `tested`, `adopted` (see below) |
| `evidence_note` | string | required for `evaluated`, `tested`, `adopted`: what was done and where the result lives |
| `status` | string | `candidate` or `reviewed`. `reviewed` additionally needs `reviewed_by` and `reviewed_on` |
| `last_review_date` | date | last date the upstream repository was checked against this record |
| `editorial_review` | string | `pending` until a human approves |
| `unavailable` | array of string | fields or evidence deliberately not available (for example `tested`) |
| `[opinion]` | table | `value_judgment` (text) and `limitations` (array, at least one). Editorial, not fact. |
| `[provenance]` | table | `seed_pointer`, `discovery_dates`, `source_types`, `visibility = "public"`, `private_text_included = false` |
| `[[sources]]` | array | public citations: `url` (https), `kind`, `accessed` |
| `[[facts]]` | array | verifiable claims: `claim` and `source_url`. `source_url` must appear in `[[sources]]` |

## Evidence states (never upgrade without evidence)

- `inspected`: someone read the upstream repository page, README or license. Says nothing about whether it works.
- `evaluated`: compared against a stated criterion or alternative, with the comparison written down.
- `tested`: run, with the command and outcome recorded in `evidence_note`.
- `adopted`: in use in a real workflow, with where recorded in `evidence_note`.

## Fact versus opinion

- `[[facts]]` hold only what an upstream page states. Each cites a source. Vendor marketing numbers
  (stars, user counts, benchmark scores) are not facts here.
- `[opinion].value_judgment` is editorial. It is never cited as a fact and never claims an
  experiment.

## Private material

A record points at its source discussion with `provenance.seed_pointer` and never quotes it.
No employer material, personal confidences, private repository details, or conversation text.
The validator scans every string for a deny-list (employer names, internal hosts, emails,
credential-looking tokens) and fails on a hit. The deny-list is a floor, not a review.
