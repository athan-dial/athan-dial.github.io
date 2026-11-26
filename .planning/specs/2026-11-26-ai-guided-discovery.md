---
arwc_version: "0.4"
arwc_kind: spec
status: proposed
---

# Problem Statement

A technically literate pharmaceutical R&D leader evaluating my portfolio needs to understand how I have shaped scientific discovery workflows: translating scientific questions into product requirements, connecting computational and experimental capabilities, and making the resulting decisions repeatable. A static architecture diagram or list of applications does not show how scientists actually choose compounds, why the choice matters, or where product ownership ends and scientific authority begins.

A successful work-product page lets a cold reader understand the problem, my evidenced contribution, the discovery loop and its decision points in a three-minute walkthrough, then independently inspect a working illustrative selection scenario, the system architecture, the rationale behind decisions, and sanitized work products. The page is useful as a discussion artifact and stands on its own for a wider technical audience.

# Solution

Create a Personal Fieldnotes work-product case study provisionally titled **AI-Guided Small-Molecule Discovery**, with the deck *Connecting computational predictions to experimental discovery*. Compound nomination means selecting a proposed set of compounds for acquisition or synthesis and experimental testing. Define that term in context; use public-safe functional descriptions throughout.

The page tells one story: how an initially fragmented nomination workflow becomes a repeatable scientific decision capability, connecting evidence, model outputs, chemical selection, scientific review, experimental execution and learning. It pairs a brief visual introduction and a functional synthetic demonstration with progressively disclosed architecture, contribution, product evolution and work artifacts. The existing work-product visual language is the foundation; scientific visuals must communicate mechanisms.

The published case study is a future outcome subject to the site's existing evidence and publication gates. This contract authorizes specification and subsequent draft implementation after review, not publication or disclosure.

# Requirements

### R1: A legible short walkthrough and independent exploration
As a hiring leader or scientific product peer, I want to grasp the workflow and the author's contribution quickly, so that I can decide which technical details merit discussion.

**Acceptance**
- GIVEN a first-time visitor with no internal terminology, WHEN the draft page is opened, THEN the opening identifies the scientific decision, the product intervention and the scope of the case study in plain language.
- The first narrative path presents the problem, a visual discovery loop, a concise contribution statement, an interactive selection scenario and a link to deeper architecture; a presenter can traverse this path in approximately three minutes without opening all details.
- The remainder supports self-directed reading: evolution, architecture, scientific decision rationale, selected artifacts and lessons, with useful in-page anchors and a logical return path from details.
- The draft is coherent without motion or JavaScript. Interactivity adds inspectability, not required explanations hidden behind controls.
- The page feels like a work-product exhibit, not a resume or a recruitment-specific landing page.

### R2: Visualize the scientific problem and experimental learning loop
As a scientific reader, I want to see how computational prioritization fits into experimentation, so that I understand where the product creates leverage.

**Acceptance**
- GIVEN the opening scientific scenario, WHEN the visual is read or its short optional progression is played, THEN it shows candidate chemical space, predictions, constrained selection, scientific review, sourcing or synthesis, testing, interpretation and feedback to subsequent decisions.
- A visual before/after or transformation makes the cost of fragmented decisions concrete: inputs, candidate ranking, selection rationale and returned evidence otherwise need to be reconstructed.
- Chemical-space marks and assay-like visualizations are explicitly illustrative; no real compound identities, measurements or implied experimental validation are present.
- The static equivalent conveys the whole causal sequence. Any motion is brief, purposeful, user-controllable or finite, and does not interrupt reading.

### R3: A functional synthetic compound nomination workbench
As a scientist reviewing a candidate library, I want to vary selection criteria and inspect the resulting proposal, so that I can understand the tradeoffs among model ranking, chemical diversity and practical feasibility.

