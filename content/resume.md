---
title: "Decision Portfolio"
date: 2026-01-20
description: "Decision systems, not achievements - evidence of how I approach high-stakes product decisions"
---

<div style="text-align: center; margin-bottom: 2rem;">
  <a href="/resume.pdf" download="Athan-Dial-Resume.pdf" style="display: inline-block; padding: 0.75rem 1.5rem; background-color: var(--accent); color: white; text-decoration: none; border-radius: 8px; font-weight: 500; transition: background-color 0.2s;">
    📄 Download PDF Resume
  </a>
</div>

# Athan Dial, PhD

**PhD-trained in multi-omics analysis. Product-tested in drug discovery ML.**

I design decision systems for ambiguous, high-stakes problems. I combine research-grade evaluation rigor with product judgment to ship measurable outcomes. I communicate in decisions, metrics, and tradeoffs—not activity.

---

## Decision Systems Portfolio

### System 1: Preventing Metric Theater in Drug Discovery ML

**Decision Context:** Data science teams were presenting accuracy metrics without reliability monitoring, creating false confidence in model predictions for multimillion-dollar compound selection decisions. Each compound decision represented $2M+ in development costs, but we lacked visibility into model performance degradation over time.

**My Decision:** I designed a combined evaluation framework (offline validation + online monitoring) instead of choosing between them. This required coordinating across ML, platform, and biology teams to establish baseline validation and production monitoring infrastructure.

**Outcome:** De-risked $2M+ in compound development by catching model degradation 3 months earlier than previous processes. The framework identified performance drift in two models before they influenced compound selection decisions. Established evaluation framework as standard for all discovery ML models.

**Key Tradeoff:** I sacrificed implementation speed (3 months vs. 2 weeks for offline-only) to gain defensibility and early warning signals. The infrastructure investment paid off across multiple models and use cases.

[Full Case Study →](/case-studies/preventing-metric-theater-drug-discovery-ml/)

---

### System 2: Reducing Pipeline Latency to Accelerate Decision Velocity

**Decision Context:** Analytics pipelines took 4-6 hours to run, blocking daily decision-making for 6+ discovery teams. Teams couldn't iterate on compound prioritization during meetings, forcing them to reconvene later—slowing R&D velocity and reducing confidence in data-driven decisions.

**My Decision:** I redesigned the data warehouse architecture using dbt + S3/Parquet with incremental models and materialized views. I prioritized latency reduction over feature completeness to unblock the decision-making bottleneck first.

**Outcome:** Reduced pipeline runtime from 4-6 hours to 20-30 minutes (85-90% reduction), enabling same-day iteration on compound prioritization. Reduced compute costs by ~$75k/year through architectural optimization. Analytics became the default path for nomination decisions across all discovery teams.

**Key Tradeoff:** I deferred some advanced analytics features to focus on infrastructure reliability and speed. Teams could make faster decisions with core metrics instead of waiting longer for comprehensive dashboards.

[Full Case Study →](/case-studies/reducing-pipeline-latency-decision-velocity/)

---

### System 3: PhD Research - Multi-Omics Pipeline Design Under Resource Constraints

**Decision Context:** During my PhD at McMaster University (2017-2022), I designed multi-omics analysis pipelines where the right evaluation approach wasn't obvious from existing literature. I had to decide how to allocate limited sequencing budget across validation experiments while maintaining statistical rigor.

**My Decision:** I developed evaluation frameworks from first principles, explicitly modeling the cost-benefit tradeoffs of different validation strategies. I prioritized experiments that maximized learning per dollar while maintaining sufficient statistical power.

**Outcome:** Successfully translated complex multi-omics data into actionable biological insights that informed experimental design. Published peer-reviewed research demonstrating the validity of the evaluation approach. Developed the "design decision systems under resource constraints" skillset that I now apply to product decisions.

**Key Tradeoff:** I chose statistical rigor over comprehensive coverage—validating core hypotheses thoroughly rather than testing everything superficially. This approach prevented false confidence while staying within budget constraints.

---

## Current Role

**Data Research Lead | Montai Therapeutics | 2022-Present**

I lead decision systems design for drug discovery analytics, owning evaluation frameworks, data architecture, and stakeholder alignment. I partner with executives, scientists, and ML teams to turn ambiguous requirements into shipped outcomes.

**Key Contributions:**
- Scaled decision-support apps cutting cycle time by ~90% across 6+ discovery teams
- Designed data warehouse (dbt/S3) reducing compute cost by ~$75k/yr
- Built exec-ready dashboards guiding $10M+ R&D investment decisions
- Integrated predictive modeling into early-stage gates, improving progression precision by ~20%

---

## Previous Roles

**Chief Analytics Officer | ArchitectHealth | 2018-2019**

Directed analytics strategy for biotech portfolio companies, informing R&D investment decisions and improving client competitiveness through actionable insights.

**Data Scientist | Replica Analytics | 2019-2020**

Built privacy-preserving synthetic data pipelines for healthcare, enabling secure clinical data sharing while maintaining statistical validity.

---

## Education

**PhD | McMaster University | 2017-2022**

Developed multi-omics analysis pipelines and evaluation frameworks for translating complex biology into actionable decision contexts. Dissertation focused on designing decision systems under resource constraints—the foundation of my current approach to product decisions.

---

## Technical Capabilities

**Decision Systems Design**
- Evaluation frameworks (offline + online) that prevent metric theater
- North star + guardrails framework for product prioritization
- Stakeholder alignment forums with clear ownership

**Data Architecture & Engineering**
- dbt, SQL/Athena, S3/Parquet data warehouses
- Data contracts, lineage, and monitoring infrastructure
- Cost-optimized pipelines with reliability as first-class requirement

**Analytics & Visualization**
- R/Python, Shiny, Plotly, ggplot2, ECharts decision tools
- Statistical graphics and trade-off analyses for executives
- Interactive dashboards with clear decision CTAs

**Communication & Alignment**
- Executive storytelling through briefs, dashboards, and documentation
- Making tradeoffs explicit and decisions easy through clear framing
- Capturing institutional knowledge into durable, actionable findings

---

<div style="text-align: center; margin-top: 3rem; padding-top: 2rem; border-top: 1px solid var(--border-light);">
  <p><strong>Want to see how I think?</strong> Read my <a href="/case-studies/">full case studies</a> or explore my <a href="/consulting/">consulting services</a>.</p>
  <a href="/resume.pdf" download="Athan-Dial-Resume.pdf" style="display: inline-block; padding: 0.75rem 1.5rem; background-color: var(--accent); color: white; text-decoration: none; border-radius: 8px; font-weight: 500; transition: background-color 0.2s; margin-top: 1rem;">
    📄 Download PDF Resume
  </a>
</div>
