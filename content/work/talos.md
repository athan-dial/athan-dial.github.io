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
overview: "TALOS is a competitive-intelligence product for scientific analysts and leadership teams. It addresses a recurring problem: each new question requires someone to reconcile scattered reports and rebuild the evidence trail. The product direction is to turn public-source material into persistent competitive program records, so analysts can revisit what changed, inspect its support, and prepare an informed briefing without starting over."
ownership: "I led product framing, scope, cross-team communication, and milestone facilitation, and brought scientific-user feedback into the work. Data-science and engineering colleagues owned source operations, entity recognition, observation semantics, and analyst-surface implementation."
figure_title: "From Fragmented Evidence to Decision-Ready Intelligence"
diagram: "work-products/talos/workflow.svg"
diagram_alt: "Public sources are discovered and ingested, then branch into recognition of companies and compounds and of targets and indications. Both converge into resolved observations. Evidence assessment and analyst review precede persistent program records, which feed landscapes, timelines, and leadership briefs. Source links travel throughout."
figure_caption: "Generalized product workflow, not a deployment map. The full delivery vision includes landscapes, timelines, and leadership briefings; their inclusion does not imply every surface shipped in the MVP. Scroll the figure on mobile."
disclosure_note: "Review copy · Generalized workflow; no proprietary scientific examples. Product name and professional attribution await employer disclosure approval."
---

<h2 id="decisions">04 / Product and design decisions</h2>
<div class="wp-decisions">
<div class="wp-decision">

### Organize around the program

A feed can show new reports while leaving the analyst to reconstruct the competitive picture. I helped frame the program as the durable unit of navigation: observations accumulate around a developing effort. This supports continuity across reviews, but requires explicit entity resolution and a way to preserve incomplete records as knowledge improves.

</div>
<div class="wp-decision">

### Preserve the trail through consolidation

Several reports can describe the same underlying development. The product contract requires consolidated observations to retain all contributing sources. That makes an answer inspectable after deduplication. The trade-off is a richer evidence model and more interface detail; a single convenient citation would be simpler, but could hide conflicting support.

</div>
<div class="wp-decision">

### Make uncertainty reviewable

A confident sentence can obscure weak evidence. I helped establish a product boundary in which evidence support and analyst judgment remain visible. Narrow machine-assisted consolidation can reduce repetition; expert review remains consequential. This accepts review effort and slower throughput in exchange for a clearer basis for using an observation.

</div>
<div class="wp-decision">

### Earn trust before expanding scope

The initial scope emphasized an evidence packet, entity resolution, and a plain analyst surface. Advanced visualization and workflow replacement were deferred. I coordinated scope and stakeholder feedback across the workstreams. This reduced the breadth of the first release while concentrating the test on whether the underlying intelligence deserved to be used.

</div>
</div>

<h2 id="evidence">05 / Evidence and outcomes</h2>

The project produced a platform brief, workstream responsibilities, data contracts, and an implementation containing provenance records, entity models, analyst review checkpoints, and briefing collections. These are concrete product and engineering artifacts; they do not establish the quality of every generated claim or the usefulness of the complete workflow.

The validation plan called for comparing consolidated observations against expert-curated examples and testing whether an analyst could use the evidence in a real presentation. Those are intended acceptance criteria. This case makes no measured claim about adoption, time saved, accuracy, or business impact.

<details>
<summary>Discuss architecture and evaluation</summary>

A useful evaluation separates entity identity, observation consolidation, evidence completeness, and usefulness to the reader. Several agreeing articles may repeat one original source. An evaluation should therefore inspect the independence of support, retain disagreements, and test whether an analyst can trace a briefing claim back to its contributing evidence. The repository demonstrates implementation work; a benchmark result would require a defined corpus, adjudication rules, and recorded errors.

</details>

<h2 id="reflections">06 / Reflections</h2>

The lesson I draw is that a durable evidence model only creates value when it serves a recurring decision. I would test the final briefing artifact earlier, alongside the underlying records. Future work should investigate how current state, changes since the last review, and upcoming evidence fit together—then evaluate whether that package changes what the reader does next.
