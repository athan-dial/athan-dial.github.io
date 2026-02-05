---
stepsCompleted: [1, 2, 3, 4, 5, 6]
workflow_complete: true
inputDocuments:
  - docs/context/1-portfolio-site-project-proposal.md
  - docs/context/2-brand-profile.md
  - docs/context/3-voice-and-tone.md
  - docs/context/4-case-study-playbook.md
  - docs/context/5-proof-points.md
date: 2026-01-09
author: Athan
---

# Product Brief: athan-dial.github.io

## Executive Summary

The athan-dial.github.io portfolio solves a critical trust gap: senior readers need to see product judgment and execution leadership, not just technical activity. This site functions as an executive brief that makes three signals instantly clear: (1) ability to turn ambiguous, high-stakes problems into concrete decision loops with metrics, guardrails, and tradeoffs; (2) cross-functional leadership that ships outcomes, not just analysis; (3) communication that enables action, not just admiration.

Target users—hiring managers, executives, and cross-functional partners—can accurately assess fit within 90 seconds through scannable, decision-forward case studies grounded in defensible evidence. Success means they can confidently answer "What did you own?", "Why that approach?", and "What changed?" without requiring a meeting.

This approach treats the portfolio as a product surface, not a scrapbook, presenting work the way senior teams consume information: structured, evidence-based, and optimized for rapid decision-making.

---

## Core Vision

### Problem Statement

Senior readers evaluating data science portfolios face a fundamental trust gap: most portfolios showcase activity and technical depth, but fail to demonstrate product judgment, decision-making rigor, and execution leadership. Hiring managers for Product, Data, Platform, and Applied ML roles need to quickly assess whether a candidate can:

- Turn ambiguous, high-stakes problems into concrete decision loops (metrics, guardrails, tradeoffs)
- Lead cross-functionally and ship measurable outcomes, not just analyze
- Explain the "why" in ways that enable others to act, not just admire the work

Current portfolio solutions fall short because they:
- Emphasize technical complexity over decision clarity
- Show what was built, not why it was built or what changed
- Require deep reading to extract signal, wasting senior readers' limited time
- Lack defensible evidence (missing metrics, unclear ownership, vague outcomes)

### Problem Impact

When portfolios fail to signal product judgment and execution leadership:

- **Hiring managers** waste time in initial screens trying to assess fit from technical artifacts alone
- **Executives** can't quickly evaluate impact, risk posture, and leverage without multiple conversations
- **Cross-functional partners** struggle to understand decision rights, clarity, and execution dependability
- **Candidates** miss opportunities because their work is misunderstood or undervalued

The cost is misalignment: strong candidates appear as "just another data scientist" while portfolios that look impressive may lack the judgment and leadership skills required for senior roles.

### Why Existing Solutions Fall Short

Traditional portfolio approaches prioritize different signals:

- **Technical portfolios** showcase code, models, and algorithms but bury decision logic and business impact
- **Resume-style sites** compress work into bullet points, losing the narrative of problem → tradeoff → outcome
- **Blog-style portfolios** emphasize storytelling but lack the structured, scannable format senior readers need
- **Case study sites** often focus on client outcomes without showing personal ownership, decision-making, and measurable impact

None of these formats are optimized for the 90-second executive scan that determines whether a candidate advances to deeper evaluation.

### Proposed Solution

A portfolio website built on Hugo + GitHub Pages that functions as an executive brief, structured for rapid signal extraction:

**Core Structure:**
- Homepage that communicates positioning within 10 seconds (headline + proof tiles + featured work)
- Case study index with gallery/grid browsing for fast scanning and selection
- Deep-dive case studies following a mandatory PM-forward structure: problem → metrics → tradeoffs → execution → outcome
- Scannable resume page optimized for executive summary consumption

**Key Features:**
- Every case study includes: user/customer, problem statement, north star + guardrails, constraints, options considered + tradeoff, and measured outcome
- Defensible evidence: numbers when possible, ranges when needed, clear redaction where required
- Visual consistency: clean, editorial, low ornament—no stock-photo vibe
- Performance optimized: fast loading, compressed images, responsive layout

**Content Strategy:**
- Three flagship case studies demonstrating the three core signals
- Consistent framing that makes PM judgment unmistakable
- Templates and playbooks enabling repeatable addition of new work without redesign

### Key Differentiators

**1. Decision-Forward Structure**
Unlike technical portfolios that bury decisions in implementation details, this site leads with problem framing, tradeoffs, and outcomes. Every case study answers "What did you own?", "Why that approach?", and "What changed?" upfront.

**2. Executive Brief Format**
Optimized for the 90-second scan that senior readers actually perform. Scannable headers, proof tiles, and structured summaries enable rapid assessment without deep reading.

