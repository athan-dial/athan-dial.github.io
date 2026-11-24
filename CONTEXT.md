# Personal Fieldnotes domain context

A personal website and publication for work on AI, data, product judgment and expert practice. This is a single Hugo site, with content and rendering modules rather than separate products.

## Vocabulary

| Term | Meaning |
| --- | --- |
| Fieldnotes | The publication at /thinking/, including essays and shorter notes. |
| Selected work | Evidence-bounded descriptions of actual decisions, products or systems, including the author's role and limits of the available evidence. |
| Profile | The canonical public identity data in data/profile.toml. Confirm factual changes before publication. |
| Public page | Content intended and approved for publication; satisfy applicable status, visibility, draft, and employer-review rules. |
| Draft | Work withheld from production output. In a public Git repository, a draft flag is not a confidentiality boundary. |
| Evidence | Source support for a specific claim; an observed outcome, range, mechanism, hypothesis or unknown must remain distinguishable. |
| Redirect stub | A retired URL whose only purpose is to direct readers to its canonical successor. |
| Publication gate | The existing checks and human review required before the built website may be released. |
| Systems Atlas | Curated research notebook on other people's software at /atlas/. The value is selection and judgment; inspected software is not necessarily tested or adopted. It is distinct from The Agentic Operating System. |
| The Agentic Operating System | Personal operating system for agent-enabled work at /work/agentic-operating-system/. It leads with eight task-led guides and keeps the seven architecture views underneath. Draft until the owner approves it. See `EDITORIAL.md`. |
| EDITORIAL.md | Canonical authority for all public prose: positioning, voice, claims, page jobs. |
| Guide | A task-led worked example on the Agentic Operating System page: when to use it, what it produces, steps, a resulting artifact, a stop condition and its limits. Avoid: tutorial, walkthrough. |
| Skill | A reusable agent instruction named in a guide. Each has a source kind. Avoid: prompt, plugin. |
| Source kind | Whose instructions a skill is: upstream used as published, upstream adapted by me, or mine (private). Private text is never published; the guide describes it in the author's own words. |
| Upstream | The public skills repository by Matt Pocock (MIT), linked only at one pinned revision and never presented as the author's own version. |
| Registry | The single validated model in data/workflows/registry.json for skills, source status and which guide uses which skill and view. Guide text and source lists derive from it. |
| Synthetic example | The invented project (an in-house tool for comparing plate-reader assay runs) that all guides share. Nothing in it is a real outcome, person or organisation. |
| View | One of the seven Arc architecture diagrams under the guides, from the overview down to the mechanics. Avoid: layer, page. |
| Decision map | A set of decision tickets worked one at a time and ending in a specification. It plans and builds nothing. Avoid: roadmap, plan. |
| Build graph | Work slices with blocking edges, all known up front and ending in checked code. Not a decision map. |
| Slice | A thin end-to-end piece of work with a check you can run on its own. A question is not a slice. |
| Frontier | On a decision map, the open decisions that nothing blocks and no one has claimed. |
| Fog | Decisions you can sense on a decision map but cannot yet state as a sharp question. |

## Boundaries

- Hugo is the existing static publishing system; preserve canonical URLs and Fieldnotes design.
- Content sources and their ownership belong in the content/data layer; presentation belongs in Hugo layouts and scoped styles. Preserve current source authorities until a reviewed migration changes them.
- Validate source safety and rendered output separately. A missing private denylist is not a full safety verdict.
- Review release candidates on exact commits. Approval to build is not approval to publish.
- The Agentic Operating System page and the Systems Atlas do not establish that those features are live; the first is draft-only and gated by the owner.

See PRODUCT.md, DESIGN.md, DIAGRAMS.md, CLAUDE.md and .planning/CONTENT-MODEL.md. Record new settled decisions in the relevant GitHub issue; update this glossary only when a domain term changes.
