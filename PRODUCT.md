# Product

## Register

brand

## Users

The primary reader is someone exploring AI, data, and expert work who wants a useful idea,
a method to borrow, or a clear account of an experiment. Fieldnotes is the main publication path.

The homepage serves a broader first visit. Colleagues, product and technical peers, hiring leaders,
and people arriving through writing should be able to understand Athan's work, trajectory, and
recurring problem territory in one scroll without being forced through a career pitch.

A useful visit leaves the reader with a clearer question, an explanation they can use, a workflow
worth testing, or a better model of Athan's practice. Articles need to stand on their own. Browsing
should not require understanding internal names or the history of this website.

## Homepage job

The homepage is not a sparse publication cover and not a conventional portfolio grid. It is a
single-scroll personal profile with seven chapters:

1. identity;
2. current idea;
3. work in practice;
4. Fieldnotes;
5. trajectory;
6. operating territory;
7. context.

This order is intentional. The reader meets Athan, sees one current idea, sees that it is grounded in
real product work, then gets the broader notebook, career movement, and the questions connecting the
whole body of work.

The common single-scroll visit should feel progressively more specific rather than increasingly
resume-like.

## Public destinations

Four, each with a distinct job. Added 2026-09-10; authority
`.planning/specs/2026-09-10-personal-brand-proof-layer-design.md`.

| Destination | Job |
|---|---|
| **Home** | Interesting practitioner. One scroll: who Athan is, one current idea, that the idea is grounded in real product work, then the notebook, the movement, and the recurring questions. |
| **Work** | Credible product leader. Two evidence-disciplined product narratives showing ownership, boundaries, and what the record does not support. |
| **Fieldnotes** | Coherent intellectual territory. Essays, field notes, and selected LinkedIn writing as three deliberate sources in one publication. |
| **About** | Research depth, trajectory, and leadership classification. The proof surface — the place a reader can establish current role, movement, product ownership, and research foundation without a public resume existing. |

The asymmetry is deliberate. The homepage should read as if it is for practitioners while
accumulating enough evidence underneath that a hiring reader can classify the work. Ideas come
before credentials on every surface; credentials are reachable in one click from any of them.

There is no Skills page, no consultancy funnel, no project zoo, and no public resume. Each of
those absences is a decision, not a gap — see the spec's deferred list before adding one.

## Brand Personality

**Rigorous, warm, bounded.**

Voice: first person, concrete situations before abstractions, uncertainty labelled rather than smoothed over. States a position and names the condition that would revise it. Dry rather than funny. Specific numbers or none.

It should feel rigorous without looking clinical, warm without looking lifestyle, technical without looking like a developer landing page, structured without looking like a consulting deck, and personal without becoming a biography site.

The reader should experience the judgment through what is emphasised, what is bounded, what is verified, and what is deliberately left out, not be told it exists.

## Anti-references

- **The dark technical zine** the Agency section used to be. Technical depth must not become the loudest reading of the career.
- **The SaaS dashboard portfolio.** Hero metric, gradient accent, identical card grid.
- **The publication-only homepage.** Fieldnotes is a strong surface language, but the personal site must retain enough professional depth to explain the work and trajectory.
- **Anything implying an active consultancy.** No pricing, no discovery calls, no engagement tiers, no lead capture. Athan is employed; the site must never read as a business.
- **Stock photography, AI-generated abstract network art, decorative icon sets.** Named in the redesign plan as disqualifying.
- **Third-party embeds.** The previous homepage led with LinkedIn iframes, two of which rendered blank.
- **Unverifiable precision.** Seven fabricated case studies were removed. A claim without a source does not ship.
- **Motion theatre.** No parallax, scroll-jacking, invisible-until-revealed content, looping decoration, or animation whose only job is to announce that the site has JavaScript.

## Design Principles

1. **Evidence before assertion.** Nothing publishes without a traceable source. Where something was never measured, the page says so; that candour is the credential.
2. **Mechanism over invented precision.** Explain the decision and the system. A real range beats a false number, and an honest absence beats both.
3. **Draw the boundary.** The recurring subject is what becomes shared and reliable versus what stays expert-controlled. The design should express boundaries too: rules and structure, not floating cards.
4. **Depth before biography.** Restore the virtual-profile effect through work, trajectory, and recurring questions rather than narrating a resume.
5. **Motion should explain progression.** The single scroll can gain rhythm and state, but the static document must remain complete.
6. **Density is respect.** These readers are fast and busy. Generous where reading happens, tight everywhere else. Empty acreage signals nothing to say.
7. **Practise what you claim.** A site arguing for verification must itself be verifiable, accessible, and fast.

## Accessibility & Inclusion

WCAG 2.2 AA, tested rather than assumed. Semantic heading order, full keyboard navigation, visible focus on every control, 4.5:1 body contrast (3:1 large and non-text), 44px pointer targets, descriptive links and alt text, nothing conveyed by colour alone, and a `prefers-reduced-motion` path for every animation.

The wide homepage chapter index is optional navigation, not the only way to reach content. Every
chapter remains in normal document flow and every index item is a real anchor. JavaScript may track
the current chapter but must not reveal, hide, reorder, or gate content.

Light-only by deliberate choice; a dark variant of a warm-paper identity is a separate design problem and is deferred.

Core Web Vitals are launch gates at p75: LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1. Self-hosted subset fonts, no client framework, no third-party embeds.
