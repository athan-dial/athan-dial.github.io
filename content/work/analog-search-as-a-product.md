---
title: "When a Faster Search Tool Still Felt Incomplete"
type: work
date: 2026-08-11
summary: "I led the product definition for an analog-search tool that made warmed-database queries roughly an order of magnitude faster after an implementation change. Then its primary expert user said a commercial alternative returned more results. My proposed response was not to claim parity. It was to give the expert threshold control and make the edge of a match visible."
status: published
evidence_status: range-only
visibility: public
employer_review: self-cleared  # Athan's own judgment, 2026-08-12. No employer review; names no employer, program, or figure.
featured: true
role: "Product lead"
users:
  - "compound-management scientists"
  - "medicinal chemists"
  - "biologists"
themes:
  - expert-workflows
  - product-judgment
canonical_url: ""
draft: false
---

I led the product definition for an analog-search tool that got materially faster on a measured basis. After an implementation change, warmed-database query times for typical and heavy searches improved by roughly an order of magnitude. Months later, its primary expert user said a commercial alternative returned more results and wanted broader coverage. I thought we were looking at a completeness problem, not evidence that our results were less relevant. My proposed response was to give the expert more control and make the boundary of the match visible.

## Who was doing the work

The search began with a compound-management scientist. They took a starting structure and assembled possible analogs for medicinal chemists to review. Biologists later consumed the resulting report.

This was not data entry. The scientist adjusted similarity thresholds when a result set looked too small. They reconciled structures and calculated properties. They checked which compounds could actually be sourced. The output depended on chemical judgment at every step.

That distinction mattered. The point was not to encode a chemist's intuition and declare the problem solved. It was to remove the repeated retrieval and reconciliation work around that intuition.

## What was already possible

The manual process worked, but it took one to two days across several disconnected tools. A scientist moved among the assay registry, a desktop chemistry tool, spreadsheets, and commercial catalogs. The manual baseline covered roughly two-thirds of the available universe.

The process also lost its reasoning. A finished spreadsheet showed which compounds survived, but there was no record of why a threshold moved or why one candidate was kept over another. Someone could inspect the answer. They could not reconstruct the search that produced it.

The expert was already doing the adaptive part well. The product opportunity was to gather the search, ranking, availability checks, and decision trail into one place without pretending that a fixed threshold could replace review.

## The product boundary

I drew the boundary around the repeatable parts of the work. The product would retrieve and rank candidates consistently, preserve the path to each result, and give the scientist a common place to review the set. The expert would still decide whether a molecule looked meaningfully similar and whether it was worth pursuing.

That boundary shaped the first release. We did not begin with every data overlay in the broader vision. We shipped a thin similarity-search slice over the one dependency that was not fragile. It was enough to test the central interaction before making the product depend on upstream data quality the team did not control.

The principle was simple: make the common work reliable, then leave the last judgment legible and adjustable.

{{< boundary-diagram >}}

## The hard choice

The first hard choice was the search engine. I wrote a decision memo comparing PostgreSQL with RDKit against Milvus. The matrix weighted product fit most heavily; data alignment, scalability, and operating ownership came next; delivery risk carried the remaining weight.

PostgreSQL with RDKit won four of the five dimensions. Milvus won on the highest scale ceiling, but that was a ceiling we had not reached. Choosing the specialized engine would have optimized for a future constraint while adding delivery and operating complexity to the first release.

I recommended the proven general-purpose option, with the engine kept behind a service boundary. Milvus remained a runnable proof of concept. If scale later became the real constraint, the team could swap the backend without rebuilding the interface.

The second hard choice arrived after shipment. One expert compared the tool with a commercial alternative and saw fewer results. That observation was real. It was also one query, not a coverage study.

Chasing result-count parity would have made an external service's behavior our product specification. I thought the complaint was about confidence in completeness. A looser threshold would return more results. More threshold choices would give the expert control. Showing results in a strong-match tier and an edge-of-match tier would let the user see where the tool became uncertain, then tighten or widen the search themselves.

## My ownership

I owned the problem framing and product definition. I wrote the requirements, phased the release, mapped the user flow, and authored the engine decision at several levels of technical detail. I also set the boundary between what the product should make consistent and what the scientist should continue to judge.

Engineering owned the production implementation. Scientific users supplied the workflow knowledge and evaluated the output. My job was to turn those inputs into a product shape the team could build, test, and revise without hiding the tradeoffs.

## What changed

The tool shipped. After an implementation change, the team measured warmed-database query times for typical and heavy searches. Both improved materially, by roughly an order of magnitude. That was a query-time result. We did not measure the full time from a scientist's starting structure to a reviewed analog list, so I cannot claim the one-to-two-day workflow became an equally dramatic end-to-end reduction.

At least one expert tested the running tool. Months later, the primary expert user pushed back because a commercial alternative returned more results and asked for more variety and more total hits. We did not measure the tool's universe coverage. The only recorded comparison was a single query, so it cannot support a coverage percentage.

We also did not instrument adoption. There is no defensible user count, query count, retention measure, or evidence that the tool became the default. The last recorded objective snapshots were at risk, and I found no scored closeout. The measured performance change and the expert's objection are both real. A broader adoption outcome is not in the record.

## What I would change now

I would define adoption instrumentation as part of the product, not as cleanup after launch. Shipping established that the workflow could be put into software. Faster warmed-database queries established that one implementation change worked. Neither told us whether experts trusted the product enough to return to it.

I would track searches, threshold changes, result expansion, review completion, and return use from the first release. I would also test the two-tier result design directly: do experts understand why the edge cases are present, and does control over the threshold change their sense of completeness?

That missing instrumentation is the real finding here. Without it, the team could improve speed and respond thoughtfully to one expert, but it could not tell whether the product had changed the wider practice. I have argued elsewhere that uninstrumented adoption is a failure mode. This project is why I take that position seriously.
