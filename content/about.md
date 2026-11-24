---
title: "About"
date: 2026-01-20
description: "Athan Dial works on AI enablement for expert work. Associate Director, Data Science & Product Management at Montai Therapeutics. PhD in Medical Sciences, and a research record that explains how Athan reasons about evidence."
layout: about
# show_profile_links is deliberately NOT set. This page ends with its own #conversations
# section, which carries the contact links with real context around them. The generic
# two-button row from _default/single.html would repeat them a screen earlier with none.

# ---------------------------------------------------------------------------------------
# Trajectory. Role, company and range only, plus descriptions that are already cleared.
#
# data/experience.json is NOT the source here, on purpose. Its `summary` fields are legacy
# resume material: they claim unhedged ownership of shared systems with no split between
# Athan's contribution and the team's. The Data Research Lead row therefore carries no
# description; the Work section carries the evidence at a grain where ownership and limits
# can be stated properly.
# ---------------------------------------------------------------------------------------
trajectory:
  - role: "Associate Director, Data Science & Product Management"
    company: "Montai Therapeutics"
    range: "2026 – present"
    note: "Data science, product direction, and applied AI for scientific work."
  - role: "Data Research Lead"
    company: "Montai Therapeutics"
    range: "2022 – 2026"
    evidence: "The Work section carries product narratives from this period."
  - role: "Data Scientist"
    company: "Replica Analytics"
    range: "2019 – 2020"
    note: "Clinical data pipelines and privacy-preserving synthetic data for health research."
  - role: "Chief Analytics Officer"
    company: "ArchitecHealth"
    range: "2018 – 2019"
    note: "Analytics strategy for small and mid-size biotech clients."

# ---------------------------------------------------------------------------------------
# Selected research, addressed by DOI so the selection is explicit and cannot drift.
# Every field a reader sees is read from data/publications.json at build time.
# ---------------------------------------------------------------------------------------
selected_research:
  - "10.1210/clinem/dgab261"
  - "10.1016/j.tem.2018.02.010"
  - "10.1096/fj.201700868rrr"

research_note: "The research is where the habits came from: what an adequately powered comparison costs, how often a clean result turns out to be a measurement artifact, and why the method section matters more than a confident conclusion. They still show up in product work, mostly as a reflex about what a number is allowed to claim."

territory_standfirst: "Four questions the work keeps returning to. Fieldnotes exists because each one is easier to think through in writing than in a planning document."
territory:
  - question: "What deserves to be built when building gets cheap?"
    detail: "A convincing first version now costs an afternoon. That moves the hard part upstream, into deciding which problems earn a product at all."
  - question: "Where does expert judgment have to stay?"
    detail: "Some of the work should become reliable and shared. Some of it is the expertise, and encoding it is how a tool starts getting quietly bypassed."
  - question: "How do we know generated work deserves trust?"
    detail: "Verification is the part that decides whether a system gets used twice. It is also the part that gets designed last, if at all."
  - question: "When contribution broadens, who owns what happens next?"
    detail: "More people can produce more candidate work. Ownership of what happens to it usually stays where it was."

conversations_intro: "If you are working through something similar, I would like to compare notes. I am most interested when the first attempt did not go the way you expected. That is the conversation I do not get tired of."
conversations_note: "Talks, panels and guest sessions are welcome, and so is a longer conversation with no agenda attached. Most of my time goes to the day job. This is not a business and there is nothing to buy."
---

I work on AI enablement for expert work: getting people who are very good at something hard to use
AI without losing the part that makes them good. Right now that means data science and product at
Montai Therapeutics, where the people using what we build know considerably more about their problem
than the software does.

That constraint is the interesting part. A tool for an expert has to fit a practice that already
works, show enough of its reasoning to be checked, and leave room for what the person knows and the
system does not. Get that boundary wrong in either direction and the tool gets used once, politely,
and then routed around.

## Why the science matters here

My PhD measured skeletal muscle function and physiology in people with type 1 diabetes. It is a
setting where the effect of interest can be small, the measurement noisy, and the honest answer
sometimes that the study cannot tell you. That training is the habit I use most. Treat an idea as a
claim. Ask what would change it. Expect a clean result to be an artifact until it survives a harder
look. None of that is specific to biology. It applies wherever someone has to decide whether a number,
a model or a demo is allowed to say what it appears to say.

## How the work tends to move

**Tighten the question before adding the feature.** One case under [Work](/work/) starts with an
expert saying a faster search tool still feels incomplete. The literal response would have been to
return more results. The useful question was whether the complaint was about relevance, coverage,
confidence or control. One comparison showed there was a problem. It could not show which one.

**Keep expert judgment visible.** The recurring design question is which part of the work should
become consistent and shared, and which part is the expertise itself. Retrieval, ranking and proposal
can become systematic. Adjudication still needs the person who understands the domain, and the
boundary works better when the product shows it than when it hides in a default setting.

**Let verification change the recommendation.** [An all-false column is a legal column](/notes/an-all-false-column-is-a-legal-column/)
describes individually valid steps producing a wrong answer. The check that caught it needed domain
knowledge, which is the kind of knowledge a verification layer should make explicit.

**Name what was not measured.** A shipped tool with no adoption instrumentation is not a successful
product because the implementation was fast. A retrospective result is not a production rule because it
survived one analysis. The Work pages name those gaps on purpose, so the edge of the evidence is visible
before the story gets smoother than the record deserves.

I also run my own agent-enabled work through a system I have drawn out in seven views, including where
a person has to decide and what gets recorded for next time.

{{< atlas-link >}}
