const fs=require('fs'),path=require('path');

function calcWeights(level, part) {
  const idealQ=Math.min(9,Math.max(1,level/30+part/20));
  const w=[];
  w[10]=0.5; // Q10固定
  for(let q=1;q<=9;q++){const d=Math.abs(q-idealQ);w[q]=Math.max(1,25-d*3)}
  return {idealQ,weights:w};
}

function dropProb(lv,pt){return Math.min(0.40,Math.max(0.20,lv/400+pt/100))}

let h='<!DOCTYPE html><html><head><meta charset=utf-8><title>全关卡装备掉落概率</title>';
h+='<style>body{background:#0d0804;color:#d4c8a0;font:13px SimHei;padding:15px}';
h+='h1{color:#FFD700;text-align:center}';
h+='table{border-collapse:collapse;margin:10px 0;font-size:10px}th,td{border:1px solid #332;padding:2px 5px;text-align:center}th{background:#1a1008;color:#FFD700;position:sticky;top:0}';
h+='tr:nth-child(even){background:#0a0604}';
h+='.c1{color:#999}.c3{color:#4bea13}.c5{color:#e720f9}.c7{color:#FF8C00}.c9{color:red}.c10{color:#FF66FF}';
h+='.high{background:#1a0800}.note{font-size:11px;color:#887}</style></head><body>';
h+='<h1>全关卡装备掉落概率 v4.0.7</h1>';
h+='<p class=note>掉率=min(40%,max(20%,等级/400+章节/100)) | Q10固定0.5权重 | v4.0.7</p>';

const levels=[1,10,20,30,40,50,60,70,80,90,100,120,140,160,180,200];
const parts=[1,3,5,8,10,12,15,18,20,22,25,28,30];

h+='<table><tr><th>等级</th><th>章节</th><th>掉率</th><th>idealQ</th>';
for(let q=1;q<=10;q++)h+='<th>Q'+q+'</th>';
h+='</tr>';

for(const lv of levels){
  for(const pt of parts){
    const prob=dropProb(lv,pt);
    const {centerQ,weights}=calcWeights(lv,pt);
    const total=weights.slice(1).reduce((a,b)=>a+b,0);
    const pcts=weights.slice(1).map(w=>(w/total*prob*100));
    h+='<tr>';
    h+='<td>Lv'+lv+'</td><td>'+pt+'章</td>';
    h+='<td>'+(prob*100).toFixed(1)+'%</td>';
    h+='<td>Q'+centerQ+'</td>';
    for(let q=0;q<10;q++){
      const p=pcts[q];
      const cls=q===0||q===1?'c1':q===2||q===3?'c3':q===4||q===5?'c5':q===6||q===7?'c7':q===8?'c9':'c10';
      h+='<td class='+cls+'>'+(p<0.01?'<0.01':p.toFixed(2))+'%</td>';
    }
    h+='</tr>';
  }
}
h+='</table>';
h+='<p class=note>概率=品质权重/总权重×掉率。Q10在所有关卡均为约0.2%~0.5%</p>';
h+='</body></html>';

const out=path.join(require('os').homedir(),'Desktop','全关卡装备掉率表.html');
fs.writeFileSync(out,h);
console.log('✅ '+out+' ('+(fs.statSync(out).size/1024).toFixed(0)+'KB)');