**Acceptance**
- GIVEN a deterministic, fictional candidate library with IDs, predicted activity scores, cluster assignments, illustrative properties, accessibility or cost units and optional public-safe illustrative structure depictions, WHEN I open the demo, THEN I see an inspectable candidate set, default policy and proposed selection.
- WHEN I change a supported ranking objective (activity-oriented or cost-adjusted), eligibility/property criteria, acquisition budget or capacity, or a per-cluster diversity constraint, THEN the same selection calculation updates the selected set, selected count, cluster coverage, estimated synthetic cost and visible chemical-space highlights.
- The dataset and rules deliberately include cases that make at least one change to objective, budget and diversity visibly alter the selected set. Explain each rule and its tie-breaking in a compact methodology disclosure.
- Selection is reproducible for identical inputs; every selected ID is eligible and unique; selected cost/capacity remains within the chosen limits; cluster counts derive from the selected rows; chart highlights and table membership agree. A diversity cap is honored when enabled. No independently fabricated counters or random re-selection.
- WHEN criteria produce zero feasible candidates, THEN the empty state explains which constraints are active, with a clear reset path. Invalid or out-of-range inputs cannot generate a misleading proposal.
- WHEN I inspect a compound or a selected pool, THEN I can identify why it was eligible/selected, see its relevant fictional inputs, and compare the proposed composition against a baseline selection.
- The demo exposes a stable scenario summary (criteria, counts and selected IDs) so the selection rationale can be revisited; reset returns to the identical default. A local read-only comparison or export is acceptable; no actual order, purchase or scientific workflow is triggered.
- All data, scores, units, behavior and any structure images are visibly labeled synthetic or illustrative. The demo explains a decision mechanism, not predictive accuracy or a production nomination algorithm.

### R4: A truthful account of scientific workflow and product evolution
As a technical leader, I want to understand how the work progressed from analysis toward repeatable software and operational use, so that I can assess the author's product judgment and delivery experience.

**Acceptance**
- GIVEN the approved private evidence corpus, WHEN the evolution is presented, THEN the visual chronology distinguishes documented stages, changes in user needs, product decisions and actual maturity at each stage; dates and outcomes appear only when the evidence and disclosure policy support them.
- Show the progression from bespoke work to repeatable data/selection workflows and interactive or operational tooling where substantiated. Explain what became reusable and what remained expert-controlled.
- Separate what I led, personally built, contributed to, and what collaborators or teams owned. Personal attribution requires evidence; use roles rather than names and avoid assigning scientific or implementation authority to me without support.
- Capabilities explicitly distinguish documented design, prototype and deployed or operational functionality. A missing adoption or outcome measurement is not converted into a success metric.
- No timeline or bar length suggests a measured maturity increase unless such a measurement is supported. Qualitative milestones are visually and textually identified as such.

### R5: A scientific workflow architecture with explicit handoffs
As a technical product reader, I want to inspect the data and decision boundaries, so that I can understand how the software fits into the wider research ecosystem.

**Acceptance**
- GIVEN the architecture overview, WHEN I follow its main path, THEN I can trace experimental records and molecular identities through dataset preparation, model training/evaluation, prediction, molecular properties/diversity, nomination search and selection, scientific/operational review, sourcing or synthesis, testing, interpretation and subsequent learning.
- The architecture shows distinct computational, scientific-product and experimental/operational responsibilities. It names meaningful inputs and outputs at key seams, including selection rationale, feasibility constraints and returned observations.
- The diagram distinguishes shared data states, actions and expert decisions; scientific approval remains a human decision, and a predicted score is not experimental evidence.
- Feedback is explicitly distinguished from a guaranteed automatic retraining cycle. Separate sourcing and synthesis paths or alternate decisions where necessary; do not invent synchronization or handoffs.
- WHEN a reader opens a region or handoff, THEN a short detail explains its purpose, input, output, decision owner by role, and a known boundary or limitation where relevant.
- The public architecture is a conceptual, sanitized representation grounded in reviewed work; it avoids proprietary schemas, topology, tools, model names or program-specific strategies.

