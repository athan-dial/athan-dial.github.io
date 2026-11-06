// Shared by both prototypes. Progressive enhancement only: the list is complete without it.
(() => {
  const root = document.querySelector('[data-atlas]');
  if (!root) return;
  const q = root.querySelector('[data-atlas-search]');
  const selects = [...root.querySelectorAll('[data-atlas-filter]')];
  const items = [...root.querySelectorAll('[data-atlas-item]')];
  const count = root.querySelector('[data-atlas-count]');
  const empty = root.querySelector('[data-atlas-empty]');
  root.querySelectorAll('[data-atlas-controls]').forEach((c) => (c.hidden = false));
  const apply = () => {
    const term = q.value.trim().toLowerCase();
    let shown = 0;
    for (const li of items) {
      const okText = !term || li.dataset.text.includes(term);
      const okFilter = selects.every((s) => !s.value || li.dataset[s.dataset.atlasFilter] === s.value);
      li.hidden = !(okText && okFilter);
      if (!li.hidden) shown++;
    }
    count.textContent = `${shown} of ${items.length} records`;
    empty.hidden = shown !== 0;
  };
  q.addEventListener('input', apply);
  selects.forEach((s) => s.addEventListener('change', apply));
})();
