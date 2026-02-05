---
phase: 04-quartz-and-vault
plan: 01
subsystem: publishing-infrastructure
type: scaffolding

tags:
  - quartz
  - github-pages
  - static-site-generator
  - deployment-automation

requires:
  - phases: []
  - decisions: []

provides:
  - "Quartz v4 repository deployed to GitHub Pages at /model-citizen/"
  - "GitHub Actions workflow for automated deployment"
  - "Publishing infrastructure ready for Phase 05 content ingestion"

affects:
  - "05-youtube-ingestion: Will publish approved content to this Quartz site"
  - "06-claude-code-integration: Will validate published output format"

tech-stack:
  added:
    - "Quartz v4.5.2 (static site generator)"
    - "GitHub Actions for CI/CD"
  patterns:
    - "Project site deployment (non-root GitHub Pages path)"
    - "ExplicitPublish filter for publishing safety guardrail"
    - "Knowledge garden layout (Explorer + Graph + Backlinks)"

key-files:
  created:
    - "~/model-citizen-quartz/quartz.config.ts: Quartz configuration with baseUrl for project site"
    - "~/model-citizen-quartz/quartz.layout.ts: Knowledge garden layout configuration"
    - "~/model-citizen-quartz/content/index.md: Landing page"
    - "~/model-citizen-quartz/.github/workflows/deploy.yml: GitHub Actions deployment workflow"
  modified: []

decisions:
  - decision: "Rename repository to model-citizen (from model-citizen-quartz)"
    rationale: "GitHub Pages project site path must match repository name for /model-citizen/ URL"
    alternatives: "Keep -quartz suffix and update baseUrl to match, but would conflict with plan objective"
    impact: "URL matches plan specification: athan-dial.github.io/model-citizen/"

  - decision: "Use separate repository approach (not monorepo)"
    rationale: "Cleaner separation between vault (future) and site; independent cloning; follows Phase 04 research recommendation"
    alternatives: "Monorepo with vault/ and site/ subdirectories would simplify GitHub Actions"
    impact: "Phase 05 will need to handle content copying between vault and Quartz repos"

  - decision: "Deploy on v4 branch (not main)"
    rationale: "Quartz upstream repository uses v4 as default branch; preserved to minimize deviation from upstream"
    alternatives: "Rename to main branch, but adds complexity with no clear benefit"
    impact: "GitHub Actions workflow triggers on v4 branch instead of main"

metrics:
  duration: "6 minutes"
  tasks-completed: 3
  commits: 2
  files-created: 4
  completed: "2026-02-05"
---

# Phase 04 Plan 01: Quartz Repository Scaffolding Summary

**One-liner:** Quartz v4 static site deployed to GitHub Pages at /model-citizen/ with GitHub Actions automation

## What Was Built

Created a Quartz v4 repository configured for the Model Citizen project site, deployed to GitHub Pages at https://athan-dial.github.io/model-citizen/ with automated CI/CD via GitHub Actions.

**Key achievements:**
- Quartz v4.5.2 installed with project site baseUrl configuration
- ExplicitPublish filter prevents accidental publication (requires `publish: true` in frontmatter)
- Knowledge garden layout with collapsed Explorer, Graph view, and prominent Backlinks
- GitHub Actions workflow deploys on push to v4 branch
- Landing page describes project as public knowledge garden

## Execution Notes

**Smooth path:**
- Node v23.10.0 already installed (above required v22+)
- Quartz cloning and installation worked first try
- GitHub Actions workflow executed successfully on first push
- Site deployed and accessible within 30 seconds of workflow completion

**Deviations from plan:**
None - plan executed exactly as written.

**Blockers encountered:**
None.

## Decisions Made

### 1. ExplicitPublish Filter Field Name
**Context:** Plan specified `status: "publish"` in landing page frontmatter, but ExplicitPublish plugin checks for `publish: true` field.

**Decision:** Updated landing page to use `publish: true` (boolean) instead of `status: "publish"` (string).

**Impact:** Landing page now publishes correctly. Future content must use `publish: true` in frontmatter to be included in public site.

**Lesson:** Always verify plugin implementation details before assuming frontmatter schema. Reading plugin source code saved debugging time.

