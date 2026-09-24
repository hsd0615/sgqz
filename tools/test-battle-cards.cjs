// Execute selected AS3 method bodies with display/event doubles; SWF compilation
// separately verifies AS3 types. These checks exercise command and UI transitions.
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname,'..');
function method(file,name,args,env={}) {
  const s=fs.readFileSync(path.join(root,file),'utf8');
  const marker=new RegExp('function '+name+'\\([^]*?\\)\\s*:\\s*[\\w.*]+\\s*\\{');
  const m=marker.exec(s);assert.ok(m,name);
  const end=s.indexOf('\n      }',m.index+m[0].length);
  let body=s.slice(m.index+m[0].length,end)
    .replace(/for each\(var (\w+):\w+ in ([^)]+)\)/g,'for (var $1 of $2)')
    .replace(/\bvar (\w+):[\w.<>*]+/g,'var $1')
    .replace(/\s+as (?:AbstractSoldier|Paimian|Class|MovieClip|ArmyInfo|String|Timer)\b/g,'')
    .replace(/\bis Gunner\b/g,'instanceof Gunner');
  const names=Object.keys(env), values=Object.values(env);
  const fn=new Function(...names,...args,body);
  return function(...input){return fn.call(this,...values,...input);};
}
const event={stopImmediatePropagation(){},stopPropagation(){}};
const noop=()=>{};
const env={Event:{ENTER_FRAME:'frame'},Config:{MERIC:30},Gunner:function(){},addEventListener:noop,removeEventListener:noop};
const fight={_direct:1,_isOver:false,_armyOrders:[],_leftSoldiers:[],_rightSoldiers:[]};
fight.findSoldier=method('game/Fight.as','findSoldier',['param1']);
fight.moveArmy=method('game/Fight.as','moveArmy',['forward'],env);
fight.updateArmyOrders=method('game/Fight.as','updateArmyOrders',['event'],env);
function unit(x,direct=1){return {x,direct,isDead:false,fireing:false,walking:false,cooling:false,moveDistance:2,calls:[],
 get canAI(){return !this.fireing&&!this.walking&&!this.cooling;},
 stand(){this.calls.push('stand');this.walking=false;},
 fire2(obj){this.calls.push(obj.target);this.fireing=true;},
 goLeft(n){this.calls.push(['left',n]);this.walking=true;},goRight(n){this.calls.push(['right',n]);this.walking=true;}};}
