/* TALOS gallery: opens each tile in its native <dialog>.
   Esc closes (native), backdrop click closes, focus returns to the tile.
   No dependencies, no globals. */
(function () {
  'use strict';

  function init(root) {
    if (!root || root.getAttribute('data-tg-init') === '1') { return; }
    root.setAttribute('data-tg-init', '1');

    var opener = null;
    var downOnBackdrop = false;
    var canModal = typeof HTMLDialogElement === 'function' &&
      typeof HTMLDialogElement.prototype.showModal === 'function';

    function open(dialog, trigger) {
      opener = trigger;
      if (canModal) { dialog.showModal(); } else { dialog.setAttribute('open', ''); }
      var body = dialog.querySelector('.tg-dbody');
      if (body) { body.scrollTop = 0; }
    }

    function close(dialog) {
      if (canModal) { dialog.close(); } else { dialog.removeAttribute('open'); restoreFocus(); }
    }

    function restoreFocus() {
      if (opener && typeof opener.focus === 'function') { opener.focus(); }
      opener = null;
    }

    var tiles = root.querySelectorAll('[data-tg-open]');
    Array.prototype.forEach.call(tiles, function (tile) {
      var dialog = document.getElementById(tile.getAttribute('data-tg-open'));
      if (!dialog) { return; }
      tile.addEventListener('click', function () { open(dialog, tile); });
    });

    // Live miniatures: clone the real artifact into the tile and scale it to fit.
    var minis = [];
    Array.prototype.forEach.call(tiles, function (tile) {
      var dialog = document.getElementById(tile.getAttribute('data-tg-open'));
      var mini = tile.querySelector('.tg-mini');
      var src = dialog && dialog.querySelector('.tg-region > *');
      if (!mini || !src) { return; }
      var live = document.createElement('div');
      live.className = 'tg-mini-live';
      var copy = src.cloneNode(true);
      live.appendChild(copy);
      // Keep ids unique: suffix every id in the clone and every reference to it.
      var withId = [copy].concat(Array.prototype.slice.call(copy.querySelectorAll('[id]'))).filter(function (n) { return n.id; });
      var ids = {};
      withId.forEach(function (n) { ids[n.id] = true; n.id = n.id + '-m'; });
      Array.prototype.forEach.call(copy.querySelectorAll('*'), function (n) {
        Array.prototype.forEach.call(n.attributes, function (a) {
          var v = a.value, nv = v;
          if (/url\(#/.test(v)) { nv = v.replace(/url\(#([^)]+)\)/g, function (m, id) { return ids[id] ? 'url(#' + id + '-m)' : m; }); }
          else if ((a.name === 'href' || a.name === 'xlink:href') && v.charAt(0) === '#' && ids[v.slice(1)]) { nv = v + '-m'; }
          else if (a.name === 'aria-labelledby' || a.name === 'aria-describedby' || a.name === 'aria-controls') { nv = v.split(/\s+/).map(function (t) { return ids[t] ? t + '-m' : t; }).join(' '); }
          if (nv !== v) { n.setAttribute(a.name, nv); }
        });
      });
      Array.prototype.forEach.call(live.querySelectorAll('a, button, [tabindex]'), function (n) { n.setAttribute('tabindex', '-1'); });
      mini.innerHTML = '';
      mini.className = 'tg-mini tg-mini--live';
      mini.appendChild(live);
      minis.push({ box: mini, live: live });
    });
    function fit() {
      minis.forEach(function (m) {
        var w = m.box.clientWidth;
        if (w) { m.live.style.transform = 'scale(' + (w / 900) + ')'; }
      });
    }
    fit();
    window.addEventListener('resize', fit);
    if (window.ResizeObserver) { var ro = new ResizeObserver(fit); minis.forEach(function (m) { ro.observe(m.box); }); }

    var dialogs = root.querySelectorAll('.tg-dialog');
    Array.prototype.forEach.call(dialogs, function (dialog) {
      var closers = dialog.querySelectorAll('[data-tg-close]');
      Array.prototype.forEach.call(closers, function (btn) {
        btn.addEventListener('click', function () { close(dialog); });
      });

      // Backdrop click: the dialog element itself is the target only outside the frame.
      dialog.addEventListener('mousedown', function (e) { downOnBackdrop = (e.target === dialog); });
      dialog.addEventListener('click', function (e) {
        if (e.target === dialog && downOnBackdrop) { close(dialog); }
        downOnBackdrop = false;
      });

      // Native close (Esc, form, or close()): return focus to the tile.
      dialog.addEventListener('close', restoreFocus);

      // Browsers without showModal have no native Esc.
      if (!canModal) {
        dialog.addEventListener('keydown', function (e) {
          if (e.key === 'Escape' || e.keyCode === 27) { close(dialog); }
        });
      }
    });

    root.className += ' tg-ready';
  }

  function boot() {
    var roots = document.querySelectorAll('.tg');
    Array.prototype.forEach.call(roots, init);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
}());
