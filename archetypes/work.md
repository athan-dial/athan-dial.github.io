---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
type: work
date: {{ .Date }}
summary: ""
status: draft # draft | published
evidence_status: needs-verification # needs-verification | verified | range-only | mechanism-only
visibility: private # private | public
employer_review: pending # pending | cleared | n-a
featured: false
role: ""
users: []
themes: [] # expert-workflows | product-judgment | reliable-ai-systems
canonical_url: ""
# Exclusion: status != published OR visibility != public ⇒ keep draft: true.
# Publish only when status: published AND visibility: public AND draft: false.
draft: true
---

## BLUF

<!-- PLACEHOLDER: problem, role, intervention, result in 60–90 words. Do not invent facts. -->

## Who was doing the work

<!-- PLACEHOLDER: specific expert users and their context. -->

## What was already possible

<!-- PLACEHOLDER: existing tools, local workarounds, and user capability. -->

## The product boundary

<!-- PLACEHOLDER: what became common and reliable; what remained expert-controlled. -->

## The hard choice

<!-- PLACEHOLDER: options considered, constraint that mattered, and why one path won. -->

## Athan's ownership

<!-- PLACEHOLDER: what he directly owned, what he influenced, and who carried adjacent responsibilities. -->

## What changed

<!-- PLACEHOLDER: verified adoption, cycle-time, quality, or workflow evidence, plus limitations. -->

## What he would change now

<!-- PLACEHOLDER: one candid reflection. Do not invent metrics or employer-confidential detail. -->
