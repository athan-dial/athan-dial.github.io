# Phase 2: Content & Styling - Research

**Researched:** 2026-02-05
**Domain:** Hugo Resume theme content population and custom CSS styling
**Confidence:** HIGH

## Summary

Hugo Resume theme uses JSON data files (experience.json, skills.json, education.json) for content structure, combined with content/_index.md for biography. The theme is built on Bootstrap and exposes extensive customization options through config params. Custom CSS overrides follow Hugo's standard patterns: place files in assets/ for Hugo Pipes processing (fingerprinting, minification) or static/ for direct copying.

Dark mode implementation requires CSS custom properties approach with JavaScript toggle and localStorage persistence. Bootstrap 5.3+ provides first-class dark mode support via data-bs-theme attribute and CSS variables, making it straightforward to implement theme switching. Typography alternatives for executive positioning include Proxima Nova, Brandon Grotesque, and Helvetica for minimal elegance. Icon systems have moved from icon fonts to SVG-based solutions like Iconify (200k+ icons) or direct SVG implementation.

CareerCanvas layout patterns emphasize single-scroll structure with alternating content density, icon-driven section headers, and narrative flow over traditional segmentation. For senior leadership positioning, content must demonstrate scope (team size, budget) and measurable impact (revenue growth, cost reduction percentages) within 2-3 sentence narrative summaries per role.

**Primary recommendation:** Use Hugo Resume's JSON data schema as-is for content structure, implement custom CSS via assets/css/custom.css with Hugo Pipes processing, adopt Bootstrap 5 data-bs-theme approach for dark mode, and structure experience narratives to show scope + impact in paragraph format rather than bullet lists.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Hugo Resume theme | master | Single-page resume template | Bootstrap-based, JSON data-driven, well-maintained |
| Bootstrap | (via theme) | Responsive framework | Theme foundation, provides dark mode infrastructure |
| Hugo Pipes | Hugo 0.154.3+ | Asset processing | Fingerprinting, minification, SRI for CSS/JS |
| JSON data files | - | Content storage | Theme's native content architecture |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Iconify | 200k+ icons | Icon system | Section headers, skill indicators, social links |
| Font Awesome | (via theme) | Icon fallback | Already included in theme for social handles |
| CSS Custom Properties | - | Dark mode theming | Color scheme switching, brand customization |
| localStorage API | - | Theme persistence | Remember user's light/dark mode preference |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| JSON data files | Markdown frontmatter | Would require custom theme templates, loses theme compatibility |
| Iconify SVG | Font Awesome icons | Icon fonts deprecated for modern web, SVG preferred |
| Bootstrap dark mode | Custom CSS classes | Bootstrap 5.3+ provides first-class support, reinventing is waste |
| assets/ directory | static/ directory | Loses Hugo Pipes benefits (fingerprinting, minification, SRI) |

**Installation:**
```bash
# No additional packages needed - theme includes Bootstrap and Font Awesome
# Custom CSS added directly to assets/css/custom.css
# Self-hosted fonts added to static/fonts/ directory
```

## Architecture Patterns

### Hugo Resume Content Structure
```
content/
└── _index.md              # Biography/summary (2-3 sentence intro)

data/
├── experience.json        # Work history with narrative summaries
├── education.json         # Degrees, certifications
├── skills.json            # Skill categories with groupings
├── certifications.json    # Optional certifications
└── boards.json            # Optional board memberships

static/
├── fonts/                 # Self-hosted typography files
│   ├── font-name.woff2
│   └── font-name.woff
└── img/
    └── profile.jpg        # Profile image

assets/
└── css/
    └── custom.css         # Custom styling (processed by Hugo Pipes)

config/_default/
├── hugo.toml              # Base config (preserve baseURL, publishDir)
├── params.toml            # Theme params (moved from hugo.toml for clarity)
└── module.toml            # Theme import
```

