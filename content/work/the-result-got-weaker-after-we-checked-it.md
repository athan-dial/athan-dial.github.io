---
title: "The Result Got Weaker After We Checked It"
type: work
work_kind: flagship
date: 2026-09-10
summary: "A retrospective analysis suggested we might already have a useful signal for when model predictions deserved more trust. The validation pass made that story smaller: one apparent effect disappeared, another turned out to be mostly a proxy for the score itself, and the final recommendation became research, not a production rule."
status: draft
evidence_status: mechanism-only
visibility: private
employer_review: pending
featured: true
role: "Analysis and product lead"
users:
  - "discovery scientists"
  - "modeling scientists"
themes:
  - reliable-ai-systems
  - product-judgment
canonical_url: ""
draft: true
card_ownership: "Question framing, validation criteria, statistical corrections, interpretation, and the boundary on what the result was allowed to become."
card_measured: "A retrospective back-test showed that one candidate confidence signal largely tracked the prediction score itself; stricter inference also caused one initially supportive cohort result to disappear."
card_unmeasured: "No prospective validation, no evidence for using the signal as a production selection rule, and no portable effect size across discovery programs."
---

The first pass gave us a result we could have used.

That was exactly why I wanted to make it harder to keep.

We were trying to answer a practical question about model-supported scientific work: when a model scores a candidate, can we tell whether that prediction is well supported by the kinds of examples the model learned from? And if we can, does that tell us anything useful about how much confidence to place in the score?

The retrospective analysis found a promising pattern. It also found something less flattering about a signal we already had: what looked like model disagreement was mostly moving with the prediction score itself. Low disagreement often meant the model was confidently calling something inactive, not that it possessed an independent measure of certainty.

That distinction mattered because the intended use was not another ranking feature. The scientists already had a ranking. The interesting product question was whether we could say something about **how much to trust it**.

## What we were actually trying to decide

A model score is easy to display. A confidence label is harder.

The temptation is to take some nearby technical quantity, call it uncertainty, and put it next to the score. That can make the interface look more responsible without making the underlying decision any safer.

I wanted a higher bar. If we were going to expose a reliability signal, it needed to carry information that was not already embedded in the score, and it needed to correspond to what happened when compounds were actually tested.

A simple starting point was training-domain support: had the model seen chemically related examples during training? That is not a complete description of applicability domain, but it is legible and falsifiable. If even that crude signal had no relationship to experimental reliability, we would have learned something cheaply.

The first pass suggested it did.

## Why the first answer was not enough

There were several ways for that result to look better than it was.

The prediction score and the apparent disagreement measure were strongly related. A simple adjustment could leave residual score structure behind and let the second variable take credit for it. Compounds sharing a chemical scaffold were also not independent observations. Treating hundreds of close relatives as hundreds of unrelated pieces of evidence would make a repeated chemical series look like replication.

There was a third problem upstream of the statistics. Not every nominated compound reached experimental testing. Any analysis of observed outcomes therefore had to distinguish a real reliability effect from the possibility that the screening process had selected a particular slice of chemistry.

So I specified a validation pass around those failure modes rather than around the result we hoped to preserve: more flexible control for the score, inference clustered by chemical scaffold, and a task-aware treatment of selection into the tested set.

The important part is that these were not robustness checks to decorate the appendix. They were allowed to change the conclusion.

They did.

## What changed after validation

One initially supportive cohort stopped being supportive once chemical relatedness was respected. A large chemical series had been contributing many observations that were not independent in the way the first analysis assumed. Under scaffold-clustered inference, the apparent effect disappeared.

I withdrew it from the finding.

The existing disagreement measure also became much less interesting. Once the prediction score itself was controlled properly, disagreement contributed essentially no independent information about experimental hit rate. What looked like uncertainty was, for practical purposes, mostly another view of the score.

The training-domain signal survived more selectively. In one setting it improved calibration without improving ranking. That was a useful distinction: it did not meaningfully change which candidates came first, but it changed how well the predicted probabilities corresponded to what happened experimentally.

For the original question, that was closer to the point.

A reliability signal does not necessarily need to reorder the list. Sometimes its job is to tell you whether a score of a given magnitude deserves the same confidence in familiar and unfamiliar parts of the domain.

The effect was not portable enough to treat as universal. Some historical cohorts supported it more strongly than others. One did not survive the stricter analysis at all. That variability became part of the result rather than something to average away.

## The product boundary

The analysis could have ended with a new field in the nomination workflow. I did not think the evidence supported that.

A domain-support signal that works retrospectively in some historical settings is a research result. Turning it into a production rule would make a much stronger claim: that the relationship is stable enough, prospective enough, and portable enough to influence what scientists test next.

We did not have that evidence.

There was also a scientific reason to be careful. Novel chemistry is often interesting precisely because it is unlike the training set. A crude applicability-domain feature should not become a machine for quietly penalizing novelty. The useful interpretation was diagnostic: **this score may deserve a different level of trust here**, not **do not pursue this compound**.

That was the boundary I wanted to preserve.

## My ownership

I framed the analysis around the decision we were trying to support rather than around the easiest statistic to compute. I specified the validation pass when the first result looked too easy to interpret, including the need for flexible score control, inference that respected chemical relatedness, and a corrected treatment of selection into the observed set.

I also owned the interpretation that mattered most to the product question: calibration and ranking are not the same thing. A feature can improve our estimate of how much to trust a score without being useful for reordering candidates.

The analysis itself was agent-assisted and reproducible from reconstructed historical data. That made verification more important, not less. When analysis becomes cheap to generate, the scarce part is deciding what the output is allowed to mean.

## What changed

The recommendation got smaller.

We did not have an independent uncertainty signal hiding in an existing disagreement field. We did have enough evidence that training-domain support might contain information about experimental reliability to justify a better test.

So the next step became a pre-committed research experiment, not a product feature: evaluate a richer continuous measure of domain support, keep chemically related compounds together during validation, use clustered uncertainty from the start, and agree in advance on what result would be strong enough to continue.

That is a less exciting outcome than discovering a ready-made confidence score.

It is also the outcome I trust.

## What I would change now

I would put the falsification conditions into the analysis brief before the first run.

The technical corrections were all available to us after the first pass, but writing them down earlier would have made the evaluation less vulnerable to the gravitational pull of a promising result. I would define the unit of independence, the score-control strategy, the handling of selection, and the prospective bar before looking at the effect.

I would also design the product question into the analysis more explicitly. If the intended use is confidence rather than ranking, calibration should be a first-class outcome from the beginning rather than something we notice because AUC failed to move.

The useful habit here is not skepticism for its own sake. It is letting verification change the shape of the thing you are willing to build.
