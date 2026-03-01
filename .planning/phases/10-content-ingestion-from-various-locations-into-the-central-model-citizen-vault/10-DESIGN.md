# Phase 10 Redesign: Single-Vault Model Citizen Integration

**Date:** 2026-02-13
**Status:** Approved (brainstorming session)

## Problem

Original Phase 10 assumed a separate `model-citizen-vault` repo with its own Node.js ingestion infrastructure (queue, dedup, normalize). This creates friction — a second vault nobody wants to maintain.

## Solution

Use the existing `2B-new` Obsidian vault as the single workspace. Content flows through natural JD folders, gets tagged `#model-citizen/<section>` when curated, Auto Note Mover routes it to `700 Model Citizen/`, and a sync script pushes to the Quartz repo.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Ingestion (web, Slack, Outlook)                        │
│  → lands in 2B-new/000 System/01 Inbox/                 │
└──────────────────────┬──────────────────────────────────┘
                       │ enrichment (split into pieces)
                       ▼
┌─────────────────────────────────────────────────────────┐
│  2B-new (full vault — messy thinking happens here)      │
│                                                         │
│  600 Resources/     ← curated sources, articles, videos │
│  100 Ideas/         ← seeds, half-formed thoughts       │
│  200 Projects/      ← explorations, designs             │
│  (existing JD folders — content lives where it belongs) │
│                                                         │
│  When ready: add #model-citizen/concept, /writing, etc. │
└──────────────────────┬──────────────────────────────────┘
                       │ Auto Note Mover (detects tags)
                       ▼
┌─────────────────────────────────────────────────────────┐
│  2B-new/700 Model Citizen/                              │
│  ├── concepts/    ← #model-citizen/concept              │
│  ├── writing/     ← #model-citizen/writing              │
│  ├── sources/     ← #model-citizen/source               │
│  ├── explorations/← #model-citizen/exploration          │
│  ├── ideas/       ← #model-citizen/idea                 │
│  └── index.md     ← Quartz landing page                 │
└──────────────────────┬──────────────────────────────────┘
                       │ sync script (rsync + git)
                       ▼
┌─────────────────────────────────────────────────────────┐
│  quartz/content/    (GitHub repo, already exists)       │
│  → Quartz builds → GitHub Pages → /model-citizen        │
└─────────────────────────────────────────────────────────┘
```

## Components

### 1. Vault Structure — `700 Model Citizen/`

New top-level JD category in 2B-new vault with section subfolders mirroring Quartz site navigation.

### 2. Tag-Based Curation

Nested tags `#model-citizen/<section>` serve dual purpose:
- Curation signal (intentional promotion)
- Section routing (Auto Note Mover maps tag → folder)

### 3. Auto Note Mover Config

Rules mapping:
- `#model-citizen/concept` → `700 Model Citizen/concepts/`
- `#model-citizen/writing` → `700 Model Citizen/writing/`
- `#model-citizen/source` → `700 Model Citizen/sources/`
- `#model-citizen/exploration` → `700 Model Citizen/explorations/`
- `#model-citizen/idea` → `700 Model Citizen/ideas/`

### 4. Five Obsidian Templates

**Concept:** title, aliases, tags, related → What It Is / How It Works / Where I've Seen It
**Source:** title, url, source_type, captured_at, tags → Summary / Key Ideas / Quotes
**Writing:** title, date, tags, draft → freeform
**Exploration:** title, tags, status → Premise / Design / Open Questions
**Idea:** title, tags → quick capture

### 5. Ingestion Tools (retargeted)

Web capture, Slack, Outlook connectors — all land in `000 System/01 Inbox/` instead of separate vault. Use existing enrichment pipeline (Phase 7) for processing.

### 6. Sync Script

rsync `700 Model Citizen/` → `quartz/content/`, git commit + push.

## What Gets Eliminated

- Separate `model-citizen-vault` repo
- Node.js queue/dedup/normalize infrastructure
- Workflow-based folder taxonomy (inbox/sources/enriched/publish_queue/published)

## What Gets Preserved

- Quartz repo at `/Users/adial/Documents/GitHub/quartz/`
- Enrichment pipeline from Phase 7
- Web/Slack/Outlook ingestion concept (retargeted)
