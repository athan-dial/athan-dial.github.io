# Architecture Research: Hugo Resume Theme Migration

**Domain:** Static site theme migration (Blowfish → Hugo Resume)
**Researched:** 2026-02-04
**Confidence:** HIGH

## Executive Summary

Migrating from Blowfish to Hugo Resume requires fundamental architectural changes. Blowfish is a flexible, Tailwind-based general-purpose theme with `content/` markdown pages. Hugo Resume is a Bootstrap-based single-page resume theme that uses JSON data files (`data/`) + minimal markdown for structured sections.

**Critical insight:** This is not a simple theme swap. Content must be restructured from markdown pages → JSON data files for core resume sections (skills, experience, education). Custom layouts and 1200+ lines of CSS will need complete adaptation to Hugo Resume's Bootstrap foundation.

## Architectural Comparison

### Current: Blowfish Theme

```
┌─────────────────────────────────────────────────────────────┐
│                    BLOWFISH ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────┤
│  Content Layer (Markdown-Driven)                            │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │ _index.md  │  │ resume.md  │  │ case-      │            │
│  │ (homepage) │  │            │  │ studies/   │            │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘            │
│        │               │               │                    │
├────────┴───────────────┴───────────────┴────────────────────┤
│  Configuration Layer (TOML)                                 │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ config/_default/                                     │    │
│  │ ├── hugo.toml (site settings)                        │    │
│  │ ├── params.toml (theme options, 180+ lines)          │    │
│  │ ├── languages.en.toml (metadata)                     │    │
│  │ └── menus.en.toml (navigation)                       │    │
│  └─────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│  Theme Layer (Tailwind CSS + Hugo Modules)                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ - Flexible layouts for any content type              │    │
│  │ - Taxonomy support (tags, categories, series)        │    │
│  │ - Multiple homepage layouts (profile, hero, card)    │    │
│  │ - Article/list views with advanced features          │    │
│  └─────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│  Customization Layer                                        │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ assets/css/custom.css (1216 lines)                   │    │
│  │ - Apple-inspired design system                        │    │
│  │ - Custom CSS variables                                │    │
│  │ - Heavy !important overrides                          │    │
│  │                                                       │    │
│  │ layouts/ (custom partials)                            │    │
│  │ - case-study-card.html                                │    │
│  │ - case-study-section.html                             │    │
│  │ - proof-tile.html                                     │    │
│  │ - case-studies/list.html                              │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Target: Hugo Resume Theme

```
┌─────────────────────────────────────────────────────────────┐
│                   HUGO RESUME ARCHITECTURE                   │
├─────────────────────────────────────────────────────────────┤
│  Single-Page Navigation Layer                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │ Auto-scrolling sections with left-hand nav         │     │
│  │ - #about → #skills → #experience → #education      │     │
│  │ - #projects → #publications → #blog                │     │
│  └────────────────────────────────────────────────────┘     │
├─────────────────────────────────────────────────────────────┤
│  Data-Driven Content Layer (JSON)                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ skills.json  │  │experience.json│  │education.json│      │
│  │              │  │               │  │              │      │
│  │ [{           │  │ [{            │  │ [{           │      │
│  │  "grouping": │  │  "role": "",  │  │  "degree": "",│     │
│  │  "skills": []│  │  "company":"",│  │  "school": "",│     │
│  │ }]           │  │  "summary":"",│  │  "range": "" │      │
│  │              │  │  "range": ""  │  │ }]           │      │
│  │              │  │ }]            │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│  Markdown Content Layer (Detail Pages)                      │
│  ┌───────────────────────────────────────────────────┐      │
│  │ content/                                           │      │
│  │ ├── _index.md (main bio/summary)                  │      │
│  │ ├── projects/                                      │      │
│  │ │   ├── creations/ (originator role)              │      │
│  │ │   └── contributions/ (collaborator role)        │      │
│  │ ├── publications/ (papers, speaking, articles)    │      │
│  │ └── blog/ (NOT posts/)                            │      │
│  └───────────────────────────────────────────────────┘      │
├─────────────────────────────────────────────────────────────┤
│  Configuration Layer (Single config.toml)                   │
│  ┌───────────────────────────────────────────────────┐      │
│  │ [params]                                           │      │
│  │ - firstName, lastName, email, phone, address       │      │
│  │ - profileImage, favicon                            │      │
│  │ - sections = ["skills", "experience", etc]         │      │
│  │ - showQr, showContact, showBoards, etc             │      │
│  │ - [[params.handles]] (social links)                │      │
│  │ - vcardfields (contact export)                     │      │
│  └───────────────────────────────────────────────────┘      │
├─────────────────────────────────────────────────────────────┤
│  Theme Layer (Bootstrap 4 + StartBootstrap Resume)          │
│  ┌───────────────────────────────────────────────────┐      │
│  │ - Fixed single-page layout                         │      │
│  │ - Left navigation with auto-scroll                 │      │
│  │ - Client-side search (fuse.js at /search)          │      │
│  │ - Optional Netlify CMS (/admin endpoint)           │      │
│  │ - vCard export (.vcf format)                       │      │
│  └───────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Key Architectural Differences

