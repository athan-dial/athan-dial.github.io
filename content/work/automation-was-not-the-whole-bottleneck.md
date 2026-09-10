---
title: "Automation Was Not the Whole Bottleneck"
type: work
work_kind: proof-note
narrative_voice: documentary
date: 2026-09-10
summary: "A recurring scientific pipeline looked like an automation problem. Some gaps were software. Others were decisions nobody had encoded yet: what counted as a valid run, where QC belonged, what evidence proved completion, and who owned a failed handoff. Mapping both kinds of dependency changed the project."
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

The project started as recurring scientific-pipeline automation.

The first useful reframe was that automation was only one class of blocker.

Some gaps were exactly what an automation roadmap would predict: a manual kickoff, a missing handoff between systems, quality checks that happened too late, outputs that another step could not reliably discover. Those are software problems. They can be assigned, built, and tested.

Other gaps looked similar on a project plan but were fundamentally different. What counted as a valid run? Which failure should stop the pipeline? Which result should be recorded for the next person? Who owned the handoff when the software worked but the scientific policy was still ambiguous?

No amount of orchestration code could answer those questions by itself.

## Map the work as one dependency system

The pipeline crossed several teams and technical surfaces, from data preparation through model execution and into a downstream scientific workflow. Different people owned different pieces. Some work was already underway, some existed only as a requirement, and some important dependencies were not connected to the main plan at all.

The end-to-end map included handoffs, manual steps, quality-control points, decision points, and the work items meant to remove each gap. The dependencies were then connected instead of treating every ticket as an independent unit of progress.

That exposed a critical path, but more importantly it exposed two different kinds of blocker living on the same path.

A software dependency can be late.

A policy dependency can be undefined.

Those need different interventions.

## A reliability target had become project folklore

The team had discussed proving reliability through a recurring sequence of clean runs. On the planning surface, that criterion existed. It looked like something that could become green or red with enough execution.

The evidence showed that the clock had never actually started.

A critical dependency had remained blocked through the period when those runs were supposed to occur. The standardized report that would have documented each run was not in place either. There was no defensible series of completed cycles to count.

Calling the criterion "at risk" would have been generous to the plan and unhelpful to everyone else. It was not a late experiment. It was an experiment the system had not yet made possible.

The exit criterion was retired and replaced with a smaller observable one: first prove a single clean end-to-end run with the required evidence, then earn the recurring cadence.

That changed the project from catching up to a schedule into establishing the measurement layer the schedule had assumed.

## Productionization includes policy

A pipeline is not productionized because every step has an API and a scheduler. It is productionized when the organization can tell what happened, whether it was acceptable, and what happens next when it was not.

For this workflow, software and policy had to converge:

- data and model checks needed to fail at the stage where someone could act on them;
- downstream systems needed a reliable way to discover approved outputs;
- a run needed a standard report rather than a chat-memory reconstruction;
- scientific policy needed explicit definitions where the software could not infer them;
- ownership had to continue across handoffs rather than ending at "service returned 200."

The last two are easy to omit from an automation roadmap because they do not look like engineering tasks. They are also where an apparently automated system becomes dependent on somebody remembering what to do.

## Role in the case

Coordinator and workflow mapper. Scope included the end-to-end workflow map, dependency structure, critical-path diagnosis, and the distinction between automation gaps and missing operating policy.

The role also included checking planned exit criteria against the evidence needed to observe them. When an intended recurring-run reliability criterion turned out never to have started, the planning claim changed rather than the evidence being stretched to fit it.

## What the artifact changed

The dependency map created a more honest object to manage.

It separated progress on local components from readiness of the whole workflow. A finished service could still sit upstream of an undefined decision. A blocked downstream integration could make several upstream improvements irrelevant to the next end-to-end run. A stale work item could continue to make the roadmap look blocked even after the capability had actually shipped.

None of that required a new platform. It required the work to be represented at the same grain as the operating problem.

There is no defensible productivity gain or before-and-after cycle-time number for this project, and the number of automated steps does not supply one. The concrete result is narrower: a reliability criterion being managed as future execution had never actually begun because the dependencies needed to observe it were not yet in place.

That is a useful failure to find on a planning board instead of during a scientific run.

Automation removes manual work. Productionization removes ambiguity about whether the work happened correctly.

## Retrospective

I would separate software gaps, policy gaps, and evidence gaps explicitly from the first dependency-map pass. They can occupy the same critical path, but they do not clear in the same way.

I would also define the proof artifact for every reliability criterion at the moment the criterion is created. If nobody can say what evidence will make the criterion true, it is not ready to be managed as a gate.
