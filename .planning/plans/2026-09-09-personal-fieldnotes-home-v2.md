# Personal Fieldnotes Homepage V2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore the personal site's professional-depth spine while keeping the Personal Fieldnotes visual language and adding restrained single-scroll chapter motion.

**Architecture:** The homepage stays server-rendered Hugo and complete without JavaScript. A tiny home-only progressive-enhancement script tracks the active chapter and adds one-time motion state; CSS owns all layout and animation, while `prefers-reduced-motion` removes the enhancement. Trajectory data uses only role/company/range fields plus canonical profile foundation data.

**Tech Stack:** Hugo 0.154.3 extended, Go templates, plain CSS, dependency-free browser JavaScript, Bash verification.

**Spec:** `.planning/design/PERSONAL-FIELDNOTES-UPDATE-2026-09-09.md`

## Global Constraints

- Preserve all existing public URLs, redirects, evidence gates, long-form book layouts, and GitHub Pages deployment.
- Do not publish resume content, internal Montai material, unsupported metrics, or legacy experience summary prose.
- No client framework, animation library, third-party script, new font dependency, external font request, or dark mode.
- The homepage must be complete and readable with JavaScript disabled.
- Never animate layout properties or gate content visibility on IntersectionObserver.
- Reduced-motion handling remains last in the final Fieldnotes CSS layer.
- Use only role/company/range from `data/experience.json` on the homepage.

---

### Task 1: Add the homepage verification contract

**Files:**
- Create: `scripts/verify-fieldnotes-home.sh`

**Interfaces:**
- Consumes: Hugo source files and built `public/index.html` when available.
- Produces: a deterministic PASS/FAIL contract for chapter order, hero copy, safe trajectory fields, chapter index, progressive script, and reduced-motion rules.

- [ ] **Step 1: Add assertions for the desired v2 source/render contract**
- [ ] **Step 2: Run the script against the current branch and confirm it fails because v2 markers are absent**
- [ ] **Step 3: Commit the failing contract**

### Task 2: Restore the single-scroll information architecture

**Files:**
- Modify: `layouts/index.html`
- Modify: `data/profile.toml`

**Interfaces:**
- Consumes: `site.Data.profile`, public work/writing pages, `site.Data.experience` role/company/range.
- Produces: seven ordered homepage chapters with stable anchor IDs.

- [ ] **Step 1: Replace the generic hero slogan with the canonical expert-work headline and role metadata**
- [ ] **Step 2: Reorder work before Fieldnotes**
- [ ] **Step 3: Add safe trajectory markup using only role/company/range plus profile foundation**
- [ ] **Step 4: Add operating-territory and context chapters**
- [ ] **Step 5: Add the wide-screen chapter index linking to all seven IDs**
- [ ] **Step 6: Run the homepage verification contract and confirm structural assertions pass**
- [ ] **Step 7: Commit**

### Task 3: Add the abundant-execution schematic

**Files:**
- Modify: `layouts/partials/fieldnote-schematic.html`
- Modify: `DIAGRAMS.md`

**Interfaces:**
- Consumes: partial name `abundant-execution`.
- Produces: native-HTML schematic using existing state/action/decision semantics.

- [ ] **Step 1: Add the named schematic without changing existing schematic behavior**
- [ ] **Step 2: Document its intended reuse and semantics**
- [ ] **Step 3: Re-run source contract**
- [ ] **Step 4: Commit**

### Task 4: Implement chapter layout and progressive motion

**Files:**
- Modify: `assets/css/fieldnotes.css`
- Create: `assets/js/fieldnotes-home.js`
- Modify: `layouts/_default/baseof.html`

**Interfaces:**
- JavaScript consumes: `[data-fn-chapter]`, `[data-fn-index-link]`.
- JavaScript produces: `html.fn-enhanced`, `.fn-chapter--entered`, and `aria-current="location"` on the active index link.
- CSS consumes those states but never hides required content.

- [ ] **Step 1: Add timeline, territory, chapter-index, context, and section-rule styles**
- [ ] **Step 2: Add one-time non-gating entry animation states**
- [ ] **Step 3: Add dependency-free IntersectionObserver logic for current chapter and entered state**
- [ ] **Step 4: Load the fingerprinted script only on the homepage and defer it**
- [ ] **Step 5: Ensure reduced-motion rules remain last and zero all new motion**
- [ ] **Step 6: Run source contract**
- [ ] **Step 7: Commit**

### Task 5: Update design authority and agent handoff

**Files:**
- Modify: `DESIGN.md`
- Modify: `PRODUCT.md`
- Modify: `CLAUDE.md`
- Modify: PR #1 description

**Interfaces:**
- Produces: durable design authority plus exact local verification/handoff instructions.

- [ ] **Step 1: Update homepage narrative and motion rules in design/product docs**
- [ ] **Step 2: Update Claude guidance with v2 chapter order and no-gating motion rule**
- [ ] **Step 3: Update PR body with completed work, known verification boundary, and local commands**
- [ ] **Step 4: Commit**

### Task 6: Local verification before merge

**Files:**
- No source changes unless verification finds a defect.

**Interfaces:**
- Consumes: completed branch.
- Produces: verified merge readiness or concrete fixes.

- [ ] **Step 1: Run `hugo --gc --minify`**
- [ ] **Step 2: Run `bash scripts/verify-fieldnotes-home.sh`**
- [ ] **Step 3: Run `bash scripts/verify-build.sh`**
- [ ] **Step 4: Run `bash scripts/verify-render.sh`**
- [ ] **Step 5: Run `bash scripts/publish-gate.sh`**
- [ ] **Step 6: Run `git diff --check main...HEAD`**
- [ ] **Step 7: Review `/` at wide desktop and standard desktop, keyboard-only, and 200% text zoom**
- [ ] **Step 8: Review narrow/mobile if the local browser environment supports it; otherwise record the boundary honestly in PR #1**
- [ ] **Step 9: Confirm JavaScript-disabled homepage still exposes all seven chapters and working anchor links**
- [ ] **Step 10: Fix only defects found by these checks, rerun the affected checks, and update PR #1 with results**
