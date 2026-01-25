---
title: "From Data Crisis to Data Culture: The STAT6 Incident"
date: 2025-08-15
description: "[VOICE: How data incident became turning point for quality culture]"
problem_type: "execution-leadership"
scope: "organization"
complexity: "high"
tags: ["incident-response", "data-quality", "team-leadership", "postmortem"]
---

## Context

[VOICE: Setting - rapid growth, technical debt accumulating]

**Facts:**
- Mid-2025: STAT6 program discovered predictions missing from warehouse
- Impact: Could not evaluate nominations for critical program ($M+ at stake)
- Symptom: Dashboard DR-3098 failed, analysis queries returned incomplete results
- Urgency: Program decisions on hold, stakeholder trust eroding

[VOICE: Stakes - not just technical bug but organizational credibility]

## Ownership

I owned:
- Incident escalation (raised to "major severity")
- Root cause analysis (traced legacy migration bug)
- Remediation plan design (technical + process fixes)
- Postmortem documentation and dissemination
- New governance framework (data lineage tests, release gates)

I influenced:
- Platform Engineering priorities (PE-3217 ticket)
- Exec communication in Conecta Ops (status updates)
- Cultural shift toward proactive quality (not reactive fixes)

## Decision Frame

**Problem statement:** [VOICE: How to frame]

Respond to data integrity failure blocking critical program while preventing future occurrences, constrained by:
- 258M predictions to backfill (engineering capacity)
- Ongoing programs needing data NOW (can't wait for perfect fix)
- Root cause hidden in legacy code (archaeological debugging needed)

**Options considered:**

**Option A: Quick patch and move on**
- Pros: Fast resolution, unblock STAT6 immediately
- Cons: No systemic improvement, likely repeats
- Risk: Band-aid on deeper quality issues

**Option B: Comprehensive rebuild**
- Pros: Clean slate, eliminate tech debt
- Cons: Months of work, programs stalled
- Risk: Over-engineering, new bugs introduced

**Option C: Targeted fix + governance uplift**
- Pros: Resolve immediate crisis + prevent recurrence via process
- Cons: Requires discipline to implement governance (not just talk)
- Risk: Process additions seen as bureaucracy

**Decision:** Chose Option C because:

[FACTS from archaeology p.28-29:]
1. Immediate: Backfill missing predictions (PE-3217 Jira ticket)
2. Short-term: Add automated lineage checks (task_id = task_name validation)
3. Long-term: Establish data ownership and release gates
4. Cultural: Postmortem as learning artifact (not blame doc)

This balanced urgency with sustainability.

**Constraints:**
- 6-week timeline already impacting program (pressure for quick fix)
- Small Platform Eng team (Rody's capacity)
- Need stakeholder confidence restoration (not just technical solution)

## Outcome

**Primary outcome:**

Resolved STAT6 blocker within 6 weeks AND established data quality culture preventing recurrence:
- Immediate: 258M predictions backfilled, STAT6 nominations resumed
- Systemic: Zero major data incidents post-fix (Q4 2025 - Q1 2026)
- Cultural: Postmortem process adopted (3-page report became template)

[VOICE: Transform crisis into capability upgrade]

**Metrics:**
- Crisis duration: 6 weeks to full resolution
- Data incidents: 3 (2024) → 1 (2025) → 0 (early 2026)
- Governance artifacts: Postmortem doc, automated lineage tests, owner assignments
- Stakeholder confidence: Rebuilt via transparency (Slack, Ops updates)

**Guardrails maintained:**
- Programs never received bad data (halted vs wrong data)
- Trust recovered via candid communication (not spin)
- No blame culture (postmortem focused on systems, not people)

**Second-order effects:**
- Incident response playbook for future crises
- "Data health" monitoring dashboard (proactive vs reactive)
- Mentored junior engineer into "Data QA" owner role
- Template for other teams' postmortems (eng, product)

**Limitations acknowledged:**
- 6-week delay was painful (could've been faster if monitoring existed)
- Some false alarms during post-fix calibration (resolved via threshold tuning)
- Process additions require ongoing discipline (risk of decay)

## Reflection

**What I'd do differently:**

[VOICE: Candid regrets]

- Heeded early Slack warnings (Sep-Oct 2024) about ID confusion
- Built monitoring infrastructure proactively (not reactively post-crisis)
- Escalated to "major severity" immediately (not after days of debugging)

**What this taught me about decision-making:**

[VOICE: Leadership lessons]

- Crises reveal latent process gaps (treat as learning opportunities, not failures)
- Transparency > spin when rebuilding stakeholder trust
- Postmortems work when blameless and action-focused

**How this informs future decisions:**

[VOICE: Meta-takeaways]

- Invest in monitoring before crises hit (proactive >>> reactive)
- Small data quirks deserve root-causing (don't let anomalies linger)
- Cultural change requires artifacts (postmortem template, not just talk)

---

**Factual Evidence Citations:**
- Incident Postmortem: ACN Lineage/STAT6 (Confluence doc)
- Quantitative Outcomes p.33 (incidents metric)
- Failures & Pivots p.28-29 (detailed narrative)
- Conecta Ops notes (escalation timeline)
