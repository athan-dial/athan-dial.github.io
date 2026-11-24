"""Serve a locally built Arc Studio (local review only; never published).

Usage: python3 studio-serve.py /path/to/studio-build [--port 8768]
Then open http://localhost:8768/studio/editor and use "Open diagram" on a plate from
data/agentic-os/plates/. Studio edits one plate at a time and saves by download.
"""
import argparse, os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        path = urlsplit(self.path).path
        if path.startswith('/studio') and not Path(self.translate_path(path)).is_file():
            self.path = '/studio/index.html'   # single-page app routes
        super().do_GET()

if __name__ == '__main__':
    ap = argparse.ArgumentParser(); ap.add_argument('build'); ap.add_argument('--port', type=int, default=8768)
    a = ap.parse_args()
    root = Path('.studio-root'); root.mkdir(exist_ok=True)
    link = root / 'studio'
    if link.is_symlink() or link.exists(): link.unlink()
    link.symlink_to(Path(a.build).resolve())
    os.chdir(root)
    print(f'Studio at http://localhost:{a.port}/studio/editor', flush=True)
    ThreadingHTTPServer(('127.0.0.1', a.port), Handler).serve_forever()
