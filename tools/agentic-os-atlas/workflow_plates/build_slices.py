#!/usr/bin/env python3
"""Plate for the spec-to-build guide: the blocking edges between five work slices of Run comparison v1.

  python3 tools/agentic-os-atlas/workflow_plates/build_slices.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from plate_lib import Plate

p = Plate('wf-build-slices', 'Fig W5', 'Five slices and what blocks them', folder='workflow-plates')
p.node('s1', 'S1 Import instrument A export', 'tool', 0, 0.5, icon='FileInput', sub='Check: raw wells show',
       desc='Slice 1. An instrument A export is imported and every well shows its raw value. Nothing blocks it, so it starts first. The check imports a fixture export and counts the wells shown.')
p.node('s2', 'S2 Import instrument B export', 'tool', 1, 0, icon='FileInput', sub='Check: same well table',
       desc='Slice 2. An instrument B export, with its own column layout, is imported. It waits for slice 1. The check compares its well table with the equivalent instrument A fixture.')
p.node('s3', 'S3 Normalise to % of control', 'tool', 1, 1, icon='Percent', sub='Check: worked plate',
       desc="Slice 3. Each well is shown as a percentage of its plate's control wells. It waits for slice 1 only, so it can run beside slice 2. The check uses a plate with known control wells.")
p.node('s4', 'S4 Compare with the reference run', 'tool', 2, 0.5, icon='Layers', sub='Check: overlay values',
       desc='Slice 4. A run is overlaid on the reference run for its protocol version. It waits for slices 2 and 3. The check overlays two fixture runs and reads the differences.')
p.node('s5', 'S5 Flag wells outside tolerance', 'tool', 2, 1.5, icon='Flag', sub='Check: the exact limit',
       desc='Slice 5. Wells outside tolerance are flagged. It waits for slice 4. The check includes a well exactly at the limit, which must not flag.')
p.edge('s1', 's2', 'right', 'left', 'blocks', 'normal', 'step')
p.edge('s1', 's3', 'right', 'left', 'blocks', 'normal', 'step')
p.edge('s2', 's4', 'right', 'left', 'blocks', 'normal', 'step')
p.edge('s3', 's4', 'right', 'left', 'blocks', 'normal', 'step')
p.edge('s4', 's5', 'bottom', 'top', 'blocks')
p.save()
