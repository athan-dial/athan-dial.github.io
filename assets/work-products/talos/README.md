# Work Product diagram

Native OpenFlowKit 0.3.0 source: `workflow.ofk` (pinned composition) and
`workflow.openflow.json` (editable scene). Export: `workflow.svg`.

Regenerate from the website root with `python3 scripts/render-workflow.py`.
The script uses OpenFlowKit's actual compiler and exporter, including native scene frame placement and fitting
for the four-column pinned layout. The outer compiler frame is excluded through the
native selection export; exported SVG is never rewritten. Do not replace the exported SVG with hand-authored paths.

These are generalized workflow assets, without scientific examples or private links.
Assets live under Hugo resources, so a production build excluding the draft case
will not publish them.

Future cases: `hugo new content work/project.md --kind work-product`, fill the
six-section contract, create a native OpenFlowKit workflow under assets/work-products,
and select it with `diagram`. Add a `stages` list for a numbered text walkthrough,
with `decision_anchor` values matching the decision headings. Keep the evidence register in ignored `_private/`.
Review-only Work links appear with `hugo -D`; publication requires human clearance,
then `draft: false`, `status: published`, and `visibility: public`.

The generator places provenance descriptions as native editable 15px text nodes because
OpenFlowKit 0.3.0 fixes icon-card sublabels at 11px. Stage frames and cards use native
square-corner appearance settings. Return routes are native scene waypoints derived
from node bounds; the compiler and exporter remain unmodified. The image preserves
its natural width, with an HTML text walkthrough for narrow screens.

OpenFlowKit 0.3.0 exports provenance description text nodes as centered
(`text-anchor="middle"`); the scene sets `textAlign: start` but the exporter
ignores it. Left-aligned descriptions require a renderer change or post-export
SVG edits, which this pipeline does not do.
