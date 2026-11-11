# Verification map

Self-reported evidence for an independent verifier. I do not grade this work. Labels: [M] measured, [I] inspected.

Re-run everything: `out/reproduce.sh` (clean `git archive` of this branch, builds both, runs the probe).

| Id | Evidence | Where | Verify by |
|---|---|---|---|
| R1 | Commands and recorded outputs for Hugo and Astro; both slices built, no duplicate skipped [M] | `out/reproduce.sh`, `out/prototypes/`, `out/evidence/results.json`, `build_metrics.txt` | Run `out/reproduce.sh`; every key in its `results/results.json` should equal `out/evidence/results.json`. I did this from a clean archive: no differing keys. |
| R2 | Each tradeoff in the REPORT difference table cites a measurement or code observation [M, I] | `REPORT.md` "Where they differ"; `evidence/change_size.txt`, `validation_test.txt`, `lighthouse_summary.txt`, `build_metrics.txt` | Match each table row to the named file. Includes two defects I hit in each stack. |
| R3 | States Hugo is sufficient and gives three observable triggers with numbers [A] | `REPORT.md` "Recommendation" | Read the section. Thresholds are proposals; the decision gate says Athan sets them. |
| R4 | Gate is open and lists unmade decisions | `DECISION-GATE.md` | Status OPEN; five unmade decisions; decision record blank. |
| C1 | Production untouched, nothing pushed [M] | `git diff --stat <base>..HEAD -- . ':!out'` is empty; `git rev-parse @{u}` fails (no upstream); `git log origin/main..HEAD` shows only my local `compare:` commits | Run the three commands. Prototype edits live only in scratch copies; the Hugo changes exist only as `out/prototypes/hugo-slice.patch`. |
| C2 | No paid or hosted service [I] | Only free npm packages (`astro`, `@astrojs/rss`, `axe-core`, `lighthouse`) and a local static server; no CMS, API or hosting | `grep -rn "http" out/prototypes` shows only public site URLs and docs links. |
| C3 | Nothing from Nima's repository or site [I] | I did not open that repo or site in this task. The slice features come from the ticket text. | `grep -rniE "nima|radar|aksoy" out` finds only the sentence in `WORKLOG.md` saying it was not opened. |
| C4 | Inspected versus measured stated; limits listed [I] | `REPORT.md` labels each row [M]/[I]/[A] and has a "Not covered" list; whole-site migration is marked inspected, not built | Spot-check three rows against `evidence/`. |
| C5 | No private or employer content [I] | Records are synthetic and say so; screenshots show the public site shell only (footer shows the words LinkedIn and Email, no address) | Open `out/slice/records.json` and `out/evidence/screens/`. |
| C6 | No outbound action [M] | Same checks as C1; no push, PR, deploy or Slack/email | `git status -sb` shows no upstream. |
| line8 (required evidence list) | comparable build outputs: `build_metrics.txt`, `hugo_pinned_version_check.txt`; screenshots: `evidence/screens/` (8 files) and `pixel_diff.txt`; performance and accessibility checks: `lighthouse_summary.txt`, `results.json` (axe keys); change-size estimate: `change_size.txt` and "Whole-site migration" in `REPORT.md`; recommendation: `REPORT.md`; unmade decisions: `DECISION-GATE.md` | `out/` | Each item exists at the named path. |

## Known gaps a verifier should know about

- Build timings are noisy (Astro 4.0 to 15.1 s across 5 cold runs) and Lighthouse is one run per page; neither supports a ranking.
- One 30 px band differs between the two detail screenshots at 390 px; cause not found.
- Records are synthetic; the real schema may change the numbers.
- The Hugo patch applies to this repo at base `c48bcc36`, which is behind remote `main`.