### Pattern 1: Experience Data Schema
**What:** JSON array with role, company, summary, range fields
**When to use:** All work history including PhD research positions
**Example:**
```json
[
  {
    "role": "Director of Product",
    "company": "Company Name",
    "summary": "Led cross-functional team of 12 engineers and data scientists building ML-powered drug discovery platform. Increased decision velocity 40% through learning agenda framework while reducing pipeline latency from 6 weeks to 2 weeks. Managed $5M annual budget and roadmap across 3 product lines.",
    "range": "January 2023 - Present"
  },
  {
    "role": "PhD Researcher",
    "company": "University Name",
    "summary": "Developed computational methods for analyzing biological networks. Transitioned from academic research to product leadership by applying experimental design principles to product strategy and quantitative analysis to user behavior. Published 5 papers in top-tier journals.",
    "range": "2015 - 2019"
  }
]
```
**Source:** https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/data/experience.json

### Pattern 2: Skills Data Schema with Proficiency Indicators
**What:** Grouped skills with optional icon and link metadata
**When to use:** Organizing skills by domain (Data Science, Product, Tools)
**Example:**
```json
[
  {
    "grouping": "Product Leadership",
    "skills": [
      {
        "name": "Learning Agenda Design",
        "icon": "flask"
      },
      {
        "name": "Roadmap Strategy"
      },
      "Cross-functional Leadership",
      "Stakeholder Alignment"
    ]
  },
  {
    "grouping": "Data Science & ML",
    "skills": [
      {
        "name": "Python",
        "link": "https://python.org"
      },
      {
        "name": "TensorFlow",
        "icon": "brain"
      },
      "Statistical Analysis",
      "Experiment Design"
    ]
  }
]
```
**Source:** https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/data/skills.json

**Note:** Skills can be strings (simple) or objects with name/icon/link properties (enhanced). Icons reference Font Awesome or custom icon identifiers.

### Pattern 3: Education Data Schema
**What:** School, degree, major, notes, range fields (notes optional)
**When to use:** All degrees and certifications
**Example:**
```json
[
  {
    "school": "[University Name](https://university.edu)",
    "degree": "PhD",
    "major": "Computational Biology",
    "notes": "Dissertation on network analysis methods. Transitioned research skills to product leadership.",
    "range": "2015 - 2019"
  },
  {
    "school": "University Name",
    "degree": "Bachelor of Science",
    "major": "Computer Science",
    "range": "2011 - 2015"
  }
]
```
**Source:** https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/data/education.json

**Note:** School field supports markdown for links. Notes field is optional but useful for PhD → Product narrative.

### Pattern 4: Custom CSS via Hugo Pipes
**What:** Place custom.css in assets/, reference via partial template with Hugo Pipes
**When to use:** All custom styling, dark mode, typography overrides
**Example:**
```css
/* assets/css/custom.css */

/* CSS Variables for Light Mode */
:root {
  --color-primary: #1E3A5F;        /* Executive blue accent */
  --color-bg-light: #FFFFFF;
  --color-text-light: #1D1D1F;     /* Near-black */
  --color-text-secondary: #86868B; /* Apple-style gray */
  --color-border: #AEAEB2;         /* Subtle borders */
}

/* CSS Variables for Dark Mode */
[data-bs-theme="dark"] {
  --color-primary: #4A90E2;        /* Brighter blue for dark mode */
  --color-bg-dark: #1D1D1F;
  --color-text-dark: #F5F5F7;
  --color-text-secondary: #AEAEB2;
  --color-border: #48484A;
}

/* Apply custom colors */
body {
  background-color: var(--color-bg-light);
  color: var(--color-text-light);
}

[data-bs-theme="dark"] body {
  background-color: var(--color-bg-dark);
  color: var(--color-text-dark);
}

/* Section headers with custom styling */
.section-heading {
  color: var(--color-primary);
  border-bottom: 2px solid var(--color-primary);
}
```
**Source:** https://gohugo.io/functions/css/sass/ and https://www.brycewray.com/posts/2023/03/styling-hugo-site/

### Pattern 5: Bootstrap 5 Dark Mode Implementation
**What:** Use data-bs-theme attribute with JavaScript toggle and localStorage
**When to use:** Theme switching with user preference persistence
**Example:**
```html
<!-- Toggle button (add to header partial) -->
<button id="theme-toggle" aria-label="Toggle theme">
  <span class="light-icon">☀️</span>
  <span class="dark-icon">🌙</span>
</button>

<script>
  // Check saved preference or default to light
  const savedTheme = localStorage.getItem('theme') || 'light';
  document.documentElement.setAttribute('data-bs-theme', savedTheme);

  // Toggle handler
  document.getElementById('theme-toggle').addEventListener('click', () => {
    const currentTheme = document.documentElement.getAttribute('data-bs-theme');
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';

    document.documentElement.setAttribute('data-bs-theme', newTheme);
    localStorage.setItem('theme', newTheme);
  });
</script>
```
**Source:** https://getbootstrap.com/docs/5.3/customize/color-modes/ and https://yonkov.github.io/post/add-dark-mode-toggle-to-hugo/

