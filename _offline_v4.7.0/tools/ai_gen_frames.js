/**
 * AI逐帧生成倭寇精灵图（4帧: stand/walk/attack/dead）
 * 用法: node tools/ai_gen_frames.js <API_KEY>
 */
const https=require('https'),fs=require('fs'),path=require('path');
const KEY=process.argv[2]||process.env.SF_API_KEY;
if(!KEY){console.log('用法: node tools/ai_gen_frames.js <API_KEY>');process.exit(1)}
const OUT=path.join(require('os').homedir(),'Desktop');

const STYLE='ancient Chinese Three Kingdoms flash game character sprite, 2.5D side view,'+
  'chibi war chess proportions, semi-realistic painted textures, gold trim details,'+
  'bold dark outlines, earthy color palette, flat shading, clean edges, white background, isolated';

function call(prompt){return new Promise((resolve,reject)=>{
  const data=JSON.stringify({model:'Tongyi-MAI/Z-Image-Turbo',prompt,image_size:'1024x1024',num_inference_steps:25});
  const req=https.request({hostname:'api.siliconflow.cn',port:443,method:'POST',path:'/v1/images/generations',
    headers:{'Content-Type':'application/json','Authorization':'Bearer '+KEY,'Content-Length':Buffer.byteLength(data)},timeout:120000
  },res=>{let d='';res.on('data',c=>d+=c);res.on('end',()=>{try{resolve(JSON.parse(d))}catch(e){resolve(d)}})});
  req.on('error',e=>reject(e));req.write(data);req.end()
})}
function dl(url,file){return new Promise(r=>{https.get(url,res=>{const c=[];res.on('data',x=>c.push(x));res.on('end',()=>{fs.writeFileSync(file,Buffer.concat(c));r(file)})}).on('error',r)})}

async function genFrames(name,basePrompt,frames){
  console.log('\n=== '+name+' ===');
  for(const f of frames){
    console.log('['+f.label+'] generating...');
    const prompt=basePrompt+', '+f.action+', '+STYLE;
    const r=await call(prompt);
    if(r.images?.[0]?.url){
      const outFile=path.join(OUT,'wokou_'+f.label+'.png');
      await dl(r.images[0].url,outFile);
      console.log('  ✓ '+outFile);
    }else{console.log('  ✗',JSON.stringify(r).substring(0,100))}
  }
}

async function main(){
  console.log('=== AI 逐帧精灵图生成 ===');

  await genFrames('倭寇精兵',
    'Japanese pirate soldier game sprite, dark navy blue cloth armor, large conical straw hat with red band, curved katana, simple leather sandals, short stature',
    [
      {label:'soldier_stand', action:'standing idle pose, both hands on katana, neutral expression'},
      {label:'soldier_walk', action:'walking forward, legs stepping, hat swaying slightly'},
      {label:'soldier_attack', action:'slashing forward with katana, dynamic combat pose, arm extended'},
      {label:'soldier_dead', action:'fallen on ground after defeat, hat fallen off, katana dropped beside'}
    ]);

  await genFrames('倭寇头领',
    'Japanese pirate daimyo warlord boss game sprite, ornate red lacquer armor with gold edges, golden kabuto helmet with crest, fierce bearded face, large odachi great sword, jinbaori shoulder cape, imposing build',
    [
      {label:'boss_stand', action:'standing idle pose, holding odachi upright, commanding presence'},
      {label:'boss_walk', action:'walking forward with heavy steps, cape flowing behind'},
      {label:'boss_attack', action:'powerful two-handed downward slash with odachi, dynamic battle stance'},
      {label:'boss_dead', action:'defeated on ground, helmet fallen off, sword dropped, cape spread'}
    ]);

  console.log('\n=== 完成 ===');
  console.log('桌面有 8 张逐帧图，下一步：拼合为精灵表并编译');
}
main().catch(e=>console.error(e.message))
