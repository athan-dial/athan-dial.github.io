# Agency → Field Notes migration map

Recovery record for material that exists only as built HTML under `docs/agency/`.
Source markdown for The Agency does not exist in this repo or in `athan-dial/skills`.
`docs/agency/**` stays live and untouched; this map is the input for redirect work
on the shell track.

Generated: 2026-08-11 (Wave 1 notes recovery).

## Extraction command (reproducible)

Run from the repo root. Reads each listed dispatch `index.html`, strips chrome
(script/style/nav/header/footer/heading-anchor widgets), unescapes entities,
converts the `div.min-h-0.min-w-0.max-w-prose.grow` article body to markdown,
and writes frontmatter matching `archetypes/note.md`.

```bash
python3 <<'PY'
from __future__ import annotations
import html as html_lib, re, pathlib
from html.parser import HTMLParser

OUT, SRC = pathlib.Path("content/notes"), pathlib.Path("docs/agency/dispatches")
NOTES = [
  ("autonomous-agents-need-a-foreman", ["reliable-ai-systems", "expert-workflows"]),
  ("read-only-automation-is-a-feature", ["reliable-ai-systems", "expert-workflows"]),
  ("delegation-is-the-real-skill", ["expert-workflows", "product-judgment"]),
  ("memory-across-sessions", ["expert-workflows", "reliable-ai-systems"]),
  ("skills-encode-what-you-learned-the-hard-way", ["expert-workflows"]),
  ("ai-research-that-actually-cites-sources", ["expert-workflows", "reliable-ai-systems"]),
]

class AgencyBodyToMarkdown(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=False)
        self.parts, self._stack, self._skip_depth = [], [], 0
        self._in_pre = self._in_link = False
        self._pre_lang, self._pre_parts, self._href, self._link_parts = "", [], None, []
        self._ol_i = 0
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if self._skip_depth:
            self._skip_depth += 1; return
        if tag == "span" and "not-prose" in attrs.get("class", ""):
            self._skip_depth = 1; return
        if tag == "a" and attrs.get("aria-label") == "Anchor":
            self._skip_depth = 1; return
        if tag in ("script", "style"):
            self._skip_depth = 1; return
        if tag in ("h1","h2","h3","h4","h5","h6"):
            self.parts.append("\n\n" + "#" * int(tag[1]) + " "); self._stack.append(tag)
        elif tag == "p":
            self.parts.append("\n\n"); self._stack.append(tag)
        elif tag == "br":
            self.parts.append("  \n")
        elif tag == "ul":
            self.parts.append("\n"); self._stack.append(tag)
        elif tag == "ol":
            self.parts.append("\n"); self._stack.append("ol"); self._ol_i = 0
        elif tag == "li":
            parent = next((t for t in reversed(self._stack) if t in ("ul","ol")), "ul")
            if parent == "ol":
                self._ol_i += 1; self.parts.append(f"\n{self._ol_i}. ")
            else:
                self.parts.append("\n- ")
            self._stack.append(tag)
        elif tag in ("strong","b"):
            self._emit("**"); self._stack.append("strong")
        elif tag in ("em","i"):
            self._emit("*"); self._stack.append("em")
        elif tag == "code" and not self._in_pre:
            self._emit("`"); self._stack.append("code")
        elif tag == "pre":
            self._in_pre, self._pre_parts, self._pre_lang = True, [], ""
            self._stack.append("pre")
        elif tag == "code" and self._in_pre:
            m = re.search(r"language-([\w+-]+)", attrs.get("class",""))
            if m: self._pre_lang = m.group(1)
            self._stack.append("code")
        elif tag == "a":
            self._href, self._link_parts, self._in_link = attrs.get("href",""), [], True
            self._stack.append("a")
        elif tag == "blockquote":
            self.parts.append("\n\n"); self._stack.append(tag)
        else:
            self._stack.append(tag)
    def handle_endtag(self, tag):
        if self._skip_depth:
            self._skip_depth -= 1; return
        if tag in ("h1","h2","h3","h4","h5","h6"):
            if self.parts and self.parts[-1].endswith(" "):
                self.parts[-1] = self.parts[-1].rstrip() + "\n"
            self._pop(tag)
        elif tag in ("strong","b"):
            self._emit("**"); self._pop("strong")
        elif tag in ("em","i"):
            self._emit("*"); self._pop("em")
        elif tag == "code" and not self._in_pre:
            self._emit("`"); self._pop("code")
        elif tag == "pre":
            code = "".join(self._pre_parts).strip("\n")
            self.parts.append(f"\n\n```{self._pre_lang}\n{code}\n```\n")
            self._in_pre = False; self._pop("pre")
        elif tag == "a":
            text, href = "".join(self._link_parts), self._href or ""
            if href.startswith("../../"):
                href = "https://athan-dial.github.io/agency/" + href[6:]
            elif href.startswith("../"):
                href = "https://athan-dial.github.io/agency/dispatches/" + href[3:]
            elif href.startswith("/") and not href.startswith("//"):
                href = "https://athan-dial.github.io" + href
            if href and text: self._emit(f"[{text}]({href})")
            elif text: self._emit(text)
            self._in_link = False; self._pop("a")
        else:
            self._pop(tag)
    def handle_data(self, data):
        if self._skip_depth: return
        data = html_lib.unescape(data)
        if self._in_pre: self._pre_parts.append(data); return
        if self._in_link: self._link_parts.append(data); return
        self._emit(data)
    def handle_entityref(self, name): self.handle_data(f"&{name};")
    def handle_charref(self, name): self.handle_data(f"&#{name};")
    def _emit(self, s): self.parts.append(s)
    def _pop(self, tag):
        while self._stack:
            if self._stack.pop() == tag: break
    def markdown(self):
        text = "".join(self.parts).replace("\r\n","\n")
        text = "\n".join(ln.rstrip() for ln in text.split("\n"))
        return re.sub(r"\n{3,}","\n\n", text).strip() + "\n"

