---
title: "An all-false column is a legal column"
type: note
date: 2026-08-12
summary: "A one-character naming mismatch made a boolean false for every row. Five layers each behaved correctly and nothing threw. The only check that caught it was a person who knew the answer was impossible."
status: published
visibility: public
themes: [reliable-ai-systems, expert-workflows]
source_url: ""
# De-identified from a private work case. No employer, program, domain, or figure appears
# here: the original named the entity type, the downstream workflow, and the purchase cost,
# and any of those plus a public employer would identify the incident. The mechanism and the
# verification lesson survive intact, which is the part that generalises. This is why the
# note carries no `role` or `users` — with the ownership context removed it is an
# observation, not a case, so it belongs here rather than in /work/.
draft: false
---

A configuration named a set in the plural. The schema expected the singular. One character.

Nothing threw. Here is what each layer did with it:

1. **Lookup.** The name did not match, so the set resolved to nothing.
2. **Pivot.** With no set to match against, the pivot evaluated false on every row.
3. **Derived table.** The all-false value landed in the derived properties table unchanged.
4. **Exposed field.** The field downstream consumers read was false for every row.
5. **Workflow.** A workflow that commits budget consumed that field as ground truth and acted on it.

Every one of those layers did exactly what it was told. The lookup could not find a set under a name that did not exist. The pivot correctly produced false. The derived table correctly stored what it received. The exposed field correctly served what it stored. The workflow correctly acted on what it read. There is no layer in that chain you could point at and call broken.

## Why nothing caught it

An all-false boolean is a legal column.

That is the whole problem. Schema validation passes: the type is right, the nulls are absent, the row count is what it should be. Freshness checks pass, because the data did arrive. Generic data-quality tests are built to catch absence, malformation, and drift, and this was none of those. It was a well-formed answer to a question nobody meant to ask.

The check that fired was a person. Someone with domain knowledge queried for records they knew existed, got an empty result, and recognised the answer as impossible. That mismatch, not a failing job, opened the thread. The fix once found was a one-line rename.

I want to be careful about what I am claiming. I cannot give you a clean inventory of the test suite that existed beforehand, so I am not going to characterise it. What I can stand behind is the failure mode that got through, and that one is not unique to any particular warehouse.

## What it implies for verification

The useful move is not more generic tests. It is a **non-generic** one: a test that fails when a column which should contain known positives contains none.

That test cannot be written by someone who only knows the schema. It requires knowing that a specific set of records must come back true — which is domain knowledge, written down and made executable. It is the difference between asserting a column is well-formed and asserting it is *right*.

Most of what we call data quality is the first kind. The incidents that hurt are the second kind, because a shared attribute that looks precise and is silently wrong propagates further than one that is obviously missing.

The money in this case was trivial, which is close to the point. The damage was not the spend. It was that five systems agreed on a wrong answer, and the only reason anyone noticed is that a human still knew what the answer was supposed to be.
