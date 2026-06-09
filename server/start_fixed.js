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
function createGeneral(pid, code, name, level, evo, feat, tf, k1, k1l, k2, k2l, k3, k3l) {
  const g = { id: db.nextId.generals++, player_id: pid, general_id: Math.floor(Math.random()*100000), code, name, level:level||1, evolution:evo||0, feature:feat||0, tianfu:tf||null, kezhi1:k1||0, kezhi1_level:k1l||1, kezhi2:k2||0, kezhi2_level:k2l||1, kezhi3:k3||0, kezhi3_level:k3l||1, is_deployed: 0 };
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
// 启动时修复 k1=k2=k3=0 的武将 (从 staticgeneral.xml 读取正确克制类型)
function migrateKezhi() {
  if (!fs.existsSync('/opt/staticgeneral.xml')) return;
  var xml = fs.readFileSync('/opt/staticgeneral.xml','utf8');
  var kezhiMap = {};
  var blocks = xml.split('<RECORD>');
  for (var i = 0; i < blocks.length; i++) {
    var cm = blocks[i].match(/<code>([^<]+)<\/code>/);
    var km = blocks[i].match(/<kezhi>([^<]+)<\/kezhi>/);
    if (cm && km && km[1].length > 0) kezhiMap[cm[1]] = km[1];
  }
  var fixed = 0;
  for (var j = 0; j < db.generals.length; j++) {
    var g = db.generals[j];
    if ((g.kezhi1||0) + (g.kezhi2||0) + (g.kezhi3||0) === 0) {
      var kz = kezhiMap[g.code];
      if (kz) {
        var parts = kz.split('|');
        if (parts.length >= 3) {
          g.kezhi1 = parseInt(parts[0].split(':')[0]) || 0;
          g.kezhi1_level = g.kezhi1_level || 1;
          g.kezhi2 = parseInt(parts[1].split(':')[0]) || 0;
          g.kezhi2_level = g.kezhi2_level || 1;
          g.kezhi3 = parseInt(parts[2].split(':')[0]) || 0;
          g.kezhi3_level = g.kezhi3_level || 1;
          fixed++;
        }
      }
    }
  }
  // 投石车(general_0_1) XML中kezhi为空，使用默认值
  for (var k = 0; k < db.generals.length; k++) {
    var h = db.generals[k];
    if (h.code === 'general_0_1' && (h.kezhi1||0) + (h.kezhi2||0) + (h.kezhi3||0) === 0) {
      h.kezhi1 = 3; h.kezhi2 = 8; h.kezhi3 = 9;
      h.kezhi1_level = h.kezhi1_level || 1; h.kezhi2_level = h.kezhi2_level || 1; h.kezhi3_level = h.kezhi3_level || 1;
      fixed++;
    }
  }
  if (fixed > 0) { console.log('[Migrate] Fixed ' + fixed + ' generals kezhi'); }
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
initLeitai();
createTestAccounts();
migrateKezhi();  // 启动时自动修复零值克制数据
save();

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
    // 如果类型全为0(旧数据),返回空字符串让客户端用XML默认值
    kezhi: ((g.kezhi1||0)+(g.kezhi2||0)+(g.kezhi3||0) === 0)
      ? ''
      : (g.kezhi1||0)+':'+(g.kezhi1_level||1)+'|'+(g.kezhi2||0)+':'+(g.kezhi2_level||1)+'|'+(g.kezhi3||0)+':'+(g.kezhi3_level||1),
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
  try { jsonData = JSON.parse(body); } catch(e) {}

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

  // 客户端版本号
  if (url === '/api/version') {
    return jsonRawResponse(socket, { success: true, version: '2.1.5', downloadUrl: 'http://47.96.41.243:3000/client/main.swf' });
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
      console.log('[Login] ' + p.role_name + ' — 武将:' + allArmy.length + ' 背包物品:' + bagModel.length + ' playerID=' + p.id + ' type=' + typeof p.id);
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
      data: { token: p.token, dianka: 99999999, armyModel: army, bagModel: [],
        process: { history: '', finished: '' }, roleModel: makeRoleModel(p),
      }
    });
  }

  // Player list
  if (url === '/api/auth/players') {
    return jsonRawResponse(socket, { success: true, data: db.players.map(p => ({ userID: p.user_id, roleName: p.role_name, level: p.level, imageID: p.image_id, money: p.money })) });
  }

  // Fight result
  if (url === '/api/game/fight-result') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '玩家不存在' });
    p.money += 100 + data.part*50 + data.level*20;
    p.exploit += 50 + data.part*20 + data.level*10;
    p.reverence += 30 + data.part*10 + data.level*5;
    const stageId = data.part + '_' + data.level;
    const fin = (p.finished_stages || '').split('|').filter(Boolean);
    if (!fin.includes(stageId)) fin.push(stageId);
    p.finished_stages = fin.join('|');
    p.level = Math.max(p.level, data.level);
    save();
    return jsonRawResponse(socket, { success: true, stamp: data.stamp, head: '10011', data: { m: p.money, e: p.exploit, r: p.reverence, part: data.part, level: data.level, finished: p.finished_stages, money: 100+data.part*50+data.level*20, exploit: 50+data.part*20+data.level*10, reverence: 30+data.part*10+data.level*5 } });
  }

  // ============ 武将招募 ============
  if (url === '/api/general/recruit') {
    const p = findPlayerByRequest(data);
    if (!p) return jsonRawResponse(socket, { success: false, message: '请先登录' });

    const headCode = parseInt(data.head) || 0;
    let costMoney = 0, costReverence = 0, costDianka = 0;
    let successRate = 0.6;

    if (headCode === 10001) { // 普通招募
      costMoney = 10000; costReverence = 1000; successRate = 0.65;
    } else if (headCode === 10002) { // 求贤招募
      costDianka = 100; successRate = 0.85;
    } else if (headCode === 10003) { // 点卡招募
      costDianka = 300; successRate = 1.0;
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
      generalData = { id: g.general_id, code: g.code, level: 1, evolution: 0, feature: 0, kezhi: (g.kezhi1||0)+':1|'+(g.kezhi2||0)+':1|'+(g.kezhi3||0)+':1', genius: null };
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

    // 详细的购买处理：扣除金钱，返回最新资源
    const itemPrice = parseInt(data.price) || 0;
    const itemMoney = parseInt(data.money) || 0;
    const itemDianka = parseInt(data.dianka) || 0;
    const itemExploit = parseInt(data.exploit) || 0;
    const itemReverence = parseInt(data.reverence) || 0;

    var payType = parseInt(data.payType) || 0;
    console.log('[Shop] 收到购买请求: shopID=' + data.shopID + ' code=' + data.code + ' count=' + data.count + ' payType=' + payType + ' price=' + itemPrice + ' money=' + itemMoney);
    console.log('[Shop] 玩家余额: money=' + p.money + ' dianka=' + p.dianka + ' exploit=' + p.exploit + ' reverence=' + p.reverence);

    if (p.money < itemMoney || p.dianka < itemDianka || p.exploit < itemExploit || p.reverence < itemReverence) {
      console.log('[Shop] 资源不足，拒绝购买');
      return jsonRawResponse(socket, { success: false, message: '资源不足' });
    }

    p.money -= itemMoney; p.dianka -= itemDianka; p.exploit -= itemExploit; p.reverence -= itemReverence;
    console.log('[Shop] 扣费后余额: money=' + p.money + ' dianka=' + p.dianka + ' exploit=' + p.exploit + ' reverence=' + p.reverence);

    // 创建/堆叠背包物品 - 按 code 查找已有物品进行堆叠
    const itemCode = data.code || 'item_0';
    const itemCount = parseInt(data.count) || 1;
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
        respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution, feature: g.feature||0, genius: g.tianfu||null, kezhi: (g.kezhi1||0)+':'+(g.kezhi1_level||1)+'|'+(g.kezhi2||0)+':'+(g.kezhi2_level||1)+'|'+(g.kezhi3||0)+':'+(g.kezhi3_level||1) };
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
        if (ki === 0) { g.kezhi1_level = (g.kezhi1_level || 1) + 1; respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: (g.kezhi1||0)+':'+(g.kezhi1_level||1)+'|'+(g.kezhi2||0)+':'+(g.kezhi2_level||1)+'|'+(g.kezhi3||0)+':'+(g.kezhi3_level||1) }; respData.index = ki; }
        else if (ki === 1) { g.kezhi2_level = (g.kezhi2_level || 1) + 1; respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: (g.kezhi1||0)+':'+(g.kezhi1_level||1)+'|'+(g.kezhi2||0)+':'+(g.kezhi2_level||1)+'|'+(g.kezhi3||0)+':'+(g.kezhi3_level||1) }; respData.index = ki; }
        else if (ki === 2) { g.kezhi3_level = (g.kezhi3_level || 1) + 1; respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu||null, kezhi: (g.kezhi1||0)+':'+(g.kezhi1_level||1)+'|'+(g.kezhi2||0)+':'+(g.kezhi2_level||1)+'|'+(g.kezhi3||0)+':'+(g.kezhi3_level||1) }; respData.index = ki; }
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
        respData.general = { id: g.general_id, code: g.code, level: g.level, evolution: g.evolution||0, feature: g.feature||0, genius: g.tianfu, kezhi: (g.kezhi1||0)+':'+(g.kezhi1_level||1)+'|'+(g.kezhi2||0)+':'+(g.kezhi2_level||1)+'|'+(g.kezhi3||0)+':'+(g.kezhi3_level||1) };
        console.log('[Tianfu] ' + p.role_name + ' ' + g.name + (isReroll?' 重洗→':' 激活→') + g.tianfu + ' dianka:' + p.dianka);
      }
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

  // Crossdomain
  if (url === '/crossdomain.xml') {
    const xml = '<?xml version="1.0"?><cross-domain-policy><allow-access-from domain="*"/></cross-domain-policy>';
    sendRawHttpResponse(socket, 200, 'OK', {
      'Content-Type': 'text/xml',
      'Content-Length': String(Buffer.byteLength(xml)),
      'Connection': 'close',
    }, xml);
    return;
  }

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
    return jsonRawResponse(socket, { success: true, uptime: Math.floor(uptime), memoryMB: Math.floor(mem.heapUsed/1024/1024), version: '2.1.5' });
  }

  // 客户端文件下载
  if (url.startsWith('/client/')) {
    var clientFile = url.substring(8); // remove /client/
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
        var mimeMap = { zip: 'application/zip', swf: 'application/x-shockwave-flash', exe: 'application/octet-stream', txt: 'text/plain', pdf: 'application/pdf', docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' };
        var mime = mimeMap[ext] || 'application/octet-stream';
        sendRawHttpResponse(socket, 200, 'OK', {
          'Content-Type': mime,
          'Content-Length': String(clientData.length),
          'Connection': 'close',
          'Content-Disposition': 'attachment; filename="' + clientFile + '"'
        }, clientData);
        return;
      }
    } catch(e) {}
    sendRawHttpResponse(socket, 404, 'Not Found', {}, 'Not Found');
    return;
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

console.log('Ready: HTTP ' + HTTP_PORT + ' + TCP ' + TCP_PORT + ' (raw TCP)');
