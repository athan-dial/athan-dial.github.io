---
title: "Before the Agent, Build the Benchmark"
type: work
work_kind: proof-note
narrative_voice: documentary
date: 2026-09-10
summary: "A benchmark for scientific decision work came before further agent optimization. The useful part turned out not to be reconstructing the source data. It was defining what a valid decision trace looks like, preserving provenance, and making leakage difficult to hide."
status: draft
evidence_status: mechanism-only
visibility: private
employer_review: pending
featured: false
role: "Benchmark design"
users:
  - "data scientists"
  - "scientific model developers"
themes:
  - reliable-ai-systems
  - product-judgment
canonical_url: ""
draft: true
card_ownership: "Benchmark contract, source-probe decisions, and the boundary between sourced facts and normalized interpretation."
card_measured: "The source probe established that campaign reconstruction was primarily a data-join problem; the harder work was defining the scientific abstraction and evaluation contract."
card_unmeasured: "No agent-performance claim yet. The benchmark is being built specifically so later performance claims have somewhere honest to land."
---

Agent demos often arrive before the benchmark that would tell anyone whether the agent is any good.

In scientific work, that ordering is especially risky.

A plausible answer is cheap. A plausible scientific decision can still depend on the wrong evidence, the wrong stage of an experiment, or information that would not have been available when the decision was actually made.

On a recent project, the evaluation environment came first.

## The data problem was smaller than expected

The source material was public assay-project data: project membership, experimental stages, endpoint definitions, depositor annotations, and observations spread across related records.

At first glance, reconstructing a multi-stage scientific campaign looked like an inference problem. It turned out to be mostly a download-and-join problem.

That was good news, but it also moved the difficulty into clearer view.

Once the records could be connected, the hard questions were different:

- What counts as one campaign rather than several related assays?
- Which source field is an observation, and which is an interpretation added during normalization?
- When two sources disagree about stage or role, what survives into the benchmark?
- At what point in the historical process should an agent be asked to make a decision?
- What information has to be hidden so the evaluation does not leak the answer backward?

Those are benchmark-design questions, not ingestion questions.

## Keep the source and the interpretation separate

One of the first schema decisions was deliberately boring.

A source might contain a free-text role label. Normalizing that label into a controlled vocabulary makes downstream reasoning easier. The dangerous version is to replace the source text with the normalized value and forget that a transformation happened.

The benchmark contract therefore separates three objects: the source text, the normalization assertion, and the normalized term.

That looks more cumbersome until something goes wrong. Then it is the difference between inspecting the benchmark and merely trusting the benchmark builder.

The same principle applies to progression through a campaign. If the benchmark infers that one experimental stage follows another, that relationship should carry the evidence and rule that produced it. An agent can then be evaluated against a trace whose assumptions are visible rather than against a synthetic "ground truth" that has already swallowed them.

## The frontier matters as much as the answer

The benchmark is meant to reconstruct a decision at the point it could actually have been made.

That means the evaluation cannot hand the agent future assay results, later-stage annotations, or downstream outcomes and then congratulate it for recovering the historical decision. The benchmark needs an explicit frontier: this was knowable now; this happened later.

That sounds obvious. In practice, leakage enters through joins, derived fields, labels created after the fact, and datasets assembled for a different purpose.

Leakage safety therefore belongs in the product contract, not in a cleanup pass after the benchmark produces interesting scores.

## Role in the case

Benchmark design. Scope included the benchmark contract, source-probe decisions, the historical decision frontier, the separation between sourced assertions and normalized interpretation, and the reconstruction rules allowed to create derived relationships.

The source probe also changed the allocation of product attention. Once campaign reconstruction collapsed into a tractable data-join problem, the harder work was no longer clever reconstruction. It was the scientific abstraction and the benchmark boundary.

## Why build this before the agent?

Because otherwise agent development changes the test.

Starting with the agent creates a strong temptation to build evaluation examples around the cases it already handles well. When examples fail, the task can drift, more context can be added, or the scoring rule can be adjusted until the result feels sensible.

A benchmark built first can still be wrong. The difference is that its assumptions can be reviewed before they become entangled with the thing being evaluated.

That gives the agent somewhere honest to fail.

There is no agent-performance result to report yet. That is intentional. The useful artifact at this stage is a reproducible decision environment with provenance, an explicit evaluation frontier, and rules that make it difficult to grade a model on information from the future by accident.

The benchmark is not the preamble to the work.

For agentic scientific systems, it is part of the work.

## Retrospective

I would keep the same ordering: define the decision trace and the leakage boundary before tuning the agent against them.

The part I would tighten is review of the benchmark itself. A benchmark can become just as self-sealing as a model if its normalization rules and historical frontier are treated as ground truth rather than inspectable choices.