def meta(html):
    def prop(p):
        r = re.search(rf'<meta property="{re.escape(p)}" content="([^"]*)"', html)
        return html_lib.unescape(r.group(1)) if r else None
    title, summary, published = prop("og:title"), prop("og:description"), prop("article:published_time")
    date = published[:10] if published else None
    return title, summary, date

def body(html):
    m = re.search(r'<div class="min-h-0 min-w-0 max-w-prose grow">(.*?)</div></section>', html, re.S)
    if not m: raise SystemExit("body missing")
    return m.group(1)

for slug, themes in NOTES:
    html = (SRC/slug/"index.html").read_text(encoding="utf-8")
    title, summary, date = meta(html)
    p = AgencyBodyToMarkdown(); p.feed(body(html)); p.close()
    url = f"https://athan-dial.github.io/agency/dispatches/{slug}/"
    fm = "\n".join([
        "---",
        f'title: "{title}"',
        "type: note",
        f"date: {date}",
        f'summary: "{summary}"',
        "status: published",
        "visibility: public",
        f"themes: [{', '.join(themes)}]",
        f"source_url: {url}",
        "draft: false",
        "---",
        "",
    ])
    (OUT/f"{slug}.md").write_text(fm + p.markdown(), encoding="utf-8")
    print("wrote", slug)
