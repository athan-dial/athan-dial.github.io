---
title: "When a Faster Search Tool Still Felt Incomplete"
type: work
work_kind: flagship
narrative_voice: documentary
date: 2026-08-11
summary: "An analog-search tool became roughly an order of magnitude faster on measured warmed-database queries. Then its primary expert user compared it with a commercial alternative and saw fewer results. The useful product question moved from speed to confidence in completeness: give the expert threshold control and make the edge of a match visible rather than claim parity the evidence did not support."
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
# Work-index card fields. Each line below is a compression of this page's own
# "Role in the case" / "What changed" sections. Keep them in sync with the body.
card_ownership: "Problem framing, product definition, release phasing, and the search-engine decision. Engineering owned the production implementation; the scientific users owned the workflow knowledge and evaluated the output."
card_measured: "Warmed-database query time for typical and heavy searches, roughly an order of magnitude faster after one implementation change."
card_unmeasured: "Adoption was never instrumented. There is no defensible user count, query count, retention measure, or coverage percentage, and the end-to-end workflow time was never measured."
---

An analog-search tool became materially faster after an implementation change. On a warmed database, query times for typical and heavy searches improved by roughly an order of magnitude.

Months later, its primary expert user compared the tool with a commercial alternative and saw fewer results. The apparent problem had moved from speed to completeness.

The comparison established something real: one query returned fewer candidates. It did not establish that the internal results were less relevant, or that the commercial service defined the correct answer. The more useful product question was what an expert needed to see and control before deciding that a search was complete enough.

## Who was doing the work

The search began with a compound-management scientist. A starting structure became a set of possible analogs for medicinal chemists to review, with biologists later consuming the resulting report.

This was not data entry. The scientist adjusted similarity thresholds when a result set looked too small, reconciled structures and calculated properties, checked which compounds could actually be sourced, and decided whether the resulting set made chemical sense. Judgment entered at every step.

The repeatable work around that judgment was the product opportunity.

## What was already possible

The manual process worked, but it took one to two days across several disconnected tools. A scientist moved among the assay registry, a desktop chemistry tool, spreadsheets, and commercial catalogs. The manual baseline covered roughly two-thirds of the available universe.

The process also lost its reasoning. A finished spreadsheet showed which compounds survived, but not why a threshold moved or why one candidate was kept over another. The answer could be inspected. The search that produced it could not be reconstructed.

The expert was already doing the adaptive part well. The product needed to gather retrieval, ranking, availability checks, and the decision trail into one place without pretending that a fixed threshold could replace review.

## The product boundary

The boundary was drawn around the repeatable parts of the work. The product would retrieve and rank candidates consistently, preserve the path to each result, and provide one place to review the set. The expert would still decide whether a molecule looked meaningfully similar and whether it was worth pursuing.

That boundary shaped the first release. The initial slice did not include every data overlay in the broader vision. It used the one dependency that was reliable enough to support a thin similarity-search workflow, which made it possible to test the central interaction without binding the product to upstream data quality the team did not control.

Make the common work reliable. Leave the last judgment legible and adjustable.

{{< boundary-diagram >}}

## The hard choice

The first hard choice was the search engine. A decision memo compared PostgreSQL with RDKit against Milvus, weighting product fit most heavily, followed by data alignment, scalability, operating ownership, and delivery risk.

PostgreSQL with RDKit won four of the five dimensions. Milvus won on the highest scale ceiling, but that was a ceiling the product had not reached. Choosing the specialized engine would have optimized for a future constraint while adding delivery and operating complexity to the first release.

The recommendation favored the proven general-purpose option, with the engine kept behind a service boundary. Milvus remained a runnable proof of concept so a real scale constraint could later justify a backend change without forcing an interface rewrite.

The second hard choice arrived after shipment. One expert saw fewer results from the internal tool than from a commercial alternative. Chasing result-count parity would have turned an external service's behavior into the product specification.

A different interpretation fit the evidence better: the complaint was about confidence in completeness. A looser threshold could return more candidates. More threshold choices could give the expert control. A strong-match tier and an edge-of-match tier could expose where the search became uncertain, letting the user tighten or widen it deliberately.

## Role in the case

Product lead. Scope included problem framing, requirements, release phasing, user-flow definition, and the search-engine decision. The product role also held the boundary between what should become consistent in software and what the scientist should continue to judge.

Engineering owned the production implementation. Scientific users supplied the workflow knowledge and evaluated the output. The product work was to turn those inputs into a shape the team could build and revise without hiding the tradeoffs.

## What changed

The tool shipped. After an implementation change, the team measured warmed-database query times for typical and heavy searches. Both improved materially, by roughly an order of magnitude.

That was a query-time result, not an end-to-end workflow result. The time from a scientist's starting structure to a reviewed analog list was never measured, so the one-to-two-day manual baseline cannot be converted into an equally dramatic workflow claim.

At least one expert tested the running tool. Months later, the primary expert user asked for more variety and more total hits after comparing it with a commercial alternative. Universe coverage was not measured. The only recorded comparison was a single query, so it cannot support a coverage percentage.

Adoption was not instrumented either. There is no defensible user count, query count, retention measure, or evidence that the tool became the default. The measured performance change and the expert's objection are both real. A broader adoption outcome is not in the record.

## Retrospective

With hindsight, I would define adoption instrumentation as part of the first release rather than as cleanup after launch. Shipping established that the workflow could be put into software. Faster queries established that one implementation change worked. Neither answered whether experts trusted the product enough to return to it.

I would also test the two-tier result design directly: whether experts understand why edge cases are present, and whether control over the threshold changes their sense of completeness.

The missing instrumentation is the useful finding. It is why I now treat return use and verification behavior as part of the product definition rather than evidence to look for later.
