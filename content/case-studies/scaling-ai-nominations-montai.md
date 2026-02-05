---
title: "Scaling AI-Driven Drug Nominations from 250 to 7,000 Compounds"
date: 2023-06-01
description: "Built pipeline scaling compound nominations 26× while improving hit rates from 5% to 27% — phased rollout strategy balanced speed with quality gates"
problem_type: "technical-architecture"
scope: "organization"
complexity: "high"
tags: ["ml-systems", "data-pipelines", "product-strategy", "stakeholder-alignment"]
---

## Context

Early 2023 presented a defining challenge: Montai's AI models could predict activity across millions of compounds, but manual library creation processes were bottlenecked at ~250 compounds per program. The central question wasn't whether AI could generate predictions — it was whether we could build a scalable system that maintained scientific rigor while expanding the search space 20×.

**Facts:**
- Baseline: 100’s of compounds, chosen manually for screening from within existing library
- Stakes: Scale 10× to 100× per program to enabled by bioactivity ML models
- Environment: Early-stage biotech, unproven concept
- My role: First data science/product hire, architected pipeline

## The challenge
> How do you architect a multi-objective decision system, that provides an optimal starting point for drug discovery funnels, is understandable by all the key decision-makers at the organization?

This was a multi-faceted problem — ML scientists wanted maximum chemical diversity, medicinal chemists needed synthetic feasibility, and program leads to ensure they didn’t waste their team’s time on a batch of inactive compounds. Each stakeholder brought valid constraints — the pipeline needed to serve all groups while delivering high quality recommendations that would bolster confidence in the AI approach.

## The solution

I owned:
- **End-to-end ‘nomination’ pipeline architecture:** Our team constructed an orchestrated SQL pipeline that enabled fully traceable, human-interpretable 
- ML integration strategy (model outputs → analytics)
- Data quality framework for predictions
- Phased rollout strategy (MVP → scale → quality)

I influenced:
- Model selection criteria (with Duminda Ranasinghe, Lead ML Scientist)
- Nomination criteria per program (with Jake Ombach, Computational Biologist)
- External data partnerships (XtalPi, vendor libraries)

## Decision Frame

**Problem statement:**

Build a data pipeline that scales compound nominations 20× while maintaining or improving experimental hit rates, constrained by:
- Unproven AI prediction quality
- Limited ML engineering capacity (small team)
- Need for rapid learning cycles (not perfect first try)

**Options considered:**

**Option A: Conservative scale (500-1000 nominations)**
- Pros: Lower risk, manageable if quality issues emerge
- Cons: May miss opportunities in vast chemical space
- Risk: Underutilize AI capability, slow learning

**Option B: Aggressive scale (10,000+ immediately)**
- Pros: Maximum coverage of chemical space
- Cons: Drowning in low-quality candidates, scientist overload
- Risk: Lost trust if hit rate crashes, wasted experimental capacity

**Option C: Phased scaling with quality gates**
- Pros: Learn at each phase, adjust criteria, build confidence
- Cons: More complex coordination, requires patience
- Risk: Slower initial progress

**Decision:** Chose Option C because:

[FACTS from archaeology p.20-21:]
1. Phase 1 (2023): Baseline nomination (prove concept with known compounds)
2. Phase 2 (2024): Expand to 1000+ (maximize learning via generative + commercial)
3. Phase 3 (late 2024): Quality filters (diversity, confidence thresholds)

Sequencing logic: Prove → scale → refine (not perfect upfront)

**Constraints:**
- Pipeline latency: Manual processes took 2-3 days → needed automation
- Data volume: 10M compounds (2023) → 258M predictions (2024)
- Team capacity: Solo data lead initially, growing to 5-6 by 2024

## Outcome

**Primary outcome:**

Scaled from 250 → 6,500+ nominations per program (26× increase) while IMPROVING hit-to-lead rates:
- TNFR1: 27% hit-to-lead (vs ~5% baseline)
- Multiple programs advanced to lead optimization faster

The significance: This wasn't just volume scaling — quality improved alongside throughput. By implementing phased quality gates and leveraging diverse data sources (generative models, commercial libraries, XtalPi partnerships), we validated that AI-driven discovery could outperform manual selection. This became Montai's core operational advantage and a key narrative for fundraising.

**Metrics:**
- Nomination throughput: 250 → 5,000-7,000 per program (Q4 2024)
- Hit-to-lead conversion: 5% → 15-30% range
- Pipeline latency: 2-3 days → same-day updates
- Model predictions: 10M → 258M compounds scored

**Guardrails maintained:**
- Nomination quality didn't degrade with scale (improved filters offset volume)
- Scientist time per compound review stayed manageable (self-service dashboards)
- Data infrastructure handled 10× load increase without major incidents (until STAT6 - separate case)

**Second-order effects:**
- Enabled XtalPi partnership analysis (build vs buy decision)
- Created reusable pipeline for future programs (MARS, cACN v2/v3)
- Demonstrated industrialized discovery to investors (fundraising narrative)

**Limitations acknowledged:**
- Diminishing returns emerged at ~5K nominations (quality > quantity phase needed)
- Generated Anthrologs initially unusable (separate failure/pivot story)
- Pipeline automation never fully complete (some manual triggers remained)

## Reflection

**What I'd do differently:**

Looking back at the archaeology of this work, three decisions stand out as suboptimal:

- Start with tighter nomination criteria earlier (wasted effort on low-probability compounds in Phase 2)
- Invest in monitoring infrastructure upfront (reactive vs proactive on data quality)
- Engage chemists more in generative model development (synthetic feasibility blindspot)

The first two were classic "move fast and learn" tradeoffs that proved correct in hindsight — we needed the volume data to understand quality needs. The third was a genuine miss: treating synthetic feasibility as a post-generation filter rather than baking it into model training cost us months.

**What this taught me about decision-making:**

Three principles emerged that I've since applied consistently:

- Phased rollouts with learning gates beat perfect upfront design — you can't architect your way out of uncertainty, you build to learn
- Volume metrics mislead without quality tracking — nomination count was a vanity metric until we paired it with hit-to-lead conversion
- Stakeholder confidence requires visible iteration — scientists trusted the pipeline because they saw us adjust criteria based on their feedback, not because the first version was perfect

**How this informs future decisions:**

These lessons directly shaped my approach to subsequent projects:

- Always define success criteria per phase before executing — the Learning Agenda framework codified this
- Build quality frameworks alongside feature development, not after crises — the STAT6 incident reinforced this
- Balance exploration (maximize learning) with exploitation (optimize known strategies) — this framing now guides my portfolio thinking

---

**Factual Evidence Citations:**
- Drug Project Overviews.xlsx (nomination counts per program)
- 2024 Mid-Year Review (pipeline automation goals)
- Quantitative Outcomes Inventory p.30 (metrics table)
- Product Strategy case study p.20-21 (phasing logic)
