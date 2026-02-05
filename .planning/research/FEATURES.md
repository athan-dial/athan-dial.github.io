# Feature Research: Hugo Resume Theme

**Domain:** Professional portfolio website for senior tech leader
**Researched:** 2026-02-04
**Confidence:** HIGH

## Feature Landscape

### Table Stakes (Users Expect These)

Features that senior tech hiring managers and networking contacts assume exist. Missing these = portfolio lacks professional credibility.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Single-page resume layout | Industry standard for quick scanning | LOW | Hugo Resume provides auto-scrolling navigation |
| Work experience timeline | Essential for career progression narrative | LOW | Driven by `data/experience.json` |
| Skills inventory | Hiring managers screen by tech stack | LOW | Driven by `data/skills.json` with dev icons |
| Education background | Credential verification (especially PhD) | LOW | Driven by `data/education.json` |
| Contact information | Must be easy to reach you | LOW | Email, phone, social handles configurable |
| Social media links | Expected: LinkedIn, GitHub at minimum | LOW | Hugo Resume supports 5+ social platforms |
| Mobile responsive design | 60%+ of traffic is mobile | LOW | Bootstrap-based, handles responsively |
| Professional photo | Humanizes portfolio, builds trust | LOW | Profile image parameter in config |
| Custom domain | yourname.com signals professionalism | LOW | Hugo deploys to any domain |
| Dark mode support | Standard UX expectation in 2026 | MEDIUM | NOT included in Hugo Resume (gap) |
| Fast load times | Slow site = high bounce rate | LOW | Static site generation handles this |
| Clean navigation | Must be intuitive within 3 seconds | LOW | Fixed left-nav with auto-scroll |

### Differentiators (Competitive Advantage)

Features that support unique positioning as PhD→Product leader with decision science focus.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Detailed project pages | Demonstrates depth over breadth | LOW | Hugo Resume has dedicated `/creations/` and `/contributions/` |
| Publications section | Showcases academic→industry bridge | LOW | Separate `/publications/` archetype |
| Blog/writing section | Thought leadership, decision frameworks | LOW | `/blog/` folder supported |
| Client-side search | Visitors can find specific topics | LOW | fuse.js powers `/search` endpoint |
| Downloadable resume PDF | Enables ATS submission and printing | MEDIUM | Requires PDF generation (not built-in) |
| Case study format | Shows decision-making process | MEDIUM | Requires custom layout/archetype |
| Metrics/outcomes display | Quantifies impact ("decision velocity") | MEDIUM | Requires custom data structure |
| Portfolio categories | Separates original work vs contributions | LOW | Built-in: `/creations/` vs `/contributions/` |
| Multi-language support | Signals global experience | MEDIUM | Hugo Resume supports EN/FR, extensible |
| Content tagging system | Enables filtering by topic/skill | LOW | Taxonomy built into Hugo |
| QR code for vCard | Easy contact add at conferences | LOW | Optional parameter in config |
| Netlify CMS integration | Non-technical editing capability | MEDIUM | Built-in admin endpoint with auth |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem valuable but undermine professional credibility or create maintenance burden.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Animated hero sections | "Looks modern and engaging" | Distracts from content, feels junior | Clean, text-focused hero with strong positioning statement |
| Skills rating bars | "Shows proficiency levels" | Subjective, often inflated, looks amateurish | List tech stack by category (current/familiar/exploring) without ratings |
| Every project ever built | "Shows breadth of experience" | Dilutes portfolio with weak work, overwhelming | Curate 3-5 best projects that align with target roles |
| Testimonials carousel | "Social proof is important" | Common on junior portfolios, feels sales-y | Let work speak for itself; mention notable collaborators in context |
| Buzzword clouds | "Highlights key skills visually" | Dated design pattern (circa 2010) | Structured skills taxonomy with context |
| Auto-playing video background | "Creates immersive experience" | Accessibility nightmare, slow load, unprofessional | High-quality static imagery or clean backgrounds |
| Multiple CTA buttons | "More ways to connect = more leads" | Decision paralysis, looks like you're job hunting | Single clear contact method, professional LinkedIn link |
| Blog with infrequent posts | "Shows thought leadership" | Stale content (last post 2023) signals neglect | Either commit to regular writing or skip blog section |
| Kitchen sink integrations | "Show I know many tools" | Over-engineered for a resume site | Use Hugo + GitHub Pages, keep it simple |
| Real-time visitor counter | "Shows site popularity" | Irrelevant for portfolio, looks insecure | Skip analytics displays entirely |

## Feature Dependencies

```
[Single-page layout]
    └──requires──> [Navigation menu]
                       └──requires──> [Section anchors]

[Project detail pages] ──enhances──> [Portfolio section]
[Publications pages] ──enhances──> [Academic credibility]
[Blog section] ──enhances──> [Thought leadership positioning]

[Search functionality] ──requires──> [fuse.js library]
                                 └──requires──> [JSON content index]

[Netlify CMS] ──requires──> [Admin authentication]
                       └──requires──> [Git integration]

[Case studies] ──conflicts──> [Brief project cards] (different content depth)
```