### Pattern 6: Self-Hosted Typography
**What:** Place font files in static/fonts/, reference with @font-face in CSS
**When to use:** Custom typography beyond web-safe fonts
**Example:**
```css
/* assets/css/custom.css */

@font-face {
  font-family: 'Proxima Nova';
  src: url('/fonts/proximanova-regular.woff2') format('woff2'),
       url('/fonts/proximanova-regular.woff') format('woff');
  font-weight: 400;
  font-style: normal;
  font-display: swap;
}

@font-face {
  font-family: 'Proxima Nova';
  src: url('/fonts/proximanova-semibold.woff2') format('woff2'),
       url('/fonts/proximanova-semibold.woff') format('woff');
  font-weight: 600;
  font-style: normal;
  font-display: swap;
}

body {
  font-family: 'Proxima Nova', -apple-system, BlinkMacSystemFont, sans-serif;
}
```
**Source:** https://discourse.gohugo.io/t/how-to-add-custom-fonts-and-not-depend-on-google/34267 and https://www.zerostatic.io/docs/hugo-advance/guides/self-host-fonts/

**Note:** Use /fonts/ path (NOT /static/fonts/), Hugo serves static/ contents at root. Use font-display: swap for performance.

### Pattern 7: Config Customization via params.toml
**What:** Move theme params from hugo.toml to params.toml for clarity
**When to use:** Extensive config requiring personal info, display controls, social links
**Example:**
```toml
# config/_default/params.toml

[params]
  firstName = "Athan"
  lastName = "Dial"
  email = "email@example.com"
  profileImage = "img/profile.jpg"
  favicon = "/favicon.ico"
  showQr = false
  showContact = true

  # Control which sections display
  sections = [
    "skills",
    "experience",
    "education",
    "publications"
  ]

# Social links
[[params.handles]]
  name = "LinkedIn"
  link = "https://www.linkedin.com/in/example/"
  icon = "linkedin"

[[params.handles]]
  name = "GitHub"
  link = "https://github.com/example"
  icon = "github"
```
**Source:** https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/config.toml

### Pattern 8: CareerCanvas-Inspired Section Icons
**What:** Use Iconify or emoji for distinctive section headers
**When to use:** Creating visual rhythm and improving scannability
**Example:**
```html
<!-- In custom partial or _index.md markdown -->
<section id="experience">
  <h2>
    <iconify-icon icon="mdi:briefcase-outline"></iconify-icon>
    Experience
  </h2>
  <!-- experience content -->
</section>

<section id="skills">
  <h2>
    <iconify-icon icon="mdi:brain"></iconify-icon>
    Skills
  </h2>
  <!-- skills content -->
</section>

<!-- Include Iconify web component in head -->
<script src="https://code.iconify.design/iconify-icon/1.0.7/iconify-icon.min.js"></script>
```
**Source:** https://iconify.design/docs/iconify-icon/ and https://felipecordero.com (CareerCanvas demo)

### Anti-Patterns to Avoid
- **Don't modify theme files directly:** Use custom.css and partial overrides in layouts/ directory
- **Don't use icon fonts:** Modern web prefers SVG-based icons (Iconify) over Font Awesome icon fonts
- **Don't place processed CSS in static/:** Use assets/ for CSS that needs minification/fingerprinting
- **Don't create separate dark mode stylesheet:** Use CSS custom properties and Bootstrap's data-bs-theme
- **Don't write bullet-list experience summaries in JSON:** Use narrative paragraphs for executive positioning
- **Don't skip localStorage for theme preference:** Users expect their choice to persist across sessions
- **Don't use relative paths for self-hosted fonts:** Use absolute /fonts/ path (not ../fonts/)

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Dark mode system | Custom CSS classes and toggle logic | Bootstrap 5 data-bs-theme + CSS variables | First-class support, tested, handles edge cases |
| Icon library | Custom SVG sprite sheets | Iconify web component | 200k+ icons from 150+ sets, single unified API |
| Asset fingerprinting | Custom cache-busting scripts | Hugo Pipes with fingerprint | Built-in, handles SRI, integrates with templates |
| Font file format conversion | Manual woff/woff2 generation | Web font generators (Font Squirrel, google-webfonts-helper) | Handles subsetting, format optimization, CSS generation |
| Theme persistence | Custom cookies or session storage | localStorage API | Standard, simple, works across page loads |
| Skills proficiency visualization | Custom CSS progress bars | Theme's icon/link metadata in JSON | Already integrated, consistent styling |

