---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
type: essay
date: {{ .Date }}
tier: practice # cornerstone | practice
summary: ""
status: draft # draft | published
visibility: private # private | public
themes: [] # expert-workflows | product-judgment | reliable-ai-systems
canonical_url: ""
# Exclusion: status != published OR visibility != public ⇒ keep draft: true.
# Publish only when status: published AND visibility: public AND draft: false.
# Reading time is computed by the template, not stored in frontmatter.
draft: true
---

<!-- PLACEHOLDER: essay body. Do not invent factual claims about Athan's work. -->
