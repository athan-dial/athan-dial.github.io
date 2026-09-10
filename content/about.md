---
title: "About"
date: 2026-01-20
description: "Athan Dial. Associate Director, Data Science & Product Management at Montai Therapeutics. PhD in Medical Sciences, and a research record that explains how he reasons about evidence."
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

research_note: "The research is not a previous life that stopped mattering. It is where the habits came from: what an adequately powered comparison costs, how often a clean result can be a measurement artifact, and why a method section matters more than a confident conclusion. Those habits still show up in product work, mostly as a reflex about what a number is allowed to claim."

territory_standfirst: "Four questions the work keeps returning to. They are the reason Fieldnotes exists: each one is easier to think through in writing than in a planning document."
territory:
  - question: "What deserves to be built when building gets cheap?"
    detail: "A convincing first version now costs an afternoon. That moves the hard part upstream, into deciding which problems earn a product at all."
  - question: "Where does expert judgment have to stay?"
    detail: "Some of the work should become reliable and shared. Some of it is the expertise, and encoding it is how a tool starts getting quietly bypassed."
  - question: "How do we know generated work deserves trust?"
    detail: "Verification is the part that decides whether a system gets used twice. It is also the part that gets designed last, if at all."
  - question: "When contribution broadens, who owns what happens next?"
    detail: "More people can produce more candidate work. Ownership of what happens to it usually stays where it was."

conversations_intro: "I am interested in how other people are working through these problems, particularly when the first attempt did not go the way they expected. That is the conversation I do not get tired of."
conversations_note: "Talks, panels, and guest sessions are welcome, and so is a longer conversation with no agenda attached. Most of my time goes to the day job; this is not a business and there is nothing to buy."
---

I build AI and data products for people whose work depends on judgment. Right now that
means data science and product at Montai Therapeutics, where the people using what we
build know considerably more about their problem than the software does.

That constraint is the interesting part. A tool for an expert has to fit a practice that
already works, expose enough of its reasoning to be checked, and leave room for what the
person knows and the system does not. Get that boundary wrong in either direction and the
result is the same: the tool gets used once, politely, and then routed around.

The route here started in medical research. My PhD measured skeletal muscle function and
physiology in people with type 1 diabetes, a setting where the effect of interest can be
small, the measurement noisy, and the honest answer sometimes that the study cannot tell
you. The same habit follows the product work now: treat the idea as a claim, and keep the
question of what would change the claim attached to it.

## How the work tends to move

**Tighten the question before adding the feature.** One case under [Work](/work/) starts
with an expert saying a faster search tool still feels incomplete. The literal response
would have been to return more results. The useful question was whether the complaint was
actually about relevance, coverage, confidence, or control. One comparison established
that there was a problem. It could not establish which problem it was.

**Keep expert judgment visible.** The recurring design question is which part of the work
should become consistent and shared, and which part is the expertise itself. Retrieval,
ranking, and proposal can become systematic without pretending that adjudication has
stopped requiring the person who understands the domain. The boundary works better when
it is visible in the product instead of buried in a default setting.

**Let verification change the recommendation.** A recent retrospective analysis started
with a useful-looking reliability signal. A stricter validation pass treated related
observations as related, controlled the existing score more carefully, and revisited how
candidates entered the observed set. One apparent effect disappeared. The recommendation
got smaller with it. That is what a verification layer should be allowed to do.

**Name what was not measured.** A shipped tool without adoption instrumentation does not
become a successful product because the implementation was fast. A retrospective result
does not become a production rule because it survives one analysis. The Work pages name
those gaps on purpose. The boundary of the evidence should be visible before the story
gets smoother than the record deserves.
