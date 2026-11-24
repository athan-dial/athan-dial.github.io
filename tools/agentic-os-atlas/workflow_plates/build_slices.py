#!/usr/bin/env python3
"""Plate for the spec-to-build guide: the blocking edges between five invented work slices.

  python3 tools/agentic-os-atlas/workflow_plates/build_slices.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from plate_lib import Plate

p = Plate('wf-build-slices', 'WF-BUILD', 'Five slices and what blocks them', folder='workflow-plates')
p.node('s1', 'Post a report', 'tool', 0, 0, icon='PenLine', sub='Check: round trip',
       desc='Slice 1. A hiker posts a report and it shows on that trail page. Nothing blocks it, so it starts first. The check posts a report and reads it back.')
p.node('s2', 'List a trail\'s reports', 'tool', 1, 0, icon='List', sub='Check: newest first',
       desc='Slice 2. A trail page lists its reports, newest first. It waits for slice 1. The check seeds three reports and reads the order.')
p.node('s4', 'Flag a wrong report', 'tool', 0, 1, icon='Flag', sub='Check: two flags hide it',
       desc='Slice 4. Two flags hide a report. It waits for slice 1 only, so it can run beside slice 2. The check flags a stored report twice.')
p.node('s3', 'Hide old reports', 'tool', 2, 0, icon='CalendarX', sub='Check: fixed clock',
       desc='Slice 3. Reports older than 14 days drop off the page. It waits for slice 2. The check runs with a fixed clock.')
p.node('s5', 'Weekly digest', 'tool', 2, 1, icon='Mail', sub='Check: fixed sample',
       desc='Slice 5. A weekly text summary of recent reports. It waits for slices 2 and 3. The check compares the digest of fixed sample data with the expected text.')
p.edge('s1', 's2', 'right', 'left', 'blocks')
p.edge('s1', 's4', 'bottom', 'top', 'blocks')
p.edge('s2', 's3', 'right', 'left', 'blocks')
p.edge('s3', 's5', 'bottom', 'top', 'blocks')
p.edge('s2', 's5', 'bottom', 'left', 'blocks', curve='step')
p.save()