PY
```

**Exception to the safe-default publish rule:** these six notes are already public on
the live Agency site. They are set to `status: published`, `visibility: public`, and
`draft: false` so they ship at launch (REDESIGN-PLAN wants 4–6 selected field notes).
No Montai program names, internal tooling, named colleagues, or metrics were found;
generic uses of “colleague” in two notes are hypothetical, not employer-identifying.

## Dispatches (7)

| Slug | Live URL | Disposition | New content path |
|---|---|---|---|
| `autonomous-agents-need-a-foreman` | https://athan-dial.github.io/agency/dispatches/autonomous-agents-need-a-foreman/ | **migrated** | `content/notes/autonomous-agents-need-a-foreman.md` |
| `read-only-automation-is-a-feature` | https://athan-dial.github.io/agency/dispatches/read-only-automation-is-a-feature/ | **migrated** | `content/notes/read-only-automation-is-a-feature.md` |
| `delegation-is-the-real-skill` | https://athan-dial.github.io/agency/dispatches/delegation-is-the-real-skill/ | **migrated** | `content/notes/delegation-is-the-real-skill.md` |
| `memory-across-sessions` | https://athan-dial.github.io/agency/dispatches/memory-across-sessions/ | **migrated** | `content/notes/memory-across-sessions.md` |
| `skills-encode-what-you-learned-the-hard-way` | https://athan-dial.github.io/agency/dispatches/skills-encode-what-you-learned-the-hard-way/ | **migrated** | `content/notes/skills-encode-what-you-learned-the-hard-way.md` |
| `ai-research-that-actually-cites-sources` | https://athan-dial.github.io/agency/dispatches/ai-research-that-actually-cites-sources/ | **migrated** | `content/notes/ai-research-that-actually-cites-sources.md` |
| `cowork-changed-how-i-think-about-ai` | https://athan-dial.github.io/agency/dispatches/cowork-changed-how-i-think-about-ai/ | **deferred** (archived-in-place; Athan decides separately) | — |

Diagram SVGs referenced from dispatch headers remain only under `docs/agency/diagrams/`;
they were outside the prose body and were not copied into the markdown notes.

## Playbooks (13)

All remain **archived-in-place** under `docs/agency/playbooks/` (REDESIGN-PLAN: open
tools / technical archive; not migrated into Hugo content in this wave).

| Slug | Live URL | Disposition | Notes |
|---|---|---|---|
| `app-data-forensics-with-cider` | https://athan-dial.github.io/agency/playbooks/app-data-forensics-with-cider/ | archived-in-place | HTML refresh redirect → `read-replica-forensics-from-claude-code` |
| `build-an-ingest-pipeline` | https://athan-dial.github.io/agency/playbooks/build-an-ingest-pipeline/ | archived-in-place | |
| `build-your-first-skill` | https://athan-dial.github.io/agency/playbooks/build-your-first-skill/ | archived-in-place | Linked from migrated skills note |
| `claude-desktop-daily-workflow` | https://athan-dial.github.io/agency/playbooks/claude-desktop-daily-workflow/ | archived-in-place | |
| `hooks-that-run-themselves` | https://athan-dial.github.io/agency/playbooks/hooks-that-run-themselves/ | archived-in-place | |
| `jira-and-confluence-from-claude-code` | https://athan-dial.github.io/agency/playbooks/jira-and-confluence-from-claude-code/ | archived-in-place | |
| `literature-review-from-your-desk` | https://athan-dial.github.io/agency/playbooks/literature-review-from-your-desk/ | archived-in-place | |
| `mcp-servers-connect-everything` | https://athan-dial.github.io/agency/playbooks/mcp-servers-connect-everything/ | archived-in-place | |
| `parallel-research-with-subagents` | https://athan-dial.github.io/agency/playbooks/parallel-research-with-subagents/ | archived-in-place | |
| `query-your-data-warehouse-with-athena` | https://athan-dial.github.io/agency/playbooks/query-your-data-warehouse-with-athena/ | archived-in-place | |
| `read-replica-forensics-from-claude-code` | https://athan-dial.github.io/agency/playbooks/read-replica-forensics-from-claude-code/ | archived-in-place | Canonical target of cider redirect |
| `run-a-project-with-gsd` | https://athan-dial.github.io/agency/playbooks/run-a-project-with-gsd/ | archived-in-place | |
| `teach-claude-your-writing-voice` | https://athan-dial.github.io/agency/playbooks/teach-claude-your-writing-voice/ | archived-in-place | |

## Redirect hints (for shell track)

Suggested eventual redirects (do not implement in this wave):

- `/agency/dispatches/<migrated-slug>/` → `/notes/<migrated-slug>/`
- `/agency/dispatches/` and `/agency/` → Field Notes / Thinking entry points (TBD)
- Playbook URLs stay put until an open-tools destination exists
- Deferred dispatch `cowork-changed-how-i-think-about-ai` stays at its Agency URL
