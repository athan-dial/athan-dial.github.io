#!/bin/bash
# Usage: build_metrics.sh <hugo_dir> <astro_dir>   (scratch copies; see out/REPRODUCE.md)
# Reports: cold/warm build times (5 runs each), output size, gzip bytes of the two slice pages' assets.
set -e
H=$1; A=$2
t() { python3 - "$@" <<'PY'
import subprocess,sys,time,statistics
cmd=sys.argv[1]; n=int(sys.argv[2]); pre=sys.argv[3] if len(sys.argv)>3 else None
ts=[]
for _ in range(n):
    if pre: subprocess.run(pre,shell=True,check=True,capture_output=True)
    s=time.time(); subprocess.run(cmd,shell=True,check=True,capture_output=True); ts.append(time.time()-s)
print("runs(s):",[round(x,2) for x in ts],"median:",round(statistics.median(ts),2))
PY
}
echo "## Hugo full-site build (this repo + slice): hugo --gc --minify"
(cd $H && hugo version | cut -c1-40; t "hugo --gc --minify -d /tmp/h-bm" 5 "rm -rf /tmp/h-bm resources/_gen")
echo "## Astro slice build: npx astro build (rm -rf dist node_modules/.astro first = cold cache)"
(cd $A && npx astro --version; t "npx astro build" 5 "rm -rf dist node_modules/.astro .astro")
echo "## Output size"
du -sk /tmp/h-bm | awk '{print "hugo public/ KB:",$1}'; du -sk $A/dist | awk '{print "astro dist/ KB:",$1}'
echo "## Slice asset bytes (raw / gzip)"
for f in $H/../../../../../tmp/h-bm/atlas/index.html; do :; done
python3 - "$H" "$A" <<'PY'
import sys,glob,gzip,os,re
def sz(p): b=open(p,'rb').read(); return len(b),len(gzip.compress(b,9))
H="/tmp/h-bm"; A=sys.argv[2]+"/dist"
for name,root in (("hugo",H),("astro",A)):
    html=open(root+"/atlas/index.html").read()
    css=re.findall(r'href=["\']?(/[^"\' >]+\.css)',html); js=re.findall(r'src=["\']?(/[^"\' >]+\.js)',html)
    rows=[("list html",root+"/atlas/index.html"),("detail html",root+"/atlas/sample-alpha/index.html")]+[("css "+c,root+c) for c in css]+[("js "+j,root+j) for j in js]
    print(name,"| inline <script> bytes in list html:",sum(len(m) for m in re.findall(r'<script[^>]*>(.*?)</script>',html,re.S)))
    for l,p in rows:
        r,g=sz(p); print(f"  {l}: {r} raw, {g} gzip")
PY
