// 测试服务端/客户端装备名称一致性 + 100轮掉落验证
const fs=require('fs'),http=require('http'),H='47.96.41.243',P=3000;

// Parse SERVER staticequip.xml
const sxml=fs.readFileSync('staticequip.xml','utf8');
const sblocks=sxml.split('<RECORD>');
const SERVER={};
for(let i=1;i<sblocks.length;i++){
  const cm=sblocks[i].match(/<code>([^<]+)<\/code>/);
  const nm=sblocks[i].match(/<name>([^<]+)<\/name>/);
  const qm=sblocks[i].match(/<quality>(\d+)<\/quality>/);
  const sm=sblocks[i].match(/<slot>(\d+)<\/slot>/);
  if(cm)SERVER[cm[1]]={name:(nm?nm[1]:'?').trim(),quality:parseInt(qm?qm[1]:'1'),slot:parseInt(sm?sm[1]:'1')};
}

// Parse CLIENT EquipData.as
const eas=fs.readFileSync('game/model/EquipData.as','utf8');
const CLIENT={};
const regex=/_data\["(proto_4_\d+)"\]=\{([^}]+)\}/g;
let m;
while((m=regex.exec(eas))!==null){
  const code=m[1],props=m[2];
  const nm=props.match(/name:"([^"]+)"/);
  const qm2=props.match(/quality:(\d+)/);
  const sm2=props.match(/slot:(\d+)/);
  CLIENT[code]={name:(nm?nm[1]:'?').trim(),quality:qm2?parseInt(qm2[1]):1,slot:sm2?parseInt(sm2[1]):1};
}

console.log('服务端:'+Object.keys(SERVER).length+'件 | 客户端:'+Object.keys(CLIENT).length+'件');

// Compare
let nameMismatch=[], serverOnly=[], clientOnly=[];
for(const code of Object.keys(SERVER)){
  if(!CLIENT[code]){clientOnly.push(code);continue}
  if(SERVER[code].name!==CLIENT[code].name) nameMismatch.push({code,server:SERVER[code].name,client:CLIENT[code].name});
}
for(const code of Object.keys(CLIENT)){
  if(!SERVER[code]) serverOnly.push(code);
}
console.log('名称不一致:'+nameMismatch.length);
nameMismatch.forEach(m=>console.log('  '+m.code+': 服务端='+m.server+' 客户端='+m.client));
if(serverOnly.length) console.log('仅客户端有('+serverOnly.length+'): '+serverOnly.slice(0,5).join(','));
if(clientOnly.length) console.log('仅服务端有('+clientOnly.length+'): '+clientOnly.slice(0,5).join(','));

// API test
function R(p,d){return new Promise(Y=>{const s=JSON.stringify(d),o={hostname:H,port:P,path:p,method:'POST',headers:{'Content-Type':'application/json','Content-Length':Buffer.byteLength(s)}},r=http.request(o,x=>{let b='';x.on('data',c=>b+=c);x.on('end',()=>{try{Y(JSON.parse(b))}catch(e){Y(b)}})});r.on('error',e=>Y({error:e.message}));r.setTimeout(5000,()=>{r.destroy();Y({error:'timeout'})});r.write(s);r.end()})}

(async()=>{
  const L=await R('/api/auth/login',{userID:'gm_admin',password:'admin123'});
  const {token,roleID:rid,userID:uid}=L.data;

  let drops=0,ok=0,errors=[];
  console.log('\n[100轮掉落] 验证服务端响应名称:');
  for(let r=1;r<=100;r++){
    const fr=await R('/api/game/fight-result',{head:10011,agent:'4399',ver:'2.1.4',token,roleID:rid,userID:uid,m:500,n:500,part:Math.floor(Math.random()*20)+1,level:60+Math.floor(Math.random()*140),time:60,result:1,touishiAlive:true});
    const drop=fr.data?fr.data.equipDrop:null;
    if(!drop) continue;
    drops++;
    const sv=SERVER[drop.code];
    const cl=CLIENT[drop.code];
    const matchServer=sv&&drop.name===sv.name&&drop.quality===sv.quality;
    const matchClient=cl&&drop.name===cl.name;
    if(matchServer&&matchClient) ok++;
    else errors.push({r,code:drop.code,dropName:drop.name,dropQ:drop.quality,server:sv?sv.name:'?',client:cl?cl.name:'?'});
  }
  console.log('  掉落'+drops+'件, 一致'+ok+', 不一致'+(drops-ok));
  errors.slice(0,10).forEach(e=>console.log('  ❌ #'+e.r+' '+e.code+': 返回='+e.dropName+'(Q'+e.dropQ+') 服务端='+e.server+' 客户端='+e.client));
  if(errors.length===0) console.log('  ✅ 服务端/客户端名称完全一致');
})().catch(e=>console.log('Err:',e.message));
