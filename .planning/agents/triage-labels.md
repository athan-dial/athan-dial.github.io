# Triage labels

Use the following canonical roles. Apply the appropriate role additively without removing existing unrelated labels. When changing a triage role, remove only the previous triage-role label.

| Role | Label | Meaning |
| --- | --- | --- |
| Untriaged | needs-triage | Proposal or unassessed work. |
| Missing information | needs-info | A material requirement, decision or evidence is missing. |
| Agent-ready | ready-for-agent | Acceptance is explicit, scope bounded, prerequisites met, and execution authorized. |
| Human-ready | ready-for-human | Human decision or authorization required. |
| Declined | wontfix | Deliberately not planned; record the rationale. |

A dependency edge is separate from triage. Do not label a blocked implementation ready-for-agent. An approved implementation spec does not grant permission to publish or merge.

Retain wayfinder:map, wayfinder:task and wayfinder:grilling as existing decision-map labels. Do not rename or repurpose them.

Bootstrap: inspect labels with gh label list --repo athan-dial/athan-dial.github.io --limit 1000. If any canonical label is missing, create only the missing label after checking that an existing role-equivalent label does not already serve the same purpose. scripts/setup-issue-labels.sh implements this non-overwriting default. Existing labels and colors are preserved. The connector confirmed the active triage labels on issues #10 and #13–#18; it could not enumerate the full repository label inventory.
