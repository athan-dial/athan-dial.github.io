// Optional enhancement. Resolves the ink rule above Atlas groups and Work case files the first time
// they scroll into view. Content is never hidden: without this script, or with reduced motion, the
// rules simply render complete.
(() => {
  if (!('IntersectionObserver' in window) || matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  const targets = document.querySelectorAll('.atlas-group, .fn-case');
  if (!targets.length) return;
  document.documentElement.classList.add('fn-motion');
  const io = new IntersectionObserver((entries) => {
    for (const e of entries) if (e.isIntersecting) { e.target.classList.add('is-entered'); io.unobserve(e.target); }
  }, { rootMargin: '0px 0px -12% 0px' });
  targets.forEach((t) => io.observe(t));
})();
