import { getCollection } from 'astro:content';
// The integration emits sitemap-index.xml; the live site's robots.txt points at /sitemap.xml, so keep that URL.
export async function GET({ site }) {
  const urls = ['/atlas/', ...(await getCollection('atlas')).map((r) => `/atlas/${r.id}/`)];
  const body = `<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${urls.map((u) => `<url><loc>${new URL(u, site)}</loc></url>`).join('')}</urlset>`;
  return new Response(body, { headers: { 'Content-Type': 'application/xml' } });
}
