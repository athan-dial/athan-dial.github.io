# Technology Stack Research: Hugo Resume Theme Migration

**Project:** Hugo Resume Theme Migration
**Researched:** 2026-02-04
**Confidence:** MEDIUM

## Recommended Stack

### Core Framework
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Hugo | 0.154.3+extended (current) → 0.154.5+ (target) | Static site generator | Already in use; Hugo Resume requires minimum 0.62, so current version 0.154.3 is compatible. Extended version required for SCSS processing. |
| Hugo Resume Theme | master branch (no releases) | Single-page resume theme | Provides data-driven resume structure with JSON-based content management. Ported from Start Bootstrap Resume template. |

### Theme Installation Method
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Hugo Modules | Go 1.12+ | Theme dependency management | **RECOMMENDED**: Preferred modern approach. Clean removal/switching, simple updates via `hugo mod get -u`. Requires Go installed. |
| Git Submodules | N/A | Alternative theme management | **FALLBACK**: Traditional approach. Simpler if Go not installed, but leaves traces across repository, harder to iterate/experiment. |

### Data File Structure
| Format | Location | Purpose | Schema |
|--------|----------|---------|--------|
| JSON | `data/experience.json` | Work history | Array of `{role, company, summary, range}` objects |
| JSON | `data/education.json` | Education background | Array of `{school, degree, major, notes?, range}` objects |
| JSON | `data/skills.json` | Skills inventory | Array of `{grouping, skills[]}` objects; skills can be strings or `{name, icon}` or `{name, link}` objects |

### Content Organization
| Location | Purpose | Format |
|----------|---------|--------|
| `content/_index.md` | Bio/summary section | Markdown |
| `content/projects/creations/` | Original projects | Markdown (use `hugo add` command) |
| `content/projects/contributions/` | Contributions to other projects | Markdown (use `hugo add` command) |
| `content/publications/` | Publications list | Markdown |
| `content/blog/` | Blog posts | Markdown (NOT `posts/` folder) |

### Frontend Dependencies (Vendored in Theme)
| Library | Version | Purpose | Notes |
|---------|---------|---------|-------|
| Bootstrap | ~4.x | CSS framework | Ported from Start Bootstrap template; vendored in theme |
| jQuery | ~3.3.1 | JavaScript utilities | Required for search functionality |
| Fuse.js | ~3.2.0 | Client-side search | Powers `/search` endpoint |
| Mark.js | ~8.11.1 | Text highlighting | Used in search results |

### Configuration Requirements
| Parameter | Type | Required | Purpose |
|-----------|------|----------|---------|
| `baseURL` | string | Yes | Site base URL |
| `theme` | string | Yes | Set to `"hugo-resume"` |
| `defaultContentLanguage` | string | No | Language code (default: "en"; supports "en", "fr") |
| `params.firstName` | string | Yes | Personal information |
| `params.lastName` | string | Yes | Personal information |
| `params.address` | string | Yes | Location |
| `params.email` | string | Yes | Contact email |
| `params.phone` | string | No | Contact phone |
| `params.profileImage` | string | Yes | Path to profile photo (e.g., `img/profile.png`) |
| `params.showQr` | bool | No | Display QR code on page |
| `params.showContact` | bool | No | Display contact section |
| `params.sections` | array | Yes | Ordered list of sections: `["skills", "experience", "education", "projects", "publications", "blog"]` |

### Output Formats (Built-in)
| Format | Extension | Purpose |
|--------|-----------|---------|
| HTML | .html | Standard site pages |
| JSON | .json | Search index for Fuse.js |
| vCard | .vcf | Downloadable contact card |

## Installation Commands

### Option A: Hugo Modules (Recommended)
```bash
# Initialize Hugo modules (requires Go 1.12+)
hugo mod init github.com/yourusername/yoursite

# Add theme as module in config.toml
# [module]
#   [[module.imports]]
#     path = "github.com/eddiewebb/hugo-resume"

# Download module
hugo mod get github.com/eddiewebb/hugo-resume

# Update module later
hugo mod get -u github.com/eddiewebb/hugo-resume

# Vendor for local inspection (optional)
hugo mod vendor
```

### Option B: Git Submodule (Fallback)
```bash
# Add theme as submodule
git submodule add https://github.com/eddiewebb/hugo-resume.git themes/hugo-resume

# Initialize submodules when cloning
git submodule update --init --recursive

# Update theme later
cd themes/hugo-resume
git pull origin master
cd ../..
git add themes/hugo-resume
git commit -m "Update hugo-resume theme"
```

### Configuration Migration from Blowfish
```bash
# 1. Backup current config
cp -r config/ config.backup/

# 2. Copy exampleSite config as starting point
# (after installing theme)

# 3. Create data files
mkdir -p data/
touch data/experience.json data/education.json data/skills.json

# 4. Reorganize content structure
# Move/restructure content/ to match Hugo Resume expectations
```

## Alternatives Considered

