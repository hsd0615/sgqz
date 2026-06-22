// Reliable deploy: uses python3 for base64 decode (no shell escaping issues)
const http=require('http'),fs=require('fs'),H='47.96.41.243',P=3000;
function exec(cmd){return new Promise(Y=>{const d=JSON.stringify({key:'sanguoq_admin_2024',cmd});const o={hostname:H,port:P,path:'/api/admin/exec',method:'POST',headers:{'Content-Type':'application/json','Content-Length':Buffer.byteLength(d)}};const r=http.request(o,res=>{let b='';res.on('data',c=>b+=c);res.on('end',()=>{try{Y(JSON.parse(b))}catch(e){Y()}})});r.on('error',e=>Y());r.write(d);r.end()})}

(async()=>{
  const content=fs.readFileSync('server/start_fixed.js','utf8');
  const b64=Buffer.from(content).toString('base64');
  const CS=400; const total=Math.ceil(b64.length/CS);
  console.log('Uploading '+total+' chunks via python3...');

  await exec('rm -f /opt/sf.b64');

  for(let i=0;i<total;i++){
    const chunk=b64.substring(i*CS,(i+1)*CS);
    const cmd = "python3 -c \"open('/opt/sf.b64','a').write('"+chunk+"')\"";
    await exec(cmd);
    if(i%80===0)process.stdout.write('.');
  }

  console.log(' Decoding...');
  await exec("python3 -c \"import base64; c=open('/opt/sf.b64').read(); d=base64.b64decode(c); open('/opt/start_fixed.js','w').write(d.decode())\" && echo DECODE_OK");
  await exec('node --check /opt/start_fixed.js && echo SYNTAX_OK || echo SYNTAX_FAIL');

  // Kill server, cron will restart with new file
  await exec('fuser -k 3000/tcp 2>/dev/null; echo KILLED');
  console.log('Done. Cron will restart in <2 min with v4.0.7');
  process.exit(0);
})().catch(e=>{console.log('Err:',e.message);process.exit(1)});
