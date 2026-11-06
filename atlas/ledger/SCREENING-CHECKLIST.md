# Public/private screening checklist (draft)

Applied to every selected record before it is called a candidate. Editorial approval is still
required before any record is treated as reviewed.

| # | Check | Method | Result for the 16 records |
|---|---|---|---|
| 1 | Upstream repository is public | GitHub API `private = false`, link check HTTP 200 | pass |
| 2 | Repository is not archived | GitHub API `archived = false` | pass |
| 3 | License read from the repository | API `license` plus LICENSE file where SPDX is `NOASSERTION` | pass (2 noted) |
| 4 | Every claim cites a public upstream page | validator: each `facts.source_url` is in `sources` | pass |
| 5 | No private conversation text | records hold a `seed_pointer` only; `private_text_included = false` enforced | pass |
| 6 | No employer, internal host, email, credential or local path | validator deny-list plus a grep over `atlas/` and `out/` | pass |
| 7 | No personal-workflow or ambiguous-ownership repositories selected | manual pass over the seed names | pass (excluded, reasons not recorded) |
| 8 | No copied code, branding or content from the PolyForm-licensed reference site | none consulted for records; schema written from the ticket field list | pass |
| 9 | Vendor marketing numbers kept out of `facts` | manual read of each README claim | pass (stars, user counts, benchmarks excluded) |
| 10 | Evidence state not above what was done | all `inspected`; `unavailable` lists tested/adopted | pass |

The deny-list is a floor, not a review. A human still has to read each record.
