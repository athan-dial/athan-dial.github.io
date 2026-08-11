# Voice reference — public-safe

**Last updated:** 2026-08-11  
**Authority:** Derived from Part 4 (Voice corpus) of `.planning/private/CHATGPT-EVIDENCE-RESPONSE.md`. Where this file and the `writing-style` skill disagree, **the corpus wins**. The skill is a prior; the corpus is evidence.

**Verbatim source:** The nine excerpts and the construction table live in `.planning/private/` (gitignored). Drafting agents with local disk access should read that file for the unedited corpus. **Do not paste those excerpts into anything that will be committed.** They are labelled `LIKELY-CONFIDENTIAL` and name programs, tools, vendors, and colleagues.

This file is safe for a public repo. It describes patterns. It does not reproduce confidential prose.

---

## If you only remember three things

1. **Conclusion first, then the ledger.** Lead with the judgment or the short answer. Put the evidence, options, and hedges after — not the other way around. Case-study BLUF and exec updates should read like his compressed causal ledgers, not like a template warming up.

2. **Label uncertainty; do not smear it.** He marks what he knows, what he is guessing, and what would change his mind. "I think" is an epistemic marker, not throat-clearing. When evidence is missing, he says so in the sentence.

3. **Concrete mechanism over brand language.** Name the friction, the option, the cause→effect. Do not stack slogans ("decision evidence", "operating layer" as wallpaper, "compounds" as a verb used for atmosphere). One idea per sentence. Show the real example.

---

## Honest correction: "metric theater"

`"metric theater"` is **`NO RECORD` as a recurring phrase** in the validated work corpus (Part 4 of the evidence response).

It appears in current site copy (About, advisory) and was previously treated as a signature tic. It is a real phrase Athan uses. It is **not load-bearing**. The nine constructions below are. Do not over-index on it when drafting. Prefer the documented constructions and the structural habits.

---

## Nine recurring constructions

Each row: what it is, when he reaches for it, and a **neutral** example in the same shape. Bare fragments that carry no internal detail are quoted as fragments; nothing confidential is reproduced.

| # | Construction | When he reaches for it | Neutral example (same shape) |
|---|---|---|---|
| 1 | **Compact judgment frame** | Opening a multi-part view for a peer or exec so the structure is visible before the detail. | Fragment (safe): `"Here's how I see it:"` then a short ownership map and how current work maps onto it. |
| 2 | **Conclusion before evidence** | Answering a research or decision question when the reader needs the takeaway first. | Fragment (safe): `"Short answer:"` then the verdict; then what exists, what does not, and what still has to be run in-house. |
| 3 | **Uncertainty marked before the view** | Offering a quick take that is provisional, not a settled position. | Fragment (safe): `"Not 100% sure - but here's my knee-jerk reaction:"` then the view. |
| 4 | **Repeated "I think" as epistemic tag** | Separating opinion from fact while still committing to a direction; often paired with a revision condition. | Neutral: `"I think my view will change once we have a sharper plan for X."` / `"I think the issue is simpler than the analysis framing."` |
| 5 | **Options as cause → effect arrows** | Turning product or UX choices into a small causal chain peers can argue with. | Neutral: `"Looser threshold → more results returned"` / `"More options for the threshold → feeling of optionality"`. |
| 6 | **"The whole theme of my … life"** | Stating a durable thesis that outlives the current ticket — a personal operating principle, not a feature pitch. | Neutral shape: `"The whole theme of my [domain] life is that it gets the average user most of the way. They still need a way to finish or refine the result."` |
| 7 | **Dry self-own after technical detail** | Peer Slack after a concrete failure or awkward moment; pressure-release, not brand humor. | Neutral shape: factual failure report first; then one short self-deprecating closer. Do not invent jokes for public essays. |
| 8 | **Compressed causal ledger for execs** | Incident or status heads-up where time is scarce. | Safe skeleton: `"Short version:"` then bullets `Cause → …` / `Impact → …` / `Fix → …` / `Future process-fix → …`. This is the closest model for a case-study BLUF. |
| 9 | **Descriptive vs prescriptive contrast** | Stopping someone from treating an observed pattern as a mandate. | Fragment (safe to quote): `"This is descriptive, not prescriptive."` |

---

## Structural habits (derived from the corpus)

These are observations across the nine excerpts, not a restatement of the table above.

### Where the conclusion sits

In decision and status writing, the **conclusion is early**. He frames ("here's how I see it"), gives the short answer, or drops the causal ledger before expanding. Exploratory threads (e.g. revising an OKR before wordsmithing) are the exception: he withholds polish and walks the framing problem first — then offers a suggestion. Portfolio BLUF should follow the early-conclusion habit, not the exploratory one.

