#!/usr/bin/env python3
"""Render TALOS's native diagram with OpenFlowKit 0.3.0 (Node 20.11+)."""
import json
import subprocess
from pathlib import Path
root = Path(__file__).resolve().parents[1]
folder = root / 'assets/work-products/talos'
cli = ['npx', '--yes', 'openflowkit@0.3.0']
subprocess.run(cli + ['validate', str(folder / 'workflow.ofk'), '--strict'], check=True)
subprocess.run(cli + ['convert', str(folder / 'workflow.ofk'), '-o', str(folder / 'workflow.openflow.json'), '--strict'], check=True)
path = folder / 'workflow.openflow.json'
doc = json.loads(path.read_text())
# The compiler retains its auto-layout frame when pins move the nodes. Fit that
# frame to this deliberately composed two-row layout before native SVG export.
doc['pages'][0]['nodes'][0]['size'] = {'width': 1100, 'height': 520}
path.write_text(json.dumps(doc, indent=2) + '\n')
result = subprocess.run(cli + ['op', 'export', '--doc', str(path), '--args', '{"format":"svg"}'], check=True, capture_output=True, text=True)
(folder / 'workflow.svg').write_text(json.loads(result.stdout)['output']['files'][0]['text'])