**Key insight:** Hugo Resume theme + Bootstrap 5 provide comprehensive infrastructure for single-page resumes. Custom solutions duplicate tested patterns and create maintenance burden.

## Common Pitfalls

### Pitfall 1: JSON Syntax Errors Breaking Build
**What goes wrong:** Missing comma, trailing comma, or unescaped quotes in JSON files cause Hugo build to fail silently
**Why it happens:** JSON is strict about syntax; hand-editing is error-prone
**How to avoid:** Use JSON linter (jsonlint.com) or VS Code JSON validation before committing. Test build with `hugo server` after every JSON edit.
**Warning signs:** `hugo server` shows blank sections, no error messages in terminal, browser console shows 404 for data

### Pitfall 2: CSS Specificity Wars with Bootstrap
**What goes wrong:** Custom CSS doesn't apply, or requires !important everywhere
**Why it happens:** Bootstrap uses specific selectors; custom.css loaded before Bootstrap, or selectors are too generic
**How to avoid:** Ensure custom.css loads AFTER Bootstrap. Use same or higher specificity as Bootstrap (e.g., .navbar-dark .nav-link instead of .nav-link)
**Warning signs:** Styles work in browser dev tools but not in page, need !important to override

### Pitfall 3: Dark Mode Color Contrast Failures
**What goes wrong:** Text becomes unreadable in dark mode (low contrast)
**Why it happens:** Light mode colors used in dark mode, or insufficient contrast ratios
**How to avoid:** Test all color combinations with WCAG contrast checker. Use separate CSS custom properties for light/dark modes, not inverted colors.
**Warning signs:** Gray text on gray background, blue links invisible on dark background

### Pitfall 4: Font Files Not Loading (404 Errors)
**What goes wrong:** Custom fonts fail to load, fallback to system fonts
**Why it happens:** Incorrect @font-face paths (using relative paths like ../fonts/ or /static/fonts/)
**How to avoid:** Use absolute paths starting with /fonts/ (Hugo serves static/ at root). Check browser network tab for 404s.
**Warning signs:** Browser dev tools shows 404 for font files, fonts render as fallback

### Pitfall 5: localStorage Theme Flashing (FOUC)
**What goes wrong:** Page loads in light mode, then flashes to dark mode on each load
**Why it happens:** Theme detection script runs after page render (placed in footer or async)
**How to avoid:** Inline theme detection script in <head> BEFORE any CSS. Use blocking script to set data-bs-theme attribute immediately.
**Warning signs:** Visible theme flash on every page load, brief white screen in dark mode

### Pitfall 6: Experience Summaries Too Dense or Too Sparse
**What goes wrong:** Paragraph summaries either too long (5+ sentences) or too short (1 sentence without scope/impact)
**Why it happens:** Unclear guidance on narrative structure for senior roles
**How to avoid:** Use 2-3 sentence structure: (1) Scope/responsibility, (2) Key outcomes with metrics, (3) Secondary impact or approach
**Warning signs:** Recruiter feedback "can't see leadership scope" or "too much detail for resume"

### Pitfall 7: PhD Entry Buried in Education Section
**What goes wrong:** PhD research hidden at bottom of page, unique differentiator not visible
**Why it happens:** Following traditional resume format (experience → education)
**How to avoid:** List PhD as experience entry with narrative showing skills transfer to product leadership. Use education section only for degree credentials.
**Warning signs:** Feedback that "we didn't realize you had research background"

