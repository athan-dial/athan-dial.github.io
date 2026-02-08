#!/usr/bin/env python3
"""
Transform vault frontmatter to Quartz-compatible format.

Transformations:
- Remove: status, idea_score fields
- Rename: created → date, modified → lastmod
- Add: draft: false

Usage:
  python3 transform-frontmatter.py <input-file>
  python3 transform-frontmatter.py < input.md

Output: Transformed markdown to stdout
"""

import sys
import re
from pathlib import Path

# Check if python-frontmatter is available
try:
    import frontmatter
    HAS_FRONTMATTER = True
except ImportError:
    HAS_FRONTMATTER = False


def transform_with_library(content: str) -> str:
    """Transform using python-frontmatter library."""
    try:
        post = frontmatter.loads(content)
    except Exception as e:
        print(f"Error parsing frontmatter: {e}", file=sys.stderr)
        sys.exit(1)

    # Access metadata dict
    metadata = post.metadata

    # Remove fields
    metadata.pop('status', None)
    metadata.pop('idea_score', None)

    # Rename fields
    if 'created' in metadata:
        metadata['date'] = metadata.pop('created')

    if 'modified' in metadata:
        metadata['lastmod'] = metadata.pop('modified')

    # Add draft: false
    metadata['draft'] = False

    return frontmatter.dumps(post)


def transform_with_regex(content: str) -> str:
    """Transform using regex-based parsing (fallback when library not available)."""

    # Extract frontmatter and body
    parts = content.split('---', 2)
    if len(parts) < 3:
        # No frontmatter or malformed
        print("Error: No valid frontmatter found", file=sys.stderr)
        sys.exit(1)

    frontmatter_text = parts[1]
    body = parts[2]

    # Parse frontmatter line by line
    lines = frontmatter_text.strip().split('\n')
    transformed_lines = []
    skip_next = False

    for line in lines:
        if skip_next:
            skip_next = False
            continue

        # Remove status and idea_score fields
        if re.match(r'^status:', line) or re.match(r'^idea_score:', line):
            continue

        # Rename created → date
        if re.match(r'^created:', line):
            line = line.replace('created:', 'date:', 1)

        # Rename modified → lastmod
        if re.match(r'^modified:', line):
            line = line.replace('modified:', 'lastmod:', 1)

        transformed_lines.append(line)

    # Add draft: false if not present
    has_draft = any(re.match(r'^draft:', line) for line in transformed_lines)
    if not has_draft:
        transformed_lines.append('draft: false')

    # Reconstruct markdown
    new_frontmatter = '\n'.join(transformed_lines)
    return f"---\n{new_frontmatter}\n---{body}"


def main():
    # Read input
    if len(sys.argv) > 1:
        input_path = Path(sys.argv[1])
        if not input_path.exists():
            print(f"Error: File not found: {input_path}", file=sys.stderr)
            sys.exit(1)
        content = input_path.read_text(encoding='utf-8')
    else:
        # Read from stdin
        content = sys.stdin.read()

    # Transform using available method
    if HAS_FRONTMATTER:
        result = transform_with_library(content)
    else:
        result = transform_with_regex(content)

    # Write to stdout
    sys.stdout.write(result)


if __name__ == '__main__':
    main()
