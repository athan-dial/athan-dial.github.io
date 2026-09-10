---
title: "About"
date: 2026-01-20
description: "Athan Dial. Associate Director, Data Science & Product Management at Montai Therapeutics. PhD in Medical Sciences, and a research record that explains how he reasons about evidence."
layout: about
# show_profile_links is deliberately NOT set. This page ends with its own #conversations
# section, which carries the contact links with real context around them. The generic
# two-button row from _default/single.html would repeat them a screen earlier with none.

# ---------------------------------------------------------------------------------------
# Trajectory. Role, company and range only, plus the four descriptions that are ALREADY
# published on this page and cleared.
#
# data/experience.json is NOT the source here, on purpose. Its `summary` fields are legacy
# resume material: they claim unhedged ownership of shared systems with no split between
# Athan's contribution and the team's, which is exactly why the Data Research Lead
# description was unpublished on 2026-08-14 (CLAUDE.md hard constraint 3). DESIGN.md bans
# them from the homepage for the same reason; the boundary is about the claims, not about
# which page renders them, so it holds here too.
#
# The Data Research Lead row therefore carries no description. That is not an oversight and
# not a gap to fill — the account of that work lives in the two Work narratives, which do
# separate what Athan owned from what engineering and the scientific users owned. The
# `evidence` key below points a reader there instead of restating the claim.
# ---------------------------------------------------------------------------------------
trajectory:
  - role: "Associate Director, Data Science & Product Management"
    company: "Montai Therapeutics"
    range: "2026 – present"
    note: "Data science, product direction, and applied AI for scientific work."
  - role: "Data Research Lead"
    company: "Montai Therapeutics"
    range: "2022 – 2026"
    evidence: "Both published Work narratives come from this period."
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
# Every field a reader sees is read from data/publications.json at build time — this list
# only chooses which three of the fourteen appear. All three are first-author and
# peer-reviewed; the aggregate line beside them is computed from the same file.
# ---------------------------------------------------------------------------------------
selected_research:
  - "10.1210/clinem/dgab261"
  - "10.1016/j.tem.2018.02.010"
  - "10.1096/fj.201700868rrr"

research_note: "The research is not a previous life that stopped mattering. It is where I learned what an adequately powered comparison costs, how often a clean result is a measurement artifact, and why a method section is the only part of a paper you can actually check. I use that on product work now, mostly as a reflex about what a number is allowed to claim."

# Current territory. The four questions match the homepage's operating-territory chapter on
# purpose — same recurring problems, stated with more specificity for a reader who has
# scrolled this far.
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

I came to this from medical research. My PhD measured skeletal muscle function and
physiology in people with type 1 diabetes, which is a field where the effect you are
looking for is small, the measurement is noisy, and the honest answer is often that the
study cannot tell you. I still approach a new idea the same way — as an experiment, with
the question of what would change my mind attached to it.

## How I work

**I spend longer on the problem than feels comfortable.** The two narratives under
[Work](/work/) both turn on a reframe rather than on an implementation. In one, the
primary user turned out not to be the person who had asked for the tool. In the other, an
expert's complaint about a competitor was a completeness problem wearing the costume of a
relevance problem. Neither of those is discoverable from a requirements document.

**I try to keep expert judgment where it belongs.** The recurring design question is which
part of the work should become consistent and shared, and which part is the expertise
itself. My default is to make the machine retrieve, rank, and propose, and to leave the
adjudication with the person who can be held responsible for it — and then to make the
boundary visible in the interface rather than implicit in a default setting.

**I treat verification as part of the product.** Not as a review step after the build. If
nobody can check what a system produced, its output is a suggestion with good posture.
This is also where I am most willing to argue: I think a number that cannot be defended is
worse than no number, and I would rather ship a range than a figure that came out of a
requirements document.

**I say what was not measured.** Both published cases have a paragraph naming what the
record does not support — adoption in one, decision quality in the other. I would rather a
reader see the gap than find it later. The absence of instrumentation in the first case is
the finding I took most seriously, and it changed how I scope work now.