| Aspect | Blowfish (Current) | Hugo Resume (Target) | Migration Impact |
|--------|-------------------|---------------------|-----------------|
| **Content Model** | Markdown pages (`content/*.md`) | JSON data files (`data/*.json`) + minimal markdown | **CRITICAL**: Requires content restructuring |
| **Layout Philosophy** | Multi-page site with flexible layouts | Single-page with auto-scroll sections | **HIGH**: Entire site structure changes |
| **Configuration** | Split across 4 TOML files in `config/_default/` | Single `config.toml` with `[params]` section | **MEDIUM**: Config consolidation needed |
| **CSS Framework** | Tailwind CSS 3.0 (utility-first) | Bootstrap 4 (component-based) | **HIGH**: 1216 lines custom CSS needs rewrite |
| **Theme Customization** | Hugo Modules (go.mod) | Git submodule, Hugo Module, or manual | **LOW**: Different install method |
| **Navigation** | Menu defined in `menus.en.toml` | Auto-generated from sections array | **MEDIUM**: Nav logic changes |
| **Content Types** | Flexible (any content type) | Fixed (skills, experience, education, projects, publications, blog) | **HIGH**: Constrained content model |
| **Custom Layouts** | 4 custom partials + 1 list layout | Must override Bootstrap layouts | **HIGH**: All custom layouts incompatible |
| **Case Studies** | First-class content type with grid view | Not a native concept (would use projects or publications) | **CRITICAL**: Feature gap |
| **Homepage** | Markdown with HTML (proof tiles) | Bio from `_index.md` + data-driven sections | **HIGH**: Homepage rewrite required |

## Content Structure Migration Map

### Phase 1: Core Resume Sections (V1 Scope)

#### Skills Migration

**Current (Blowfish):**
```markdown
content/resume.md:
---
title: "Resume"
---

## Skills
- Python, R, SQL
- Machine learning frameworks
- Data visualization
```

**Target (Hugo Resume):**
```json
data/skills.json:
[
  {
    "grouping": "Programming Languages",
    "skills": [
      {"name": "Python", "icon": "python", "link": "https://python.org"},
      {"name": "R", "icon": "r"},
      "SQL"
    ]
  },
  {
    "grouping": "Machine Learning",
    "skills": [
      "PyTorch",
      "Scikit-learn",
      "TensorFlow"
    ]
  }
]
```

**Migration complexity:** MEDIUM
- Requires manual restructuring from prose → structured JSON
- Skills can be simple strings or objects with icon/link
- Grouping provides logical organization

#### Experience Migration

**Current (Blowfish):**
```markdown
content/resume.md:
---
title: "Resume"
---

## Experience

### Senior Data Scientist, Montai
February 2023 - Present

- Led development of ML systems
- Reduced pipeline latency by 40%
```

**Target (Hugo Resume):**
```json
data/experience.json:
[
  {
    "role": "Senior Data Scientist",
    "company": "Montai",
    "summary": "Led development of ML systems.\n- Reduced pipeline latency by 40%\n- Established evaluation frameworks",
    "range": "February 2023 - Present"
  }
]
```

**Migration complexity:** LOW
- Straightforward mapping from markdown sections → JSON objects
- Summary field supports `\n` for line breaks
- Bullet lists can be preserved with `\n-` formatting

#### Education Migration

**Current (Blowfish):**
```markdown
content/resume.md:

## Education

### PhD in Bioinformatics
University of Example, 2015-2020
```

