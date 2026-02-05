---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
inputDocuments:
  - planning-artifacts/product-brief-athan-dial.github.io-2026-01-09.md
  - docs/context/1-portfolio-site-project-proposal.md
  - docs/context/2-brand-profile.md
  - docs/context/3-voice-and-tone.md
  - docs/context/4-case-study-playbook.md
  - docs/context/5-proof-points.md
workflowType: 'prd'
lastStep: 1
briefCount: 1
researchCount: 0
brainstormingCount: 0
projectDocsCount: 5
date: 2026-01-09
author: Athan
projectType: greenfield
---

# Product Requirements Document - athan-dial.github.io

**Author:** Athan
**Date:** 2026-01-09

## Executive Summary

The athan-dial.github.io portfolio solves a critical trust gap: senior readers need to see product judgment and execution leadership, not just technical activity. This Hugo static site functions as an executive brief that makes three signals instantly clear: (1) ability to turn ambiguous, high-stakes problems into concrete decision loops with metrics, guardrails, and tradeoffs; (2) cross-functional leadership that ships outcomes, not just analysis; (3) communication that enables action, not just admiration.

Target users—hiring managers, executives, and cross-functional partners—can accurately assess fit within 90 seconds through scannable, decision-forward case studies grounded in defensible evidence. Success means they can confidently answer "What did you own?", "Why that approach?", and "What changed?" without requiring a meeting.

This approach treats the portfolio as a product surface, not a scrapbook, presenting work the way senior teams consume information: structured, evidence-based, and optimized for rapid decision-making.

### What Makes This Special

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

## Project Classification

**Technical Type:** Web Application (Static Site)
**Domain:** General (Portfolio/Professional Site)
**Complexity:** Low
**Project Context:** Greenfield - new project

**Technical Stack:**
- **Framework:** Hugo (static site generator)
- **Hosting:** GitHub Pages
- **Theme Base:** Blowfish (with minimal customization)
- **Deployment:** Static HTML/CSS/JS via GitHub Pages

**Architecture Pattern:**
Static site generation with markdown content, minimal client-side JavaScript, serverless hosting. No backend services, databases, or complex interactivity required.

**Key Technical Considerations:**
- Fast loading and performance optimization
- Responsive design for mobile/tablet/desktop
- SEO basics (titles, descriptions, OpenGraph, sitemap, robots)
- Accessibility basics (semantic headings, keyboard navigation, alt text)
- Minimal customization of Blowfish theme to achieve "calm authority" visual direction

---

## Success Criteria

### User Success

**Primary Success Metric:**
A hiring manager can say: **"I trust this person's judgment and want to talk to them."**

**User Success Indicators:**

**For Hiring Managers:**
- Can assess product judgment and decision ownership within 90 seconds
- Can answer "What did you own?", "Why that approach?", and "What changed?" without requiring a meeting
- Interview conversations skip "tell me what you did" and jump straight to tradeoffs and outcomes
- Experience fewer screens and deeper conversations as a result of portfolio clarity

**For Executives/Skip-Level Reviewers:**
- Can quickly evaluate strategic thinking and problem selection without deep reading
- Can assess risk posture and leverage through scannable case studies
- Portfolio functions as confirmation device, not discovery tool

**For Cross-Functional Partners:**
- Can predict collaboration quality and working style from portfolio content
- Can understand decision boundaries and explicit ownership
- Arrive at interviews already aligned on working approach

**The "Aha!" Moment:**
When a reader thinks: **"This person made the kinds of decisions I struggle with."**

**Homepage Success Test:**
If someone can't understand what kind of operator you are in 10 seconds, the MVP fails.

### Business Success

**Primary Business Metric:**
Change how senior people evaluate you, not just impress them.

**Business Success Indicators:**

**Interview Quality:**
- Interview conversations elevate from basic questions to strategic discussions
- Best feedback: "We didn't need to ask you the usual questions"
- Reduced time spent on basic qualification questions

**Career Impact:**
- Access to staff+, principal, and exec-adjacent roles
- Different expectations and conversations in interviews
- Positioning above "strong IC with opinions" into "decision owner territory"

