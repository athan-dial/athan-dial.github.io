#!/usr/bin/env node

/**
 * extract-article.mjs
 *
 * Fetches a web page and extracts article content using @mozilla/readability.
 * Outputs JSON with title, byline, excerpt, content (markdown), url, siteName.
 *
 * Usage: node extract-article.mjs "https://example.com/article"
 */

import { parseHTML } from 'linkedom';
import { Readability } from '@mozilla/readability';
import TurndownService from 'turndown';

const url = process.argv[2];

if (!url) {
  console.error('Error: URL required');
  console.error('Usage: node extract-article.mjs "https://example.com/article"');
  process.exit(1);
}

// Validate URL
try {
  new URL(url);
} catch (error) {
  console.error(`Error: Invalid URL: ${url}`);
  process.exit(1);
}

try {
  // Fetch the page
  const response = await fetch(url);

  if (!response.ok) {
    console.error(`Error: HTTP ${response.status} ${response.statusText}`);
    process.exit(1);
  }

  const html = await response.text();

  // Parse HTML with linkedom (lightweight DOM implementation)
  const { document } = parseHTML(html);

  // Extract article with Readability
  const reader = new Readability(document, {
    debug: false,
    charThreshold: 500
  });

  const article = reader.parse();

  if (!article) {
    console.error('Error: Could not extract article content (possible paywall or non-article page)');
    process.exit(1);
  }

  // Convert HTML content to markdown
  const turndownService = new TurndownService({
    headingStyle: 'atx',
    codeBlockStyle: 'fenced',
    emDelimiter: '*'
  });

  const markdownContent = turndownService.turndown(article.content);

  // Output JSON
  const result = {
    title: article.title || '',
    byline: article.byline || '',
    excerpt: article.excerpt || '',
    content: markdownContent,
    url: url,
    siteName: article.siteName || ''
  };

  console.log(JSON.stringify(result, null, 2));

} catch (error) {
  console.error(`Error: ${error.message}`);
  process.exit(1);
}
