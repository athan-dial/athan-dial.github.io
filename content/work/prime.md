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
overview: "A generic assistant can critique a deck, but cannot show where each point comes from or whether the advisor judges like the expert it represents. PrIME is an advisor workspace for executives and business-development leads preparing for an expert or partner conversation. It pairs a fluid conversation with a critique that keeps only supported points and states its gaps."
figure_title: "From a Deck and an Expert to a Critique You Can Trust"
diagram: "work-products/prime/workflow.svg"
diagram_alt: "Four stages run left to right: build advisor, converse, critique and verify, share. A curator promotes an advisor built from sourced claims. A deck joins the conversation, a draft critique is checked by an independent pass, and each point is either supported or stated as a gap, with one dashed revision loop. Supported points reach a readout that feeds exports and a planned handoff, with a dashed planned loop back to the sources. The numbered walkthrough gives the complete text description."
role:
  led: ["Product definition", "The job", "Trust contract", "Success criteria", "Sequence of bets"]
  with:
    who: "A scientific advisor, an executive sponsor and an engineering team, who"
    owned: ["Shaped scope and review", "Built the workspace", "Built the critique pipeline", "Built the exports"]
figure_caption: "Generalized product workflow."
figure_note: "Every point in a critique shows its support or states a gap."
stages:
  - title: Build advisor
    description: "Assemble sources into a profile whose claims each link to evidence; a curator promotes it."
    decision_label: Measure fidelity before promoting
    decision_anchor: fidelity
  - title: Converse
    description: "Talk strategy with the advisor; attach a deck at any point. Answers stay useful and hedged when evidence is thin."
    decision_label: Exploratory chat, fail-closed artifacts
    decision_anchor: contract
  - title: Critique and verify
    description: "Draft a critique, check each point in a separate pass, keep what is supported, and state the gaps."
    decision_label: Exploratory chat, fail-closed artifacts
    decision_anchor: contract
  - title: Share
    description: "A readout a cold recipient can follow, with exports and a labelled path into a general assistant."
    decision_label: Copy-first handoff
    decision_anchor: handoff
decisions:
  - title: "Exploratory chat, fail-closed artifacts"
    anchor: contract
    stage: 2
    problem: "Applying one abstention rule to everything turned strategic questions into a wall."
    call: "I framed two postures: conversation can speculate under a visible hedge, while a critique artifact never carries an unsupported claim."
    cost: "Users meet two trust models and have to learn which one they are in."
  - title: "Measure fidelity before promoting"
    anchor: fidelity
    stage: 1
    problem: "The product asks people to trust a named advisor, yet no expert had checked a persona."
    call: "I pitched a positive control: run a deck a real expert reviewed through that expert's advisor and compare it with what they said, with the generic lens as a control."
    cost: "Named-advisor features wait until the comparison exists."
  - title: "Outcome bets, not a ticket list"
    anchor: bets
    stage: 3
    problem: "A first unaided executive session exposed broken flows, an invisible trust mechanism, and a conversation that was too constrained."
    call: "I turned a large issue inventory into seven outcome bets sequenced now, next and later, and held a full connector as exploratory."
    cost: "Outcomes are fixed tightly while solutions can change, so the roadmap reads less like a plan."
  - title: "Copy-first handoff over a connector"
    anchor: handoff
    stage: 4
    problem: "Users may prefer a general assistant's tools."
    call: "A bounded, previewed handoff keeps provenance inside the product and labels the continuation unverified."
    cost: "Paste-and-open friction. I would revisit only if observed behavior shows that friction is the barrier."
outcomes:
  - title: "A working advisor workspace"
    icon: layout-dashboard
    status: built
  - title: "A critique pipeline"
    note: "Drafts, independently checks and revises once"
    icon: git-merge
    status: built
  - title: "Standalone and annotated exports"
    icon: file-text
    status: built
  - title: "An unaided executive walkthrough"
    note: "Its findings drove the sequence of bets"
    icon: users
    status: built
reflections:
  worked: "Putting the trust mechanism where the user already works, instead of in a separate dossier."
  didnt: "I would run the fidelity comparison before building persona features, not after."
  grow: "Test whether a critique changes what the presenter does in the room."
disclosure_note: "Review copy · Generalized workflow; no names, sources, or internal data. Product name and professional attribution await employer disclosure approval."
---
