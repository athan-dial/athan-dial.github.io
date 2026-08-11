# Content safety contract

**Binding on every file written into `content/`.** Read this before drafting anything.

This repo is **public**. Everything in `content/`, `data/`, `layouts/`, and `.planning/` is visible to
anyone, including Athan's employer, colleagues, and any future employer. The evidence that the
drafting work is based on lives in `.planning/private/` and is dense with material that must never
cross into `content/`.

This file states the rules and the approved vocabulary. It deliberately does **not** list the real
names it protects — pairing a real name with its abstraction is itself the disclosure. The per-story
mappings live in `.planning/private/`.

Enforcement: `scripts/verify-content-safety.sh`, wired into `scripts/verify-build.sh`. A violation
**fails the build**.

## Never appears in `content/`

| Category | Why |
|---|---|
| Internal program identifiers | Naming a program alongside its status, results, or failures discloses pipeline information. Some are also public gene symbols; the disclosure is the association with this employer. |
| Internal tool, app, and platform codenames | These are internal assets. The story is always tellable by function: "an analog-search tool", "an internal intelligence platform". |
| Third-party vendors, catalogs, CROs, commercial software | Naming these exposes commercial relationships. See the one exception below. |
| Model codenames | Same as tools. |
| Colleague names | Never name a colleague on a personal portfolio, with or without confidentiality. Use their role: "the compound-management scientist", "a platform engineer", "the analyst". |
| Internal document, ticket, or wiki IDs | Includes `pageId=` query parameters and any bare numeric document reference. |
| Chat, wiki, or workspace permalinks | A public site must never link into a private workspace. |
| Internal hostnames, cloud, and IAM identifiers | Includes environment names, hosted-zone IDs, role and user names, ARNs. |
| Internal schema names | Table, column, and warehouse identifiers. Describe layers by role instead. |
| Absolute dollar figures above three digits | Cost, budget, and portfolio figures. Use a range or characterise the magnitude. |
| Unpublished headcount, portfolio size, or program counts | Same reasoning. |
| Internally-announced job titles that differ from Athan's public self-description | Only the public wording may appear anywhere on the site. |

## The one exception: widely-used open-source technology

Named technology **may** appear when it is genuinely public and the story is unintelligible without
it. A build-versus-buy decision between two well-known open-source engines is not credible to an
engineer reading it if both options are anonymised, and nothing is disclosed by naming software
anyone can download.

**The test:** is it a public artifact anyone can obtain and run, or is it a commercial relationship,
a vendor account, or an internal asset? Public tool → nameable. Anything else → abstract it.

## Approved vocabulary

Use these consistently. Five drafting tracks inventing five different euphemisms for the same thing
reads as evasion; one shared vocabulary reads as discretion. Extend this list rather than improvising,
and add what you introduce.

| Instead of a specific… | Write |
|---|---|
| compound registry / assay database | "the assay registry" |
| desktop cheminformatics application | "a desktop chemistry tool" |
| named compound suppliers | "commercial catalogs" |
| contract research organisation | "an external chemistry partner" |
| internal nomination tooling | "the nomination workflow" |
| internal knowledge system | "an internal knowledge system" |
| internal search tool | "an analog-search tool" |
| internal CI platform | "an internal intelligence platform" |
| a named discovery program | "a discovery program", "one program" |
| a colleague | their role: "the medicinal chemist", "the analyst", "a platform engineer" |
| a warehouse table | its role: "a seed table", "a derived properties table", "the exposed field" |
| a specific environment | "the production environment" |

## Claim discipline

### `TARGET` is not `MEASURED`

This is the rule the whole evidence gate exists to enforce. Every figure in the relevant product
requirements documents is a target or a success criterion, not an outcome. The quarantined case
studies published targets as results, which is why they were quarantined.

- If you state a number, it must be `MEASURED`, and the sentence must say **what was measured**.
  "Query time fell from roughly 24 seconds to roughly 2 seconds on a warmed database" is publishable.
  "Sub-second search" is not, if that figure came from a requirements document.
- A target may be mentioned **as a target**, explicitly labelled: "we designed for X" — never in a
  "what changed" section.
- An `ESTIMATED` figure must read as an estimate: "approximately", "roughly", or a range.

### The four classifications

Every claim in the private ledger carries one. They map to what a sentence may do:

| Classification | What you may write |
|---|---|
| **public-and-verified** | State it plainly, with the figure. |
| **publishable-in-a-range** | Give the range and say it is a range. Never the exact value. |
| **publishable-as-mechanism-only** | Explain the decision and the system. No program names, no metrics. |
| **private** | Nothing. Useful for interviews, not for the site. |

**When in doubt, classify down.** A weaker claim you can defend beats a stronger one you cannot.

### `NO RECORD` gets said out loud

Where the evidence establishes that something was never measured, **write that into the prose.** Do
not quietly omit the section. "The tool shipped and people used it; we never instrumented adoption,
and I would do that differently" is a publishable sentence, it is true, and it is a better signal of
judgment than a number would have been. Silence reads as concealment; stating the gap reads as
calibration.

### Ranges beat precision

When a figure is sensitive but the direction matters, publish the range. "Roughly two-thirds
coverage" and "about an order of magnitude faster" carry the argument without exposing an internal
number. Precision that cannot be defended is worse than an honest approximation.

## Pre-publish checklist

Two minutes, before any draft is considered done:

1. `bash scripts/verify-build.sh` — passes. This runs both the content gate and the safety scan.
2. Read the draft looking **only** for numbers. For each one: measured or target? If measured, does
   the sentence say what was measured?
3. Read it again looking **only** for proper nouns. Every one: is it public, or is it internal?
4. Search the draft for a colleague's name or a role that identifies one person.
5. Check the frontmatter is `status: draft` and `visibility: private`. Nothing publishes without
   Athan's review.
6. Confirm every claim traces to something in `.planning/private/` — and that you invented nothing.

## If the scanner flags you

A match is a prompt to reword, not proof of a leak — a denied term can appear innocently. **Resolve it
by changing the prose, never by weakening the denylist.** If a term genuinely needs to be publishable,
that is a decision for Athan, not for a drafting agent.
