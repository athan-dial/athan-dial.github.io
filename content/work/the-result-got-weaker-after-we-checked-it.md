---
title: "The Result Got Weaker After We Checked It"
type: work
work_kind: flagship
narrative_voice: documentary
date: 2026-09-10
summary: "A retrospective analysis suggested a useful signal for when model predictions deserved more trust. The validation pass made the story smaller: one apparent effect disappeared, another turned out to be mostly a proxy for the score itself, and the final recommendation became research, not a production rule."
status: draft
evidence_status: mechanism-only
visibility: private
employer_review: pending
featured: true
role: "Validation design and interpretation"
users:
  - "discovery scientists"
  - "modeling scientists"
themes:
  - reliable-ai-systems
  - product-judgment
canonical_url: ""
draft: true
card_ownership: "Validation criteria, statistical corrections, interpretation, and the boundary on what the result was allowed to become."
card_measured: "A retrospective back-test showed that one candidate confidence signal largely tracked the prediction score itself; stricter inference also caused one initially supportive cohort result to disappear."
card_unmeasured: "No prospective validation, no evidence for using the signal as a production selection rule, and no portable effect size across discovery programs."
---

The first pass produced a result that was easy to want.

That made the validation standard more important.

The practical question was whether a model score could be accompanied by something more useful than another score: an indication of how well supported a prediction was by the kinds of examples the model had learned from, and whether that support changed how much confidence scientists should place in the prediction.

The retrospective analysis found a promising pattern. It also found something less flattering about an existing disagreement signal. What looked like model uncertainty was moving strongly with the prediction score itself. Low disagreement often meant the model was confidently calling something inactive, not that it possessed an independent measure of certainty.

The scientists already had a ranking. The more interesting product question was whether anything in the analysis could say **how much to trust it**.

## What was actually being decided

A model score is easy to display. A confidence label is harder.

A nearby technical quantity can be named "uncertainty" and placed beside a score, which makes an interface look more responsible without necessarily making the underlying decision safer. A useful reliability signal needed to add information that was not already embedded in the score and needed to correspond to what happened when compounds were actually tested.

A simple starting point was training-domain support: whether the model had seen chemically related examples during training. That is not a complete applicability-domain model, but it is legible and falsifiable. If even that crude signal had no relationship to experimental reliability, the failure would have been informative.

The first pass suggested that it did.

## Why the first answer was not enough

There were several ways for that result to look better than it was.

The prediction score and the apparent disagreement measure were strongly related. A simple adjustment could leave residual score structure behind and let the second variable take credit for it. Compounds sharing a chemical scaffold were also not independent observations. Treating hundreds of close relatives as hundreds of unrelated pieces of evidence would make a repeated chemical series look like replication.

There was another problem upstream of the statistics. Not every nominated compound reached experimental testing. Any analysis of observed outcomes therefore had to distinguish a real reliability effect from the possibility that the screening process had selected a particular slice of chemistry.

The validation pass was designed around those failure modes rather than around preservation of the first result: more flexible control for the score, inference clustered by chemical scaffold, and a task-aware treatment of selection into the tested set.

These were not appendix robustness checks. They were allowed to change the conclusion.

They did.

## What changed after validation

One initially supportive cohort stopped being supportive once chemical relatedness was respected. A large chemical series had been contributing many observations that were not independent in the way the first analysis assumed. Under scaffold-clustered inference, the apparent effect disappeared and was removed from the finding.

The existing disagreement measure also became much less interesting. Once the prediction score itself was controlled properly, disagreement contributed essentially no independent information about experimental hit rate. What looked like uncertainty was, for practical purposes, mostly another view of the score.

The training-domain signal survived more selectively. In one setting it improved calibration without improving ranking. That distinction mattered. It did not meaningfully change which candidates came first, but it changed how well the predicted probabilities corresponded to what happened experimentally.

For a reliability question, calibration was closer to the point.

A signal does not need to reorder a list to be useful. Sometimes its job is to tell whether a score of a given magnitude deserves the same confidence in familiar and unfamiliar parts of the domain.

The effect was not portable enough to treat as universal. Some historical cohorts supported it more strongly than others. One did not survive the stricter analysis at all. That variability became part of the result rather than something to average away.

## The product boundary

The analysis could have ended with a new field in the nomination workflow. The evidence did not support that move.

A domain-support signal that works retrospectively in some historical settings is a research result. Turning it into a production rule would make a much stronger claim: that the relationship is stable enough, prospective enough, and portable enough to influence what scientists test next.

That evidence did not exist yet.

There was also a scientific reason to be careful. Novel chemistry is often interesting precisely because it is unlike the training set. A crude applicability-domain feature should not become a machine for quietly penalizing novelty. The useful interpretation was diagnostic: **this score may deserve a different level of trust here**, not **do not pursue this compound**.

## Role in the case

Validation design and interpretation. The role covered reframing the analysis around the decision it was meant to support, specifying the stricter validation pass, tightening the statistical treatment when the first result looked too easy to interpret, and deciding what the surviving evidence was allowed to become.

The role also included the distinction between calibration and ranking. A feature can improve the estimate of how much to trust a score without being useful for reordering candidates.

The analysis itself was agent-assisted and reproducible from reconstructed historical data. That made verification more important, not less. When analysis becomes cheap to generate, the scarce part is deciding what the output is allowed to mean.

## What changed

The recommendation got smaller.

There was no independent uncertainty signal hiding in the existing disagreement field. There was enough evidence that training-domain support might contain information about experimental reliability to justify a better test.

The next step therefore became a pre-committed research experiment rather than a product feature: evaluate a richer continuous measure of domain support, keep chemically related compounds together during validation, use clustered uncertainty from the start, and agree in advance on what result would be strong enough to continue.

That is a less exciting outcome than discovering a ready-made confidence score.

It is also more defensible.

## Retrospective

I would put the falsification conditions into the analysis brief before the first run. The unit of independence, score-control strategy, handling of selection, and prospective bar were all available to specify earlier, before a promising result had any gravitational pull.

I would also make the product question explicit in the analysis design. If the intended use is confidence rather than ranking, calibration should be a first-class outcome from the beginning rather than something noticed because a ranking metric failed to move.

The useful habit is not skepticism for its own sake. It is letting verification change the shape of the thing I am willing to build.
