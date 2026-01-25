---
title: "Scaling AI-Driven Drug Nominations from 250 to 7,000 Compounds"
date: 2023-06-01
description: "[VOICE: Brief summary of nomination scaling]"
problem_type: "technical-architecture"
scope: "organization"
complexity: "high"
tags: ["ml-systems", "data-pipelines", "product-strategy", "stakeholder-alignment"]
---

## Context

[VOICE: Problem space intro]

**Facts:**
- Baseline: 250 compounds nominated manually (NRF2, 2023)
- Stakes: Scale to 1000+ per program to enable AI-driven discovery
- Environment: Early-stage biotech, unproven nomination concept
- My role: First data science/product hire, architected pipeline

[VOICE: Stakeholder complexity, ambiguity]

## Ownership

I owned:
- End-to-end nomination pipeline architecture
- ML integration strategy (model outputs → analytics)
- Data quality framework for predictions
- Phased rollout strategy (MVP → scale → quality)

I influenced:
- Model selection criteria (with Duminda Ranasinghe, Lead ML Scientist)
- Nomination criteria per program (with Jake Ombach, Computational Biologist)
- External data partnerships (XtalPi, vendor libraries)

## Decision Frame

**Problem statement:** [VOICE: How to structure]

Scale compound nominations 20× while maintaining/improving hit rates, constrained by:
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

[VOICE: Interpret significance]

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

[VOICE: Specific regrets from archaeology insights]

- Start with tighter nomination criteria earlier (wasted effort on low-probability compounds in Phase 2)
- Invest in monitoring infrastructure upfront (reactive vs proactive on data quality)
- Engage chemists more in generative model development (synthetic feasibility blindspot)

**What this taught me about decision-making:**

[VOICE: Meta-lessons]

- Phased rollouts with learning gates >>> perfect upfront design
- Volume metrics mislead without quality tracking (hit rates matter more than count)
- Stakeholder confidence requires visible iteration (not just end results)

**How this informs future decisions:**

[VOICE: Forward-looking]

- Always define success criteria per phase before executing
- Build quality frameworks alongside feature development (not after crises)
- Balance exploration (maximize learning) with exploitation (optimize known strategies)

---

**Factual Evidence Citations:**
- Drug Project Overviews.xlsx (nomination counts per program)
- 2024 Mid-Year Review (pipeline automation goals)
- Quantitative Outcomes Inventory p.30 (metrics table)
- Product Strategy case study p.20-21 (phasing logic)
