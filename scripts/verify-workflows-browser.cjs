// Browser check for the draft workflow page (/work/agentic-operating-system/).
//
//   hugo --gc --minify -D --destination /tmp/draft && hugo --gc --minify --destination public
//   node scripts/verify-workflows-browser.cjs /tmp/draft public
//
// Draft build: task choices on the first screen, eight guides with working anchors, source links that
// point only at the pinned public upstream, no horizontal overflow, diagram tabs that change the
// diagram, visible keyboard focus, and the same content with JavaScript off. Production build: none of
// it exists. Emulated touch and axe-core stay development proxies; real devices are checked under #18.
const assert = require('node:assert/strict');
const { spawn } = require('node:child_process');
const fs = require('node:fs');
const { chromium } = require('playwright');

const [draftDir, prodDir] = process.argv.slice(2);
if (!draftDir) { console.error('usage: verify-workflows-browser.cjs <draft-build-dir> [production-build-dir]'); process.exit(2); }
const registry = JSON.parse(fs.readFileSync('data/workflows/registry.json', 'utf8'));
const pin = registry.upstream.rev;
const guideFile = id => JSON.parse(fs.readFileSync(`data/workflows/guides/${id}.json`, 'utf8'));
const guideIds = registry.guides.map(g => g.id).filter(id => !guideFile(id).draft_stub);   // a registered stub is not rendered
const page = '/work/agentic-operating-system/';
const servers = [];
const serve = (dir, port) => servers.push(spawn('python3', ['-m', 'http.server', String(port), '--bind', '127.0.0.1', '--directory', dir], { stdio: 'ignore' }));
const sleep = ms => new Promise(r => setTimeout(r, ms));
const log = m => console.log('PASS ' + m);