### How he marks uncertainty

He **tags the uncertain clause**, then continues. Patterns: "kinda", "IMO", "Not 100% sure", "I think", "I'm not sure if I'm conflating X and Y", "my opinions will change once…". He does not soften every sentence. When the evidence is firm (what got created in a failed deploy; cause/impact/fix of an incident), he states it flat.

### Hedge relative to commitment

Usually **hedge, then commit** — or commit with an explicit revision condition attached. Example shape: firm product opinion, then "I think my opinions will change once we get more detailed with the planning." He does not bury the view under hedges; he dates the confidence.

### Disagreement with someone else's framing

He **concedes the useful part**, then reframes the problem. Typical moves: agree with the education/analysis impulse; say the last conversation suggests a simpler mechanism; rename the fight (e.g. parity chase vs. completeness perception); propose a UX response instead of an arms race. He does not dunk. He changes the question.

### Exec vs peer compression

- **Exec / heads-up:** "Quick heads-up" → short version → causal bullets → offer to walk through detail. Almost no throat-clearing.
- **Peer / channel:** warmer openers ("Hi folks", wave emoji), numbered options, quoted user observations, explicit tradeoffs.
- **Peer DM (technical):** inventory of what happened and what did not; ask before cleanup; one dry closer.
- **Public announcement:** career news as context; thesis in the middle; forward-looking close. Longer sentences than Slack; still concrete nouns early.

### Lists and arrows

He uses **numbered lists for mutually exclusive or sequenced points**, bullets for inventories, and **arrows for causal linkage** (option → effect; Cause → …). Lists are argument machinery, not decoration. Prefer arrows when the relationship is causal; prefer numbers when order or ranking matters.

### How he closes

Closes are **practical or invitational**, not restated theses: check with you before cleanup; happy to walk through at the spike; feedback welcome; "does this work grammatically?" / is the target feasible? Public writing may end on energy and unlock — still tied to a concrete claim, not a slogan stack.

### Honesty before wordsmithing

When asked to polish a goal or OKR, he **gives the honest assessment first** ("cart before the horse"), interrogates the denominator and feasibility, then helps with wording. Drafting agents should not pretty-print a weak metric; they should surface the framing problem the way he would.

### Maturity without oversell

When sharing a tool or method, he states the premise, what is in the box, and what is deliberately fake or limited (sample corpus, local defaults). He does not pretend the artifact is more mature than it is.

---

## What he does NOT do

Useful negatives from absence across the corpus:

| Avoid | Why |
|---|---|
| Corporate throat-clearing | No "I'm excited to share", "I wanted to take a moment", "as we continue our journey". Peer opens are brief; exec opens are "Quick heads-up". |
| Superlatives and adjective inflation | No "groundbreaking", "best-in-class", "powerful platform". Strength comes from mechanism and measured detail. |
| Tricolons as rhetoric | He lists when the list is operational (cause/impact/fix), not for cadence ("better, faster, stronger"). |
| Rhetorical questions as transitions | Questions in the corpus are diagnostic or clarifying ("is the target still referring to X?", "can you confirm…?"), not "So what does this mean for leaders?" |
| Conclusions that restate the opening | Closings advance (ask, offer, invite, propose wording). They do not echo the lede. |
| Parity-with-vendor as default goal | When the user's complaint looks like "competitor found more", he resists chasing uncontrolled factors and looks for a product response he can own. |
| Publishing targets as results | Separate from voice, but voice-adjacent: he interrogates whether a number is a promise, a capability claim, or a measured outcome before he helps write it. |
| Buzzword clusters | Do not paste portfolio slogans. Even public thesis language should appear once, earned, not as a refrain. |

Also avoid inventing "Athan-isms." If a phrase is not in the nine constructions and not clearly evidenced, do not force it. That includes over-using "metric theater."

---

## Channel calibration

The corpus spans Slack DMs, channel posts, exec updates, and one public post. Drafting tracks write for a **public site**. Map registers as follows:

