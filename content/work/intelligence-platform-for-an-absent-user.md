---
title: "The primary user was not in the room"
type: work
date: 2026-08-11
summary: "I designed and helped build an internal intelligence platform that reconciled records from multiple sources without asking a model to decide what was true. A discovery conversation changed the primary user from the analyst to a leadership function. That reframe clarified the product boundary: the machine could retrieve, rank, and propose; the analyst still had to adjudicate. The platform eventually reached production after an earlier attempt failed at a permissions boundary."
status: draft
evidence_status: mechanism-only
visibility: private
employer_review: pending
featured: true
role: "Product and technical lead"
users: ["competitive-intelligence analysts", "business-development leadership"]
themes: ["expert-workflows", "product-judgment", "reliable-ai-systems"]
canonical_url: ""
draft: true
---

## BLUF

I designed and helped build an internal intelligence platform that reconciled records from multiple sources without asking a model to decide what was true. A discovery conversation changed the primary user from the analyst to a leadership function. That reframe clarified the product boundary: the machine could retrieve, rank, and propose; the analyst still had to adjudicate. The platform eventually reached production after an earlier attempt failed at a permissions boundary.

The supported result is narrower than an adoption claim. The record does not support the milestone count, delivery interval, or requirements ratio that appeared in an earlier version of this story. I do not use them here.

## Who was doing the work

We started by treating the competitive-intelligence analyst as the primary user. That was reasonable. The analyst gathered source material, reconciled inconsistent names, and decided what a competitor's activity meant. The work depended on both broad recall and domain judgment.

Then one discovery conversation changed the frame. The person in the session pointed toward a leadership function as the primary consumer. That user was not in the room.

This was more than a persona change. An analyst-facing tool would optimize the work of assembling and cleaning evidence. A leadership-facing product had to make the resulting picture coherent enough to use, while preserving a route back to the underlying evidence. The analyst remained essential, but the product was no longer only for the analyst.

## What was already possible

The predecessor was a manual spreadsheet diff. It gave the team a way to compare snapshots, but its unit of comparison was whatever each source happened to call a row. The platform needed a more stable object underneath those rows.

Different sources could describe the same organization, target, or asset differently. Before any language model could summarize a change, the system had to decide which records referred to the same entity. That was the real data problem. A fluent summary built on unresolved identities would only make the ambiguity harder to see.

The spreadsheet also left the analyst doing the reconciliation. That was not a weakness in the analyst's process. It was evidence that the shared system had not yet taken responsibility for a repetitive part of the work.

## The product boundary

I designed the platform around a canonical entity layer. Source records would remain traceable to their origin, while organizations, targets, and assets could be reconciled into shared entities. Evidence would support claims and associations rather than disappearing into a generated paragraph.

The implemented resolution path had three bands, with the exact thresholds deliberately omitted here:

- High-confidence matches could resolve automatically.
- Ambiguous matches went to human review.
- Low-confidence matches were flagged rather than forced.

That boundary was the product. The language model proposed candidates. The analyst adjudicated the uncertain cases. The system handled recall and ranking; the expert remained responsible for meaning.

It would have been easy to describe full automation as the more advanced option. I think it would have been the less useful product. Entity resolution errors propagate. Once a bad match becomes a canonical record, every downstream view can inherit a confident mistake.

## The hard choice

The hard choice was not which model to use. It was where to stop the model.

Automatic resolution made sense when the evidence cleared a high confidence bar. Human review made sense in the middle, where two plausible records needed context. Below that band, the honest answer was a flag. The system should not manufacture certainty to keep a pipeline moving.

The discovery conversation added a second constraint. Leadership needed a coherent view, but coherence could not come from hiding disagreement. That pushed the design toward a canonical layer with provenance and explicit curation. It also kept interpretation with the analyst. The platform could organize the evidence around a competitor's move. It could not decide what that move meant for the business.

## Athan's ownership

I owned the product requirements, roadmap, and architecture, and I worked directly in the implementation across the application. This was not a requirements document handed across a boundary. Product and technical choices moved together.

My part was to define the common data model, set the resolution boundary, and turn the discovery reframe into a different product surface. Analysts supplied the domain judgment the system was designed to preserve. Production deployment also depended on infrastructure permissions outside the application itself, which became important when the first attempt failed.

## What changed

An early production attempt stopped most of the way through deployment at a permissions boundary nobody had accounted for. Most of the supporting infrastructure had been created. The running service and its domain record had not. That was a failed deployment, not a spring production launch.

Production is verifiably observed roughly four months later, inside a window of a few weeks. That is the shipping claim the primary record supports.

The record does not establish a specific number of versioned milestones in a specific interval. It also does not establish a requirements-met ratio at any milestone. One document label looked like a requirements count, but it was a version label. I would rather leave those numbers out than turn document metadata into an outcome.

The evidence establishes that the platform reached production. It does not give me a measured adoption or decision-quality result I can responsibly publish. That limits the outcome claim, and it should.

## What he would change now

The most consequential architecture correction arrived during the build. Publication date and event date are different facts. A source can report an event after it happened, and the system can learn about that source later still. Treating those moments as one timestamp produces a clean but false timeline.

I specified a temporal model that would preserve both when a fact was true in the world and when the system learned it. That invariant reshaped the planned data model. It was not built. An implementation audit confirmed that it had been deferred.

I would make that distinction part of the first data-model review now, with an implementation check attached to it. I would also instrument the human-review loop and downstream use before calling the platform successful. Reaching production matters. Knowing whether experts correct the proposals, trust the resulting entities, and use the product for real decisions matters more.
