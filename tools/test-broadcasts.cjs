const fs=require('fs'),vm=require('vm'),assert=require('assert/strict');
const source=fs.readFileSync(process.env.BROADCAST_SERVER_FILE || 'server/start_fixed.js','utf8');
const funcs=source.slice(source.indexOf('function sendToPlayer('),source.indexOf('function jsonRawResponse('));
let now=1900000000000,id=0;
const players=[{id:1,role_name:'本人'},{id:2,role_name:'网页玩家'},{id:3,role_name:'桌面玩家'},{id:4,role_name:'离线玩家'}];
const ctx={db:{players,announcements:[],generals:[],bagItems:[],nextId:{bagItems:1}},Date:{now:()=>now},uuidv4:()=>String(++id),console:{log(){}},save(){},tcpSessions:new Map([['tcp',{playerId:3}]]),tcp:[],tcpSend(session,msg){ctx.tcp.push({playerId:session.playerId,msg});},generalRecruitMap:{super:{title:0,name:'超级'},elite:{title:1,name:'一流'},low:{title:2,name:'二流'}},EQUIP_DATA:{q5:{quality:5,name:'极品'},q10:{quality:10,name:'彩装'},q1:{quality:1,name:'白装'}},STAGE_NAMES:{'9_111':'巨斧阵','10_121':'匈奴前哨'}};
vm.createContext(ctx);vm.runInContext(funcs,ctx);
for(let i=0;i<135;i++)ctx.broadcastToAll('广播 ['+i+'] "引号" \\ 路径');
ctx.sendToPlayer(players[1],{type:'neighbor_list',neighbors:[{id:1},{id:2}]});
for(const p of players){let cursor=0,all=[];do{const r=ctx.readPollMessages(p,{cursor});assert(r.messages.length<=100);if(!r.messages.length)break;all.push(...r.messages);assert(r.cursor>cursor);cursor=r.cursor;}while(true);assert.equal(all.filter(m=>m.msg.from==='system').length,135);assert.equal(new Set(all.map(m=>m.seq)).size,all.length);assert.equal(ctx.readPollMessages(p,{cursor}).messages.length,0);}
assert.equal(ctx.tcp.length,135);assert.equal(ctx.getRecentAnnouncements().length,135);
const first=ctx.readPollMessages(players[0],{cursor:0});assert.deepEqual(ctx.readPollMessages(players[0],{cursor:0}).messages,first.messages,'Retry keeps same unacknowledged batch');
const end=ctx.readPollMessages(players[0],{cursor:first.cursor}).cursor;ctx.broadcastToAll('同一毫秒新消息');assert.equal(ctx.readPollMessages(players[0],{cursor:end}).messages.length,1,'Same timestamp does not lose message');
let count=ctx.db.announcements.length;ctx.announceGeneral(players[0],'super');ctx.announceGeneral(players[0],'elite');ctx.announceGeneral(players[0],'low');assert.equal(ctx.db.announcements.length-count,2);
count=ctx.db.announcements.length;ctx.announceEquipment(players[0],'q1',1);ctx.announceEquipment(players[0],'q5',1);ctx.announceEquipment(players[0],'q10',2);assert.equal(ctx.db.announcements.length-count,2);
count=ctx.db.announcements.length;ctx.announceStage(players[0],9,111);ctx.announceStage(players[0],10,121);ctx.announceStage(players[0],1,1);assert.equal(ctx.db.announcements.length-count,2);assert(ctx.db.announcements.at(-1).msg.includes('匈奴前哨'));
// Execute the actual AS3 JSON acceptance body with event substitutes.
const as=fs.readFileSync('com/iflashigame/net/HttpPollConnection.as','utf8');let body=as.match(/private function acceptPollResponse\(raw:String\):Boolean\s*\{([\s\S]*?)\n      \}/)[1];body=body.replace(/var (\w+):Object/g,'var $1').replace('response.messages is Array','Array.isArray(response.messages)').replace('for each(var message in response.messages)','for(var message of response.messages)').replace(/dispatchEvent\(/g,'this.dispatchEvent(').replace(/Number\(/g,'Number(');
const accept=new Function('raw','SocketEvent',body);const client={_cursor:0,received:[],dispatchEvent(e){this.received.push(e.msg);}};function SocketEvent(type,msg){this.msg=msg;}SocketEvent.DATA='data';
const payload=ctx.readPollMessages(players[1],{cursor:0});assert(accept.call(client,JSON.stringify(payload),SocketEvent));assert.equal(client.received.length,100);const oldCursor=client._cursor;assert.throws(()=>accept.call(client,'{"messages":[',SocketEvent));assert.equal(client._cursor,oldCursor);const rest=ctx.readPollMessages(players[1],{cursor:client._cursor});assert(accept.call(client,JSON.stringify(rest),SocketEvent));assert(client.received.some(m=>m.neighbors&&m.neighbors.length===2));assert(client.received[0].plain.includes('[0]'));
// Run real reward routes with isolated data; never send live broadcast test messages.
ctx.Math=Object.create(Math);ctx.Math.random=()=>0.99;ctx.findPlayerByRequest=()=>players[0];ctx.jsonRawResponse=(_,r)=>r;ctx.socket={};ctx.PROTO_DATA={token:{name:'求贤令'}};ctx.save=()=>{};
const fuben=source.slice(source.indexOf("  if (url === '/api/fuben/flip')"),source.indexOf('  // Fuben recruit super general'));
vm.runInContext('function flip(data){var url="/api/fuben/flip";'+fuben+'}',ctx);count=ctx.db.announcements.length;assert(ctx.flip({result:'1|q10|1'}).success);assert.equal(ctx.db.announcements.length,count+1);assert(!ctx.flip({result:'1|q10|1'}).success);assert.equal(ctx.db.announcements.length,count+1);
// Main battle: prepared drop and fallback share the award broadcast, loss emits neither.
const fight=source.slice(source.indexOf("  if (url === '/api/game/fight-result')"),source.indexOf('  // 每日重置副本数据'));
ctx.getStageId=()=>81;ctx.AWARD_MAP={};ctx.CRYSTAL_MAP={};ctx.GENERAL_BASE_STATS={};ctx.generalNameToCode={};
vm.runInContext('function fight(data){var url="/api/game/fight-result";'+fight+'}',ctx);
Object.assign(players[0],{money:0,exploit:0,reverence:0,level:111,finished_stages:'81',_pendingMainEquipDrop:{'9_111':{code:'q10',quality:10}}});
count=ctx.db.announcements.length;assert(ctx.fight({part:9,level:111,m:111,n:111,flag:'win'}).success);assert.equal(ctx.db.announcements.length,count+2);assert(ctx.db.announcements.at(-2).msg.includes('彩色装备'));
count=ctx.db.announcements.length;assert(ctx.fight({part:9,level:111,flag:'lost'}).success);assert.equal(ctx.db.announcements.length,count);
now+=3600001;assert.equal(ctx.getRecentAnnouncements().length,0);
console.log('PASS: 4 recipients incl sender/offline, TCP delivery, 135-message burst, same-ms cursors, retry, nested JSON/brackets, reward thresholds, stages, actual flip route and idempotence');
