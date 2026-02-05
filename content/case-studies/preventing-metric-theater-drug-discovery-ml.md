---
title: "Preventing Metric Theater in Drug Discovery ML"
date: 2026-01-09
description: "Designed evaluation framework combining offline validation with online performance tracking to de-risk multimillion-dollar compound selection decisions"
problem_type: "product-strategy"
scope: "team"
complexity: "high"
tags: ["evaluation-frameworks", "product-strategy", "stakeholder-alignment", "ml-systems"]
---

## Context

Data science teams were presenting accuracy metrics without reliability monitoring, creating false confidence in model predictions for multimillion-dollar compound selection decisions. The stakes were high: each compound decision represented $2M+ in development costs, but teams lacked visibility into model performance degradation over time.

This work lived in the drug discovery ML platform, where prediction models guide which compounds advance to expensive in-vitro and in-vivo testing phases. My role was to own the evaluation framework design and establish decision forums with clear ownership.

## Ownership

I owned:
- Evaluation framework architecture (offline + online validation design)
- Decision forum structure and cadence
- Monitoring dashboard specifications and success criteria

I influenced:
- Model architecture choices (collaborated with ML engineering)
- Compound selection thresholds (aligned with biology and chemistry teams)
- Resource allocation for monitoring infrastructure (partnered with platform team)

## Decision Frame

**Problem statement:** We needed reliable model performance tracking for compound selection decisions because false positives cost $2M+ per compound, but we were constrained by limited labeled data, 6-month feedback loops, and no existing monitoring infrastructure.

**Options considered:**

**Option A: Offline validation only**
- Pros: Fast to implement, uses existing test sets
- Cons: No visibility into production drift, misses real-world degradation
- Risk: Models degrade silently, false confidence in predictions

**Option B: Online monitoring only**
- Pros: Real-time visibility, catches degradation early
- Cons: Requires production infrastructure, longer implementation time
- Risk: No baseline validation, unclear what "degradation" means

**Option C: Combined framework (offline + online)**
- Pros: Baseline validation + ongoing monitoring, catches both training issues and production drift
- Cons: More complex, requires coordination across teams
- Risk: Implementation complexity, potential for conflicting signals

**Decision:** Chose Option C because:
1. Compound decisions require both initial validation (offline) and ongoing confidence (online)
2. 6-month feedback loops mean we need early warning signals, not just retrospective analysis
3. The infrastructure investment pays off across multiple models and use cases

**Constraints:**
- Limited labeled data for validation sets (biology team bandwidth)
- 3-month timeline to show value (executive commitment window)
- No existing monitoring infrastructure (platform team capacity)

## Outcome

**Primary outcome:** De-risked $2M+ in compound development by catching model degradation 3 months earlier than the previous process allowed. The framework identified performance drift in two models before they influenced compound selection decisions.

**Guardrails maintained:**
- Model accuracy stayed within ±2% of baseline
- Prediction latency remained under 100ms (required for interactive workflows)
- False positive rate stayed below 5% threshold

**Second-order effects:**
- Established evaluation framework as standard for all discovery ML models
- Created reusable monitoring infrastructure used by 3 other model teams
- Improved stakeholder confidence in ML-driven decisions (measured via survey)

**Limitations acknowledged:**
- Early detection required 2-3 months of production data to establish baselines
- Some false alarms occurred during initial calibration (resolved through threshold tuning)
- Framework doesn't prevent all bad decisions, but significantly reduces risk

## Reflection

**What I'd do differently:**
- Start with a smaller pilot model to validate the framework before scaling
- Involve biology team earlier in validation set design (reduced rework)
- Build monitoring dashboards in parallel with framework design (faster time-to-value)

**What this taught me about decision-making:**
- Evaluation frameworks are product decisions, not just technical choices
- Stakeholder alignment on "what good looks like" is critical before building
- Combining offline and online validation creates defensible decision systems

**How this informs future decisions:**
- Always design evaluation before building models (not after)
- Establish decision forums with clear owners before problems arise
- Invest in reusable infrastructure when multiple teams face similar challenges