### Pitfall 8: Section Ordering Not Optimized for Scan Pattern
**What goes wrong:** Most important content (skills, recent experience) appears below fold
**Why it happens:** Using theme's default section ordering
**How to avoid:** Control section order with params.sections array in config. Place skills → experience → education for product roles.
**Warning signs:** Analytics show high bounce rate, recruiters miss key skills

### Pitfall 9: Icon Accessibility Failures
**What goes wrong:** Screen readers can't interpret icon-only section headers
**Why it happens:** Icons used without accessible text labels
**How to avoid:** Always pair icons with visible text labels. Use aria-label or aria-hidden appropriately. Test with screen reader.
**Warning signs:** Accessibility audit failures, screen reader users confused about section purpose

### Pitfall 10: Asset Fingerprinting Cache Issues
**What goes wrong:** CSS changes don't appear for users with cached version
**Why it happens:** Not using Hugo Pipes fingerprinting, so filename doesn't change
**How to avoid:** Use Hugo Pipes with .Permalink or .RelPermalink to generate fingerprinted filenames
**Warning signs:** "Clear cache to see changes" instructions needed, users see old styles

## Code Examples

Verified patterns from official sources:

### Complete experience.json with Senior Leadership Narrative
```json
[
  {
    "role": "Director of Product",
    "company": "Biotech Company",
    "summary": "Led team of 15 data scientists and engineers building ML-powered drug discovery platform. Increased decision velocity by 40% through systematic learning agenda framework while reducing pipeline latency from 6 weeks to 2 weeks. Managed $8M annual budget across 3 product lines with direct executive stakeholder engagement.",
    "range": "January 2023 - Present"
  },
  {
    "role": "Senior Product Manager",
    "company": "Biotech Company",
    "summary": "Owned end-to-end product strategy for computational biology tools serving 50+ researchers. Defined and executed roadmap balancing technical debt reduction with feature velocity, shipping 12 major releases in 18 months. Built cross-functional alignment framework reducing planning cycles from 4 weeks to 1 week.",
    "range": "March 2020 - December 2022"
  },
  {
    "role": "PhD Researcher in Computational Biology",
    "company": "University Name",
    "summary": "Developed statistical methods for analyzing biological networks. Transferred experimental design rigor to product discovery, quantitative analysis skills to metrics strategy, and systems thinking to technical architecture. Published 6 papers in top-tier journals and presented at 8 international conferences.",
    "range": "September 2015 - February 2020"
  }
]
```
**Source:** https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/data/experience.json (adapted for senior leadership)

**Note:** Each entry follows scope → impact → approach structure. PhD entry explicitly bridges research to product skills.

### Complete skills.json with Domain-Based Categories
```json
[
  {
    "grouping": "Product Leadership",
    "skills": [
      {
        "name": "Learning Agenda Design",
        "icon": "lightbulb"
      },
      "Decision Framework Development",
      "Cross-functional Team Leadership",
      "Executive Stakeholder Management",
      {
        "name": "Roadmap Strategy",
        "icon": "map"
      }
    ]
  },
  {
    "grouping": "Data Science & ML",
    "skills": [
      {
        "name": "Python",
        "link": "https://python.org",
        "icon": "python"
      },
      {
        "name": "R",
        "link": "https://r-project.org"
      },
      "Statistical Analysis",
      "Experiment Design",
      {
        "name": "TensorFlow",
        "icon": "brain"
      }
    ]
  },
  {
    "grouping": "Technical Architecture",
    "skills": [
      "System Design",
      "Data Pipeline Architecture",
      {
        "name": "AWS",
        "link": "https://aws.amazon.com"
      },
      "API Design",
      "Performance Optimization"
    ]
  },
  {
    "grouping": "Tools & Platforms",
    "skills": [
      "Git",
      "Jira",
      "Tableau",
      "SQL",
      "Docker"
    ]
  }
]
```
**Source:** https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/data/skills.json (adapted for product leadership)

