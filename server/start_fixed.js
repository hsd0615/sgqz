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
function dedupeGenerals(pid) {
  // 按code去重, 保留最高level的, 同时合并装备数据
  var map = {}; var removed = 0;
  var toKeep = [];
  for (var gi = 0; gi < db.generals.length; gi++) {
    var g = db.generals[gi];
    if (g.player_id !== pid) { toKeep.push(g); continue; }
    var key = g.code;
    if (map[key]) {
      var prev = map[key];
      // 合并装备: 非'0'的equip保留
      if ((g.equip1||'0') !== '0' && (prev.equip1||'0') === '0') prev.equip1 = g.equip1;
      if ((g.equip2||'0') !== '0' && (prev.equip2||'0') === '0') prev.equip2 = g.equip2;
      if ((g.equip3||'0') !== '0' && (prev.equip3||'0') === '0') prev.equip3 = g.equip3;
      if ((g.equip4||'0') !== '0' && (prev.equip4||'0') === '0') prev.equip4 = g.equip4;
      if ((g.equip5||'0') !== '0' && (prev.equip5||'0') === '0') prev.equip5 = g.equip5;
      if ((g.equip6||'0') !== '0' && (prev.equip6||'0') === '0') prev.equip6 = g.equip6;
      // 保留更高level的
      if (g.level > prev.level || ((g.level === prev.level) && ((g.evolution||0) > (prev.evolution||0)))) {
        toKeep = toKeep.filter(function(x) { return x !== prev; });
        map[key] = g; toKeep.push(g);
      }
      removed++;
    } else {
      map[key] = g; toKeep.push(g);
    }
  }
  db.generals = toKeep;
  if (removed > 0) { console.log('[Dedupe] Removed ' + removed + ' duplicate generals for player ' + pid + ', kept ' + Object.keys(map).length); save(); }
}
function createGeneral(pid, code, name, level, evo, feat, tf, k1, k1l, k2, k2l, k3, k3l, eq1, eq2, eq3, eq4, eq5, eq6) {
  const g = { id: db.nextId.generals++, player_id: pid, general_id: Math.floor(Math.random()*100000), code, name, level:level||1, evolution:evo||0, feature:feat||0, tianfu:tf||null, kezhi1:k1||0, kezhi1_level:k1l||1, kezhi2:k2||0, kezhi2_level:k2l||1, kezhi3:k3||0, kezhi3_level:k3l||1, is_deployed: 0, equip1: eq1||'0', equip2: eq2||'0', equip3: eq3||'0', equip4: eq4||'0', equip5: eq5||'0', equip6: eq6||'0' };
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
var generalNameToCode = {}; // name → code 映射 (用于通关奖励在野武将)
function loadKezhiMap() {
  if (!fs.existsSync('/opt/staticgeneral.xml')) return;
  var xml = fs.readFileSync('/opt/staticgeneral.xml','utf8');
  var blocks = xml.split('<RECORD>');
  for (var i = 0; i < blocks.length; i++) {
    var cm = blocks[i].match(/<code>([^<]+)<\/code>/);
    var km = blocks[i].match(/<kezhi>([^<]+)<\/kezhi>/);
    var nm = blocks[i].match(/<name>([^<]+)<\/name>/);
    if (cm && km && km[1].length > 0) KEZHI_MAP[cm[1]] = km[1];
    // 同时加载招募概率
    if (cm) {
      var mm = blocks[i].match(/<money>(\d+)<\/money>/);
      var dm = blocks[i].match(/<dianka>(\d+)<\/dianka>/);
      if (mm && dm) generalRecruitMap[cm[1]] = { money: parseInt(mm[1]), dianka: parseInt(dm[1]) };
    }
    // name → code 映射
    if (cm && nm) generalNameToCode[nm[1]] = cm[1];
  }
  KEZHI_MAP['general_0_1'] = '3:1|8:1|9:1';
  console.log('[KezhiMap] Loaded ' + Object.keys(KEZHI_MAP).length + ' entries, recruit: ' + Object.keys(generalRecruitMap).length + ', names: ' + Object.keys(generalNameToCode).length);
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

// 游戏数据缓存(供/api/game-data, 避免每次请求读取磁盘)
var GAME_DATA_CACHE = null;
function buildGameDataCache() {
  var shop = [], proto = [], equip = [];
  try {
    // 商城数据
    if (fs.existsSync('/opt/shop.xml')) {
      var sx = fs.readFileSync('/opt/shop.xml','utf8');
      var sblocks = sx.split('<RECORD>');
      for (var si = 1; si < sblocks.length; si++) {
        var sid = (sblocks[si].match(/<id>([^<]+)<\/id>/)||[])[1];
        if(!sid) continue;
        shop.push({
          id:sid, name:((sblocks[si].match(/<name>([^<]+)<\/name>/)||[])[1]||''),
          category:parseInt(((sblocks[si].match(/<category>(\d+)<\/category>/)||[])[1]||'1')),
          code:((sblocks[si].match(/<code>([^<]+)<\/code>/)||[])[1]||''),
          count:parseInt(((sblocks[si].match(/<count>(\d+)<\/count>/)||[])[1]||'1')),
          payType:parseInt(((sblocks[si].match(/<payType>(\d+)<\/payType>/)||[])[1]||'1')),
          oldPrice:parseInt(((sblocks[si].match(/<oldPrice>(\d+)<\/oldPrice>/)||[])[1]||'0')),
          newPrice:parseInt(((sblocks[si].match(/<newPrice>(\d+)<\/newPrice>/)||[])[1]||'0'))
        });
      }
    }
    // 道具数据
    if (fs.existsSync('/opt/staticproto.xml')) {
      var px = fs.readFileSync('/opt/staticproto.xml','utf8');
      var pblocks = px.split('<RECORD>');
      for (var pi = 1; pi < pblocks.length; pi++) {
        var pcd = (pblocks[pi].match(/<code>([^<]+)<\/code>/)||[])[1];
        if(!pcd) continue;
        proto.push({
          code:pcd, type:parseInt(((pblocks[pi].match(/<type>(\d+)<\/type>/)||[])[1]||'1')),
          name:((pblocks[pi].match(/<name>([^<]+)<\/name>/)||[])[1]||''),
          desc:((pblocks[pi].match(/<desc>([^<]*)<\/desc>/)||[])[1]||'')
        });
      }
    }
    // 装备数据
    for (var ek in EQUIP_DATA) { equip.push(Object.assign({code:ek}, EQUIP_DATA[ek])); }
    GAME_DATA_CACHE = { shopItems:shop, protoItems:proto, equipItems:equip };
    console.log('[GameDataCache] shop:'+shop.length+' proto:'+proto.length+' equip:'+equip.length);
  } catch(e) {
    console.log('[GameDataCache] Error: ' + e.message);
    GAME_DATA_CACHE = { shopItems:[], protoItems:[], equipItems:[] };
  }
}

// 关卡敌将数据: stageKey → [{code,level,evolution,name}]
var STAGE_ENEMY_GENS = {};
// 武将品质映射: code → quality (0=超级 1=一流 2=二流 3=三流) 来自staticgeneral.xml的title字段
var GENERAL_QUALITY = {};
function buildGeneralQualityMap() {
  if (fs.existsSync('/opt/staticgeneral.xml')) {
    var gxml = fs.readFileSync('/opt/staticgeneral.xml','utf8');
    var grecs = gxml.split('<RECORD>');
    for (var ri=1; ri<grecs.length; ri++) {
      var cm = grecs[ri].match(/<code>([^<]+)<\/code>/);
      var tm = grecs[ri].match(/<title>(\d+)<\/title>/);
      if (cm && tm) GENERAL_QUALITY[cm[1]] = parseInt(tm[1]);
    }
  }
  console.log('[QualityMap] Built from title field: ' + Object.keys(GENERAL_QUALITY).length + ' codes (0=超级 1=一流 2=二流 3=三流)');
}
function parseGeneralQuality(code) {
  return GENERAL_QUALITY[code] != null ? GENERAL_QUALITY[code] : 3;
}
// 投石车(type=0)不掉装备
function canDropEquip(code) {
  var m = (code||'').match(/^general_0_/);
  return !m; // 投石车排除
}
// 根据敌将品质和关卡难度分配默认装备
function getDefaultEquipForEnemy(enemyCode, genQuality, genLevel, fubenID, stageIdx) {
  // 返回6槽装备数组 [weapon, armor, acc1, helmet, boots, acc2]
  var equips = ['0', '0', '0', '0', '0', '0'];
  if (!canDropEquip(enemyCode)) return equips; // 投石车(type=0)不装备
  if (genLevel < 5) return equips; // 太低等级不给装备
  // 敌人装备品质低于掉落品质: maxQ=9, 仅关卡掉落Q10时敌人可有Q10
  var lvBonus = Math.floor(genLevel / 20);
  var qBias = genQuality == 0 ? 2 : (genQuality == 1 ? 1 : 0);
  var maxQ = Math.min(9, 1 + lvBonus + qBias);
  var minQ = Math.max(1, maxQ - 3);
  // 为每个装备槽随机选择装备
  for (var s = 0; s < 6; s++) {
    if (Math.random() < Math.min(0.75, 0.20 + genLevel * 0.005)) { // 等级越高越容易有装备
      var slotCandidates = [];
      for (var ek in EQUIP_DATA) {
        var eq = EQUIP_DATA[ek];
        if (eq.quality >= minQ && eq.quality <= maxQ && eq.slot === s + 1) {
          slotCandidates.push(ek);
        }
      }
      if (slotCandidates.length > 0) {
        equips[s] = slotCandidates[Math.floor(Math.random() * slotCandidates.length)];
      }
    }
  }
  return equips;
}
function loadStageEnemyData() {
  if (!fs.existsSync('/opt/stage.xml')) return;
  var xml = fs.readFileSync('/opt/stage.xml','utf8');
  var gates = xml.split('<gate');
  for (var i=1; i<gates.length; i++) {
    var pm = gates[i].match(/part="(\d+)"/);
    var lm = gates[i].match(/level="(\d+)"/);
    if (!pm||!lm) continue;
    var key = pm[1]+'_'+lm[1];
    var gens = gates[i].match(/<general[^>]*\/>/g)||[];
    STAGE_ENEMY_GENS[key] = [];
    for (var j=0; j<gens.length; j++) {
      var lvm = gens[j].match(/level="(\d+)"/);
      var evm = gens[j].match(/evolution="(\d+)"/);
      var nm = gens[j].match(/name="([^"]+)"/);
      var cm = gens[j].match(/code="([^"]+)"/);
      STAGE_ENEMY_GENS[key].push({
        code: cm?cm[1]:'',
        level: parseInt(lvm?lvm[1]:'1'),
        evolution: parseInt(evm?evm[1]:'0'),
        name: nm?nm[1]:'敌将'
      });
    }
  }
  console.log('[StageEnemy] Loaded ' + Object.keys(STAGE_ENEMY_GENS).length + ' stages');
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
    if (g.equip4 === undefined) { g.equip4 = '0'; changed = true; }
    if (g.equip5 === undefined) { g.equip5 = '0'; changed = true; }
    if (g.equip6 === undefined) { g.equip6 = '0'; changed = true; }
    if (changed) fixed++;
  }
  if (fixed > 0) { console.log('[Migrate] Added equipment slots to ' + fixed + ' generals'); }
}