### R6: Explore when predictive search is scientifically justified
As a scientific decision-maker, I want to compare evidence states and see how the appropriate strategy changes, so that I understand the conditions under which computational search may be useful.

**Acceptance**
- GIVEN an illustrative program evidence state, WHEN I choose among inconclusive biological signal, credible but chemically concentrated signal, distributed signal with unexplored chemistry, and sufficient credible series, THEN a small visual chemical-space example and explanation identify a defensible proposed next decision and its assumptions.
- The example distinguishes broad exploratory search from experimental deepening or hit expansion, and explains the cost of broadening search when biological signal, model applicability, experimental capacity or feasible chemistry are inadequate.
- It surfaces model generalization, experimental uncertainty and expert judgment as considerations, and states what evidence could change the recommendation.
- The explorer is educational and clearly a proposed decision framework; it does not assert universal rules, validate a model, infer experimental outcomes or automate scientific approvals.
- Each scenario has distinct, scientifically plausible implications. If the private evidence does not support an asserted historical decision, present it only as a clearly labeled illustrative principle or omit it.

### R7: Show decision evidence and inspectable work products
As an independent reviewer, I want to inspect examples of the work behind the story, so that I can evaluate reasoning rather than take achievement claims on trust.

**Acceptance**
- The page presents a curated exhibit of the workflow/process architecture, nomination information architecture, scientific application evolution and scientific strategy/decision framework, using sanitized reconstructions or approved public artifacts.
- Each exhibit explains the original job of the artifact, a concrete decision or tradeoff it makes visible, its maturity, and the author's evidenced role. Readers can expand or follow an accessible local detail with no private links.
- Major historical claims are grounded in a private claim-to-source ledger; the public version contains only approved abstractions and permissible references. Evidence gaps are stated or the claim is removed.
- Authentic reconstructed interfaces or diagrams are preferable to decorative icons or generic thumbnail placeholders. If an artifact cannot be safely reconstructed, use an honest mechanism-level explanation instead.
- Close with a concise reflection on what worked, limits and what would be measured or changed next, with no invented results.

### R8: A coherent, accessible portfolio experience
As a reader on a laptop or phone, I want a fast, legible, visually engaging page that belongs to the existing portfolio, so that I can explore it without losing orientation.

**Acceptance**
- The page uses the existing light Personal Fieldnotes design system, typography, tokens, masthead and semantic diagram vocabulary. Use intentional spatial hierarchy, varied visual compositions and concise captions; the main demonstration and architecture receive the most visual space.
- The diagrams remain legible at desktop and narrow widths, with controlled scrolling or a meaningful responsive alternative for complex structures. No clipped controls, overlapping diagram nodes, broken connectors or unintended whole-page horizontal overflow.
- All controls have meaningful names, keyboard behavior, visible focus, programmatically communicated state, and accessible descriptions for charts. Color is supplemented by text or shape. Provide sufficient contrast and touch targets per site policy.
- At 200% text zoom, with reduced motion and with scripts disabled, the static narrative, core diagrams and a documented example selection remain available. The no-script experience explains that interactive changes require JavaScript.
- No new runtime service or paid dependency is needed. Static Hugo builds and existing site checks pass without changing unrelated routes, navigation or published work.
- The implementation remains draft/private and excluded from the public site and public indexes until the author explicitly authorizes publication.

# Constraints

### C1: Evidence and public-repository safety
All tracked files, including this specification, fixtures, screenshots, generated assets and planning documents, are public-visible. Follow CLAUDE.md, PRODUCT.md and the repository content-safety contract. Use approved public-safe vocabulary and entirely fictional demo data. Keep the evidence corpus and real-to-fictional mappings in authorized untracked/private locations. No internal project or model names, program identifiers, collaborators' names, private links or identifiers, vendor relationships, real molecular structures from employer work, confidential metrics, credentials, or proprietary schema details may enter tracked artifacts. The same rule covers metadata, image text, captions, alt text and client bundles.

