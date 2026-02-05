# Phase 2: Content & Styling - Context

**Gathered:** 2026-02-05
**Status:** Ready for planning

<domain>
## Phase Boundary

Populate professional profile with complete work history, skills, education, bio, and contact info. Apply custom visual branding (colors, typography, dark mode). Adopt CareerCanvas layout patterns while keeping custom theming.

**Not in scope:** Case studies migration, blog section, publications, PDF resume (all deferred to v2).

</domain>

<decisions>
## Implementation Decisions

### Content Depth & Structure
- **Experience format:** Paragraph summaries (2-3 sentence narrative per role, not bullet lists)
- **PhD framing:** Integrated narrative — PhD listed as experience entry showing how research skills transferred to product leadership
- **Role scope:** Full career arc — all positions including PhD research and earlier roles
- **Case study links:** Claude's discretion on whether/how to link from experience entries

### Visual Branding Direction
- **Color scheme:** Near-monochromatic base with pops of bright executive blue accent (#1E3A5F range)
- **Dark mode:** Must work perfectly — equal attention to light and dark modes
- **Layout patterns from CareerCanvas:**
  - Alternating card sections (left/right positioning for visual rhythm)
  - Icon-driven section headers (distinctive icon per section)
  - Single-scroll structure (everything on one page, smooth scrolling)
- **Typography:** Open to exploring alternatives to TikTok Sans — should fit minimal/elegant executive aesthetic

### Skills Presentation
- **Categories:** Domain-based (Data Science, Product Management, Technical Leadership, Tools)
- **Proficiency indicators:** Visual/iconographic representation (not text tiers)
- **Technical depth:** Mix — high-level categories with expandable/hover detail for specific tools
- **Balance:** Equal weight to product/leadership and technical skills

### Bio & Positioning Voice
- **Tone:** Professional but warm — executive credibility with approachable voice
- **Person:** First person ("I build..." not "Athan builds...")
- **Emphasis:** Lead with decision-making philosophy, credentials support it
- **Length:** Short (2-3 sentences) — punchy intro, details live in experience section

### Claude's Discretion
- Whether to link experience entries to case studies
- Exact icon selection for section headers
- Typography alternatives exploration (recommend options)
- Specific proficiency visualization approach
- Exact blue accent shade within the executive blue palette

</decisions>

<specifics>
## Specific Ideas

- **CareerCanvas theme reference:** https://themes.gohugo.io/themes/careercanvas/
  - Adopt layout components (alternating cards, icons, single-scroll) NOT theming (colors, typography)
  - This is a structural reference, not a visual clone
- **Color philosophy:** Near-monochromatic creates elegance; bright blue accents create executive polish
- **PhD → Product is the unique differentiator** — should be visible in experience flow, not hidden in education section

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

**Already deferred to v2 (per ROADMAP.md):**
- Case studies migration
- Full CSS port (1200+ lines)
- Blog/writing section
- Publications section
- Downloadable PDF resume

</deferred>

---

*Phase: 02-content-styling*
*Context gathered: 2026-02-05*
