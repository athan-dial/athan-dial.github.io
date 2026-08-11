---
title: "AI research that actually cites sources"
type: note
date: 2026-04-06
summary: "A fake citation in a product brief forced the switch: parallel pulls from PubMed, preprints, and trials, then tables with DOIs I can open before I repeat a number."
status: published
visibility: public
themes: [expert-workflows, reliable-ai-systems]
source_url: https://athan-dial.github.io/agency/dispatches/ai-research-that-actually-cites-sources/
draft: false
---
Last year I repeated a survival statistic I’d pulled from a chat session—sounded authoritative, so I said it in a product brief. Someone asked for the DOI. I searched. The paper wasn’t there. That afternoon I stopped treating model prose as evidence.

Now when I need proof, I run `/research`. Several subagents hit PubMed, bioRxiv, ClinicalTrials.gov, and related indexes in parallel; the synthesizer returns markdown tables with titles, populations, and persistent IDs. Contradictions stay in the packet so I pick the fight on purpose instead of by accident.

**Parallel agents cover the field.** I define 3–4 subtopics and let `/research` spin up a worker for each—parallel sweeps beat serial “summarize this, then summarize that” in my sessions. One hits PubMed for peer-reviewed data, another scans preprints, another searches trial registries, and a fourth gathers mechanistic reviews. Each worker returns a list of papers with titles, authors, dates, and persistent identifiers. I see the terrain before I invest in deep reading.

**Evidence arrives structured.** The output is a markdown table with key findings, populations, sample sizes, and DOIs. Inline commentary links directly to the source rather than asserting “studies show.” When two studies disagree, Claude notes the conflict and includes both references so I can investigate. I copy the table into my working doc and never wonder where a number came from.

**Claims stay verifiable.** If I want to quote a specific hazard ratio, I click the DOI and read the section myself. When I need to share the research packet, the citations travel with it. Nobody has to trust that an assistant hallucinated responsibly. The evidence is inspectable.

**Workflow integrates with review.** After `/research` delivers the packet, I route follow-up tasks to /codex-task for data extraction or to Cowork for slide drafting. The citations remain attached. When legal or medical reviewers ask for provenance, I hand them the same structured output and they can replicate every search.

The first week I paid in prompt wiring and verification habits. Since then I’ve skipped retractions, untraceable numbers, and the trust collapse when legal asks “where did this come from?” I still read the paper before I quote the hazard ratio—but I can open the DOI in one click because the packet was built that way from the start.