### C2: Content-authenticity gate
Before writing historical case-study prose, obtain and use the evidence and voice materials required by the child repository's CLAUDE.md. Resolve attribution and disclosure with the author where needed. Without them, structural/demonstration work may proceed only as explicitly illustrative; historical claims remain blocked. Follow the site's claim classification and distinguish target, estimate and measurement. Do not weaken safety checks or invent supporting records.

### C3: Scientific and computational integrity
Synthetic data must be self-contained and deterministic. Demonstration summaries are computed from the displayed selection. A model score is not a measured assay result. Scientific strategy explanations are conditional and do not promise improved hit rate, predictive generalization, savings or accelerated discovery. Preserve scientific and operational decision authority.

### C4: Site design and engineering boundaries
Follow the existing Hugo architecture, Personal Fieldnotes tokens, diagram grammar, accessibility and performance conventions. Prefer existing primitives and native browser capabilities. Keep project-specific code local unless a demonstrably shared need justifies extraction; do not build a general case-study framework in anticipation. No tracking, network calls, third-party embeds or services required for the demo. Do not commit generated publish output.

### C5: Review and publication authority
This is a proposed specification, not an execution ticket, approval, or authorization to publish. Decompose only after specification review. Implement a draft and present evidence for human review; publication, merge to the deployment branch and disclosure of additional facts require explicit author authorization. No public links into private sources.

# Implementation Decisions

## Locked
- Repo: athan-dial/athan-dial.github.io
- Base branch: main
- Deliver one work-product page in the existing Hugo work section, with a proposed descriptive slug `/work/ai-guided-discovery/`; honor any established non-conflicting route convention.
- Reading order: opening problem and discovery-loop visual, concise contribution, interactive nomination workbench, evolution, inspectable architecture, scientific decision explorer, artifact exhibits, reflection. A short path links to deep exploration.
- Use one coherent local synthetic fixture and one selection-calculation seam shared by every displayed summary, plot and table. The exact selection algorithm is illustrative, disclosed and distinct from historical implementation.
- Use the current site design system and existing work-product patterns as the visual precedent. Prefer a purposeful editorial experience over equally weighted cards.
- Private evidence and voice requirements remain those of the child repository; the source ledger is not a tracked public artifact.

## Executor discretion
- Choose a small deterministic fixture size, fictional identities, cost units, property ranges, ranking formula, tie-breaking and selection strategy sufficient to demonstrate the stated constraints and tradeoffs. Do not claim optimality unless the implemented algorithm warrants it.
- Choose visual encoding, exact composition, diagram format, details panel behavior, optional animation mechanics and accessible interaction patterns within the existing site conventions.
- Reuse components where their existing behavior fits; prefer narrowly scoped implementation over adding dependencies or a universal page framework.
- Choose a small number of evidence-backed exhibits and the depth of their public-safe reconstructions.
- Choose the most useful behavioral tests using existing build and browser seams, adding a focused selection-calculation test seam where needed.

## Escalate before deciding
- Missing mandatory private evidence/voice corpus; unclear individual attribution; uncertain public disclosure of any artifact or outcome. Omit or block the affected historical claim until resolved.
- A consequential departure from the site design system, route/publishing policy, or the agreed distinction between demonstration and historical capabilities.
- Any request to publish, expose real scientific data, link internal systems, use paid/external services, or generalize the feature into a new cross-site platform.

# Testing Decisions

