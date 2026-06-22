// 主线关卡掉落测试 — 50轮 × 多等级 → HTML
const fs=require('fs'),http=require('http'),H='47.96.41.243',P=3000;
const xml=fs.readFileSync('staticequip.xml','utf8');
const blocks=xml.split('<RECORD>');const EQ={};
for(let i=1;i<blocks.length;i++){const cm=blocks[i].match(/<code>([^<]+)<\/code>/);const nm=blocks[i].match(/<name>([^<]+)<\/name>/);const qm=blocks[i].match(/<quality>(\d+)<\/quality>/);const sm=blocks[i].match(/<slot>(\d+)<\/slot>/);if(cm)EQ[cm[1]]={name:nm?nm[1]:'?',quality:parseInt(qm?qm[1]:'1'),slot:parseInt(sm?sm[1]:'1')}}

function R(p,d){return new Promise(Y=>{const s=JSON.stringify(d),o={hostname:H,port:P,path:p,method:'POST',headers:{'Content-Type':'application/json','Content-Length':Buffer.byteLength(s)}},r=http.request(o,x=>{let b='';x.on('data',c=>b+=c);x.on('end',()=>{try{Y(JSON.parse(b))}catch(e){Y(b)}})});r.on('error',e=>Y({error:e.message}));r.setTimeout(8000,()=>{r.destroy();Y({error:'timeout'})});r.write(s);r.end()})}

const Q_COLORS={1:'#999',2:'#aaa',3:'#4bea13',4:'#4bea13',5:'#e720f9',6:'#e720f9',7:'#FF8C00',8:'#FF8C00',9:'#FF0000',10:'#FF66FF'};
const Q_NAMES={1:'白',2:'白',3:'绿',4:'绿',5:'紫',6:'紫',7:'橙',8:'橙',9:'红',10:'彩'};
const SLOT_NAMES={1:'武器',2:'铠甲',3:'饰品',4:'头盔',5:'战靴'};

async function runTest(lv, rounds, part) {
  const L=await R('/api/auth/login',{userID:'gm_admin',password:'admin123'});
  const {token,roleID:rid,userID:uid}=L.data;
  let drops=[], dist={}, slotDist={}, noDrop=0;

  for(let r=1;r<=rounds;r++){
    // Prepare
    await R('/api/game/fight-prepare',{head:10010,agent:'4399',ver:'2.1.4',token,roleID:rid,userID:uid,
      enemyLevels:Array(6).fill(lv+Math.floor(Math.random()*10)).join(','),level:lv,part});
    // Fight result
    const fr=await R('/api/game/fight-result',{head:10011,agent:'4399',ver:'2.1.4',token,roleID:rid,userID:uid,
      m:500,n:500,part,level:lv,time:60,result:1,touishiAlive:true});
    const drop=fr.data?fr.data.equipDrop:null;
    if(!drop){noDrop++;continue}
    drops.push(drop);
    dist[drop.quality]=(dist[drop.quality]||0)+1;
    if(EQ[drop.code]) slotDist[EQ[drop.code].slot]=(slotDist[EQ[drop.code].slot]||0)+1;
  }
  return {drops,dist,slotDist,noDrop,total:rounds};
}

