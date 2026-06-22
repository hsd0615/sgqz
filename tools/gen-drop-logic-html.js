const fs=require('fs'),path=require('path');
function calcWeights(level, part) {
  const idealQ=Math.min(9,Math.max(1,level/30+part/20));
  const w=[];w[10]=0.5;for(let q=1;q<=9;q++){const d=Math.abs(q-idealQ);w[q]=Math.max(1,25-d*3)}
  const t=w.slice(1).reduce((a,b)=>a+b,0);return{idealQ,weights:w.slice(1).map(x=>x/t*100)};
}
let h='<!DOCTYPE html><html><head><meta charset=utf-8><title>主线掉落逻辑</title>';
h+='<style>body{background:#0d0804;color:#d4c8a0;font:14px SimHei;padding:20px;max-width:1000px;margin:0 auto}';
h+='h1{color:#FFD700;text-align:center}h2{color:#C8A84E;margin-top:20px}h3{color:#998}';
h+='table{border-collapse:collapse;width:100%;margin:8px 0;font-size:11px}th,td{border:1px solid #332;padding:3px 6px;text-align:center}th{background:#1a1008;color:#FFD700}';
h+='.code{background:#1a1008;border:1px solid #332;border-radius:4px;padding:8px 12px;margin:6px 0;font:11px Consolas;white-space:pre;color:#998}';
h+='.formula{color:#FFD700}</style></head><body>';
h+='<h1>⚔ 主线关卡装备掉落逻辑 v4.0.7</h1>';

h+='<h2>流程</h2><p>fight-prepare(预计算掉落) → 存入_pendingMainEquipDrop → fight-result(直接使用) → 入包</p>';

h+='<h2>掉率</h2><p class=formula>min(70%, max(15%, level/200 + part/50))</p>';
h+='<table><tr><th>Lv\\章</th><th>1章</th><th>5章</th><th>10章</th><th>15章</th><th>25章</th></tr>';
for(const lv of[10,30,50,80,100,150,200]){
  h+='<tr><td>Lv'+lv+'</td>';
  for(const pt of[1,5,10,15,25])h+='<td>'+Math.round(Math.min(0.70,Math.max(0.15,lv/200+pt/50))*100)+'%</td>';
  h+='</tr>'
}
h+='</table>';

h+='<h2>品质加权</h2><p class=formula>idealQ=min(8,floor(level/25)+floor(part/10)+1)</p>';
h+='<p>rawW[q]=max(1,25-|q-idealQ|×8); Q9权重3; Q10权重1.5</p>';
h+='<table><tr><th>场景</th><th>cQ</th><th>Q1</th><th>Q2</th><th>Q3</th><th>Q4</th><th>Q5</th><th>Q6</th><th>Q7</th><th>Q8</th><th>Q9</th><th>Q10</th></tr>';
for(const[lv,pt,nm] of[[20,3,'Lv20Ch3'],[50,8,'Lv50Ch8'],[80,15,'Lv80Ch15'],[120,22,'Lv120Ch22'],[180,28,'Lv180Ch28']]){
  const{idealQ,weights}=calcWeights(lv,pt);
  h+='<tr><td>'+nm+'</td><td>Q'+idealQ+'</td>';
  for(let q=0;q<10;q++)h+='<td>'+weights[q].toFixed(1)+'%</td>';
  h+='</tr>'
}
h+='</table>';

h+='<h2>品质颜色</h2><table><tr><th>Q1-2白</th><th>Q3-4绿</th><th>Q5-6紫</th><th>Q7-8橙</th><th>Q9红</th><th>Q10彩</th></tr>';
h+='<tr><td style=color:#999>#999</td><td style=color:#4bea13>#4bea13</td><td style=color:#e720f9>#e720f9</td><td style=color:#FF8C00>#FF8C00</td><td style=color:red>red</td><td style=color:#FF66FF>#FF66FF</td></tr></table>';

h+='</body></html>';
fs.writeFileSync(path.join(require('os').homedir(),'Desktop','主线掉落逻辑.html'),h);
console.log('✅ Done');
