/* TALOS story: problem motion, interactive demo (synthetic data), decision explainers.
   Vanilla JS. Progressive: without JS the static text, architecture figure and gallery still read. */
(function () {
  'use strict';
  var doc = document, root = doc.documentElement;
  var reduce = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
  root.classList.add('wp-js');
  if (reduce) root.classList.add('wp-static');

  function $(s, c) { return (c || doc).querySelector(s); }
  function $$(s, c) { return Array.prototype.slice.call((c || doc).querySelectorAll(s)); }
  function esc(s) { return String(s).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }
  function el(tag, cls, html) { var e = doc.createElement(tag); if (cls) e.className = cls; if (html != null) e.innerHTML = html; return e; }

  /* ---------- architecture region lighting (shared) ---------- */
  var lightTimer = null, holdUntil = 0;
  function light(key, hold) {
    if (!key && !hold && Date.now() < holdUntil) return; // a click keeps the region lit for a moment
    $$('.arch-region').forEach(function (r) { r.classList.toggle('is-lit', !!key && r.classList.contains('arch-region--' + key)); });
    clearTimeout(lightTimer);
    if (key && hold) { holdUntil = Date.now() + hold; lightTimer = setTimeout(function () { holdUntil = 0; light(null); }, hold); }
  }
  $$('[data-light]').forEach(function (a) {
    var k = a.getAttribute('data-light');
    a.addEventListener('mouseenter', function () { light(k); });
    a.addEventListener('focus', function () { light(k); });
    a.addEventListener('mouseleave', function () { light(null); });
    a.addEventListener('blur', function () { light(null); });
    a.addEventListener('click', function () { light(k, 3200); });
  });

  /* ---------- reveal ---------- */
  if ('IntersectionObserver' in window && !reduce) {
    var rv = new IntersectionObserver(function (es) { es.forEach(function (e) { if (e.isIntersecting) { e.target.classList.add('is-in'); rv.unobserve(e.target); } }); }, { rootMargin: '0px 0px -8% 0px' });
    $$('.wp-reveal').forEach(function (n) { rv.observe(n); });
  } else { $$('.wp-reveal').forEach(function (n) { n.classList.add('is-in'); }); }

  /* ---------- 01 problem motion ---------- */
  var motion = $('[data-ts-motion]');
  if (motion && !reduce && 'IntersectionObserver' in window) {
    var played = false;
    motion.classList.add('is-armed');
    function play() { motion.classList.remove('is-armed', 'is-playing'); void motion.offsetWidth; motion.classList.add('is-playing'); }
    var mo = new IntersectionObserver(function (es) { es.forEach(function (e) { if (e.isIntersecting && !played) { played = true; play(); mo.disconnect(); } }); }, { threshold: 0.2 });
    mo.observe(motion);
    var rb = $('[data-ts-replay]', motion); if (rb) rb.addEventListener('click', function () { played = true; play(); });
  } else if (motion) { var rb2 = $('[data-ts-replay]', motion); if (rb2) rb2.hidden = true; }

  /* ---------- data ---------- */
  var dataEl = $('#ts-demo-data'); var D = null;
  try { D = dataEl ? JSON.parse(dataEl.textContent) : null; } catch (e) { D = null; }
  if (!D) return;
  var T0 = Date.parse(D.meta.start), T1 = Date.parse(D.meta.end), TODAY = Date.parse(D.meta.today), REVIEW = Date.parse(D.meta.lastReview);
  var MON = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  function pct(d) { var t = typeof d === 'number' ? d : Date.parse(d); return Math.max(0, Math.min(100, (t - T0) / (T1 - T0) * 100)); }
  function fmt(d, prec) { var x = new Date(Date.parse(d)); var m = MON[x.getUTCMonth()], y = x.getUTCFullYear(); return prec === 'month' ? m + ' ' + y : x.getUTCDate() + ' ' + m + ' ' + y; }
  function band(c) { return { high: 'High', medium: 'Medium', uncertain: 'Uncertain' }[c]; }
  function conf(c, s) { return '<span class="ts-conf ts-conf--' + c + '"><i></i>' + band(c) + (s != null ? ' ' + s.toFixed(2) : '') + '</span>'; }
  function progById(id) { return D.programs.filter(function (p) { return p.id === id; })[0]; }
  function newCount(p) { return p.events.filter(function (e) { return e.isNew; }).length; }

  /* ---------- 02 demo ---------- */
  var app = $('[data-ts-demo]');
  if (app) (function () {
    var body = $('[data-body]', app), crumbs = $('[data-crumbs]', app), meta = $('[data-meta]', app), live = $('[data-live]', app), rlink = $('[data-region-link]', app);
    var S = { view: 'landscape', pid: null, eid: null, aid: null, onlyNew: false };
    meta.textContent = D.meta.target + ' · synthetic · last review ' + fmt(D.meta.lastReview, 'day');

    function say(t) { live.textContent = ''; setTimeout(function () { live.textContent = t; }, 30); }
    function go(view, o, focus) { for (var k in o) S[k] = o[k]; S.view = view; render(!!focus); }
    function focusHead() { var h = $('[data-focus]', body); if (h) { h.setAttribute('tabindex', '-1'); h.focus({ preventScroll: false }); } }

    function renderCrumbs() {
      var p = S.pid && progById(S.pid), e = p && S.eid && p.events.filter(function (x) { return x.id === S.eid; })[0];
      var steps = [
        { n: 1, label: 'Landscape', view: 'landscape', ok: true },
        { n: 2, label: p ? p.asset : 'Program', view: 'program', ok: !!p },
        { n: 3, label: e ? 'Event' : 'Event', view: 'event', ok: !!e },
        { n: 4, label: 'Evidence', view: 'evidence', ok: !!(e && S.aid != null) }
      ];
      var cur = S.view === 'landscape' ? 1 : S.view === 'program' ? 2 : (S.aid != null ? 4 : 3);
      crumbs.innerHTML = '';
      steps.forEach(function (s) {
        var b = el('button', 'ts-crumb', s.n + ' ' + esc(s.label)); b.type = 'button'; b.disabled = !s.ok;
        if (s.n === cur) b.setAttribute('aria-current', 'step');
        b.addEventListener('click', function () {
          if (s.n === 1) go('landscape', { pid: null, eid: null, aid: null }, true);
          else if (s.n === 2) go('program', { eid: null, aid: null }, true);
          else if (s.n === 3) go('event', { aid: null }, true);
          else if (s.n === 4) { var a = $('.ts-assert', body); if (a) a.focus(); }
        });
        crumbs.appendChild(b);
      });
    }

    function renderRegion() {
      if (S.view === 'landscape' || S.view === 'program') { rlink.hidden = false; rlink.innerHTML = 'These views are part of <a href="#architecture" data-light="products">region 04, Intelligence products ↗</a>'; }
      else { rlink.hidden = false; rlink.innerHTML = 'This provenance chain lives in <a href="#architecture" data-light="substrate">region 03, Canonical intelligence ↗</a>'; }
      $$('[data-light]', rlink).forEach(function (a) { var k = a.getAttribute('data-light'); a.addEventListener('mouseenter', function () { light(k); }); a.addEventListener('focus', function () { light(k); }); a.addEventListener('mouseleave', function () { light(null); }); a.addEventListener('blur', function () { light(null); }); a.addEventListener('click', function () { light(k, 3200); }); });
    }

    function render(focus) {
      body.innerHTML = '';
      var v = S.view === 'landscape' ? landscape() : S.view === 'program' ? program() : event();
      body.appendChild(v);
      renderCrumbs(); renderRegion();
      if (focus) focusHead();
    }

    /* landscape */
    function landscape() {
      var w = el('div', 'ts-view');
      var nNew = D.programs.reduce(function (a, p) { return a + newCount(p); }, 0);
      w.innerHTML = '<div class="ts-view-h"><h3 data-focus>Competitive landscape · ' + esc(D.meta.target) + '</h3><div class="ts-tools"><button type="button" class="ts-toggle" aria-pressed="' + S.onlyNew + '" data-new>New since last review (' + nNew + ')</button></div></div>' +
        '<p class="ts-hint">Each lane is one program: bars run from first seen to today, dots are events. Select a lane to open the program.</p>';
      var axis = el('div', 'ts-axis'); axis.setAttribute('aria-hidden', 'true');
      var at = el('div', 'ts-axis-track');
      [['Oct', '2025-10-01'], ['Jan', '2026-01-01'], ['Apr', '2026-04-01'], ['Jul', '2026-07-01']].forEach(function (m) { var s = el('span', null, m[0] + (m[0] === 'Oct' || m[0] === 'Jan' ? ' ' + m[1].slice(0, 4) : '')); s.style.left = pct(m[1]) + '%'; at.appendChild(s); });
      axis.appendChild(el('div')); axis.appendChild(at); w.appendChild(axis);
      var ul = el('ul', 'ts-lanes');
      D.programs.forEach(function (p) {
        var nn = newCount(p), li = el('li');
        var b = el('button', 'ts-lane' + (S.onlyNew && !nn ? ' is-dim' : '')); b.type = 'button';
        b.setAttribute('aria-label', 'Open ' + p.asset + ', ' + p.sponsor + ', ' + p.indication + ', ' + D.phases[p.phase] + ', ' + p.events.length + ' events' + (nn ? ', ' + nn + ' new since last review' : ''));
        var track = '';
        track += '<span class="ts-bar" style="left:' + pct(p.firstSeen) + '%;width:' + (pct(D.meta.today) - pct(p.firstSeen)) + '%"></span>';
        track += '<span class="ts-phase" style="left:' + pct(p.firstSeen) + '%">' + esc(D.phases[p.phase]) + '</span>';
        p.events.forEach(function (e) { track += '<span class="ts-dot ts-dot--' + e.conf + (e.isNew ? ' is-new' : '') + '" style="left:' + pct(e.date) + '%"></span>'; });
        (p.catalysts || []).forEach(function (c) { var x = pct(c.date); track += x > 55 ? '<span class="ts-flag is-left" style="right:' + (100 - x) + '%">' + esc(c.label) + '</span>' : '<span class="ts-flag" style="left:' + x + '%">' + esc(c.label) + '</span>'; });
        track += '<span class="ts-today" style="left:' + pct(TODAY) + '%"></span><span class="ts-review" style="left:' + pct(REVIEW) + '%"></span>';
        b.innerHTML = '<span class="ts-lane-label"><strong>' + esc(p.sponsor) + '</strong><span>' + esc(p.asset) + ' · ' + esc(p.indication) + '</span>' + (nn ? '<span><span class="ts-newtag">' + nn + ' new</span></span>' : '') + '</span><span class="ts-track">' + track + '</span>';
        b.addEventListener('click', function () { go('program', { pid: p.id, eid: null, aid: null }, true); say('Showing ' + p.asset + ', ' + p.events.length + ' events.'); });
        li.appendChild(b); ul.appendChild(li);
      });
      w.appendChild(ul);
      w.appendChild(el('div', 'ts-legend', '<span><i class="l-high"></i>High confidence</span><span><i class="l-medium"></i>Medium</span><span><i class="l-uncertain"></i>Uncertain</span><span><i class="l-new"></i>New since last review</span><span><i class="l-review"></i>Last review</span><span>Dashed line: today · Dotted flag: expected catalyst</span>'));
      $('[data-new]', w).addEventListener('click', function () { S.onlyNew = !S.onlyNew; render(false); var t = $('[data-new]', body); if (t) t.focus(); });
      return w;
    }

    /* program */
    function program() {
      var p = progById(S.pid), w = el('div', 'ts-view');
      var h = '<div class="ts-view-h"><h3 data-focus>' + esc(p.sponsor) + ' · ' + esc(p.asset) + '</h3></div>' +
        '<p class="ts-id"><span><b>Asset</b> ' + esc(p.asset) + '</span><span><b>Indication</b> ' + esc(p.indication) + '</span><span><b>Sponsor</b> ' + esc(p.sponsor) + '</span><span><b>First seen</b> ' + fmt(p.firstSeen, 'day') + '</span></p>';
      h += '<ol class="ts-ladder" aria-label="Development phase">';
      D.phases.forEach(function (ph, i) { var c = i < p.phase ? 'done' : i === p.phase ? 'now' : 'next'; h += '<li class="' + c + '">' + esc(ph) + (i === p.phase ? ' · now' : i > p.phase ? ' · projected' : '') + '</li>'; });
      h += '</ol><p class="ts-hint">Events accumulate on the program over time. Select a dot or a row.</p><div class="ts-ptl" id="ts-ptl"></div><ul class="ts-events" id="ts-events"></ul>';
      w.innerHTML = h;
      var ptl = $('#ts-ptl', w), ul = $('#ts-events', w);
      p.events.forEach(function (e) {
        var d = el('button', 'ts-dot ts-dot--' + e.conf + (e.isNew ? ' is-new' : '')); d.type = 'button'; d.style.left = pct(e.date) + '%'; d.setAttribute('aria-label', e.title + ', ' + fmt(e.date, e.precision) + ', ' + band(e.conf) + ' confidence');
        d.addEventListener('click', function () { openEvent(p, e); });
        ptl.appendChild(d);
      });
      ptl.insertAdjacentHTML('beforeend', '<span class="ts-today" style="left:' + pct(TODAY) + '%"></span><span class="ts-review" style="left:' + pct(REVIEW) + '%"></span>');
      p.events.slice().sort(function (a, b) { return Date.parse(b.date) - Date.parse(a.date); }).forEach(function (e) {
        var li = el('li'), b = el('button', 'ts-ev'); b.type = 'button';
        b.innerHTML = '<span class="ts-ev-date">' + fmt(e.date, e.precision) + '</span><span class="ts-ev-title">' + esc(e.title) + '</span><span class="ts-ev-meta"><span class="ts-verb">' + esc(e.verb) + '</span>' + conf(e.conf, e.score) + '<span>' + e.sources.length + (e.sources.length === 1 ? ' source' : ' sources') + '</span>' + (e.isNew ? '<span class="ts-newtag">New</span>' : '') + '</span>';
        b.addEventListener('click', function () { openEvent(p, e); });
        li.appendChild(b); ul.appendChild(li);
      });
      return w;
    }
    function openEvent(p, e) { go('event', { eid: e.id, aid: null }, true); say('Showing event: ' + e.title + '. ' + e.sources.length + ' contributing claims.'); }

    /* event + evidence */
    function event() {
      var p = progById(S.pid), e = p.events.filter(function (x) { return x.id === S.eid; })[0], w = el('div', 'ts-view');
      var dis = e.sources.some(function (s) { return s.role === 'disagrees'; });
      var h = '<div class="ts-ev-hero"><div class="ts-ev-meta"><span class="ts-verb">' + esc(e.verb) + '</span>' + conf(e.conf, e.score) + (e.isNew ? '<span class="ts-newtag">New since last review</span>' : '') + '</div><h3 data-focus>' + esc(e.title) + '</h3>' +
        '<p class="ts-stats"><span><b>Program</b> ' + esc(p.sponsor) + ' · ' + esc(p.asset) + '</span><span><b>Date</b> ' + fmt(e.date, e.precision) + ' <small>(' + e.precision + ' precision)</small></span><span><b>Reported by</b> ' + e.sources.length + (e.sources.length === 1 ? ' source' : ' sources') + '</span></p></div>';
      if (dis) h += '<p class="ts-banner" role="note"><b>Sources disagree.</b> ' + esc(e.note || 'At least one source disagrees with the anchor. The platform keeps both and shows the difference.') + '</p>';
      h += '<div class="ts-merge"><div><h4 class="ts-sec-label">' + e.sources.length + (e.sources.length === 1 ? ' claim' : ' claims') + ' <span>consolidated into one event</span></h4><ul class="ts-asserts" id="ts-asserts"></ul></div><div id="ts-evid" aria-live="polite"></div></div>';
      w.innerHTML = h;
      var ul = $('#ts-asserts', w);
      e.sources.forEach(function (s, i) {
        var src = D.sources[s.src], li = el('li'), b = el('button', 'ts-assert'); b.type = 'button'; b.setAttribute('aria-pressed', S.aid === i ? 'true' : 'false'); b.setAttribute('data-i', i);
        b.innerHTML = '<span class="ts-assert-claim">' + esc(s.claim) + '</span><span class="ts-assert-meta"><span class="ts-role ts-role--' + s.role + '">' + esc(s.role.replace('-', ' ')) + '</span><span>' + esc(src.name) + '</span><span>' + esc(src.type) + '</span></span>';
        b.addEventListener('click', function () { S.aid = i; $$('.ts-assert', w).forEach(function (x) { x.setAttribute('aria-pressed', x === b ? 'true' : 'false'); }); evidence(w, e, i); renderCrumbs(); say('Evidence for: ' + s.claim); });
        li.appendChild(b); ul.appendChild(li);
      });
      evidence(w, e, S.aid);
      return w;
    }
    function evidence(w, e, i) {
      var box = $('#ts-evid', w);
      if (i == null) { box.innerHTML = '<h4 class="ts-sec-label">Evidence</h4><p class="ts-hint">Select a claim to follow it back to the words that support it. Each claim keeps its own source, dates and confidence.</p>' + ents(e) + revs(e); return; }
      var s = e.sources[i], src = D.sources[s.src];
      var snip = esc(s.snippet).replace(esc(s.hl), '<mark>' + esc(s.hl) + '</mark>');
      box.innerHTML = '<h4 class="ts-sec-label">Provenance walk <span>claim → event, and back</span></h4>' +
        '<ol class="ts-walk"><li data-n="1"><strong>Source</strong>' + esc(src.name) + ' · ' + esc(src.type) + ' · ' + esc(src.authority) + '</li>' +
        '<li data-n="2"><strong>Document</strong>Published ' + fmt(s.published, 'day') + ' · ingested ' + fmt(s.ingested, 'day') + '</li>' +
        '<li data-n="3" class="is-snip"><strong>Snippet, verbatim</strong><blockquote>' + snip + '</blockquote></li>' +
        '<li data-n="4"><strong>Assertion</strong>' + esc(s.claim) + ' <span class="ts-role ts-role--' + s.role + '">' + esc(s.role.replace('-', ' ')) + '</span></li>' +
        '<li data-n="5"><strong>Event</strong>' + esc(e.title) + '</li></ol>' + revs(e) + ents(e);
    }
    function revs(e) { return '<h4 class="ts-sec-label">Revision history</h4><ol class="ts-revs">' + e.revisions.map(function (r) { return '<li><b>' + esc(r.kind) + '</b>' + esc(r.note) + '</li>'; }).join('') + '</ol>'; }
    function ents(e) { return '<h4 class="ts-sec-label">Entity matches</h4><table class="ts-ents"><thead><tr><th scope="col">Class</th><th scope="col">Entity</th><th scope="col">Confidence</th></tr></thead><tbody>' + e.entities.map(function (x) { return '<tr><td>' + esc(x.cls) + '</td><td>' + esc(x.name) + (x.note ? '<br><small>' + esc(x.note) + '</small>' : '') + '</td><td>' + conf(x.conf) + '</td></tr>'; }).join('') + '</tbody></table>'; }

    render(false);
  })();

  /* ---------- FLIP helper ---------- */
  function flip(nodes, mutate) {
    var first = nodes.map(function (n) { return n.getBoundingClientRect(); });
    mutate();
    if (reduce || !nodes[0].animate) return;
    nodes.forEach(function (n, i) {
      var b = n.getBoundingClientRect(), dx = first[i].left - b.left, dy = first[i].top - b.top;
      if (!dx && !dy) return;
      n.animate([{ transform: 'translate(' + dx + 'px,' + dy + 'px)' }, { transform: 'none' }], { duration: 520, easing: 'cubic-bezier(.32,.72,0,1)' });
    });
  }
  function seg(art, cb) {
    var btns = $$('.ts-seg', art);
    btns.forEach(function (b) { b.addEventListener('click', function () { var sib = b.parentNode; $$('.ts-seg', sib).forEach(function (x) { x.setAttribute('aria-pressed', x === b ? 'true' : 'false'); }); cb(b.getAttribute('data-mode')); }); });
  }

  /* ---------- 05 decisions ---------- */
  var ax = $('[data-dx="program"]');
  if (ax) (function () {
    var stage = $('[data-stage]', ax), feed = el('div', 'ts-feed'), items = [];
    D.feed.forEach(function (f) { var p = progById(f.program); var n = el('div', 'ts-fitem'); n.innerHTML = '<time>' + esc(f.day) + '</time><span>' + esc(f.text) + '</span><span class="ts-ptag">' + esc(p.asset) + '</span>'; n.setAttribute('data-p', f.program); items.push(n); });
    stage.appendChild(feed);
    function layout(mode) {
      feed.innerHTML = ''; feed.classList.toggle('is-grouped', mode === 'program');
      if (mode === 'feed') { items.forEach(function (n) { feed.appendChild(n); }); return; }
      D.programs.forEach(function (p) { var its = items.filter(function (n) { return n.getAttribute('data-p') === p.id; }); if (!its.length) return; var g = el('div', 'ts-fgroup'); g.appendChild(el('div', 'ts-fgroup-h', esc(p.sponsor) + ' · ' + esc(p.asset) + ' · ' + esc(D.phases[p.phase]))); its.forEach(function (n) { g.appendChild(n); }); feed.appendChild(g); });
    }
    layout('feed');
    seg(ax, function (m) { flip(items, function () { layout(m); }); });
  })();

  var tx = $('[data-dx="trail"]');
  if (tx) (function () {
    var stage = $('[data-stage]', tx), prog = progById('nw101'), ev = prog.events.filter(function (e) { return e.id === 'nw3'; })[0];
    var card = el('div', 'ts-card');
    card.innerHTML = '<span class="ts-verb">' + esc(ev.verb) + '</span> ' + conf(ev.conf, ev.score) + '<h4>' + esc(ev.title) + '</h4><p class="ts-stats"><span><b>Date</b> ' + fmt(ev.date, ev.precision) + '</span></p><ul class="ts-srcs"></ul><div data-note></div>';
    var ul = $('.ts-srcs', card), nodes = [];
    ev.sources.forEach(function (s, i) { var src = D.sources[s.src]; var li = el('li', 'ts-src'); li.innerHTML = '<span><b>' + esc(src.name) + '</b></span><span class="ts-role ts-role--' + s.role + '">' + esc(s.role.replace('-', ' ')) + '</span><small>' + esc(s.claim) + '</small>'; ul.appendChild(li); nodes.push(li); });
    stage.appendChild(card);
    function set(m) {
      var one = m === 'one';
      nodes.forEach(function (n, i) { n.classList.toggle('is-hidden', one && i > 0); n.setAttribute('aria-hidden', one && i > 0 ? 'true' : 'false'); });
      $('[data-note]', card).innerHTML = one ? '<p class="ts-warn"><b>Hidden:</b> one source gives a different day. With a single citation, a reader never sees the disagreement.</p>' : '<p class="ts-stats"><span><b>' + ev.sources.length + ' sources</b> · 3 agree or add context · 1 differs on the day</span></p>';
    }
    set('all'); seg(tx, set);
  })();

  var rx = $('[data-dx="route"]');
  if (rx) (function () {
    var stage = $('[data-stage]', rx), range = $('[data-range]', rx), out = $('[data-out]', rx), wrap = $('[data-range-wrap]', rx), mode = 'selective';
    var auto = el('div', 'ts-rcol'), q = el('div', 'ts-rcol ts-rcol--q');
    auto.innerHTML = '<h4>Linked automatically</h4><p class="ts-rcount" data-c>0</p><ul class="ts-rlist"></ul>';
    q.innerHTML = '<h4>Analyst queue</h4><p class="ts-rcount" data-c>0</p><ul class="ts-rlist"></ul>';
    stage.appendChild(auto); stage.appendChild(q);
    var items = D.matches.map(function (m) { var n = el('li', 'ts-match'); n.innerHTML = '<b>' + esc(m.mention) + '</b><span>' + m.score.toFixed(2) + '</span><small>matched to ' + esc(m.to) + '</small>'; n.setAttribute('data-s', m.score); return n; });
    function place() {
      var t = parseFloat(range.value); out.textContent = t.toFixed(2);
      var la = $('.ts-rlist', auto), lq = $('.ts-rlist', q); la.innerHTML = ''; lq.innerHTML = '';
      var na = 0, nq = 0;
      items.slice().sort(function (a, b) { return b.getAttribute('data-s') - a.getAttribute('data-s'); }).forEach(function (n) { var toQ = mode === 'all' || parseFloat(n.getAttribute('data-s')) < t; (toQ ? lq : la).appendChild(n); toQ ? nq++ : na++; });
      $('[data-c]', auto).textContent = na + ' of ' + items.length; $('[data-c]', q).textContent = nq + ' of ' + items.length;
    }
    place();
    range.addEventListener('input', function () { flip(items, place); });
    seg(rx, function (m) { mode = m; wrap.hidden = m === 'all'; flip(items, place); });
  })();
})();