const a=unit(100),b=unit(110),front=unit(500,-1),back=unit(600,-1),dead=unit(400,-1);dead.isDead=true;
fight._leftSoldiers=[a,b];fight._rightSoldiers=[dead,null,back,front];
assert.equal(fight.findSoldier(-1),front);
fight.moveArmy(true);
assert.equal(a.calls.at(-1),front);assert.equal(b.calls.at(-1),front);
front.isDead=true;a.fireing=false;b.fireing=false;
fight.updateArmyOrders(event);
assert.equal(a.calls.at(-1),back);assert.equal(b.calls.at(-1),back);
fight.moveArmy(false);assert.equal(fight._armyOrders.length,2,'Retreat waits for ongoing strikes');
a.fireing=false;b.fireing=false;fight.updateArmyOrders(event);
assert.deepEqual(a.calls.slice(-2),['stand',['left',60]],'Retreat cancels chase before movement');
assert.equal(fight._armyOrders.length,0);
fight._direct=-1;fight._rightSoldiers=[back];back.fireing=false;fight.moveArmy(false);
assert.deepEqual(back.calls.at(-1),['right',60]);
const Type={TOUSHICHE:0,QIBING:9,WUDOUBING:6,PART_SOLDIER:18,JUNZHU:20};
let hits=0;const victim={shanbi:0,hurt(damage,attacker){assert.equal(damage,77);assert.equal(attacker.type,6);hits++;}};
const hit=method('game/Fight.as','onSoldierFireCompleteHandler',['param1'],{
 Type,Config:{MERIC:30},Tools:{getJilv:()=>false},Logic:{getHurtVale:()=>77},
 Weapon:function(){throw Error('A martial attack must not construct a projectile');}
});
for(const direct of [-1,1])hit.call({findSoldier:()=>victim,getAllDistance:()=>10}, {...event,target:{type:6,direct,attckDistance:4},data:null});
assert.equal(hits,2,'Both enemy and friendly martial attacks deal melee damage with a null event payload');
hit.call({findSoldier:()=>victim,getAllDistance:()=>1000},{...event,target:{type:6,direct:-1,attckDistance:4},data:null});
assert.equal(hits,2,'No melee damage outside range');
for(const kind of ['Saber','Shooter','Junzhu']){
 let followed;
 const follow=method('game/display/'+kind+'.as','afterTempMoveHandler',['param1'],{
   _locked:front,_world:{findSoldier:()=>back},_direct:1,
   SoldierEvent:{MOVE_COMPLETE:'move'},removeEventListener:noop
 });
 follow.call({fire2:obj=>followed=obj.target,stand(){throw Error('A live front target remains');}},event);
 assert.equal(followed,back,'Movement completion reacquires a live target for '+kind);
}
for(const direct of [-1,1]){
 let shot;
 const gunner=method('game/display/Gunner.as','fire2',['param1'],{Math,parent:{},_direct:direct});
 gunner.call({canAI:true,_direct:direct,parent:{},getHurPoint:()=>({x:direct===1?80:690,y:280}),fire:x=>shot=x},{target:{x:385,isDead:false}});
 assert.equal(shot.angle,-45*direct);assert.ok(shot.power>=0&&shot.power<=100);
 const speed=shot.power/100*0.145+0.025, gravity=0.0098/200;
 const vx=speed/Math.sqrt(2), vy=-vx;
 const t=(-vy+Math.sqrt(vy*vy+2*gravity*70))/gravity;
 assert.ok(Math.abs(vx*t-305)<0.001,'Catapult aims at front target using its projectile physics');
}
const cards=Array.from({length:6},()=>({disable:false,initData(s){this.data=s;this.disable=false;},show(){this.shown=true;}}));
const Timer=function(){this.stop=noop;this.start=noop;this.addEventListener=noop;};
const uiEnv={Tools:{setDisabled:(btn,value)=>btn.disabled=value},Timer,TimerEvent:{TIMER_COMPLETE:'done'},int:Number,String,Paimian:x=>x};
const panel={_cards:cards,_deckId:'deck',_pendingIndex:-1,_flipsRemaining:6,_flippedCards:[],__okBtn:{},__tf:{},_requestTimer:null,updateFlipsText:noop};
panel.resolveRecruit=method('game/ui/fuben/FanpaiPanel.as','resolveRecruit',['success','data'],uiEnv);
panel.onRequestTimeout=method('game/ui/fuben/FanpaiPanel.as','onRequestTimeout',['event'],uiEnv);
panel._pendingIndex=0;panel.resolveRecruit(true,{deckId:'deck',cardIndex:0,result:'1|same|1'});
panel._pendingIndex=1;panel.resolveRecruit(true,{deckId:'deck',cardIndex:1,result:'1|same|1'});
assert.equal(panel._flipsRemaining,4);assert.ok(cards[0].shown&&cards[1].shown);
assert.ok(cards[0].disable&&cards[1].disable);assert.equal(cards[2].disable,false);
panel._pendingIndex=2;for(const card of cards)card.disable=true;
panel.onRequestTimeout(event);assert.equal(cards[2].disable,false);assert.equal(cards[3].disable,true);
assert.equal(panel.__okBtn.disabled,false,'Timeout permits retry or close');
panel.resolveRecruit(true,{deckId:'old-deck',cardIndex:2,result:'1|same|1'});
assert.equal(panel._pendingIndex,2,'Ignore another deck response');
panel.resolveRecruit(false,null);assert.equal(panel._pendingIndex,-1);assert.equal(cards[3].disable,false);
let sent;
const UIEvent=function(type,bubbles,data){this.type=type;this.data=data;};
UIEvent.CLOSE='close';UIEvent.SEND_PAIMIAN='send';
const close=method('game/ui/fuben/FanpaiPanel.as','okBtnClickHandler',['param1'],{UIEvent,dispatchEvent:e=>sent=e});
close.call({_choosed:false,_stageID:0,_maxFlips:1},event);
assert.equal(sent.type,'close','A single-token panel must close without submitting a second flip');
console.log('PASS: front targeting/retargeting, deferred retreat, bidirectional martial damage, duplicate-reward cards, timeout/retry UI');
