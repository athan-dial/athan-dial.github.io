---
title: "Lock the Outcome, Not the Prototype"
type: work
work_kind: flagship
narrative_voice: documentary
date: 2026-09-10
summary: "There was working software and a team ready to take it forward. The problem was that the product plan had started treating inherited implementation choices as requirements. The contract changed: lock the outcome and the important boundaries; document the prototype as context specialists are free to challenge."
status: draft
evidence_status: mechanism-only
visibility: private
employer_review: pending
featured: true
role: "Product lead"
users:
  - "scientific analysts"
  - "technical specialists"
themes:
  - product-judgment
  - reliable-ai-systems
canonical_url: ""
draft: true
card_ownership: "Product framing, the planning contract, team-level ownership boundaries, and the decision about what the PRD was allowed to prescribe."
card_measured: "This is a decision-trail case, not a performance claim. The documented change narrowed the product contract, separated required outcomes from inherited implementation, and made ownership and readiness gates explicit."
card_unmeasured: "No measured productivity, delivery-speed, or adoption outcome is claimed from the planning change itself."
---

There was working software, a real problem, and a team ready to take the next version forward.

The product plan was still wrong.

Not because the prototype had failed. The opposite. It had accumulated enough working choices that the document describing the next phase had started to treat those choices as requirements: architecture, model stack, orchestration patterns, interface assumptions, even some of the vocabulary used to decide whether the system was ready.

Those choices were useful evidence about what already existed. They were not automatically the outcome the team had been asked to preserve.

The planning contract changed around one distinction: **lock the outcome; describe the prototype as inheritance.**

## Who was doing the work

The product crossed several technical surfaces. Different specialists owned source reliability, entity quality, output structure, and the analyst-facing review path. The system only worked if those surfaces composed into one repeatable loop.

That made the handoff awkward in two predictable ways. A conventional feature backlog could fragment the work into pieces that were locally understandable but globally easy to disconnect. A highly prescriptive product document could solve the opposite problem by telling specialists how to work inside surfaces they were better placed to judge.

The product contract needed to hold the shared outcome without swallowing specialist autonomy.

## What was already possible

The prototype already had substantial capability. That created a subtle planning problem.

When nothing exists, teams know they are designing. When a lot already exists, implementation history starts masquerading as product truth.

A current architecture becomes **the architecture**. A model choice becomes **the model requirement**. A UI built to test one idea becomes a permanent surface because it is the thing everyone can point at. The more convincing the prototype, the easier it is to stop noticing which choices were contingent.

An outcomes-only brief would have created a different failure mode. It would have discarded decisions, constraints, and known problems that the first build had already paid to discover, forcing specialists to reconstruct the context before they could improve it.

The useful middle was neither blank-slate autonomy nor inherited prescription.

## The product boundary

The revised planning rule separated three things that had been blurred together.

**The outcome was binding.** The next phase had to demonstrate one repeatable, explainable loop for a real scientific use case. It had to preserve provenance, survive defined readiness checks, and produce an output an expert could inspect.

**The inherited stack was descriptive.** Existing architectural choices, model integrations, data shapes, commands, and interface patterns were documented because they were the current state of the system. Specialists should understand them before changing them. They were not requirements merely because they already existed.

**Changes to load-bearing assumptions became decisions.** Replacing an inherited choice was welcome when a specialist had a better answer. If the change altered the shared product contract, it needed to become explicit rather than arrive as implementation drift.

That division gave the team room to exercise judgment without turning the handoff into a blank sheet of paper.

## The hard choice

There were two tempting extremes.

One was a pure-outcomes PRD: here is what success looks like, go solve it. In a system with real history, that mostly transfers the cost of reconstructing context to the people doing the work.

The other was to lock outcomes plus the important-looking pieces of the prototype. That reduces ambiguity in the short term, but it promotes yesterday's implementation choices into tomorrow's constraints. The people closest to a technical surface become implementers of a decision they might have been better placed to make.

The document therefore showed the inherited system in enough detail to make the current state legible, while reserving the word **requirement** for the outcomes and boundaries that actually needed to hold.

The same distinction shaped the work around it. Ownership followed durable surfaces rather than temporary features. Handoffs were defined by what one surface had to provide to the next. Readiness was expressed as observable gates rather than a general sense that the system looked good in a demo.

The documentation itself got smaller too. If two documents answered the same question, one of them had to lose. A handoff with sixteen places to look is not more documented than a handoff with four. It is a search problem wearing a documentation costume.

## Role in the case

Product lead. Scope included the product framing and planning contract for the handoff: which outcomes were load-bearing, which existing choices belonged in the record as inheritance rather than prescription, how ownership should divide across specialist surfaces, and when implementation work was mature enough to crystallize into tracked delivery.

Several technical surfaces had their own implementation owners, with the product role acting as advisor rather than substitute specialist. That distinction was deliberate. The planning model existed to make clear which decisions belonged to the product contract, which belonged to a specialist, and which crossed a seam and therefore needed to be made together.

The team owned the implementation. Local freedom was preserved without making the shared outcome ambiguous.

## What changed

The immediate change was to the plan, not to a performance metric.

The next phase was narrowed to one repeatable loop instead of platform expansion. The PRD stopped prescribing implementation details it did not need to own. Specialist responsibilities were organized around surfaces that composed into that loop. Readiness checks became a shared vocabulary. New delivery tickets were held until the underlying documents were accepted rather than using tickets to create the appearance of settled scope.

No defensible productivity or delivery-speed number comes from that planning change. It is evidence of an operating decision, not evidence that everyone suddenly moved faster.

What changed was more basic: the team had a cleaner answer to **what are we actually asking this work to preserve?**

That question becomes more important as AI makes prototypes easier to produce. A prototype can contain a startling amount of implementation before the product question has finished moving. If the plan treats everything already built as intentional, cheap execution turns quickly into expensive inheritance.

## Retrospective

I would make the distinction visible in the document itself from the first draft.

For a meaningful product handoff, I now want three explicit columns: **Must hold**, **Inherited**, and **Open to challenge**. That would make the argument shorter and the autonomy clearer.

The broader lesson is not that product people should specify less. Sometimes they should specify much more. The useful question is what kind of thing I am specifying.

Lock the outcome tightly enough that the team can tell whether the work succeeded. Leave the implementation open enough that the people doing the work can still improve it.