| Channel in corpus | Register | Use on the site for… |
|---|---|---|
| **Public post** (role announcement) | First person; career fact as frame; one durable thesis; applied-AI outlook; slightly longer sentences; employer named because the post is a job announcement. | Essays and About: closest full-register match. Keep the thesis concrete (workflows, human-in-the-loop, knowledge in a system). Do not inflate into keynote voice. |
| **Exec causal ledger** | Maximum compression; cause → impact → fix → process-fix; offer detail offline. | **Work BLUF and "What changed" openers.** If a section cannot be skimmed in ten seconds, it is not done. |
| **Peer channel** | Warm, structured, options with arrows, user quote or observation, explicit non-goal. | Body of a case study: the hard choice, the reframe, what he would change now. |
| **Peer DM (technical / failure)** | Chronological facts, created vs not created, ask before acting, dry self-own. | Incident / proof notes: mechanism honesty. Drop the emoji density and internal host detail for public prose; keep the candour. |
| **OKR / framing DM** | Honest assessment before wordsmithing; pressure-test denominators and feasibility. | Anywhere a metric appears: say what was measured; if it was a target, call it a target. |

**Portfolio default:** write like the public post for stance and first person, and like the exec ledger for the top of a work piece. Peer-channel texture belongs in the middle, not in the hero.

---

## Reconciliation with the `writing-style` skill

Invoke `writing-style` (and `references/core-voice.md`, `references/public-writing.md`) when drafting. Treat the skill as **how to polish and extend** once the corpus patterns are respected.

| Topic | Skill prior | Corpus evidence | Rule for drafting |
|---|---|---|---|
| Conclusion placement | Preserve "visible thinking"; do not always lead with a formed conclusion. | Work writing usually **leads with the judgment** or short answer. | For work/BLUF/exec-like sections: corpus wins — conclusion first. For cornerstone essays: skill's visible-thinking arc is fine if it still lands a crisp compression. |
| "I think" | Prefer observation ("I noticed") over belief language when possible. | **"I think" is a load-bearing epistemic marker** in the corpus. | Keep "I think" when marking opinion. Do not scrub it into false certainty. |
| Contrast / "not X, but Y" | Avoid manufactured contrarian formulas; keep real corrections. | Authentic contrasts appear ("descriptive, not prescriptive"; directional benchmarks vs decision-grade evidence). | Keep earned distinctions. Do not invent punchy antitheses for LinkedIn energy. |
| Humor | Dry, situational; do not add jokes after drafting. | Self-owns appear in peer Slack after technical honesty. | Public site: rare, deadpan, only if the situation earns it. Never emoji-forward. |
| Public announcement | News is context, not thesis. | Matches: role news opens; thesis is the middle. | Follow both. |
| Aphorisms | Earn the line; do not stack. | Public thesis lines exist; work corpus prefers mechanisms and ledgers. | One earned compression per piece max unless the artifact is the thesis essay itself. |
| "Metric theater" | Not a documented load-bearing tic in the skill's core constructions. | **`NO RECORD` as recurring in work corpus.** | Do not treat as signature. |

**Bottom line:** the skill is right about concrete-first reasoning, epistemic precision, reframes, boundaries, and anti-patterns (throat-clearing, adjective inflation, fake anecdotes). The corpus corrects the skill on **where the conclusion sits in operational writing** and on **which verbal constructions actually recur**.

---

## Drafting checklist (voice only)

Before a draft is "done" on voice:

1. Does the first screenful state the judgment or the short version?
2. Is every number either measured (and labelled as such) or explicitly a target — matching CONTENT-SAFETY-CONTRACT, not voice theatre?
3. Are hedges attached to specific claims, not sprayed?
4. Is there at least one concrete object, option, or cause→effect — not only abstract nouns?
5. Did you avoid "metric theater" as a crutch and avoid slogan piles?
6. Does the close advance (limitation, next change, open question) instead of restating the lede?
7. If you needed a verbatim model, did you read `.planning/private/CHATGPT-EVIDENCE-RESPONSE.md` Part 4 locally — without copying confidential sentences into the repo?

---

## Source labels (for this file)

| Claim in this file | Epistemic | Source |
|---|---|---|
| Nine constructions and their shapes | `MEASURED` | Part 4 construction table + excerpts 1–9 |
| Structural habits above | `INFERRED` | Pattern read across Part 4 excerpts; not a separate labelled table in the source |
| Negative patterns (absences) | `INFERRED` | Absence across the same corpus |
| Channel calibration | `INFERRED` | Audience/format labels on excerpts 1–9 |
| `"metric theater"` not recurring in work corpus | `NO RECORD` (as recurrence) | Part 4 explicit note; also `.planning/EVIDENCE-DECISIONS.md` |
| Public thesis fragment about models vs surrounding systems | `INFERRED` · `PUBLIC` | Excerpt 8 / public post; already summarised in EVIDENCE-DECISIONS |

Nothing in this file is a content draft for `content/`.
