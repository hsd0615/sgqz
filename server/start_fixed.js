// 原始TCP HTTP服务器 — 完全绕过 Node.js HTTP 模块
// Node v22 的 HTTP 模块处理与 Flash URLLoader 存在未知兼容问题
// 直接用 net 模块手工构造 HTTP 响应，确保字节级别精确控制

const fs = require('fs');
const path = require('path');
const net = require('net');
const { exec } = require('child_process');
const { v4: uuidv4 } = require('uuid');

const HTTP_PORT = 3000;
const TCP_PORT = 3001;
const DATA_FILE = path.join(__dirname, 'data', 'sanguo.json');

// ============ 数据库 ============
let db = { players: [], generals: [], bagItems: [], leitaiRooms: [], nextId: { players: 1, generals: 1, bagItems: 1 } };
if (fs.existsSync(DATA_FILE)) {
  try { db = JSON.parse(fs.readFileSync(DATA_FILE, 'utf-8')); } catch(e) {}
}
function save() { fs.writeFileSync(DATA_FILE, JSON.stringify(db)); }
function findPlayer(uid) { return db.players.find(p => String(p.user_id) === String(uid)); }
function findPlayerByToken(token) { return db.players.find(p => p.token === token); }
function findPlayerByPwd(uid, pwd) { return db.players.find(p => String(p.user_id) === String(uid) && p.password === pwd); }
function createPlayer(uid, name, img, agent, pwd) {
  const p = { id: db.nextId.players++, user_id: String(uid), agent, password: pwd||'', role_name: name, image_id: img, level: 1, money: 5000, dianka: 0, exploit: 0, reverence: 0, rongyu: 0, win_count: 0, lost_count: 0, finished_stages: '', history: '', login_server: 0, token: uuidv4().replace(/-/g,'') };
  db.players.push(p);
  save();
  return p;
}
function findGenerals(pid) { return db.generals.filter(g => g.player_id === pid); }
function createGeneral(pid, code, name, level, evo, feat, tf, k1, k1l, k2, k2l, k3, k3l, eq1, eq2, eq3) {
  const g = { id: db.nextId.generals++, player_id: pid, general_id: Math.floor(Math.random()*100000), code, name, level:level||1, evolution:evo||0, feature:feat||0, tianfu:tf||null, kezhi1:k1||0, kezhi1_level:k1l||1, kezhi2:k2||0, kezhi2_level:k2l||1, kezhi3:k3||0, kezhi3_level:k3l||1, is_deployed: 0, equip1: eq1||'0', equip2: eq2||'0', equip3: eq3||'0' };
  db.generals.push(g);
  save();
  return g;
}
function initLeitai() {
  if (db.leitaiRooms.length > 0) return;
  const levels = [{lv:200,p:[10000,10000,30,5000,5000,10]},{lv:180,p:[10000,10000,30,5000,5000,10]},{lv:160,p:[8000,8000,30,5000,5000,10]},{lv:140,p:[8000,8000,30,5000,5000,10]},{lv:120,p:[5000,5000,30,2000,2000,10]},{lv:90,p:[5000,5000,30,2000,2000,10]},{lv:60,p:[3000,3000,30,1000,1000,10]},{lv:30,p:[3000,3000,30,1000,1000,10]}];
  for (const lv of levels) for (let t=0;t<6;t++) db.leitaiRooms.push({rID:lv.lv*100+t,rLevel:lv.lv,rStatus:0,rType:(t%3)+1,rPrice:lv.p[t],rongyu_pool:0,battle_count:0,rCount:0,rValue:0, mInfo: null});
  save();
}

// ============ 武将数据 ============
// 全局克制类型映射 (从staticgeneral.xml加载, 服务端权威数据源)
var KEZHI_MAP = {};
var generalRecruitMap = {};
function loadKezhiMap() {
  if (!fs.existsSync('/opt/staticgeneral.xml')) return;
  var xml = fs.readFileSync('/opt/staticgeneral.xml','utf8');
  var blocks = xml.split('<RECORD>');
  for (var i = 0; i < blocks.length; i++) {
    var cm = blocks[i].match(/<code>([^<]+)<\/code>/);
    var km = blocks[i].match(/<kezhi>([^<]+)<\/kezhi>/);
    if (cm && km && km[1].length > 0) KEZHI_MAP[cm[1]] = km[1];
    // 同时加载招募概率
    if (cm) {
      var mm = blocks[i].match(/<money>(\d+)<\/money>/);
      var dm = blocks[i].match(/<dianka>(\d+)<\/dianka>/);
      if (mm && dm) generalRecruitMap[cm[1]] = { money: parseInt(mm[1]), dianka: parseInt(dm[1]) };
    }
  }
  KEZHI_MAP['general_0_1'] = '3:1|8:1|9:1';
  console.log('[KezhiMap] Loaded ' + Object.keys(KEZHI_MAP).length + ' entries, recruit: ' + Object.keys(generalRecruitMap).length);
}

// 全局关卡ID映射 (part_level → stage_id, 从stage.xml加载)
var STAGE_MAP = {};
function loadStageMap() {
  if (!fs.existsSync('/opt/stage.xml')) return;
  var xml = fs.readFileSync('/opt/stage.xml','utf8');
  var blocks = xml.split('<gate');
  for (var i = 1; i < blocks.length; i++) {
    var pm = blocks[i].match(/part="(\d+)"/);
    var lm = blocks[i].match(/level="(\d+)"/);
    var im = blocks[i].match(/id="(\d+)"/);
    if (pm && lm && im) STAGE_MAP[pm[1]+'_'+lm[1]] = parseInt(im[1]);
  }
  console.log('[StageMap] Loaded ' + Object.keys(STAGE_MAP).length + ' stage IDs');
}
// 加载关卡奖励数据 (soldier/proto/money等)
var AWARD_MAP = {};
function loadAwardMap() {
  if (!fs.existsSync('/opt/stage.xml')) return;
  var xml = fs.readFileSync('/opt/stage.xml','utf8');
  var blocks = xml.split('<gate');
  for (var i = 1; i < blocks.length; i++) {
    var pm = blocks[i].match(/part="(\d+)"/);
    var lm = blocks[i].match(/level="(\d+)"/);
    var aw = blocks[i].match(/<award\s+([^>]+)\/>/);
    if (pm && lm && aw) {
      var key = pm[1]+'_'+lm[1];
      // 解析award属性
      var attrs = aw[1];
      var sm = attrs.match(/soldier="([^"]*)"/);
      var rm = attrs.match(/recruit="([^"]*)"/);
      var prm = attrs.match(/proto="([^"]*)"/);
      var mom = attrs.match(/money="(\d+)"/);
      var exm = attrs.match(/exploit="(\d+)"/);
      var rem = attrs.match(/reverence="(\d+)"/);
      AWARD_MAP[key] = {
        soldier: (sm&&sm[1]) ? sm[1] : '',
        recruit: (rm&&rm[1]) ? rm[1] : '',
        proto: (prm&&prm[1]) ? prm[1] : '',
        money: (mom&&mom[1]) ? parseInt(mom[1]) : 0,
        exploit: (exm&&exm[1]) ? parseInt(exm[1]) : 0,
        reverence: (rem&&rem[1]) ? parseInt(rem[1]) : 0
      };
    }
  }
  console.log('[AwardMap] Loaded ' + Object.keys(AWARD_MAP).length + ' awards');
}
// 加载商城数据 (shop.xml)
var SHOP_DATA = {};
function loadShopData() {
  if (!fs.existsSync('/opt/shop.xml')) return;
  var xml = fs.readFileSync('/opt/shop.xml','utf8');
  var blocks = xml.split('<RECORD>');
  for (var i = 1; i < blocks.length; i++) {
    var idm = blocks[i].match(/<id>([^<]+)<\/id>/);
    var cm = blocks[i].match(/<code>([^<]+)<\/code>/);
    var nm = blocks[i].match(/<name>([^<]+)<\/name>/);
    var pm = blocks[i].match(/<newPrice>(\d+)<\/newPrice>/);
    var ptm = blocks[i].match(/<payType>(\d+)<\/payType>/);
    var cntm = blocks[i].match(/<count>(\d+)<\/count>/);
    if (idm && cm && pm) {
      SHOP_DATA[idm[1]] = { code: cm[1], name: (nm?nm[1]:''), newPrice: parseInt(pm[1]), payType: parseInt(ptm?ptm[1]:'1'), count: parseInt(cntm?cntm[1]:'1') };
    }
  }
  console.log('[ShopData] Loaded ' + Object.keys(SHOP_DATA).length + ' items');
}
// 加载道具数据 (staticproto.xml)
var PROTO_DATA = {};
function loadProtoData() {
  if (!fs.existsSync('/opt/staticproto.xml')) return;
  var xml = fs.readFileSync('/opt/staticproto.xml','utf8');
  var blocks = xml.split('<RECORD>');
  for (var i = 1; i < blocks.length; i++) {
    var cm = blocks[i].match(/<code>([^<]+)<\/code>/);
    var nm = blocks[i].match(/<name>([^<]+)<\/name>/);
    var tm = blocks[i].match(/<type>(\d+)<\/type>/);
    if (cm) {
      PROTO_DATA[cm[1]] = { name: (nm?nm[1]:''), type: parseInt(tm?tm[1]:'1') };
    }
  }
  console.log('[ProtoData] Loaded ' + Object.keys(PROTO_DATA).length + ' items');
}

// 装备数据 (staticequip.xml)
var EQUIP_DATA = {};
function loadEquipData() {
  if (!fs.existsSync('/opt/staticequip.xml')) return;
  var xml = fs.readFileSync('/opt/staticequip.xml','utf8');
  var blocks = xml.split('<RECORD>');
  for (var i = 1; i < blocks.length; i++) {
    var cm = blocks[i].match(/<code>([^<]+)<\/code>/);
    if (cm) {
      var slotm = blocks[i].match(/<slot>(\d+)<\/slot>/);
      var atkm = blocks[i].match(/<attack>(\d+)<\/attack>/);
      var defm = blocks[i].match(/<defense>(\d+)<\/defense>/);
      var hpm = blocks[i].match(/<hp>(\d+)<\/hp>/);
      var lvrm = blocks[i].match(/<levelReq>(\d+)<\/levelReq>/);
      var qm = blocks[i].match(/<quality>(\d+)<\/quality>/);
      var nm2 = blocks[i].match(/<name>([^<]+)<\/name>/);
      var atkpctm = blocks[i].match(/<attackPct>(\d+)<\/attackPct>/);
      var defpctm = blocks[i].match(/<defensePct>(\d+)<\/defensePct>/);
      var hppctm = blocks[i].match(/<hpPct>(\d+)<\/hpPct>/);
      EQUIP_DATA[cm[1]] = {
        name: (nm2?nm2[1]:''),
        slot: parseInt(slotm?slotm[1]:'1'),
        attack: parseInt(atkm?atkm[1]:'0'),
        attackPct: parseInt(atkpctm?atkpctm[1]:'0'),
        defense: parseInt(defm?defm[1]:'0'),
        defensePct: parseInt(defpctm?defpctm[1]:'0'),
        hp: parseInt(hpm?hpm[1]:'0'),
        hpPct: parseInt(hppctm?hppctm[1]:'0'),
        levelReq: parseInt(lvrm?lvrm[1]:'1'),
        quality: parseInt(qm?qm[1]:'1')
      };
    }
  }
  console.log('[EquipData] Loaded ' + Object.keys(EQUIP_DATA).length + ' items');
}

function getStageId(part, level) {
  return STAGE_MAP[part+'_'+level] || parseInt(part+''+level) || 1;
}

