import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://athan-dial.github.io',
  trailingSlash: 'always',
  build: { format: 'directory' },
});
