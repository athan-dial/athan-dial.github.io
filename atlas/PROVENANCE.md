# Atlas image provenance

Self-hosted copies of images from each project's own README or repository, shown on `/atlas/` with a credit line
and an "Original" link. Files live in `assets/atlas/`; each record's `[image]` table points at one. Raster
images were resized to at most 1200px wide and re-encoded as WebP; animated GIFs were reduced to one still
frame (the most detailed). Transparent images were flattened onto white. Nothing is hotlinked.

Decision 2026-11-06 (Athan): include banners and logos and include every licence class. That means the
repo licence below does NOT clear the image: a repo licence may not cover its artwork, and logos are
trademarked. Rows marked REVIEW need Athan's explicit OK in LOCAL-GATE.md step 4 before any push. Decision 2026-11-06 (Athan): no images from AGPL repos; the Claude Squad image was removed (its record text stays). Remove an
image by deleting the `[image]` table from the record (the card falls back to a typographic tile).

Left out on purpose: sponsor advertisements in the Scrapling README, badges, benchmark charts, and the
Cognee demo frame (it carried a vendor benchmark claim; the wordmark is used instead).

| Project | File | Kind | Repo licence | Status | Source |
|---|---|---|---|---|---|
| CLI Agent Orchestrator (CAO) | `awslabs--cli-agent-orchestrator.webp` | banner | Apache-2.0 | OK permissive | https://github.com/awslabs/cli-agent-orchestrator/blob/main/docusaurus/static/img/cao-social-card.png |
| Scrapling | none (typographic tile) | | BSD-3-Clause | | |
| codebase-memory-mcp | `deusdata--codebase-memory-mcp.webp` | screenshot | MIT | OK permissive | https://github.com/DeusData/codebase-memory-mcp/blob/main/docs/images/lens-system-structure.png |
| Graphiti | `getzep--graphiti.webp` | diagram | Apache-2.0 | OK permissive | https://github.com/getzep/graphiti/blob/main/images/graphiti-graph-intro.gif |
| Scientific Agent Skills | none (typographic tile) | | MIT | | |
| Kedro-Viz | `kedro-org--kedro-viz.webp` | screenshot | Apache-2.0 | OK permissive | https://github.com/kedro-org/kedro-viz/blob/main/.github/img/banner.gif |
| Letta (formerly MemGPT) | none (typographic tile) | | Apache-2.0 | | |
| Mem0 | `mem0ai--mem0.webp` | banner | Apache-2.0 | OK permissive | https://github.com/mem0ai/mem0/blob/main/docs/images/banner-sm.png |
| Context Mode | `mksglu--context-mode.webp` | banner | NOASSERTION | REVIEW: no licence stated | https://github.com/mksglu/context-mode/blob/main/docs/assets/readme/hero-light.png |
| MCP Registry | none (typographic tile) | | NOASSERTION | | |
| OpenShell | `nvidia--openshell.webp` | logo | Apache-2.0 | OK permissive | https://github.com/NVIDIA/OpenShell/blob/main/docs/brand/assets/openshell-avatar-1024.png |
| OpenLineage | `openlineage--openlineage.svg` | diagram | Apache-2.0 | OK permissive | https://github.com/OpenLineage/OpenLineage/blob/main/doc/with-ol.svg |
| SQLLineage | `reata--sqllineage.webp` | diagram | MIT | OK permissive | https://github.com/reata/sqllineage/blob/master/docs/_static/table.jpg |
| Claude Squad | none (image removed 2026-11-06, AGPL-3.0 repo; typographic plate) | | AGPL-3.0 | removed | |
| SQLMesh | `sqlmesh--sqlmesh.webp` | diagram | Apache-2.0 | OK permissive | https://github.com/TobikoData/sqlmesh/blob/main/docs/readme/architecture_diagram.png |
| Cognee | `topoteretes--cognee.svg` | logo | Apache-2.0 | OK permissive | https://github.com/topoteretes/cognee/blob/main/assets/cognee-logo.svg |
