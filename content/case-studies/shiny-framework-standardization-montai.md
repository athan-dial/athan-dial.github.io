---
title: "Standardizing Montai's App Ecosystem with R Shiny"
date: 2024-06-01
description: "Converged fragmented app development onto single framework, cutting development time 66% — balanced team skills with deployment simplicity to accelerate internal tool velocity"
problem_type: "technical-architecture"
scope: "team"
complexity: "medium"
tags: ["technical-architecture", "developer-experience", "tool-selection", "team-velocity"]
---

## Context

By mid-2024, Montai's internal web app landscape had fragmented. Different engineers built tools in their preferred frameworks — Python Streamlit, Python Dash, R Shiny, Jupyter notebooks — creating a sprawling ecosystem with inconsistent UX and duplicated effort. For a small data team (~5-6 people), this fragmentation imposed hidden costs: context-switching overhead, maintenance burden, and harder onboarding.

**Facts:**
- 2024: Growing need for internal web apps (compound selection, data visualization, report generation)
- Problem: Different engineers using different frameworks (Python Streamlit/Dash, R Shiny, Jupyter notebooks)
- Pain: Inconsistent UX, duplicated effort, hard to maintain, context-switching cost
- Stakes: Small team (~5-6 people) needed velocity + consistency

Technical leadership was needed to converge on a single approach. The challenge: balance team skills, deployment infrastructure, and use case requirements — while avoiding the trap of "one size fits all" dogma that ignores practical constraints.

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

**Problem statement:**

Choose and standardize a single internal app framework to accelerate development velocity and establish consistent UX, constrained by:
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

Standardization enabled a small team to punch above its weight. By converging on R Shiny, we transformed app development from bespoke engineering work into repeatable application of templates and patterns. The Montai Style library meant new apps inherited authentication, theming, and layout automatically — developers focused on domain logic, not infrastructure.

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

Three technical decision lessons stand out:

- Build 2-3 small apps as proof-of-concept (not one large incomplete app)
- Pair with full-stack engineer earlier (balanced R expertise with UI polish)
- Evaluate hybrid (Shiny prototype → React for scale) for future-proofing

The Nomination App as flagship proof-of-concept was the right instinct but wrong execution — it remained "in early stages" too long, undermining confidence in the standardization decision. Building multiple small, complete examples would have demonstrated feasibility more convincingly. The other two are standard risk mitigations I should have applied upfront.

**What this taught me about decision-making:**

Framework standardization reinforced three architecture principles:

- Standardization is both social and technical — adoption matters more than theoretical "best tool"; R Shiny won because the data team already used R for analysis, not because it was objectively superior to Python frameworks
- Proof-of-concept validates assumptions better than research — actual implementation exposed deployment constraints and UI limitations that documentation never revealed
- Small team constraints favor simplicity over flexibility — supporting one framework well beats supporting many poorly; the tradeoff was clear and correct

**How this informs future decisions:**

These tool selection principles now guide my technical architecture work:

- Always prototype with a real use case before mandating a standard — abstract evaluation misses practical constraints that only implementation reveals
- Optimize for team strengths, not abstract "best practices" — the best framework is the one your team can actually use effectively
- Standardization trades flexibility for velocity — know when that tradeoff is worth it (small teams yes, large platform teams maybe not)

---

**Factual Evidence Citations:**
- Project Inventory p.8 (Shiny framework entry)
- Technical Architecture p.17-18 (decision rationale)
- 2024 Mid-Year Review (Shiny standardization goal)
- Slack: Montai Style repo ready (Kyle T)