**3. Defensible Evidence**
Every claim ties to metrics, constraints, and outcomes. Numbers when possible, ranges when needed, clear redaction where required. No vague bragging—only verbs that imply ownership: defined, drove, shipped, measured.

**4. Product Surface, Not Scrapbook**
Treats the portfolio as a product with clear information architecture, consistent templates, and repeatable systems. This approach forces sharper narrative that's reusable for interviews and leadership conversations.

**5. PM Signal Unavoidable**
The mandatory case study structure ensures metrics, tradeoffs, stakeholder alignment, and roadmap logic appear on every flagship case study. The PM story can't get buried under technical details.

**Unfair Advantage:**
The combination of structured PM-forward case studies, executive brief format, and defensible evidence creates a portfolio that speaks the language senior readers actually use: decisions, metrics, tradeoffs, and outcomes. This is hard for competitors to copy because it requires genuine product judgment and execution leadership—not just technical skills.

---

## Target Users

### Primary Users

#### The Hiring Manager Who Actually Owns Outcomes

**Who They Are:**
- **Title range:** Director, Senior Director, Head of Product/Data/Platform, sometimes VP
- **Function:** Product, Data Science, Applied ML, Platform, or hybrid orgs where lines are blurry
- **Context:** They're accountable for delivery, not just resourcing. They've been burned before by candidates with strong resumes and smart interviews but weak judgment under real pressure.

**Their Day, Realistically:**
Their calendar is chaos with a veneer of control:
- Morning: leadership meetings, roadmap fights, budget tradeoffs
- Midday: unblock teams, review specs, make calls with imperfect info
- Late afternoon: candidate reviews squeezed between real work
- Evening: thinking about the one decision they made today that could quietly ruin next quarter

**Where the Portfolio Fits:**
Between meetings. On a laptop. Half-attentive. Time-boxed to under two minutes unless something clicks. This portfolio is either a fast filter that earns deeper attention, or another tab they close without guilt. There is no middle ground.

**What They're Trying to Accomplish (and Why It's Hard):**
They are not trying to hire "a data scientist." They are trying to hire someone who can:
- See the real problem when everyone else is arguing symptoms
- Translate messy organizational goals into concrete decisions
- Interrogate data without worshipping it
- Make calls, ship, and own the consequences

What's hard right now:
- Everyone claims ownership; few can prove it
- Everyone says "impact"; few can show decision logic
- Everyone knows tools; few know when not to use them

They are scanning for **judgment density**, not skill breadth.

**Their Typical Evaluation Process:**
1. Resume skim (credentials, scope, trajectory)
2. Portfolio or case study scan (if available)
3. Interview loop optimized to answer one question: "Can I trust this person with ambiguity?"

Most candidates fail at step 2 by listing outputs instead of decisions, describing collaboration without ownership, or narrating process without stakes. The portfolio either arms the hiring manager with conviction before interviews, or forces them to do more work later.

**The Judgment Test (Unspoken but Ruthless):**
This is the mental checklist running silently:
- Did they frame the right problem?
- Did they define success in business terms, not vanity metrics?
- Did they show tradeoffs, not just outcomes?
- Do they understand second-order effects?
- Can they explain why a reasonable alternative was rejected?

When they say "This person has product judgment," they mean: "This person would reduce my decision load." When they say "Just another data scientist," they mean: "Smart, but I'd still have to think for them."

**Key Variations Within the Primary Persona:**

**Product vs Data Hiring Manager:**
- **Product-side HM:** Bias toward strategy, tradeoffs, user impact. Skepticism: "Can this person go beyond analysis?" Signal they crave: decision ownership under ambiguity.
- **Data/ML-side HM:** Bias toward rigor, scalability, correctness. Skepticism: "Is this just storytelling?" Signal they crave: analytical depth in service of decisions.

The portfolio bridges them by anchoring analysis inside decisions, not adjacent to them.

**IC vs Staff+/Principal Hiring:**
- **IC Hiring:** Looking for execution reliability. Wants clarity, follow-through, scoped ownership.
- **Staff+/Principal Hiring:** Looking for leverage. Wants to see problem selection, influence without authority, systems thinking, organizational impact over time.

The structure is explicitly senior because it answers: "What did you decide, and what changed because of it?" That's staff+ language.

**Startup vs Enterprise:**
- **Startup:** Wants speed, scrappiness, end-to-end ownership. Signal: "Can this person ship without permission?"
- **Enterprise:** Wants navigation, influence, risk management. Signal: "Can this person make progress inside constraints?"

The portfolio works for both by emphasizing decision context, not heroics.

