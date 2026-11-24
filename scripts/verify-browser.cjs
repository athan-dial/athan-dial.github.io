// Headless smoke checks, not a substitute for visual or assistive-technology review.
// Run from the repository root after building public/. Playwright is a test-only dependency.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const { spawn } = require('node:child_process');
const { chromium } = require('playwright');

const root = 'http://127.0.0.1:8765';
const expected = fs.readdirSync('atlas/records').filter(p => p.endsWith('.toml')).length;
const routes = ['/', '/about/', '/work/', '/thinking/', '/atlas/', '/atlas/sqlmesh--sqlmesh/', '/atlas/letta-ai--letta/', '/work/analog-search-as-a-product/'];
const server = spawn('python3', ['-m', 'http.server', '8765', '--bind', '127.0.0.1', '--directory', 'public'], { stdio: 'ignore' });
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

async function checkPage(page, route, label) {
  const res = await page.goto(root + route, { waitUntil: 'load' });
  assert(res && res.ok(), label + ': response ' + route);
  await page.evaluate(() => document.fonts.ready);
  const metrics = await page.evaluate(() => ({
    viewport: document.documentElement.clientWidth,
    width: document.documentElement.scrollWidth,
    heading: !!document.querySelector('main h1'),
    nav: document.querySelectorAll('.site-nav a').length
  }));
  assert(metrics.heading, label + ': main heading ' + route);
  assert.equal(metrics.nav, 4, label + ': primary navigation ' + route);
  assert(metrics.width <= metrics.viewport + 2, label + ': body overflow ' + route + ' (' + metrics.width + ' vs ' + metrics.viewport + ')');
  console.log('PASS ' + label + ' ' + route + ' (width ' + metrics.width + '/' + metrics.viewport + ')');
}

(async () => {
  let browser;
  try {
    for (let i = 0; i < 50; i++) {
      try { if ((await fetch(root)).ok) break; } catch {}
      if (i === 49) throw Error('local preview server did not start');
      await sleep(100);
    }
    browser = await chromium.launch({ headless: true });
    for (const width of [390, 800, 1600]) {
      const ctx = await browser.newContext({ viewport: { width, height: 900 }, reducedMotion: 'reduce' });
      const page = await ctx.newPage();
      const errors = [];
      page.on('pageerror', e => errors.push(String(e)));
      for (const route of routes) await checkPage(page, route, width + 'px');
      assert.equal(errors.length, 0, errors.join('\n'));
      await page.goto(root + '/', { waitUntil: 'load' });
      await page.keyboard.press('Tab');
      const focused = await page.evaluate(() => ({ href: document.activeElement.getAttribute('href'), top: document.activeElement.getBoundingClientRect().top }));
      assert.equal(focused.href, '#main-content', 'first keyboard stop is skip link');
      assert(focused.top >= 0, 'focused skip link must be on screen');
      await ctx.close();
    }
    const noJS = await browser.newContext({ javaScriptEnabled: false, viewport: { width: 390, height: 900 } });
    const staticPage = await noJS.newPage();
    for (const route of routes) await checkPage(staticPage, route, '390px JS off');
    await staticPage.goto(root + '/atlas/');
    assert.equal(await staticPage.locator('[data-atlas-item]').count(), expected, 'all catalogue records in static DOM');
    assert.equal(await staticPage.locator('[data-atlas-controls]').isVisible(), false, 'unavailable search controls hidden');
    await noJS.close();

    const page = await browser.newPage({ viewport: { width: 1280, height: 900 }, reducedMotion: 'reduce' });
    await page.goto(root + '/atlas/');
    await page.locator('[data-atlas-search]').fill('lineage');
    const matching = await page.locator('[data-atlas-item]:not([hidden])').count();
    assert(matching > 0 && matching < expected, 'catalogue search reduces results');
    assert.equal(new URL(page.url()).searchParams.get('q'), 'lineage');
    await page.locator('[data-atlas-clear]').click();
    assert.equal(await page.locator('[data-atlas-item]:not([hidden])').count(), expected);
    console.log('PASS catalogue search, URL state and clear (' + matching + '/' + expected + ')');

    // Font-size enlargement is a text-zoom proxy, not native browser zoom.
    for (const route of ['/', '/about/', '/work/', '/thinking/', '/atlas/']) {
      await page.goto(root + route, { waitUntil: 'load' });
      const m = await page.evaluate(() => {
        document.documentElement.style.fontSize = '200%';
        return { width: document.documentElement.scrollWidth, viewport: document.documentElement.clientWidth };
      });
      assert(m.width <= m.viewport + 2, '200% text-size proxy overflow ' + route + ' (' + m.width + ' vs ' + m.viewport + ')');
      console.log('PASS 200% text-size proxy ' + route);
    }
    console.log('Browser smoke PASS; manual visual, contrast and screen-reader review still required.');
  } finally {
    if (browser) await browser.close();
    server.kill();
  }
})().catch(e => { console.error(e); process.exitCode = 1; });