(async () => {
  let browser;
  try {
    serve(draftDir, 8771); if (prodDir) serve(prodDir, 8772);
    for (const port of [8771, ...(prodDir ? [8772] : [])]) {
      let up = false;
      for (let i = 0; i < 50 && !up; i++) { try { up = (await fetch('http://127.0.0.1:' + port)).ok; } catch {} if (!up) await sleep(100); }
      if (!up) throw Error('preview server on ' + port + ' did not start');
    }
    browser = await chromium.launch({ headless: true });
    const base = 'http://127.0.0.1:8771';

    for (const [w, h] of [[1280, 900], [390, 844]]) {
      const ctx = await browser.newContext({ viewport: { width: w, height: h }, reducedMotion: 'reduce' });
      const p = await ctx.newPage();
      const errors = []; p.on('pageerror', e => errors.push(e.message)); p.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
      await p.goto(base + page, { waitUntil: 'load' }); await p.waitForTimeout(1200);

      // 1. first screen: the first task choice is visible without scrolling
      const first = await p.locator('.wf-start__lead a').first().boundingBox();
      assert(first && first.y + 40 < h, `${w}px: first task choice is below the first screen (y=${first && first.y})`);
      log(`${w}px: first task choice is on the first screen`);

      // 2. no horizontal overflow
      const ov = await p.evaluate(() => [document.documentElement.scrollWidth, document.documentElement.clientWidth]);
      assert.equal(ov[0], ov[1], `${w}px: page overflows horizontally ${ov}`);

      // 3. eight guides, every task link resolves, every guide lists its sources
      assert.equal(await p.locator('section.wf-guide').count(), guideIds.length, 'guide count differs from the registry');
      for (const id of guideIds) assert(await p.locator('#guide-' + id).count(), 'missing guide ' + id);
      const hrefs = await p.$$eval('.wf-start a[href^="#"]', as => as.map(a => a.getAttribute('href')));
      for (const href of await p.$$eval('.wf-guides a[href^="#"], .wf-sources a[href^="#"]', as => as.map(a => a.getAttribute('href')))) assert(await p.locator(href).count(), 'in-guide anchor does not resolve: ' + href);
      for (const href of hrefs) assert(await p.locator(href).count(), 'task link target missing: ' + href);
      assert.equal(hrefs.filter(h2 => h2.startsWith('#guide-')).length, guideIds.length, 'every guide should be reachable from the task list');
      for (const id of guideIds) assert((await p.locator(`#guide-${id} .wf-sources-inline li`).count()) >= 1, 'guide without a source list: ' + id);
      log(`${w}px: ${guideIds.length} guides, every task link resolves, every guide lists sources`);

      // 4. source links: only the pinned public upstream; private skills carry none
      const ext = await p.$$eval('a[href^="http"]', as => as.map(a => a.href));
      for (const u of await p.$$eval('.wf-guides a[href], .wf-sources a[href]', as => as.map(a => a.getAttribute('href')))) assert(u.startsWith('#') || u === registry.upstream.repo || u.includes('/blob/' + pin + '/'), 'a guide or source link is neither an anchor nor a pinned upstream file: ' + u);
      for (const u of ext.filter(u => u.includes('mattpocock/skills/blob'))) assert(u.includes('/blob/' + pin + '/'), 'upstream link not at the pinned revision: ' + u);
      assert(!ext.some(u => /github\.com\/athan-dial\/(?!athan-dial\.github\.io)/.test(u)), 'a link points at a private repository');
      for (const s of registry.skills.filter(s => s.source_kind === 'private')) {
        const n = await p.locator(`a:has(code:text-is("${s.name}"))`).count();
        assert.equal(n, 0, `private skill ${s.name} is linked`);
      }
      log(`${w}px: upstream links are pinned; private skills are not linked`);

      // 5. diagrams: every mount shows an Arc diagram; tabs change it; keyboard focus ring is visible
      const mounts = p.locator('.wfplate');
      const n = await mounts.count();
      for (let i = 0; i < n; i++) {
        const m = mounts.nth(i); await m.scrollIntoViewIfNeeded();
        assert(await m.locator('[data-arc-diagram]').count(), `diagram ${i} did not render`);
        const tabs = m.locator('.wfplate__tabs button');
        if (await tabs.count() > 1) {
          const before = await m.locator('[data-arc-diagram]').innerText();
          await tabs.nth(1).focus(); await p.keyboard.press('Enter'); await p.waitForTimeout(400);
          assert.equal(await tabs.nth(1).getAttribute('aria-pressed'), 'true', 'tab did not become pressed');
          assert.notEqual(await m.locator('[data-arc-diagram]').innerText(), before, `diagram ${i}: tab did not change the diagram`);
          const ring = await tabs.nth(1).evaluate(el => { const c = getComputedStyle(el); return [c.outlineStyle, parseFloat(c.outlineWidth)]; });
          assert(ring[0] !== 'none' && ring[1] >= 2, `diagram ${i}: no visible focus ring on its tab`);
        }
      }
      const expectMounts = guideIds.reduce((c, id) => { const d = guideFile(id); return c + ['map', 'compare', 'build'].filter(k => d[k]?.plates).length; }, 0);
      assert.equal(n, expectMounts, `diagram mounts (${n}) differ from the guides' plate blocks (${expectMounts})`);
      log(`${w}px: ${n} diagrams render; tabs switch states by keyboard with a visible ring`);

      // 5b. a guide's "underneath" link opens that architecture view, offers the way back, and back works
      await p.evaluate(() => window.scrollTo(0, 0));
      const viewLink = p.locator('.wf-guide__views a[data-view]').first();
      const fromGuide = await viewLink.getAttribute('data-from');
      const viewId = await viewLink.getAttribute('data-view');
      await viewLink.click(); await p.waitForTimeout(500);
      const shown = await p.locator('#agentic-os-atlas .atlas__views [aria-current="true"]').count();
      assert(shown === 1, 'the architecture atlas did not show a current view after the guide link');
      assert((await p.evaluate(() => location.hash)) === '#' + viewId, 'the atlas did not move to the view ' + viewId);
      const back = p.locator('.atlas__return a'); assert(await back.count(), 'no way back to the guide from the opened view');
      await back.click(); await p.waitForTimeout(300);
      assert((await p.evaluate(() => location.hash)) === '#guide-' + fromGuide, 'back-to-guide link did not return to the guide');
      log(`${w}px: a guide's view link opens the Arc view in place and offers a way back to the guide`);

      // 5c. diagrams on one page must not share SVG ids (a connector would resolve another diagram's gradient)
      const clash = await p.evaluate(() => { const seen = {}; document.querySelectorAll('svg [id]').forEach(e => { seen[e.id] = (seen[e.id] || 0) + 1; }); return Object.entries(seen).filter(([, c]) => c > 1).map(([k]) => k); });
      assert.deepEqual(clash, [], 'duplicate SVG ids across diagrams: ' + clash.join(', '));
      const dangling = await p.evaluate(() => [...document.querySelectorAll('[stroke*="url(#"]')].map(e => e.getAttribute('stroke').match(/url\(#([^)]+)\)/)[1]).filter(id => !document.getElementById(id)));
      assert.deepEqual(dangling, [], 'connectors reference missing gradients: ' + dangling.join(', '));
      log(`${w}px: diagrams share no SVG ids and every gradient reference resolves`);

      // 6. back navigation: following an in-page link then going back returns to where you were
      await p.goto(base + page, { waitUntil: 'load' }); await p.waitForTimeout(800);
      await p.locator('.wf-start__lead a').nth(1).click(); await p.waitForTimeout(300);
      assert(/#guide-/.test(await p.evaluate(() => location.hash)), 'task link did not move to its guide');
      await p.goBack(); await p.waitForTimeout(300);
      assert.equal(await p.evaluate(() => location.hash), '', 'back did not return to the top of the page');
      log(`${w}px: task link and back navigation work`);

      // 7. first task link shows a keyboard focus ring
      await p.evaluate(() => { window.scrollTo(0, 0); document.activeElement && document.activeElement.blur(); });
      for (let i = 0; i < 30; i++) { await p.keyboard.press('Tab'); if (await p.evaluate(() => document.activeElement.matches('.wf-start__lead a'))) break; }
      assert(await p.evaluate(() => document.activeElement.matches('.wf-start__lead a')), 'Tab never reached the first task link');
      const ring = await p.locator('.wf-start__lead a').first().evaluate(el => { const c = getComputedStyle(el); return [c.outlineStyle, parseFloat(c.outlineWidth)]; });
      assert(ring[0] !== 'none' && ring[1] >= 2, 'first task link has no visible focus ring');
      assert.deepEqual(errors, [], 'console or page errors: ' + errors.join('; '));
      await ctx.close();
    }

    // 8. narrow widths: no overflow at 320 and 768
    for (const w of [320, 768, 900, 1000, 1100, 1440]) {
      const ctx = await browser.newContext({ viewport: { width: w, height: 800 }, reducedMotion: 'reduce' });
      const p = await ctx.newPage(); await p.goto(base + page, { waitUntil: 'load' }); await p.waitForTimeout(800);
      const ov = await p.evaluate(() => [document.documentElement.scrollWidth, document.documentElement.clientWidth]);
      assert.equal(ov[0], ov[1], `${w}px: page overflows horizontally ${ov}`);
      await ctx.close();
    }
    log('320, 768, 900, 1000, 1100 and 1440px: no horizontal overflow');

    // 9. JavaScript off: every guide's steps, map states, comparison and source status are still there
    const nj = await browser.newContext({ viewport: { width: 1280, height: 900 }, javaScriptEnabled: false });
    const q = await nj.newPage(); await q.goto(base + page, { waitUntil: 'load' });
    let states = 0, rows = 0, tickets = 0, slices = 0;
    for (const id of guideIds) {
      const d = guideFile(id);
      assert.equal(await q.locator(`#guide-${id} .wf-step`).count(), d.steps.length, 'no-JS: step count differs from the data for ' + id);
      states += (d.map?.states || []).length; rows += (d.compare?.rows || []).length; slices += (d.build?.slices || []).length;
      tickets += (d.map?.states || []).reduce((n, st) => n + st.tickets.length, 0);
    }
    assert.equal(await q.locator('.wf-state').count(), states, 'no-JS: map states differ from the data');
    assert.equal(await q.locator('.wf-ticket').count(), tickets, 'no-JS: map tickets differ from the data');
    assert.equal(await q.locator('.wf-table tbody tr').count(), rows, 'no-JS: comparison rows differ from the data');
    assert.equal(await q.locator('.wf-slice').count(), slices, 'no-JS: build slices differ from the data');
    assert.equal(await q.locator('.wfplate-mount:visible').count(), 0, 'no-JS: an empty diagram mount is showing');
    assert((await q.locator('.atlas-text__view').count()) === 7, 'no-JS: the seven views are not all written out');
    assert((await q.locator('.wf-sources__list li').count()) === registry.skills.length, 'no-JS: source list does not match the registry');
    log('JavaScript off: every guide, the map states, the comparison, the sources and the seven views are readable');
    await nj.close();

    // 10. production: none of it exists
    if (prodDir) {
      const res = await fetch('http://127.0.0.1:8772' + page); assert.equal(res.status, 404, 'production serves the draft page');
      for (const route of ['/', '/work/', '/about/', '/thinking/']) {
        const html = await (await fetch('http://127.0.0.1:8772' + route)).text();
        assert(!/agentic-operating-system|wf-guide|mattpocock\/skills|workflow-plates/.test(html), `production ${route} carries draft workflow content`);
      }
      for (const route of ['/sitemap.xml', '/index.xml', '/work/index.xml', '/atlas/']) {
        const r = await fetch('http://127.0.0.1:8772' + route); if (!r.ok) continue;
        assert(!/agentic-operating-system/.test(await r.text()), `production ${route} lists the draft page`);
      }
      const leaks = [];
      (function walk(d) { for (const f of fs.readdirSync(d, { withFileTypes: true })) { const p2 = d + '/' + f.name; if (f.isDirectory()) walk(p2); else if (/atlas\/agentic-os|workflow-plates/i.test(p2)) leaks.push(p2); } })(prodDir);
      assert.deepEqual(leaks, [], 'production ships draft-only assets: ' + leaks.slice(0, 3).join(', '));
      log('production: no draft page, links, upstream references or atlas assets');
    }
    console.log('Workflow browser check PASS.');
  } finally {
    if (browser) await browser.close();
    servers.forEach(s => s.kill());
  }
})().catch(e => { console.error(e); process.exitCode = 1; });