**Portfolio Effectiveness:**
- Portfolio compresses trust-building and elevates conversation quality
- Enables faster progression through interview loops
- Creates leverage in compensation and role negotiations

**Success Validation:**
- Qualitative backchannels: "Which case did you read first, and why?"
- Conversion proxy: Interview progression velocity
- Goal isn't "they read everything" - it's "they arrive pre-convinced I have product judgment"

### Technical Success

**Performance Requirements:**
- Fast loading: Optimized static site generation with compressed assets
- Responsive layout: Mobile, tablet, and desktop compatibility
- Performance targets: Lighthouse performance score > 90 (target)
- Image optimization: Compressed images with appropriate formats

**Accessibility Requirements:**
- Semantic HTML structure with proper heading hierarchy
- Keyboard navigation support throughout site
- Alt text for all images
- WCAG 2.1 Level AA compliance (baseline)

**SEO Requirements:**
- Page titles and meta descriptions for all pages
- OpenGraph tags for social sharing
- XML sitemap generation
- robots.txt configuration
- Structured data where appropriate

**Visual Consistency:**
- Clean, editorial design with low ornament
- No stock-photo vibe
- Consistent typography hierarchy that privileges reading speed
- Generous whitespace and muted, neutral color palette
- Strong section headers and subheaders

**Reliability:**
- GitHub Pages uptime (managed by GitHub)
- No broken links or missing assets
- Consistent rendering across modern browsers

### Measurable Outcomes

**User Success Metrics:**
- 90-second assessment capability: Hiring managers can complete initial evaluation within target timeframe
- Interview conversation quality: Measured through qualitative feedback on conversation depth
- Case study engagement: Which case studies get read first and why (qualitative tracking)

**Business Success Metrics:**
- Interview progression velocity: Faster movement through interview stages
- Conversation quality: Shift from "tell me what you did" to "how would you approach our problem"
- Role quality: Access to more senior roles (staff+, principal, exec-adjacent)

**Technical Success Metrics:**
- Page load time: < 2 seconds on 3G connection
- Lighthouse scores: Performance > 90, Accessibility > 95, Best Practices > 95, SEO > 95
- Zero broken links or missing assets
- 100% responsive design coverage

---

## Product Scope

### MVP - Minimum Viable Product

**MVP North Star (Non-Negotiable):**
The MVP succeeds if a hiring manager can say: **"I trust this person's judgment and want to talk to them."**

**Essential Pages (MVP):**

**1. Homepage**
- Positioning statement that signals: seniority, decision ownership, end-to-end product thinking
- Immediate proof signals (not testimonials, not buzzwords)
- Clear path to case studies
- **Success Criteria:** If someone can't understand what kind of operator you are in 10 seconds, the MVP fails

**2. Case Studies Index**
- Gallery/grid browsing for fast scanning and selection
- Enables hiring managers to choose which case study to read based on problem relevance, scope, and complexity signals
- Strong metadata display (problem type, scope, complexity)

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

**Technical MVP Requirements:**
- Hugo static site generator setup
- Blowfish theme with minimal customization
- GitHub Pages deployment configuration
- Basic SEO (titles, descriptions, OpenGraph, sitemap, robots)
- Accessibility basics (semantic headings, keyboard navigation, alt text)
- Performance optimization (compressed images, fast loading)

**What Creates the "Aha!" Moment:**
- Explicit tradeoffs
- Clear ownership language
- Calm, non-performative confidence
- Saying "no" on the page

**Priority Order (Non-Negotiable):**
1. **One killer case study** - This is the core value
2. **Homepage clarity** - 10-second positioning test
3. **Resume credibility** - Traditional evaluator support
4. **Second case study** (optional) - Range demonstration
5. **Everything else** - Deferred until core value is proven

**Decision Point:**
If the MVP doesn't feel slightly uncomfortable to ship, it's too big. The goal is not to impress. It's to change how senior people evaluate you.

### Growth Features (Post-MVP)

