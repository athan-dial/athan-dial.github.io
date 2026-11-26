---
title: PrIME
layout: work-product
type: work
date: 2026-11-26
draft: true
status: review
visibility: private
employer_review: pending
work_kind: flagship
summary: "Advisor conversation and deck critique where every supported claim shows its evidence."
description: "A Work Product case study on governed AI critique, provenance, and expert judgment."
timeframe: "2026"
disciplines: "Product management / AI enablement / Evidence and review"
tagline: "Rehearse the hard conversation."
overview: "PrIME is an advisor workspace for executives and business-development leads preparing for an expert or partner conversation. A generic assistant can critique a deck, but cannot show where each point comes from or whether the advisor judges like the expert it represents. PrIME pairs a fluid conversation with a critique that keeps only supported points and states its gaps."
ownership: "I owned the product definition: the job, the trust contract, the success criteria, and the sequence of bets. A scientific advisor and an executive sponsor shaped scope and review. Engineering colleagues built the workspace, the critique pipeline, and the exports."
figure_title: "From a Deck and an Expert to a Critique You Can Trust"
diagram: "work-products/prime/workflow.svg"
diagram_alt: "Four stages run left to right: build advisor, converse, critique and verify, share. A curator promotes an advisor built from sourced claims. A deck joins the conversation, a draft critique is checked by an independent pass, and each point is either supported or stated as a gap, with one dashed revision loop. Supported points reach a readout that feeds exports and a planned handoff, with a dashed planned loop back to the sources. The numbered walkthrough gives the complete text description."
figure_caption: "Generalized product workflow. Outline nodes show exports and a planned handoff; the expert-fidelity check is planned, not measured."
stages:
  - title: Build advisor
    description: "Assemble sources into a profile whose claims each link to evidence; a curator promotes it."
    decision: D2
    decision_label: Measure fidelity before promoting
    decision_anchor: d2-fidelity
  - title: Converse
    description: "Talk strategy with the advisor; attach a deck at any point. Answers stay useful and hedged when evidence is thin."
    decision: D1
    decision_label: Exploratory chat, fail-closed artifacts
    decision_anchor: d1-contract
  - title: Critique and verify
    description: "Draft a critique, check each point in a separate pass, keep what is supported, and state the gaps."
    decision: D1
    decision_label: Exploratory chat, fail-closed artifacts
    decision_anchor: d1-contract
  - title: Share
    description: "A readout a cold recipient can follow, with exports and a labelled path into a general assistant."
    decision: D4
    decision_label: Copy-first handoff
    decision_anchor: d4-handoff
disclosure_note: "Review copy · Generalized workflow; no names, sources, or internal data. Product name and professional attribution await employer disclosure approval."
---

<h2 id="decisions">04 / Product and design decisions</h2>
<div class="wp-decisions">
<div class="wp-decision">

<h3 id="d1-contract">D1 · Exploratory chat, fail-closed artifacts</h3>

Applying one abstention rule to everything turned strategic questions into a wall. I framed two postures: conversation can speculate under a visible hedge, while a critique artifact never carries an unsupported claim. Users now meet two trust models, and have to learn which one they are in.

</div>
<div class="wp-decision">

<h3 id="d2-fidelity">D2 · Measure fidelity before promoting</h3>

The product asks people to trust a named advisor, yet no expert had checked a persona. I pitched a positive control: run a deck a real expert reviewed through that expert's advisor and compare it with what they said, with the generic lens as a control. It delays named-advisor features until the comparison exists.

</div>
<div class="wp-decision">

<h3 id="d3-bets">D3 · Outcome bets, not a ticket list</h3>

A first unaided executive session exposed broken flows, an invisible trust mechanism, and a conversation that was too constrained. I turned a large issue inventory into seven outcome bets sequenced now, next and later, and held a full connector as exploratory. Outcomes are fixed tightly; solutions can change.

</div>
<div class="wp-decision">

<h3 id="d4-handoff">D4 · Copy-first handoff over a connector</h3>

Users may prefer a general assistant's tools. A bounded, previewed handoff keeps provenance inside the product and labels the continuation unverified. The cost is paste-and-open friction; I would revisit only if observed behavior shows that friction is the barrier.

</div>
</div>

<h2 id="evidence">05 / Evidence and outcomes</h2>

The team built a working advisor workspace, a critique pipeline that drafts, independently checks and revises once, and standalone and annotated exports. It was used in an unaided walkthrough with an executive, whose findings drove the sequence of bets in D3.

I make no measured claim about advisor fidelity, adoption, time saved, or decision quality. The fidelity comparison in D2 is a planned instrument, not a result. Success criteria are intended: a first-time user completes the loop without help, and a recipient understands the conclusion from the export alone.

<details>
<summary>Discuss architecture and evaluation</summary>

Separate three questions: is a point grounded in the deck or the advisor's sources, does the advisor judge like the expert, and does the artifact travel. The first is checkable per claim. The second needs ground truth from the real expert, kept out of the corpus used to build the persona, or a good score is circular. The third is tested with a reader who has never opened the product.

</details>

<h2 id="reflections">06 / Reflections</h2>

I learned that trust has to be visible where the user already works, not in a separate dossier. I would run the fidelity comparison before building persona features, not after. Next I want to test whether a critique changes what the presenter does in the room.