// 获取武将克制字符串: XML类型(权威) + DB等级(可升级)
function getKezhiStr(g) {
  var xmlKz = KEZHI_MAP[g.code];
  if (!xmlKz) {
    // XML无此武将，用DB值或返回空让客户端fallback
    if ((g.kezhi1||0)+(g.kezhi2||0)+(g.kezhi3||0) === 0) return '';
    return (g.kezhi1||0)+':'+(g.kezhi1_level||1)+'|'+(g.kezhi2||0)+':'+(g.kezhi2_level||1)+'|'+(g.kezhi3||0)+':'+(g.kezhi3_level||1);
  }
  var parts = xmlKz.split('|');
  var k1 = parseInt(parts[0].split(':')[0]) || 0;
  var k2 = parseInt(parts[1].split(':')[0]) || 0;
  var k3 = parseInt(parts[2].split(':')[0]) || 0;
  var l1 = g.kezhi1_level || parseInt(parts[0].split(':')[1]) || 1;
  var l2 = g.kezhi2_level || parseInt(parts[1].split(':')[1]) || 1;
  var l3 = g.kezhi3_level || parseInt(parts[2].split(':')[1]) || 1;
  return k1+':'+l1+'|'+k2+':'+l2+'|'+k3+':'+l3;
}

// 启动时修复DB中不完整的克制数据
function migrateKezhi() {
  var fixed = 0;
  for (var j = 0; j < db.generals.length; j++) {
    var g = db.generals[j];
    var xmlKz = KEZHI_MAP[g.code];
    if (!xmlKz) continue;
    var parts = xmlKz.split('|');
    if (parts.length < 3) continue;
    var changed = false;
    if ((g.kezhi1||0) === 0) { g.kezhi1 = parseInt(parts[0].split(':')[0]) || 0; changed = true; }
    if ((g.kezhi2||0) === 0) { g.kezhi2 = parseInt(parts[1].split(':')[0]) || 0; changed = true; }
    if ((g.kezhi3||0) === 0) { g.kezhi3 = parseInt(parts[2].split(':')[0]) || 0; changed = true; }
    g.kezhi1_level = g.kezhi1_level || 1;
    g.kezhi2_level = g.kezhi2_level || 1;
    g.kezhi3_level = g.kezhi3_level || 1;
    if (changed) fixed++;
  }
  if (fixed > 0) { console.log('[Migrate] Fixed ' + fixed + ' generals kezhi types from XML'); }
}

function migrateEquipment() {
  var fixed = 0;
  for (var ei = 0; ei < db.generals.length; ei++) {
    var g = db.generals[ei];
    var changed = false;
    if (g.equip1 === undefined) { g.equip1 = '0'; changed = true; }
    if (g.equip2 === undefined) { g.equip2 = '0'; changed = true; }
    if (g.equip3 === undefined) { g.equip3 = '0'; changed = true; }
    if (changed) fixed++;
  }
  if (fixed > 0) { console.log('[Migrate] Added equipment slots to ' + fixed + ' generals'); }
}

function ensureGenerals(pid, list, level, evo, feat, tf) {
  for (const [code, name, kezhi] of list) {
    if (findGenerals(pid).some(g => g.code === code)) continue;
    const kp = kezhi.split('|');
    // 参数: pid,code,name,level,evo,feat,tf, k1,k1l, k2,k2l, k3,k3l
    createGeneral(pid, code, name, level||1, evo||0, feat||0, tf||null,
      parseInt(kp[0].split(':')[0]), parseInt(kp[0].split(':')[1]||'1'),
      parseInt(kp[1].split(':')[0]), parseInt(kp[1].split(':')[1]||'1'),
      parseInt(kp[2].split(':')[0]), parseInt(kp[2].split(':')[1]||'1'));
  }
}
const ALL_SUPERS = [
  ['general_9_18','吕布','6:1|1:1|8:1'],['general_9_20','马超','6:1|1:1|8:1'],['general_9_16','夏侯惇','6:1|1:1|8:1'],
  ['general_7_19','赵云','5:1|4:1|7:1'],['general_7_14','张飞','5:1|4:1|7:1'],['general_3_13','关羽','2:1|1:1|6:1'],
  ['general_1_15','黄忠','5:1|7:1|9:1'],['general_1_23','姜维','5:1|7:1|9:1'],['general_2_11','貂蝉','5:1|4:1|7:1'],
  ['general_6_15','魏延','6:1|1:1|8:1'],['general_0_1','投石车','3:1|8:1|9:1'],
];
const PRO_GENERALS = [
  ['general_9_18','吕布','6:1|1:1|8:1'],['general_7_19','赵云','5:1|4:1|7:1'],['general_3_13','关羽','2:1|1:1|6:1'],
  ['general_1_15','黄忠','5:1|7:1|9:1'],['general_6_15','魏延','6:1|1:1|8:1'],['general_0_1','投石车','3:1|8:1|9:1'],
];
const NEWBIE_GENERALS = [
  ['general_0_1','投石车','3:1|8:1|9:1'],['general_1_0','王平','5:1|7:1|9:1'],['general_3_0','吕翔','2:1|1:1|6:1'],
];

function createTestAccounts() {
  let p1 = findPlayer('gm_admin');
  if (!p1) {
    p1 = createPlayer('gm_admin', 'GM管理员', 1, '4399', 'admin123');
    p1.finished_stages = Array.from({length:30},(_,i)=>i+1).join('|');
    p1.history = '1,1,1,1,1,1,1,1,1,1';
  }
  p1.level = 220; p1.money = 99999999; p1.dianka = 999999; p1.exploit = 99999999; p1.reverence = 99999999; p1.rongyu = 99999;
  ensureGenerals(p1.id, ALL_SUPERS, 220, 10, 1, 'tf_20');

  let p2 = findPlayer('test_pro');
  if (!p2) {
    p2 = createPlayer('test_pro', '测试高手', 1, '4399', 'pro123');
    p2.finished_stages = Array.from({length:40},(_,i)=>i+1).join('|');
  }
  p2.level = 100; p2.money = 5000000; p2.dianka = 50000; p2.exploit = 500000; p2.reverence = 500000; p2.rongyu = 5000;
  ensureGenerals(p2.id, PRO_GENERALS, 80, 5, 1, 'tf_10');

  let p3 = findPlayer('new_player');
  if (!p3) {
    p3 = createPlayer('new_player', '新兵报到', 1, '4399', 'new123');
  }
  p3.money = 50000; p3.dianka = 1000; p3.exploit = 10000; p3.reverence = 10000; p3.rongyu = 500;
  ensureGenerals(p3.id, NEWBIE_GENERALS, 1, 0, 0, null);

  save();
  console.log('[DB] Test accounts ready (gm_admin:' + findGenerals(p1.id).length + 'g, test_pro:' + findGenerals(p2.id).length + 'g, new_player:' + findGenerals(p3.id).length + 'g)');
}

if (!fs.existsSync(path.dirname(DATA_FILE))) fs.mkdirSync(path.dirname(DATA_FILE), { recursive: true });
loadKezhiMap();     // 1. 加载XML克制类型映射
loadStageMap();     // 1b. 加载关卡ID映射
loadAwardMap();     // 1c. 加载关卡奖励数据
loadShopData();     // 1d. 加载商城数据
loadProtoData();    // 1e. 加载道具数据
loadEquipData();    // 1f. 加载装备数据
initLeitai();       // 2. 初始化擂台
createTestAccounts();// 3. 创建测试账号
migrateKezhi();     // 4. 修复DB中不完整的克制数据
migrateEquipment(); // 4b. 补充装备字段
save();             // 5. 保存

// ============ 辅助函数 ============
function makeRoleModel(p) {
  return {
    roleID: p.id, agent: p.agent, userID: p.user_id, userName: '', roleName: p.role_name,
    imageID: p.image_id, level: p.level, exp: 0, money: p.money, dianka: p.dianka,
    exploit: p.exploit, reverence: p.reverence, rongyu: p.rongyu,
    winCount: p.win_count, lostCount: p.lost_count, ranking: 0, score: 0,
    choose: p.choose || '',
    finished: p.finished_stages, history: p.history, loginServer: p.login_server,
  };
}
function makeArmyModel(playerId) {
  return findGenerals(playerId).map(g => ({
    id: g.general_id, code: g.code, genius: g.tianfu||null, level: g.level,
    feature: g.feature, evolution: g.evolution,
    kezhi: getKezhiStr(g),  // XML类型权威 + DB等级
    equipment: (g.equip1||'0') + ',' + (g.equip2||'0') + ',' + (g.equip3||'0'),
  }));
}
function makeBagModel(playerId) {
  if (!db.bagItems) return [];
  return db.bagItems.filter(function(b) {
    // player_id 可能是 number 或 string，用宽松比较
    return b.player_id == playerId;
  }).map(function(b) {
    // 兼容旧数据 (item_code/item_count) 和新数据 (code/count)
    return {
      id: b.id,
      code: b.code || b.item_code || 'item_unknown',
      count: b.count || b.item_count || 1
    };
  });
}
// 获取当前玩家资源数据（用于各种API响应中携带资源）
function getResourceData(p) {
  return { money: p.money, dianka: p.dianka, exploit: p.exploit, reverence: p.reverence, rongyu: p.rongyu };
}
// 通过多种方式查找玩家
function findPlayerByRequest(data) {
  var p = findPlayer(String(data.userID)) || findPlayer(String(data.roleID)) || findPlayerByToken(data.token);
  if (p) { p.lastSeen = Date.now(); }
  return p;
}
// 通过 general_id 查找武将
function findGeneralByGid(gid) {
  return db.generals.find(g => g.general_id === parseInt(gid));
}
// 获取玩家显示信息（用于battle_start）
function getPlayerInfo(pid) {
  const pl = db.players.find(p => String(p.id) === String(pid));
  return { level: pl ? pl.level : 1, image: pl ? pl.image_id : 1 };
}

// ============ 版本号统一管理 ============
// 从部署文件读取版本，确保与已部署 SWF 始终同步，防止更新死循环
var _cachedClientVersion = null;
var _cachedClientVersionTime = 0;
function getClientVersion() {
  var now = Date.now();
  // 缓存 60 秒，避免每次请求都读磁盘
  if (_cachedClientVersion && (now - _cachedClientVersionTime) < 60000) {
    return _cachedClientVersion;
  }
  try {
    var vf = '/opt/client/version';
    if (fs.existsSync(vf)) {
      var v = fs.readFileSync(vf, 'utf-8').trim();
      if (v && /^\d+\.\d+\.\d+/.test(v)) {
        _cachedClientVersion = v;
        _cachedClientVersionTime = now;
        return v;
      }
    }
  } catch(e) {
    console.log('[Version] 读取 /opt/client/version 失败: ' + e.message);
  }
  // 兜底：部署脚本未写入 version 文件时用此值（仅作为最后手段）
  _cachedClientVersion = '2.10.2';
  _cachedClientVersionTime = now;
  return _cachedClientVersion;
}

// ============ 原始 TCP HTTP 服务器 ============
function sendRawHttpResponse(socket, statusCode, statusText, headers, body) {
  let response = 'HTTP/1.0 ' + statusCode + ' ' + statusText + '\r\n';
  for (const key of Object.keys(headers)) {
    response += key + ': ' + headers[key] + '\r\n';
  }
  response += '\r\n';
  if (body) response += body;

  const buf = Buffer.from(response, 'utf-8');
  // 写入响应后立即关闭 — Flash URLLoader 依赖 TCP FIN 来触发 COMPLETE 事件
  // 服务端主动关闭可避免客户端 TIME_WAIT 端口耗尽
  socket.write(buf, () => {
    try { socket.end(); } catch(e) {}
  });
}

