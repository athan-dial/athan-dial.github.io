import { defineCollection } from 'astro:content';
import { file } from 'astro/loaders';
import { z } from 'astro/zod';

const atlas = defineCollection({
  // The shared JSON uses `id` for the display id and `slug` for the URL; Astro's loader reads `id` as the entry key.
  loader: file('src/content/atlas_sample.json', {
    parser: (text) => JSON.parse(text).map(({ id, slug, ...rest }: any) => ({ id: slug, recordId: id, ...rest })),
  }),
  schema: z.object({
    recordId: z.string(),
    title: z.string(),
    summary: z.string(),
    domain: z.enum(['Data', 'Product', 'Systems', 'Writing']),
    status: z.enum(['Shipped', 'In progress', 'Archived']),
    year: z.number().int(),
    tags: z.array(z.string()),
    body: z.string(),
  }),
});

export const collections = { atlas };
