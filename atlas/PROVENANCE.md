# Atlas image provenance

Self-hosted copies of images from each project's own README or repository, shown on `/atlas/` with a credit line
and an "Original" link. Files live in `assets/atlas/`; each record's `[image]` table points at one. Raster
images were resized to at most 1200px wide and re-encoded as WebP; animated GIFs were reduced to one still
frame (the most detailed). Transparent images were flattened onto white. Nothing is hotlinked.

Decision 2026-11-06 (Athan): include banners and logos and include every licence class. That means the
repo licence below does NOT clear the image: a repo licence may not cover its artwork, and logos are
trademarked. Rows marked REVIEW need Athan's explicit OK in LOCAL-GATE.md step 4 before any push. Tier 2 additions (2026-11-06) follow the same rules. Tier 1 additions (2026-11-06): image risk accepted by Athan, AGPL repos get no image. Decision 2026-11-06 (Athan): no images from AGPL repos; the Claude Squad image was removed (its record text stays). Remove an
image by deleting the `[image]` table from the record (the card falls back to a typographic tile).

Left out on purpose: sponsor advertisements in the Scrapling README, badges, benchmark charts, and the
Cognee demo frame (it carried a vendor benchmark claim; the wordmark is used instead).

| Project | File | Kind | Repo licence | Status | Source |
|---|---|---|---|---|---|
| Cate | `0-ai-ug--cate.webp` | screenshot | MIT | OK permissive | https://github.com/0-AI-UG/cate/blob/HEAD/assets/demo-canvas.gif |
| ECC | `affaan-m--ecc.webp` | banner | MIT | OK permissive | https://github.com/affaan-m/ECC/blob/HEAD/assets/hero.png |
| AgentField | `agent-field--agentfield.webp` | screenshot | Apache-2.0 | OK permissive | https://github.com/Agent-Field/agentfield/blob/HEAD/assets/UI.png |
| Dash | none (no usable README image; plate) | | Apache-2.0 | | |
| ai-memory | `akitaonrails--ai-memory.webp` | logo | MIT | OK permissive | https://github.com/akitaonrails/ai-memory/blob/HEAD/docs/logo-light.png |
| Token Optimizer | `alexgreensh--token-optimizer.webp` | screenshot | NOASSERTION | REVIEW: NOASSERTION | https://github.com/alexgreensh/token-optimizer/blob/HEAD/skills/token-optimizer/assets/dashboard-demo.gif |
| Data Engineering Skills | none (no usable README image; plate) | | MIT | | |
| GPT Researcher | none (no usable README image; plate) | | Apache-2.0 | | |
| Context Ontology Accelerator | none (no usable README image; plate) | | Apache-2.0 | | |
| CLI Agent Orchestrator | `awslabs--cli-agent-orchestrator.webp` | banner | Apache-2.0 | OK permissive | https://github.com/awslabs/cli-agent-orchestrator/blob/main/docusaurus/static/img/cao-social-card.png |
| Unlimited OCR | none (no usable README image; plate) | | MIT | | |
| Browser Use | none (no usable README image; plate) | | MIT | | |
| WrenAI | `canner--wrenai.webp` | diagram | NOASSERTION | REVIEW: NOASSERTION | https://github.com/Canner/WrenAI/blob/HEAD/misc/wren-ai-architecture.png |
| Feynman | `companion-inc--feynman.webp` | screenshot | MIT | OK permissive | https://github.com/Companion-Inc/feynman/blob/HEAD/assets/hero.png |
| Scrapling | none (no usable README image; plate) | | BSD-3-Clause | | |
| Indra OCR | none (no usable README image; plate) | | Apache-2.0 | | |
| codebase-memory-mcp | `deusdata--codebase-memory-mcp.webp` | screenshot | MIT | OK permissive | https://github.com/DeusData/codebase-memory-mcp/blob/main/docs/images/lens-system-structure.png |
| vir | `djolex999--vir.webp` | screenshot | MIT | OK permissive | https://github.com/djolex999/vir/blob/HEAD/docs/graph.png |
| Docling Graph | `docling-project--docling-graph.webp` | logo | MIT | OK permissive | https://github.com/docling-project/docling-graph/blob/HEAD/docs/assets/logo.png |
| LM Wiki | `domleca--llm-wiki.webp` | screenshot | MIT | OK permissive | https://github.com/domleca/llm-wiki/blob/HEAD/docs/assets/query-modal.png |
| nodeterm | `eneskirca--nodeterm.webp` | logo | NOASSERTION | REVIEW: NOASSERTION | https://github.com/eneskirca/nodeterm/blob/HEAD/docs/assets/nodeterm.png |
| agent-autolearn | none (no usable README image; plate) | | MIT | | |
| Dex | `exmergo--dex.webp` | banner | Apache-2.0 | OK permissive | https://github.com/exmergo/dex/blob/HEAD/assets/preview-light.png |
| Fabro | `fabro-sh--fabro.webp` | screenshot | MIT | OK permissive | https://github.com/fabro-sh/fabro/blob/HEAD/docs/public/images/runs-board.png |
| agentos-bench | none (no usable README image; plate) | | Apache-2.0 | | |
| agtx | none (no usable README image; plate) | | Apache-2.0 | | |
| Beads | none (no usable README image; plate) | | MIT | | |
| Locals | none (no usable README image; plate) | | Apache-2.0 | | |
| Graphiti | `getzep--graphiti.webp` | diagram | Apache-2.0 | OK permissive | https://github.com/getzep/graphiti/blob/main/images/graphiti-graph-intro.gif |
| SDL-MCP | `glitterkill--sdl-mcp.webp` | banner | NOASSERTION | REVIEW: NOASSERTION | https://github.com/GlitterKill/sdl-mcp/blob/HEAD/docs/readme-assets/readme-hero-v10.webp |
| EGM | none (no usable README image; plate) | | Apache-2.0 | | |
| Google Skills | none (no usable README image; plate) | | Apache-2.0 | | |
| Floorplan | `haydenschmitty--floorplan.webp` | screenshot | MIT | OK permissive | https://github.com/haydenschmitty/floorplan/blob/HEAD/docs/images/screens.png |
| Helix Foundry | none (no usable README image; plate) | | Apache-2.0 | | |
| LightRAG | `hkuds--lightrag.webp` | screenshot | MIT | OK permissive | https://github.com/HKUDS/LightRAG/blob/HEAD/README.assets/iShot_2025-03-23_12.40.08.png |
| Tessera | none (AGPL-3.0 repo, no image; plate) | | AGPL-3.0 | | |
| OfficeCLI | none (no usable README image; plate) | | Apache-2.0 | | |
| Maestro | `its-maestro-baby--maestro.webp` | screenshot | MIT | OK permissive | https://github.com/its-maestro-baby/maestro/blob/HEAD/assets/platform_screenshot.png |
| Scientific Agent Skills | none (no usable README image; plate) | | MIT | | |
| agent-ctrl | `k4cper-g--agent-ctrl.webp` | logo | Apache-2.0 | OK permissive | https://github.com/k4cper-g/agent-ctrl/blob/HEAD/docs/logo.png |
| Agentic Context Engine | `kayba-ai--agentic-context-engine.webp` | banner | Apache-2.0 | OK permissive | https://github.com/kayba-ai/agentic-context-engine/blob/HEAD/assets/kayba-banner.png |
| Kandev | none (AGPL-3.0 repo, no image; plate) | | AGPL-3.0 | | |
| Kedro-Viz | `kedro-org--kedro-viz.webp` | screenshot | Apache-2.0 | OK permissive | https://github.com/kedro-org/kedro-viz/blob/main/.github/img/banner.gif |
| Obsidian Skills | none (no usable README image; plate) | | MIT | | |
| Langfuse | none (no usable README image; plate) | | NOASSERTION | | |
| AtomisticSkills | none (no usable README image; plate) | | MIT | | |
| Letta (formerly MemGPT) | none (no usable README image; plate) | | Apache-2.0 | | |
| SigMap | `manojmallick--sigmap.webp` | logo | MIT | OK permissive | https://github.com/manojmallick/sigmap/blob/HEAD/assets/logo.png |
| Armory | none (no usable README image; plate) | | MIT | | |
| Mem0 | `mem0ai--mem0.webp` | banner | Apache-2.0 | OK permissive | https://github.com/mem0ai/mem0/blob/main/docs/images/banner-sm.png |
| tld | none (no usable README image; plate) | | Apache-2.0 | | |
| Data Formulator | none (no usable README image; plate) | | MIT | | |
| Ontology Playground | `microsoft--ontology-playground.webp` | screenshot | MIT | OK permissive | https://github.com/microsoft/Ontology-Playground/blob/HEAD/public/og-image.png |
| SkillOpt | none (no usable README image; plate) | | MIT | | |
| Waza | none (no usable README image; plate) | | MIT | | |
| Context Mode | `mksglu--context-mode.webp` | banner | NOASSERTION | REVIEW: NOASSERTION | https://github.com/mksglu/context-mode/blob/main/docs/assets/readme/hero-light.png |
| MCP Registry | none (no usable README image; plate) | | NOASSERTION | | |
| SurfSense | none (no usable README image; plate) | | Apache-2.0 | | |
| REA | none (no usable README image; plate) | | MIT | | |
| last30days | none (no usable README image; plate) | | MIT | | |
| NoteBrain | `nmdra--notebrain-cli.webp` | screenshot | MIT | OK permissive | https://github.com/nmdra/notebrain-cli/blob/HEAD/assets/search.png |
| OpenShell | `nvidia--openshell.webp` | logo | Apache-2.0 | OK permissive | https://github.com/NVIDIA/OpenShell/blob/main/docs/brand/assets/openshell-avatar-1024.png |
| GSD Core | none (no usable README image; plate) | | MIT | | |
| OpenLineage | `openlineage--openlineage.svg` | diagram | Apache-2.0 | OK permissive | https://github.com/OpenLineage/OpenLineage/blob/main/doc/with-ol.svg |
| OpenTabs | `opentabs-dev--opentabs.webp` | screenshot | MIT | OK permissive | https://github.com/opentabs-dev/opentabs/blob/HEAD/assets/demo-hero.gif |
| Repowire | `prassanna-ravishankar--repowire.webp` | diagram | none | REVIEW: none | https://github.com/prassanna-ravishankar/repowire/blob/HEAD/images/repowire-arch.webp |
| SQLLineage | `reata--sqllineage.webp` | diagram | MIT | OK permissive | https://github.com/reata/sqllineage/blob/master/docs/_static/table.jpg |
| relaydeck | none (no usable README image; plate) | | MIT | | |
| Repowise | none (AGPL-3.0 repo, no image; plate) | | AGPL-3.0 | | |
| LiteParse | none (no usable README image; plate) | | Apache-2.0 | | |
| SpectRAG | `sightandcite--spectrag.webp` | diagram | MIT | OK permissive | https://github.com/SightAndCite/SpectRAG/blob/HEAD/assets/online-offline-main-pipeline.png |
| Duckle | `slothflowlabs--duckle.webp` | screenshot | Apache-2.0 | OK permissive | https://github.com/slothflowlabs/duckle/blob/HEAD/docs/assets/real-life-screenshot/mega-pipeline-join.png |
| Claude Squad | none (AGPL-3.0 repo, no image; plate) | | AGPL-3.0 | | |
| Agent Toolkit | none (no usable README image; plate) | | MIT | | |
| SQLMesh | `sqlmesh--sqlmesh.webp` | diagram | Apache-2.0 | OK permissive | https://github.com/TobikoData/sqlmesh/blob/main/docs/readme/architecture_diagram.png |
| Storybloq | `storybloq--storybloq.webp` | screenshot | NOASSERTION | REVIEW: NOASSERTION | https://github.com/Storybloq/storybloq/blob/HEAD/assets/board.png |
| Synapse AI | none (AGPL-3.0 repo, no image; plate) | | AGPL-3.0 | | |
| Tank | none (no usable README image; plate) | | MIT | | |
| agenttop | `tech4242--agenttop.webp` | screenshot | MIT | OK permissive | https://github.com/tech4242/agenttop/blob/HEAD/docs/preview.png |
| zeroshot | none (no usable README image; plate) | | MIT | | |
| QMD | none (no usable README image; plate) | | MIT | | |
| Cognee | `topoteretes--cognee.svg` | logo | Apache-2.0 | OK permissive | https://github.com/topoteretes/cognee/blob/main/assets/cognee-logo.svg |
| Cua | `trycua--cua.webp` | banner | MIT | OK permissive | https://github.com/trycua/cua/blob/HEAD/img/card-cua-spaces-wide.webp |
| Archify | `tt-a1i--archify.webp` | diagram | Apache-2.0 | OK permissive | https://github.com/tt-a1i/archify/blob/HEAD/docs/assets/archify-demo-reach.png |
| PageIndex | `vectifyai--pageindex.webp` | diagram | MIT | OK permissive | https://docs.pageindex.ai/images/cookbook/vectorless-rag.png |
| Hindsight | `vectorize-io--hindsight.webp` | diagram | MIT | OK permissive | https://github.com/vectorize-io/hindsight/blob/HEAD/hindsight-docs/static/img/hindsight-overview.webp |
| terminal-browser | none (no usable README image; plate) | | MIT | | |
