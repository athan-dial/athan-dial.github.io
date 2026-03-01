---
phase: quick
plan: 3
type: execute
wave: 1
depends_on: []
files_modified: [static/img/profile.jpg, docs/img/profile.jpg]
autonomous: true
requirements: []
---

<objective>
Replace PIL-generated placeholder profile image with authentic professional headshot photo on Hugo Resume homepage.

Purpose: Display real headshot instead of generic placeholder
Output: Profile photo updated in both source (static/) and built (docs/) directories
</objective>

<execution_context>
@/Users/adial/Documents/GitHub/athan-dial.github.io/config/_default/params.toml (profileImage = "img/profile.jpg" already configured)
@/Users/adial/Documents/GitHub/athan-dial.github.io/CLAUDE.md (Hugo build to docs/ directory)
</execution_context>

<context>
Project is Hugo Resume portfolio deployed to GitHub Pages from docs/ directory.
Profile image is referenced in params.toml and displayed on homepage.
Source photo (PNG, 1024x1536) ready at /Users/adial/Downloads/Professional Headshot Guidelines Feb 17 2026.png
Existing placeholder (JPEG, 1200x630) at static/img/profile.jpg
</context>

<tasks>

<task type="auto">
  <name>Task 1: Convert and copy profile photo to static directory</name>
  <files>static/img/profile.jpg</files>
  <action>
Convert the professional headshot from PNG to JPEG format and copy to static/img/profile.jpg:

1. Use ImageMagick or native tools to convert /Users/adial/Downloads/Professional Headshot Guidelines Feb 17 2026.png to JPEG
2. Optimize for web: target quality 85-90 for good balance of quality and file size
3. Output to static/img/profile.jpg (overwriting the existing 12KB placeholder)
4. Verify file exists and is JPEG format

The Hugo build process is already configured to reference this file as profileImage in params.toml. No config changes needed.
  </action>
  <verify>
file /Users/adial/Documents/GitHub/athan-dial.github.io/static/img/profile.jpg
Should return: JPEG image data
  </verify>
  <done>Professional headshot converted to JPEG and stored at static/img/profile.jpg, ready for Hugo build</done>
</task>

<task type="auto">
  <name>Task 2: Build and deploy updated site to docs/</name>
  <files>docs/img/profile.jpg</files>
  <action>
Rebuild Hugo site to populate docs/ directory with updated profile image:

1. Navigate to /Users/adial/Documents/GitHub/athan-dial.github.io
2. Run: hugo (builds to docs/ directory per publishDir in hugo.toml)
3. Verify that docs/img/profile.jpg is updated with the new headshot
4. Check file size and modification timestamp to confirm it's the new image

This rebuilds the static site for GitHub Pages deployment.
  </action>
  <verify>
ls -lh /Users/adial/Documents/GitHub/athan-dial.github.io/docs/img/profile.jpg
stat /Users/adial/Documents/GitHub/athan-dial.github.io/docs/img/profile.jpg
Should show recent modification timestamp matching build time
  </verify>
  <done>Site rebuilt and docs/img/profile.jpg updated with professional headshot</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Professional headshot photo integrated into Hugo Resume homepage</what-built>
  <how-to-verify>
1. Run: hugo server -D
2. Visit: http://localhost:1313
3. Homepage should display professional headshot in profile image area (top-left or prominent position depending on theme)
4. Verify image quality looks good (sharp, colors accurate, not pixelated or distorted)
5. Test on mobile and desktop to confirm responsive behavior
  </how-to-verify>
  <resume-signal>Approved if headshot displays correctly and looks professional. Otherwise describe issues (blurry, wrong colors, layout broken, etc.)</resume-signal>
</task>

</tasks>

<verification>
1. Profile image file exists at static/img/profile.jpg (JPEG format)
2. Hugo builds successfully without errors
3. docs/img/profile.jpg contains the new headshot
4. Local server displays professional headshot on homepage
5. Headshot appears crisp and well-proportioned across device sizes
</verification>

<success_criteria>
- Professional headshot replaces placeholder on live homepage
- Image displays without distortion or quality loss
- File sizes optimized for web (target <50KB)
- Both static/ and docs/ directories updated
- Site builds without errors
</success_criteria>

<output>
After completion, commit changes:

```bash
git add static/img/profile.jpg docs/img/profile.jpg
git commit -m "feat: add professional headshot to portfolio homepage"
git push
```

Profile photo will be live on GitHub Pages after push.
</output>