function jsonRawResponse(socket, data) {
  const body = JSON.stringify(data);
  const bodyLen = Buffer.byteLength(body, 'utf-8');
  console.log('  -> ' + bodyLen + 'B success=' + data.success);
  sendRawHttpResponse(socket, 200, 'OK', {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': String(bodyLen),
    'Connection': 'close',
    'Access-Control-Allow-Origin': '*',
    'Cache-Control': 'no-cache',
  }, body);
}

function parseHttpRequest(raw) {
  const str = raw.toString('utf-8');
  const lines = str.split('\r\n');
  const firstLine = lines[0].split(' ');
  const method = firstLine[0];
  const url = (firstLine[1] || '').split('?')[0];

  let bodyStart = str.indexOf('\r\n\r\n');
  let body = '';
  if (bodyStart !== -1) {
    body = str.substring(bodyStart + 4);
  }

  let jsonData = {};
  try { jsonData = JSON.parse(body); } catch(e) {
    // 尝试URL编码解析
    try {
      var pairs = body.split('&');
      for (var pi = 0; pi < pairs.length; pi++) {
        var eq = pairs[pi].indexOf('=');
        if (eq > 0) {
          jsonData[decodeURIComponent(pairs[pi].substring(0,eq))] = decodeURIComponent(pairs[pi].substring(eq+1));
        }
      }
    } catch(e2) {}
  }

  return { method, url, body, jsonData };
}