**Target (Hugo Resume):**
```json
data/education.json:
[
  {
    "degree": "PhD in Bioinformatics",
    "school": "University of Example",
    "range": "2015 - 2020"
  }
]
```

**Migration complexity:** LOW
- Simple 3-field structure
- Direct mapping from markdown content

#### About/Bio Migration

**Current (Blowfish):**
```markdown
content/_index.md:
---
title: "Athan Dial, PhD"
---

# Athan Dial, PhD

**PhD-trained in multi-omics analysis...**
```

**Target (Hugo Resume):**
```markdown
content/_index.md:
---
title: "Athan Dial, PhD"
---

PhD-trained in multi-omics analysis. Product-tested in drug discovery ML.

I combine product judgment with technical depth to turn ambiguous
problems into decision systems...
```

**Migration complexity:** LOW
- Same file location, simplified content
- Remove custom HTML (proof tiles) for V1
- Focus on concise bio text

#### Contact Information

**Current (Blowfish):**
```toml
config/_default/languages.en.toml:
[author]
  name = "Athan Dial"
  email = "athan@example.com"
```

**Target (Hugo Resume):**
```toml
config.toml:
[params]
  firstName = "Athan"
  lastName = "Dial"
  email = "athan@example.com"
  phone = "555-555-5555"
  address = "City, State"
  profileImage = "img/profile.jpg"
```

**Migration complexity:** LOW
- Config consolidation
- More granular contact fields

### Phase 2: Deferred Features (V2 Scope)

#### Case Studies → Projects

**Current (Blowfish):**
```
content/case-studies/
├── preventing-metric-theater.md
├── reducing-pipeline-latency.md
└── scaling-ai-nominations.md

Custom layouts:
layouts/case-studies/list.html (grid view)
layouts/partials/case-study-card.html
layouts/partials/case-study-section.html
```

**Target (Hugo Resume):**
```
content/projects/
├── creations/ (originator role)
│   └── decision-velocity-framework.md
└── contributions/ (collaborator role)
    └── ml-evaluation-system.md
```

**Migration complexity:** HIGH
- Case studies map to either "creations" or "contributions" projects
- Must rewrite frontmatter to Hugo Resume archetype format
- Custom grid layout incompatible (Hugo Resume uses list view)
- Lose case study-specific metadata (problem_type, scope, complexity)
- Content structure (Context → Ownership → Decision Frame → Outcome → Reflection) can be preserved in markdown body

**Decision:** DEFER to V2
- V1 focuses on resume content only
- Case studies require design decisions about how to adapt custom UI

## Data Flow Comparison

### Current (Blowfish) Content Rendering Flow

```
User Request
    ↓
Hugo Router → content/resume.md (frontmatter + markdown)
    ↓
Blowfish Theme Layouts
    ↓
├── layouts/_default/single.html
├── assets/css/compiled.css (Tailwind)
└── assets/css/custom.css (1216 lines, loaded after)
    ↓
HTML Output (multi-page site)
```

### Target (Hugo Resume) Content Rendering Flow

```
User Request
    ↓
Hugo Router → content/_index.md (bio only)
    ↓
Hugo Resume Theme Layouts
    ↓
├── layouts/index.html (single-page template)
│   ├── Sections loop: {{ range .Site.Params.sections }}
│   │   ├── "skills" → reads data/skills.json
│   │   ├── "experience" → reads data/experience.json
│   │   └── "education" → reads data/education.json
│   ├── Projects: range where "Type" "eq" "projects"
│   └── Publications: range where "Type" "eq" "publications"
└── assets/css/bootstrap.min.css + resume.css
    ↓
HTML Output (single-page with anchor sections)
```

**Key difference:** Hugo Resume templates directly reference `.Site.Data.*` for structured content, while Blowfish renders markdown content through flexible layouts.

## Architectural Patterns

### Pattern 1: Data-Driven Content Sections

**What:** Hugo Resume uses JSON files in `data/` to populate homepage sections (skills, experience, education). Templates access via `.Site.Data.skills`, `.Site.Data.experience`, etc.

**When to use:** For structured, repeating content that benefits from schema validation and separation of data from presentation.

