// Header regression check: label clipping, not just page overflow.
//
// A page can have no horizontal overflow while the wordmark is cut to "Athan Di" inside its own box
// (flex-shrink + overflow:hidden). This measures the rendered text of the wordmark and every primary
// link against its box, and checks that the four links and the wordmark are all present, on screen,
// not overlapping, at least 44px tall, and that each one's keyboard focus ring is visible and not
// clipped by an ancestor. It then proves the detector works by re-introducing the old defect and
// requiring the check to fail.
//
// Run from the repository root after building public/:  node scripts/verify-header.cjs
const assert = require('node:assert/strict');
const { spawn } = require('node:child_process');
const { chromium } = require('playwright');

const port = 8766;
const root = 'http://127.0.0.1:' + port;
const widths = [320, 390, 768, 1280];
const routes = ['/', '/about/', '/work/', '/thinking/', '/atlas/'];
const expectedLinks = ['Work', 'Fieldnotes', 'Systems Atlas', 'About'];
const server = spawn('python3', ['-m', 'http.server', String(port), '--bind', '127.0.0.1', '--directory', 'public'], { stdio: 'ignore' });
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

// Runs in the page. Returns a list of problems; empty means the header is sound.
function inspectHeader(expected) {
  const problems = [];
  const vw = document.documentElement.clientWidth;
  const name = document.querySelector('.site-header__name');
  const links = [...document.querySelectorAll('.site-nav a')];
  if (!name) return ['no wordmark'];
  const textWidth = el => { const r = document.createRange(); r.selectNodeContents(el); return r.getBoundingClientRect().width; };
  const items = [['wordmark', name], ...links.map(a => [a.textContent.trim(), a])];

  if (name.textContent.trim() !== 'Athan Dial') problems.push('wordmark text is "' + name.textContent.trim() + '"');
  if (links.map(a => a.textContent.trim()).join('|') !== expected.join('|')) problems.push('primary links are ' + links.map(a => a.textContent.trim()).join(', '));

  for (const [label, el] of items) {
    const box = el.getBoundingClientRect();
    const cs = getComputedStyle(el);
    if (box.width === 0 || box.height === 0) problems.push(label + ' is not rendered');
    if (el.scrollWidth > el.clientWidth + 0.5) problems.push(label + ' text overflows its box (scrollWidth ' + el.scrollWidth + ' > ' + el.clientWidth + ')');
    if (textWidth(el) > box.width + 0.5) problems.push(label + ' text is wider than its box (' + Math.round(textWidth(el)) + ' > ' + Math.round(box.width) + ')');
    if (cs.textOverflow !== 'clip' && cs.overflow !== 'visible') problems.push(label + ' truncates with ' + cs.textOverflow);
    if (box.left < -0.5 || box.right > vw + 0.5) problems.push(label + ' leaves the viewport (' + Math.round(box.left) + '..' + Math.round(box.right) + ' of ' + vw + ')');
    if (box.height < 43.5) problems.push(label + ' target is ' + Math.round(box.height) + 'px tall, under 44');
  }
  for (let i = 0; i < items.length; i++) {
    for (let j = i + 1; j < items.length; j++) {
      const a = items[i][1].getBoundingClientRect();
      const b = items[j][1].getBoundingClientRect();
      if (a.left < b.right - 1 && b.left < a.right - 1 && a.top < b.bottom - 1 && b.top < a.bottom - 1) problems.push(items[i][0] + ' overlaps ' + items[j][0]);
    }
  }
  return problems;
}

// Runs in the page against document.activeElement: the focus ring must exist and sit inside every clipping ancestor.
function inspectFocus() {
  const el = document.activeElement;
  const cs = getComputedStyle(el);
  const label = el.textContent.trim() || el.getAttribute('href');
  if (cs.outlineStyle === 'none' || parseFloat(cs.outlineWidth) < 2) return [label + ': no visible focus ring (' + cs.outlineStyle + ' ' + cs.outlineWidth + ')'];
  const grow = parseFloat(cs.outlineWidth) + parseFloat(cs.outlineOffset || '0');
  const r = el.getBoundingClientRect();
  const ring = { left: r.left - grow, right: r.right + grow, top: r.top - grow, bottom: r.bottom + grow };
  const problems = [];
  if (ring.left < 0 || ring.right > document.documentElement.clientWidth) problems.push(label + ': focus ring leaves the viewport');
  for (let p = el.parentElement; p && p !== document.documentElement; p = p.parentElement) {
    const pc = getComputedStyle(p);
    if (pc.overflowX === 'visible' && pc.overflowY === 'visible') continue;
    const pr = p.getBoundingClientRect();
    if (ring.left < pr.left - 0.5 || ring.right > pr.right + 0.5 || ring.top < pr.top - 0.5 || ring.bottom > pr.bottom + 0.5) problems.push(label + ': focus ring is clipped by <' + p.tagName.toLowerCase() + ' class="' + p.className + '">');
  }
  return problems;
}

async function checkRoute(page, route, width) {
  await page.goto(root + route, { waitUntil: 'load' });
  await page.evaluate(() => document.fonts.ready);
  const problems = await page.evaluate(inspectHeader, expectedLinks);
  // Keyboard: skip link, wordmark, then the four links.
  await page.evaluate(() => document.activeElement && document.activeElement.blur());
  for (let i = 0; i < 6; i++) {
    await page.keyboard.press('Tab');
    const inHeader = await page.evaluate(() => !!document.activeElement.closest('.site-header'));
    if (inHeader) problems.push(...await page.evaluate(inspectFocus));
  }
  return problems.map(p => width + 'px ' + route + ': ' + p);
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
    let checked = 0;
    for (const width of widths) {
      const ctx = await browser.newContext({ viewport: { width, height: 800 }, reducedMotion: 'reduce' });
      const page = await ctx.newPage();
      for (const route of routes) {
        const problems = await checkRoute(page, route, width);
        assert.equal(problems.length, 0, '\n' + problems.join('\n'));
        checked++;
      }
      console.log('PASS header at ' + width + 'px: full wordmark, four links, 44px targets, visible unclipped focus (' + routes.length + ' routes)');
      await ctx.close();
    }

    // Detector self-test: restore the defect that shipped (wordmark may shrink and clips with overflow:hidden,
    // navigation forced onto one row) and require the check to notice. A check that cannot fail proves nothing.
    const ctx = await browser.newContext({ viewport: { width: 390, height: 800 }, reducedMotion: 'reduce' });
    const page = await ctx.newPage();
    await page.addInitScript(() => {
      document.addEventListener('DOMContentLoaded', () => {
        const s = document.createElement('style');
        s.textContent = '.site-header__inner{flex-wrap:nowrap!important}.site-nav{flex:0 0 auto!important;flex-wrap:nowrap!important;border:0!important}.site-header__name{flex:0 1 auto!important;min-width:0!important;overflow:hidden!important;text-overflow:ellipsis!important}';
        document.head.appendChild(s);
      });
    });
    const regressed = await checkRoute(page, '/', 390);
    assert(regressed.some(p => /wordmark/.test(p)), 'self-test: the check did not detect a clipped wordmark; problems were: ' + regressed.join('; '));
    console.log('PASS detector self-test: a re-introduced clipped wordmark is reported (' + regressed.filter(p => /wordmark/.test(p))[0].replace(/^\d+px \/: /, '') + ')');
    await ctx.close();
    console.log('Header check PASS (' + checked + ' route/width combinations).');
  } finally {
    if (browser) await browser.close();
    server.kill();
  }
})().catch(e => { console.error(e); process.exitCode = 1; });
