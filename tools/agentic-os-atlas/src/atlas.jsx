import React, {useCallback, useEffect, useMemo, useRef, useState} from 'react'
import {createRoot} from 'react-dom/client'
import {ArcDiagram} from '@hudsonkit/arc'
import '@hudsonkit/arc/arc.css'
import './frame.css'
import style from '../../../data/agentic-os/style.json'
import views from '../../../data/agentic-os/views.json'

// One canonical dataset: the same plates the Hugo template reads for the no-JS text.
const files = import.meta.glob('../../../data/agentic-os/plates/*.arc.json', {eager: true, import: 'default'})
const plates = Object.fromEntries(Object.entries(files).map(([p, d]) => [p.split('/').pop().replace('.arc.json', ''), d]))

// Path of {diagram, node} hops that opens each plate, derived from the child links.
function pathsFor(root) {
  const paths = {[root]: []}
  const queue = [root]
  while (queue.length) {
    const id = queue.shift()
    for (const [node, nd] of Object.entries(plates[id].nodeData)) {
      if (nd.child && !(nd.child in paths)) {
        paths[nd.child] = [...paths[id], {diagram: id, node}]
        queue.push(nd.child)
      }
    }
  }
  return paths
}
const root = views.root
const paths = pathsFor(root)
const viewAt = path => (path.length ? plates[path[path.length - 1].diagram].nodeData[path[path.length - 1].node].child : root)

function initialView() {
  const id = decodeURIComponent((location.hash || '').replace(/^#/, ''))
  return views.views.some(v => v.id === id) ? id : root
}

function Atlas() {
  const [view, setView] = useState(initialView)
  const [nonce, setNonce] = useState(0)
  const live = useRef(null)
  const meta = views.views.find(v => v.id === view)
  const others = useMemo(() => Object.fromEntries(Object.entries(plates).filter(([id]) => id !== root)), [])

  // Arc opens a child plate on click only. Give those nodes a keyboard path too: focusable,
  // announced as buttons, opened with Enter or Space. The seven view buttons above stay
  // the primary keyboard route; this makes the in-diagram route match.
  const frame = useRef(null)
  const scroller = useRef(null)
  // On a narrow screen the plate keeps a readable width and the wrapper scrolls sideways; the
  // wrapper is only a keyboard stop when it actually overflows.
  useEffect(() => {
    const el = scroller.current
    if (!el) return undefined
    const sync = () => { const scrolls = getComputedStyle(el).overflowX === 'auto' && el.scrollWidth > el.clientWidth + 1; if (scrolls) el.setAttribute('tabindex', '0'); else el.removeAttribute('tabindex') }
    sync()
    const ro = new ResizeObserver(sync); ro.observe(el)
    return () => ro.disconnect()
  }, [])
  useEffect(() => {
    const el = frame.current
    if (!el) return undefined
    const decorate = () => {
      for (const node of el.querySelectorAll('[data-arc-node-id]')) {
        const nd = plates[viewAt(paths[view])]?.nodeData[node.dataset.arcNodeId]
        if (!nd || !nd.child) continue
        const target = views.views.find(v => v.id === nd.child)
        node.setAttribute('role', 'button')
        node.setAttribute('tabindex', '0')
        node.setAttribute('aria-label', 'Open the ' + (target ? target.short : nd.child) + ' view: ' + nd.name)
        if (!node.dataset.kb) {
          node.dataset.kb = '1'
          node.addEventListener('keydown', e => {
            if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); node.click() }
          })
        }
      }
    }
    decorate()
    const mo = new MutationObserver(decorate)
    mo.observe(el, {childList: true, subtree: true})
    return () => mo.disconnect()
  }, [view, nonce])

  const go = useCallback(id => {
    setView(id); setNonce(n => n + 1)
    try { history.replaceState(null, '', '#' + id) } catch (e) { /* file:// previews */ }
  }, [])
  const onAltitude = useCallback(path => {
    const id = viewAt(path)
    setView(id)
    try { history.replaceState(null, '', '#' + id) } catch (e) {}
  }, [])

  return (
    <div className="atlas" data-atlas-view={view}>
      <ol className="atlas__views" aria-label="Atlas views">
        {views.views.map((v, i) => (
          <li key={v.id}>
            <button type="button" onClick={() => go(v.id)} aria-current={v.id === view ? 'true' : undefined}>
              <span className="atlas__num">{String(i + 1).padStart(2, '0')}</span>
              <span className="atlas__name">{v.short}</span>
            </button>
          </li>
        ))}
      </ol>
      <p className="visually-hidden" role="status" aria-live="polite">{'Showing view ' + (views.views.findIndex(v => v.id === view) + 1) + ' of ' + views.views.length + ': ' + meta.short + '. ' + meta.claim}</p>
      <div className="atlas__head">
        <h2 className="atlas__title">{meta.title}</h2>
        <p className="atlas__claim">{meta.claim}</p>
      </div>
      <div className="atlas__scroll" ref={scroller} role="region" aria-label="Diagram. On a narrow screen it scrolls sideways.">
      <div className="atlas__frame" ref={frame} role="group" aria-label={meta.title + ' diagram. A text version of every view follows on this page.'}>
        <ArcDiagram key={nonce} data={plates[root]} diagrams={others} openPath={paths[view]}
          onAltitudeChange={onAltitude} style={style} mode="light"
          defaultZoom="fit" maxFitZoom={1.3} fitPadding={24} label="" showArcToggle={false} />
      </div>
      </div>
      <ul className="atlas__legend" aria-label="Legend">
        <li><span className="atlas__key atlas__key--tool" aria-hidden="true" />Forest: action or tool</li>
        <li><span className="atlas__key atlas__key--state" aria-hidden="true" />Paper: data, evidence or state</li>
        <li><span className="atlas__key atlas__key--human" aria-hidden="true" />Citrus: human judgment</li>
        <li><span className="atlas__key atlas__key--gate" aria-hidden="true" />Diamond: a decision gate</li>
        <li><span className="atlas__key atlas__key--feedback" aria-hidden="true" />Dashed: feedback or revision</li>
      </ul>
      <p className="atlas__hint">Open a node marked with an arrow to descend; use the breadcrumb to climb back. Drag to pan, use the zoom control to scale.</p>
    </div>
  )
}