### Complete Custom CSS with Dark Mode
```css
/* assets/css/custom.css */

/* ===== CSS VARIABLES ===== */
:root {
  /* Light mode colors */
  --color-primary: #1E3A5F;
  --color-primary-hover: #2A4A75;
  --color-bg: #FFFFFF;
  --color-text: #1D1D1F;
  --color-text-secondary: #86868B;
  --color-border: #AEAEB2;
  --color-card-bg: #F5F5F7;

  /* Typography */
  --font-body: 'Proxima Nova', -apple-system, BlinkMacSystemFont, sans-serif;
  --font-weight-normal: 400;
  --font-weight-semibold: 600;
}

[data-bs-theme="dark"] {
  /* Dark mode colors */
  --color-primary: #4A90E2;
  --color-primary-hover: #5BA3F5;
  --color-bg: #1D1D1F;
  --color-text: #F5F5F7;
  --color-text-secondary: #AEAEB2;
  --color-border: #48484A;
  --color-card-bg: #2C2C2E;
}

/* ===== TYPOGRAPHY ===== */
@font-face {
  font-family: 'Proxima Nova';
  src: url('/fonts/proximanova-regular.woff2') format('woff2');
  font-weight: 400;
  font-style: normal;
  font-display: swap;
}

@font-face {
  font-family: 'Proxima Nova';
  src: url('/fonts/proximanova-semibold.woff2') format('woff2');
  font-weight: 600;
  font-style: normal;
  font-display: swap;
}

body {
  font-family: var(--font-body);
  font-weight: var(--font-weight-normal);
  background-color: var(--color-bg);
  color: var(--color-text);
  transition: background-color 0.3s ease, color 0.3s ease;
}

/* ===== SECTION STYLING ===== */
section {
  padding: 4rem 0;
}

.section-heading {
  color: var(--color-primary);
  font-weight: var(--font-weight-semibold);
  border-bottom: 2px solid var(--color-primary);
  padding-bottom: 1rem;
  margin-bottom: 2rem;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.section-heading iconify-icon {
  font-size: 1.75rem;
}

/* ===== EXPERIENCE CARDS ===== */
.resume-item {
  background-color: var(--color-card-bg);
  border: 1px solid var(--color-border);
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.resume-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

[data-bs-theme="dark"] .resume-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.resume-item h3 {
  color: var(--color-primary);
  font-weight: var(--font-weight-semibold);
  margin-bottom: 0.5rem;
}

.resume-item .company {
  color: var(--color-text-secondary);
  font-size: 1rem;
  margin-bottom: 0.5rem;
}

.resume-item .range {
  color: var(--color-text-secondary);
  font-size: 0.875rem;
  font-style: italic;
  margin-bottom: 1rem;
}

.resume-item .summary {
  color: var(--color-text);
  line-height: 1.6;
}

/* ===== SKILLS ===== */
.skill-group {
  margin-bottom: 2rem;
}

.skill-group h4 {
  color: var(--color-primary);
  font-weight: var(--font-weight-semibold);
  margin-bottom: 1rem;
}

.skill-tag {
  display: inline-block;
  background-color: var(--color-card-bg);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 0.5rem 1rem;
  margin: 0.25rem;
  color: var(--color-text);
  transition: background-color 0.2s ease;
}

.skill-tag:hover {
  background-color: var(--color-primary);
  color: white;
}

/* ===== DARK MODE TOGGLE ===== */
#theme-toggle {
  position: fixed;
  top: 1rem;
  right: 1rem;
  background-color: var(--color-card-bg);
  border: 1px solid var(--color-border);
  border-radius: 50%;
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: transform 0.2s ease;
  z-index: 1000;
}

#theme-toggle:hover {
  transform: scale(1.1);
}

#theme-toggle .dark-icon {
  display: none;
}

[data-bs-theme="dark"] #theme-toggle .light-icon {
  display: none;
}

[data-bs-theme="dark"] #theme-toggle .dark-icon {
  display: block;
}
```
**Source:** https://getbootstrap.com/docs/5.3/customize/color-modes/ and https://www.brycewray.com/posts/2023/03/styling-hugo-site/

### Dark Mode Toggle JavaScript (Inline in Head)
```html
<!-- Place in layouts/partials/head-extend.html or directly in baseof.html <head> -->
<script>
  // CRITICAL: Must run BEFORE page render to prevent flash
  (function() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-bs-theme', savedTheme);
  })();
</script>

<!-- Place in layouts/partials/footer-extend.html or before </body> -->
<button id="theme-toggle" aria-label="Toggle theme">
  <span class="light-icon" aria-hidden="true">☀️</span>
  <span class="dark-icon" aria-hidden="true">🌙</span>
</button>

<script>
  document.getElementById('theme-toggle').addEventListener('click', function() {
    const currentTheme = document.documentElement.getAttribute('data-bs-theme');
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';

    document.documentElement.setAttribute('data-bs-theme', newTheme);
    localStorage.setItem('theme', newTheme);
  });
</script>
```
**Source:** https://yonkov.github.io/post/add-dark-mode-toggle-to-hugo/ and https://getbootstrap.com/docs/5.3/customize/color-modes/