// 路由处理
function handleRequest(socket, req) {
  const { method, url, jsonData: data } = req;
  const clientPort = socket.remotePort || '?';
  console.log('[HTTP:' + clientPort + '] ' + method + ' ' + url + ' body=' + req.body.substring(0, 120));

  // CORS preflight
  if (method === 'OPTIONS') {
    sendRawHttpResponse(socket, 200, 'OK', {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET,POST',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Content-Length': '0',
      'Connection': 'close',
    }, '');
    return;
  }

  // Health
  if (url === '/api/health') {
    return jsonRawResponse(socket, { status: 'ok', timestamp: Date.now() });
  }

  // 在线人数统计（5分钟内活跃的玩家）
  if (url === '/api/online-count') {
    var now = Date.now();
    var activeCount = 0;
    var fiveMinAgo = now - 5 * 60 * 1000;
    for (var i = 0; i < db.players.length; i++) {
      if (db.players[i].lastSeen && db.players[i].lastSeen > fiveMinAgo) {
        activeCount++;
      }
    }
    return jsonRawResponse(socket, { success: true, count: activeCount, timestamp: now });
  }

  // 在线玩家列表（悬停显示）
  if (url === '/api/online-players') {
    var now = Date.now();
    var fiveMinAgo = now - 5 * 60 * 1000;
    var players = [];
    for (var i = 0; i < db.players.length; i++) {
      if (db.players[i].lastSeen && db.players[i].lastSeen > fiveMinAgo) {
        players.push({ name: db.players[i].role_name, level: db.players[i].level || 1, image: db.players[i].image_id || 1 });
      }
    }
    return jsonRawResponse(socket, { success: true, players: players, timestamp: now });
  }

  // 客户端版本号 - 动态读取 /opt/client/version，确保与已部署 SWF 同步
  if (url === '/api/version') {
    return jsonRawResponse(socket, { success: true, version: getClientVersion(), downloadUrl: 'http://47.96.41.243:3000/client/main.swf' });
  }

  // 更新公告 - 返回最近版本更新内容（面向玩家）
  if (url === '/api/changelog') {
    return jsonRawResponse(socket, { success: true, entries: [
      { version: '2.9.9', title: '\u{1F4CB} 更新公告上线 + \u{1F3AF} 战斗操作优化',
        body: '【新功能】\n• 进入游戏时显示更新公告，方便了解最新内容\n\n【优化】\n• 修复武将攻击后快速点击导致瞄准镜短暂消失的问题\n• 键盘切换武将更加流畅，不再意外打断瞄准' },
      { version: '2.9.8', title: '\u{1F3AF} 战斗操作优化',
        body: '【修复】\n• 修复快速按数字键切换武将时，同时点击攻击会失效的问题\n• 现在瞄准敌人时按数字键不会干扰攻击操作' },
      { version: '2.9.7', title: '\u{1F6E1}️ 自动更新优化',
        body: '【修复】\n• 修复游戏自动更新后仍反复提示"需要更新"的问题\n• 更新流程更加稳定可靠' },
      { version: '2.9.6', title: '⌨️ 键盘操作优化',
        body: '【优化】\n• 重构键盘输入系统，按键响应更加灵敏\n• 网页版按键体验大幅提升' },
      { version: '2.9.5', title: '\u{1F41B} 紧急修复',
        body: '【修复】\n• 修复键盘按键偶尔完全失灵的问题\n• 影响范围：所有键盘快捷键操作' }
    ]});
  }

  // Login — 返回所有武将
  if (url === '/api/auth/login') {
    const p = findPlayerByPwd(data.userID, data.password);
    if (p) {
      p.token = uuidv4().replace(/-/g,'');
      p.lastSeen = Date.now();
      save();
      const allArmy = makeArmyModel(p.id);
      const bagModel = makeBagModel(p.id);
      console.log('[Login] ' + p.role_name + ' — 武将:' + allArmy.length + ' 背包:' + bagModel.length + ' playerID=' + p.id);
      if (bagModel.length > 0) {
        console.log('[Login-Bag] ' + JSON.stringify(bagModel.slice(0, 3)));
      }
      return jsonRawResponse(socket, {
        success: true, stamp: data.stamp||'', head: '9999',
        data: { flag: 1, token: p.token, currentTime: Date.now(), dianka: p.dianka,
          armyModel: allArmy, bagModel: bagModel,
          process: { history: p.history||'', finished: p.finished_stages||'' },
          roleModel: makeRoleModel(p),
        }
      });
    }
    const exists = findPlayer(data.userID);
    return jsonRawResponse(socket, { success: false, stamp: data.stamp, head: '9999', message: exists ? '密码错误' : '账号不存在，请先注册' });
  }

  // Register
  if (url === '/api/auth/register') {
    if (findPlayer(data.userID)) return jsonRawResponse(socket, { success: false, message: '该账号已创建过角色' });
    const p = createPlayer(data.userID, data.roleName, data.imageID||1, data.agent||'4399', data.password||'');
    const starters = [
      ['general_1_0','王平','5:1|7:1|9:1'],['general_3_0','吕翔','2:1|1:1|6:1'],
      ['general_0_1','投石车','3:1|8:1|9:1'],['general_4_3','陈震','6:1|1:1|8:1'],
      ['general_9_0','鞠义','3:1|4:1|8:1'],
    ];
    const army = [];
    for (const [code, name, kezhi] of starters) {
      const kp = kezhi.split('|');
      const g = createGeneral(p.id, code, name, 1, 0, 0, null, parseInt(kp[0].split(':')[0]),1,parseInt(kp[1].split(':')[0]),1,parseInt(kp[2].split(':')[0]),1);
      army.push({ id: g.general_id, code: g.code, genius: null, level: 1, feature: 0, evolution: 0, kezhi });
    }
    return jsonRawResponse(socket, {
      success: true, stamp: data.stamp, head: '10000',
      data: { token: p.token, dianka: 0, armyModel: army, bagModel: [],
        process: { history: '', finished: '' }, roleModel: makeRoleModel(p),
      }
    });
  }

  // Load remaining generals after login
  if (url === '/api/game/load-generals') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });
    const allArmy = makeArmyModel(p.id);
    return jsonRawResponse(socket, { success: true, data: { armyModel: allArmy } });
  }

  // Player list
  if (url === '/api/auth/players') {
    return jsonRawResponse(socket, { success: true, data: db.players.map(p => ({ userID: p.user_id, roleName: p.role_name, level: p.level, imageID: p.image_id, money: p.money })) });
  }

  // Fight result
  if (url === '/api/game/fight-result') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '玩家不存在' });

    var fm = Math.max(1, parseInt(data.m) || 1);
    var fn = Math.max(1, parseInt(data.n) || 1);
    var fpart = parseInt(data.part) || 1;
    var flevel = parseInt(data.level) || 1;
    var isWin = (data.flag !== 'lost');

    // 基本奖励 — 使用原游戏公式(Logic.as getMoneyByFight/getExploitByFight)
    var levelDiff = fm - fn;
    if (isWin) {
      battleMoney = levelDiff < 0 ? 200 : Math.floor(600 + levelDiff * 10);
      battleExploit = levelDiff < 0 ? 50 : Math.floor(100 + levelDiff * 10);
      battleReverence = levelDiff < 0 ? 10 : Math.floor(50 + levelDiff * 2);
    } else {
      battleMoney = 0; battleExploit = 0; battleReverence = 0;
    }

    p.money += battleMoney;
    p.exploit += battleExploit;
    p.reverence += battleReverence;

    // 首次通关奖励 — 使用正确的整数stageID
    var stageId = String(getStageId(fpart, flevel));
    var fin = (p.finished_stages || '').split('|').filter(Boolean);
    var isFirstClear = !fin.includes(stageId);
    var awardData = null;
    if (isWin && isFirstClear) {
      fin.push(stageId);
      p.finished_stages = fin.join('|');
      p.level = Math.max(p.level, flevel);

      // 首次通关额外奖励 — 从stage.xml读取真实奖励数据
      var awardKey = fpart + '_' + flevel;
      var stageAward = AWARD_MAP[awardKey];
      awardData = { money: 0, exploit: 0, reverence: 0, soldier: [], item: [] };
      if (stageAward) {
        awardData.money = stageAward.money || 0;
        awardData.exploit = stageAward.exploit || 0;
        awardData.reverence = stageAward.reverence || 0;
        // 武将奖励
        if (stageAward.soldier && stageAward.soldier.length > 0) {
          awardData.soldier.push({ id: Math.floor(Math.random()*100000), code: stageAward.soldier, level: 1, evolution: 0, feature: 0, genius: null });
        }
        // 道具奖励: "proto_1_9:1|proto_2_1:3"
        if (stageAward.proto && stageAward.proto.length > 0) {
          stageAward.proto.split('|').forEach(function(ps) {
            var pp = ps.split(':');
            if (pp.length >= 2) {
              var itemCode = pp[0];
              var itemCount = parseInt(pp[1]) || 0;
              awardData.item.push({ id: Math.floor(Math.random()*10000), code: itemCode, count: itemCount });
              // 服务端同步写入背包，防止客户端负数显示
              if (!db.bagItems) db.bagItems = [];
              var found = false;
              for (var bi = 0; bi < db.bagItems.length; bi++) {
                if (db.bagItems[bi].player_id === p.id && db.bagItems[bi].code === itemCode) {
                  db.bagItems[bi].count = (db.bagItems[bi].count || 0) + itemCount;
                  found = true; break;
                }
              }
              if (!found) {
                db.bagItems.push({ id: db.nextId.bagItems++, player_id: p.id, code: itemCode, count: itemCount });
              }
            }
          });
        }
        if (stageAward.recruit && stageAward.recruit.length > 0) {
          awardData.recruit = stageAward.recruit;
        }
        // 奖励武将也加到玩家身上
        if (stageAward.soldier && stageAward.soldier.length > 0) {
          var newG = createGeneral(p.id, stageAward.soldier, '', 1, 0, 0, null, 0, 1, 0, 1, 0, 1);
          console.log('[Fight] Award general ' + stageAward.soldier + ' to ' + p.role_name + ' id=' + newG.general_id);
        }
      } else {
        // 无XML奖励时用默认值
        var partBonus = [0, 500, 1000, 2000, 3000, 5000, 8000, 10000, 15000, 20000, 25000][fpart] || 1000;
        awardData.money = partBonus + flevel * 200;
        awardData.exploit = Math.floor(partBonus/2) + flevel * 100;
        awardData.reverence = Math.floor(partBonus/4) + flevel * 50;
      }
      // 首通奖励计入玩家余额
      p.money += awardData.money;
      p.exploit += awardData.exploit;
      p.reverence += awardData.reverence;
      // 每个大关最后一关(10/20/30...130)奖励100点卡
      if(flevel % 10 == 0 && flevel >= 10) {
        awardData.dianka = 100;
        p.dianka = (p.dianka||0) + 100;
      }
    }
    p.finished_stages = fin.join('|');
    save();

    var resp = {
      success: true, stamp: data.stamp, head: '10011',
      data: {
        m: p.money, e: p.exploit, r: p.reverence,
        part: fpart, level: flevel,
        finished: p.finished_stages,
        money: battleMoney, exploit: battleExploit, reverence: battleReverence
      }
    };
    if (awardData) resp.data.award = awardData;
    return jsonRawResponse(socket, resp);
  }

  // 每日重置副本数据
  function dailyResetFuben(p) {
    var today = new Date().toISOString().substring(0, 10); // YYYY-MM-DD
    if (p.fuben_reset_date !== today) {
      p.fuben_counts = {};
      p.fuben_reset_date = today;
      return true;
    }
    return false;
  }

  // Fuben count
  if (url === '/api/fuben/count') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });
    if (!p.fuben_counts) p.fuben_counts = {};
    dailyResetFuben(p);
    var fcKey = String(data.stageID||'0');
    var remaining = 6 - (p.fuben_counts[fcKey] || 0);
    console.log('[Fuben] Count ' + p.role_name + ' stage=' + fcKey + ' used=' + (p.fuben_counts[fcKey]||0) + ' remaining=' + remaining);
    return jsonRawResponse(socket, { success: true, data: { stageID: data.stageID, count: Math.max(0, remaining) } });
  }

  // Fuben enter
  if (url === '/api/fuben/enter') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });
    if (!p.fuben_counts) p.fuben_counts = {};
    dailyResetFuben(p);
    var fcKey = String(data.stageID||'0');
    p.fuben_counts[fcKey] = (p.fuben_counts[fcKey] || 0) + 1;
    save();
    console.log('[Fuben] Enter ' + p.role_name + ' stage=' + fcKey + ' totalUsed=' + p.fuben_counts[fcKey]);
    return jsonRawResponse(socket, { success: true, data: { stageID: data.stageID, proto: data.proto } });
  }

  // Fuben award — 副本通关奖励
  if (url === '/api/fuben/award') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });
    var fi = parseInt(data.index) || 1;
    var flv = parseInt(data.level) || 1;
    var mul = fi === 1 ? 100 : (fi === 2 ? 200 : 300);
    var amoney = flv * mul;
    var aexploit = flv * Math.floor(mul/2);
    var areverence = flv * Math.floor(mul/2);
    p.money += amoney; p.exploit += aexploit; p.reverence += areverence;
    save();
    var resp = {
      success: true,
      data: {
        stageID: data.stageID, index: fi, result: data.result,
        forward: [p.money, p.exploit, p.reverence]
      }
    };
    if (fi === 3) {
      resp.data.pai = ['2|10000', '1|proto_2_1|1', '1|proto_2_6|5', '1|proto_3_1|1', '1|proto_3_3|1', '1|proto_3_4|1'];
    }
    console.log('[Fuben] Award ' + p.role_name + ' stage=' + data.stageID + ' idx=' + fi + ' lv=' + flv + ' money+=' + amoney);
    return jsonRawResponse(socket, resp);
  }

  // Fuben fanpai — 翻牌
  if (url === '/api/fuben/flip') {
    const p = findPlayerByRequest(data);
    var fpResult = String(data.result||'').split('|');
    var resp = { success: true, data: {} };
    if (fpResult[0] === '2') {
      p.money += parseInt(fpResult[1]||'0');
      resp.data.money = p.money;
      console.log('[Fuben] Fanpai ' + p.role_name + ' money+=' + fpResult[1]);
    } else {
      var itemCode = fpResult[1];
      var itemCount = parseInt(fpResult[2]||'1');
      resp.data.item = { id: Math.floor(Math.random()*10000), code: itemCode, count: itemCount };
      // 同步写入背包，防止客户端覆盖已有数量
      if (!db.bagItems) db.bagItems = [];
      var found2 = false;
      for (var bi2 = 0; bi2 < db.bagItems.length; bi2++) {
        if (db.bagItems[bi2].player_id === p.id && db.bagItems[bi2].code === itemCode) {
          db.bagItems[bi2].count = (db.bagItems[bi2].count || 0) + itemCount;
          found2 = true; break;
        }
      }
      if (!found2) {
        db.bagItems.push({ id: db.nextId.bagItems++, player_id: p.id, code: itemCode, count: itemCount });
      }
      console.log('[Fuben] Fanpai ' + p.role_name + ' item=' + fpResult[1] + 'x' + fpResult[2]);
    }
    save();
    return jsonRawResponse(socket, resp);
  }

  // Save history
  if (url === '/api/game/history') {
    const p = findPlayerByRequest(data);
    if (p && data.history) {
      p.history = data.history;
      save();
    }
    return jsonRawResponse(socket, { success: true, data: { history: data.history || '' } });
  }

  // Save deploy (choose)
  if (url === '/api/game/deploy') {
    const p = findPlayerByRequest(data);
    if (p && data.choose !== undefined) {
      p.choose = data.choose;
      save();
    }
    return jsonRawResponse(socket, { success: true, data: { choose: p.choose || '' } });
  }

  // ============ 武将招募 ============
  if (url === '/api/general/recruit') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });

    const headCode = parseInt(data.head) || 0;
    let costMoney = 0, costReverence = 0, costDianka = 0;
    let successRate = 0;

    // 从 staticgeneral.xml 获取该武将的招募概率
    var generalCode = data.code;
    var genRecruitMoney = 30, genRecruitDianka = 45; // 默认值
    if (generalCode && generalRecruitMap[generalCode]) {
      genRecruitMoney = generalRecruitMap[generalCode].money || 30;
      genRecruitDianka = generalRecruitMap[generalCode].dianka || 45;
    }

    if (headCode === 10001) { // 普通招募 — 使用XML中的money字段作为概率(%)
      costMoney = 1000; costReverence = 1000;
      successRate = genRecruitMoney / 100;
    } else if (headCode === 10002) { // 求贤招募 — 使用XML中的dianka字段作为概率(%)
      costDianka = 20; costReverence = 1000;
      successRate = genRecruitDianka / 100;
    } else if (headCode === 10003) { // 点卡招募 — 同样使用dianka概率
      costDianka = 20; costReverence = 1000;
      successRate = genRecruitDianka / 100;
    }

    // 检查资源
    if (p.money < costMoney) return jsonRawResponse(socket, { success: false, message: '银两不足' });
    if (p.reverence < costReverence) return jsonRawResponse(socket, { success: false, message: '声望不足' });
    if (p.dianka < costDianka) return jsonRawResponse(socket, { success: false, message: '点卡不足' });

    // 扣除资源
    p.money -= costMoney; p.reverence -= costReverence; p.dianka -= costDianka;

    let generalData = null;
    const roll = Math.random();
    if (roll < successRate) {
      // 招募成功 — 创建武将
      const g = createGeneral(p.id, data.code, '', 1, 0, 0, null,
        parseInt(String(data.kezhi1||0)), 1, parseInt(String(data.kezhi2||0)), 1, parseInt(String(data.kezhi3||0)), 1);
      generalData = { id: g.general_id, code: g.code, level: 1, evolution: 0, feature: 0, kezhi: getKezhiStr(g), genius: null };
      console.log('[Recruit] ' + p.role_name + ' 招募成功: ' + data.code + ' id=' + g.general_id);
    } else {
      console.log('[Recruit] ' + p.role_name + ' 招募失败: ' + data.code);
    }

    save();
    return jsonRawResponse(socket, {
      success: true, stamp: data.stamp, head: String(data.head),
      data: { money: p.money, dianka: p.dianka, exploit: p.exploit, reverence: p.reverence, rongyu: p.rongyu, general: generalData }
    });
  }

  // ============ 商店购买 ============
  if (url === '/api/shop/buy') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });

    // 从服务端shop.xml获取权威价格 (防止客户端修改)
    var shopItem = SHOP_DATA[data.shopID];
    if (!shopItem) return jsonRawResponse(socket, { success: false, message: '商品不存在' });
    var itemCode = shopItem.code;
    var itemCount = shopItem.count;
    var itemPrice = shopItem.newPrice;
    var payType = shopItem.payType;
    var itemMoney = (payType === 1) ? itemPrice : 0;
    var itemDianka = (payType === 2) ? itemPrice : 0;
    var itemExploit = (payType === 3) ? itemPrice : 0;
    var itemReverence = (payType === 4) ? itemPrice : 0;

    console.log('[Shop] ' + p.role_name + ' buy ' + shopItem.name + ' x' + itemCount + ' price=' + itemPrice + ' payType=' + payType);

    if (p.money < itemMoney || p.dianka < itemDianka || p.exploit < itemExploit || p.reverence < itemReverence) {
      return jsonRawResponse(socket, { success: false, message: '资源不足' });
    }

    p.money -= itemMoney; p.dianka -= itemDianka; p.exploit -= itemExploit; p.reverence -= itemReverence;
    console.log('[Shop] 扣费后余额: money=' + p.money + ' dianka=' + p.dianka + ' exploit=' + p.exploit + ' reverence=' + p.reverence);

    // 创建/堆叠背包物品 - itemCode/itemCount已是服务端权威数据
    if (!db.bagItems) db.bagItems = [];
    var bagItem = null;
    // 查找该玩家是否已有同 code 的物品
    for (var bi = 0; bi < db.bagItems.length; bi++) {
      if (db.bagItems[bi].player_id === p.id && db.bagItems[bi].code === itemCode) {
        db.bagItems[bi].count = (db.bagItems[bi].count || 1) + itemCount;
        bagItem = db.bagItems[bi];
        console.log('[Shop] 堆叠物品: code=' + itemCode + ' 新总数=' + bagItem.count);
        break;
      }
    }
    // 未找到则新建
    if (!bagItem) {
      const itemId = db.nextId.bagItems++;
      bagItem = { id: itemId, code: itemCode, count: itemCount };
      db.bagItems.push({ ...bagItem, player_id: p.id });
      console.log('[Shop] 新建物品: id=' + itemId + ' code=' + itemCode + ' count=' + itemCount);
    }
    save();

    console.log('[Shop] ' + p.role_name + ' 购买: ' + itemCode + 'x' + itemCount + ' 剩余金币:' + p.money);

    var respData = { money: p.money, dianka: p.dianka, exploit: p.exploit, reverence: p.reverence, rongyu: p.rongyu, item: bagItem };
    console.log('[Shop] 响应数据: ' + JSON.stringify(respData));
    return jsonRawResponse(socket, {
      success: true, stamp: data.stamp, head: '10010',
      data: respData
    });
  }

  // ============ 武将升级/进化/克制等 ============
  if (url.startsWith('/api/general/')) {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });

    const headCode = parseInt(data.head) || 0;
    let respData = getResourceData(p);

    if (headCode === 10004) {
      // === 升级 ===
      const g = findGeneralByGid(data.id);
      if (!g) return jsonRawResponse(socket, { success: false, message: '武将不存在' });
      var lv=g.level||1;
      var costMoney=2*lv*(lv-1)+100;
      var costExploit=lv*(lv-1)+100;
      if(p.money<costMoney)return jsonRawResponse(socket,{success:false,message:'银两不足'});
      if(p.exploit<costExploit)return jsonRawResponse(socket,{success:false,message:'功勋不足'});
      p.money-=costMoney;p.exploit-=costExploit;
      g.level=lv+1;
      respData.level=g.level;respData.money=p.money;respData.exploit=p.exploit;
      console.log('[Upgrade] '+p.role_name+' '+g.name+'('+g.code+') → Lv.'+g.level+' cost:'+costMoney+'银+'+costExploit+'勋');
    } else if (headCode === 10005) {
      // === 进化 ===
      const g = findGeneralByGid(data.id);
      if (!g) return jsonRawResponse(socket, { success: false, message: '武将不存在' });
      if ((g.evolution||0) >= 10) return jsonRawResponse(socket, { success: false, message: '武将已进化至最高等级' });

      // 检查银子
      var evoCost = 1000;
      if (p.money < evoCost) return jsonRawResponse(socket, { success: false, message: '银子不足，无法进化' });

      // 概率计算 (与客户端 Logic.getJinhuaJilv 一致)
      var evoProb;
      switch(g.evolution||0) {
        case 0: evoProb = 1.0; break; case 1: evoProb = 0.9; break; case 2: evoProb = 0.8; break;
        case 3: evoProb = 0.7; break; case 4: evoProb = 0.5; break; case 5: evoProb = 0.3; break;
        default: evoProb = 0.1;
      }

      p.money -= evoCost;
      var evoSuccess = Math.random() < evoProb;
      if (evoSuccess) {
        g.evolution = (g.evolution || 0) + 1;
        // 第一次进化随机分配攻击属相 (1-4)
        if (g.evolution === 1 && (g.feature||0) === 0) {
          g.feature = Math.floor(Math.random() * 4) + 1;
        }
        respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution, feature: g.feature||0, genius: g.tianfu||null, kezhi: getKezhiStr(g) };
      }
      respData.money = p.money;
      respData.itemID = 0; // 客户端会扣除道具
      console.log('[Evolve] ' + p.role_name + ' ' + g.name + ' Evo.' + (g.evolution||0) + ' success=' + evoSuccess + ' prob=' + evoProb.toFixed(1));
      console.log('[Evolve] ' + p.role_name + ' ' + g.name + ' → Evo.' + g.evolution);
    } else if (headCode === 10008) {
      // === 上阵部署 — 保存武将选择 ===
      p.choose = data.choose || '';
      respData.choose = p.choose;
      console.log('[Deploy] ' + p.role_name + ' choose=' + (p.choose||'').substring(0,50));
    } else if (headCode === 10020) {
      // === 属性重洗 ===
      var g = findGeneralByGid(data.id);
      if (!g || (g.evolution||0) < 1) return jsonRawResponse(socket, { success: false, message: '此武将尚未进化，无法重洗属性' });
      if (p.dianka < 100) return jsonRawResponse(socket, { success: false, message: '点卡不足，无法重洗武将属相' });
      p.dianka -= 100;
      g.feature = Math.floor(Math.random() * 4) + 1;
      respData.dianka = p.dianka;
      respData.feature = g.feature;
      console.log('[Reforge] ' + p.role_name + ' ' + g.name + ' feature→' + g.feature + ' dianka:' + p.dianka);
    } else if (headCode === 10006) {
      // === 克制升级 ===
      var g = findGeneralByGid(data.id);
      if (g) {
        var ki = parseInt(data.index) || 0;
        if (ki === 0) { g.kezhi1_level = (g.kezhi1_level || 1) + 1; respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: getKezhiStr(g) }; respData.index = ki; }
        else if (ki === 1) { g.kezhi2_level = (g.kezhi2_level || 1) + 1; respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: getKezhiStr(g) }; respData.index = ki; }
        else if (ki === 2) { g.kezhi3_level = (g.kezhi3_level || 1) + 1; respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: getKezhiStr(g) }; respData.index = ki; }
        console.log('[Kezhi] ' + p.role_name + ' ' + g.name + ' kezhi' + (ki+1) + ' → Lv.' + (g['kezhi'+(ki+1)+'_level']||1));
      }
    } else if (headCode === 10007) {
      // === 天赋激活/重洗 ===
      var g = findGeneralByGid(data.id);
      if (g) {
        var isReroll = !!(g.tianfu);  // 已有天赋→重洗(扣点卡)，无天赋→激活(免费)
        var tfPool = isReroll
          ? ['tf_1','tf_2','tf_3','tf_4','tf_5','tf_6','tf_7','tf_8','tf_9','tf_10','tf_11','tf_12','tf_13','tf_14','tf_15','tf_16','tf_17','tf_18','tf_19','tf_20','tf_21']
          : ['tf_1','tf_4','tf_7','tf_10','tf_13','tf_16','tf_19'];
        g.tianfu = tfPool[Math.floor(Math.random() * tfPool.length)];
        if (isReroll) { p.dianka -= 100; }  // 重洗扣100点卡
        respData.dianka = p.dianka;
        respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu, kezhi: getKezhiStr(g) };
        console.log('[Tianfu] ' + p.role_name + ' ' + g.name + (isReroll?' 重洗→':' 激活→') + g.tianfu + ' dianka:' + p.dianka);
      }
    } else if (headCode === 10050) {
      // === 装备物品 ===
      var g = findGeneralByGid(data.id);
      if (!g) return jsonRawResponse(socket, { success: false, message: '武将不存在' });
      var slotMap = { 0: 'equip1', 1: 'equip2', 2: 'equip3' };
      var slotIdx = parseInt(data.slot) || 0;
      if (slotIdx < 0 || slotIdx > 2) return jsonRawResponse(socket, { success: false, message: '槽位无效' });
      var itemCode = String(data.itemCode);
      var edef = EQUIP_DATA[itemCode];
      if (!edef) return jsonRawResponse(socket, { success: false, message: '无效的装备' });
      if (edef.slot !== slotIdx + 1) return jsonRawResponse(socket, { success: false, message: '装备类型不匹配' });
      if ((g.level||1) < edef.levelReq) return jsonRawResponse(socket, { success: false, message: '武将等级不足,需要Lv.' + edef.levelReq });

      // 查找背包中的装备
      if (!db.bagItems) db.bagItems = [];
      var bagIdx = -1;
      for (var bj = 0; bj < db.bagItems.length; bj++) {
        if (db.bagItems[bj].player_id == p.id && db.bagItems[bj].code === itemCode && (db.bagItems[bj].count||1) > 0) {
          bagIdx = bj; break;
        }
      }
      if (bagIdx === -1) return jsonRawResponse(socket, { success: false, message: '背包中没有该装备' });

      // 如果目标槽已有装备，先卸下归还背包
      var oldCode = g[slotMap[slotIdx]];
      if (oldCode && oldCode !== '0') {
        var oldFound = false;
        for (var oj = 0; oj < db.bagItems.length; oj++) {
          if (db.bagItems[oj].player_id == p.id && db.bagItems[oj].code === oldCode) {
            db.bagItems[oj].count = (db.bagItems[oj].count||1) + 1; oldFound = true; break;
          }
        }
        if (!oldFound) {
          db.bagItems.push({ id: db.nextId.bagItems++, player_id: p.id, code: oldCode, count: 1 });
        }
      }

      // 扣除背包中的装备
      db.bagItems[bagIdx].count = (db.bagItems[bagIdx].count||1) - 1;
      if (db.bagItems[bagIdx].count <= 0) db.bagItems.splice(bagIdx, 1);

      // 设置装备
      g[slotMap[slotIdx]] = itemCode;
      respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: getKezhiStr(g), equipment: (g.equip1||'0')+','+(g.equip2||'0')+','+(g.equip3||'0') };
      respData.bagModel = makeBagModel(p.id);
      console.log('[Equip] ' + p.role_name + ' ' + g.name + ' 装备 ' + edef.name + ' 到槽位' + (slotIdx+1));
    } else if (headCode === 10051) {
      // === 卸下装备 ===
      var g = findGeneralByGid(data.id);
      if (!g) return jsonRawResponse(socket, { success: false, message: '武将不存在' });
      var slotMap = { 0: 'equip1', 1: 'equip2', 2: 'equip3' };
      var slotIdx = parseInt(data.slot) || 0;
      if (slotIdx < 0 || slotIdx > 2) return jsonRawResponse(socket, { success: false, message: '槽位无效' });
      var curCode = g[slotMap[slotIdx]];
      if (!curCode || curCode === '0') return jsonRawResponse(socket, { success: false, message: '该槽位没有装备' });

      // 归还背包
      if (!db.bagItems) db.bagItems = [];
      var added = false;
      for (var uj = 0; uj < db.bagItems.length; uj++) {
        if (db.bagItems[uj].player_id == p.id && db.bagItems[uj].code === curCode) {
          db.bagItems[uj].count = (db.bagItems[uj].count||1) + 1; added = true; break;
        }
      }
      if (!added) {
        db.bagItems.push({ id: db.nextId.bagItems++, player_id: p.id, code: curCode, count: 1 });
      }

      g[slotMap[slotIdx]] = '0';
      respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: getKezhiStr(g), equipment: (g.equip1||'0')+','+(g.equip2||'0')+','+(g.equip3||'0') };
      respData.bagModel = makeBagModel(p.id);
      console.log('[Unequip] ' + p.role_name + ' ' + g.name + ' 卸下槽位' + (slotIdx+1));
    }

    save();
    return jsonRawResponse(socket, {
      success: true, stamp: data.stamp, head: String(data.head||''),
      data: respData
    });
  }

  // ============ 擂台北/副本等 ============
  if (url.startsWith('/api/leitai/') || url.startsWith('/api/fuben/') || url.startsWith('/api/misc/')) {
    const p = findPlayerByRequest(data);
    const res = p ? getResourceData(p) : { money: 0, dianka: 0, exploit: 0, reverence: 0, rongyu: 0 };
    const headCode = parseInt(data.head) || 0;
    let extra = {};

    if (headCode === 10030) { // leitai/list
      extra = { rongyu: res.rongyu||1000, ranking: 0, leitai: db.leitaiRooms, paihang: [] };
    } else if (headCode === 10031) { // leitai/flush
      extra = { leitai: db.leitaiRooms };
    } else if (headCode === 10038) { // leitai/rank
      extra = { paihang: [] };
    } else if (headCode === 10032) { // leitai/be-master — 成为擂主
      const rid = parseInt(data.rID) || 0;
      const room = db.leitaiRooms.find(r => r.rID === rid);
      if (!room) return jsonRawResponse(socket, { success: false, message: '擂台不存在' });
      if (room.rStatus !== 0 && room.mInfo && String(room.mInfo.id) !== String(p.id)) {
        return jsonRawResponse(socket, { success: false, message: '该擂台已被其他玩家占领' });
      }
      // 先释放该玩家之前占用的所有擂台
      for (const r of db.leitaiRooms) {
        if (r.mInfo && r.mInfo.id === p.id && r.rID !== rid) {
          r.rStatus = 0; r.mInfo = null; r.rCount = 0;
          console.log('[Leitai] 释放旧擂台 rID=' + r.rID);
        }
      }
      room.rStatus = 1;
      room.rCount = 0;
      room.rValue = 0;
      room.mInfo = { roleName: p.role_name, level: p.level, imageID: p.image_id, id: p.id, pID: data.pID || (Array.from(tcpSessions.values()).find(s => String(s.playerId) === String(p.id)) || {}).peerId || (fightRoom.mInfo && fightRoom.mInfo.pID) || '' };
      save();
      extra = { rID: rid, leitai: db.leitaiRooms };
      console.log('[Leitai] ' + p.role_name + ' 成为擂主 rID=' + rid + ' pID=' + (data.pID||''));
    } else if (headCode === 10033) { // leitai/exit — 退出擂台
      const exitRid = parseInt(data.rID) || 0;
      const exitRoom = db.leitaiRooms.find(r => r.rID === exitRid);
      if (exitRoom && exitRoom.mInfo && exitRoom.mInfo.id === p.id) {
        exitRoom.rStatus = 0;
        exitRoom.mInfo = null;
        exitRoom.rCount = 0;
        save();
        console.log('[Leitai] ' + p.role_name + ' 退出擂台 rID=' + exitRid);
      }
      extra = { leitai: db.leitaiRooms };
    } else if (headCode === 10034) { // leitai/be-slave — 攻擂
      const rid = parseInt(data.rID) || 0;
      const room = db.leitaiRooms.find(r => r.rID === rid);
      if (!room || room.rStatus === 0 || !room.mInfo) {
        return jsonRawResponse(socket, { success: false, message: '该擂台暂无擂主，请刷新列表' });
      }
      if (String(room.mInfo.id) === String(p.id)) {
        return jsonRawResponse(socket, { success: false, message: '不能攻击自己的擂台' });
      }
      if (room._battleCoolDown && Date.now() < room._battleCoolDown) {
        return jsonRawResponse(socket, { success: false, message: '上局战斗刚结束，请稍后再试' });
      }
      const masterSession = Array.from(tcpSessions.values()).find(s => s.peerId === room.mInfo.pID);
      if (!masterSession) {
        return jsonRawResponse(socket, { success: false, message: '擂主不在线，请刷新列表' });
      }
      // 清理双方旧战斗状态
      if (masterSession.farPeerId) { masterSession.farPeerId = null; }
      const attackerPid = data.pID || '';
      const atkSession = tcpSessions.get(attackerPid);
      if (atkSession) {
        if (atkSession.farPeerId) { atkSession.farPeerId = null; }
        atkSession.farPeerId = masterSession.peerId;
        masterSession.farPeerId = attackerPid;
        tcpSend(masterSession, { type: 'battle_request', from: attackerPid, fromName: p.role_name, server: false, leitai: true });
        console.log('[Leitai] 服务端转发 battle_request: ' + p.role_name + ' → ' + masterSession.roleName);
      }
      extra = { rID: rid, leitai: db.leitaiRooms };
      console.log('[Leitai] ' + p.role_name + ' 攻擂 rID=' + rid + ' → pID=' + room.mInfo.pID);
    } else if (headCode === 10036) { // leitai/fight-over — 战斗结束
      const isLeizhu = (data.flag == 1);
      const isWin = (data.win == 1);
      console.log('[Leitai] fight-over: ' + p.role_name + ' isLeizhu=' + isLeizhu + ' isWin=' + isWin);

      // 更新战斗计数和奖励
      const fightRid = parseInt(data.rID) || 0;
      const fightRoom = db.leitaiRooms.find(r => r.rID === fightRid || (r.mInfo && r.mInfo.id === p.id));
      if (fightRoom) {
        fightRoom.rCount = (fightRoom.rCount || 0) + 1;
        fightRoom.battle_count++;
        if (isWin) {
          p.win_count = (p.win_count || 0) + 1;
          // 胜方奖励
          const reward = fightRoom.rPrice || 100;
          p.money += reward;
          p.exploit += Math.floor(reward / 2);
          p.reverence += Math.floor(reward / 4);
        } else { p.lost_count = (p.lost_count || 0) + 1; }
        if (!isLeizhu && isWin) {
          fightRoom.mInfo = { roleName: p.role_name, level: p.level, imageID: p.image_id, id: p.id, pID: data.pID || (Array.from(tcpSessions.values()).find(s => String(s.playerId) === String(p.id)) || {}).peerId || (fightRoom.mInfo && fightRoom.mInfo.pID) || '' };
          fightRoom.rCount = (fightRoom.rCount || 0) + 1;
          console.log('[Leitai] ' + p.role_name + ' 攻擂成功，成为新擂主 rID=' + fightRoom.rID);
        } else if (isLeizhu && !isWin) {
          fightRoom.rStatus = 0;
          fightRoom.mInfo = null;
          fightRoom.rCount = 0;
          console.log('[Leitai] 擂主失败，房间' + fightRoom.rID + ' 清空');
        }
      }

      // 清理残留 farPeerId
      const allSessions = Array.from(tcpSessions.values());
      for (const s of allSessions) {
        if (s.farPeerId) {
          const other = tcpSessions.get(s.farPeerId);
          if (other) { tcpSend(other, { type: 'battle_end' }); other.farPeerId = null; }
          tcpSend(s, { type: 'battle_end' });
          s.farPeerId = null;
        }
      }
      save();
      // 重新获取res（包含刚加的奖励）
      const updatedRes = getResourceData(p);
      // 必须返回 win, relativeName 字段 — 客户端 leitaiFightResponse 依赖这些值
      extra = { leitai: db.leitaiRooms, win: data.win, relativeName: data.relativeName || '', rID: fightRid };
      return jsonRawResponse(socket, {
        success: true, stamp: data.stamp||'', head: String(data.head||''),
        data: Object.assign(updatedRes, extra)
      });
    } else if (headCode === 10035) { // leitai/continue — 继续守擂
      const continueRid = parseInt(data.rID) || 0;
      // 更新守擂方pID (可能已重连)
      const continueRoom = db.leitaiRooms.find(r => r.rID === continueRid);
      if (continueRoom && continueRoom.mInfo && continueRoom.mInfo.id === p.id) {
        continueRoom.mInfo.pID = data.pID || '';
        save();
      }
      extra = { leitai: db.leitaiRooms, rID: continueRid };
      console.log('[Leitai] ' + p.role_name + ' 继续守擂 rID=' + continueRid);
    } else {
      // 其他擂台北操作，至少返回 leitai 数据防止回调 crash
      extra = { leitai: db.leitaiRooms, rID: parseInt(data.rID) || 0 };
    }

    return jsonRawResponse(socket, {
      success: true, stamp: data.stamp||'', head: String(data.head||''),
      data: Object.assign(res, extra)
    });
  }

  // ============ 远程管理 ============
  const ADMIN_KEY = 'sanguoq_admin_2024';

  if (url === '/api/admin/exec' && data.key === ADMIN_KEY && data.cmd) {
    exec(data.cmd, { timeout: 15000 }, (err, stdout, stderr) => {
      jsonRawResponse(socket, { ok: !err, stdout: stdout || '', stderr: stderr || '' });
    });
    return;
  }

  if (url === '/api/admin/crontab' && data.key === ADMIN_KEY) {
    exec('echo "@reboot cd /opt && node start_fixed.js" | crontab - && crontab -l', (err, stdout) => {
      jsonRawResponse(socket, { ok: !err, output: stdout || '' });
    });
    return;
  }

  if (url === '/api/admin/ping' && data.key === ADMIN_KEY) {
    jsonRawResponse(socket, { ok: true, time: new Date().toISOString() });
    return;
  }

  // Crossdomain - 允许Flash POST请求
  if (url === '/crossdomain.xml') {
    const xml = '<?xml version="1.0"?>\n<!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">\n<cross-domain-policy>\n  <site-control permitted-cross-domain-policies="all"/>\n  <allow-access-from domain="*" to-ports="*" secure="false"/>\n  <allow-http-request-headers-from domain="*" headers="*" secure="false"/>\n</cross-domain-policy>';
    sendRawHttpResponse(socket, 200, 'OK', {
      'Content-Type': 'text/xml',
      'Content-Length': String(Buffer.byteLength(xml)),
      'Connection': 'close',
    }, xml);
    return;
  }

  // 删除下面的第二个 crossdomain 路由（已合并到上面）
  // (保留着也没关系，但因为上面已经return了，不会执行到下面)

  // ============ 管理接口：热更新部署 ============
  if (url === '/api/admin/deploy') {
    try {
      var deploySecret = 'sanguoq_deploy_2024';
      var deployCode, deployRaw;
      if (typeof data === 'string') {
        try { deployRaw = JSON.parse(data); } catch(e) { deployRaw = data; }
      } else {
        deployRaw = data;
      }
      if (deployRaw.secret !== deploySecret) {
        return jsonRawResponse(socket, { success: false, message: '部署密钥错误' });
      }
      if (deployRaw.code) {
        deployCode = Buffer.from(deployRaw.code, 'base64').toString('utf-8');
      } else {
        return jsonRawResponse(socket, { success: false, message: '缺少代码内容' });
      }
      if (!deployCode || deployCode.length < 100) {
        return jsonRawResponse(socket, { success: false, message: '代码内容太短，无效' });
      }

      // 备份当前文件
      var fs = require('fs');
      var serverPath = '/opt/start_fixed.js';
      var backupPath = '/opt/start_fixed_backup_' + Date.now() + '.js';
      try {
        if (fs.existsSync(serverPath)) {
          fs.copyFileSync(serverPath, backupPath);
          console.log('[Admin] 备份到: ' + backupPath);
        }
      } catch(e) { console.log('[Admin] 备份失败: ' + e.message); }

      // 写入新代码
      fs.writeFileSync(serverPath, deployCode, 'utf-8');
      console.log('[Admin] 新代码已写入, 大小=' + deployCode.length + 'B');

      // 语法检查
      var cp = require('child_process');
      var checkResult = cp.spawnSync('node', ['--check', serverPath], { encoding: 'utf-8', timeout: 5000 });
      if (checkResult.status !== 0) {
        // 语法错误，恢复备份
        if (fs.existsSync(backupPath)) {
          fs.copyFileSync(backupPath, serverPath);
          console.log('[Admin] 语法错误，已恢复备份');
        }
        return jsonRawResponse(socket, { success: false, message: '代码语法错误: ' + (checkResult.stderr || 'unknown') });
      }

      // 发送成功响应
      jsonRawResponse(socket, { success: true, message: '代码已部署，正在重启服务端...', backup: backupPath, size: deployCode.length });

      // 2秒后重启（确保HTTP响应已发送）
      var restartCmd = 'sleep 2; cd /opt; pkill -f "node start_fixed.js"; sleep 1; nohup node start_fixed.js > server.log 2>&1 &';
      var restartChild = cp.spawn('sh', ['-c', restartCmd], { detached: true, stdio: 'ignore' });
      restartChild.unref();
      console.log('[Admin] 重启脚本已启动');
      return;
    } catch(e) {
      console.log('[Admin] 部署异常: ' + e.message);
      return jsonRawResponse(socket, { success: false, message: '部署异常: ' + e.message });
    }
  }

  if (url === '/api/admin/status') {
    var uptime = process.uptime();
    var mem = process.memoryUsage();
    return jsonRawResponse(socket, { success: true, uptime: Math.floor(uptime), memoryMB: Math.floor(mem.heapUsed/1024/1024), version: getClientVersion() });
  }

  // Flash安全策略文件
  if (url === '/crossdomain.xml') {
    try {
      var fs = require('fs');
      var cdmPath = '/opt/crossdomain.xml';
      if (fs.existsSync(cdmPath)) {
        var cdmData = fs.readFileSync(cdmPath, 'utf-8');
        sendRawHttpResponse(socket, 200, 'OK', {
          'Content-Type': 'application/xml; charset=utf-8',
          'Content-Length': String(cdmData.length),
          'Connection': 'close'
        }, cdmData);
        return;
      }
    } catch(e) {}
  }

  // 客户端文件下载 (SWF + XML数据)
  if (url.startsWith('/client/')) {
    var clientFile = url.substring(8).split('?')[0]; // remove /client/, strip query
    if (clientFile.indexOf('..') >= 0) {
      sendRawHttpResponse(socket, 403, 'Forbidden', {}, 'Forbidden');
      return;
    }
    var clientPath = '/opt/client/' + clientFile;
    try {
      var fs = require('fs');
      if (fs.existsSync(clientPath)) {
        var clientData = fs.readFileSync(clientPath);
        var ext = clientFile.split('.').pop().toLowerCase();
        var mimeMap = { zip: 'application/zip', swf: 'application/x-shockwave-flash', exe: 'application/octet-stream', txt: 'text/plain', pdf: 'application/pdf', xml: 'application/xml; charset=utf-8', html: 'text/html; charset=utf-8', htm: 'text/html; charset=utf-8' };
        var mime = mimeMap[ext] || 'application/octet-stream';
        // 禁止缓存，每次从服务器拉最新
        var headStr = 'HTTP/1.0 200 OK\r\nContent-Type: ' + mime + '\r\nContent-Length: ' + clientData.length + '\r\nCache-Control: no-cache, no-store, must-revalidate\r\nPragma: no-cache\r\nExpires: 0\r\nConnection: close\r\n\r\n';
        var headBuf = Buffer.from(headStr, 'utf-8');
        var fullBuf = Buffer.concat([headBuf, clientData]);
        socket.write(fullBuf, function() { try { socket.end(); } catch(e) {} });
        return;
      }
    } catch(e) {}
    sendRawHttpResponse(socket, 404, 'Not Found', {}, 'Not Found');
    return;
  }

  // ===== 网页版 API =====

  // 存档加载
  if (url === '/api/load' && data.token) {
    const p = findPlayerByToken(data.token);
    if (p) {
      p.lastSeen = Date.now();
      try {
        const savePath = '/opt/data/save_' + p.id + '.json';
        const fs = require('fs');
        if (fs.existsSync(savePath)) {
          const saveData = fs.readFileSync(savePath, 'utf-8');
          return jsonRawResponse(socket, { success: true, data: saveData });
        }
      } catch(e) {}
      return jsonRawResponse(socket, { success: true, data: null }); // 新玩家无存档
    }
    return jsonRawResponse(socket, { success: false, message: 'Token invalid' });
  }

  // 存档保存
  if (url === '/api/save' && data.token && data.saveData) {
    const p = findPlayerByToken(data.token);
    if (p) {
      p.lastSeen = Date.now();
      try {
        const fs = require('fs');
        const dir = '/opt/data';
        if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
        fs.writeFileSync(dir + '/save_' + p.id + '.json', data.saveData, 'utf-8');
        save();
        return jsonRawResponse(socket, { success: true, message: 'Saved' });
      } catch(e) {
        return jsonRawResponse(socket, { success: false, message: e.message });
      }
    }
    return jsonRawResponse(socket, { success: false, message: 'Token invalid' });
  }

  // 消息轮询：发送消息（含业务处理 - 认证/加房/聊天/对战）
  if (url === '/api/poll/send' && data.token) {
    const p = findPlayerByToken(data.token);
    if (!p) {
      console.log('[Poll] send FAIL: invalid token ' + String(data.token).substring(0,10));
      return jsonRawResponse(socket, { success: false, message: 'Token invalid' });
    }
    p.lastSeen = Date.now();
    const msg = typeof data.msg === 'string' ? JSON.parse(data.msg) : data.msg;
    console.log('[Poll] ' + p.role_name + ' send type=' + (msg ? msg.type : 'null') + ' peerId=' + (p._pollPeerId||'(new)'));
    if (msg) {
      processPollMessage(p, msg);
    }
    return jsonRawResponse(socket, { success: true });
  }

  // 消息轮询：接收消息
  if (url === '/api/poll/recv' && data.token) {
    const p = findPlayerByToken(data.token);
    if (!p) {
      console.log('[Poll] recv FAIL: invalid token ' + String(data.token).substring(0,10));
      return jsonRawResponse(socket, { success: false, message: 'Token invalid' });
    }
    p.lastSeen = Date.now();
    if (!p._pollQueue) p._pollQueue = [];
    const since = data.since || 0;
    const newMsgs = p._pollQueue.filter(m => m.time > since);
    // 同时检查TCP relay消息
    if (p._tcpRelayQueue) {
      for (const rm of p._tcpRelayQueue) {
        newMsgs.push(rm);
      }
      p._tcpRelayQueue = [];
    }
    return jsonRawResponse(socket, { success: true, messages: newMsgs, serverTime: Date.now() });
  }

  // Other API endpoints — 返回当前玩家资源（防止覆盖归零）
  if (url.startsWith('/api/')) {
    const p = findPlayerByRequest(data);
    const res = p ? getResourceData(p) : { money: 0, dianka: 0, exploit: 0, reverence: 0, rongyu: 0 };
    console.log('[Stub] ' + url + ' head=' + data.head + ' player=' + (p?p.role_name:'?') + ' money=' + res.money);
    return jsonRawResponse(socket, { success: true, stamp: data.stamp||'', head: String(data.head||''), data: res });
  }

  // 404
  sendRawHttpResponse(socket, 404, 'Not Found', {
    'Content-Type': 'text/plain',
    'Content-Length': '9',
    'Connection': 'close',
  }, 'Not Found');
}

