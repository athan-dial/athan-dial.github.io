// Progressive enhancement only: every group and card is in the HTML without it.
(() => {
  const root = document.querySelector('[data-atlas]');
  if (!root) return;
  const q = root.querySelector('[data-atlas-search]');
  const clear = root.querySelector('[data-atlas-clear]');
  const items = [...root.querySelectorAll('[data-atlas-item]')];
  const groups = [...root.querySelectorAll('[data-atlas-group]')];
  const mores = [...root.querySelectorAll('[data-atlas-more]')];
  const count = root.querySelector('[data-atlas-count]');
  const empty = root.querySelector('[data-atlas-empty]');
  root.querySelectorAll('[data-atlas-controls]').forEach((c) => (c.hidden = false));
  const apply = () => {
    const term = q.value.trim().toLowerCase();
    let shown = 0;
    for (const li of items) {
      li.hidden = !!term && !li.dataset.text.includes(term);
      if (!li.hidden) shown++;
    }
    for (const m of mores) m.open = !!term;
    for (const g of groups) g.hidden = !g.querySelector('[data-atlas-item]:not([hidden])');
    count.textContent = `${shown} of ${items.length} systems`;
    empty.hidden = shown !== 0;
    clear.hidden = !term;
    const url = new URL(location.href);
    term ? url.searchParams.set('q', q.value.trim()) : url.searchParams.delete('q');
    history.replaceState(null, '', url);
  };
  q.addEventListener('input', apply);
  clear.addEventListener('click', () => { q.value = ''; apply(); q.focus(); });
  const initial = new URLSearchParams(location.search).get('q');
  if (initial) { q.value = initial; apply(); }
})();