(async()=>{
  const configs=[
    {lv:20,part:3,label:'Lv20 第3章'},
    {lv:50,part:8,label:'Lv50 第8章'},
    {lv:80,part:15,label:'Lv80 第15章'},
    {lv:120,part:22,label:'Lv120 第22章'},
    {lv:180,part:28,label:'Lv180 第28章'},
  ];
  const results=[];
  for(const c of configs){
    console.log('Testing '+c.label+'...');
    const r=await runTest(c.lv,50,c.part);
    results.push({...c,...r});
    console.log('  掉落'+r.drops.length+'件, 无掉落'+r.noDrop+'轮');
  }

  // Build HTML
  let h='<!DOCTYPE html><html><head><meta charset=utf-8><title>主线关卡掉落测试</title>';
  h+='<style>body{background:#0d0804;color:#d4c8a0;font:14px SimHei;padding:20px}h1{color:#FFD700;text-align:center}h2{color:#C8A84E;margin-top:25px}';
  h+='table{border-collapse:collapse;width:100%;margin:8px 0;font-size:11px}th,td{border:1px solid #332;padding:3px 6px;text-align:center}th{background:#1a1008;color:#FFD700}';
  h+='.bar{display:inline-block;background:#8B6914;height:14px;margin:0 2px;vertical-align:middle}.summary{display:flex;gap:20px;flex-wrap:wrap}';
  h+='.card{background:#1a1008;border:1px solid #332;border-radius:8px;padding:12px;min-width:280px}.card h3{color:#FFD700;margin:0 0 8px;font-size:13px}';
  h+='.drop-row{font-size:10px;line-height:1.6}.drop-row span{margin:0 2px;padding:1px 4px;border-radius:2px}</style></head><body>';
  h+='<h1>⚔ 主线关卡掉落测试 — 50轮</h1>';

  for(const r of results){
    const dropRate=(r.drops.length/r.total*100).toFixed(1);
    h+='<h2>📊 '+r.label+' — 掉率 '+dropRate+'% ('+r.drops.length+'/'+r.total+'轮)</h2>';
    h+='<div class=summary>';

    // Quality dist
    h+='<div class=card><h3>品质分布</h3><table><tr><th>品质</th><th>数量</th><th>占比</th><th></th></tr>';
    const totalDrops=r.drops.length||1;
    for(let q=1;q<=10;q++){
      const c=r.dist[q]||0,pct=(c/totalDrops*100).toFixed(1);
      h+='<tr><td style="color:'+Q_COLORS[q]+'">Q'+q+' '+Q_NAMES[q]+'</td><td>'+c+'</td><td>'+pct+'%</td>';
      h+='<td style="text-align:left"><span class=bar style="width:'+Math.round(pct*3)+'px"></span></td></tr>';
    }
    h+='</table></div>';

    // Slot dist
    h+='<div class=card><h3>部位分布</h3><table><tr><th>部位</th><th>数量</th></tr>';
    for(let s=1;s<=5;s++)h+='<tr><td>'+SLOT_NAMES[s]+'</td><td>'+(r.slotDist[s]||0)+'</td></tr>';
    h+='</table></div>';

    // Rate info
    h+='<div class=card><h3>统计</h3>';
    h+='<p>测试轮数: <b>'+r.total+'</b></p>';
    h+='<p>有掉落: <b>'+r.drops.length+'</b> 轮 ('+dropRate+'%)</p>';
    h+='<p>无掉落: <b>'+r.noDrop+'</b> 轮</p>';
    if(r.drops.length>0){
      const avgQ=(Object.entries(r.dist).reduce((s,[q,c])=>s+q*c,0)/totalDrops).toFixed(2);
      h+='<p>平均品质: <b>Q'+avgQ+'</b></p>';
    }
    h+='</div></div>';

    // All drops list
    if(r.drops.length>0){
      h+='<h3>掉落明细</h3><div class=drop-row>';
      r.drops.forEach((d,i)=>{
        const q=d.quality,clr=Q_COLORS[q]||'#fff';
        h+='<span style="color:'+clr+';background:rgba(255,255,255,0.05)">#'+(i+1)+' '+d.name+' Q'+q+'</span>';
      });
      h+='</div>';
    }
  }

  h+='<p style="color:#666;font-size:11px;margin-top:30px">生成: '+new Date().toLocaleString()+' | 三国Q战 v4.0.7</p></body></html>';

  const out=process.env.USERPROFILE+'\\Desktop\\主线关卡掉落测试.html';
  fs.writeFileSync(out,h);
  console.log('\n✅ '+out+' ('+(fs.statSync(out).size/1024).toFixed(1)+'KB)');
})().catch(e=>console.log('Err:',e.message));
