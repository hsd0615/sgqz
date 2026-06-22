// Reset all non-admin accounts
const http=require('http'),fs=require('fs'),H='47.96.41.243',P=3000;
function exec(cmd){return new Promise(Y=>{const d=JSON.stringify({key:'sanguoq_admin_2024',cmd});const o={hostname:H,port:P,path:'/api/admin/exec',method:'POST',headers:{'Content-Type':'application/json','Content-Length':Buffer.byteLength(d)}};const r=http.request(o,res=>{let b='';res.on('data',c=>b+=c);res.on('end',()=>{try{Y(JSON.parse(b))}catch(e){Y()}})});r.on('error',e=>Y());r.write(d);r.end()})}

const script =
"const fs=require('fs');const db=JSON.parse(fs.readFileSync('/opt/data/sanguo.json','utf8'));"+
"const adminPid=db.players.find(p=>p.role_name==='GM管理员')?.id;"+
"let accts=0,gens=0,eqs=0;"+
"db.players.forEach(p=>{"+
"if(p.id===adminPid)return;accts++;"+
"p.finished_stages='1|2|3|4|5|6|7|8|9|10|11|12|13|14|15';"+
"p.history='4|4|4|4|4|4|4|4|4|4';"+
"p.level=Math.min(p.level||1,25);"+
"const pgens=db.generals.filter(g=>g.player_id===p.id);"+
"pgens.forEach(g=>{"+
"gens++;g.kezhi1_level=1;g.kezhi2_level=1;g.kezhi3_level=1;"+
"g.equip1='0';g.equip2='0';g.equip3='0';g.equip4='0';g.equip5='0';g.equip6='0';"+
"g.level=Math.min(g.level||1,25);g.evolution=0;});"+
"const before=db.bagItems.filter(b=>b.player_id===p.id&&(b.code||'').startsWith('proto_4_')).length;"+
"eqs+=before;db.bagItems=db.bagItems.filter(b=>!(b.player_id===p.id&&(b.code||'').startsWith('proto_4_')));"+
"});fs.writeFileSync('/opt/data/sanguo.json',JSON.stringify(db));"+
"console.log('accts:'+accts+' gens:'+gens+' equip:'+eqs);";

(async()=>{
  const b64=Buffer.from(script).toString('base64');
  const CS=400; const total=Math.ceil(b64.length/CS);
  console.log('Uploading '+total+' chunks...');
  await exec('rm -f /tmp/reset2.b64');

  for(let i=0;i<total;i++){
    const chunk=b64.substring(i*CS,(i+1)*CS);
    await exec("python3 -c \"open('/tmp/reset2.b64','a').write('"+chunk+"')\"");
    if(i%30===0)process.stdout.write('.');
  }

  console.log(' Executing...');
  await exec("python3 -c \"import base64; c=open('/tmp/reset2.b64').read(); d=base64.b64decode(c); open('/tmp/reset2.js','w').write(d.decode())\" && node /tmp/reset2.js && echo RESET_DONE");

  // Verify
  const http2=require('http');
  const login=await new Promise(Y=>{
    const d=JSON.stringify({userID:'test_pro',password:'pro123'});
    const r=http2.request({hostname:H,port:P,path:'/api/auth/login',method:'POST',headers:{'Content-Type':'application/json','Content-Length':Buffer.byteLength(d)}},res=>{let b='';res.on('data',c=>b+=c);res.on('end',()=>{try{Y(JSON.parse(b))}catch(e){Y(b)}})});r.on('error',e=>Y({error:e.message}));r.write(d);r.end();
  });
  if(login.success){
    const bag=login.data.bagModel.filter(b=>(b.code||'').startsWith('proto_4_'));
    console.log('\ntest_pro 装备:'+bag.length+'件, 武将:'+(login.data.armyModel||[]).length);
  }
  console.log('Done');
  process.exit(0);
})().catch(e=>{console.log('Err:',e.message);process.exit(1)});