### Dependency Notes

- **Single-page layout requires navigation menu:** Auto-scrolling nav is core UX pattern
- **Project detail pages enhance portfolio section:** Allows brief cards on homepage, detailed pages for depth
- **Search requires fuse.js + JSON index:** Hugo Resume has this built-in, low maintenance
- **Netlify CMS requires admin auth + git:** Optional feature, adds complexity without clear value for personal site
- **Case studies conflict with brief project cards:** Decision needed - emphasize depth (case studies) or breadth (many projects)

## MVP Definition

### Launch With (v1)

Minimum viable portfolio to support hiring conversations and networking.

- [x] **Single-page resume layout** — Table stakes for quick scanning
- [x] **Work experience timeline** — Essential for career narrative (Montai 2023-2026, Stanford Data Science, PhD)
- [x] **Skills taxonomy** — Hiring managers screen by tech stack (R/Shiny, Python, Product Strategy)
- [x] **Education section** — PhD credential is key differentiator
- [x] **Contact info + social links** — LinkedIn and GitHub minimum
- [x] **Mobile responsive** — 60%+ mobile traffic
- [x] **Custom domain** — athan-dial.github.io → athandial.com (if available)
- [x] **Professional photo** — Humanizes portfolio
- [ ] **3-5 curated projects** — Defer to post-launch (requires ChatGPT Deep Research outputs)

### Add After Validation (v1.x)

Features to add once theme migration is working and basic content is live.

- [ ] **Case studies section** — Decision evidence format (requires custom archetype)
- [ ] **Publications page** — Academic→industry bridge (requires content curation)
- [ ] **Blog section** — Thought leadership on decision systems (requires authentic voice research)
- [ ] **Search functionality** — Enable once content volume justifies it
- [ ] **Downloadable resume PDF** — Enable ATS submission and printing
- [ ] **Dark mode** — Standard UX feature, missing from Hugo Resume

### Future Consideration (v2+)

Features to defer until portfolio is established and strategy is validated.

- [ ] **Multi-language support** — Only if targeting global roles
- [ ] **Tag-based filtering** — Only if 10+ projects/articles exist
- [ ] **Netlify CMS integration** — Unnecessary for personal site maintained by owner
- [ ] **QR code vCard** — Nice-to-have for conference networking
- [ ] **Advisory/consulting page** — Requires employer safety review

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Single-page resume layout | HIGH | LOW (built-in) | P1 |
| Work experience timeline | HIGH | LOW (data-driven) | P1 |
| Skills inventory | HIGH | LOW (data-driven) | P1 |
| Education background | HIGH | LOW (data-driven) | P1 |
| Contact + social links | HIGH | LOW (config params) | P1 |
| Mobile responsive | HIGH | LOW (Bootstrap) | P1 |
| Professional photo | HIGH | LOW (image + config) | P1 |
| Custom domain | MEDIUM | LOW (DNS setup) | P1 |
| Case studies section | HIGH | MEDIUM (custom archetype) | P2 |
| Publications page | MEDIUM | LOW (built-in archetype) | P2 |
| Blog/writing section | MEDIUM | LOW (built-in archetype) | P2 |
| Search functionality | MEDIUM | LOW (built-in fuse.js) | P2 |
| Downloadable resume PDF | MEDIUM | MEDIUM (PDF generation) | P2 |
| Dark mode | MEDIUM | MEDIUM (CSS overrides) | P2 |
| Project detail pages | MEDIUM | LOW (built-in archetype) | P2 |
| Tag-based filtering | LOW | LOW (Hugo taxonomy) | P3 |
| Multi-language support | LOW | MEDIUM (i18n setup) | P3 |
| Netlify CMS | LOW | MEDIUM (auth + config) | P3 |
| QR code vCard | LOW | LOW (built-in toggle) | P3 |

**Priority key:**
- P1: Must have for launch (professional credibility threshold)
- P2: Should have, add when content is ready (differentiation features)
- P3: Nice to have, future consideration (low ROI, niche use cases)

## Competitor Feature Analysis

Based on professional portfolio research for senior tech roles in 2026.

