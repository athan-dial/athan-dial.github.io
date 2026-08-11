---
title: "Skills encode what you learned the hard way"
type: note
date: 2026-04-06
summary: "Every skill I write holds the constraint I burned time discovering — the CLI flag that silently fails, the join pattern that actually works, the config the docs forgot to mention."
status: published
visibility: public
themes: [expert-workflows]
source_url: https://athan-dial.github.io/agency/dispatches/skills-encode-what-you-learned-the-hard-way/
draft: false
---
Thursday I finally got the join right—the one the docs gloss over. Monday Claude suggested the wrong table again because the winning pattern lived only in last week’s transcript. I was paying for the same debugging tax every time the calendar turned.

A **skill** is where that tax stops: a `SKILL.md` with a trigger, the commands that actually work, failure modes with consequences named, and a verification sniff test. Load it once when the situation matches; the session starts from the baseline I already bought.

## What makes a strong skill

Four obligations:

- **A real trigger** — the exact situation that earns loading this skill, not “sometimes useful”
- **What to actually run** — commands, endpoints, config. Secrets excluded, everything else explicit
- **What I’ve burned time on** — the failure mode you’ll hit if you skip a step. Name the consequence, not only the slip
- **A verification pass** — row count check, version sniff test, a known-good output to compare against

A strong skill reads like a hallway aside: *use curl for this API; the CLI is broken* — one sentence, one day saved.

## Why skills compound

Every session that starts from the right baseline compounds. By the third run I’ve saved the setup time and the debugging I’d spend re-learning the edge case.

Skills also make delegation possible. When I hand off a task to a subagent or a colleague’s Claude session, the skill carries the institutional knowledge with it. The receiver doesn’t need my debugging history; they need the distilled result of it.

## The maintenance cost is real

A skill that falls out of sync with the tool it describes is worse than no skill at all — it gives false confidence. When the procedure changes, both the skill and any playbook that references it need to move. I treat skill maintenance as ops, not garnish. A broken skill is an active hazard.

## Where I’d start

I pick the thing I’ve explained to Claude three times this week. I write it down as a SKILL.md with a trigger, the procedure, and the failure mode I keep hitting—that’s the first skill. Step-by-step:
[Build your first skill](https://athan-dial.github.io/agency/playbooks/build-your-first-skill/).