const httpServer = net.createServer((socket) => {
  socket.setNoDelay(true);
  let buffer = Buffer.alloc(0);

  socket.on('data', (data) => {
    buffer = Buffer.concat([buffer, data]);

    const headerEnd = buffer.indexOf('\r\n\r\n');
    if (headerEnd === -1) return;

    const headerStr = buffer.slice(0, headerEnd).toString('utf-8');
    const contentLengthMatch = headerStr.match(/Content-Length:\s*(\d+)/i);

    if (contentLengthMatch) {
      const contentLen = parseInt(contentLengthMatch[1]);
      const totalLen = headerEnd + 4 + contentLen;
      if (buffer.length < totalLen) return;

      const reqData = buffer.slice(0, totalLen);
      buffer = buffer.slice(totalLen);
      try {
        handleRequest(socket, parseHttpRequest(reqData));
      } catch(e) {
        console.error('[HTTP] Error:', e.message);
        try { socket.end(); } catch(e2) {}
      }
    } else {
      const reqData = buffer.slice(0, headerEnd + 4);
      buffer = buffer.slice(headerEnd + 4);
      try {
        handleRequest(socket, parseHttpRequest(reqData));
      } catch(e) {
        console.error('[HTTP] Error:', e.message);
        try { socket.end(); } catch(e2) {}
      }
    }
  });

  socket.on('error', (err) => { /* ignore */ });
});

