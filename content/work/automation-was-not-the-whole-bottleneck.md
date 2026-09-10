---
title: "Automation Was Not the Whole Bottleneck"
type: work
work_kind: proof-note
date: 2026-09-10
summary: "We were trying to make a recurring scientific pipeline reliable. Some gaps were software. Others were decisions nobody had encoded yet: what counted as a valid run, where QC belonged, what evidence proved completion, and who owned a failed handoff. Mapping both kinds of dependency changed the project."
status: draft
evidence_status: mechanism-only
visibility: private
employer_review: pending
featured: false
role: "Coordinator and workflow mapper"
users:
  - "data scientists"
  - "scientific model developers"
themes:
  - reliable-ai-systems
  - product-judgment
canonical_url: ""
draft: true
card_ownership: "End-to-end workflow mapping, dependency structure, critical-path diagnosis, and the distinction between automation gaps and missing operating policy."
card_measured: "The dependency audit established that an intended recurring-run reliability criterion had never actually started and that a standard run-report mechanism was still missing."
card_unmeasured: "No portfolio-level productivity gain or before-and-after cycle-time reduction is claimed from the productionization work."
---

We were trying to automate a recurring scientific pipeline.

The first useful thing I did was stop treating it as an automation problem.

Some of the gaps were exactly what you would expect: a manual kickoff, a missing handoff between systems, quality checks that happened too late, outputs that another step could not reliably discover. Those are software problems. You can assign them, build them, and test them.

Other gaps looked similar on a project plan but were fundamentally different. What counted as a valid run? Which failure should stop the pipeline? Which result should be recorded for the next person? Who owned the handoff when the software worked but the scientific policy was still ambiguous?

There was no amount of orchestration code that could answer those questions for us.

## I mapped the work as one dependency system

The pipeline crossed several teams and technical surfaces, from data preparation through model execution and into a downstream scientific workflow. Different people owned different pieces. Some work was already underway, some existed only as a requirement, and some important dependencies were not connected to the main plan at all.

I started by mapping the end-to-end flow: handoffs, manual steps, quality-control points, decision points, and the work items that were supposed to remove each gap.

Then I wired the dependencies together rather than treating every ticket as an independent unit of progress.

That exposed a critical path, but more importantly it exposed two different kinds of blocker living on the same path.

A software dependency can be late.

A policy dependency can be undefined.

Those need different interventions.

## A reliability target had become project folklore

The team had discussed proving reliability through a recurring sequence of clean runs. On the planning surface, that criterion existed. It looked like something that could become green or red with enough execution.

When I went back through the evidence, the clock had never actually started.

A critical dependency had remained blocked through the period when those runs were supposed to occur. The standardized report that would have documented each run was not in place either. There was therefore no defensible series of completed cycles to count.

Calling the criterion "at risk" would have been generous to the plan and unhelpful to everyone else. It was not a late experiment. It was an experiment we had not yet made possible.

So I retired that exit criterion and replaced it with a smaller one we could actually observe: first prove a single clean end-to-end run with the required evidence, then earn the recurring cadence.

That changed the project from catching up to a schedule into establishing the measurement layer the schedule had assumed.

## Productionization includes policy

This is the distinction I keep coming back to.

A pipeline is not productionized because every step has an API and a scheduler. It is productionized when the organization can tell what happened, whether it was acceptable, and what happens next when it was not.

For this workflow, that meant software and policy had to converge:

- data and model checks needed to fail at the stage where someone could act on them;
- downstream systems needed a reliable way to discover approved outputs;
- a run needed a standard report rather than a chat-memory reconstruction;
- scientific policy needed explicit definitions where the software could not infer them;
- ownership had to continue across handoffs rather than ending at "my service returned 200."

The last two are easy to omit from an automation roadmap because they do not look like engineering tasks. They are also where an apparently automated system becomes dependent on somebody remembering what to do.

## What the artifact changed

The dependency map gave us a more honest object to manage.

It separated progress on local components from readiness of the whole workflow. A finished service could still sit upstream of an undefined decision. A blocked downstream integration could make several upstream improvements irrelevant to the next end-to-end run. A stale work item could continue to make the roadmap look blocked even after the capability had actually shipped.

None of that required a new platform. It required the work to be represented at the same grain as the operating problem.

I do not have a defensible productivity gain or before-and-after cycle-time number for this project, and I would not infer one from the number of automated steps. The concrete result I trust is narrower: we found that a reliability criterion we were managing as future execution had never actually begun, because the dependencies needed to observe it were not yet in place.

That is a useful failure to find on a planning board instead of during a scientific run.

The broader point is simple enough: automation removes manual work. Productionization removes ambiguity about whether the work happened correctly.
