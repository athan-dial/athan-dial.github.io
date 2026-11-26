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
figure_title: "From Fragmented Evidence to Decision-Ready Intelligence"
diagram: "work-products/talos/workflow.svg"
diagram_alt: "Four stages run left to right: collect, recognize, resolve and judge, remember and deliver. Entity branches converge into observations. Every accepted observation passes through analyst review and a Ready to use decision; held evidence returns for review. Program records feed delivery surfaces, with a dashed next-review loop back to sources. The numbered walkthrough gives the complete text description."
overview: "Scientific analysts rebuild the same competitive picture every time a new question comes in: who is developing what, and what changed since last time. TALOS keeps that picture. It turns public reports into one record per competing program, links every claim to its sources, and lets an analyst see what changed and brief leadership without starting over."
role:
  led: "Product framing, scope, cross-team communication and milestones, and bringing scientific users' feedback into the work."
  built: "The full working prototype, end to end."
  with: "Data-science and engineering team leads on my product team, who owned source collection, entity recognition, the observation model and the analyst interface."
figure_caption: "Generalized product workflow."
figure_note: "Every claim carries its sources: source → observation → program → briefing."
stages:
  - title: Collect
    description: "Find public reports and keep each source and its date."
    decision_label: Keep the trail through merging
    decision_anchor: provenance
  - title: Recognize
    description: "Match every company, compound, target and indication mentioned to one shared identity."
    decision_label: Organize around the program
    decision_anchor: programs
  - title: Resolve and judge
    description: "Merge overlapping reports into one observation. An analyst checks the support, then accepts it or holds it."
    decision_label: Make uncertainty reviewable
    decision_anchor: judgment
  - title: Remember and deliver
    description: "Add each accepted observation to its program's record. Landscapes, timelines and briefs draw on those records and carry the sources with them."
    decision_label: Earn trust before expanding scope
    decision_anchor: scope
decisions:
  - title: "Organize around the program"
    anchor: programs
    problem: "A feed shows new reports but leaves the analyst to rebuild the picture."
    call: "I framed the program, one developing effort, as the unit the product is built around, so each observation attaches to a record that grows."
    cost: "The product needs reliable entity matching and a way to keep incomplete records until the picture improves."
  - title: "Keep the trail through merging"
    anchor: provenance
    problem: "Several reports often describe the same development."
    call: "A merged observation keeps every contributing source, so an answer can still be checked after duplicates are removed."
    cost: "A richer evidence model and more interface detail. One convenient citation would be simpler, but it could hide sources that disagree."
  - title: "Make uncertainty reviewable"
    anchor: judgment
    problem: "A confident sentence can hide weak evidence."
    call: "I set the boundary that every observation shows its support and the analyst's judgment. Machine help is limited to merging repeats; an expert decides what gets used."
    cost: "Review time and slower throughput, in exchange for a clear basis for using each observation."
  - title: "Earn trust before expanding scope"
    anchor: scope
    problem: "The first release covered an evidence packet, entity matching and a plain analyst interface."
    call: "Advanced visualization and replacing the analyst's workflow waited. I coordinated scope and stakeholder feedback across the workstreams."
    cost: "A narrower release, whose test was whether the intelligence deserved to be used."
outcomes:
  - "A working prototype of the full product, built by me."
  - "A platform brief, a written split of workstream responsibilities, and data contracts between the teams."
  - "The team's build: source records, entity models, analyst review checkpoints and briefing collections."
reflections:
  worked: "Organizing around the program and keeping every source through merging gave the product one record an analyst can inspect, instead of a feed to reconstruct."
  didnt: "I tested the briefing, the thing leadership actually reads, later than the underlying records."
  grow: "Test the briefing alongside the records, then work out how current state, changes since the last review and upcoming evidence fit in one package, and whether that package changes what the reader does next."
disclosure_note: "Review copy · Generalized workflow; no proprietary scientific examples. Product name and professional attribution await employer disclosure approval."
---