httpServer.listen(HTTP_PORT, '0.0.0.0', () => {
  console.log('Raw TCP HTTP server on ' + HTTP_PORT);
});

// ============ TCP 大厅服务器 (port 3001) ============
const tcpSessions = new Map();
const tcpRooms = new Map();

// TCP→Web轮询消息中继：当TCP对手不在线时，消息投递到玩家的poll队列
function relayToWebPlayer(tcpPeerId, msg) {
  if (!tcpPeerId) return;
  // 通过peerId找到TCP session → 找到playerId → 投递poll消息
  const ses = tcpSessions.get(tcpPeerId);
  if (ses) return; // 对手在TCP在线，不需要relay
  // 尝试通过peerId匹配到玩家（peerId存储在擂台中）
  for (const room of db.leitaiRooms) {
    if (room.mInfo && room.mInfo.pID === tcpPeerId && room.mInfo.id) {
      const p = db.players.find(pl => pl.id === room.mInfo.id);
      if (p) {
        if (!p._tcpRelayQueue) p._tcpRelayQueue = [];
        p._tcpRelayQueue.push({ time: Date.now(), msg: msg });
        return;
      }
    }
  }
}

// ===== 网页版消息处理（复用TCP业务逻辑） =====
function processPollMessage(player, msg) {
  if (!player._pollQueue) player._pollQueue = [];
  if (!player._pollPeerId) {
    // 首次认证：分配peerId
    if (msg.type === 'auth') {
      player._pollPeerId = 'w' + Date.now().toString(36) + Math.random().toString(36).substr(2, 6);
      player._pollSession = {
        peerId: player._pollPeerId,
        playerId: player.id,
        roleName: player.role_name,
        rooms: []
      };
      // 加入全局web会话列表
      if (!globalWebSessions) globalWebSessions = {};
      globalWebSessions[player._pollPeerId] = player._pollSession;
      // 返回认证成功+在线邻居列表
      player._pollQueue.push({ time: Date.now(), msg: {
        type: 'auth_success', peerId: player._pollPeerId, message: 'OK'
      }});
      // 返回邻居列表
      var neighbors = [];
      for (var pid in globalWebSessions) {
        if (pid !== player._pollPeerId) {
          var s = globalWebSessions[pid];
          neighbors.push({ pID: s.peerId, roleName: s.roleName, level: 1, imageID: 1, status: 0 });
        }
      }
      player._pollQueue.push({ time: Date.now(), msg: { type: 'neighbor_list', neighbors: neighbors } });
      console.log('[Web] Auth OK: ' + player.role_name + ' (' + player._pollPeerId + ') queue=' + player._pollQueue.length);
    }
    return;
  }

  var session = player._pollSession;
  if (!session) return;

  // 房间操作
  if (msg.type === 'join_room') {
    var roomName = msg.room;
    if (!session.rooms) session.rooms = [];
    if (session.rooms.indexOf(roomName) < 0) session.rooms.push(roomName);
    if (!globalWebRooms) globalWebRooms = {};
    if (!globalWebRooms[roomName]) globalWebRooms[roomName] = [];
    if (globalWebRooms[roomName].indexOf(player._pollPeerId) < 0) {
      globalWebRooms[roomName].push(player._pollPeerId);
    }
    // 通知其他邻居，并返回当前邻居
    var roomNeighbors = [];
    for (var pid2 of globalWebRooms[roomName]) {
      if (pid2 !== player._pollPeerId) {
        var otherPlayer = findPlayerByPollPeerId(pid2);
        if (otherPlayer && otherPlayer._pollQueue) {
          otherPlayer._pollQueue.push({ time: Date.now(), msg: {
            type: 'neighbor_join', peer: { pID: session.peerId, roleName: session.roleName, level: 1, imageID: 1, status: 0 }
          }});
        }
        roomNeighbors.push({ pID: pid2, roleName: 'Player', level: 1, imageID: 1, status: 0 });
      }
    }
    player._pollQueue.push({ time: Date.now(), msg: { type: 'room_joined', room: roomName, neighbors: roomNeighbors } });
  }

  // 聊天
  else if (msg.type === 'chat') {
    if (!globalWebRooms || !globalWebRooms[msg.room]) return;
    for (var pid3 of globalWebRooms[msg.room]) {
      if (pid3 !== player._pollPeerId) {
        var chatTarget = findPlayerByPollPeerId(pid3);
        if (chatTarget && chatTarget._pollQueue) {
          chatTarget._pollQueue.push({ time: Date.now(), msg: {
            type: 'chat', room: msg.room, from: session.peerId, fromName: session.roleName,
            text: msg.text || msg.data, plain: msg.plain || null
          }});
        }
      }
    }
  }

  // 对战请求
  else if (msg.type === 'battle_request') {
    var targetPeer = msg.targetPeerId;
    var targetPlayer = findPlayerByPollPeerId(targetPeer);
    if (targetPlayer && targetPlayer._pollQueue) {
      targetPlayer._pollQueue.push({ time: Date.now(), msg: {
        type: 'battle_request', from: session.peerId, fromName: session.roleName, server: msg.server
      }});
    }
  }

  // 对战接受
  else if (msg.type === 'battle_accept') {
    var fromPeer = msg.fromPeerId;
    var fromPlayer = findPlayerByPollPeerId(fromPeer);
    if (fromPlayer && fromPlayer._pollQueue) {
      fromPlayer._pollQueue.push({ time: Date.now(), msg: {
        type: 'battle_start', direct: 1, opponentPID: session.peerId,
        leftInfo: { name: fromPlayer.role_name, level: fromPlayer.level || 1, image: fromPlayer.image_id || 1 },
        rightInfo: { name: session.roleName, level: player.level || 1, image: player.image_id || 1 }
      }});
      player._pollQueue.push({ time: Date.now(), msg: {
        type: 'battle_start', direct: -1, opponentPID: fromPlayer._pollPeerId,
        leftInfo: { name: fromPlayer.role_name, level: fromPlayer.level || 1, image: fromPlayer.image_id || 1 },
        rightInfo: { name: session.roleName, level: player.level || 1, image: player.image_id || 1 }
      }});
    }
  }

  // 对战动作 & P2P消息 → 转发给对手
  else if (msg.type === 'battle_action' || msg.type === 'p2p_message') {
    var oppPeer = msg.to || session.farPeerId;
    if (oppPeer) {
      var oppPlayer = findPlayerByPollPeerId(oppPeer);
      if (oppPlayer && oppPlayer._pollQueue) {
        oppPlayer._pollQueue.push({ time: Date.now(), msg: {
          type: msg.type, from: session.peerId, data: msg.data || msg
        }});
      }
    }
  }

  // 存储 farPeerId (对战对手)
  if (msg.to && !session.farPeerId) {
    session.farPeerId = msg.to;
  }
}