### 2. Repository Rename to Match URL Path
**Context:** Repository initially created as `model-citizen-quartz`, resulting in GitHub Pages URL `/model-citizen-quartz/` instead of plan-specified `/model-citizen/`.

**Decision:** Renamed repository to `model-citizen` using `gh repo rename`.

**Impact:** URL now matches plan specification and baseUrl configuration. No breaking changes because rename happened before external links existed.

**Lesson:** GitHub Pages project site path is always `username.github.io/repo-name/` - repository name must exactly match desired path.

### 3. Preserve v4 Branch from Upstream
**Context:** Quartz upstream repository uses `v4` as default branch. Could rename to `main` but adds complexity.

**Decision:** Keep `v4` as default branch and update GitHub Actions workflow to trigger on `v4` instead of `main`.

**Impact:** Aligns with Quartz conventions, minimizes deviation from upstream. No functional difference for deployment.

## Technical Insights

### Quartz Configuration for Project Sites
**Pattern:** GitHub Pages project sites require baseUrl without protocol or trailing slash:
```typescript
baseUrl: "athan-dial.github.io/model-citizen"  // Correct
baseUrl: "https://athan-dial.github.io/model-citizen/"  // Wrong - breaks RSS/sitemap
```

**Why it matters:** Quartz uses baseUrl to generate absolute URLs for RSS feeds, sitemaps, and canonical tags. Including protocol or trailing slash causes malformed URLs.

### ExplicitPublish Safety Guardrail
**Pattern:** Dual-signal publishing requires explicit `publish: true` boolean in frontmatter:
```yaml
---
title: "My Note"
publish: true  # Required for publication
---
```

**Why it matters:** Prevents accidental publication of drafts or private notes. Automation can move notes through workflow stages (inbox → enriched) but cannot auto-publish without human setting `publish: true`.

### GitHub Actions Deployment Flow
**Pattern:** Two-job workflow (build → deploy) with artifact upload:
1. Build job: Install deps, build Quartz, upload `public/` directory as artifact
2. Deploy job: Download artifact, deploy to GitHub Pages using `actions/deploy-pages@v4`

**Why it matters:** Separation allows deploy job to run in GitHub Pages environment with correct permissions. Single-job approach fails due to permission constraints.

## Next Phase Readiness

**Ready to proceed:** Yes, publishing infrastructure is operational.

**Phase 05 dependencies satisfied:**
- ✅ Quartz site deployed and accessible
- ✅ GitHub Actions workflow automated
- ✅ Landing page established
- ✅ ExplicitPublish filter configured

**Known issues:** None.

**Handoff notes for Phase 05:**
- Content must have `publish: true` in frontmatter to be included
- Quartz will ignore folders: inbox/, sources/, enriched/, ideas/, drafts/ (configured in ignorePatterns)
- Deployment happens automatically on push to v4 branch
- Site URL: https://athan-dial.github.io/model-citizen/

## Retrospective

### What Went Well
- Research phase accurately predicted all configuration requirements (baseUrl format, ignorePatterns, ExplicitPublish)
- GitHub Actions workflow worked first try with no debugging needed
- Repository rename handled cleanly with no broken links

### What Could Improve
- Could have caught ExplicitPublish field name (`publish: true` vs `status: "publish"`) during plan review
- Initial repository name should have been `model-citizen` from start (avoided rename step)

### Lessons for Future Phases
- Always verify plugin implementation (read source code) before assuming frontmatter schema
- Repository name determines GitHub Pages URL - plan repository name carefully
- Quartz's ExplicitPublish is stricter than expected (boolean-only, not string values)

## Files Modified

**Created:**
- `~/model-citizen-quartz/quartz.config.ts` (configured for project site)
- `~/model-citizen-quartz/quartz.layout.ts` (knowledge garden layout)
- `~/model-citizen-quartz/content/index.md` (landing page)
- `~/model-citizen-quartz/.github/workflows/deploy.yml` (GitHub Actions workflow)

**Modified:**
- Git remote URL (updated to match renamed repository)

## Commits

| Task | Commit | Message |
|------|--------|---------|
| 1 | 0d75853 | feat(04-01): configure Quartz for Model Citizen project site |
| 3 | c89f0dd | ci(04-01): add GitHub Actions workflow for Pages deployment |

**Note:** Task 2 (Git initialization and GitHub push) involved git/GitHub operations but no file changes, so no separate commit was created.
