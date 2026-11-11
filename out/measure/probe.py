"""Behavior + a11y + layout probe. Usage: probe.py <hugo_url_base> <astro_url_base> <axe.min.js> <outdir>
Runs the same checks against both servers and writes results.json + screenshots."""
import json, sys, pathlib
from playwright.sync_api import sync_playwright

bases = {"hugo": sys.argv[1], "astro": sys.argv[2]}
axe = pathlib.Path(sys.argv[3]).read_text()
out = pathlib.Path(sys.argv[4]); (out / "screens").mkdir(parents=True, exist_ok=True)
res = {}

def visible_count(page):
    return page.eval_on_selector_all("[data-atlas-item]", "els => els.filter(e => !e.hidden).length")

with sync_playwright() as p:
    b = p.chromium.launch()
    for name, base in bases.items():
        r = res[name] = {}
        # --- JS-off: full list, detail link works
        ctx = b.new_context(java_script_enabled=False, viewport={"width": 1440, "height": 900})
        pg = ctx.new_page(); pg.goto(base + "/atlas/")
        r["js_off_items"] = pg.eval_on_selector_all("[data-atlas-item]", "e => e.length")
        r["js_off_controls_hidden"] = pg.eval_on_selector("[data-atlas-controls]", "e => getComputedStyle(e).display === 'none'")
        pg.click(".atlas-card__title a"); r["js_off_detail_url"] = pg.url.replace(base, "")
        ctx.close()
        # --- JS-on behavior
        ctx = b.new_context(viewport={"width": 1440, "height": 900}); pg = ctx.new_page()
        msgs = []; pg.on("console", lambda m: msgs.append(m.text)); pg.on("pageerror", lambda e: msgs.append("ERR " + str(e)))
        reqs = []; pg.on("response", lambda resp: reqs.append((resp.url.replace(base, ""), resp.headers.get("content-length"), resp.request.resource_type)))
        pg.goto(base + "/atlas/", wait_until="networkidle")
        r["requests"] = len(reqs); r["request_types"] = sorted({t for _, _, t in reqs})
        r["initial_count_text"] = pg.inner_text("[data-atlas-count]")
        pg.fill("[data-atlas-search]", "alpha"); r["search_alpha"] = visible_count(pg)
        pg.fill("[data-atlas-search]", "essay"); r["search_tag_essay"] = visible_count(pg)
        pg.fill("[data-atlas-search]", "zzzz"); r["search_none"] = visible_count(pg); r["empty_state_shown"] = pg.is_visible("[data-atlas-empty]")
        pg.fill("[data-atlas-search]", "")
        pg.select_option("[data-atlas-filter=domain]", "Data"); r["filter_domain_data"] = visible_count(pg)
        pg.select_option("[data-atlas-filter=status]", "Shipped"); r["filter_data_and_shipped"] = visible_count(pg)
        pg.fill("[data-atlas-search]", "metrics"); r["filter_plus_search"] = visible_count(pg); r["count_text_after"] = pg.inner_text("[data-atlas-count]")
        pg.fill("[data-atlas-search]", ""); pg.select_option("[data-atlas-filter=domain]", ""); pg.select_option("[data-atlas-filter=status]", "")
        r["reset_count"] = visible_count(pg)
        r["console_messages"] = msgs
        # keyboard: tab order inside main
        pg.goto(base + "/atlas/"); seq = []
        for _ in range(8):
            pg.keyboard.press("Tab"); seq.append(pg.evaluate("(() => { const a=document.activeElement; return (a.tagName+':'+(a.getAttribute('aria-label')||a.textContent||a.placeholder||'').trim().slice(0,24)) })()"))
        r["tab_sequence"] = seq
        # axe
        for label, path in (("list", "/atlas/"), ("detail", "/atlas/sample-alpha/")):
            pg.goto(base + path); pg.add_script_tag(content=axe)
            ax = pg.evaluate("axe.run(document, {runOnly:['wcag2a','wcag2aa','wcag21aa','best-practice']})")
            r[f"axe_{label}"] = {"violations": [{"id": v["id"], "impact": v["impact"], "nodes": len(v["nodes"])} for v in ax["violations"]], "passes": len(ax["passes"])}
        # main-region geometry (visual-criteria equivalence)
        pg.goto(base + "/atlas/")
        r["geometry_list_1440"] = pg.evaluate("""(() => { const q = s => { const e=document.querySelector(s); const b=e.getBoundingClientRect(); return [Math.round(b.x),Math.round(b.width),Math.round(b.height)] };
          return {h1:q('.atlas h1'), controls:q('.atlas__controls'), list:q('.atlas__list'), firstCard:q('.atlas-card')} })()""")
        r["fonts_loaded"] = pg.evaluate("[...document.fonts].filter(f=>f.status==='loaded').map(f=>f.family+' '+f.weight)")
        pg.screenshot(path=str(out / "screens" / f"{name}-list-1440.png"), full_page=False)
        pg.goto(base + "/atlas/sample-alpha/"); pg.screenshot(path=str(out / "screens" / f"{name}-detail-1440.png"))
        r["geometry_detail_1440"] = pg.evaluate("(()=>{const b=document.querySelector('.atlas-detail').getBoundingClientRect();return [Math.round(b.x),Math.round(b.width),Math.round(b.height)]})()")
        ctx.close()
        # --- mobile 390
        ctx = b.new_context(viewport={"width": 390, "height": 844}, device_scale_factor=2, has_touch=True, is_mobile=True); pg = ctx.new_page()
        for label, path in (("list", "/atlas/"), ("detail", "/atlas/sample-alpha/")):
            pg.goto(base + path, wait_until="networkidle")
            r[f"mobile_overflow_{label}"] = pg.evaluate("document.documentElement.scrollWidth > window.innerWidth")
            pg.screenshot(path=str(out / "screens" / f"{name}-{label}-390.png"))
        pg.goto(base + "/atlas/"); pg.fill("[data-atlas-search]", "alpha"); r["mobile_search_alpha"] = visible_count(pg)
        ctx.close()
        # --- 200% zoom emulation: 720 css px wide at DSF 2 ~ 1440 at 200%
        ctx = b.new_context(viewport={"width": 720, "height": 450}); pg = ctx.new_page(); pg.goto(base + "/atlas/")
        r["zoom200_overflow"] = pg.evaluate("document.documentElement.scrollWidth > window.innerWidth"); ctx.close()
    b.close()
json.dump(res, open(out / "results.json", "w"), indent=1)
print(json.dumps({k: {x: v for x, v in d.items() if not x.startswith("axe") and x != "console_messages"} for k, d in res.items()}, indent=1)[:6000])