function findPlayerByPollPeerId(peerId) {
  for (var i = 0; i < db.players.length; i++) {
    if (db.players[i]._pollPeerId === peerId) return db.players[i];
  }
  return null;
}

// 全局Web会话存储
var globalWebSessions = {};
var globalWebRooms = {};

function tcpSend(session, msg) {
  try {
    const json = JSON.stringify(msg);
    const payload = Buffer.from(json, 'utf-8');
    const header = Buffer.alloc(4);
    header.writeInt32BE(payload.length, 0);
    session.socket.write(Buffer.concat([header, payload]));
  } catch(e) {}
}

function tcpHandleMessage(session, msg) {
  switch (msg.type) {
    case 'auth': {
      session.peerId = 'p' + Date.now().toString(36) + Math.random().toString(36).substr(2,6);
      session.playerId = msg.roleID || 0;
      session.roleName = msg.roleName || 'Player';
      tcpSessions.set(session.peerId, session);
      tcpSend(session, { type: 'auth_success', peerId: session.peerId, message: 'OK' });
      // 更新该玩家所有擂台的 pID（防止重连后 pID 过期导致攻擂失败）
      for (const room of db.leitaiRooms) {
        if (room.mInfo && room.mInfo.id === session.playerId) {
          room.mInfo.pID = session.peerId;
        }
      }
      save();
      console.log('[TCP] Auth: ' + session.roleName + ' (' + session.peerId + ')');
      break;
    }
    case 'join_room': {
      const room = msg.room;
      console.log('[TCP] ' + session.roleName + ' join_room: ' + room);
      if (!tcpRooms.has(room)) tcpRooms.set(room, new Set());
      const peers = tcpRooms.get(room);
      for (const pid of peers) {
        const other = tcpSessions.get(pid);
        if (other) tcpSend(other, { type: 'neighbor_join', peer: { pID: session.peerId, roleID: String(session.playerId), roleName: session.roleName, level: 1, imageID: 1, agent: '4399', status: 0 } });
      }
      peers.add(session.peerId);
      session.rooms.add(room);
      const neighbors = [];
      for (const pid of peers) {
        if (pid !== session.peerId) {
          const other = tcpSessions.get(pid);
          if (other) neighbors.push({ pID: other.peerId, roleID: String(other.playerId), roleName: other.roleName, level: 1, imageID: 1, agent: '4399', status: 0 });
        }
      }
      tcpSend(session, { type: 'room_joined', room, neighbors });
      break;
    }
    case 'chat': {
      const room = tcpRooms.get(msg.room);
      const plainPreview = msg.plain ? msg.plain.replace(/<[^>]*>/g,'').substring(0,50) : (msg.text||'').substring(0,30);
      console.log('[TCP] ' + session.roleName + ' chat: "' + plainPreview + '" in ' + msg.room);
      if (room) {
        for (const pid of room) {
          if (pid !== session.peerId) {
            const other = tcpSessions.get(pid);
            if (other) tcpSend(other, { type: 'chat', room: msg.room, from: session.peerId, fromName: session.roleName, text: msg.text || msg.data, plain: msg.plain || null });
          }
        }
      }
      break;
    }
    case 'battle_request': {
      const target = tcpSessions.get(msg.targetPeerId);
      console.log('[TCP] battle_request from ' + session.roleName + ' to ' + msg.targetPeerId + ' (found=' + !!target + ')');
      if (!target) { tcpSend(session, { type: 'battle_request_fail', reason: '对手不在线，请刷新擂台列表' }); break; }
      if (target.farPeerId) { tcpSend(session, { type: 'battle_request_fail', reason: '对手战斗中' }); break; }
      session.farPeerId = msg.targetPeerId;
      tcpSend(target, { type: 'battle_request', from: session.peerId, fromName: session.roleName, server: msg.server });
      break;
    }
    case 'battle_accept': {
      const opp = tcpSessions.get(msg.fromPeerId);
      console.log('[TCP] battle_accept from ' + session.roleName + ' to ' + msg.fromPeerId + ' (found=' + !!opp + ')');
      if (!opp) { tcpSend(session, { type: 'error', message: '对手离线' }); break; }
      session.farPeerId = msg.fromPeerId;
      opp.farPeerId = session.peerId;
      // 守方在左(direct=1)，攻方在右(direct=-1) — 与 addFightWait 调用中的 _direct 对应
      // session = 守方(发accept者), opp = 攻方
      // 守方: direct=1, left=守方自己, right=攻方 (addFightWait: leizhu==true → left=me,right=opp,direct=1)
      // 攻方: direct=-1, left=守方, right=攻方自己 (addFightWait: leizhu==false → left=opp,right=me,direct=-1)
      var defInfo = getPlayerInfo(session.playerId);
      var atkInfo = getPlayerInfo(opp.playerId);
      tcpSend(session, { type: 'battle_start', direct: 1, opponentPID: opp.peerId, leftInfo: { name: session.roleName, level: defInfo.level, image: defInfo.image }, rightInfo: { name: opp.roleName, level: atkInfo.level, image: atkInfo.image } });
      tcpSend(opp, { type: 'battle_start', direct: -1, opponentPID: session.peerId, server: true, leftInfo: { name: session.roleName, level: defInfo.level, image: defInfo.image }, rightInfo: { name: opp.roleName, level: atkInfo.level, image: atkInfo.image } });
      break;
    }
    case 'battle_action': {
      const opp = session.farPeerId ? tcpSessions.get(session.farPeerId) : null;
      if (opp) tcpSend(opp, { type: 'battle_action', from: session.peerId, data: msg.data });
      else relayToWebPlayer(session.farPeerId, { type: 'battle_action', from: session.peerId, data: msg.data });
      break;
    }
    case 'battle_start':
      console.log('[TCP] battle_start relay: ' + session.roleName);
      break;
    case 'p2p_message':
      // P2P 战斗同步消息 — 转发给对手
      if (session.farPeerId) {
        const opp = tcpSessions.get(session.farPeerId);
        if (opp) tcpSend(opp, { type: 'p2p_message', data: msg.data, from: session.peerId });
        else relayToWebPlayer(session.farPeerId, { type: 'p2p_message', data: msg.data, from: session.peerId });
      }
      break;
    case 'battle_end':
      console.log('[TCP] battle_end: ' + session.roleName);
      if (session.farPeerId) {
        const o = tcpSessions.get(session.farPeerId);
        if (o) { o.farPeerId = null; tcpSend(o, { type: 'battle_end' }); }
        session.farPeerId = null;
      }
      // 清理此玩家所有擂台的战斗状态
      for (const room of db.leitaiRooms) {
        if (room.mInfo && room.mInfo.id === session.playerId) {
          room._battleCoolDown = Date.now() + 3000; // 3秒冷却
        }
      }
      break;
    default:
      tcpSend(session, { type: 'error', message: 'Unknown: ' + msg.type });
  }
}

