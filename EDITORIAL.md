# Editorial authority

The canonical guide for everything a reader of this site can read: page copy, titles, summaries,
metadata, captions, diagram labels and the text a script generates. If a template, data file or
older planning document disagrees with this file about wording or positioning, this file wins.

It sits beside three other authorities and does not replace them:

| File | Governs |
|---|---|
| `EDITORIAL.md` (this file) | What the site says, to whom, in what voice, and how far a claim may go |
| `PRODUCT.md` | Who the readers are and what each destination is for |
| `DESIGN.md` | How it looks and behaves |
| `DIAGRAMS.md` | How an idea is drawn |

`CLAUDE.md` hard constraints (no PII, employer safety, content authenticity, no internal material)
still bind every sentence written under this guide. Nothing here relaxes them.

Decisions below were approved by the owner on 2026-11-24. Change them only on the owner's say-so,
and update this file in the same commit as the copy that depends on it.

## 1. Positioning

**Territory: AI enablement for expert work.** How people who are good at something difficult can use
AI without giving up the part that makes them good: which problems deserve a tool, where judgment has
to stay with a person, and how anyone checks what a machine produced.

**Headline, unchanged:** "I build AI and data products for people whose work depends on judgment."
It lives in `data/profile.toml`; `scripts/verify-fieldnotes-home.sh` asserts it. The supporting copy
carries the new emphasis; the headline does not move.

**Readers.** Professional peers and intellectually curious practitioners. People who build, lead or
study this kind of work and would like a useful idea, a method to borrow or an honest account of an
experiment. Hiring leaders are welcome and are served by being able to classify the work quickly, not
by being addressed. There is no sales audience.

**Heritage.** The scientific training is a differentiating foundation, and it is not a life-sciences
credential. Its relevance is the habits: treat an idea as a claim, ask what an adequately powered
comparison costs, expect a clean result to be an artifact until shown otherwise, and keep the method
section ahead of the confident conclusion. Those habits apply to any expert domain. Say that, and
show it with an example, rather than listing degrees.

**Career narrative.** One evolving practice that has passed through science, data science, product
leadership and AI enablement. The titles changed; the question underneath is close to the same one.
Never frame it as a pivot or a ladder. Lead with the practice, then let the roles show where it
happened.

## 2. Voice

Conversational, intellectually curious, occasionally dry. The voice of a colleague explaining
something at a whiteboard who would rather be accurate than impressive.

Do:

- Lead with the point, then the evidence. Mark what is known, what is a guess and what would change
  the view ("I think", "I did not check", "the record does not show").
- Use concrete nouns and one real example in place of an abstraction. Name the friction, the option and the
  consequence.
- Let a dry aside land once, after something concrete. Humour is a pressure release, never a brand.
- Write short sentences with ordinary words. Use a technical term when it is exact, and define it
  the first time.
- Say "I" for what the author did, "we" only for what a team did, and keep the two apart.

Do not:

- Use symmetrical rhetoric: "not X but Y", "less X, more Y", "X changes, Y stays", rule-of-three
  slogans, or paired clauses built for rhythm. State the claim once, plainly.
- Use brand and consultancy jargon: *leverage, unlock, empower, seamless, robust, holistic,
  transformative, best-in-class, thought leader, journey, ecosystem, stakeholders* (as filler),
  *at scale* (as decoration), *operating layer* or *decision evidence* as wallpaper.
- Inflate. No impact claim, number, adoption claim or ownership claim that a source in hand does not
  support. No "led", "built" or "delivered" where the evidence says "contributed to".
- Open with an announcement ("In today's fast-moving world") or close with a summary of what was just
  said.
- Use em dashes as punctuation habit. Prefer a full stop or a comma.

`scripts/verify-editorial.sh` checks the mechanical part of this list. The rest needs a reader.

## 3. Claims

Every factual sentence is one of four kinds. Write so the reader can tell which.

