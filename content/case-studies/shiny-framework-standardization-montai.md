---
title: "Standardizing Montai's App Ecosystem with R Shiny"
date: 2024-06-01
description: "[VOICE: Framework decision that cut app development time 66%]"
problem_type: "technical-architecture"
scope: "team"
complexity: "medium"
tags: ["technical-architecture", "developer-experience", "tool-selection", "team-velocity"]
---

## Context

[VOICE: Fragmentation problem]

**Facts:**
- 2024: Growing need for internal web apps (compound selection, data visualization, report generation)
- Problem: Different engineers using different frameworks (Python Streamlit/Dash, R Shiny, Jupyter notebooks)
- Pain: Inconsistent UX, duplicated effort, hard to maintain, context-switching cost
- Stakes: Small team (~5-6 people) needed velocity + consistency

[VOICE: Technical leadership needed to converge on single approach]

## Ownership

I owned:
- Framework evaluation (Streamlit vs Dash vs Shiny vs multi-framework)
- Proof-of-concept implementation (Nomination App in Shiny)
- Internal standards documentation (app dev guidelines)
- Team training (brown bag sessions on Shiny patterns)

I influenced:
- Montai Style library (with Kyle T - UI components for Shiny)
- Posit Connect deployment strategy (with Platform Eng)
- Team skill development (mentored colleagues on Shiny)

## Decision Frame

**Problem statement:** [VOICE: Technical choice framing]

Standardize internal app framework to accelerate development and maintain consistency, constrained by:
- Mixed team skills (some Python, some R, few full-stack engineers)
- Data-heavy use cases (need robust plotting + data wrangling)
- Small team (can't support multiple frameworks well)

**Options considered:**

**Option A: Streamlit (Python)**
- Pros: Quick to develop, popular, Python-based (most engineers know)
- Cons: Lacked flexibility for complex UI at the time, less mature
- Risk: Montai had significant R analytics codebase to leverage

**Option B: Dash (Python/Plotly)**
- Pros: More customizable than Streamlit, production-ready
- Cons: More engineering-heavy, steeper learning curve
- Risk: Fewer team members comfortable with Plotly ecosystem

**Option C: R Shiny**
- Pros: Powerful for data apps, integrates with R analytics, Posit Connect deployment, data team knows R
- Cons: Fewer pure software engineers comfortable with R
- Risk: Long-term maintainability if team shifts to Python-heavy

**Option D: Multi-framework (case-by-case)**
- Pros: Flexibility, use best tool per job
- Cons: Fragmentation persists, no consistency gains
- Risk: Maintenance burden grows, onboarding harder

**Decision:** Chose Option C (R Shiny) because:

[FACTS from archaeology p.17-18:]

1. **Team skills alignment:** Data scientists already used R for analysis (reuse code directly in apps)
2. **Deployment simplicity:** Posit Connect already in use (easy publishing)
3. **Rapid prototyping:** Shiny allows quick UI iteration with reactive data
4. **Ecosystem maturity:** Robust R packages (ggplot2, dplyr) for data visualization
5. **Proof-of-concept success:** Built Nomination App as flagship example (validated approach)

Tradeoff accepted: Some engineers less comfortable with R, but data team velocity more valuable.

**Constraints:**
- 3-month timeline to show value (mid-2024 goal)
- No dedicated UI/UX designer (needed framework with decent defaults)
- Small Platform Eng capacity (deployment needed to be straightforward)

## Outcome

**Primary outcome:**

Cut app development time ~66% (3 weeks → 1 week for new apps) while establishing consistent UI/UX:
- Velocity: SAR Dashboard app built in 1 week using Shiny template (vs 3 weeks from scratch)
- Consistency: All internal apps shared Montai Style components (auth, layout, branding)
- Capability: Non-engineer (chemist) added filter to Shiny app after training (broadened contributor base)

[VOICE: Enabled small team to punch above weight with unified approach]

**Metrics:**
- App development time: 3 weeks → 1 week (anecdotal, for similar scope)
- Framework adoption: 100% of new apps in Shiny by Q4 2024
- Team contributions: Chemist contributed feature (skill development success)

**Technical artifacts:**
- Nomination App (flagship proof-of-concept)
- Montai Style repo (UI components library for Shiny)
- Internal dev guidelines (Confluence: "How to build a Shiny app")

**Second-order effects:**
- Template for other internal tools (SAR Dashboard, compound selection)
- Reusable patterns (authentication, data connections, theming)
- Easier onboarding (new hires learned one framework, not three)

**Limitations acknowledged:**
- Nomination App "still in early stages" by mid-2024 (incomplete proof-of-concept initially)
- Some engineers less comfortable with R (required training investment)
- Framework lock-in risk (if future needs exceed Shiny capabilities)

## Reflection

**What I'd do differently:**

[VOICE: Technical decision lessons]

- Build 2-3 small apps as proof-of-concept (not one large incomplete app)
- Pair with full-stack engineer earlier (balanced R expertise with UI polish)
- Evaluate hybrid (Shiny prototype → React for scale) for future-proofing

**What this taught me about decision-making:**

[VOICE: Architecture choices]

- Framework standardization is social + technical (adoption > theoretical best tool)
- Proof-of-concept validates assumptions (not just docs/research)
- Small team constraints favor simplicity over flexibility (one framework well > many poorly)

**How this informs future decisions:**

[VOICE: Tool selection]

- Always prototype with real use case before mandating standard
- Optimize for team strengths, not abstract "best practices"
- Standardization trades flexibility for velocity (know when tradeoff worth it)

---

**Factual Evidence Citations:**
- Project Inventory p.8 (Shiny framework entry)
- Technical Architecture p.17-18 (decision rationale)
- 2024 Mid-Year Review (Shiny standardization goal)
- Slack: Montai Style repo ready (Kyle T)
