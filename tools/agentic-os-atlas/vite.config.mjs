// Built from the pinned Arc checkout (see build.sh). ARC_DIR points at it; React, Vite and
// the patched @hudsonkit/arc library all resolve from there so there is one copy of each.
import {fileURLToPath} from 'node:url'
import path from 'node:path'
const here = path.dirname(fileURLToPath(import.meta.url))
const arc = path.resolve(process.env.ARC_DIR || path.join(here, '.arc/arc'))
const lib = path.join(arc, 'lib') + '/'
export default {
  root: here,
  base: './',
  resolve: {
    dedupe: ['react', 'react-dom'],
    alias: [
      {find: '@hudsonkit/arc/arc.css', replacement: lib + 'arc.css'},
      {find: '@hudsonkit/arc', replacement: lib + 'arc.es.js'},
      {find: /^react$/, replacement: path.join(arc, 'node_modules/react')},
      {find: /^react\/(.*)$/, replacement: path.join(arc, 'node_modules/react/$1')},
      {find: /^react-dom$/, replacement: path.join(arc, 'node_modules/react-dom')},
      {find: /^react-dom\/(.*)$/, replacement: path.join(arc, 'node_modules/react-dom/$1')},
    ],
  },
  server: {fs: {allow: [here, path.resolve(here, '../..'), arc]}},
  build: {
    outDir: process.env.ATLAS_OUT || path.resolve(here, '../../assets/atlas/agentic-os'),
    emptyOutDir: true,
    cssCodeSplit: false,
    rollupOptions: {
      input: path.join(here, process.env.ATLAS_ENTRY || 'src/atlas.jsx'),
      output: {entryFileNames: 'atlas.js', chunkFileNames: 'chunk-[hash].js', assetFileNames: 'atlas[extname]'},
    },
  },
}
