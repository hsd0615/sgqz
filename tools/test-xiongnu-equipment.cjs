const fs=require('fs'),assert=require('assert/strict'),vm=require('vm'),zlib=require('zlib');
const src=fs.readFileSync(process.env.EQUIP_SERVER_FILE||'server/start_fixed.js','utf8');
function extract(name){let start=src.indexOf('function '+name+'('),open=src.indexOf('{',start),depth=1,i=open+1;for(;depth;i++){if(src[i]==='{')depth++;if(src[i]==='}')depth--;}return src.slice(start,i);}
const records=xml=>[...xml.matchAll(/<RECORD>([\s\S]*?)<\/RECORD>/g)].map(m=>Object.fromEntries([...m[1].matchAll(/<(\w+)>([^<]*)<\/\1>/g)].map(x=>[x[1],x[2]])));
const generals=records(fs.readFileSync('staticgeneral.xml','utf8'));
const byCode=Object.fromEntries(generals.map(g=>[g.code,g]));
const config=fs.readFileSync('game/fuben/XiongnuConfig.as','utf8');
let swf=fs.readFileSync('general.swf');if(swf.toString('ascii',0,3)==='CWS')swf=zlib.inflateSync(swf.subarray(8));
for(const code of new Set([...config.matchAll(/getArmyInfo\("([^"]+)"/g)].map(m=>m[1]))){assert(byCode[code],code);assert(swf.includes(Buffer.from(byCode[code].skin+'_0')),byCode[code].skin);}
const ctx={db:{generals:[{code:'cat',player_id:1,equip1:'sword',equip2:'sword'},{code:'normal',player_id:2,equip1:'sword'}],bagItems:[],nextId:{bagItems:5}},GENERAL_BASE_STATS:{cat:{type:0},normal:{type:1}},console,fs:{existsSync:()=>true,readFileSync:()=>fs.readFileSync('staticequip.xml','utf8')},EQUIP_DATA:{}};
vm.createContext(ctx);vm.runInContext(['isCatapult','migrateCatapultEquipment','loadEquipData'].map(extract).join('\n'),ctx);
assert.equal(ctx.migrateCatapultEquipment(),2);assert.equal(ctx.migrateCatapultEquipment(),0);assert.equal(ctx.db.bagItems.length,2);assert(ctx.db.bagItems.every(i=>i.player_id===1&&i.count===1));assert.equal(ctx.db.generals[1].equip1,'sword');
ctx.loadEquipData();assert.equal(ctx.EQUIP_DATA.proto_4_21.dmgBonus,3);assert.equal(ctx.EQUIP_DATA.proto_4_26.dmgBonus,4);
const data={};const equip=fs.readFileSync('game/model/EquipData.as','utf8');for(const m of equip.matchAll(/_data\["([^"]+)"\]=(\{[^;]+\});/g))data[m[1]]=vm.runInNewContext('('+m[2]+')');
const attrs=['attack','defense','hp','attackPct','defensePct','hpPct','dmgBonus','dmgReduce','critRate','critDmg','lifesteal','atkInterval'];
const common=Object.entries(data).filter(([k,v])=>v.quality===1);for(const [k,v] of common){assert(attrs.some(a=>v[a]),k+' client empty');assert(attrs.some(a=>ctx.EQUIP_DATA[k][a]),k+' server empty');}
assert(src.includes("if (isCatapult(g)) return jsonRawResponse"));
assert(fs.readFileSync('game/model/ArmyInfo.as','utf8').includes('if(this.type == Type.TOUSHICHE) return 0;'));
console.log('PASS: Xiongnu dependencies/resources, idempotent item return, catapult guards, '+common.length+' white equipment records and accessory stats');
