// Benchmark host: the improved Arc rendering of the synthetic fixture workflow, nothing else.
import React from 'react'
import {createRoot} from 'react-dom/client'
import {ArcDiagram} from '@hudsonkit/arc'
import '@hudsonkit/arc/arc.css'
import './frame.css'
import style from '../../../data/agentic-os/style.json'
import plate from '../bench/workflow.fieldnotes.arc.json'
createRoot(document.getElementById('bench')).render(
  <div className="atlas"><div className="atlas__frame" style={{height: '100%'}}>
    <ArcDiagram data={plate} style={style} mode="light" defaultZoom="fit" maxFitZoom={1.6} fitPadding={20} label="" showArcToggle={false} />
  </div></div>)
