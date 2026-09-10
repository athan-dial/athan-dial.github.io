---
title: "Lock the Outcome, Not the Prototype"
type: work
work_kind: flagship
date: 2026-09-10
summary: "We had working software and a team ready to take it forward. The problem was that the product plan had started treating inherited implementation choices as requirements. I changed the contract: lock the outcome and the important boundaries; document the prototype as context specialists are free to challenge."
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

We had working software, a real problem, and a team ready to take the next version forward.

The product plan was still wrong.

Not because the prototype had failed. The opposite. It had accumulated enough working choices that the document describing the next phase had started to treat those choices as requirements: architecture, model stack, orchestration patterns, interface assumptions, even some of the vocabulary we were using to decide whether the system was ready.

Those choices were useful evidence. They were also decisions the specialists taking over the work were qualified to revisit.

I changed the contract around a distinction that sounds obvious only after you have been bitten by the alternative: **lock the outcome; describe the prototype as inheritance.**

## Who was doing the work

The product sat across several technical surfaces. Different specialists owned source reliability, entity quality, output structure, and the analyst-facing review path. The system only worked if those surfaces composed into one repeatable loop.

That made the handoff unusual. A conventional feature backlog would have fragmented the work into pieces that were locally understandable but globally easy to disconnect. At the same time, a highly prescriptive product document would have told specialists how to solve problems inside their own areas before they had a chance to inspect the inherited implementation.

My job was not to become the deepest expert in each surface. It was to make the product contract coherent enough that each person could exercise that expertise without quietly changing what the whole system was supposed to prove.

## What was already possible

The prototype already had substantial capability. That created a subtle planning problem.

When nothing exists, teams know they are designing. When a lot already exists, implementation history starts masquerading as product truth.

A current architecture becomes **the architecture**. A model choice becomes **the model requirement**. A UI built to test one idea becomes a permanent surface because it is the thing everyone can point at. The more convincing the prototype, the easier it is to stop noticing which choices were contingent.

I did not want to throw that context away. An outcomes-only brief would have forced everyone to rediscover decisions, constraints, and known failure modes that the first build had already paid to learn.

But I also did not want the product plan to fossilize them.

## The product boundary

The revised planning rule separated three things that had been blurred together.

**The outcome was binding.** The next phase had to demonstrate one repeatable, explainable loop for a real scientific use case. It had to preserve provenance, survive defined readiness checks, and produce an output an expert could inspect.

**The inherited stack was descriptive.** Existing architectural choices, model integrations, data shapes, commands, and interface patterns were documented because they were the current state of the world. Specialists should understand them before changing them. They were not requirements merely because they already existed.

**Changes to load-bearing assumptions became decisions.** If a specialist wanted to replace an inherited choice that affected the shared product contract, that was welcome. It simply had to become explicit rather than arriving as implementation drift.

That division gave the team room to exercise judgment without turning the handoff into a blank sheet of paper.

## The hard choice

There were two tempting extremes.

One was to write the PRD as pure outcomes: here is what success looks like, go solve it. That sounds empowering. In a system with real history, it mostly transfers the cost of reconstructing context to the people doing the work.

The other was to lock outcomes plus the important-looking pieces of the prototype. That reduces ambiguity in the short term, but it also promotes yesterday's implementation choices into tomorrow's constraints. The people closest to a technical surface become implementers of a decision they might have been better placed to make.

I wanted the middle to be explicit rather than accidental.

The document therefore showed the inherited system in enough detail to make the current state legible, while reserving the word **requirement** for the outcomes and boundaries we actually meant to hold fixed.

The same idea changed how I organized the work around it. Ownership followed durable surfaces rather than temporary features. Handoffs were defined by what one surface had to provide to the next. Readiness was expressed as observable gates rather than a general sense that the system looked good in a demo.

And the documentation itself got smaller. If two documents answered the same question, one of them had to lose. A handoff with sixteen places to look is not more documented than a handoff with four. It is a search problem wearing a documentation costume.

## My ownership

I owned the product framing and the planning contract for the handoff. That included deciding which outcomes were load-bearing, which existing choices should be treated as context rather than prescription, how work should be divided across specialist surfaces, and when implementation work was mature enough to crystallize into tracked delivery.

I was also an advisor rather than the implementation owner on several of those surfaces. That distinction is important here. The point of the planning model was not to centralize technical decisions with me. It was to make it obvious which decisions were mine to hold, which belonged to a specialist, and which crossed a seam and therefore needed to be made together.

The team owned the implementation. Specialists could challenge inherited choices inside their surface. The product contract existed to prevent local freedom from becoming global ambiguity.

## What changed

The immediate change was to the plan, not to a metric.

The next phase was narrowed to one repeatable loop instead of platform expansion. The PRD stopped prescribing implementation details it did not need to own. Specialist responsibilities were organized around surfaces that composed into that loop. Readiness checks became a shared vocabulary. New delivery tickets were held until the underlying documents were accepted rather than using tickets to create the appearance of settled scope.

I do not have a defensible productivity number for that change, and I would not infer one from activity. This is evidence of an operating decision, not evidence that everyone suddenly moved faster.

What it gave us was something more basic: a cleaner answer to **what are we actually asking the team to preserve?**

That question has become more important as AI makes prototypes easier to produce. A prototype can now contain a startling amount of implementation before the product question has finished moving. If the plan treats everything already built as intentional, cheap execution turns very quickly into expensive inheritance.

## What I would change now

I would make the distinction visible in the document itself from the first draft.

For every meaningful product handoff, I now want three explicit columns:

- **Must hold:** the outcome, constraint, or boundary the work is accountable to.
- **Inherited:** what exists today and is worth understanding before changing.
- **Open to challenge:** choices we expect the specialist to revisit if they have a better answer.

That would have made the argument shorter and the autonomy clearer.

The broader lesson is not that product people should specify less. Sometimes they should specify much more. The useful question is what kind of thing you are specifying.

Lock the outcome tightly enough that the team can tell whether the work succeeded. Leave the implementation open enough that the people doing the work can still improve it.