// Workflow plates: small, single-purpose diagrams embedded in a guide. Each mount lists plate ids
// (data-workflow-plates="a,b") and optional state labels (data-labels="Day 1|Day 3"); the guide's own
// text and table are the no-JavaScript equivalent, so these are progressive enhancement.
const wfFiles = import.meta.glob('../../../data/agentic-os/workflow-plates/*.arc.json', {eager: true, import: 'default'})
const wfPlates = Object.fromEntries(Object.entries(wfFiles).map(([p, d]) => [p.split('/').pop().replace('.arc.json', ''), d]))

function WorkflowPlate({ids, labels, caption}) {
  const [i, setI] = useState(0)
  const id = ids[i]
  const scroller = useRef(null)
  useEffect(() => {
    const el = scroller.current
    if (!el) return undefined
    const sync = () => { const scrolls = el.scrollWidth > el.clientWidth + 1; if (scrolls) el.setAttribute('tabindex', '0'); else el.removeAttribute('tabindex') }
    sync()
    const ro = new ResizeObserver(sync); ro.observe(el)
    return () => ro.disconnect()
  }, [id])
  return (
    <div className="wfplate">
      {ids.length > 1 && (
        <div className="wfplate__tabs" role="group" aria-label="Show another state of this map">
          {ids.map((pid, n) => (
            <button type="button" key={pid} aria-pressed={n === i} onClick={() => setI(n)}>{labels[n] || pid}</button>
          ))}
        </div>
      )}
      <p className="visually-hidden" role="status" aria-live="polite">{'Showing ' + (labels[i] || id) + '. ' + caption}</p>
      <div className="wfplate__scroll" ref={scroller} role="region" aria-label={(labels[i] || id) + ' diagram. On a narrow screen it scrolls sideways.'}>
        <div className="atlas__frame wfplate__frame" role="group" aria-label={(labels[i] || id) + ' diagram. The same content is written out as text beside it.'}>
          <ArcDiagram key={id} data={wfPlates[id]} style={style} mode="light" defaultZoom="fit" maxFitZoom={1.3}
            fitPadding={20} label="" showArcToggle={false} />
        </div>
      </div>
    </div>
  )
}

for (const el of document.querySelectorAll('[data-workflow-plates]')) {
  const ids = el.dataset.workflowPlates.split(',').filter(id => id in wfPlates)
  if (!ids.length) continue
  el.hidden = false
  createRoot(el).render(<WorkflowPlate ids={ids} labels={(el.dataset.labels || '').split('|')} caption={el.dataset.caption || ''} />)
}

const mount = document.getElementById('agentic-os-atlas')
if (mount) {
  mount.hidden = false
  createRoot(mount).render(<Atlas />)
}
