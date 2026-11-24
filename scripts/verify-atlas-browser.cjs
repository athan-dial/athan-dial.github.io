// Architecture atlas interactions on the draft page: the seven view tabs, native drill-down by clicking
// nodes, breadcrumb return, zoom, drag-to-pan and keyboard access. Scoped to #agentic-os-atlas because
// the page also carries small workflow diagrams that reuse node ids.
//   node scripts/verify-atlas-browser.cjs http://127.0.0.1:8771/work/agentic-operating-system/
const {chromium}=require('playwright');
(async()=>{const url=process.argv[2];const b=await chromium.launch();const p=await b.newPage({viewport:{width:1440,height:900}});
const res=[];const ok=(n,v,d='')=>{res.push((v?'PASS':'FAIL')+' '+n+(d?' — '+d:''));};
const logs=[];p.on('pageerror',e=>logs.push('PAGEERROR '+e.message));p.on('console',m=>{if(m.type()==='error')logs.push('console.error '+m.text())});
await p.goto(url,{waitUntil:'networkidle'});await p.waitForTimeout(1000);
const heading=async()=>p.locator('#agentic-os-atlas .atlas__title').innerText();
const trail=async()=>p.locator('#agentic-os-atlas [data-arc-altitude-trail]').first().innerText().catch(()=>'(none)');
ok('initial view is overview', (await heading()).startsWith('Expert judgment'), await heading());
// tabs
for(const [name,expect] of [['Thinking','Intent becomes'],['Making','A decision becomes'],['Sharing','Work only counts'],['Governed execution','Autonomous work'],['Human authorization','Autonomy ends'],['Durable learning','Context carries'],['Overview','Expert judgment']]){
  await p.locator('#agentic-os-atlas .atlas__views').getByRole('button',{name:new RegExp(name)}).first().click();await p.waitForTimeout(500);
  ok('tab '+name+' -> heading', (await heading()).startsWith(expect), (await heading())+' | hash='+(await p.evaluate(()=>location.hash))+' | trail='+(await trail()).replace(/\n/g,' '));
}
// native drill-down by clicking nodes
const clickNode=async(id)=>{const n=p.locator(`#agentic-os-atlas [data-arc-node-id="${id}"]`);await n.click();await p.waitForTimeout(900)};
await clickNode('making'); ok('click Making node -> Making view', (await heading()).startsWith('A decision becomes'), 'trail='+(await trail()).replace(/\n/g,' '));
await clickNode('ready'); ok('click Ready-to-run gate -> Governed execution', (await heading()).startsWith('Autonomous work'), 'trail='+(await trail()).replace(/\n/g,' '));
// breadcrumb back
const crumbs=await p.locator('#agentic-os-atlas [data-arc-altitude-trail] button, [data-arc-altitude-trail] a').allInnerTexts();ok('breadcrumb has ancestors', crumbs.length>=2, JSON.stringify(crumbs));
if(crumbs.length){await p.locator('#agentic-os-atlas [data-arc-altitude-trail] button, [data-arc-altitude-trail] a').first().click();await p.waitForTimeout(800);ok('breadcrumb -> root', (await heading()).startsWith('Expert judgment'), await heading());}
// thinking -> authorization, sharing -> learning
await clickNode('thinking');await clickNode('decision');ok('Thinking -> Decide -> Human authorization', (await heading()).startsWith('Autonomy ends'), 'trail='+(await trail()).replace(/\n/g,' '));
await p.locator('#agentic-os-atlas .atlas__views').getByRole('button',{name:/Overview/}).first().click();await p.waitForTimeout(500);
await clickNode('sharing');await clickNode('learn');ok('Sharing -> Lessons -> Durable learning', (await heading()).startsWith('Context carries'), 'trail='+(await trail()).replace(/\n/g,' '));
// zoom controls
await p.locator('#agentic-os-atlas .atlas__views').getByRole('button',{name:/Overview/}).first().click();await p.waitForTimeout(600);
const zoomBtns=await p.locator('#agentic-os-atlas .atlas__frame button').evaluateAll(els=>els.map(e=>({label:e.getAttribute('aria-label')||e.title||e.textContent.trim(),w:Math.round(e.getBoundingClientRect().width),h:Math.round(e.getBoundingClientRect().height)})));
ok('zoom/frame buttons have names', zoomBtns.length>0 && zoomBtns.every(b=>b.label), JSON.stringify(zoomBtns));
const pct=async()=>p.locator('#agentic-os-atlas .atlas__frame').innerText().then(t=>(t.match(/(\d+)%/)||[])[1]);
const before=await pct();const zin=p.locator('#agentic-os-atlas .atlas__frame button').last();await zin.click();await p.waitForTimeout(400);const after=await pct();ok('zoom in changes scale', before!==after, before+'% -> '+after+'%');
// pan by drag
const fr=await p.locator('#agentic-os-atlas .atlas__frame').boundingBox();await p.evaluate(()=>window.scrollTo(0,document.querySelector('#views').getBoundingClientRect().top+scrollY-70));await p.waitForTimeout(300);const g=p.locator('#agentic-os-atlas [data-arc-node-id="thinking"]');const b0=await g.boundingBox();
await p.evaluate(()=>window.scrollTo(0,document.querySelector('#views').getBoundingClientRect().top+scrollY-70));await p.waitForTimeout(300);const fr2=await p.locator('#agentic-os-atlas .atlas__frame').boundingBox();await p.mouse.move(fr2.x+80,fr2.y+30);await p.mouse.down();await p.mouse.move(fr2.x-40,fr2.y+70,{steps:10});await p.mouse.up();await p.waitForTimeout(300);const b1=await g.boundingBox();
ok('drag pans the canvas', Math.abs(b1.x-b0.x)>50, `x ${Math.round(b0.x)} -> ${Math.round(b1.x)}`);
// keyboard
await p.reload({waitUntil:'networkidle'});await p.waitForTimeout(800);
await p.locator('#agentic-os-atlas .atlas__views').getByRole('button',{name:/Thinking/}).first().focus();await p.keyboard.press('Enter');await p.waitForTimeout(500);ok('keyboard Enter on tab switches view',(await heading()).startsWith('Intent becomes'),await heading());
const focusables=await p.evaluate(()=>[...document.querySelectorAll('#agentic-os-atlas .atlas__frame [tabindex],#agentic-os-atlas .atlas__frame button,#agentic-os-atlas .atlas__frame a,#agentic-os-atlas .atlas__frame [role=button]')].map(e=>e.tagName+':'+(e.getAttribute('role')||'')+':'+(e.getAttribute('tabindex')||'')+':'+(e.getAttribute('aria-label')||e.getAttribute('data-arc-node-id')||'').slice(0,20)));
ok('focusable elements inside plate', focusables.length>0, focusables.length+' e.g. '+focusables.slice(0,6).join(' | '));
console.log(res.join('\n'));console.log(logs.join('\n')||'no console errors');await b.close();if(res.some(r=>r.startsWith('FAIL'))||logs.length)process.exit(1)})();