### Biography Content (_index.md)
```markdown
---
title: "Athan Dial"
---

I build product systems that turn uncertainty into velocity. With a PhD in computational biology and 5+ years leading ML product teams, I bridge technical depth with strategic product thinking. I specialize in decision frameworks that help teams move faster without moving recklessly—learning agenda design, build vs. buy analysis, and metrics architecture that prevents theater.

Currently Director of Product at [Company], previously Senior PM building drug discovery platforms. I write about product systems, technical leadership, and the PhD-to-product skills transfer that shapes how I work.
```
**Source:** User's positioning strategy from CONTEXT.md (professional but warm, decision-making philosophy first)

### Config Params for Hugo Resume
```toml
# config/_default/params.toml

[params]
  firstName = "Athan"
  lastName = "Dial"
  email = "athan@example.com"
  profileImage = "img/profile.jpg"
  favicon = "/favicon.ico"

  # Display controls
  showQr = false
  showContact = true
  showCertifications = false
  showBoards = false

  # Section ordering (top to bottom on page)
  sections = [
    "skills",
    "experience",
    "education"
  ]

# Social links
[[params.handles]]
  name = "LinkedIn"
  link = "https://www.linkedin.com/in/athandial/"
  icon = "linkedin"

[[params.handles]]
  name = "GitHub"
  link = "https://github.com/athan-dial"
  icon = "github"
```
**Source:** https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/config.toml

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Icon fonts (Font Awesome) | SVG-based icons (Iconify) | ~2020-2022 | Better accessibility, smaller payload, more flexibility |
| Separate dark mode stylesheets | CSS custom properties + data attributes | Bootstrap 5.3 (2023) | Single stylesheet, easier maintenance, instant switching |
| assets/ vs static/ confusion | Hugo Pipes for processed assets, static/ for direct copy | Hugo 0.43+ (2018) | Clear separation, automatic fingerprinting for assets/ |
| Bullet-list resume experience | Narrative paragraph summaries | 2025-2026 trend | Better for senior leadership scope visibility |
| Google Fonts CDN | Self-hosted fonts | Privacy concerns (~2022) | GDPR compliance, faster load times, no external dependencies |
| Manual CSS cache busting | Hugo Pipes fingerprinting | Hugo 0.43+ (2018) | Automatic unique filenames, no manual versioning |

**Deprecated/outdated:**
- **Icon fonts for modern web:** SVG-based solutions like Iconify are now standard
- **Separate dark.css file:** Bootstrap 5.3+ provides integrated dark mode via data attributes
- **LibSass:** Deprecated in Hugo 0.153.0, use Dart Sass instead
- **theme = "name" in hugo.toml:** Use module.toml imports instead (from Phase 1 research)

## Open Questions

Things that couldn't be fully resolved:

1. **Exact typography choice for executive aesthetic**
   - What we know: Proxima Nova, Brandon Grotesque, Helvetica recommended for minimal elegance
   - What's unclear: Which specific font best matches "executive credibility with approachable voice" positioning
   - Recommendation: Test 2-3 options (Proxima Nova as primary candidate) and decide based on visual review. Marked as Claude's discretion in CONTEXT.md.

2. **Proficiency visualization approach for skills**
   - What we know: Hugo Resume supports icon and link metadata per skill, but no built-in proficiency bars/ratings
   - What's unclear: Whether to add custom CSS for visual proficiency indicators or rely on grouping + description
   - Recommendation: Start with icon-based differentiation (icons for core competencies, plain text for supporting skills), evaluate if additional visualization needed. Claude's discretion per CONTEXT.md.

3. **Case study linking from experience entries**
   - What we know: Case studies deferred to v2, but CONTEXT.md leaves linking as Claude's discretion
   - What's unclear: Whether to include placeholder links in experience.json or wait until case studies exist
   - Recommendation: Add case studies in future phase, then retrospectively add links to experience.json. Don't create placeholder links.

