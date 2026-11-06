# Atlas image provenance

Self-hosted copies of images from each project's own README or repository, shown on `/atlas/` with a credit line
and an "Original" link. Files live in `assets/atlas/`; each record's `[image]` table points at one. Raster
images were resized to at most 1200px wide and re-encoded as WebP; animated GIFs were reduced to one still
frame (the most detailed). Transparent images were flattened onto white. Nothing is hotlinked.

Decision 2026-11-06 (Athan): include banners and logos and include every licence class. That means the
repo licence below does NOT clear the image: a repo licence may not cover its artwork, and logos are
trademarked. Rows marked REVIEW need Athan's explicit OK in LOCAL-GATE.md step 4 before any push. Tier 1 additions (2026-11-06): image risk accepted by Athan, AGPL repos get no image. Decision 2026-11-06 (Athan): no images from AGPL repos; the Claude Squad image was removed (its record text stays). Remove an
image by deleting the `[image]` table from the record (the card falls back to a typographic tile).

Left out on purpose: sponsor advertisements in the Scrapling README, badges, benchmark charts, and the
Cognee demo frame (it carried a vendor benchmark claim; the wordmark is used instead).

| Project | File | Kind | Repo licence | Status | Source |
|---|---|---|---|---|---|
| AgentField | `agent-field--agentfield.webp` | screenshot | Apache-2.0 | OK permissive | https://github.com/Agent-Field/agentfield/blob/HEAD/assets/UI.png |
| Dash | none (no usable README image; plate) | | Apache-2.0 | | |
| ai-memory | `akitaonrails--ai-memory.webp` | logo | MIT | OK permissive | https://github.com/akitaonrails/ai-memory/blob/HEAD/docs/logo-light.png |
| Token Optimizer | `alexgreensh--token-optimizer.webp` | screenshot | NOASSERTION | REVIEW: NOASSERTION (The LICENSE file is PolyForm Noncommercial 1.0.0, with a sep) | https://github.com/alexgreensh/token-optimizer/blob/HEAD/skills/token-optimizer/assets/dashboard-demo.gif |
| Context Ontology Accelerator | none (no usable README image; plate) | | Apache-2.0 | | |
| CLI Agent Orchestrator | `awslabs--cli-agent-orchestrator.webp` | banner | Apache-2.0 | OK permissive | https://github.com/awslabs/cli-agent-orchestrator/blob/main/docusaurus/static/img/cao-social-card.png |
| Browser Use | none (no usable README image; plate) | | MIT | | |
| WrenAI | `canner--wrenai.webp` | diagram | NOASSERTION | REVIEW: NOASSERTION (The LICENSE file says the repository is licensed by path: co) | https://github.com/Canner/WrenAI/blob/HEAD/misc/wren-ai-architecture.png |
| Scrapling | none (no usable README image; plate) | | BSD-3-Clause | | |
| codebase-memory-mcp | `deusdata--codebase-memory-mcp.webp` | screenshot | MIT | OK permissive | https://github.com/DeusData/codebase-memory-mcp/blob/main/docs/images/lens-system-structure.png |
| vir | `djolex999--vir.webp` | screenshot | MIT | OK permissive | https://github.com/djolex999/vir/blob/HEAD/docs/graph.png |
| Docling Graph | `docling-project--docling-graph.webp` | logo | MIT | OK permissive | https://github.com/docling-project/docling-graph/blob/HEAD/docs/assets/logo.png |
| nodeterm | `eneskirca--nodeterm.webp` | logo | NOASSERTION | REVIEW: NOASSERTION (The LICENSE file is Business Source License 1.1 with an addi) | https://github.com/eneskirca/nodeterm/blob/HEAD/docs/assets/nodeterm.png |
| Dex | `exmergo--dex.webp` | banner | Apache-2.0 | OK permissive | https://github.com/exmergo/dex/blob/HEAD/assets/preview-light.png |
| Fabro | `fabro-sh--fabro.webp` | screenshot | MIT | OK permissive | https://github.com/fabro-sh/fabro/blob/HEAD/docs/public/images/runs-board.png |
| agtx | none (no usable README image; plate) | | Apache-2.0 | | |
| Beads | none (no usable README image; plate) | | MIT | | |
| Locals | none (no usable README image; plate) | | Apache-2.0 | | |
| Graphiti | `getzep--graphiti.webp` | diagram | Apache-2.0 | OK permissive | https://github.com/getzep/graphiti/blob/main/images/graphiti-graph-intro.gif |
| SDL-MCP | `glitterkill--sdl-mcp.webp` | banner | NOASSERTION | REVIEW: NOASSERTION (The LICENSE file is a custom source-available Community Lice) | https://github.com/GlitterKill/sdl-mcp/blob/HEAD/docs/readme-assets/readme-hero-v10.webp |
| Helix Foundry | none (no usable README image; plate) | | Apache-2.0 | | |
| LightRAG | `hkuds--lightrag.webp` | screenshot | MIT | OK permissive | https://github.com/HKUDS/LightRAG/blob/HEAD/README.assets/iShot_2025-03-23_12.40.08.png |
| Scientific Agent Skills | none (no usable README image; plate) | | MIT | | |
| Agentic Context Engine | `kayba-ai--agentic-context-engine.webp` | banner | Apache-2.0 | OK permissive | https://github.com/kayba-ai/agentic-context-engine/blob/HEAD/assets/kayba-banner.png |
| Kedro-Viz | `kedro-org--kedro-viz.webp` | screenshot | Apache-2.0 | OK permissive | https://github.com/kedro-org/kedro-viz/blob/main/.github/img/banner.gif |
| Langfuse | none (no usable README image; plate) | | NOASSERTION | | |
| Letta (formerly MemGPT) | none (no usable README image; plate) | | Apache-2.0 | | |
| SigMap | `manojmallick--sigmap.webp` | logo | MIT | OK permissive | https://github.com/manojmallick/sigmap/blob/HEAD/assets/logo.png |
| Mem0 | `mem0ai--mem0.webp` | banner | Apache-2.0 | OK permissive | https://github.com/mem0ai/mem0/blob/main/docs/images/banner-sm.png |
| Data Formulator | none (no usable README image; plate) | | MIT | | |
| Waza | none (no usable README image; plate) | | MIT | | |
| Context Mode | `mksglu--context-mode.webp` | banner | NOASSERTION | REVIEW: NOASSERTION (Elastic License 2.0 (ELv2), read from the repository LICENSE) | https://github.com/mksglu/context-mode/blob/main/docs/assets/readme/hero-light.png |
| MCP Registry | none (no usable README image; plate) | | NOASSERTION | | |
| OpenShell | `nvidia--openshell.webp` | logo | Apache-2.0 | OK permissive | https://github.com/NVIDIA/OpenShell/blob/main/docs/brand/assets/openshell-avatar-1024.png |
| OpenLineage | `openlineage--openlineage.svg` | diagram | Apache-2.0 | OK permissive | https://github.com/OpenLineage/OpenLineage/blob/main/doc/with-ol.svg |
| OpenTabs | `opentabs-dev--opentabs.webp` | screenshot | MIT | OK permissive | https://github.com/opentabs-dev/opentabs/blob/HEAD/assets/demo-hero.gif |
| Repowire | `prassanna-ravishankar--repowire.webp` | diagram | none | REVIEW: none (GitHub reports no license and the repository has no LICENSE ) | https://github.com/prassanna-ravishankar/repowire/blob/HEAD/images/repowire-arch.webp |
| SQLLineage | `reata--sqllineage.webp` | diagram | MIT | OK permissive | https://github.com/reata/sqllineage/blob/master/docs/_static/table.jpg |
| Duckle | `slothflowlabs--duckle.webp` | screenshot | Apache-2.0 | OK permissive | https://github.com/slothflowlabs/duckle/blob/HEAD/docs/assets/real-life-screenshot/mega-pipeline-join.png |
| Claude Squad | none (removed, AGPL-3.0 repo; plate) | | AGPL-3.0 | | |
| SQLMesh | `sqlmesh--sqlmesh.webp` | diagram | Apache-2.0 | OK permissive | https://github.com/TobikoData/sqlmesh/blob/main/docs/readme/architecture_diagram.png |
| Storybloq | `storybloq--storybloq.webp` | screenshot | NOASSERTION | REVIEW: NOASSERTION (The README and the LICENSE file state PolyForm Shield 1.0.0,) | https://github.com/Storybloq/storybloq/blob/HEAD/assets/board.png |
| Tank | none (no usable README image; plate) | | MIT | | |
| zeroshot | none (no usable README image; plate) | | MIT | | |
| QMD | none (no usable README image; plate) | | MIT | | |
| Cognee | `topoteretes--cognee.svg` | logo | Apache-2.0 | OK permissive | https://github.com/topoteretes/cognee/blob/main/assets/cognee-logo.svg |
| Cua | `trycua--cua.webp` | banner | MIT | OK permissive | https://github.com/trycua/cua/blob/HEAD/img/card-cua-spaces-wide.webp |
| PageIndex | `vectifyai--pageindex.webp` | diagram | MIT | OK permissive | https://docs.pageindex.ai/images/cookbook/vectorless-rag.png |
| Hindsight | `vectorize-io--hindsight.webp` | diagram | MIT | OK permissive | https://github.com/vectorize-io/hindsight/blob/HEAD/hindsight-docs/static/img/hindsight-overview.webp |
