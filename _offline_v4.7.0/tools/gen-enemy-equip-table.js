const fs=require('fs'),path=require('path');

// Parse EQUIP_DATA
const exml=fs.readFileSync('staticequip.xml','utf8');
const EQUIP={};
exml.split('<RECORD>').forEach(b=>{
  const cm=b.match(/<code>([^<]+)<\/code>/),nm=b.match(/<name>([^<]+)<\/name>/);
  const qm=b.match(/<quality>(\d+)<\/quality>/),sm=b.match(/<slot>(\d+)<\/slot>/);
  if(cm)EQUIP[cm[1]]={name:nm?nm[1]:'?',quality:parseInt(qm?qm[1]:'1'),slot:parseInt(sm?sm[1]:'1')};
});

// Parse staticgeneral for enemy quality
const gxml=fs.readFileSync('staticgeneral.xml','utf8');
const GEN_QUALITY={};
gxml.split('<RECORD>').forEach(b=>{
  const cm=b.match(/<code>([^<]+)<\/code>/),tm=b.match(/<title>(\d+)<\/title>/);
  if(cm)GEN_QUALITY[cm[1]]=parseInt(tm?tm[1]:'3');
});

function getGeneralQuality(code){return GEN_QUALITY[code]!=null?GEN_QUALITY[code]:3;}
function canDropEquip(code){return !(code||'').match(/^general_0_/);}

function getEquipRange(enemyCode, genLevel){
  if(!canDropEquip(enemyCode)||genLevel<5)return null;
  const genQuality=getGeneralQuality(enemyCode);
  const lvBonus=Math.floor(genLevel/20);
  const qBias=genQuality==0?2:(genQuality==1?1:0);
  const maxQ=Math.min(9,1+lvBonus+qBias);
  const minQ=Math.max(1,maxQ-3);
  const equipProb=Math.min(0.75,0.20+genLevel*0.005);
  return {minQ,maxQ,prob:equipProb};
}

// Parse stage.xml
const sxml=fs.readFileSync('stage.xml','utf8');
const gates=sxml.split('<gate');
const SLOT=['武器','铠甲','饰品Ⅰ','头盔','战靴','饰品Ⅱ'];

let h='<!DOCTYPE html><html><head><meta charset=utf-8><title>全关卡敌方装备表</title>';
h+='<style>body{background:#0d0804;color:#d4c8a0;font:12px SimHei;padding:15px}';
h+='h1{color:#FFD700;text-align:center}h2{color:#C8A84E}h3{color:#998;margin:5px 0}';
h+='table{border-collapse:collapse;margin:8px 0;font-size:9px}th,td{border:1px solid #332;padding:2px 4px;text-align:center}th{background:#1a1008;color:#FFD700}';
h+='tr:nth-child(even){background:#0a0604}';
h+='.eq{font-size:8px}.q{font-weight:bold}</style></head><body>';
h+='<h1>全关卡敌方武将装备 v4.0.7</h1>';
h+='<p style=color:#887;font-size:10px>maxQ=min(9,1+lv/20+qBias) | 每槽75%概率(随等级) | Q10仅掉落不装备</p>';

for(let i=1;i<gates.length;i++){
  const pm=gates[i].match(/part="(\d+)"/),lm=gates[i].match(/level="(\d+)"/);
  if(!pm||!lm)continue;
  const part=pm[1],level=lm[1];
  const gens=gates[i].match(/<general[^>]*\/>/g)||[];

  let stageNum=0;
  for(let j=0;j<gens.length;j++){
    const cm=gens[j].match(/code="([^"]+)"/);
    const nm=gens[j].match(/name="([^"]+)"/);
    const lvm=gens[j].match(/level="(\d+)"/);
    if(!cm)continue;
    stageNum++;
    if(stageNum===1){
      h+='<h2>第'+part+'章 Lv'+level+'</h2><table><tr><th>#</th><th>名称</th><th>Lv</th><th>品质</th><th>装备范围</th><th>槽概率</th><th>备注</th></tr>';
    }

    const code=cm[1],name=nm?nm[1]:'?',elv=parseInt(lvm?lvm[1]:level);
    const quality=getGeneralQuality(code);
    const qName=quality==0?'超级':quality==1?'一流':quality==2?'二流':'三流';
    const range=getEquipRange(code,elv);

    h+='<tr><td>'+stageNum+'</td><td>'+name+'</td><td>'+elv+'</td><td>'+qName+'</td>';
    if(range){
      h+='<td>Q'+range.minQ+'~Q'+range.maxQ+'</td><td>'+(range.prob*100).toFixed(0)+'%</td><td>满6槽随机</td>';
    }else{
      h+='<td>-</td><td>-</td><td>投石车或Lv<5</td>';
    }
    h+='</tr>';
  }
  h+='</table>';
}

h+='<p style=color:#666;font-size:10px;margin-top:20px">生成: '+new Date().toLocaleString()+' | 三国Q战 v4.0.7</p></body></html>';

const out=path.join(require('os').homedir(),'Desktop','全关卡敌方装备表.html');
fs.writeFileSync(out,h);
console.log('✅ '+out+' ('+(fs.statSync(out).size/1024).toFixed(0)+'KB)');
