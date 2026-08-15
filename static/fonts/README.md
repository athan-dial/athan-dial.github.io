# Self-hosted fonts

Latin-subset WOFF2 files served from `/fonts/`. No CDN, no external font request.

## Archivo — the current text face (added 2026-08-13)

`archivo-latin-variable.woff2`, 35KB, weights 100–900 in one variable file. It carries display,
headings and body; IBM Plex Mono carries metadata. Fetched from the Google Fonts CSS API with a
woff2-capable User-Agent, taking the `latin` subset (the `unicode-range` containing `U+0000-00FF`):

```bash
curl -A "<modern browser UA>" \
  "https://fonts.googleapis.com/css2?family=Archivo:wght@100..900&display=swap"
# then curl the URL from the /* latin */ @font-face block
```

**Licence: OFL-1.1** (SIL Open Font License), verified against the upstream repository
`Omnibus-Type/Archivo`. Self-hosting and redistribution are permitted, so there is no licensing
tail on this direction — worth recording, because the design exploration initially assumed the
grotesque would be a commercial face.

## Retired and removed (2026-08-14)

Manrope (Clinical Architect) and Source Serif 4 (Editorial Systems) were dropped from the type
scale when Archivo took over both `--font-serif` and `--font-sans`. Their `@font-face` rules and
the three underlying files (`manrope-latin-variable.woff2`,
`source-serif-4-latin-variable.woff2`, `source-serif-4-latin-variable-italic.woff2`) have been
deleted — a grep across `assets/`, `layouts/`, `content/`, and `data/` confirmed nothing
referenced either family before removal. Do not re-add them without a design-system decision.

## Original provenance (Editorial Systems)

The source stylesheet was Google Fonts:

```text
https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=Manrope:wght@200..800&family=Source+Serif+4:ital,opsz,wght@0,8..60,400..700;1,8..60,400..700&display=swap
```

All faces use this Latin unicode range:

```text
U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC,
U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193,
U+2212, U+2215, U+FEFF, U+FFFD
```

Expected files and ranges (current set only — see "Retired and removed" above for what used to
be here):

| File | Family | Style | Weight |
| --- | --- | --- | --- |
| `archivo-latin-variable.woff2` | Archivo | normal | 100–900 variable |
| `ibm-plex-mono-latin-400.woff2` | IBM Plex Mono | normal | 400 |
| `ibm-plex-mono-latin-500.woff2` | IBM Plex Mono | normal | 500 |

Exact fetch commands for the IBM Plex Mono files (URLs returned by Google Fonts on 2026-08-11):

```sh
mkdir -p static/fonts
curl -L --fail 'https://fonts.gstatic.com/s/ibmplexmono/v20/-F63fjptAgt5VM-kVkqdyU8n1i8q131nj-o.woff2' -o static/fonts/ibm-plex-mono-latin-400.woff2
curl -L --fail 'https://fonts.gstatic.com/s/ibmplexmono/v20/-F6qfjptAgt5VM-kVkqdyU8n3twJwlBFgsAXHNk.woff2' -o static/fonts/ibm-plex-mono-latin-500.woff2
```

Status: all three current files are present and committed. The site loads no external font
stylesheet.

To refetch (e.g. a Google Fonts version bump moves the version path): re-request the stylesheet
URL above with a modern browser `User-Agent` to get WOFF2 URLs, then rerun the commands. Verify
each file reports as `Web Open Font Format (Version 2)` via `file static/fonts/*.woff2` — a
failed fetch silently writes an HTML error page.
