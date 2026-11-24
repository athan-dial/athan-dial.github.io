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
| Systems Atlas | Proposed external software research catalogue at /atlas/, currently on an unmerged branch. Inspected software is not necessarily tested or adopted. |
| Interactive architecture | Proposed navigable explanation of an agentic workflow system, distinct from the external research catalogue. |

## Boundaries

- Hugo is the existing static publishing system; preserve canonical URLs and Fieldnotes design.
- Content sources and their ownership belong in the content/data layer; presentation belongs in Hugo layouts and scoped styles. Preserve current source authorities until a reviewed migration changes them.
- Validate source safety and rendered output separately. A missing private denylist is not a full safety verdict.
- Review release candidates on exact commits. Approval to build is not approval to publish.
- The interactive architecture and Systems Atlas proposals do not establish that those features are live.

See PRODUCT.md, DESIGN.md, DIAGRAMS.md, CLAUDE.md and .planning/CONTENT-MODEL.md. Record new settled decisions in the relevant GitHub issue; update this glossary only when a domain term changes.
