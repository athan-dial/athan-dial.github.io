# Coverage statement (draft)

The accessible input was a partial seed index of 207 candidate GitHub repositories recovered
from morning-digest and investigation history. It is **not a verified inventory and not a complete
history**. This work does not claim full coverage of anything the history contained.

- Seed rows: 207. Distinct canonical owner/repo identities: 207 (no duplicates found).
- Every seed row carried `historically_recovered_unverified`. That column and the
  `coverage_note` column were treated as claims to re-check, not evidence.
- Upstream check run 2026-11-04 over all 207 rows (read-only, public GitHub API metadata):
  205 resolved to a public repository; 2 did not resolve at the seed URL (`404`). One of those two
  appears to have moved to a different owner; the new owner is not in the seed, so no link was added.
  Both stay `unverified` and are not selected.
- Selected for the prototype: **16** records (target was 12 to 20), all `inspected`, all `candidate`.
  The other 191 rows are not selected. They stay `unverified` for editorial purposes: resolving a URL is not the
  same as reading the license, reading the README and screening for fit.
- Selection was by editorial judgment for topic spread and clear public documentation, not by
  popularity. Topics: agent memory (4), agent orchestration (2), data lineage (2), and one each for
  data transformation, pipeline visualization, protocol registry, web scraping, code intelligence,
  scientific skills, agent sandboxing, agent tooling.
- Not selected on purpose: repositories that read as personal tools or personal workflows, and any
  repository whose ownership or relation to private work was unclear. No reason beyond the
  category is recorded, because recording more would describe private context.
- Evidence states: all 16 are `inspected` (README, license and repository metadata were read).
  None is `evaluated`, `tested` or `adopted`. No experiment is claimed.
- Dates: 10 of 16 records have `date_not_recovered`, because the seed did not recover them.
- Licenses read from the repositories: 14 SPDX-identified; `modelcontextprotocol/registry`
  (mixed MIT/Apache-2.0 transition, per its LICENSE) and `mksglu/context-mode` (Elastic License
  2.0, source-available) carry a `license_note`. `smtg-ai/claude-squad` is AGPL-3.0.
- The seed CSV is archived read-only outside every repository and is not copied here. Its hash was
  re-checked against `MANIFEST.sha256` after this work (see `out/VERIFICATION.md`).