const tcpServer = net.createServer((socket) => {
  const session = { socket, peerId: '', playerId: 0, roleName: '', rooms: new Set(), farPeerId: null, buffer: Buffer.alloc(0), expectedLen: -1 };
  socket.on('data', (data) => {
    session.buffer = Buffer.concat([session.buffer, data]);
    while (true) {
      if (session.expectedLen < 0) { if (session.buffer.length < 4) break; session.expectedLen = session.buffer.readInt32BE(0); session.buffer = session.buffer.slice(4); }
      if (session.buffer.length < session.expectedLen) break;
      const payload = session.buffer.slice(0, session.expectedLen).toString('utf-8');
      session.buffer = session.buffer.slice(session.expectedLen);
      session.expectedLen = -1;
      try {
        const msg = JSON.parse(payload);
        if (msg.type !== 'chat') console.log('[TCP-IN] ' + session.roleName + ' type=' + msg.type + ' ' + JSON.stringify(msg).substring(0,150));
        tcpHandleMessage(session, msg);
      } catch(e) { console.log('[TCP] parse error:', e.message); }
    }
  });
  socket.on('close', () => {
    if (session.peerId) {
      for (const room of session.rooms) { const r = tcpRooms.get(room); if (r) { r.delete(session.peerId); if (r.size === 0) tcpRooms.delete(room); } }
      if (session.farPeerId) { const o = tcpSessions.get(session.farPeerId); if (o) { o.farPeerId = null; tcpSend(o, { type: 'battle_opponent_disconnected', peerId: session.peerId }); } }
      tcpSessions.delete(session.peerId);
    }
  });
  socket.on('error', () => {});
});
tcpServer.listen(TCP_PORT, '0.0.0.0', () => console.log('TCP server on ' + TCP_PORT));

// ============ 心跳：定期更新在线玩家 lastSeen ============
// 修复：已关闭游戏的玩家仍显示在在线人数中的bug
// 每60秒遍历所有活跃TCP连接，更新对应玩家的lastSeen时间戳
setInterval(() => {
  const now = Date.now();
  for (const [peerId, session] of tcpSessions) {
    if (session.playerId) {
      const p = db.players.find(pl => pl.id === session.playerId);
      if (p) {
        p.lastSeen = now;
      }
    }
  }
  // 每5分钟保存一次（避免过于频繁的磁盘IO）
  if (now % (5 * 60 * 1000) < 60000) {
    save();
  }
}, 60000); // 60秒心跳

console.log('Ready: HTTP ' + HTTP_PORT + ' + TCP ' + TCP_PORT + ' (raw TCP)');