function ensureAllEquip(pid) {
  // 发放全部装备各一件
  var allCodes = [];
  for (var ek in EQUIP_DATA) { allCodes.push(ek); }

  var existing = db.bagItems.filter(function(b){return b.player_id===pid;}).map(function(b){return b.code;});
  var added = 0;
  allCodes.forEach(function(code){
    if (existing.indexOf(code) < 0) {
      db.bagItems.push({ id: db.nextId.bagItems++, player_id: pid, code: code, count: 1 });
      added++;
    }
  });
  if (added > 0) console.log('[Equip] Gave ' + added + ' Q8+ equip to gm_admin');
}

function ensureAmmoItems(pid) {
  // 8种战车弹药(proto_2_1~8) + 进化卷(proto_1_1~9) 每样99个
  var ammoCodes = [];
  for (var i=1; i<=8; i++) ammoCodes.push('proto_2_'+i);
  for (var i2=1; i2<=9; i2++) ammoCodes.push('proto_1_'+i2);
  // 其他消耗品 proto_3_1~4
  for (var i3=1; i3<=4; i3++) ammoCodes.push('proto_3_'+i3);

  var existing = db.bagItems.filter(function(b){return b.player_id===pid;});
  var existingCodes = existing.map(function(b){return b.code;});
  var added = 0;
  ammoCodes.forEach(function(code){
    if (existingCodes.indexOf(code) < 0) {
      db.bagItems.push({ id: db.nextId.bagItems++, player_id: pid, code: code, count: 99 });
      added++;
    }
  });
  if (added > 0) console.log('[Ammo] Gave ' + added + ' ammo/consumable items (x99) to player ' + pid);
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
  ['general_1_15','黄忠','5:1|7:1|9:1'],['general_2_11','貂蝉','5:1|4:1|7:1'],
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
  // 给GM测试号发放全部76件装备
  ensureAllEquip(p1.id);
  // 发放弹药和消耗品(每样99个)
  ensureAmmoItems(p1.id);

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
  // 清理所有玩家的重复武将
  var allPids = {}; db.generals.forEach(function(g){ allPids[g.player_id]=true; });
  for (var _pid in allPids) dedupeGenerals(parseInt(_pid));
  console.log('[DB] Test accounts ready (gm_admin:' + findGenerals(p1.id).length + 'g, test_pro:' + findGenerals(p2.id).length + 'g, new_player:' + findGenerals(p3.id).length + 'g)');
}

if (!fs.existsSync(path.dirname(DATA_FILE))) fs.mkdirSync(path.dirname(DATA_FILE), { recursive: true });
loadKezhiMap();     // 1. 加载XML克制类型映射
buildGeneralQualityMap(); // 1a. 构建武将品质映射(超级/一流/二流...)
loadStageMap();     // 1b. 加载关卡ID映射
loadStageEnemyData(); // 1b2. 加载敌将数据
loadAwardMap();     // 1c. 加载关卡奖励数据
loadShopData();     // 1d. 加载商城数据
loadProtoData();    // 1e. 加载道具数据
loadEquipData();    // 1f. 加载装备数据
buildGameDataCache(); // 1g. 构建游戏数据缓存(供/api/game-data)
initLeitai();       // 2. 初始化擂台
createTestAccounts();// 3. 创建测试账号
migrateKezhi();     // 4. 修复DB中不完整的克制数据
migrateEquipment();
	migrateBagItems();  // 统一背包旧格式
	//cleanLowQualityEquip(); // 4b. 补充装备字段
save();             // 5. 保存


	// 统一背包道具格式: 旧格式(item_code/item_count) -> 新格式(code/count)
	function migrateBagItems() {
	  if (!db.bagItems) return;
	  var migrated = 0;
	  for (var bi = 0; bi < db.bagItems.length; bi++) {
	    var item = db.bagItems[bi];
	    if (item.item_code && !item.code) { item.code = item.item_code; delete item.item_code; migrated++; }
	    if (item.item_count !== undefined && item.count === undefined) { item.count = item.item_count; delete item.item_count; migrated++; }
	  }
	  if (migrated > 0) console.log('[Migrate] Fixed ' + migrated + ' bag item format issues');
	}

// 启动时清理全服Q7以下装备
function cleanLowQualityEquip() {
  var lowQ = {};
  for (var ek in EQUIP_DATA) { if (EQUIP_DATA[ek].quality < 8) lowQ[ek] = true; }
  var br = 0, er = 0;
  db.bagItems = db.bagItems.filter(function(b) {
    if (!b.code || !b.code.startsWith('proto_4_')) return true;
    if (lowQ[b.code]) { br++; return false; }
    return true;
  });
  db.generals.forEach(function(g) {
    for (var s = 1; s <= 6; s++) {
      var eq = g['equip' + s];
      if (eq && eq !== '0' && lowQ[eq]) { g['equip' + s] = '0'; er++; }
    }
  });
  if (br > 0 || er > 0) console.log('[Cleanup] 移除低品质装备: 背包' + br + '件, 卸下' + er + '件');
}

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
    kezhi: getKezhiStr(g),
    equipment: (g.equip1||'0') + ',' + (g.equip2||'0') + ',' + (g.equip3||'0') + ',' + (g.equip4||'0') + ',' + (g.equip5||'0') + ',' + (g.equip6||'0'),
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
  _cachedClientVersion = '4.0.8';
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

var BROADCASTS = [];
function broadcastToAll(msg) {
  var now = Date.now();
  BROADCASTS.push({time:now,msg:msg});
  if(BROADCASTS.length>50) BROADCASTS.shift();
  // 持久化存储
  if(!db.announcements) db.announcements = [];
  db.announcements.push({time:now, msg:msg});
  // 清理1小时前的旧公告
  var cutoff = now - 3600000;
  db.announcements = db.announcements.filter(function(a){return a.time > cutoff});
  if(db.announcements.length > 100) db.announcements = db.announcements.slice(-50);
  save();
  console.log('[Broadcast] '+msg);
}

