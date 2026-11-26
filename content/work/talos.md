---
title: TALOS
layout: work-product
type: work
date: 2026-11-26
draft: true
status: review
visibility: private
employer_review: pending
work_kind: flagship
summary: "Making competitive evidence durable, traceable, and useful to the next decision."
description: "A Work Product case study on competitive intelligence, provenance, and analyst judgment."
timeframe: "2026"
disciplines: "Product management / Scientific informatics / Applied AI"
tagline: "Competitive intelligence with an evidence trail."
overview: "Analysts rebuild the same competitive picture for every new question. TALOS keeps that picture: who is developing what, and what changed since last time. It turns public reports into one record per competing program, links every claim to its sources, and lets an analyst brief leadership without starting over."
role:
  led: ["Product framing", "Scope", "Cross-team communication", "Milestones", "Scientific user feedback"]
  built: ["Full working prototype"]
  with:
    who: "Data-science and engineering team leads on my product team, who owned"
    owned: ["Source collection", "Entity recognition", "Observation model", "Analyst interface"]
figure_title: "Architecture of a Continuous Competitive Intelligence Platform"
diagram: "work-products/talos/architecture.svg"
diagram_mobile: "work-products/talos/architecture-mobile.svg"
diagram_inline: true
diagram_alt: "Architecture in four regions, left to right. Four source lanes (news, clinical trial registries, patents, commercial reference data) each take their own processing path: news is extracted into atomic assertions, recognized, resolved, consolidated into events and dated; trials load as records; patents run a classify and summarize lane; reference data is mapped and compared beside the news, never merged. Everything lands in a canonical substrate where documents back assertions, assertions consolidate into events, and events build development programs defined by asset, indication and sponsor, linked to canonical entities, with provenance, confidence, temporal state and revision history. Intelligence products answer what changed, who is developing what, what we know about a program, why we believe it, and let other tools ask. An analyst resolution workbench handles only uncertain matches and feeds corrections back. A continuous loop covers incremental ingestion, event revisions and changes since last review."
figure_caption: "Generalized product architecture. Select a region to jump to the decision behind it."
legend:
  - key: solid
    label: "Solid outline: built"
  - key: dashed
    label: "Dashed outline: documented design"
  - key: dotted
    label: "Dotted outline: planned"
  - key: substrate
    label: "Forest: canonical substrate"
  - key: review
    label: "Citrus: analyst review"
stages:
  - title: Source lanes
    description: "News, clinical trial registries, patents and commercial reference data each take their own path in. Only the news is extracted."
    decision_label: Keep the trail through merging
    decision_anchor: provenance
  - title: Computational intelligence
    description: "News becomes atomic assertions, resolved entities, consolidated events and dated state. Trials load as records, patents run their own lane, and reference data is compared beside the news."
    decision_label: Keep the trail through merging
    decision_anchor: provenance
  - title: Canonical intelligence
    description: "Documents back assertions, assertions consolidate into events, and events build programs: asset × indication × sponsor, with targets attached to assets. Provenance, confidence, time and revisions travel with every record."
    decision_label: Organize around the program
    decision_anchor: programs
  - title: Intelligence products
    description: "A cockpit, a landscape, a program explorer, an evidence explorer and programmatic access, each framed by the question it answers."
    decision_label: Earn trust before expanding scope
    decision_anchor: scope
decisions:
  - title: "Organize around the program"
    anchor: programs
    stage: 3
    region: substrate
    problem: "A feed shows new reports but leaves the analyst to rebuild the picture."
    call: "I framed the program, one developing effort, as the unit the product is built around, so each observation attaches to a record that grows."
    cost: "The product needs reliable entity matching and a way to keep incomplete records until the picture improves."
  - title: "Keep the trail through merging"
    anchor: provenance
    stage: 2
    region: compute
    problem: "Several reports often describe the same development."
    call: "A merged observation keeps every contributing source, so an answer can still be checked after duplicates are removed."
    cost: "A richer evidence model and more interface detail. One convenient citation would be simpler, but it could hide sources that disagree."
  - title: "Make uncertainty reviewable"
    anchor: judgment
    stage: 2
    region: workbench
    problem: "A confident sentence can hide weak evidence."
    call: "I set the boundary that every observation shows its support and its confidence, and that only uncertain matches and conflicts route to an analyst. The rest do not wait for approval."
    cost: "Analyst time goes to the uncertain cases, and confident links rely on the evidence trail instead of a human check."
  - title: "Earn trust before expanding scope"
    anchor: scope
    stage: 4
    region: products
    problem: "The first release covered an evidence packet, entity matching and a plain analyst interface."
    call: "Advanced visualization and replacing the analyst's workflow waited. I coordinated scope and stakeholder feedback across the workstreams."
    cost: "A narrower release, whose test was whether the intelligence deserved to be used."
outcomes:
  - title: "Working prototype of the full product"
    note: "Built by me"
    icon: layout-dashboard
    status: built
  - title: "Platform brief and workstream split"
    note: "Who owns what, in writing"
    icon: file-text
    status: built
  - title: "Data contracts between the teams"
    icon: scroll-text
    status: built
  - title: "The team's build"
    note: "Source records, entity models, analyst review checkpoints, briefing collections"
    icon: database
    status: built
reflections:
  worked: "Organizing around the program and keeping every source through merging gave the product one record an analyst can inspect, instead of a feed to reconstruct."
  didnt: "I tested the briefing, the thing leadership actually reads, later than the underlying records."
  grow: "Test the briefing alongside the records, then work out how current state, changes since the last review and upcoming evidence fit in one package, and whether that package changes what the reader does next."
disclosure_note: "Review copy · Generalized workflow; no proprietary scientific examples. Product name and professional attribution await employer disclosure approval."
---
