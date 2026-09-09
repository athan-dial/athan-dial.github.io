(() => {
  const chapters = Array.from(document.querySelectorAll('[data-fn-chapter]'));
  const links = Array.from(document.querySelectorAll('[data-fn-index-link]'));

  if (!chapters.length) return;

  document.documentElement.classList.add('fn-enhanced');

  const linksById = new Map(
    links.map((link) => [link.getAttribute('href')?.replace(/^#/, ''), link])
  );

  const setCurrent = (id) => {
    links.forEach((link) => link.removeAttribute('aria-current'));
    const current = linksById.get(id);
    if (current) current.setAttribute('aria-current', 'location');
  };

  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (reducedMotion || !('IntersectionObserver' in window)) {
    chapters.forEach((chapter) => chapter.classList.add('fn-chapter--entered'));
    setCurrent(chapters[0].id);
    return;
  }

  const active = new Map();
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('fn-chapter--entered');
          active.set(entry.target.id, entry.intersectionRatio);
        } else {
          active.delete(entry.target.id);
        }
      });

      if (!active.size) return;

      const current = Array.from(active.entries())
        .sort((a, b) => b[1] - a[1])[0]?.[0];
      if (current) setCurrent(current);
    },
    {
      rootMargin: '-28% 0px -48% 0px',
      threshold: [0.05, 0.2, 0.4, 0.6, 0.8],
    }
  );

  chapters.forEach((chapter) => observer.observe(chapter));
})();
