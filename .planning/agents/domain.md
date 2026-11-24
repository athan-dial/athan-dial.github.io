# Domain documentation

Single context at repository root: CONTEXT.md. No separate context map or additional agent instruction file is needed.

- CLAUDE.md is the canonical repository agent entrypoint.
- PRODUCT.md defines reader jobs and product scope.
- DESIGN.md and DIAGRAMS.md define the Fieldnotes visual and schematic language.
- The content model and safety contract in .planning/ govern publication.
- The proposed EDITORIAL.md must be approved before it becomes editorial authority (issue #16).
- GitHub issue specifications are canonical for new work. Keep durable architecture decisions in the corresponding issue and update CONTEXT.md if terms change.

Read relevant domain documents before shaping or changing work. If a seam crosses content, templates or publication validation, use existing checks and document the behavioral contract before refactoring.

Do not add tracked docs/ or public/. The former is prohibited by verify-build.sh; the latter is generated output. .planning/agents/ intentionally replaces the generic docs/agents/ path.
