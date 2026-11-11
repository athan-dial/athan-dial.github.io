# Verification map, mapped to the real ticket ids (self-reported evidence, not self-graded)

Evidence folder (local, outside every repo, unpublished): `~/Github/_scratch-701/evidence/`. Inventory: `out/INVENTORY.md`.

| Id | Evidence | Status |
|---|---|---|
| R1 | Inspected-file index with repo URL, path, SHA: INVENTORY section 0. Nima repo `ac0cd31f`; Craft Anything `078cf0c4`; ours `c48bcc36` (remote main `3640e693`) | covered; verifier should resolve the SHAs |
| R2 | INVENTORY section 3: desktop (1440x900) and mobile (390x844) for feed, search/filter, detail, navigation, each row marked [I] or [A]; 14 screenshots in the evidence folder (`radar-{desktop,mobile}-{feed,search,filter,detail}.png`, `radar-mobile-menu.png`, plus narrow Orca captures) | covered; desktop and phone width taken with Playwright because Orca's pane cannot be resized; JS-off, keyboard and performance not tested (marked [A]) |
| R3 | INVENTORY section 1: URL, SEO, RSS, build, design system, deployment, each with source | covered; baseline is the worktree base, which is behind remote `main` |
| R4 | INVENTORY section 4: reuse list, license boundary, site constraints, unresolved repo identity (section 2), minimum slice, integration path, blockers; path copies nothing from Nima | covered; "Atlas" undefined in source material, noted |
| C1 | Only reads, public shallow clones in `~/Github/_scratch-701` and a scratch-dir build; no edits to either site. Craft Anything: C1 search found no match; identity then set by Athan's confirmation (recorded as the source), then inspected read-only | covered |
| C2 | Outputs describe behavior in my own words; no Nima code, text, brand or asset in any output file. Screenshots are outside every repo and absent from `git status` | covered; verifier should diff against `ac0cd31f` |
| C3 | Every INVENTORY row carries [I] or [A] plus a source | covered; verifier should spot-check |
| C4 | Outputs hold no private or employer-related text (grepped for the employer name: 0 hits); local drafts only | covered |
| C5 | No push, PR, merge, deploy or paid service. Earlier push of `1bb7682d` was reversed by the supervisor (remote branch deleted, 2026-11-04); all work is local commits only. `1bb7682d` still exists in local history and contains an older inventory that quoted some Radar labels; it is not published anywhere | covered; local history not rewritten |

Output scrub (2026-11-04): `out/` holds no quoted Radar labels or headings, no Nima text and no screenshots; descriptive wording only. Screenshots stay in the evidence folder. Jira untouched, nothing marked Done.