**Why This Persona Gets the Most Value:**
This hiring manager has the authority to act, recognizes judgment when they see it, and is tired of guessing. For them, your portfolio is not content—it's decision support. If we design for this person first, every secondary user benefits.

### Secondary Users

#### Executives and Skip-Level Reviewers

**Who They Are:**
- **Titles:** VP, SVP, GM, sometimes C-suite
- **Involvement:** Late-stage interview loop, hiring committee, final yes/no
- **Time:** Brutally limited
- **Patience:** Microscopic

They're not asking "Can this person do the work?" They're asking "Is this a good bet?"

**How They Interact Differently:**
Executives don't read linearly. They triangulate:
- They skim the homepage to answer: "Why is this person senior?"
- They open one case study, not three
- They jump straight to: problem framing, outcomes, scope of influence

If the portfolio feels tactical, they're done. If it feels like thinking, they lean in.

**Signals They Prioritize (Beyond the Hiring Manager):**
Executives care less about tools and more about:
- **Problem selection:** Did this person work on the right things?
- **Value creation:** Did outcomes move the org, not just a metric?
- **Judgment under constraint:** Did they navigate tradeoffs responsibly?
- **Narrative coherence:** Can they explain complexity without drowning in it?

What makes them say "this person thinks strategically":
- Clear articulation of second-order effects
- Comfort with irreversible decisions
- Evidence of shaping direction, not just executing it
- Calm confidence without defensiveness

No bravado. No buzzwords. Just clarity.

**When They See the Portfolio:**
Most often after initial interviews, sometimes between rounds as prep, occasionally before meeting you via internal share. In all cases, the portfolio functions as a confirmation device, not discovery. They're checking for red flags and upside.

#### Cross-Functional Partners

**Who They Are:**
- Engineering leads
- Senior scientists
- Ops, Commercial, or GTM partners
- Sometimes peer-level candidates interviewing you back

These are future collaborators deciding one thing: "Do I want to work with this person?" They are not judging seniority alone. They are judging working style.

**How They Evaluate You Differently:**
They are asking:
- Do you understand my constraints?
- Do you respect expertise outside your lane?
- Can you translate between worlds without condescension?
- Will working with you make my job easier or harder?

They look for:
- Clear decision boundaries
- Explicit ownership
- Thoughtful collaboration (not "we did X" fog)
- Evidence you can carry ideas from abstraction to production

This group values someone who can reason abstractly, interrogate data deeply, map decisions cleanly, and actually ship. That's rare. And magnetic.

**Their Journey:**
They usually encounter the portfolio via internal referrals, interview loops, or "You should look at this candidate's site" Slack messages. They read more deeply than execs, but less defensively than hiring managers. If they like what they see, they show up to interviews already aligned.

### User Journey

#### Primary Persona: The Hiring Manager Journey

**1. Discovery**
Common paths:
- LinkedIn application click
- Resume forwarded internally
- Referral email with "worth a look"
- Calendar prep link before interview

The intent is skeptical but open.

**2. First 10 Seconds (Homepage)**
Their internal monologue:
- "What kind of candidate is this?"
- "Is this senior or just polished?"
- "Can I trust their judgment?"

What must land immediately:
- Clear positioning: decision-owner, not executor
- Evidence density, not fluff
- Signal that this respects their time

If they feel sold to, they bounce. If they feel understood, they stay.

**3. Case Study Selection**
They don't pick randomly. They choose based on:
- Problem relevance to their org
- Scope that matches the role
- Signals of ambiguity or complexity

Titles and subtitles matter more than visuals here.

**4. The 90-Second Scan**
This is the crucible. They're scanning for:
- Problem clarity
- Success definition
- Decision logic
- Tradeoffs acknowledged
- Outcome honesty

They are not reading prose. They are stress-testing thinking. If it holds, they slow down.

**5. Decision Moment**
The "yes" happens when they think: "I don't need to test basics with this person." They move from evaluation → curiosity, skepticism → engagement.

A "pass" happens fast when ownership is vague, impact is inflated, or decisions are implied, not owned.

**6. Post-Portfolio Impact**
This is the real win. The interview changes from "Tell me what you did" to:
- "Walk me through how you think"
- "How would you approach our problem?"
- "What would you do differently now?"

The portfolio compresses trust-building and elevates the conversation. That's leverage.

**Big Picture:**
- Hiring managers use the portfolio to reduce uncertainty
- Executives use it to assess strategic upside
- Cross-functional partners use it to predict collaboration quality

One artifact. Three lenses. Each sees what they care about most.

---

## MVP Scope

### MVP North Star (Non-Negotiable)

The MVP succeeds if a hiring manager can say:

**"I trust this person's judgment and want to talk to them."**

Nothing else matters yet. Not polish. Not clever interactions. Not edge-case users.

### Core Problem and Solution