| Category | Recommended | Alternative | Why Not Alternative |
|----------|-------------|-------------|---------------------|
| Theme installation | Hugo Modules | Git Submodules | Modules cleaner for switching themes, easier updates, no repository traces |
| Data format | JSON files in `data/` | Markdown frontmatter | Theme designed around JSON data files; changing would require theme modification |
| Content structure | Theme's prescribed folders | Custom layout | Breaking theme conventions requires extensive layout overrides |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `posts/` folder for blog | Theme expects `blog/` folder specifically | `content/blog/` |
| YAML/TOML for resume data | Theme only supports JSON in `data/` directory | JSON files (`experience.json`, etc.) |
| Direct theme modification | Breaks upgrade path | Override via `layouts/` directory in project root |
| Hugo < 0.62 | Theme minimum requirement | Hugo 0.154.3+extended (current version) |

## Migration-Specific Considerations

### From Blowfish to Hugo Resume

**Breaking changes:**
1. **Data structure**: Blowfish uses markdown frontmatter; Hugo Resume uses JSON data files
2. **Content organization**: Different folder structure and naming conventions
3. **Configuration format**: Hugo Resume uses flat `config.toml` vs Blowfish's `config/_default/` directory structure
4. **Styling approach**: Bootstrap-based vs Tailwind CSS (Blowfish)
5. **Module system**: Both support Hugo Modules, but import paths differ

**Compatibility preserved:**
- Hugo version: Current 0.154.3 works with both themes
- Deployment target: Both can publish to `docs/` directory
- Markdown content: Standard markdown files portable between themes

### GitHub Pages Deployment

No changes required from current setup:
```toml
publishDir = "docs"
```

Both Blowfish and Hugo Resume respect `publishDir` configuration.

## Version Compatibility Matrix

| Hugo Resume Minimum | Current Project | Compatibility |
|---------------------|-----------------|---------------|
| Hugo 0.62 | Hugo 0.154.3+extended | ✅ Compatible |
| Go N/A (if using git submodules) | N/A | ✅ No Go required for submodule approach |
| Go 1.12+ (if using Hugo Modules) | Unknown | ⚠️ Verify Go version if choosing modules |

## Known Issues & Limitations

### Theme Maintenance Status
- **Last activity**: Theme has 308 stars, 263 forks, but no official releases published
- **Active development**: Unclear; 8 open issues, 3 pull requests
- **Risk**: Theme may not receive updates for new Hugo versions or bug fixes
- **Mitigation**: Fork theme if customizations needed; be prepared to maintain locally

### Documented Issues
1. **Template rendering errors** (Issue #69): Some users report build failures with missing template parameters
   - **Prevention**: Ensure all required config parameters set
2. **Email obfuscation** (Issue #26): `-remove-` text appears in mailto links as spam defense
   - **Expected behavior**: By design
3. **Posts folder confusion** (Issue #30): Theme requires `blog/` not `posts/` folder
   - **Prevention**: Use correct folder naming

### Search Functionality Dependencies
- Requires jQuery, Fuse.js, Mark.js loaded in correct order
- Client-side only; no server-side search
- JSON output format must be configured for search index

## Stack Patterns by Use Case

**If prioritizing ease of switching/experimentation:**
- Use Hugo Modules
- Keep theme customizations minimal
- Override layouts in project `layouts/` directory only

**If avoiding Go dependency:**
- Use Git Submodules
- Accept more complex theme switching process
- Document submodule management in README

**If heavy customization needed:**
- Fork hugo-resume theme to own repository
- Use forked version as module/submodule
- Maintain customizations in fork, not project

## Development Dependencies

None required beyond Hugo itself. Theme includes all frontend assets.

**Optional:**
- Go 1.12+ (for Hugo Modules approach)
- Git (for submodule approach)

## Sources

**HIGH confidence:**
- [Hugo Resume GitHub Repository](https://github.com/eddiewebb/hugo-resume) - Official theme source
- [Hugo Resume theme.toml](https://github.com/eddiewebb/hugo-resume/blob/master/theme.toml) - Minimum Hugo version (0.62)
- [Hugo Resume exampleSite config](https://github.com/eddiewebb/hugo-resume/blob/master/exampleSite/config.toml) - Configuration parameters
- [Hugo Resume data files](https://github.com/eddiewebb/hugo-resume/tree/master/exampleSite/data) - JSON schema examples

**MEDIUM confidence:**
- [Hugo Modules vs Git Submodules comparison](https://drmowinckels.io/blog/2025/submodules/) - Installation method tradeoffs (2026-01-12)
- [Managing Hugo Dependencies guide](https://bruce-willis.github.io/posts/hugo-modules-guide/) - Hugo Modules best practices
- [Hugo discourse: Theme as module vs submodule](https://discourse.gohugo.io/t/theme-as-a-hugo-module-or-theme-as-a-git-submodule/54388) - Community recommendations

**LOW confidence (unverified WebSearch only):**
- Frontend library versions (jQuery 3.3.1, Fuse.js 3.2.0, Mark.js 8.11.1) - Mentioned in search results but not confirmed in official docs
- Theme maintenance status - No recent release dates visible; inferred from repository statistics

---
*Stack research for: Hugo Resume Theme Migration*
*Researched: 2026-02-04*
*Overall confidence: MEDIUM - Core requirements verified from official sources; frontend dependency versions and maintenance status need validation*