| Kind | How it reads | Allowed support |
|---|---|---|
| Observed | States it flat | A source the owner can point to |
| Reported | Names whose account it is | The account, with its limits |
| Proposed | "I think", "the idea is", "would" | The reasoning, not a result |
| Not measured | Says so in the sentence | Nothing: the gap is the content |

Rules that follow from it:

- Ownership is split on the page: what I owned, what the team owned, what the record does not support.
- A role, title, date or employer is public only if it is in `data/profile.toml`, `data/experience.json` or
  the About trajectory. **The current role has not been re-verified since the 2026-09 profile
  reconciliation. Before About is released, the owner confirms title, organisation and dates and
  removes this sentence.**
- No consultancy. Do not imply a business, a service, pricing, a deliverable or availability for hire. Conversations
  with peers are welcome and carry no offer (CLAUDE.md hard constraint 2).
- Published essays keep their text and URLs. Edit one only with separate owner approval and a recorded
  reason. Contextual links added around an essay are not edits to it.
- A draft case becomes public only when the evidence classification, employer review and owner approval
  are all recorded. Until then it stays out of the build.

## 4. What each destination is for

Home, Work, Fieldnotes, Systems Atlas and About are the primary navigation. Each does one job the
others do not. A sentence that could sit on two pages belongs on the page whose job it serves, and is
linked from the other.

| Destination | Reader's question | Job | Does not do |
|---|---|---|---|
| **Home** | Who is this, and is it worth my next ten minutes? | One current idea, the work behind it, the notebook, the movement of a career, the questions that persist | Pitch, list credentials, repeat About |
| **Work** | What has this person actually decided, and how do they know? | Cases and systems written as decisions with ownership and limits. Features **The Agentic Operating System** | Show impact the record cannot support |
| **Fieldnotes** | What is this person thinking about? | Essays and field notes: arguments, methods, experiments | Serve as a feed or a résumé |
| **Systems Atlas** | What are other people building, and what does this person make of it? | A curated research notebook: selection and judgment about outside software, each entry saying what it is, what I make of it and what I did not check | Endorse, rank or claim coverage. It is not my work |
| **About** | How do I place this person? | The practice first, then heritage, trajectory, selected evidence, research and an invitation to talk | Replace a résumé or advertise a service |

### The Agentic Operating System

Featured under Work and linked prominently from Home. Present it as **a personal operating system for
agent-enabled work that demonstrates reusable principles**: judgment stays with a person, capability
is reused rather than rebuilt, execution is governed, and learning is recorded. Give it progressive
depth: a one-minute overview, then views that go as deep as a reader cares to go. It is not a product, a
company system or evidence of an enterprise deployment, and it says so. Public text on it is curated and
generalised; source traceability stays outside the repository.

### The Systems Atlas

A research notebook, not a directory. The value is the selection and the judgment, so every
entry keeps its "what I make of it" and "what I did not check". Never present a count as coverage or
an entry as an endorsement. The record schema, provenance gate and image-rights review in
`atlas/` are unchanged and outrank any copy preference.

## 5. Cases

Develop a historical draft case only where three things hold: the evidence exists in a form the owner
can point to, confidentiality has been cleared in writing, and the prose can state ownership and limits
without padding. Where any of the three is missing, the case stays draft and its blocker is recorded in
the review notes, not guessed around. The withheld absent-user narrative stays withheld; its former
route redirects to Work.

## 6. Conversations

The invitation is to peers who are working on something similar, especially when the first attempt
did not go as planned. Talks, panels and guest sessions are welcome. State that most of the time goes
to the day job and that nothing is for sale.

## 7. Review

Before a copy change merges: read it against section 2 aloud; trace each factual sentence to a kind
in section 3; run `scripts/verify-editorial.sh`; have one cold reader (someone outside the field) say
what the page is for in a sentence. The cold read is a human step. The script does not replace it.
