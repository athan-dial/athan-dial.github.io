---
title: "Autonomous agents need a foreman"
type: note
date: 2026-04-06
summary: "I learned the hard way that one-shot multi-phase Claude Code returns fast code and expensive cleanup; discuss → plan → execute → verify with atomic commits is what made autonomy survivable for me."
status: published
visibility: public
themes: [reliable-ai-systems, expert-workflows]
source_url: https://athan-dial.github.io/agency/dispatches/autonomous-agents-need-a-foreman/
draft: false
---
The first time I ran a multi-phase project in Claude Code, I pasted the whole scope once and let it run. A lot of code came back fast. Roughly a third of it was wrong in ways that cost more to unwind than a clean restart—no phased plan, no verification between steps, floor three while floor one was still wet concrete.

## What I changed

I started treating every non-trivial project as a phased pipeline. Each phase gets:

- A **discussion step** where I answer questions about the approach and surface assumptions before any code is written
- A **plan** with discrete tasks, dependencies, and acceptance criteria
- An **execution step** that commits atomically — one task, one commit, verifiable before moving on
- A **verification gate** where I check the built thing against the plan before advancing

This is what GSD (`/gsd:new-project`) does: it walks through requirements, builds a roadmap with numbered phases, and then plans and executes each phase with built-in checkpoints. The structure keeps the agent productive while checkpoints keep each phase aimed at the agreed goal.

## The autonomy spectrum

I run three modes depending on the work:

**Guided** — I discuss the phase, review the plan, watch execution, verify manually. For anything where the domain is unfamiliar or the stakes are high.

**Quick** — Claude plans and executes with atomic commits but skips optional review agents. For well-understood changes where I trust the pattern.

**Autonomous** — Claude runs all remaining phases end-to-end, including plan generation and verification. I review the output after. For mechanical work across known patterns — like this site’s content migration.

The jump from guided to autonomous felt risky the first time. What made it work: the verification step catches drift before it compounds, and atomic commits mean I can revert any single task without losing the rest.

## The foreman metaphor

A construction foreman sequences trades, holds inspections before the next floor starts, and surfaces problems early. Bricks still get laid; the foreman keeps order and quality from slipping. That’s the role the orchestration layer plays. The agent does the work; the structure makes the work trustworthy.
