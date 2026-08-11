# Evidence decisions — publishable summary

**Last updated:** 2026-08-11

This file is **safe for a public repo**. It records the *decisions* that came out of the evidence
work, with no internal program names, tool codenames, document IDs, chat permalinks, colleague
attributions, or unpublished metrics.

The supporting detail — claim-by-claim sources, epistemic labels, sensitivity labels — lives in
`.planning/private/` (gitignored, never commit). If you are an agent working on content, read the
private files for specifics and keep anything you write here at this level of abstraction.

## How claims are labelled

Every claim in the private ledger carries an epistemic label and a sensitivity label:

- Epistemic: `MEASURED` · `ESTIMATED` · `TARGET` · `INFERRED`
- Sensitivity: `PUBLIC` · `INTERNAL` · `LIKELY-CONFIDENTIAL`
- `NO RECORD` means the search did not establish the fact. It is a finding, not a failure, and it is
  publishable as candour.

The single most important distinction is **`TARGET` vs `MEASURED`**. The quarantined case studies
published PRD targets and OKR goals as if they were results. That is the specific failure this
whole gate exists to prevent.

## Settled — safe to publish

| Fact | Note |
|---|---|
| PhD, Medical Sciences, McMaster University, 2017–2021 | Dissertation title verified against the public institutional repository. The site previously described this work as something it was not; corrected in `data/education.json`. |
| 14 DOI-bearing publications; 9 first or sole author | All public. Seven full journal/review articles, six conference abstracts, one protocol. **State the category and denominator** — the count is 7, 13, or 14 depending on what is included. Currently surfaced nowhere on the site. |
| Associate Director role dates from 2026 | Publicly announced by Athan in April 2026. `data/experience.json` previously dated it 2025. |
| Public role wording: "Associate Director, Data Science & Product Management" | This is Athan's own public self-description and is what the site uses. The employer's internally-announced functional title differs and is `INTERNAL` — do not publish it. |
| Prior employer and the role before it | Verified from public records. Exact legal entity suffix and start/end months are `NO RECORD`. |

## Retired — do not publish

| Framing | Why |
|---|---|
| The sourcing-cycle "long baseline → short target" reduction | The target was a promised turnaround, never an achieved cycle time, and the baseline was averaged without a stable clock definition. Even the start of the clock was contested on the record. **No consistently instrumented baseline exists.** Retire the result framing entirely; the honest-measurement problem is a strong essay instead. |
| "Three billion compounds" as a capability | It is an `INFERRED` ceiling and appears elsewhere as a target. A conservative range is supportable; the headline number is not. |
| A former job title used on the résumé and site | Appears only in self-authored records. No employer announcement, compensation notice, or directory entry uses it. Removing it was the evidence-conservative call. |
| Any PRD or OKR figure presented as an outcome | Every number in the relevant product requirements document is a target or success criterion. |

## Viable work stories

Three are viable. Nothing was manufactured to reach a number.

1. **The analog-search product story — viable, and better than expected.** The gap was "no measured
   post-launch outcome." There *is* one: a substantial, measured latency improvement after an
   implementation change. What does **not** exist is adoption, coverage, or a scored objective —
   all `NO RECORD`.
   The more interesting finding is that the honest arc is not a triumph. After launch the primary
   expert user reported the tool returning *fewer* results than a commercial alternative and wanted
   more coverage. Athan's own read was that this was a perception problem about completeness rather
   than a relevance problem, and the proposed response was a UX change, not a parity chase. **That
   tension is the case study** — it is a far better product-judgment artifact than "we shipped it and
   it was fast," and it needs no confidential number to land.

2. **The internal platform story — viable, with corrections.** Two claims previously believed do not
   survive: a specific milestone count in a specific timeframe, and a requirements-met ratio. Both
   `NO RECORD`. Production shipped in a verifiable ~3-week window, months later than an earlier
   attempt that failed on a permissions boundary during deploy. One design invariant central to the
   story was **designed and deferred, not implemented** — say "planned," never "built."

3. **The data-lineage incident — viable and nearly complete.** A one-character naming error
   propagated through several layers to a small real purchase cost. Mechanism fully documented end to
   end, including how it was detected and fixed. Two precision corrections: the cost is approximate,
   not exact; and the early count of *affected* items and the final count of *purchased* items are
   different denominators and must not be presented as one number.

**A fourth candidate is the best-evidenced of all** and was not previously on the list: a
procurement-attrition funnel where the denominator, every stage, the source table, and the
measurement window are all recorded. It is the only candidate with a genuinely measured end-to-end
rate. It is also the most confidentiality-dense, so it needs the heaviest abstraction — but
mechanism-plus-ratio is publishable without absolute figures.

## The strongest argument Athan already owns

The closest thing to a real field argument in the record is already **public**, in his own words: a
claim that model access is table stakes and durable advantage accrues to the surrounding operating
layer — workflows, human-in-the-loop design, and institutional knowledge held in a system rather than
in someone's head.

There is a sharper internal extension of it: when empirical comparison between approaches is
*structurally* unavailable, the choice becomes a first-principles strategic argument that should be
written down in the open rather than disguised as measurement. That is cornerstone-essay material and
it is defensible without any confidential detail.

Note for the voice work: "metric theater" is `NO RECORD` as a recurring phrase in the work corpus. It
appears in the current site copy. It is a real phrase Athan uses, but it is not the load-bearing tic
it looked like — the private ledger documents nine constructions that are.

## Still open — needs Athan, not more research

1. Whether PhD completion is 2021 (verified thesis issuance) or 2022 (possible conferral). A
   conferral record would settle it.
2. Exact legal spelling of one prior employer; the repo contains two spellings.
3. Whether to name two AI vendors in any adoption writing — a personal judgment call, not a
   confidentiality one.
4. Where the calibration/postmortem material goes. Recommendation: an essay, not a case study — the
   mechanism content is strong and the outcome is not attributable to Athan.
5. The employment summaries in `data/experience.json` still contain unverified percentage and dollar
   claims, and one names an internal system. `/resume/` is quarantined so none of it renders, but the
   text is in a public repo. These need Athan's line-by-line verification before that page un-gates.
