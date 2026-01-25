---
title: "Build vs Buy: Strategic Analysis for Analog Generation"
date: 2025-11-15
description: "Quantitative analysis guiding $250k+ partnership decision — ROI modeling revealed internal model needed 50× improvement, recommended hybrid approach balancing near-term progress with long-term IP"
problem_type: "product-strategy"
scope: "organization"
complexity: "high"
tags: ["strategic-analysis", "build-vs-buy", "roi-modeling", "executive-communication"]
---

## Context

Late 2025 brought Montai to a strategic crossroads. Our core IP hinged on generating novel analog compounds ("Anthrologs") through proprietary AI models — but the internal generative model produced ~360M virtual compounds with uncertain synthetic feasibility. Meanwhile, XtalPi offered curated, higher-confidence AI-suggested compounds from external sources.

**Facts:**
- Late 2025: Montai's core IP = generating novel analog compounds ("Anthrologs")
- Problem: Internal generative model produced ~360M virtual compounds, but many not synthesizable/uncertain value
- Alternative: XtalPi (external partner) offered curated AI-suggested compounds (more drug-like)
- Stakes: Resource allocation - invest in internal model improvement OR buy external suggestions?

The CSO (Margo) needed an evidence-based recommendation by December 1, 2025. This wasn't a philosophical debate about build vs buy — it was a portfolio allocation decision with measurable ROI implications. I had three weeks to model the tradeoffs quantitatively and make a clear recommendation.

## Ownership

I owned:
- Comparative analysis design (internal vs external compound quality)
- ROI modeling (compounds accessible per $ investment)
- Visualization strategy (UMAP plots, complexity charts for exec communication)
- Presentation to CSO (Dec 1 deadline)

I influenced:
- Strategic direction (hybrid approach recommendation)
- ACN model improvement priorities (with Duminda, ML scientist)
- Partnership terms with XtalPi (data informed negotiations)

## Decision Frame

**Problem statement:**

Allocate resources between internal generative model improvement and external compound partnerships to maximize discovery speed while managing IP and cost tradeoffs, constrained by:
- Internal generative model accuracy too low (needed ~50× improvement)
- XtalPi partnership cost vs potential value unclear
- Time pressure (programs need compounds NOW, not in 1 year)

**Options considered:**

**Option A: Rely internally (double down on ACN model)**
- Pros: IP stays in-house, potentially massive unique space
- Cons: Model needs significant improvement, compounds have uncertain synthetic feasibility
- Risk: Wasted time on low-quality suggestions, delays programs

**Option B: Outsource analog suggestions (XtalPi)**
- Pros: Immediate high-quality suggestions, less internal R&D
- Cons: Cost, reliance on external, less proprietary
- Risk: Dependence on partner, potential quality gaps

**Option C: Hybrid (external for near-term + internal for long-term)**
- Pros: Don't miss opportunities today while investing in tomorrow
- Cons: More complex, requires patience for internal improvements
- Risk: Internal improvements never materialize (sunk cost)

**Decision:** Recommended Option C because:

[FACTS from archaeology p.14-15:]

**Quantitative analysis:**
1. Head-to-head comparison (STAT6, OX40L, TL1A):
   - Filtered both Montai Anthrologs + XtalPi space to top quality
   - Compared predicted activity and novelty via UMAP diversity plots
   - XtalPi covered chemical areas Montai didn't (complementary)

2. ROI model ("napkin math"):
   - $250k building block investment → 0.9-12.4M Anthrologs accessible
   - Scales with higher budgets, but diminishing returns without model improvement
   - Calculated ACN precision gain needed: ~50× improvement for full generative utility

3. Strategic implication:
   - External (XtalPi) fills gap NOW while ACN improves
   - Set goal: If cACN v2 achieves precision by mid-2026, reduce external dependency
   - Hybrid de-risks both options (not all-in on unproven internal model)

**Constraints:**
- Dec 1, 2025 deadline to CSO (time-boxed analysis)
- 360M Montai compounds vs unknown XtalPi set size (asymmetric comparison)
- Internal model improvement timeline uncertain (Duminda's capacity)

## Outcome

**Primary outcome:**

Guided strategic decision that balanced near-term progress with long-term IP:
- Immediate: Montai allocated budget to XtalPi-sourced compounds for 2-3 programs
- Long-term: Tasked data/ML team to focus on cACN v2/v3 improvements (precision goal)
- Validation: Some XtalPi compounds became hits in early 2026 (justified spend)

The hybrid approach avoided overcommitting in either direction. Going all-in on internal models would have delayed programs by 6-12 months while we chased a 50× accuracy improvement. Going fully external would have ceded our core IP advantage. The quantitative analysis made it clear that both paths had merit — and that combining them de-risked the strategy while keeping options open.

**Metrics:**
- Analysis timeframe: ~3 weeks (Nov-Dec 2025)
- Executive decision: Made by Dec 1, 2025 (met deadline)
- Outcome validation: XtalPi hits in Q1 2026 + cACN v2 improved 2× by mid-2026 (on track to 50×)

**Strategic artifacts:**
- ROI model spreadsheet (investment scenarios)
- UMAP diversity plots (XtalPi vs Montai chemical space)
- Complexity charts (synthetic accessibility comparison)
- Presentation deck to CSO (evidence-based recommendation)

**Second-order effects:**
- Template for future build vs buy decisions (quantitative framework reused)
- Strengthened partnership with XtalPi (data-driven collaboration)
- Internal team focused on high-leverage improvements (not boiling ocean)

**Limitations acknowledged:**
- Analysis timeboxed (deeper investigation possible but not needed for decision)
- Model improvement uncertainty (50× gain ambitious, may take longer)
- Hybrid complexity (managing two paths simultaneously)

## Reflection

**What I'd do differently:**

Three strategic analysis lessons emerged in retrospect:

- Start internal model improvements earlier (not wait for crisis/comparison)
- Engage chemists more in generative model design (synthetic feasibility blindspot)
- Pilot XtalPi with one program before org-wide (reduce risk)

The first was a failure of proactive planning — we knew the ACN model had accuracy issues but didn't prioritize improvements until external pressure forced the comparison. The second repeated a pattern from the nomination scaling work: treating chemist expertise as validation rather than design input. The third was standard risk mitigation we should have applied but didn't.

**What this taught me about decision-making:**

This analysis validated three principles about strategic framing:

- Quantitative framing transforms opinions into evidence — the ROI model gave the CSO a concrete basis for decision rather than competing gut feelings about build vs buy
- Build vs buy is rarely binary — hybrid approaches often dominate pure strategies, especially when timelines and uncertainty favor hedging
- Executive decisions need clear options plus a recommendation — presenting "here's the data, you decide" abdicates leadership; executives want your synthesis and recommendation backed by evidence

**How this informs future decisions:**

These meta-takeaways now guide my approach to strategic analysis:

- Always model tradeoffs quantitatively when stakes are high — even "napkin math" beats handwaving about strategic direction
- Build vs buy is a portfolio decision, not an all-in bet — maintaining optionality through hybrid approaches preserves strategic flexibility
- Strategic patience requires near-term wins to buy time for long bets — the hybrid worked because XtalPi compounds delivered wins while we improved internal models

---

**Factual Evidence Citations:**
- Project Inventory p.9 (XtalPi collaboration entry)
- Decision Systems p.14-15 (detailed analysis narrative)
- Slack DM (William→Athan analysis goal)
- Jake Ombach Slack (quantitative scenario results)