**Phase 2 Enhancements:**
- About page with deeper narrative
- Contact page with structured form (or email link in footer if sufficient)
- Additional case studies (3-5 total)
- Analytics to track engagement patterns (qualitative backchannels preferred over instrumentation)
- Enhanced filtering/search for case studies (only if it clearly adds value)

**Phase 2 Technical Enhancements:**
- Refined OpenGraph images
- Enhanced visual consistency and polish
- Performance optimizations based on usage patterns

### Vision (Future)

**Phase 3 Expansion (Optional):**
- Writing/talks section
- Additional projects showcase
- Enhanced case study filtering and organization
- More sophisticated visual design elements (only if they serve the core value)

**Strategic Evolution:**
The portfolio may evolve into a broader professional presence, but MVP success is measured by one metric: does it change how hiring managers evaluate you? Everything else is secondary until that's proven.

---

## User Journeys

### Journey 1: The Hiring Manager - Fast Filter to Deep Engagement

**Persona:** Director/Senior Director/Head of Product/Data/Platform who owns outcomes and has been burned before by candidates with strong resumes but weak judgment.

**Their Story:**
Sarah Chen is a Senior Director of Data Science at a mid-size tech company. Her calendar is chaos with a veneer of control. Between roadmap fights, budget tradeoffs, and unblocking teams, she squeezes candidate reviews into late afternoon gaps. She's been burned before—strong resumes, smart interviews, but weak judgment under real pressure. She's tired of guessing.

**Opening Scene - Discovery:**
It's 4:47 PM on a Tuesday. Sarah has 13 minutes before her next meeting. A referral email arrives: "Worth a look - this candidate's portfolio is different." Skeptical but open, she clicks the LinkedIn link that leads to athan-dial.github.io.

**Rising Action - The 10-Second Test:**
The homepage loads fast. No animations, no fluff. A clear positioning statement: "Data science + product leader who turns ambiguous, high-stakes problems into decision systems." Proof tiles show concrete outcomes, not buzzwords. Sarah thinks: "This person respects my time."

She scans the case studies index. Three options, but one catches her eye: "Reducing Clinical Decision Latency" - problem relevance to her org's healthcare data challenges. She clicks.

**The 90-Second Scan:**
Sarah's internal monologue runs the judgment test:
- Problem clarity? ✓ "We needed to reduce decision latency for clinicians..."
- Success definition? ✓ "North star: time-to-decision, guardrails: accuracy, compliance"
- Decision logic? ✓ "Options: A (real-time), B (batch), C (hybrid). Chose B because..."
- Tradeoffs acknowledged? ✓ "Latency tradeoff for reliability and cost"
- Outcome honesty? ✓ "Reduced from X to Y, with clear constraints"

She slows down. This holds up under stress-testing.

**Climax - The Decision Moment:**
Sarah thinks: "I don't need to test basics with this person." She moves from evaluation → curiosity, skepticism → engagement. The portfolio has compressed trust-building. She forwards it to her skip-level with a note: "This candidate thinks the way we need to think."

**Resolution - Post-Portfolio Impact:**
The interview changes. Instead of "Tell me what you did," Sarah asks: "Walk me through how you think about ambiguous problems." The conversation jumps straight to tradeoffs and outcomes. Sarah's decision load is reduced. She knows this person can handle ambiguity.

**Six Months Later:**
The candidate is on the team, and Sarah's initial assessment was accurate. The portfolio didn't just showcase work—it predicted working style.

**Journey Requirements Revealed:**
- Homepage that communicates positioning within 10 seconds
- Case study index with clear problem relevance signals
- Case studies that support 90-second stress-testing
- Clear ownership language and explicit tradeoffs
- Outcome honesty with constraints acknowledged

### Journey 2: The Executive - Strategic Upside Assessment

**Persona:** VP/SVP/GM who's a risk assessor, not a day-to-day evaluator. Brutally limited time, microscopic patience.

**Their Story:**
James Mitchell is a VP of Product at a Fortune 500 company. He's in late-stage interview loops, making final yes/no decisions. He's not asking "Can this person do the work?" He's asking "Is this a good bet?"

