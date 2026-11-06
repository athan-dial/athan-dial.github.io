#!/bin/bash
# usage: status.sh state "summary" "next"
cd "$(dirname "$0")/.."
python3 - "$@" <<'PY'
import json,sys,datetime,os
state,summary,nxt=sys.argv[1:4]
needs=json.load(open('out/needs.json')) if os.path.exists('out/needs.json') else []
d={"schema":1,"runner":"claude","state":state,"summary":summary,"next":nxt,"needs_athan":needs,
"last_report":"out/REPORT.md" if os.path.exists('out/REPORT.md') else "none yet","evidence":[],
"updated_at":datetime.datetime.now().astimezone().isoformat(timespec='seconds')}
if os.path.exists('out/evidence.json'): d["evidence"]=json.load(open('out/evidence.json'))
json.dump(d,open('out/STATUS.json.tmp','w'),indent=1)
os.replace('out/STATUS.json.tmp','out/STATUS.json')
PY
orca worktree set --worktree active --comment "$1: ${2:0:70}" >/dev/null 2>&1
