# Work Product diagram

Native OpenFlowKit 0.3.0 source: `workflow.ofk` (pinned composition) and
`workflow.openflow.json` (editable scene). Export: `workflow.svg`.

Regenerate from the website root with `python3 scripts/render-workflow.py`.
The script uses OpenFlowKit's actual compiler and exporter, including frame fitting
for the pinned layout. Do not replace the exported SVG with hand-authored paths.

These are generalized workflow assets, without scientific examples or private links.
Assets live under Hugo resources, so a production build excluding the draft case
will not publish them.

Future cases: `hugo new content work/project.md --kind work-product`, fill the
six-section contract, create a native OpenFlowKit workflow under assets/work-products,
and select it with `diagram`. Keep the evidence register in ignored `_private/`.
Review-only Work links appear with `hugo -D`; publication requires human clearance,
then `draft: false`, `status: published`, and `visibility: public`.