| Feature | Industry Standard | Hugo Resume | Our Approach |
|---------|-------------------|-------------|--------------|
| Single-page layout | ✅ Auto-scrolling nav | ✅ Built-in | Use as-is |
| Work experience | ✅ Timeline format | ✅ JSON-driven | Use data/experience.json |
| Skills display | ✅ Categorized list | ✅ JSON + dev icons | Avoid rating bars, use categories |
| Projects showcase | ✅ 3-5 curated with detail | ✅ Archetype + detail pages | Use creations/ for original work |
| GitHub integration | ✅ Link to repos | ✅ Social handle | Link to top repos |
| LinkedIn presence | ✅ Profile link | ✅ Social handle | Ensure profile is updated |
| Custom domain | ✅ yourname.com | ✅ Any domain | Secure athandial.com if available |
| Dark mode | ✅ Standard UX | ❌ Not built-in | Implement via custom CSS |
| Search | ⚠️ Nice-to-have | ✅ Built-in fuse.js | Enable once content volume justifies |
| Blog | ⚠️ Optional | ✅ Built-in archetype | Defer until authentic voice research complete |
| Downloadable PDF | ⚠️ Common | ❌ Not built-in | Implement for ATS compatibility |
| Case studies | ⚠️ Rare, differentiating | ❌ Requires custom archetype | High priority for positioning |
| Publications | ⚠️ Academic portfolios | ✅ Built-in archetype | Use for PhD→Product narrative |
| Testimonials | ❌ Anti-pattern | ❌ Not built-in | Skip entirely |
| Skill rating bars | ❌ Anti-pattern | ⚠️ Optional in JSON | Skip, use categories instead |
| CMS integration | ❌ Over-engineered | ✅ Optional Netlify CMS | Skip, markdown editing sufficient |

## Hugo Resume Theme Feature Coverage

### Built-In Features (No Custom Work)

**Content Structure:**
- Single-page resume with auto-scroll navigation
- Work experience timeline (JSON-driven)
- Skills inventory with dev icons (JSON-driven)
- Education background (JSON-driven)
- Project showcases with detail pages (`/creations/` and `/contributions/`)
- Publications section with detail pages
- Blog/writing section (`/blog/` folder)
- Contact information display
- Social media handles (LinkedIn, GitHub, Stack Overflow, Keybase, Bluesky)

**Interactive Features:**
- Client-side search powered by fuse.js at `/search`
- Tag-based content taxonomy
- JSON output format (alongside HTML)
- vCard download for contact info
- QR code display (optional toggle)

**Technical Features:**
- Mobile responsive (Bootstrap-based)
- Multi-language support (EN/FR built-in, extensible)
- Google Analytics integration
- Code syntax highlighting
- Static site generation (fast, secure, low-cost hosting)

**CMS Features (Optional):**
- Netlify CMS integration at `/admin` endpoint
- WYSIWYG editor with markdown commit capability
- Authentication for authorized editing

### Missing Features (Custom Work Required)

**Essential Gaps:**
- Dark mode support (standard UX expectation in 2026)
- Downloadable resume PDF (ATS compatibility)
- Case study archetype (decision evidence format)
- Metrics/outcomes display structure

**Nice-to-Have Gaps:**
- Advanced filtering by tags/categories
- Print-friendly CSS (separate from PDF)
- Image optimization pipeline
- Custom social share cards

## Sources

**Hugo Resume Theme (Official):**
- [Hugo Resume on Hugo Themes](https://themes.gohugo.io/themes/hugo-resume/)
- [Hugo Resume GitHub Repository](https://github.com/eddiewebb/hugo-resume)
- [Hugo Resume README](https://github.com/eddiewebb/hugo-resume/blob/master/README.md)

**Professional Portfolio Best Practices (2026):**
- [How to Create a Software Engineer Portfolio in 2026](https://zencoder.ai/blog/how-to-create-software-engineer-portfolio)
- [UX Portfolio Guide: How Senior Designers Get Hired in 2026](https://uxplaybook.org/articles/senior-ux-designer-portfolio-get-hired-2026)
- [Building a Portfolio That Gets Hired: 2026 Developer Guide](https://www.hakia.com/skills/building-portfolio/)
- [What Recruiters Look for in Developer Portfolios](https://pesto.tech/resources/what-recruiters-look-for-in-developer-portfolios)
- [Best Web Developer Portfolio Examples from Top Developers in 2026](https://elementor.com/blog/best-web-developer-portfolio-examples/)

**Portfolio Anti-Patterns:**
- [Common mistakes when creating a portfolio (and how to avoid them)](https://www.wix.com/blog/common-portfolio-mistakes)
- [5 Common Mistakes in Portfolio Website Content to Avoid](https://www.strikingly.com/blog/posts/5-common-mistakes-portfolio-website-content)
- [12 Things You Should Remove From Your Portfolio Website Immediately](https://mattolpinski.com/articles/fix-your-portfolio/)
- [Five development portfolio anti-patterns and how to avoid them](https://nitor.com/en/articles/five-development-portfolio-anti-patterns-and-how-to-avoid-them)

**Resume Website Credibility (2026):**
- [15 Current Resume Trends for 2026 + Examples](https://www.resume-now.com/job-resources/resumes/resume-trends)
- [11 Resume Trends in 2026 That Hiring Managers Can't Resist](https://novoresume.com/career-blog/resume-trends)

---
*Feature research for: Hugo Resume theme migration for PhD→Product leader portfolio*
*Researched: 2026-02-04*
*Confidence: HIGH (official theme docs + verified portfolio best practices)*
