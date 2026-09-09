# Fieldnotes schematics

One diagram, one idea worth remembering. Start by stating what the reader should understand;
then include only the relationships needed to explain it. Use prose for a trivial sequence.

| Shape | Meaning |
| --- | --- |
| Paper card with doubled left rule | A data state, input, output, or evidence |
| Forest block | A tool or action |
| Citrus block with heavy top rule | Human judgment or authorization |
| Forward arrow | Flow or dependency |
| Dashed return | Feedback or revision |

Use a numbered eyebrow, a claim-style serif title, explicit node types, short concrete labels,
and a one-sentence takeaway. Colors come from the site's tokens. Shapes and labels retain meaning
without color. Citrus does not mean success; forest does not mean verified.

## Current examples

- `{{< fieldnote-schematic "outer-loop" >}}` — the relationship between product judgment and
  the plan/build/verify loop. Used in The Outer Loop.
- `{{< fieldnote-schematic "known-positives" >}}` — structural validity versus domain verification.
  Used in the all-false-column note.
- `{{< boundary-diagram >}}` — the existing expert/shared-capability boundary in the analog-search case.

Implementation: `layouts/partials/fieldnote-schematic.html` and `assets/css/fieldnotes.css`.
Unknown schematic names fail the Hugo build. Keep prose and diagrams consistent. Diagram labels
must not add factual claims, imply measurements, or grant authority absent from the article.

## Future notes and experiments

Create notes through the existing `archetypes/note.md`. Keep the default draft/private state until
review. Optional `format` can say `Workflow` or `Experiment`, and optional `card_summary` can shorten
the archive excerpt. Article content and diagrams remain normal Hugo source; no CMS or runtime service
is added. A useful experiment describes the question, setup, observation, limitations, and next step.
Only report outcomes actually observed. Reusable procedures belong beside the evidence that supports them.

## Reuse prompt

Design a Fieldnotes schematic for this note. State its single claim first. Use the smallest useful
set of entities, actions and relationships. Use paper for states/evidence, forest for actions/tools,
and citrus for human judgment, with explicit type labels. Name relationships where an unlabeled
arrow could be ambiguous. Make important branches, boundaries and feedback visible. Give it a
numbered classification, a claim headline and one takeaway. Implement in semantic HTML with the
existing diagram classes; let text wrap and recompose the flow on narrow screens. Do not invent
measurements, outcomes, authority or causal relationships. If prose explains it better, say so.
