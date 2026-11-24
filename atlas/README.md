# Systems Atlas: external research catalogue

This is the candidate integrated catalogue, not evidence that the site has deployed it. Hugo mounts `atlas/records/` under `data/atlas` and renders records via `content/atlas/_content.gotmpl`. Existing inspected records and their stated evidence limitations are preserved. No runtime tests or adoption are implied by inclusion.

- `SCHEMA.md` defines the record format; `validate.py` checks it; `check_links.py` checks source URLs.
- `records/` holds the TOML source; `tests/run.sh` exercises valid and invalid examples.
- `COVERAGE.md`, `ledger/` and `PROVENANCE.md` document scope and source/image provenance. Historical counts in earlier evidence are not current verification.

Run `python3 atlas/validate.py atlas/records`, `python3 atlas/lint_copy.py atlas/records` and `bash atlas/tests/run.sh`. Review every record and image right before publication; see LOCAL-GATE.md.
