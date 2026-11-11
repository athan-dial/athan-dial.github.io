import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';
// Same public path as the Hugo feed (/index.xml), so existing subscribers keep working.
export async function GET(context) {
  const records = await getCollection('atlas');
  return rss({
    title: 'Athan Dial',
    description: 'Prototype feed of synthetic sample records.',
    site: context.site,
    items: records.map((r) => ({ title: r.data.title, link: `/atlas/${r.id}/`, description: r.data.summary, pubDate: new Date(`${r.data.year}-01-01`) })),
    customData: '<atom:link href="https://athan-dial.github.io/index.xml" rel="self" type="application/rss+xml"/>',
    xmlns: { atom: 'http://www.w3.org/2005/Atom' },
  });
}
