# Historical integration decisions

Candidate assembled from the engineering setup commit, the public PR #12 tree and the stacked PR #3 tree. This is source reconciliation, not a release or verification verdict.

- Preserve the proof-layer About/Work/Fieldnotes structure, computed research evidence, documentary case voice, high-resolution Outer Loop resource and Atlas navigation/record adapters.
- Keep the catalogue's own templates, asset paths, validators and source records. Retain the narrow navigation and reduced-motion improvements; omit the compact Work and About replacement templates and their obsolete motion selectors.
- Preserve the four unapproved draft stories on the original content-review branch; do not copy them or their fixed five-story gate into the candidate. The documentary voice check applies to all integrated flagship/proof-note sources. Remove the draft-only validation anecdote from About and link to the existing public verification note instead.
- Carry the documented quarantine decision into the integrated source. The former URL redirects to Work. Keep the prior source record on its original branch. The proof-layer and render gates distinguish that explicit redirect from a real case.
- Exclude out/, browser logs, retrospective.png and generated evidence artifacts. Retain original branch and PR history. No old PR is closed or merged.
- Preserve established publication constraints and current-head review. No claim of Hugo, browser or image-rights verification is made by this source-only operation.

## Older design branches

- design/hallmark-motif: its unique commitment (90153e3) is the lossless 1254px Outer Loop plate, two density variants, fixed desktop track and scrollable narrow plate. Those changes are already included through the proof-layer branch; the integrated home keeps them and the later duplicate-card fix. No extra merge is needed.
- design/expressive-layer: its unique commitment (f9bb50e) introduced the older Hybrid + book expressive CSS layer and alternative boundary/case diagrams, including one for the now-withheld case. The current Fieldnotes design authority and schematic system supersede that direction. Do not recover the obsolete layer or disputed case visualization. Retain the branch as history.

The first review workflow run built the site and passed the substantive checks; only git diff --check rejected CRLF line endings in the inherited provenance CSV. Normalize those 17 line endings without altering fields. The subsequent workflow adds a browser smoke check using the prior spike's pinned Playwright version. This tests viewport layout, keyboard skip link, JS-disabled content, catalogue search and a text-size proxy; it does not authorize publication.