**The Core Problem:**
Hiring managers cannot reliably assess decision quality from resumes or typical portfolios.

**The MVP Solution:**
A site that:
- Establishes senior positioning in under 10 seconds
- Proves decision ownership with real evidence
- Changes the interview conversation

That's it.

### Core Features

#### Essential Pages (MVP)

**1. Homepage**
- **Core Functionality:**
  - Positioning statement that signals: seniority, decision ownership, end-to-end product thinking
  - Immediate proof signals (not testimonials, not buzzwords)
  - Clear path to case studies
- **Success Criteria:** If someone can't understand what kind of operator you are in 10 seconds, the MVP fails.

**2. Case Studies Index**
- Gallery/grid browsing for fast scanning and selection
- Enables hiring managers to choose which case study to read based on problem relevance, scope, and complexity signals

**3. 1-2 Flagship Case Studies (Not 3)**
- **Minimum Viable Count:** One excellent case study beats three good ones
- **Ideal MVP:** 1 flagship, deeply defensible case + optional second lighter-weight case to show range
- **Rationale:** Shipping with 3 half-polished cases dilutes trust. This product is about judgment density, not volume.

**Minimum Viable Case Study Structure:**
Every case study must answer five questions, cleanly and fast:
1. **Context:** What problem mattered? Why now? Why it was hard
2. **Ownership:** What you owned. What decisions were yours vs influenced
3. **Decision Frame:** Options considered. Tradeoffs. Constraints
4. **Outcome:** What changed. Metrics if relevant, but not fetishized. Second-order effects
5. **Reflection:** What you'd do differently. What this taught you about decision-making

If a case study can't support cross-examination here, it's not MVP-ready.

**4. Resume Page**
- HTML snapshot + PDF link
- Scannable executive summary format
- Credibility signal for traditional resume-first evaluators

#### What Creates the "Aha!" Moment

The aha is not visual. The aha is when a reader thinks: **"This person made the kinds of decisions I struggle with."**

Features that create that moment:
- Explicit tradeoffs
- Clear ownership language
- Calm, non-performative confidence
- Saying "no" on the page

No animations required. No clever UI tricks. Just intellectual honesty.

#### Hugo + Blowfish: Minimum Customization for "Calm Authority"

**Required Customization:**
- Typography hierarchy that privileges reading speed
- Generous whitespace
- Muted, neutral color palette
- Strong section headers and subheaders
- Consistent case study template

**Explicitly Not Required for MVP:**
- Custom components
- Micro-interactions
- Dark mode tuning
- Advanced theming
- Custom CMS logic

Blowfish already gets you 80%. Take it. Don't fight it.

### Out of Scope for MVP

**Explicitly Deferred Pages:**
- About page (hygiene, not value driver)
- Contact page (email link in footer is enough)

If a hiring manager wants to contact you, they will find a way. Don't pretend otherwise.

**Explicitly Deferred Features:**
- Analytics instrumentation
- A/B testing
- Complex filtering or tagging
- Interactive diagrams
- Long-form essays
- "Thought leadership" posts
- Personal storytelling detours

Those are Phase 2 luxuries.

**Additional Out of Scope (from project proposal):**
- Backend services, logins, complex interactivity
- Custom CMS (unless explicitly requested)
- Heavy React app behavior

### MVP Success Criteria

**Primary Success Metric:**
A hiring manager can say: "I trust this person's judgment and want to talk to them."

**Validation Signals:**
- Interview conversations skip "tell me what you did" and jump straight to tradeoffs and outcomes
- Fewer screens and deeper conversations
- Best feedback: "We didn't need to ask you the usual questions"

**Decision Point:**
If the MVP doesn't feel slightly uncomfortable to ship, it's too big. The goal is not to impress. It's to change how senior people evaluate you.

### Priority Order (Non-Negotiable)

1. **One killer case study** - This is the core value
2. **Homepage clarity** - 10-second positioning test
3. **Resume credibility** - Traditional evaluator support
4. **Second case study** (optional) - Range demonstration
5. **Everything else** - Deferred until core value is proven

If you ship that, the product already works.

### Future Vision

**Phase 2 Enhancements (Post-MVP):**
- About page with deeper narrative
- Contact page with structured form
- Additional case studies (3-5 total)
- Analytics to track engagement patterns
- Enhanced filtering/search for case studies (only if it clearly adds value)

**Phase 3 Expansion (Optional):**
- Writing/talks section
- Additional projects showcase
- Refined OpenGraph images
- Enhanced visual consistency and polish

**Strategic Evolution:**
The portfolio may evolve into a broader professional presence, but MVP success is measured by one metric: does it change how hiring managers evaluate you? Everything else is secondary until that's proven.
