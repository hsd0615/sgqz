const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const source = fs.readFileSync(process.env.RECRUIT_SERVER_FILE || path.join(__dirname, '../server/start_fixed.js'), 'utf8');
const policy = source.split('// BEGIN RECRUIT_POLICY')[1].split('// END RECRUIT_POLICY')[0];
const routes = source.slice(source.indexOf("  if (url === '/api/recruit/cards')"), source.indexOf('  // ============ 商店购买'));
const p = {id:1, level:100, money:10, finished_stages:'90'};
const ctx = {
  require, console:{log(){}}, Math:Object.create(Math),
  db:{generals:[], bagItems:[{id:1, player_id:1, code:'proto_3_3', count:6}], nextId:{bagItems:2}},
  generalRecruitMap:{
    superA:{title:0,name:'甲'}, superAold:{title:0,name:'甲'},
    superB:{title:0,name:'乙'}, locked:{title:0,name:'未解锁'}, low:{title:1,name:'普通将'}
  },
  generalNameToCode:{甲:'superA',乙:'superB'},
  AWARD_MAP:{a:{recruit:'甲、乙、普通将'}, b:{recruit:'未解锁'}}, STAGE_MAP:{a:90,b:91},
  EQUIP_DATA:{lowEquip:{quality:1}, highEquip:{quality:10}}, KEZHI_MAP:{},
  findPlayerByRequest:()=>p, jsonRawResponse:(_,response)=>response, socket:{}, save(){},
  getKezhiStr:()=>'',
  createGeneral:(id,code,unused,level)=>{const g={player_id:id,code,level,general_id:100};ctx.db.generals.push(g);return g;}
};
vm.createContext(ctx);
vm.runInContext(policy + '\nfunction request(url,data) {' + routes + '\n}',ctx);
assert.deepEqual(Array.from(ctx.recruitSuperPool(p),g=>g.code),['superA','superB']);
assert.match(ctx.recruitReward(p,()=>0.049999),/^3\|superA\|0\|30$/);
assert.equal(ctx.recruitReward(p,()=>0.05),'1|lowEquip|1');
assert.equal(ctx.recruitReward({...p,finished_stages:''},()=>0),'1|lowEquip|1');
let superCount=0;
for(let i=0;i<10000;i++){
  let first=true;
  const result=ctx.recruitReward(p,()=>{if(first){first=false;return i/10000;}return 0;});
  if(result.startsWith('3|'))superCount++;
  else assert.equal(result,'1|lowEquip|1');
}
assert.equal(superCount,500,'Exactly 5% of stratified probability samples');
let cards=ctx.request('/api/recruit/cards',{});
assert.equal(cards.data.maxFlips,6);
assert.equal(cards.data.pai.length,6);
assert.ok(cards.data.pai.every(x=>x===''),'No reward exposed before a paid flip');
const deckId=cards.data.deckId;
ctx.Math.random=()=>0.5;
const flip=index=>ctx.request('/api/recruit/flip',{deckId,cardIndex:index,result:'3|locked|0|999'});
const first=flip(0);
assert.equal(first.data.result,'1|lowEquip|1','Ignore forged client reward');
assert.equal(ctx.db.bagItems[0].count,5);
assert.deepEqual(flip(0),first,'Retry returns the same saved result');
assert.equal(ctx.db.bagItems[0].count,5,'Retry does not consume another token');
assert.equal(flip(1).success,true,'Two identical equipment rewards use different slots');
assert.equal(ctx.db.bagItems[0].count,4);
assert.equal(flip(6).success,false);
assert.equal(ctx.request('/api/recruit/flip',{deckId:'wrong',cardIndex:2}).success,false);
ctx.Math.random=()=>0;
assert.equal(flip(2).data.general.title,0,'Preserve title zero');
assert.equal(ctx.recruitSuperPool(p).some(g=>g.name==='甲'),false,'Exclude already-owned aliases');
for(let i=3;i<6;i++)assert.equal(flip(i).success,true);
assert.equal(ctx.db.bagItems.some(b=>b.code==='proto_3_3'),false);
assert.equal(ctx.request('/api/recruit/cards',{}).success,false);
assert.equal(flip(0).data.result,'1|lowEquip|1','A last-token retry still succeeds');
console.log('PASS: 5% boundary/distribution, unlocks, title 0, ordinary equipment, slot identity, retry, token accounting');