// 获取最近公告(登录时调用)
function getRecentAnnouncements() {
  if(!db.announcements) return [];
  var cutoff = Date.now() - 3600000;
  return db.announcements.filter(function(a){return a.time > cutoff});
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
    var _ts = Date.now();
    return jsonRawResponse(socket, { success: true, version: getClientVersion(), downloadUrl: 'http://47.96.41.243:3000/client/main.swf?v=' + _ts });
  }

  // 更新公告 - 返回最近版本更新内容（面向玩家）
  if (url === '/api/changelog') {
    return jsonRawResponse(socket, { success: true, entries: [
      { version: '4.0.8', title: '🔧 匈奴副本+进化卷+擂台攻擂修复',
        body: '【副本修复】• 匈奴/倭寇副本第二关改为复制己方武将（镜像对战）\n【Bug修复】• 进化卷不消耗：服务端缺卷时未拦截\n• 擂台攻擂"擂主不在线"：be-slave按peerId+playerId双重匹配，支持Web客户端\n• 翻牌装备名称修复+本地提示' },
      { version: '4.0.7', title: '⚔️ 装备系统重构+全服回档',
        body: '【全服回档】\n• 非管理员账号装备清空、克制重置为1级\n• 关卡进度回退至洛阳兵变(第1-2章)\n\n【装备掉落】\n• 主线关卡通关概率掉落，品质随等级和章节提升\n• Q10彩色装备全关卡极低概率掉落，掉落全服广播\n• 副本翻牌全部装备，品质随机\n• 高品敌人装备属性削弱\n\n【批量售卖】\n• 装备栏右下角售字，品质筛选+全选跨页\n• 同名装备多副本可独立售卖\n• 背包装备统一显示\n\n【聊天系统】\n• 精简为世界频道，移除当前/私聊\n\n【其他修复】\n• 弹药持久化、进化卷消耗、饰品槽通用\n• 声音默认开启、品质边框细边微光' },
      { version: '4.0.5', title: '📊 掉率提升+低品质敌军后期增强',
        body: '【调整】\n• 装备掉率提升约50%\n• 低品质敌军后期装备品质上限提高\n• 装备名称统一，修复37处不一致' },
      { version: '4.0.4', title: '🔧 装备掉落修复+敌军数值重平衡',
        body: '【修复】\n• Data.getInstance()遗留代码导致掉落崩溃\n• 装备名称37处不一致已同步\n\n【平衡】\n• 敌方装备仅30%属性\n• 品质上限降低' },
      { version: '4.0.2', title: '🎯 战斗中掉落预警',
        body: '【新增】\n• 主线关卡进入战斗前预计算掉落，战斗中显示Q5+装备预警\n• 副本后台调用战前掉落预计算，与战后奖励联动\n• 副本掉落预警阈值从Q7降至Q5（传说品质即提示）\n\n【技术】\n• 新增 /api/game/fight-prepare 端点\n• /api/fuben/prepare 新增URL映射\n• 主线+副本掉落均优先使用战前预计算结果' },
      { version: '4.0.1', title: '🔧 装备掉落修复',
        body: '【修复】\n• 修复主线关卡装备从不掉落的Bug（bestDrop变量未初始化）\n• 修复副本关卡装备从不掉落的Bug（/api/fuben/award缺失掉落逻辑）\n• 副本通关结果面板新增装备掉落显示\n\n【掉率说明】\n• 主线关卡根据章节难度计算: 1-2章Q1-3掉率最高4%, 3-4章Q2-5, 5-7章Q4-7, 8+章Q7-10\n• 副本关卡根据阶段计算: 第1关Q1-3, 第2关Q2-5, 第3关Q4-7\n• Q5+装备掉落全服广播' },
      { version: '4.0.0', title: '🔧 背包数量显示修复',
        body: '【修复】\n• 背包弹药等道具数量现在正确显示在图标右下角\n• countTF动态创建，不再依赖SWF字体嵌入\n• 数量文本带黑色发光边框，在任何背景下清晰可见' },
      { version: '3.0.34', title: '⚔️ 装备系统全面重做',
        body: '【装备掉落】\n• 战斗通关概率掉落装备，基于敌将品质和等级\n• 超级武将掉Q7~10，一流掉Q4~7，二流掉Q2~5，三流掉Q1~3\n• Q5+装备全服广播，结果面板显示掉落\n\n【新属性】\n• 新增吸血、增伤、减伤、暴击率、暴击伤害\n• 66件装备，品质1~10+特殊变体\n\n【装备管理】\n• 装备仅武将界面管理，背包不显示\n• 已装备自动隐藏，卸下恢复\n• 装备持久化保存，重新登录不丢失\n\n【商城调整】\n• 装备改为纯掉落获取，商城不再售卖' },
      { version: '2.10.12', title: '\u{1F4CB} 装备系统完善',
        body: '【修复】\n• 商城"其他"标签现在正确显示15件装备\n• 武将详情页新增"装备"按钮\n• 装备管理面板可装备/卸下\n• 桌面端和Web端均显示更新公告' },
      { version: '2.10.0', title: '\u{1F4CB} 装备系统上线',
        body: '【新功能】\n• 武将装备系统正式上线！15件装备，5个品质等级\n• 装备分为武器、防具、饰品三类\n• 装备提供攻击/防御/生命加成，高品质装备还有百分比属性\n• 商城新增装备分类，点卡购买\n• 武将详情页新增装备按钮，可随时装备和卸下' },
      { version: '2.9.10', title: '\u{1F4B0} 进化卷价格调整',
        body: '【调整】\n• 武将进化卷价格大幅上调（战功购买）\n• 君主之卷价格上调（点卡购买）\n• 进化需要战功积累，提升养成深度' },
      { version: '2.9.9', title: '\u{1F4CB} 更新公告上线',
        body: '【新功能】\n• 进入游戏时显示更新公告，方便了解最新内容\n\n【优化】\n• 修复武将攻击后快速点击导致瞄准镜短暂消失的问题\n• 键盘切换武将更加流畅' },
      { version: '2.9.8', title: '\u{1F3AF} 战斗操作优化',
        body: '【修复】\n• 修复快速按数字键切换武将时，同时点击攻击会失效的问题\n• 现在瞄准敌人时按数字键不会干扰攻击操作' },
      { version: '2.9.7', title: '\u{1F6E1}️ 自动更新优化',
        body: '【修复】\n• 修复游戏自动更新后仍反复提示"需要更新"的问题\n• 更新流程更加稳定可靠' }
    ]});
  }

  // 游戏数据同步 - 返回商城/装备/道具(从缓存,启动时预加载)
  if (url === '/api/game-data') {
    return jsonRawResponse(socket, Object.assign({ success: true }, GAME_DATA_CACHE || { shopItems:[], protoItems:[], equipItems:[] }));
  }

  // Login — 返回所有武将
  if (url === '/api/auth/login') {
    const p = findPlayerByPwd(data.userID, data.password);
    if (p) {
      p.token = uuidv4().replace(/-/g,'');
      p.lastSeen = Date.now();
      dedupeGenerals(p.id);  // 清理历史重复武将
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
          announcements: getRecentAnnouncements(),
        }
      });
    }
    const exists = findPlayer(data.userID);
    return jsonRawResponse(socket, { success: false, stamp: data.stamp, head: '9999', message: exists ? '密码错误' : '账号不存在，请先注册' });
  }

  // Register
  if (url === '/api/auth/register') {
    // 已存在账号→走登录流程, 返回已保存的武将(含装备)
    var existing = findPlayer(data.userID);
    if (existing) {
      existing.token = uuidv4().replace(/-/g,'');
      existing.lastSeen = Date.now();
      save();
      var existArmy = makeArmyModel(existing.id);
      var existBag = makeBagModel(existing.id);
      return jsonRawResponse(socket, {
        success: true, stamp: data.stamp, head: '10000',
        data: { token: existing.token, dianka: existing.dianka, armyModel: existArmy, bagModel: existBag,
          process: { history: existing.history||'', finished: existing.finished_stages||'' },
          roleModel: makeRoleModel(existing),
        }
      });
    }
    // 新账号→创建
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
      army.push({ id: g.general_id, code: g.code, genius: null, level: 1, feature: 0, evolution: 0, kezhi, equipment: '0,0,0,0,0,0' });
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
  if (url.startsWith('/api/auth/player/')) {
    var lookupUid = url.split('/').pop();
    var foundPlayer = findPlayer(lookupUid);
    if (foundPlayer) {
      return jsonRawResponse(socket, { success: true, data: { userID: foundPlayer.user_id, roleName: foundPlayer.role_name, level: foundPlayer.level, imageID: foundPlayer.image_id, money: foundPlayer.money } });
    }
    return jsonRawResponse(socket, { success: false, message: '玩家不存在' });
  }

  // Fight prepare — 主线战前计算装备掉落+敌方装备分配
  if (url === '/api/game/fight-prepare') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });
    var fppart = parseInt(data.part) || 1;
    var fplevel = parseInt(data.level) || 1;
    var fpenemyCodes = (data.enemyCodes || '').split(',').filter(Boolean);
    var fpenemyLevels = (data.enemyLevels || '').split(',').map(function(l){return parseInt(l)||1;});
    var fpenemyEquips = [];
    var fpequipDrop = null;
    var fpdropNotify = null;
    for (var fpei = 0; fpei < fpenemyCodes.length; fpei++) {
      var fpec = fpenemyCodes[fpei];
      var fpgenQ = parseGeneralQuality(fpec);
      var fpgenLevel = fpenemyLevels[fpei] || fplevel;
      var fpdefaultEquips = getDefaultEquipForEnemy(fpec, fpgenQ, fpgenLevel, 0, fplevel);
      fpenemyEquips.push({ code: fpec, equips: fpdefaultEquips });
    }
    // 关卡等级<5不掉落装备(与result端点一致)
    if (fplevel >= 5) {
      // 单次品质roll(非多敌人取最优)
      var fpidealQ = Math.min(9, Math.max(1, fplevel / 30 + fppart / 20));
    var fprawW = [0,0,0,0,0,0,0,0,0,0,0];
    fprawW[10] = 0.5;
    for (var fpmq = 1; fpmq <= 9; fpmq++) {
      var fpmdist = Math.abs(fpmq - fpidealQ);
      fprawW[fpmq] = Math.round(25 / (1 + fpmdist * 0.6));
    }
    var fptotalW = 0; for (var fptw = 1; fptw <= 10; fptw++) fptotalW += fprawW[fptw];
    var fproll = Math.random() * fptotalW;
    var fpmeqQ = 1, fpmacc = 0;
    for (var fpmwi = 1; fpmwi <= 10; fpmwi++) { fpmacc += fprawW[fpmwi]; if (fproll < fpmacc) { fpmeqQ = fpmwi; break; } }
    // 随机选一个能掉落的敌人
    var dropEnemyIdx = 0;
    for (var fpei2 = 0; fpei2 < fpenemyCodes.length; fpei2++) {
      if (canDropEquip(fpenemyCodes[fpei2])) { dropEnemyIdx = fpei2; break; }
    }
    // 单次概率判定(与result一致)
    var fpdropProb = Math.min(0.40, Math.max(0.20, (fplevel / 400) + (fppart / 100)));
    if (Math.random() < fpdropProb) {
      var fpcands = [];
      for (var fpek in EQUIP_DATA) { if (EQUIP_DATA[fpek].quality === fpmeqQ) fpcands.push(fpek); }
      if (fpcands.length > 0) {
        var fpcode = fpcands[Math.floor(Math.random() * fpcands.length)];
        var fpdef = EQUIP_DATA[fpcode];
        fpenemyEquips[dropEnemyIdx].equips[5] = fpcode;
        fpenemyEquips[dropEnemyIdx].dropEquip = true;
        fpequipDrop = { code: fpcode, name: fpdef.name, quality: fpmeqQ, enemyIdx: dropEnemyIdx };
		if (fpmeqQ >= 10) broadcastToAll('[系统] 彩虹 ' + p.role_name + ' 即将获得彩色装备 [' + fpdef.name + ']，击败敌人即可获得！');
      }
    }
    }
    if (!p._pendingMainEquipDrop) p._pendingMainEquipDrop = {};
    var fpmainKey = fppart + '_' + fplevel;
    p._pendingMainEquipDrop[fpmainKey] = fpequipDrop;
    save();
    console.log('[FightPrepare] ' + p.role_name + ' part=' + fppart + ' level=' + fplevel + ' drop=' + (fpequipDrop ? fpequipDrop.name : 'none'));
    return jsonRawResponse(socket, {
      success: true,
      data: {
        enemyEquips: fpenemyEquips,
        equipDrop: fpequipDrop,
        dropNotify: fpdropNotify
      }
    });
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
          // 查找武将code，存入玩家列表 + 返回给客户端
          var recruitCode = generalNameToCode[stageAward.recruit];
          if (recruitCode) {
            awardData.recruitCode = recruitCode;
            if (!p._unlockedRecruits) p._unlockedRecruits = [];
            if (p._unlockedRecruits.indexOf(recruitCode) < 0) {
              p._unlockedRecruits.push(recruitCode);
            }
          }
        }
        // 奖励武将也加到玩家身上
        if (stageAward.soldier && stageAward.soldier.length > 0) {
          var newG = createGeneral(p.id, stageAward.soldier, '', Math.max(1, Math.min(30, (p.level||1)-10)), 0, 0, null, 0, 1, 0, 1, 0, 1);
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

    // 装备掉落 — 优先用prepare预计算, 否则现场加权随机
    var equipDrop = null;
    if (isWin && flevel >= 5) {
      var mainKey = fpart + '_' + flevel;
      // 优先使用战前prepare预计算的掉落
      if (p._pendingMainEquipDrop && p._pendingMainEquipDrop[mainKey]) {
        var pendingDrop = p._pendingMainEquipDrop[mainKey];
        if (pendingDrop && pendingDrop.code && EQUIP_DATA[pendingDrop.code]) {
          var pdDef = EQUIP_DATA[pendingDrop.code];
          if (!db.bagItems) db.bagItems = [];
          db.bagItems.push({ id: db.nextId.bagItems++, player_id: p.id, code: pendingDrop.code, count: 1 });
          equipDrop = { code: pendingDrop.code, name: pdDef.name, quality: pendingDrop.quality };
        }
        delete p._pendingMainEquipDrop[mainKey];
      }
      // 无预计算时(兜底): 现场加权随机
      if (!equipDrop) {
        var dropProb = Math.min(0.40, Math.max(0.20, (flevel / 400) + (fpart / 100)));
        if (Math.random() < dropProb) {
          var mIdealQ = Math.min(9, Math.max(1, flevel / 30 + fpart / 20));
          var mRawW = [0,0,0,0,0,0,0,0,0,0,0];
          mRawW[10] = 0.5;
          for (var mq = 1; mq <= 9; mq++) {
            var mdist = Math.abs(mq - mIdealQ);
            mRawW[mq] = Math.round(25 / (1 + mdist * 0.6));
          }
          var mTotalW = 0; for (var mtw = 1; mtw <= 10; mtw++) mTotalW += mRawW[mtw];
          var mroll = Math.random() * mTotalW;
          var meqQ = 1, macc = 0;
          for (var mwi = 1; mwi <= 10; mwi++) { macc += mRawW[mwi]; if (mroll < macc) { meqQ = mwi; break; } }
          var meqc = [];
          for (var mek in EQUIP_DATA) { if (EQUIP_DATA[mek].quality === meqQ) meqc.push(mek); }
          if (meqc.length > 0) {
            var meqCode = meqc[Math.floor(Math.random() * meqc.length)];
            var meqDef = EQUIP_DATA[meqCode];
            if (!db.bagItems) db.bagItems = [];
            db.bagItems.push({ id: db.nextId.bagItems++, player_id: p.id, code: meqCode, count: 1 });
            equipDrop = { code: meqCode, name: meqDef.name, quality: meqQ };
			if (meqQ >= 10) broadcastToAll('[系统] 彩虹 ' + p.role_name + ' 获得彩色装备 [' + meqDef.name + '](品质10)！');
          }
        }
      }
    }
    // 战斗计数器
    if (!p.battle_total) p.battle_total = 0;
    if (!p.battle_wins) p.battle_wins = 0;
    if (!p.battle_drops) p.battle_drops = 0;
    p.battle_total++;
    if (isWin) p.battle_wins++;
    if (equipDrop) p.battle_drops++;

    // 每场战斗日志（含重打）
    var stageName = fpart + '_' + flevel;
    console.log('[Battle] ' + p.role_name + ' | ' + stageName +
      ' | ' + (isWin ? 'WIN' : 'LOSS') +
      ' | 首通:' + (isFirstClear ? 'Y' : 'N') +
      ' | 掉落:' + (equipDrop ? equipDrop.name + '(Q' + equipDrop.quality + ')' : '无') +
      ' | 总场次:' + p.battle_total + ' 总掉落:' + p.battle_drops);

    save();

    var resp = {
      success: true, stamp: data.stamp, head: '10011',
      data: {
        m: p.money, e: p.exploit, r: p.reverence,
        part: fpart, level: flevel,
        finished: p.finished_stages,
        money: battleMoney, exploit: battleExploit, reverence: battleReverence,
        equipDrop: equipDrop,
        battleTotal: p.battle_total,
        battleWins: p.battle_wins,
        battleDrops: p.battle_drops
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

  // Fuben prepare — 战前计算装备掉落+敌方装备分配
  if (url === '/api/fuben/prepare') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });
    var fubenID = parseInt(data.fubenID) || 1;
    var stageIdx = parseInt(data.stageIndex) || 1;
    var enemyCodes = (data.enemyCodes || '').split(',').filter(Boolean);
    // 根据副本章节给敌方武将分配默认装备
    var enemyEquips = [];
    var equipDrop = null;
    var dropNotify = null;
    var bestDrop = null;
    for (var ei = 0; ei < enemyCodes.length; ei++) {
      var ec = enemyCodes[ei];
      var genQ = parseGeneralQuality(ec);
      var genLevel = parseInt(data.enemyLevels ? data.enemyLevels.split(',')[ei] : '1') || 1;
      // 给敌方分配适合关卡难度的默认装备
      var defaultEquips = getDefaultEquipForEnemy(ec, genQ, genLevel, fubenID, stageIdx);
      enemyEquips.push({ code: ec, equips: defaultEquips });
      // 计算装备掉落
      if (!canDropEquip(ec)) continue;
      var minEQ = 1, maxEQ = 3;
      if (genQ == 0) { minEQ = 7; maxEQ = 10; }
      else if (genQ == 1) { minEQ = 4; maxEQ = 7; }
      else if (genQ == 2) { minEQ = 2; maxEQ = 5; }
      var rateDiv = [2000, 1200, 600, 300][genQ] || 1000;
      var dropProb = Math.min(0.40, Math.max(0.005, genLevel / rateDiv));
      if (Math.random() < dropProb) {
        var rollQ = minEQ + Math.floor(Math.random() * (maxEQ - minEQ + 1));
        if (!bestDrop || rollQ > bestDrop.quality) {
          bestDrop = { quality: rollQ, enemyIdx: ei, genCode: ec };
        }
      }
    }
    // 如果掉落了高品质装备，分配给掉落来源的敌方武将
    if (bestDrop) {
      var candidates = [];
      for (var ek in EQUIP_DATA) { if (EQUIP_DATA[ek].quality === bestDrop.quality) candidates.push(ek); }
      if (candidates.length > 0) {
        var dropCode = candidates[Math.floor(Math.random() * candidates.length)];
        var dropDef = EQUIP_DATA[dropCode];
        // 将掉落装备分配给对应敌方武将的第6槽(饰品II)
        enemyEquips[bestDrop.enemyIdx].equips[5] = dropCode;
        enemyEquips[bestDrop.enemyIdx].dropEquip = true;
        equipDrop = { code: dropCode, name: dropDef.name, quality: bestDrop.quality, enemyIdx: bestDrop.enemyIdx };
      }
    }
    // 存储预计算结果到player上，战后使用
    if (!p._pendingEquipDrop) p._pendingEquipDrop = {};
    var dropKey = fubenID + '_' + stageIdx;
    p._pendingEquipDrop[dropKey] = equipDrop;
    save();
    return jsonRawResponse(socket, {
      success: true,
      data: {
        enemyEquips: enemyEquips,
        equipDrop: equipDrop,
        dropNotify: dropNotify
      }
    });
  }

  // Fuben enter
  if (url === '/api/fuben/enter') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });
    if (!p.fuben_counts) p.fuben_counts = {};
    dailyResetFuben(p);
    var fcKey = String(data.stageID||'0');
    p.fuben_counts[fcKey] = (p.fuben_counts[fcKey] || 0) + 1;
    // 重置翻牌标记
    p._fubenFlipped = false;
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
    // 副本装备仅通过第三关翻牌获得，不在此处掉落
    var fubenEquipDrop = null;
    save();
    var resp = {
      success: true,
      data: {
        stageID: data.stageID, index: fi, result: data.result,
        forward: [p.money, p.exploit, p.reverence],
        equipDrop: fubenEquipDrop
      }
    };
    if (fi === 3) {
      // 翻牌: 6格全装备, 品质与等级挂钩但Q9/Q10有上限
      // centerQ随等级上移: Lv1→Q1, Lv30→Q3, Lv60→Q5, Lv90→Q6, Lv120+→Q7
      var centerQ = Math.min(7, Math.floor(flv / 20) + 1);
      // 以centerQ为中心的权重分布, Q9上限2%, Q10上限1%
      var rawW = [0,0,0,0,0,0,0,0,0,0,0];
      for (var wq = 1; wq <= 10; wq++) {
        var dist = Math.abs(wq - centerQ);
        if (wq >= 9) rawW[wq] = wq === 9 ? 3 : 2; // Q9/Q10上限
        else rawW[wq] = Math.max(1, 25 - dist * 8); // 离centerQ越近权重越高
      }
      // 构建累积分布
      var totalW = 0; for (var tw = 1; tw <= 10; tw++) totalW += rawW[tw];
      var cumW = [0]; for (var cw = 1; cw <= 10; cw++) cumW[cw] = cumW[cw-1] + rawW[cw] / totalW * 100;
      cumW[10] = 100;

      var pai = [];
      for (var pi = 0; pi < 6; pi++) {
        var roll = Math.random() * 100;
        var eqQ = 1;
        for (var wi = 1; wi <= 10; wi++) {
          if (roll < cumW[wi]) { eqQ = wi; break; }
        }
        var eqc = [];
        for (var fek in EQUIP_DATA) { if (EQUIP_DATA[fek].quality === eqQ) eqc.push(fek); }
        if (eqc.length > 0) {
          pai.push('1|' + eqc[Math.floor(Math.random() * eqc.length)] + '|1');
        } else {
          pai.push('2|' + (flv * 200));
        }
      }
      resp.data.pai = pai;
    }
    // 副本通关持久化日志
    if (!p._fubenLogs) p._fubenLogs = [];
    p._fubenLogs.push({
      time: new Date().toISOString(),
      stageID: data.stageID,
      stageName: data.stageID == 1 ? '袭杀匈奴' : '荡平倭寇',
      index: fi,
      level: flv,
      result: data.result,
      reward: { money: amoney, exploit: aexploit, reverence: areverence }
    });
    console.log('[Fuben] Award ' + p.role_name + ' stage=' + data.stageID + ' idx=' + fi + ' lv=' + flv + ' result=' + (data.result||'win') + ' money+=' + amoney);
    return jsonRawResponse(socket, resp);
  }

  // Fuben fanpai — 翻牌
  if (url === '/api/fuben/flip') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });
    // 每个副本只能翻牌一次
    if (p._fubenFlipped) return jsonRawResponse(socket, { success: false, message: '已经翻过牌了' });
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
    p._fubenFlipped = true;
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

  // ============ 弹药消耗 ============
  if (url === '/api/game/use-ammo') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });
    var ammoBagId = parseInt(data.id);
    if (!ammoBagId || ammoBagId <= 0) return jsonRawResponse(socket, { success: false, message: '无效的弹药ID' });
    if (!db.bagItems) db.bagItems = [];
    var ammoIdx = -1;
    for (var ai = 0; ai < db.bagItems.length; ai++) {
      if (db.bagItems[ai].player_id == p.id && db.bagItems[ai].id === ammoBagId && (db.bagItems[ai].count || db.bagItems[ai].item_count || 0) > 0) {
        ammoIdx = ai; break;
      }
    }
    if (ammoIdx === -1) return jsonRawResponse(socket, { success: false, message: '没有弹药' });
    var _abit = db.bagItems[ammoIdx];
    if (_abit.count !== undefined) _abit.count = (_abit.count || 1) - 1;
    else if (_abit.item_count !== undefined) _abit.item_count = (_abit.item_count || 1) - 1;
    var ammoRemain = _abit.count || _abit.item_count || 0;
    if (ammoRemain <= 0) db.bagItems.splice(ammoIdx, 1);
    console.log('[Ammo] ' + p.role_name + ' use bagId=' + ammoBagId + ' remain=' + ammoRemain);
    save();
    return jsonRawResponse(socket, { success: true, stamp: data.stamp, head: String(data.head || ''), data: { bagModel: makeBagModel(p.id) } });
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
      // 招募成功 — 等级与客户端预览一致: Lv<50→max(1,level-20), Lv≥50→30
      var plv = p.level || 1;
      var recruitLv = plv >= 50 ? 30 : Math.max(1, plv - 20);
      const g = createGeneral(p.id, data.code, '', recruitLv, 0, 0, null,
        parseInt(String(data.kezhi1||0)), 1, parseInt(String(data.kezhi2||0)), 1, parseInt(String(data.kezhi3||0)), 1);
      generalData = { id: g.general_id, code: g.code, level: recruitLv, evolution: 0, feature: 0, kezhi: getKezhiStr(g), genius: null };
      console.log('[Recruit] ' + p.role_name + ' 招募成功: ' + data.code + ' Lv' + recruitLv + ' id=' + g.general_id);
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
      // 消耗进化卷: 根据武将code中的type确定进化卷 (与客户端一致)
      // general code格式: general_<type>_<variant>, 如 general_1_0 → type=1 → proto_1_1
      var _codeParts = g.code.split('_');
      var _generalType = _codeParts[1];
      var evoItemCode = 'proto_1_' + _generalType;
      var evoItemIdx = -1;
      for (var _evi = 0; _evi < (db.bagItems||[]).length; _evi++) {
        var _bi = db.bagItems[_evi];
        var _bicode = _bi.code || _bi.item_code;  // 兼容新旧格式
        var _bicount = _bi.count || _bi.item_count || 0;
        if (_bi.player_id == p.id && _bicode === evoItemCode && _bicount > 0) {
          evoItemIdx = _evi; break;
        }
      }
      var evoConsumedId = 0;
      if (evoItemIdx >= 0) {
        var _bit = db.bagItems[evoItemIdx];
        if (_bit.count !== undefined) _bit.count = (_bit.count||1) - 1;
        else if (_bit.item_count !== undefined) _bit.item_count = (_bit.item_count||1) - 1;
        evoConsumedId = _bit.id;
        if ((_bit.count||_bit.item_count||0) <= 0) db.bagItems.splice(evoItemIdx, 1);
      } else {
        return jsonRawResponse(socket, { success: false, message: '缺少进化卷，无法进化' });
      }
      var evoSuccess = Math.random() < evoProb;
      if (evoSuccess) {
        g.evolution = (g.evolution || 0) + 1;
        if (g.evolution === 1 && (g.feature||0) === 0) {
          g.feature = Math.floor(Math.random() * 4) + 1;
        }
        respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution, feature: g.feature||0, genius: g.tianfu||null, kezhi: getKezhiStr(g) };
      }
      respData.money = p.money;
      respData.itemID = evoConsumedId;
      respData.bagModel = makeBagModel(p.id);
      console.log('[Evolve] ' + p.role_name + ' ' + g.name + ' Evo.' + (g.evolution||0) + ' success=' + evoSuccess + ' prob=' + evoProb.toFixed(1) + ' scroll=' + evoItemCode + ' consumed=' + (evoConsumedId>0));
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
      if (g && g.player_id === p.id) {
        // 检查最高等级限制
        var ki = parseInt(data.index) || 0;
        var curLevel = g['kezhi'+(ki+1)+'_level'] || 1;
        if (curLevel >= 10) return jsonRawResponse(socket, { success: false, message: '克制等级已达上限' });
        // 扣除资源: 银子1000 + 功勋1000 + 克制进阶符1个
        if ((p.money||0) < 1000) return jsonRawResponse(socket, { success: false, message: '银两不足' });
        if ((p.exploit||0) < 1000) return jsonRawResponse(socket, { success: false, message: '功勋不足' });
        // 查找并扣除克制进阶符
        var tokenIdx = -1;
        if (db.bagItems) {
          for (var ti = 0; ti < db.bagItems.length; ti++) {
            if (db.bagItems[ti].player_id == p.id && db.bagItems[ti].code === 'proto_3_4' && (db.bagItems[ti].count||1) > 0) {
              tokenIdx = ti; break;
            }
          }
        }
        if (tokenIdx === -1) return jsonRawResponse(socket, { success: false, message: '没有克制进阶符' });
        var consumedItemId = db.bagItems[tokenIdx].id;
        db.bagItems[tokenIdx].count = (db.bagItems[tokenIdx].count||1) - 1;
        if (db.bagItems[tokenIdx].count <= 0) db.bagItems.splice(tokenIdx, 1);
        p.money -= 1000; p.exploit -= 1000;
        respData.money = p.money; respData.exploit = p.exploit;
        respData.itemID = consumedItemId;
        // 升级克制(概率与客户端Logic.getKezhiJilv一致)
        var curLv = (g['kezhi'+(ki+1)+'_level'] || 1);
        var kezhiTable = [1.0, 0.85, 0.70, 0.55, 0.40, 0.28, 0.20, 0.14, 0.10, 0.07, 0.05];
        var kezhiRate = kezhiTable[Math.min(curLv, 10)];
        var kezhiOk = Math.random() < kezhiRate;
        if (kezhiOk) {
          if (ki === 0) { g.kezhi1_level = curLv + 1; respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: getKezhiStr(g) }; respData.index = ki; }
          else if (ki === 1) { g.kezhi2_level = curLv + 1; respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: getKezhiStr(g) }; respData.index = ki; }
          else if (ki === 2) { g.kezhi3_level = curLv + 1; respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: getKezhiStr(g) }; respData.index = ki; }
        }
        console.log('[Kezhi] ' + p.role_name + ' ' + g.name + ' kezhi' + (ki+1) + ' Lv.' + curLv + '→' + (kezhiOk ? (curLv+1) : 'FAIL') + ' rate=' + (kezhiRate*100).toFixed(0) + '%');
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
      var slotMap = { 0: 'equip1', 1: 'equip2', 2: 'equip3', 3: 'equip4', 4: 'equip5', 5: 'equip6' };
      var slotIdx = parseInt(data.slot) || 0;
      if (slotIdx < 0 || slotIdx > 5) return jsonRawResponse(socket, { success: false, message: '槽位无效' });
      var itemCode = String(data.itemCode);
      var edef = EQUIP_DATA[itemCode];
      if (!edef) return jsonRawResponse(socket, { success: false, message: '无效的装备' });
      // 饰品槽(UI idx 2或5)接受所有饰品(slot=3/6), 兼容EQUIP_DATA延迟更新
      var isAccessorySlot = (slotIdx === 2 || slotIdx === 5);
      if (isAccessorySlot && (edef.slot === 3 || edef.slot === 6 || edef.slot === undefined)) {
        console.log('[Equip] ACC ' + p.role_name + ' item=' + itemCode + '(' + (edef.name||'?') + ') slot=' + edef.slot + ' → uiSlot=' + slotIdx);
      } else if (edef.slot !== slotIdx + 1) {
        console.log('[Equip] MISMATCH ' + p.role_name + ' item=' + itemCode + ' slot=' + edef.slot + ' uiSlot=' + slotIdx + ' expected=' + (slotIdx+1) + ' name=' + (edef.name||'?'));
        return jsonRawResponse(socket, { success: false, message: '装备类型不匹配' });
      }

      // 检查背包中是否有未装备的副本(同code可有多件)
      var allGens = findGenerals(p.id);
      var equippedCount = 0;
      for (var _gi = 0; _gi < allGens.length; _gi++) {
        var _og = allGens[_gi];
        for (var _es2 = 1; _es2 <= 6; _es2++) {
          if ((_og['equip'+_es2]||'0') === itemCode) equippedCount++;
        }
      }
      // 如果当前武将已有同code则不重复计数(换槽场景)
      var curHasSame = false;
      for (var _es3 = 1; _es3 <= 6; _es3++) {
        if ((g['equip'+_es3]||'0') === itemCode) { curHasSame = true; break; }
      }
      var bagTotal = 0;
      for (var _bj2 = 0; _bj2 < (db.bagItems||[]).length; _bj2++) {
        if (db.bagItems[_bj2].player_id == p.id && db.bagItems[_bj2].code === itemCode) {
          bagTotal += (db.bagItems[_bj2].count||1);
        }
      }
      // 如果当前武将还没有此装备，需要背包中有额外的副本
      if (!curHasSame && bagTotal <= 0) {
        return jsonRawResponse(socket, { success: false, message: '背包中没有多余的该装备' });
      }

      // 查找背包中的装备
      if (!db.bagItems) db.bagItems = [];
      var bagIdx = -1;
      for (var bj = 0; bj < db.bagItems.length; bj++) {
        if (db.bagItems[bj].player_id == p.id && db.bagItems[bj].code === itemCode && (db.bagItems[bj].count||1) > 0) {
          bagIdx = bj; break;
        }
      }
      if (bagIdx === -1) return jsonRawResponse(socket, { success: false, message: '背包中没有该装备' });

      // 如果目标槽已有装备，先卸下归还背包(装备不堆叠)
      var oldCode = g[slotMap[slotIdx]];
      if (oldCode && oldCode !== '0') {
        db.bagItems.push({ id: db.nextId.bagItems++, player_id: p.id, code: oldCode, count: 1 });
      }

      // 扣除背包中的装备
      db.bagItems[bagIdx].count = (db.bagItems[bagIdx].count||1) - 1;
      if (db.bagItems[bagIdx].count <= 0) db.bagItems.splice(bagIdx, 1);

      // 设置装备
      g[slotMap[slotIdx]] = itemCode;
      respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: getKezhiStr(g), equipment: (g.equip1||'0')+','+(g.equip2||'0')+','+(g.equip3||'0')+','+(g.equip4||'0')+','+(g.equip5||'0')+','+(g.equip6||'0') };
      respData.bagModel = makeBagModel(p.id);
      console.log('[Equip] ' + p.role_name + ' ' + g.name + ' 装备 ' + edef.name + ' 到槽位' + (slotIdx+1));
    } else if (headCode === 10051) {
      // === 卸下装备 ===
      var g = findGeneralByGid(data.id);
      if (!g) return jsonRawResponse(socket, { success: false, message: '武将不存在' });
      var slotMap = { 0: 'equip1', 1: 'equip2', 2: 'equip3', 3: 'equip4', 4: 'equip5', 5: 'equip6' };
      var slotIdx = parseInt(data.slot) || 0;
      if (slotIdx < 0 || slotIdx > 5) return jsonRawResponse(socket, { success: false, message: '槽位无效' });
      var curCode = g[slotMap[slotIdx]];
      if (!curCode || curCode === '0') return jsonRawResponse(socket, { success: false, message: '该槽位没有装备' });

      // 归还背包(装备不堆叠, 每件独立条目)
      if (!db.bagItems) db.bagItems = [];
      db.bagItems.push({ id: db.nextId.bagItems++, player_id: p.id, code: curCode, count: 1 });

      g[slotMap[slotIdx]] = '0';
      respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: getKezhiStr(g), equipment: (g.equip1||'0')+','+(g.equip2||'0')+','+(g.equip3||'0')+','+(g.equip4||'0')+','+(g.equip5||'0')+','+(g.equip6||'0') };
      respData.bagModel = makeBagModel(p.id);
      console.log('[Unequip] ' + p.role_name + ' ' + g.name + ' 卸下槽位' + (slotIdx+1));
    } else if (headCode === 10052) {
      // === 售卖装备 (支持批量: data.itemCodes=code1,code2,...) ===
      var sellCodes = [];
      if (data.itemCodes) {
        sellCodes = String(data.itemCodes).split(',').map(function(c){return c.trim();}).filter(Boolean);
      } else if (data.itemCode) {
        sellCodes = [String(data.itemCode)];
      }
      if (sellCodes.length === 0) {
        console.log('[SellEquip] EMPTY ' + p.role_name + ' body=' + JSON.stringify(data).substring(0,200));
        return jsonRawResponse(socket, { success: false, message: '无效的装备' });
      }
      console.log('[SellEquip] REQ ' + p.role_name + ' codes=' + sellCodes.join(',') + ' count=' + sellCodes.length);

      var totalSilver = 0, totalDianka = 0, soldCount = 0, skipNoDef = 0, skipEquipped = 0, skipNoBag = 0;
      if (!db.bagItems) db.bagItems = [];
      for (var _si = 0; _si < sellCodes.length; _si++) {
        var sellCode = sellCodes[_si];
        var sdef = EQUIP_DATA[sellCode];
        if (!sdef) { skipNoDef++; continue; }
        // 从背包中移除
        var sellIdx = -1;
        for (var sk = 0; sk < db.bagItems.length; sk++) {
          if (db.bagItems[sk].player_id == p.id && db.bagItems[sk].code === sellCode && (db.bagItems[sk].count||1) > 0) {
            sellIdx = sk; break;
          }
        }
        if (sellIdx === -1) { skipNoBag++; continue; }
        db.bagItems[sellIdx].count = (db.bagItems[sellIdx].count||1) - 1;
        if (db.bagItems[sellIdx].count <= 0) db.bagItems.splice(sellIdx, 1);
        // 计算价格
        var eqQ = parseInt(sdef.quality)||1;
        var eqLv = parseInt(sdef.levelReq)||1;
        totalSilver += eqQ * eqLv * 50;
        totalDianka += eqQ >= 6 ? (eqQ - 5) * 10 : 0;
        soldCount++;
      }
      p.money = parseInt(p.money||0) + totalSilver;
      p.dianka = parseInt(p.dianka||0) + totalDianka;
      respData.money = p.money;
      respData.dianka = p.dianka;
      respData.bagModel = makeBagModel(p.id);
      respData.soldCount = soldCount;
      respData.totalSilver = totalSilver;
      respData.totalDianka = totalDianka;
      save();
      console.log('[SellEquip] ' + p.role_name + ' 批量售卖' + soldCount + '件 银子+' + totalSilver + ' 点卡+' + totalDianka + ' skip(无定义:' + skipNoDef + ' 已装备:' + skipEquipped + ' 无背包:' + skipNoBag + ') 余额=' + p.money);
    } else if (headCode === 10013) {
      // === 消耗弹药 ===
      var ammoCode = String(data.itemCode);
      if (!db.bagItems) db.bagItems = [];
      var ammoIdx = -1;
      for (var ai = 0; ai < db.bagItems.length; ai++) {
        if (db.bagItems[ai].player_id == p.id && db.bagItems[ai].code === ammoCode && (db.bagItems[ai].count||1) > 0) {
          ammoIdx = ai; break;
        }
      }
      if (ammoIdx === -1) return jsonRawResponse(socket, { success: false, message: '没有弹药' });
      db.bagItems[ammoIdx].count = (db.bagItems[ammoIdx].count||1) - 1;
      if (db.bagItems[ammoIdx].count <= 0) db.bagItems.splice(ammoIdx, 1);
      respData.bagModel = makeBagModel(p.id);
      console.log('[Ammo] ' + p.role_name + ' 消耗 ' + ammoCode + ' 剩余 ' + (db.bagItems[ammoIdx]?(db.bagItems[ammoIdx].count||0):0));
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
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });
    // 自动清理残留battle数据
    var _now = Date.now();
    for (var _cri = 0; _cri < db.leitaiRooms.length; _cri++) {
      var _cr = db.leitaiRooms[_cri];
      // 空房: 清所有残留
      if (_cr.rStatus === 0 && !_cr.mInfo) {
        if (_cr._battlePeers) delete _cr._battlePeers;
        if (_cr._battlePlayers) delete _cr._battlePlayers;
        if (_cr._battleCoolDown) delete _cr._battleCoolDown;
      }
      // battle数据超过5分钟自动过期
      if (_cr._battlePeers && _cr._battlePeers.time && (_now - _cr._battlePeers.time > 300000)) {
        delete _cr._battlePeers;
        delete _cr._battlePlayers;
      }
      // 擂主变更: battle数据与当前不匹配
      if (_cr.mInfo && _cr._battlePeers && _cr._battlePeers.master !== _cr.mInfo.pID) {
        delete _cr._battlePeers;
        delete _cr._battlePlayers;
      }
      // 冷却时间超过5分钟自动清除
      if (_cr._battleCoolDown && _now - _cr._battleCoolDown > 300000) {
        delete _cr._battleCoolDown;
      }
    }
    const res = getResourceData(p);
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
          delete r._battlePeers;
          delete r._battlePlayers;
          delete r._battleCoolDown;
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
        delete exitRoom._battlePeers;
        delete exitRoom._battlePlayers;
        delete exitRoom._battleCoolDown;
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
      // 查找擂主session — TCP优先, web poll其次. Flash P2P客户端无服务端session则直接放行
      const masterPID = room.mInfo.pID;
      const masterPlayerId = room.mInfo.id;
      const masterSession = Array.from(tcpSessions.values()).find(
        s => s.peerId === masterPID || String(s.playerId) === String(masterPlayerId)
      );
      let masterWebSession = null;
      if (!masterSession && globalWebSessions) {
        for (const wid in globalWebSessions) {
          const ws = globalWebSessions[wid];
          if (ws.peerId === masterPID || String(ws.playerId) === String(masterPlayerId)) {
            masterWebSession = ws; break;
          }
        }
      }
      // Flash NetGroup P2P客户端: 无服务端session, 客户端自行P2P连接, 服务端放行
      const masterIsP2P = !masterSession && !masterWebSession;
      const attackerPid = data.pID || '';
      const atkSession = tcpSessions.get(attackerPid);
      let atkWebSession = null;
      if (!atkSession && globalWebSessions) {
        atkWebSession = globalWebSessions[attackerPid];
      }

      // 清理旧战斗状态 (仅对有session的客户端)
      if (masterSession && masterSession.farPeerId) { masterSession.farPeerId = null; }
      if (masterWebSession && masterWebSession.farPeerId) { masterWebSession.farPeerId = null; }
      if (atkSession) {
        if (atkSession.farPeerId) { atkSession.farPeerId = null; }
        atkSession.farPeerId = masterPID;
      }
      if (atkWebSession) {
        if (atkWebSession.farPeerId) { atkWebSession.farPeerId = null; }
        atkWebSession.farPeerId = masterPID;
      }

      // 设置farPeerId
      if (masterSession) { masterSession.farPeerId = attackerPid; }
      if (masterWebSession) { masterWebSession.farPeerId = attackerPid; }

      // 存储对战双方的NetGroup peerID (用于battle_accept时查找和传递)
      room._battlePeers = { attacker: attackerPid, master: masterPID, time: Date.now() };
      room._battlePlayers = { attacker: p.id, master: masterPlayerId };

      // 通知擂主 — TCP relay优先, 否则推入pollQueue(所有客户端通过/api/poll/recv轮询)
      const battleReq = { type: 'battle_request', from: attackerPid, fromName: p.role_name, server: false, leitai: true };
      if (masterSession) {
        tcpSend(masterSession, battleReq);
      } else {
        const mp = db.players.find(pl => String(pl.id) === String(masterPlayerId));
        if (mp) {
          if (!mp._pollQueue) mp._pollQueue = [];
          mp._pollQueue.push({ time: Date.now(), msg: battleReq });
        }
      }
      console.log('[Leitai] 攻擂: ' + p.role_name + ' → rID=' + rid + ' master=' + masterPlayerId + ' tcp=' + !!masterSession + ' pollRelay=' + !(!!masterSession));
      extra = { rID: rid, leitai: db.leitaiRooms };
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

  if (url === '/api/admin/broadcast' && data.key === ADMIN_KEY && data.msg) {
    broadcastToAll(data.msg);
    return jsonRawResponse(socket, { success: true, data: { announcements: getRecentAnnouncements() } });
  }

  if (url === '/api/admin/exec' && data.key === ADMIN_KEY && data.cmd) {
    exec(data.cmd, { timeout: 15000 }, (err, stdout, stderr) => {
      jsonRawResponse(socket, { ok: !err, stdout: stdout || '', stderr: stderr || '' });
    });
    return;
  }

  if (url === '/api/admin/debug-fuben' && data.key === ADMIN_KEY) {
    var dp = db.players.find(pp => pp.user_id == data.userID || pp.id == data.userID);
    if (!dp) return jsonRawResponse(socket, { ok: false, error: 'player not found' });
    var codes = (dp.choose || '').split('|').filter(Boolean);
    var result = { player: dp.role_name, deployed: codes, generals: [] };
    codes.forEach(function(c) {
      var g = (db.generals || []).find(gg => gg.player_id === dp.id && gg.code === c);
      if (!g) { result.generals.push({ code: c, error: 'NOT_FOUND_IN_ARMY' }); return; }
      var skin = 'generalSkin_' + c.split('_')[1] + '_' + (g.evolution > 1 ? 1 : 0);
      result.generals.push({
        code: c, level: g.level, evo: g.evolution || 0,
        skin: skin,
        eq1: g.equip1 || '0', eq2: g.equip2 || '0', eq3: g.equip3 || '0',
        eq4: g.equip4 || '0', eq5: g.equip5 || '0', eq6: g.equip6 || '0'
      });
    });
    return jsonRawResponse(socket, { ok: true, data: result });
  }

  if (url === '/api/admin/fuben-logs' && data.key === ADMIN_KEY) {
    var targetId = data.userID || data.roleID || 0;
    var fp = db.players.find(pp => pp.user_id == targetId || pp.id == targetId);
    if (!fp) return jsonRawResponse(socket, { ok: false, error: 'player not found' });
    return jsonRawResponse(socket, { ok: true, player: fp.role_name, logs: fp._fubenLogs || [] });
  }

  if (url === '/api/admin/grant-equip' && data.key === ADMIN_KEY) {
    var targetId = data.userID;
    var p = db.players.find(pp => pp.user_id == targetId || pp.id == targetId);
    if (!p) return jsonRawResponse(socket, { ok: false, error: 'player not found' });
    if (!db.bagItems) db.bagItems = [];
    var codes = Object.keys(EQUIP_DATA);
    var added = 0;
    codes.forEach(function(ek) {
      var exist = db.bagItems.findIndex(b => b.player_id == p.id && b.code === ek);
      if (exist >= 0) { db.bagItems[exist].count = (db.bagItems[exist].count||1)+1; }
      else { db.bagItems.push({id:db.nextId.bagItems++, player_id:p.id, code:ek, count:1}); }
      added++;
    });
    save();
    return jsonRawResponse(socket, { ok: true, player: p.role_name, added: added, totalBag: db.bagItems.filter(b=>b.player_id==p.id).length });
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

  // 重置非管理员装备+回退进度
  if (url === '/api/admin/reset-equip-progress' && data.key === ADMIN_KEY) {
    var resetCount = 0;
    var equipRemoved = 0;
    var stagesRolled = 0;
    db.players.forEach(function(p) {
      if (p.user_id === 'gm_admin') return; // 跳过管理员
      // 1. 清除武将装备
      var gens = db.generals.filter(function(g) { return g.player_id === p.id; });
      gens.forEach(function(g) {
        var hadEquip = false;
        for (var si = 1; si <= 6; si++) {
          var key = 'equip' + si;
          if (g[key] && g[key] !== '0') { hadEquip = true; equipRemoved++; }
          g[key] = '0';
        }
      });
      // 2. 清除背包中的装备
      var oldLen = db.bagItems.length;
      db.bagItems = db.bagItems.filter(function(b) {
        if (b.player_id !== p.id) return true;
        if (b.code && b.code.indexOf('proto_4_') === 0) { equipRemoved++; return false; }
        return true;
      });
      // 3. 回退进度：移除最后3个已通关关卡
      var fin = (p.finished_stages || '').split('|').filter(Boolean);
      if (fin.length > 0) {
        fin.sort(function(a,b) { return parseInt(a) - parseInt(b); });
        var removed = Math.min(3, fin.length);
        fin = fin.slice(0, fin.length - removed);
        p.finished_stages = fin.join('|');
        stagesRolled += removed;
      }
      // 4. 清除存档文件，强制客户端从服务器重新拉取
      var savePath = '/opt/data/save_' + p.id + '.json';
      try { if (fs.existsSync(savePath)) fs.unlinkSync(savePath); } catch(e) {}
      resetCount++;
    });
    save();
    return jsonRawResponse(socket, { ok: true, resetPlayers: resetCount, equipRemoved: equipRemoved, stagesRolledBack: stagesRolled });
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
    let p = findPlayerByToken(data.token) || findPlayerByRequest(data);
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

  // 强制重载装备数据(部署后调用)
  if (url === '/api/admin/reload-equip') {
    EQUIP_DATA = {};
    loadEquipData();
    var _rc = Object.keys(EQUIP_DATA).length;
    var _ra = 0; for (var _rek in EQUIP_DATA) { if (EQUIP_DATA[_rek].slot === 3 || EQUIP_DATA[_rek].slot === 6) _ra++; }
    console.log('[Reload] EQUIP_DATA reloaded: ' + _rc + ' items, 饰品: ' + _ra);
    return jsonRawResponse(socket, { success: true, data: { equipCount: _rc, accessoryCount: _ra } });
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
    // 查找对战房间 — 按player ID匹配(最可靠), 或按peerId匹配
    var battleRoom = null;
    for (var bri = 0; bri < db.leitaiRooms.length; bri++) {
      var br = db.leitaiRooms[bri];
      if (!br._battlePeers) continue;
      // 匹配: player ID (最可靠) 或 peerId
      if (String(br._battlePlayers?.master) === String(player.id) ||
          br._battlePeers.master === session.peerId ||
          br._battlePeers.master === msg.from) {
        battleRoom = br; break;
      }
    }
    if (!battleRoom) {
      // fallback: 按fromPeerId在玩家中搜索
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
      return;
    }

    // 使用房间存储的NetGroup peerID (用于客户端P2P通信)
    var atkPeerId = battleRoom._battlePeers.attacker;
    var masterPeerId = battleRoom._battlePeers.master;
    var atkPlayerId = battleRoom._battlePlayers.attacker;
    var masterPlayerId = battleRoom._battlePlayers.master;

    var atkPlayer = db.players.find(pl => String(pl.id) === String(atkPlayerId));
    var masterPlayer = db.players.find(pl => String(pl.id) === String(masterPlayerId));

    var atkName = atkPlayer ? atkPlayer.role_name : 'Attacker';
    var atkLevel = atkPlayer ? atkPlayer.level : 1;
    var atkImage = atkPlayer ? atkPlayer.image_id : 1;
    var masterName = masterPlayer ? masterPlayer.role_name : 'Master';
    var masterLevel = masterPlayer ? masterPlayer.level : 1;
    var masterImage = masterPlayer ? masterPlayer.image_id : 1;

    // battle_start发给攻擂者
    if (atkPlayer && !atkPlayer._pollQueue) atkPlayer._pollQueue = [];
    if (atkPlayer) atkPlayer._pollQueue.push({ time: Date.now(), msg: {
      type: 'battle_start', direct: 1, opponentPID: masterPeerId,
      leftInfo: { name: atkName, level: atkLevel, image: atkImage },
      rightInfo: { name: masterName, level: masterLevel, image: masterImage }
    }});

    // battle_start发给擂主
    if (!player._pollQueue) player._pollQueue = [];
    player._pollQueue.push({ time: Date.now(), msg: {
      type: 'battle_start', direct: -1, opponentPID: atkPeerId,
      leftInfo: { name: atkName, level: atkLevel, image: atkImage },
      rightInfo: { name: masterName, level: masterLevel, image: masterImage }
    }});

    // 清理房间对战状态
    delete battleRoom._battlePeers;
    delete battleRoom._battlePlayers;
    console.log('[Leitai] battle_start sent: atk=' + atkName + '(' + atkPeerId + ') master=' + masterName + '(' + masterPeerId + ')');
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
