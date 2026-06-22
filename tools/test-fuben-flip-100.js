// 匈奴副本翻牌测试 — 100轮 × Lv50/Lv100 → HTML
const fs=require('fs'),http=require('http'),H='47.96.41.243',P=3000;

const xml=fs.readFileSync('staticequip.xml','utf8');
const blocks=xml.split('<RECORD>');const EQ={};
for(let i=1;i<blocks.length;i++){const cm=blocks[i].match(/<code>([^<]+)<\/code>/);const nm=blocks[i].match(/<name>([^<]+)<\/name>/);const qm=blocks[i].match(/<quality>(\d+)<\/quality>/);const sm=blocks[i].match(/<slot>(\d+)<\/slot>/);if(cm)EQ[cm[1]]={name:nm?nm[1]:'?',quality:parseInt(qm?qm[1]:'1'),slot:parseInt(sm?sm[1]:'1')}}

function R(p,d){return new Promise(Y=>{const s=JSON.stringify(d),o={hostname:H,port:P,path:p,method:'POST',headers:{'Content-Type':'application/json','Content-Length':Buffer.byteLength(s)}},r=http.request(o,x=>{let b='';x.on('data',c=>b+=c);x.on('end',()=>{try{Y(JSON.parse(b))}catch(e){Y(b)}})});r.on('error',e=>Y({error:e.message}));r.setTimeout(5000,()=>{r.destroy();Y({error:'timeout'})});r.write(s);r.end()})}

const Q_COLORS={1:'#999',2:'#aaa',3:'#4bea13',4:'#4bea13',5:'#e720f9',6:'#e720f9',7:'#FF8C00',8:'#FF8C00',9:'#FF0000',10:'#FF66FF'};
const Q_NAMES={1:'白',2:'白',3:'绿',4:'绿',5:'紫',6:'紫',7:'橙',8:'橙',9:'红',10:'彩'};
const SLOT_NAMES={1:'武器',2:'铠甲',3:'饰品',4:'头盔',5:'战靴'};

function renderRound(r, cards, lv) {
  let h='<tr><td class=rn>#'+r+'</td>';
  for(const c of cards) {
    const p=c.split('|'),code=p[1];
    if(!code.startsWith('proto_4_')){h+='<td>-</td>';continue}
    const e=EQ[code];
    if(!e){h+='<td>?</td>';continue}
    const q=e.quality,clr=Q_COLORS[q]||'#fff',nm=Q_NAMES[q]||'';
    h+='<td><span style="color:'+clr+'">'+e.name+'</span><br><small>Q'+q+' '+nm+' | '+SLOT_NAMES[e.slot]+'</small></td>';
  }
  h+='</tr>\n';
  return h;
}

async function runTest(lv, rounds) {
  const L=await R('/api/auth/login',{userID:'gm_admin',password:'admin123'});
  const {token,roleID:rid,userID:uid}=L.data;
  let html='',dist={},slotDist={};
  for(let r=1;r<=rounds;r++){
    const a=await R('/api/fuben/award',{head:10018,stageID:1,index:3,result:1,level:lv,token,roleID:rid,userID:uid,agent:'4399',ver:'2.1.4'});
    html+=renderRound(r,a.data.pai,lv);
    for(const c of a.data.pai){
      const p=c.split('|'),code=p[1];
      if(!code.startsWith('proto_4_'))continue;
      const e=EQ[code];if(!e)continue;
      dist[e.quality]=(dist[e.quality]||0)+1;
      slotDist[e.slot]=(slotDist[e.slot]||0)+1;
    }
    if(r%10===0) process.stdout.write('.');
  }
  return {html,dist,slotDist,total:rounds*6};
}

(async()=>{
  const results=[];
  for(const lv of [50,100]){
    console.log('\nLv'+lv+' 100轮...');
    const r=await runTest(lv,100);
    results.push({lv,...r});
  }

  // Build HTML
  let html='<!DOCTYPE html><html><head><meta charset=utf-8><title>匈奴副本翻牌测试</title>';
  html+='<style>body{background:#0d0804;color:#d4c8a0;font:14px SimHei,sans-serif;padding:20px}';
  html+='h1{color:#FFD700;text-align:center}h2{color:#C8A84E;margin-top:30px}';
  html+='table{border-collapse:collapse;width:100%;margin:10px 0;font-size:11px}';
  html+='th,td{border:1px solid #332;padding:4px 8px;text-align:center}';
  html+='th{background:#1a1008;color:#FFD700}';
  html+='.rn{color:#666;width:30px}.small{font-size:10px;color:#998}';
  html+='.bar{display:inline-block;background:#8B6914;height:16px;margin:0 2px;vertical-align:middle}';
  html+='.summary{display:flex;gap:30px;flex-wrap:wrap}';
  html+='.card{background:#1a1008;border:1px solid #332;border-radius:8px;padding:15px;min-width:250px}';
  html+='.card h3{color:#FFD700;margin:0 0 10px}</style></head><body>';
  html+='<h1>⚔ 匈奴副本翻牌测试 — 100轮</h1>';

  for(const r of results){
    const centerQ=Math.min(7,Math.floor(r.lv/20)+1);
    html+='<h2>📊 Lv'+r.lv+' (centerQ='+centerQ+') — '+r.total+'件装备</h2>';

    // Quality distribution
    html+='<div class=summary>';
    html+='<div class=card><h3>品质分布</h3><table><tr><th>品质</th><th>数量</th><th>占比</th><th></th></tr>';
    for(let q=1;q<=10;q++){
      const cnt=r.dist[q]||0,pct=(cnt/r.total*100).toFixed(1);
      html+='<tr><td style="color:'+Q_COLORS[q]+'">Q'+q+' '+Q_NAMES[q]+'</td><td>'+cnt+'</td><td>'+pct+'%</td>';
      html+='<td style="text-align:left"><span class=bar style="width:'+Math.round(pct*3)+'px"></span></td></tr>';
    }
    html+='</table></div>';

    // Slot distribution
    html+='<div class=card><h3>部位分布</h3><table><tr><th>部位</th><th>数量</th><th>占比</th></tr>';
    for(let s=1;s<=5;s++){
      const cnt=r.slotDist[s]||0,pct=(cnt/r.total*100).toFixed(1);
      html+='<tr><td>'+SLOT_NAMES[s]+'</td><td>'+cnt+'</td><td>'+pct+'%</td></tr>';
    }
    html+='</table></div></div>';

    // Round-by-round table (first 30 rounds)
    html+='<h3>翻牌明细 (前30轮)</h3><table><tr><th>#</th>';
    for(let i=1;i<=6;i++) html+='<th>格'+i+'</th>';
    html+='</tr>';
    const rows=r.html.split('\n').filter(Boolean);
    html+=rows.slice(0,30).join('\n');
    html+='</table>';
  }

  html+='<p class=small>生成时间: '+new Date().toLocaleString()+' | 三国Q战 v4.0.7</p></body></html>';

  const outPath=process.env.USERPROFILE+'\\Desktop\\匈奴翻牌测试_100轮.html';
  fs.writeFileSync(outPath,html);
  console.log('\n\n✅ 已保存到: '+outPath);
  console.log('文件大小: '+(fs.statSync(outPath).size/1024).toFixed(1)+'KB');
})().catch(e=>console.log('Err:',e.message));
