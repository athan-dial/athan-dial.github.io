---
title: "Work"
summary: "Product narratives, not project summaries. Each one is a decision I owned, the boundary I drew, and what the record actually supports."
# Stated once, above the cases. The two published pieces are the whole set deliberately —
# see the proof-layer spec. Do not add a third narrative to make the page look fuller.
evidence_note: "Every figure here is either measured and labelled as measured, or given as a range because the exact value should not publish. Where something was never instrumented, the case says so. That gap is part of the evidence, not a footnote hiding one."
# The section INDEX is public — it is a primary nav target (menus.en.toml, weight 1) and
# must appear in sitemap.xml. These two fields are what layouts/sitemap.xml checks; the
# cascade below is unchanged and still defaults every CHILD page to draft/private.
status: published
visibility: public
cascade:
  - _target:
      kind: page
    status: draft
    visibility: private
    evidence_status: needs-verification
    employer_review: pending
    draft: true
---

Two product narratives. Each one starts with the decision, names who was doing the work,
draws the boundary between what the software made reliable and what stayed with the
expert, and separates what I owned from what the team owned.

Items appear here only after they clear evidence classification and employer review.
Nothing unpublished ships by accident, and the collection stays small on purpose.
