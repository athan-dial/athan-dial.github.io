# Systems Atlas: draft records (not published)

Draft, portable content model and 16 candidate records. Lives outside `content/`, `data/` and
`layouts/`, so Hugo does not build or publish it.

- `SCHEMA.md` the record format. `validate.py` checks it. `check_links.py` link-checks every URL.
- `records/` one TOML file per candidate. `tests/run.sh` proves valid sets pass and bad ones fail.
- `COVERAGE.md` what the seed covers and does not. `ledger/` provenance and the screening checklist.

Run: `python3 atlas/validate.py atlas/records` and `bash atlas/tests/run.sh`.
