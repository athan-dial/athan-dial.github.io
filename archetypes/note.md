---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
type: note
date: {{ .Date }}
summary: ""
status: draft # draft | published
visibility: private # private | public
themes: [] # expert-workflows | product-judgment | reliable-ai-systems
source_url: "" # set when migrating from the Agency site
# Exclusion: status != published OR visibility != public ⇒ keep draft: true.
# Publish only when status: published AND visibility: public AND draft: false.
draft: true
---

<!-- PLACEHOLDER: field note body. Do not invent factual claims about Athan's work. -->
