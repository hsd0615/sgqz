/**
 * AI精灵图生成 v2 - 融入三国Q战原游戏美术风格
 * 用法: node tools/ai_gen_sprites.js <API_KEY>
 */
const https=require('https'),fs=require('fs'),path=require('path');
const KEY=process.argv[2]||process.env.SF_API_KEY;
if(!KEY){console.log('用法: node tools/ai_gen_sprites.js <API_KEY>');process.exit(1)}
const OUT=path.join(require('os').homedir(),'Desktop');

const STYLE='ancient Chinese Three Kingdoms flash game art style, 2.5D side view game sprite, '+
  'chibi proportions, semi-realistic painted look, bold outlines, rich earthy colors, '+
  'gold trim details, flat shading with subtle gradients, game character asset, '+
  'white background, clean edges';

function call(prompt){
  return new Promise((resolve,reject)=>{
    const data=JSON.stringify({model:'Tongyi-MAI/Z-Image-Turbo',prompt:prompt+', '+STYLE,image_size:'1024x1024',num_inference_steps:25});
    const req=https.request({hostname:'api.siliconflow.cn',port:443,method:'POST',path:'/v1/images/generations',
      headers:{'Content-Type':'application/json','Authorization':'Bearer '+KEY,'Content-Length':Buffer.byteLength(data)},timeout:120000
    },res=>{let d='';res.on('data',c=>d+=c);res.on('end',()=>{try{resolve(JSON.parse(d))}catch(e){resolve(d)}})});
    req.on('error',e=>reject(e));req.write(data);req.end()
  })
}
function dl(url,file){return new Promise(r=>{https.get(url,res=>{const c=[];res.on('data',x=>c.push(x));res.on('end',()=>{fs.writeFileSync(file,Buffer.concat(c));r(file)})}).on('error',r)})}

async function main(){
  console.log('=== AI倭寇精灵图 v2 ===\n');
  console.log('[1/2] 倭寇精兵...');
  const r1=await call('game sprite, Japanese pirate soldier, dark navy blue cloth armor, large conical straw hat with red band, holding curved katana, simple leather sandals, small build, frontline infantry');
  if(r1.images?.[0]?.url){await dl(r1.images[0].url,path.join(OUT,'ai_wokou_soldier.png'));console.log('✓ 精兵\n')}else{console.log('✗',JSON.stringify(r1).substring(0,200),'\n')}

  console.log('[2/2] 倭寇头领...');
  const r2=await call('game boss sprite, Japanese pirate daimyo warlord, ornate red lacquer armor with gold edges, golden kabuto helmet with crest, fierce bearded face, large odachi sword, commanding presence, jinbaori cape');
  if(r2.images?.[0]?.url){await dl(r2.images[0].url,path.join(OUT,'ai_wokou_boss.png'));console.log('✓ 头领\n')}else{console.log('✗',JSON.stringify(r2).substring(0,200),'\n')}

  console.log('=== 完成 ===\n满意后: node tools/cloud-deploy.js');
}
main().catch(e=>console.error(e.message))