4. **Section icon selection specifics**
   - What we know: CareerCanvas uses emoji, Iconify provides 200k+ icons, icons improve scannability
   - What's unclear: Exact icon-to-section mapping (briefcase vs. building for experience, brain vs. lightbulb for skills)
   - Recommendation: Use semantic icons (briefcase for experience, brain for skills, graduation cap for education), test in browser, iterate. Claude's discretion per CONTEXT.md.

5. **Exact executive blue accent shade**
   - What we know: #1E3A5F range specified in CONTEXT.md as "executive blue"
   - What's unclear: Whether this exact hex is optimal or if lighter/darker shade needed for accessibility
   - Recommendation: Test #1E3A5F in light mode, adjust if contrast ratio fails WCAG AA. Use #4A90E2 (brighter) for dark mode. Claude's discretion per CONTEXT.md.

## Sources

### Primary (HIGH confidence)
- Hugo Resume theme repository: https://github.com/eddiewebb/hugo-resume
- Hugo Resume data schema files:
  - https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/data/experience.json
  - https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/data/skills.json
  - https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/data/education.json
- Hugo Resume config: https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/config.toml
- Bootstrap 5 color modes: https://getbootstrap.com/docs/5.3/customize/color-modes/
- Hugo asset processing (Hugo Pipes): https://gohugo.io/functions/css/sass/
- Hugo self-hosted fonts guide: https://discourse.gohugo.io/t/how-to-add-custom-fonts-and-not-depend-on-google/34267
- Iconify documentation: https://iconify.design/docs/iconify-icon/

### Secondary (MEDIUM confidence)
- CareerCanvas demo site: https://felipecordero.com (verified layout patterns)
- Hugo styling best practices: https://www.brycewray.com/posts/2023/03/styling-hugo-site/
- Dark mode implementation guide: https://yonkov.github.io/post/add-dark-mode-toggle-to-hugo/
- Self-hosted fonts guide: https://www.zerostatic.io/docs/hugo-advance/guides/self-host-fonts/
- Resume trends 2026: https://www.resumepilots.com/blogs/career-advice/resume-linkedin-trends-2026-how-top-leaders-are-rewriting-the-rules-of-visibility
- Executive resume guide: https://careersteering.com/executive-resume-checklist-2026/
- Professional fonts guide: https://www.ebaqdesign.com/blog/professional-fonts
- Typography trends 2026: https://artcoastdesign.com/blog/typography-branding-trends-2026

### Tertiary (LOW confidence)
- Hugo Resume theme overview: https://themes.gohugo.io/themes/hugo-resume/ (marketing page, not technical docs)
- Icon font best practices: https://hugeicons.com/blog/development/best-icon-font-libraries-for-developers (general guidance)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Hugo Resume data schema verified from official repository, Bootstrap 5 dark mode documented
- Architecture patterns: HIGH - JSON schema, CSS patterns, dark mode implementation verified with official sources
- Pitfalls: MEDIUM - Based on general Hugo/Bootstrap experience and community discussions, not Hugo Resume-specific documentation
- Typography recommendations: MEDIUM - Based on 2026 design trends articles, not tested for this specific positioning
- CareerCanvas patterns: MEDIUM - Verified from demo site observation, not official documentation

**Research date:** 2026-02-05
**Valid until:** 2026-03-05 (30 days - Hugo Resume theme stable, Bootstrap 5 established, typography trends evolving slowly)

**User decision constraints applied:**
- Experience format: Paragraph summaries (researched narrative structure patterns)
- PhD framing: Integrated as experience entry (researched skills transfer language)
- Color scheme: Near-monochromatic + executive blue (researched CSS variables implementation)
- Dark mode: Must work perfectly (researched Bootstrap 5 approach + localStorage persistence)
- CareerCanvas layout patterns: Researched specific structural elements (alternating cards, icons, single-scroll)
- Typography: Open to alternatives (researched Proxima Nova, Brandon Grotesque, Helvetica)
- Skills presentation: Domain-based categories (researched JSON grouping approach)
- Bio voice: Professional but warm, first person (researched positioning language patterns)

**Deferred to v2 (not researched):**
- Case studies migration
- Blog/writing section
- Publications section
- PDF resume generation