**Opening Scene - Confirmation Mode:**
It's 8:15 AM. James has 10 minutes before his first meeting. An internal Slack message: "You should look at this candidate's site before the final round." The portfolio link is shared. James doesn't read linearly—he triangulates.

**Rising Action - Strategic Scan:**
James skims the homepage: "Why is this person senior?" The positioning is clear: decision-owner, not executor. He opens one case study, not three. He jumps straight to: problem framing, outcomes, scope of influence.

If the portfolio feels tactical, he's done. But this feels like thinking. He leans in.

**Climax - The Strategic Test:**
James looks for:
- Problem selection: Did this person work on the right things? ✓
- Value creation: Did outcomes move the org, not just a metric? ✓
- Judgment under constraint: Did they navigate tradeoffs responsibly? ✓
- Narrative coherence: Can they explain complexity without drowning in it? ✓

He sees clear articulation of second-order effects. Comfort with irreversible decisions. Evidence of shaping direction, not just executing it. Calm confidence without defensiveness.

**Resolution - Risk Assessment Complete:**
The portfolio functions as a confirmation device. James checks for red flags (none found) and upside (clear). He's checking: "Is this a good bet?" The answer is yes. The portfolio has done its job—he can make the final decision with confidence.

**Journey Requirements Revealed:**
- Homepage that answers "Why is this person senior?" instantly
- Case studies that enable strategic triangulation (problem → outcome → scope)
- Clear articulation of second-order effects and irreversible decisions
- Evidence of direction-shaping, not just execution
- Calm, non-performative confidence in presentation

### Journey 3: The Cross-Functional Partner - Collaboration Quality Prediction

**Persona:** Engineering lead, senior scientist, or ops/commercial partner deciding: "Do I want to work with this person?"

**Their Story:**
Dr. Priya Patel is a Senior Engineering Lead evaluating a potential data science partner. She's not judging seniority alone—she's judging working style. Will working with this person make her job easier or harder?

**Opening Scene - Internal Referral:**
It's Wednesday afternoon. A colleague sends a Slack message: "You should look at this candidate's site—they're interviewing for the DS role on your team." Priya clicks the link, curious but cautious.

