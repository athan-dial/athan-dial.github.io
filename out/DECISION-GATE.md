# Decision gate: platform for the Atlas

**Status: DECIDED 2026-11-06 for decision 1 and 2 (keep Hugo, proposed thresholds). Decisions 3 to 5 remain open. Owner: Athan.**

The report recommends keeping Hugo (`REPORT.md`). That is a recommendation, not a selection. It stays open until Athan records a choice here.

## Decisions not made

1. **Platform.** Keep Hugo, adopt Astro, or defer. Options: keep Hugo (recommended), adopt Astro, defer until a trigger fires.
2. **Migration trigger thresholds.** The report proposes: 3 or more interactive pieces sharing state or a page script near 150 lines; 2 or more cross-referencing record types or a validation block near 50 lines or one bad record live; more than about 10 content files needing interactive embeds. Athan sets or changes the numbers.
3. **Whether to add Next.js or any other candidate.** No concrete requirement was found, so it was not compared. Adding one needs Athan's go.
4. **How Atlas pages appear in feeds.** In Hugo, adding the section adds every record to the live `/index.xml` and sitemap by default. Whether Atlas records belong in the main feed is open.
5. **Whether the real records step should be re-measured.** The slice used 12 synthetic records. Re-running `out/reproduce.sh` against the real schema would confirm the numbers.

## Not done, and not authorized by this report

No migration, redesign, deployment, push or PR. No paid or hosted service. Production files, `main` and the live site are unchanged.

## Record of the decision (blank until Athan fills it)

- Date: 2026-11-06
- Choice: Keep Hugo
- Thresholds set: as proposed (3+ interactive pieces sharing state or ~150-line page script; 2+ cross-referencing record types or ~50-line validation block or one bad record live; 10+ content files needing interactive embeds)
- Notes: Independent re-run of out/reproduce.sh on 2026-11-06 matched out/evidence/results.json on every key. Decisions 3 to 5 not addressed.