- **R1:** seam: rendered draft page; evidence: timed walkthrough script or observed short path, complete heading/anchor map, no-script reading inspection and independent navigation.
- **R2:** seam: static diagram and optional playback; evidence: ordered labeled stages, feedback direction, static equivalent and reduced-motion/finite playback checks. Confirm visual is labeled illustrative.
- **R3:** seam: pure selection calculation plus rendered controls; evidence: fixtures for default, changed objective, tight budget, cluster cap on/off, no eligible candidate, boundary inputs, deterministic tie and reset. Independently recompute sums, distinct clusters and ID membership from returned rows; verify chart/table/summary consistency and baseline comparison. Tests must reject a display with hardcoded counts, overspent budget, ineligible candidates, duplicate IDs or differing chart membership. Exercise controls in-browser.
- **R4:** seam: chronology and role statements; evidence: private claim ledger with disclosure/maturity/attribution review; compare rendered claims against accepted ledger. Check that no target is described as measured and no team ownership is presented as personal authorship.
- **R5:** seam: diagram model and detail navigation; evidence: handoff/owner/input/output audit against approved abstractions, geometry and edge checks, keyboard drill-down walkthrough. Confirm expert decision and nonautomatic feedback semantics.
- **R6:** seam: strategy scenario state and rendered explanation; evidence: visit every scenario and verify distinct visual/explanatory result, explicit limitations, change conditions, reset and keyboard use; review scientific wording.
- **R7:** seam: exhibit gallery and claim review; evidence: all details open and return correctly; artifact maturity and role checked against private evidence; inspect captions and reconstructed assets for unsupported or unsafe content.
- **R8:** seam: full Hugo render and interaction; evidence: desktop and narrow screenshots, keyboard traversal, 200% zoom, contrast, reduced motion, no-script and controlled overflow checks; verify the page is draft/private and absent from ordinary production build and indexes.
- **C1/C2:** seam: diff, public artifacts and claim ledger; evidence: repository safety checks plus manual proper-noun, number, metadata, asset and screenshot review; verify required private evidence was actually inspected before historical prose. Reject any committed internal source, private link or unsupported attribution.
- **C3:** seam: fixture/algorithm and scientific copy; evidence: reproducibility, constraint checks, explicit synthetic labels and scientific review of score/assay and strategy distinctions.
- **C4:** seam: repo diff and build; evidence: existing token and template use, no generated output or unnecessary runtime dependencies, no external demo requests, existing routes remain intact. Run canonical checks from CLAUDE.md and applicable work-page/render checks; include fresh `hugo --gc --minify`, `scripts/verify-build.sh`, `scripts/verify-render.sh`, `scripts/publish-gate.sh` and diff whitespace checks as applicable. Identify unavailable checks explicitly.
- **C5:** seam: draft settings and Git history; evidence: no live deployment or publish transition, reviewed public-safe draft and requirement-to-evidence matrix. Human review of draft and publication are separate gates.

The highest-risk behavioral seam is the pure selection function: test actual selection membership and invariants rather than screenshot appearance alone. Reuse existing browser and repository checks, with the smallest additional seam necessary. Certification of this specification and implementation verification are separate from authoring.

# Out of Scope

Production chemical informatics, real model inference, experimental design automation, purchasing or synthesis ordering, confidential source data, reverse-engineering proprietary algorithms, scientific validation or claims of business impact, new enterprise platform integrations, a universal portfolio framework, redesign of other case studies, job application workflows, and live publication.

# Starting State

The repository's current documented baseline is a custom Hugo site with the Personal Fieldnotes design system, draft/private content policy, content safety and render/build checks. CLAUDE.md identifies DESIGN.md, PRODUCT.md, DIAGRAMS.md, shared Fieldnotes CSS, existing work layouts and the site's private evidence/voice requirements as relevant authority. Inspect the current work-product implementation and reconcile the uploaded review snapshot with the actual branch before choosing reusable components. Do not assume the snapshot has been merged or published.

# Further Notes

The case study should be useful in a live technical discussion: begin with the scientific choice, operate one example, then follow the architecture or decision evidence according to the reader's interests. A public reader must not need that live explanation.

After human review, the next agent-home verb is `to-tickets`. Keep the spec authoritative for the WHAT, with ticket decomposition and implementation evidence separate.