**Trade-offs:**
- ✅ Pro: Clean separation of content (data) and presentation (templates)
- ✅ Pro: JSON schema makes content structure explicit
- ✅ Pro: CMS integration easier with structured data
- ❌ Con: Less flexible than markdown (can't easily add custom sections)
- ❌ Con: Requires JSON editing (no prose/markdown richness)
- ❌ Con: Hard to version control narrative changes (diffs show JSON structure noise)

**Example:**
```go-html-template
{{ range .Site.Data.experience }}
  <div class="resume-item">
    <h3 class="resume-title">{{ .role }}</h3>
    <div class="resume-company">{{ .company }}</div>
    <div class="resume-date">{{ .range }}</div>
    <div class="resume-summary">{{ .summary | markdownify }}</div>
  </div>
{{ end }}
```

**Migration application:** V1 requires converting `content/resume.md` prose sections → `data/*.json` structured data.

### Pattern 2: Archetype-Based Content Creation

**What:** Hugo Resume provides archetypes (templates) for projects and publications. Use `hugo new projects/creations/name.md` to scaffold with correct frontmatter structure.

**When to use:** When creating new project or publication entries to ensure consistent metadata.

**Trade-offs:**
- ✅ Pro: Enforces frontmatter consistency
- ✅ Pro: Faster content creation (no need to remember required fields)
- ❌ Con: Less flexible than freeform markdown
- ❌ Con: Must learn archetype conventions

**Example:**
```bash
# Create new project
hugo new projects/creations/ml-pipeline.md

# Generates:
---
title: "ML Pipeline"
date: 2026-02-04
draft: true
image: ""
alt: ""
color: ""
link: ""
description: ""
---
```

**Migration application:** V2 case studies migration would use project archetypes. Current case study frontmatter must be mapped to project archetype fields.

### Pattern 3: Section-Based Navigation

**What:** Hugo Resume auto-generates left-hand navigation from `params.sections` array. Each section corresponds to either a data file (skills, experience, education) or a content type (projects, publications, blog).

**When to use:** For single-page layouts where sections should be accessible via anchor links (#skills, #experience).

**Trade-offs:**
- ✅ Pro: No manual menu configuration (DRY principle)
- ✅ Pro: Auto-scrolling navigation enhances UX
- ❌ Con: Fixed section types (can't easily add custom sections)
- ❌ Con: Single-page layout limits content organization flexibility

**Example:**
```toml
[params]
sections = ["skills", "experience", "education", "projects", "publications"]

# Auto-generates nav:
# <nav>
#   <a href="#skills">Skills</a>
#   <a href="#experience">Experience</a>
#   <a href="#education">Education</a>
#   <a href="#projects">Projects</a>
#   <a href="#publications">Publications</a>
# </nav>
```

**Migration application:** Replaces Blowfish's `menus.en.toml` explicit menu configuration. Requires consolidating multi-page site → single-page sections.

### Pattern 4: Hugo's Template Lookup Order for Overrides

**What:** Hugo resolves templates by checking project-level `layouts/` before falling back to theme `themes/hugo-resume/layouts/`. This allows selective theme customization without modifying theme files.

**When to use:** To override specific theme templates (e.g., navbar, footer, section layouts) while preserving theme upgrade path.

**Trade-offs:**
- ✅ Pro: Theme can be updated independently of customizations
- ✅ Pro: Explicit override locations (easy to audit customizations)
- ✅ Pro: Partial overrides supported (override one template, keep rest)
- ❌ Con: Must understand theme's template structure to know what to override
- ❌ Con: Breaking changes in theme updates may require updating overrides

**Example:**
```
layouts/
├── _default/
│   └── single.html        # Overrides theme's single.html for all content
├── projects/
│   └── single.html        # Overrides only for projects
└── partials/
    └── head.html          # Overrides <head> content (e.g., for custom CSS)
```

**Migration application:**
- Custom CSS: Create `layouts/partials/head.html` to inject `<link>` to custom stylesheet
- Case studies (V2): Override `layouts/projects/list.html` and `layouts/projects/single.html` for custom grid/card layouts

## Anti-Patterns to Avoid

### Anti-Pattern 1: Modifying Theme Files Directly

**What people do:** Clone Hugo Resume into `themes/hugo-resume/` and edit files directly (e.g., `themes/hugo-resume/layouts/index.html`, `themes/hugo-resume/static/css/resume.css`).

**Why it's wrong:**
- Breaks theme upgrade path (git pull conflicts)
- Mixes customizations with theme code (hard to audit what was changed)
- No clear ownership boundary (which changes are "yours" vs theme's)

**Do this instead:**
1. Install theme as Hugo Module or git submodule (never edit theme directory)
2. Override specific files in project-level `layouts/` or `static/`
3. Document overrides in `.planning/` or comments

**Example:**
```bash
# ❌ WRONG
vim themes/hugo-resume/layouts/index.html

# ✅ CORRECT
# Copy theme template to project layouts/
mkdir -p layouts
cp themes/hugo-resume/layouts/index.html layouts/index.html
vim layouts/index.html  # Edit project copy, not theme file
```

### Anti-Pattern 2: Mixing Markdown and JSON for Same Content Type

**What people do:** Keep some experience entries in `data/experience.json` and others in `content/experience/*.md` markdown files.

**Why it's wrong:**
- Hugo Resume templates expect consistent data sources (either JSON *or* markdown, not both)
- Creates maintenance burden (two places to update experience)
- Templates may not render mixed sources correctly

**Do this instead:**
- Choose one content model per section:
  - **Structured sections** (skills, experience, education) → JSON in `data/`
  - **Narrative sections** (projects, publications, blog) → Markdown in `content/`
- If JSON schema feels limiting, consider whether Hugo Resume is the right theme (Blowfish offers more flexibility)

### Anti-Pattern 3: Excessive !important in Custom CSS

**What people do:** Override Bootstrap styles with `!important` everywhere to force custom design.

**Why it's wrong:**
- Creates specificity wars (next override needs more !important)
- Breaks Bootstrap's responsive utilities (may need to override every breakpoint)
- Hard to debug (can't tell which rule is winning)
- Makes future Bootstrap updates risky

**Do this instead:**
1. **Override variables:** Hugo Resume may expose Bootstrap SCSS variables (check theme docs). Recompile with custom values.
2. **Add custom classes:** Instead of overriding `.resume-item`, create `.resume-item--custom` with your styles.
3. **Use higher specificity selectively:** `.resume-section .resume-item { }` is more specific without `!important`.
4. **Load custom CSS last:** Ensure `layouts/partials/head.html` loads custom stylesheet *after* Bootstrap/theme CSS.

**Example:**
```css
/* ❌ WRONG */
.resume-item { color: red !important; }
h3 { font-size: 24px !important; }

/* ✅ CORRECT */
.resume-item { color: var(--text-primary); }  /* Use CSS variables */
.resume-item h3 { font-size: 1.5rem; }        /* Scope overrides */
```

**Migration concern:** Current `custom.css` uses 1216 lines with heavy `!important` usage to override Tailwind/Blowfish. This approach will be even more problematic with Bootstrap's component classes. Consider clean-slate CSS rewrite for Hugo Resume.

### Anti-Pattern 4: Storing Resume Content in config.toml

**What people do:** Put entire job descriptions, skill lists, education details in `[params]` within `config.toml`.

**Why it's wrong:**
- Config file becomes huge and unmanageable
- No content versioning (config changes trigger full site rebuild)
- Violates separation of concerns (config = settings, content = data)
- Can't leverage Hugo's content management features (drafts, dates, taxonomies)

**Do this instead:**
- Use `data/*.json` for structured resume content (skills, experience, education)
- Use `content/*.md` for narrative content (projects, publications, blog)
- Reserve `config.toml` `[params]` for settings only (display options, contact info, feature flags)

**Example:**
```toml
# ❌ WRONG
[params]
experience = """
Senior Data Scientist at Montai
February 2023 - Present
Led development of ML systems.
Reduced pipeline latency by 40%.
"""

# ✅ CORRECT
# config.toml:
[params]
firstName = "Athan"
lastName = "Dial"
sections = ["skills", "experience", "education"]

# data/experience.json:
[
  {
    "role": "Senior Data Scientist",
    "company": "Montai",
    "summary": "Led development of ML systems.\n- Reduced pipeline latency by 40%",
    "range": "February 2023 - Present"
  }
]
```

## Migration Strategy

### V1: Core Resume (MVP)

**Goal:** Launch functional resume site with Hugo Resume theme.

**Scope:**
- Skills, experience, education (data-driven)
- About/bio (markdown)
- Contact information (config)
- Basic styling (minimal CSS overrides)

**Migration sequence:**

1. **Install Hugo Resume theme** (Hugo Module or git submodule)
   - Add to `go.mod`: `require github.com/eddiewebb/hugo-resume v1.0.0`
   - Or: `git submodule add https://github.com/eddiewebb/hugo-resume.git themes/hugo-resume`

2. **Create data files** (content transformation)
   - Extract skills from `content/resume.md` → `data/skills.json`
   - Extract experience from `content/resume.md` → `data/experience.json`
   - Extract education from `content/resume.md` → `data/education.json`

3. **Simplify content/_index.md** (bio only)
   - Remove proof tiles HTML
   - Keep concise bio paragraph
   - Add professional summary

4. **Consolidate config.toml** (settings migration)
   - Merge `config/_default/*.toml` → single `config.toml`
   - Map `languages.en.toml` author info → `[params]` firstName/lastName/email
   - Convert `menus.en.toml` items → `params.sections` array
   - Remove Blowfish-specific params (colorScheme, homepage.layout, etc.)

5. **Create basic custom.css override** (styling foundation)
   - Create `layouts/partials/head.html` to inject custom stylesheet
   - Create `static/css/custom.css` with minimal overrides (colors, fonts, spacing)
   - Start clean (don't port 1216-line Blowfish overrides wholesale)

6. **Test and validate**
   - `hugo server` and verify all sections render
   - Check responsive behavior (mobile, tablet, desktop)
   - Validate vCard export works (.vcf download)
   - Test search functionality (/search)

**Preservation strategy:**
- Keep `content/case-studies/` folder intact (inactive, not linked in nav)
- Keep `layouts/case-studies/` custom layouts (for V2 reference)
- Archive Blowfish config: `mv config/_default config/_default.bak`

**Dependencies:**
- Skills JSON schema understanding (see Sources below)
- Experience JSON schema (4 required fields: role, company, summary, range)
- Education JSON schema (3 required fields: degree, school, range)

### V2: Case Studies & Advanced Features

**Goal:** Add decision portfolio (case studies) with custom design.

**Scope:**
- Migrate case studies → projects (creations or contributions)
- Reimplement custom card/grid layouts
- Add proof tiles or equivalent homepage feature
- Restore full custom CSS design system

**Migration sequence:**

1. **Map case studies to projects**
   - Decision: Classify each case study as "creation" or "contribution"
   - Use `hugo new projects/creations/name.md` archetype
   - Map frontmatter: `problem_type` → custom field, `scope` → custom field
   - Preserve content structure (Context → Ownership → Decision Frame → Outcome → Reflection)

2. **Override project layouts**
   - Create `layouts/projects/list.html` (case study grid)
   - Create `layouts/projects/single.html` (case study detail page)
   - Create `layouts/partials/case-study-card.html` (reuse existing)

3. **Restore homepage proof tiles**
   - Create `layouts/index.html` (override Hugo Resume homepage)
   - Integrate proof tiles HTML from `content/_index.md` (Blowfish version)
   - Style with custom CSS

4. **Reimplement custom design system**
   - Port CSS variables from Blowfish `custom.css` (1216 lines)
   - Adapt to Bootstrap 4 classes (not Tailwind utilities)
   - Test light/dark mode (if desired)

**Risks:**
- Hugo Resume's single-page layout may conflict with multi-page case studies
- Bootstrap 4 component classes may require extensive overrides
- Auto-scroll navigation may feel constrained for portfolio use case

**Alternative consideration:** If V2 proves too complex, consider sticking with Blowfish or exploring hybrid approach (Hugo Resume for resume, Blowfish for case studies as subdomain/subdirectory).

## Styling Strategy

### Blowfish → Hugo Resume CSS Migration

**Challenge:** Migrating 1216 lines of Tailwind-overriding CSS to Bootstrap-based theme.

**Current approach (Blowfish):**
- Custom CSS loaded *after* Tailwind via Hugo's asset pipeline
- Heavy use of `!important` to override Tailwind utilities
- CSS variables defined in `:root` (115 variables: colors, typography, spacing)
- Apple-inspired design system (Inter font, subtle grays, generous spacing)

**Target approach (Hugo Resume):**
- Hugo Resume uses Bootstrap 4 with `static/css/resume.css`
- Custom CSS must override Bootstrap component classes (`.resume-item`, `.resume-section`)
- Bootstrap's responsive breakpoints differ from Tailwind's

**Migration options:**

#### Option A: Clean Slate (RECOMMENDED for V1)

Start with minimal CSS overrides, add selectively.

**Pros:**
- Avoids porting unnecessary Blowfish-specific styles
- Opportunity to embrace Bootstrap's design system
- Easier to maintain (less CSS = less bugs)

**Cons:**
- Loses current visual brand (Apple-inspired design)
- May require re-establishing design system from scratch

**Implementation:**
1. Create `static/css/custom.css` with core variables only (colors, fonts)
2. Override Bootstrap sparingly (typography, spacing, colors)
3. Test at each step (ensure responsive behavior intact)

**Example:**
```css
/* custom.css (V1: minimal overrides) */
:root {
  --primary-color: #007AFF;
  --text-primary: #1D1D1F;
  --font-sans: 'Inter', -apple-system, sans-serif;
}

body {
  font-family: var(--font-sans);
  color: var(--text-primary);
}

.resume-section h2 {
  color: var(--primary-color);
}
```

#### Option B: Full Port (Deferred to V2)

Port all 1216 lines of Blowfish CSS to Hugo Resume, adapting Tailwind overrides → Bootstrap overrides.

**Pros:**
- Preserves exact visual brand
- Maintains design system consistency
- Less rework if V2 adds more pages

**Cons:**
- HIGH effort (must audit every rule for Bootstrap compatibility)
- Risk of breaking Bootstrap responsive utilities
- May introduce bugs (CSS specificity conflicts)

**Implementation:**
1. Copy `assets/css/custom.css` → `static/css/custom-full.css`
2. Replace Tailwind utility selectors → Bootstrap component selectors
3. Test extensively (all breakpoints, light/dark mode)

**Example:**
```css
/* Tailwind utility override (Blowfish) */
.prose { font-family: var(--font-serif) !important; }

/* Bootstrap component override (Hugo Resume) */
.resume-item-description { font-family: var(--font-serif); }
```

#### Option C: Hybrid (CSS Variables + Selective Overrides)

Define CSS variables in custom stylesheet, use Bootstrap's classes but override variable values.

**Pros:**
- Lightweight (define variables, let Bootstrap use them)
- Easy to adjust brand colors/fonts/spacing
- Minimal specificity conflicts

**Cons:**
- Hugo Resume may not expose Bootstrap variables in customizable way
- Requires theme code inspection (which variables are used where)

**Implementation:**
1. Inspect `themes/hugo-resume/static/css/resume.css` for variable usage
2. Define custom variables in `static/css/custom.css`
3. Override Bootstrap variables if theme supports it

**Feasibility:** UNKNOWN (requires inspecting Hugo Resume's CSS architecture). If theme doesn't use CSS variables, this approach won't work.

### Recommendation

**V1:** Use **Option A (Clean Slate)** to launch quickly with minimal CSS. Focus on content correctness, not pixel-perfect design.

**V2:** Evaluate **Option C (Hybrid)** first. If not feasible, use **Option B (Full Port)** for brand consistency.

## Integration Points

### External Services

| Service | Blowfish Support | Hugo Resume Support | Migration Notes |
|---------|-----------------|-------------------|-----------------|
| **Google Analytics** | ✅ `googleAnalytics` in `hugo.toml` | ✅ `[params.google.analytics]` in `config.toml` | Move tracker ID to params section |
| **Search** | ❌ Not built-in | ✅ Fuse.js at `/search` | Hugo Resume provides client-side search automatically |
| **CMS** | ❌ Not built-in | ✅ Netlify CMS at `/admin` | Optional feature, requires configuration |
| **vCard Export** | ❌ Not built-in | ✅ `.vcf` download | Hugo Resume outputs vCard format for contact sharing |
| **Social Handles** | ✅ `[author.social]` in `languages.en.toml` | ✅ `[[params.handles]]` in `config.toml` | Migrate to params.handles array with name/link/icon |
| **RSS Feeds** | ✅ Built-in Hugo RSS | ✅ Built-in Hugo RSS | No changes needed |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| **Data → Templates** | `.Site.Data.*` access | Templates directly read JSON files from `data/` |
| **Content → Templates** | `.Pages` iteration | Templates iterate over `content/` markdown files |
| **Config → Templates** | `.Site.Params.*` access | Templates read settings from `[params]` section |
| **Partials → Layouts** | `{{ partial "name" . }}` | Layouts compose partials (navbar, footer, head, etc.) |
| **Custom CSS → Theme CSS** | Cascading order | Custom CSS loaded after theme CSS (override via specificity) |

**Migration boundary risk:** Blowfish custom partials (`case-study-card.html`, `proof-tile.html`) won't work in Hugo Resume without layout overrides. Must reimplement using Hugo Resume's partial structure.

## Confidence Assessment

| Area | Confidence | Sources |
|------|-----------|---------|
| Hugo Resume architecture | HIGH | Official GitHub repo, exampleSite, JSON schemas inspected |
| Content migration path | HIGH | Clear mapping: markdown → JSON for data, markdown preserved for narrative |
| Config consolidation | HIGH | `config.toml` structure documented, params clear |
| Custom CSS migration | MEDIUM | No Hugo Resume CSS variable documentation found; requires code inspection |
| Case study migration (V2) | MEDIUM | Projects archetype exists, but custom layouts require overrides |
| Single-page layout fit | LOW | Uncertainty whether single-page navigation suits portfolio use case |

## Open Questions

1. **Does Hugo Resume expose Bootstrap SCSS variables for customization?**
   - Impact: Determines CSS migration strategy (Option C feasibility)
   - Mitigation: Inspect `themes/hugo-resume/assets/` or `static/css/` for SCSS source files

2. **Can Hugo Resume's single-page layout support multi-page "detail" sections?**
   - Impact: Case studies (V2) may need to break single-page paradigm
   - Mitigation: Test creating `layouts/projects/single.html` as full-page layout (not anchor section)

3. **How to preserve proof tiles on homepage with Hugo Resume's auto-generated sections?**
   - Impact: Homepage branding (key differentiator in current Blowfish site)
   - Mitigation: Override `layouts/index.html` entirely with custom implementation

4. **Is the single-page resume layout optimal for a "decision portfolio" positioning?**
   - Impact: May feel constrained vs. current multi-page Blowfish site
   - Mitigation: Consider whether Hugo Resume is the right theme choice, or if Blowfish should be retained

## Sources

### HIGH Confidence (Official Documentation)

- [Hugo Resume GitHub Repository](https://github.com/eddiewebb/hugo-resume) - Theme architecture, features, installation
- [Hugo Resume exampleSite](https://github.com/eddiewebb/hugo-resume/tree/master/exampleSite) - Directory structure reference
- [experience.json Schema](https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/data/experience.json) - JSON structure for experience data
- [skills.json Schema](https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/data/skills.json) - JSON structure for skills data
- [config.toml Example](https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/config.toml) - Configuration parameters
- [Hugo Resume README](https://github.com/eddiewebb/hugo-resume/blob/master/README.md) - Content structure, archetypes, migration tips

### MEDIUM Confidence (Community Resources)

- [Hugo Theme Customization Guide](https://bwaycer.github.io/hugo_tutorial.hugo/themes/customizing/) - Template override patterns
- [How to override CSS in Hugo](https://discourse.gohugo.io/t/how-to-override-css-classes-with-hugo/3033) - CSS override strategies
- [Hugo Data Files Documentation](https://bwaycer.github.io/hugo_tutorial.hugo/extras/datafiles/) - Using YAML/JSON data in Hugo
- [Using Hugo Structured Data to Build a Resume Page](https://aldra.co/blog/hugo_structured_data/) - Data-driven resume approach
- [Overriding theme partials](https://discourse.gohugo.io/t/how-to-override-a-themes-partials/47227) - Partial override best practices

### LOW Confidence (Inferred from Theme Code)

- CSS customization approach (requires inspecting theme source for SCSS variables)
- Case study layout compatibility (requires testing project overrides)

---

**Architecture Research for:** Hugo Resume Theme Migration
**Researched:** 2026-02-04
**Confidence:** HIGH (core architecture), MEDIUM (CSS migration), LOW (single-page fit)
