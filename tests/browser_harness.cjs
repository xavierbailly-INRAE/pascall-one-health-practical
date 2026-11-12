// Script-level harness; real browser rendering is checked separately.
const fs=require('node:fs'),path=require('node:path'),vm=require('node:vm'),assert=require('node:assert/strict');
const html=fs.readFileSync(path.join(__dirname,'../docs/Pascall_offline_EN.html'),'utf8');
const script=[...html.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/gi)].map(x=>x[1]).join('\n');
const checks=[];function check(name,fn){fn();checks.push({name,passed:true})}
function start(storage=new Map(),blocked=false){
 const elements={};let blob=null,downloaded=false;
 const el=id=>({id,value:'',hidden:false,textContent:'',innerHTML:'',attrs:{},events:{},children:[],classList:{toggle(){}},setAttribute(k,v){this.attrs[k]=v},addEventListener(k,f){this.events[k]=f},replaceChildren(){this.children=[]},appendChild(x){this.children.push(x)}});
 for(const [,id]of html.matchAll(/\bid="([^"]+)"/g))elements[id]=el(id);
 elements.treeRoot.value=elements.clockRoot.value='rtt';elements.fitMode.value='pooled';
 const ctx={document:{getElementById:id=>elements[id],querySelectorAll:s=>s==='.step'?[1,2,3,4,5].map(i=>elements['step'+i]):s==='nav button'?[1,2,3,4,5].map(i=>elements['nav'+i]):[],createElementNS:(ns,tag)=>({...el(''),tag}),createElement:()=>({click(){downloaded=true}})},localStorage:{getItem(k){if(blocked)throw Error('blocked');return storage.get(k)||null},setItem(k,v){if(blocked)throw Error('blocked');storage.set(k,v)}},Blob,URL:{createObjectURL(b){blob=b;return 'blob:test'},revokeObjectURL(){}},setTimeout:f=>f(),window:{}};
 vm.createContext(ctx);vm.runInContext(script,ctx);
 return {elements,ctx,storage,blob:()=>blob,downloaded:()=>downloaded,click(id){const x=elements[id];(x.onclick||x.events.click)()},change(id,value){elements[id].value=value;elements[id].onchange()}};
}
(async()=>{
 let a=start();check('initial step',()=>assert.equal(a.elements.progress.textContent,'Stage 1 of 5'));
 for(let i=1;i<=5;i++)check('navigate '+i,()=>{a.click('nav'+i);assert.deepEqual([1,2,3,4,5].filter(j=>!a.elements['step'+j].hidden),[i]);assert.equal(a.elements['nav'+i].attrs['aria-current'],'step')});
 check('navigation boundaries',()=>{a.click('next');assert.equal(a.elements.progress.textContent,'Stage 5 of 5');a.click('nav1');a.click('previous');assert.equal(a.elements.progress.textContent,'Stage 1 of 5')});
 const ref=fs.readFileSync(path.join(__dirname,'../reference/regression_summary.csv'),'utf8').trim().split(/\r?\n/);const heads=ref.shift().split(',');const rows=ref.map(l=>Object.fromEntries(l.split(',').map((v,i)=>[heads[i],v])));
 for(const root of ['rtt','midpoint'])for(const mode of ['pooled','separate'])check(root+' '+mode+' OLS and selector consistency',()=>{
  a.change('clockRoot',root);a.change('fitMode',mode);assert.equal(a.elements.treeRoot.value,root);assert.match(a.elements.treeImg.src,/^data:image\/png;base64,/);assert(a.elements.treeImg.alt.includes(root==='rtt'?'RTT':'midpoint'));
  for(const g of ['pooled','first','second']){const r=rows.find(r=>r.rooting===root&&r.group===g),f=a.ctx.window.currentFits[g];assert.equal(f.n,Number(r.n));assert(Math.abs(f.slope-Number(r.slope))<1e-10);assert(Math.abs(f.r2-Number(r.R2))<1e-10)}
  const slopes=a.elements.clockChart.children.filter(x=>x.tag==='line'&&x.attrs['stroke-width']===2.5);assert.equal(slopes.length,mode==='pooled'?1:2);
 });
 check('tree selection updates diagnostic',()=>{a.change('treeRoot','rtt');assert.equal(a.elements.clockRoot.value,'rtt')});
 for(let i=1;i<=5;i++){a.elements['note'+i].value='Bloc '+i+' — été';a.elements['note'+i].events.input()}
 check('notes survive reload',()=>{a=start(a.storage);for(let i=1;i<=5;i++)assert.equal(a.elements['note'+i].value,'Bloc '+i+' — été')});
 a.click('exportNotes');const txt=await a.blob().text();check('UTF-8 export with five notes and choices',()=>{assert(a.downloaded());for(let i=1;i<=5;i++)assert(txt.includes('Bloc '+i+' — été'));assert(txt.includes('Selected root: rtt'));assert(txt.includes('Displayed fit: separate'))});
 check('blocked storage leaves UI functional',()=>{const b=start(new Map(),true);b.elements.note1.value='test';b.elements.note1.events.input();b.click('nav5');b.click('exportNotes');assert(b.downloaded());assert(b.elements.notesStatus.textContent.includes('unavailable'))});
 check('invalid stored JSON leaves UI functional',()=>{const b=start(new Map([['pascall-practical-v1-notes','{broken']]));b.click('nav3');assert.equal(b.elements.progress.textContent,'Stage 3 of 5')});
 console.log(JSON.stringify({all_passed:true,count:checks.length,checks},null,2));
})().catch(e=>{console.error(e);process.exitCode=1});
