# Self-hosted fonts

Editorial Systems uses Latin-subset WOFF2 files served from `/fonts/`. The source
stylesheet is Google Fonts:

```text
https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=Manrope:wght@200..800&family=Source+Serif+4:ital,opsz,wght@0,8..60,400..700;1,8..60,400..700&display=swap
```

All faces use this Latin unicode range:

```text
U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC,
U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193,
U+2212, U+2215, U+FEFF, U+FFFD
```

Expected files and ranges:

| File | Family | Style | Weight |
| --- | --- | --- | --- |
| `manrope-latin-variable.woff2` | Manrope | normal | 200–800 variable |
| `source-serif-4-latin-variable.woff2` | Source Serif 4 | normal | 400–700 variable |
| `source-serif-4-latin-variable-italic.woff2` | Source Serif 4 | italic | 400–700 variable |
| `ibm-plex-mono-latin-400.woff2` | IBM Plex Mono | normal | 400 |
| `ibm-plex-mono-latin-500.woff2` | IBM Plex Mono | normal | 500 |

Exact fetch commands (URLs returned by Google Fonts on 2026-08-11):

```sh
mkdir -p static/fonts
curl -L --fail 'https://fonts.gstatic.com/s/manrope/v20/xn7gYHE41ni1AdIRggexSvfedN4.woff2' -o static/fonts/manrope-latin-variable.woff2
curl -L --fail 'https://fonts.gstatic.com/s/sourceserif4/v14/vEFI2_tTDB4M7-auWDN0ahZJW1gb8te1Xb7G.woff2' -o static/fonts/source-serif-4-latin-variable.woff2
curl -L --fail 'https://fonts.gstatic.com/s/sourceserif4/v14/vEFK2_tTDB4M7-auWDN0ahZJW1gewtW_WpzEpMs.woff2' -o static/fonts/source-serif-4-latin-variable-italic.woff2
curl -L --fail 'https://fonts.gstatic.com/s/ibmplexmono/v20/-F63fjptAgt5VM-kVkqdyU8n1i8q131nj-o.woff2' -o static/fonts/ibm-plex-mono-latin-400.woff2
curl -L --fail 'https://fonts.gstatic.com/s/ibmplexmono/v20/-F6qfjptAgt5VM-kVkqdyU8n3twJwlBFgsAXHNk.woff2' -o static/fonts/ibm-plex-mono-latin-500.woff2
```

Status: all five files are present and committed (fetched 2026-08-11). The temporary
Google Fonts fallback that `baseof.html` carried while they were missing has been
removed — the site loads no external font stylesheet.

To refetch (e.g. a Google Fonts version bump moves the `v20`/`v14` paths): re-request
the stylesheet URL above with a modern browser `User-Agent` to get WOFF2 URLs, then
rerun the commands. Verify each file reports as `Web Open Font Format (Version 2)`
via `file static/fonts/*.woff2` — a failed fetch silently writes an HTML error page.