**Rising Action - Working Style Assessment:**
Priya reads more deeply than execs, but less defensively than hiring managers. She's asking:
- Do you understand my constraints? (She looks for technical depth with decision context)
- Do you respect expertise outside your lane? (She looks for collaborative language, not condescension)
- Can you translate between worlds? (She looks for clear explanations that don't oversimplify)
- Will working with you make my job easier? (She looks for clear decision boundaries and explicit ownership)

**Climax - The Collaboration Test:**
Priya finds a case study that shows:
- Clear decision boundaries: "I owned the metric definition; engineering owned the implementation"
- Explicit ownership: "This was my call" not "we did X" fog
- Thoughtful collaboration: Evidence of carrying ideas from abstraction to production
- Translation capability: Technical depth explained in business terms, business needs translated to technical requirements

She thinks: "This person can reason abstractly, interrogate data deeply, map decisions cleanly, and actually ship. That's rare. And magnetic."

**Resolution - Pre-Aligned Interview:**
If Priya likes what she sees, she shows up to interviews already aligned. The portfolio has predicted collaboration quality. She knows this person will make her job easier, not harder.

**Journey Requirements Revealed:**
- Case studies that show clear decision boundaries and explicit ownership
- Evidence of thoughtful collaboration (not "we did X" fog)
- Technical depth explained in business terms
- Business needs translated to technical requirements
- Clear demonstration of abstraction → production capability

### Journey 4: The Hiring Manager - Edge Case (Wrong Case Study Selection)

**Persona:** Same hiring manager persona, but encountering a case study that doesn't match their needs.

**Their Story:**
Same Sarah Chen, but this time she selects a case study that's less relevant to her org's challenges. The case study is well-structured, but the problem domain doesn't resonate.

**Opening Scene - Mismatch Discovery:**
Sarah clicks on a case study about "Optimizing E-commerce Recommendations" but her org is in healthcare. The problem framing is solid, but the domain context doesn't align.

**Rising Action - Alternative Path:**
Instead of bouncing, Sarah:
- Scans the case study structure (still holds up)
- Checks the case studies index for other options
- Finds a second case study: "Reducing Clinical Decision Latency" - perfect match
- Recognizes the consistent structure makes comparison easy

**Climax - Structure Over Content:**
Sarah realizes: "Even when the domain doesn't match, the decision-making structure is consistent. I can see the judgment quality regardless of context." The portfolio's structure enables her to find the right case study quickly.

**Resolution - Successful Navigation:**
Sarah finds the relevant case study and completes her evaluation. The portfolio's consistent structure and clear index enable successful navigation even when initial selection doesn't match.

**Journey Requirements Revealed:**
- Case studies index that enables quick problem-domain matching
- Consistent structure across all case studies (enables comparison)
- Clear metadata (problem type, scope, complexity) in index
- Multiple case studies to show range and enable selection

### Journey Requirements Summary

**Core Capabilities Revealed by Journeys:**

1. **Homepage Capability:**
   - 10-second positioning communication
   - Immediate proof signals (not testimonials)
   - Clear path to case studies
   - Fast loading and performance

2. **Case Studies Index Capability:**
   - Gallery/grid browsing for fast scanning
   - Strong metadata display (problem type, scope, complexity)
   - Enables problem-relevance-based selection
   - Consistent structure preview

3. **Case Study Capability:**
   - 90-second scannable structure
   - Five-question framework (Context, Ownership, Decision Frame, Outcome, Reflection)
   - Explicit tradeoffs and constraints
   - Clear ownership language
   - Outcome honesty with metrics/constraints
   - Support for strategic triangulation (problem → outcome → scope)

4. **Resume Page Capability:**
   - HTML snapshot + PDF link
   - Scannable executive summary format
   - Credibility signal for traditional evaluators

5. **Technical Capabilities:**
   - Fast loading (performance optimization)
   - Responsive design (mobile/tablet/desktop)
   - SEO basics (titles, descriptions, OpenGraph)
   - Accessibility basics (semantic HTML, keyboard navigation, alt text)
   - Visual consistency (calm authority aesthetic)

**Out of Scope (Explicitly Deferred):**
- About page (MVP) - hygiene, not value driver
- Contact page (MVP) - email link in footer is enough
- Analytics instrumentation (MVP) - qualitative feedback preferred
- A/B testing
- Complex filtering or tagging
- Interactive diagrams
- Long-form essays
- "Thought leadership" posts
- Personal storytelling detours
- Backend services, logins, complex interactivity
- Custom CMS (unless explicitly requested)
- Heavy React app behavior

---

## Functional Requirements

### Homepage Capabilities

- FR1: Visitors can understand the site owner's positioning (seniority, decision ownership, end-to-end product thinking) within 10 seconds of landing on the homepage
- FR2: Visitors can see immediate proof signals (outcomes, scope, metrics) without scrolling
- FR3: Visitors can navigate to the case studies index from the homepage
- FR4: Visitors can access the resume page from the homepage
- FR5: The homepage displays positioning statement that signals seniority and decision ownership
- FR6: The homepage displays proof tiles showing concrete outcomes and scope (not testimonials or buzzwords)

### Case Studies Index Capabilities

- FR7: Visitors can browse case studies in a gallery/grid format for fast scanning
- FR8: Visitors can see case study metadata (problem type, scope, complexity) in the index view
- FR9: Visitors can select a case study based on problem relevance to their organization
- FR10: Visitors can identify case study scope and complexity signals before reading the full case study
- FR11: The case studies index enables problem-relevance-based selection
- FR12: The case studies index displays consistent structure preview for all case studies

### Case Study Page Capabilities

- FR13: Visitors can read case studies that answer five core questions: Context, Ownership, Decision Frame, Outcome, Reflection
- FR14: Visitors can understand what problem mattered, why it mattered now, and why it was hard (Context)
- FR15: Visitors can identify what the site owner owned versus what they influenced (Ownership)
- FR16: Visitors can see options considered, tradeoffs, and constraints (Decision Frame)
- FR17: Visitors can understand what changed, metrics if relevant, and second-order effects (Outcome)
- FR18: Visitors can read reflection on what would be done differently and what was learned (Reflection)
- FR19: Case studies support 90-second scannable structure for rapid assessment
- FR20: Case studies display explicit tradeoffs and constraints
- FR21: Case studies use clear ownership language (not "we did X" fog)
- FR22: Case studies show outcome honesty with metrics and constraints acknowledged
- FR23: Case studies enable strategic triangulation (problem → outcome → scope) for executive readers
- FR24: Case studies demonstrate decision-making structure regardless of domain context

### Resume Page Capabilities

- FR25: Visitors can view resume content in HTML format on the site
- FR26: Visitors can download resume as PDF
- FR27: The resume page displays scannable executive summary format
- FR28: The resume page provides credibility signal for traditional resume-first evaluators

### Navigation and Site Structure Capabilities

- FR29: Visitors can navigate between homepage, case studies index, individual case studies, and resume page
- FR30: The site maintains consistent navigation structure across all pages
- FR31: Visitors can return to homepage from any page
- FR32: The site provides clear information architecture for finding relevant content

### Content Management Capabilities

- FR33: Content authors can add new case studies using consistent template structure
- FR34: Content authors can update existing case studies while maintaining structure integrity
- FR35: The site supports markdown-based content authoring for case studies
- FR36: Case studies follow mandatory structure that ensures PM signal is unavoidable

---

## Non-Functional Requirements

### Performance

- NFR1: Homepage loads and displays positioning within 2 seconds on 3G connection
- NFR2: Case study pages load and become scannable within 2 seconds on 3G connection
- NFR3: Lighthouse performance score must be > 90
- NFR4: Images are compressed and optimized for fast loading
- NFR5: Static site generation produces optimized HTML/CSS/JS assets
- NFR6: Site supports 90-second assessment capability without performance degradation

### Accessibility

- NFR7: Site meets WCAG 2.1 Level AA compliance baseline
- NFR8: All pages use semantic HTML structure with proper heading hierarchy
- NFR9: All interactive elements support keyboard navigation
- NFR10: All images include descriptive alt text
- NFR11: Site maintains focus indicators for keyboard navigation
- NFR12: Color contrast meets WCAG AA standards for text readability

### SEO

- NFR13: All pages include unique, descriptive page titles
- NFR14: All pages include meta descriptions
- NFR15: All pages include OpenGraph tags for social sharing
- NFR16: Site generates XML sitemap
- NFR17: Site includes robots.txt configuration
- NFR18: Site includes structured data where appropriate for search engines

### Visual Consistency

- NFR19: Site maintains clean, editorial design with low ornament
- NFR20: Site avoids stock-photo aesthetic
- NFR21: Typography hierarchy privileges reading speed
- NFR22: Site uses generous whitespace and muted, neutral color palette
- NFR23: Section headers and subheaders are visually strong and consistent
- NFR24: Case study template maintains visual consistency across all case studies
- NFR25: Site achieves "calm authority" visual direction

### Reliability

- NFR26: Site maintains GitHub Pages uptime (managed by GitHub infrastructure)
- NFR27: Site has zero broken links or missing assets
- NFR28: Site renders consistently across modern browsers (Chrome, Firefox, Safari, Edge)
- NFR29: Site maintains responsive design across mobile, tablet, and desktop viewports
- NFR30: Static site generation produces error-free HTML output

### Content Quality

- NFR31: All case studies must support cross-examination on five core questions
- NFR32: Case studies demonstrate judgment density, not just volume
- NFR33: Content maintains voice and tone standards (crisp, calm, decisive, concrete)
- NFR34: All claims tie to metrics, constraints, and outcomes (defensible evidence)
- NFR35: Content avoids vague bragging and uses ownership verbs (defined, drove, shipped, measured)
