(() => {
  const chapters = Array.from(document.querySelectorAll('[data-fn-chapter]'));
  const links = Array.from(document.querySelectorAll('[data-fn-index-link]'));

  if (!chapters.length) return;

  document.documentElement.classList.add('fn-enhanced');

  const linksById = new Map(
    links.map((link) => [link.getAttribute('href')?.replace(/^#/, ''), link])
  );

  let currentId = null;
  const setCurrent = (id) => {
    if (!id || id === currentId) return;
    currentId = id;
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

  // Entered state only. Ratios are not used to pick the current chapter: a tall chapter
  // never reaches the ratio a short one does, and cached ratios go stale between
  // thresholds, which left the index lagging the reader by two chapters.
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) entry.target.classList.add('fn-chapter--entered');
      });
    },
    { rootMargin: '0px 0px -15% 0px', threshold: 0.02 }
  );
  chapters.forEach((chapter) => observer.observe(chapter));

  // The current chapter is the last one whose top has crossed the reading line.
  const readingLine = () => window.innerHeight * 0.3;
  const update = () => {
    // At the foot of the page the last chapter can never reach the reading line, so
    // clamp to it rather than leaving the index stuck on the previous chapter.
    const atBottom =
      window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 2;
    if (atBottom) {
      setCurrent(chapters[chapters.length - 1].id);
      return;
    }
    const line = readingLine();
    let found = chapters[0];
    for (const chapter of chapters) {
      if (chapter.getBoundingClientRect().top <= line) found = chapter;
    }
    setCurrent(found.id);
  };

  let ticking = false;
  const onScroll = () => {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(() => {
      ticking = false;
      update();
    });
  };

  window.addEventListener('scroll', onScroll, { passive: true });
  window.addEventListener('resize', onScroll, { passive: true });
  update();
})();
