// 根治版服务器 — 原始Node HTTP, 无Express/chunked/keepalive
// Flash URLLoader 对 Express 的分块响应处理有问题
// 使用 Content-Length + Connection:close 一次性发送完整响应

const http = require('http');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

const PORT = 3000;
const DATA_FILE = path.join(__dirname, 'data', 'sanguo.json');

// ============ 简易JSON数据库 ============
let db = { players: [], generals: [], bagItems: [], leitaiRooms: [], nextId: { players: 1, generals: 1, bagItems: 1 } };
if (fs.existsSync(DATA_FILE)) {
  try { db = JSON.parse(fs.readFileSync(DATA_FILE, 'utf-8')); } catch(e) {}
}
function save() { fs.writeFileSync(DATA_FILE, JSON.stringify(db)); }
function findPlayer(uid) { return db.players.find(p => String(p.user_id) === String(uid)); }
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
  for (const lv of levels) for (let t=0;t<6;t++) db.leitaiRooms.push({r_id:lv.lv*100+t,room_level:lv.lv,room_status:0,room_type:(t%3)+1,room_price:lv.p[t],rongyu_pool:0,battle_count:0});
  save();
}
function createTestAccounts() {
  if (findPlayer('gm_admin')) return;
  const p1 = createPlayer('gm_admin', 'GM管理员', 1, '4399', 'admin123');
  p1.level = 220; p1.money = 99999999; p1.dianka = 999999; p1.exploit = 99999999; p1.reverence = 99999999; p1.rongyu = 99999;
  p1.finished_stages = Array.from({length:30},(_,i)=>i+1).join('|');
  p1.history = '1,1,1,1,1,1,1,1,1,1';
  save();
  const supers = [
    ['general_9_18','吕布','6:1|1:1|8:1'],['general_9_20','马超','6:1|1:1|8:1'],['general_9_16','夏侯惇','6:1|1:1|8:1'],
    ['general_7_19','赵云','5:1|4:1|7:1'],['general_7_14','张飞','5:1|4:1|7:1'],['general_3_13','关羽','2:1|1:1|6:1'],
    ['general_1_15','黄忠','5:1|7:1|9:1'],['general_1_23','姜维','5:1|7:1|9:1'],['general_2_11','貂蝉','5:1|4:1|7:1'],
    ['general_6_15','魏延','6:1|1:1|8:1'],['general_0_1','投石车','3:1|8:1|9:1'],
  ];
  for (const [code, name, kezhi] of supers) {
    const kp = kezhi.split('|');
    createGeneral(p1.id, code, name, 220, 10, 1, 'tf_20', parseInt(kp[0].split(':')[0]),10,parseInt(kp[1].split(':')[0]),10,parseInt(kp[2].split(':')[0]),10);
  }
  const p2 = createPlayer('test_pro', '测试高手', 1, '4399', 'pro123');
  p2.level=100; p2.money=500000; p2.dianka=50000; p2.exploit=500000; p2.reverence=500000;
  p2.finished_stages = Array.from({length:40},(_,i)=>i+1).join('|');
  save();
  const p3 = createPlayer('new_player', '新兵报到', 1, '4399', 'new123');
  console.log('[Init] Test accounts ready: gm_admin, test_pro, new_player');
}

// ============ 初始化 ============
if (!fs.existsSync(path.dirname(DATA_FILE))) fs.mkdirSync(path.dirname(DATA_FILE), { recursive: true });
initLeitai();
createTestAccounts();

// ============ HTTP响应辅助 ============
// Flash URLLoader 兼容: Content-Length + Connection:close
// 关键修复: Node v22 中 keepAliveTimeout=0 会用 RST 关连接导致 Flash 收不到数据
// 改用默认 keepAlive (5s) + 响应后 graceful shutdown
function jsonResponse(res, data) {
  const body = JSON.stringify(data);
  const bodyLen = Buffer.byteLength(body, 'utf-8');
  res.shouldKeepAlive = false;  // 明确禁止 keep-alive
  res.writeHead(200, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': bodyLen,
    'Connection': 'close',
    'Access-Control-Allow-Origin': '*',
  });
  // 在 end 回调中 graceful close socket (FIN 而非 RST)
  res.end(body, () => {
    // 响应发送完毕后，给 Flash 一点时间读取
    const sock = res.socket;
    if (sock && !sock.destroyed) {
      // 延迟 50ms 确保数据到达客户端
      setTimeout(() => {
        try { sock.end(); } catch(e) {}
      }, 50);
    }
  });
}

// 请求日志
function logRequest(req, body) {
  const short = body ? body.substring(0, 200) : '';
  console.log(`[HTTP] ${req.method} ${req.url} body=${short}  from=${req.socket.remoteAddress}:${req.socket.remotePort}`);
}

function makeRoleModel(p) {
  return {
    roleID: p.id, agent: p.agent, userID: p.user_id, userName: '', roleName: p.role_name,
    imageID: p.image_id, level: p.level, exp: 0, money: p.money, dianka: p.dianka,
    exploit: p.exploit, reverence: p.reverence, rongyu: p.rongyu,
    winCount: p.win_count, lostCount: p.lost_count, ranking: 0, score: 0, choose: '',
    finished: p.finished_stages, history: p.history, loginServer: p.login_server,
  };
}

function makeArmyModel(playerId) {
  return findGenerals(playerId).map(g => ({
    id: g.general_id, code: g.code, genius: g.tianfu||null, level: g.level,
    feature: g.feature, evolution: g.evolution,
    kezhi: g.kezhi1+'|'+g.kezhi2+'|'+g.kezhi3,
  }));
}

// ============ 服务器 ============
const server = http.createServer((req, res) => {
  // CORS
  if (req.method === 'OPTIONS') {
    res.writeHead(200, { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Methods': 'GET,POST', 'Access-Control-Allow-Headers': 'Content-Type' });
    res.end();
    return;
  }

  let body = '';
  req.on('data', c => body += c);
  req.on('end', () => {
    logRequest(req, body);
    const url = req.url.split('?')[0];
    let data = {};
    try { data = JSON.parse(body); } catch(e) {}

    // /api/health
    if (url === '/api/health' || req.method === 'GET' && url === '/api/health') {
      return jsonResponse(res, { status: 'ok', timestamp: Date.now() });
    }

    // /api/auth/login
    if (url === '/api/auth/login') {
      const p = findPlayerByPwd(data.userID, data.password);
      if (p) {
        p.token = uuidv4().replace(/-/g,'');
        save();
        return jsonResponse(res, {
          success: true, stamp: data.stamp, head: '9999',
          data: { flag: 1, token: p.token, currentTime: Date.now(), dianka: p.dianka,
            armyModel: makeArmyModel(p.id).slice(0, 2), bagModel: [],
            process: { history: p.history||'', finished: p.finished_stages||'' },
            roleModel: makeRoleModel(p),
          }
        });
      }
      const exists = findPlayer(data.userID);
      return jsonResponse(res, { success: false, stamp: data.stamp, head: '9999', message: exists ? '密码错误' : '账号不存在，请先注册' });
    }

    // /api/auth/register
    if (url === '/api/auth/register') {
      if (findPlayer(data.userID)) return jsonResponse(res, { success: false, message: '该账号已创建过角色' });
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
      return jsonResponse(res, {
        success: true, stamp: data.stamp, head: '10000',
        data: { token: p.token, dianka: 99999999, armyModel: army, bagModel: [],
          process: { history: '', finished: '' }, roleModel: makeRoleModel(p),
        }
      });
    }

    // /api/auth/players
    if (url === '/api/auth/players') {
      return jsonResponse(res, { success: true, data: db.players.map(p => ({ userID: p.user_id, roleName: p.role_name, level: p.level, imageID: p.image_id, money: p.money })) });
    }

    // /api/game/fight-result
    if (url === '/api/game/fight-result') {
      const p = db.players.find(p => String(p.id) === String(data.roleID));
      if (!p) return jsonResponse(res, { success: false, message: '玩家不存在' });
      p.money += 100 + data.part*50 + data.level*20;
      p.exploit += 50 + data.part*20 + data.level*10;
      p.reverence += 30 + data.part*10 + data.level*5;
      const stageId = `${data.part}_${data.level}`;
      const fin = (p.finished_stages || '').split('|').filter(Boolean);
      if (!fin.includes(stageId)) fin.push(stageId);
      p.finished_stages = fin.join('|');
      p.level = Math.max(p.level, data.level);
      save();
      return jsonResponse(res, { success: true, stamp: data.stamp, head: '10011', data: { m: p.money, e: p.exploit, r: p.reverence, part: data.part, level: data.level, finished: p.finished_stages, money: 100+data.part*50+data.level*20, exploit: 50+data.part*20+data.level*10, reverence: 30+data.part*10+data.level*5 } });
    }

    // /api/shop/buy
    if (url === '/api/shop/buy') {
      return jsonResponse(res, { success: true, stamp: data.stamp, head: '10010', data: { money: 5000, dianka: 0, exploit: 0, reverence: 0 } });
    }

    // /api/general/* (recruit/upgrade/evolve etc.)
    if (url.startsWith('/api/general/')) {
      return jsonResponse(res, { success: true, stamp: data.stamp, head: data.head, data: { money: 5000, exploit: 5000 } });
    }

    // /api/leitai/list
    if (url === '/api/leitai/list') {
      return jsonResponse(res, { success: true, data: { rongyu: 1000, ranking: 0, leitai: db.leitaiRooms, paihang: [] } });
    }

    // /api/fuben/*
    if (url.startsWith('/api/fuben/')) {
      return jsonResponse(res, { success: true, stamp: data.stamp, head: String(data.head||''), data: {} });
    }

    // /api/misc/*
    if (url.startsWith('/api/misc/')) {
      return jsonResponse(res, { success: true, stamp: data.stamp, head: String(data.head||''), data: {} });
    }

    // crossdomain.xml
    if (url === '/crossdomain.xml') {
      res.writeHead(200, { 'Content-Type': 'text/xml' });
      return res.end('<?xml version="1.0"?><cross-domain-policy><allow-access-from domain="*"/></cross-domain-policy>');
    }

    // Default
    return jsonResponse(res, { success: false, message: 'Unknown: ' + url });
  });
});

// Node v22: 保留默认 keepAliveTimeout (5s)，让连接优雅关闭 (FIN)
// keepAliveTimeout=0 会导致 socket.destroy() → RST 包，Flash 收不到数据!
server.keepAliveTimeout = 5000;
server.requestTimeout = 0;

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Fixed server on ${PORT} (raw HTTP, no Express/chunking)`);
});

// ============ TCP 服务器 (port 3001) - ChatManager 实时通信 ============
const net = require('net');
const tcpSessions = new Map();     // peerID -> { socket, peerId, playerId, roleName, rooms, farPeerId, buffer, expectedLen }
const tcpRooms = new Map();        // roomName -> Set<peerID>

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
      console.log(`[TCP] Auth: ${session.roleName} (${session.peerId})`);
      break;
    }
    case 'join_room': {
      const room = msg.room;
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
      if (room) {
        for (const pid of room) {
          if (pid !== session.peerId) {
            const other = tcpSessions.get(pid);
            if (other) tcpSend(other, { type: 'chat', room: msg.room, from: session.peerId, fromName: session.roleName, text: msg.text || msg.data });
          }
        }
      }
      break;
    }
    case 'battle_request': {
      const target = tcpSessions.get(msg.targetPeerId);
      if (!target) { tcpSend(session, { type: 'battle_request_fail', reason: '对手不在线' }); break; }
      if (target.farPeerId) { tcpSend(session, { type: 'battle_request_fail', reason: '对手战斗中' }); break; }
      session.farPeerId = msg.targetPeerId;
      tcpSend(target, { type: 'battle_request', from: session.peerId, fromName: session.roleName, server: msg.server });
      break;
    }
    case 'battle_accept': {
      const opp = tcpSessions.get(msg.fromPeerId);
      if (!opp) { tcpSend(session, { type: 'error', message: '对手离线' }); break; }
      session.farPeerId = msg.fromPeerId;
      opp.farPeerId = session.peerId;
      tcpSend(session, { type: 'battle_start', direct: 1, opponentPID: opp.peerId, leftInfo: { name: session.roleName, level: 1, image: 1 }, rightInfo: { name: opp.roleName, level: 1, image: 1 } });
      tcpSend(opp, { type: 'battle_start', direct: -1, opponentPID: session.peerId, server: true, leftInfo: { name: opp.roleName, level: 1, image: 1 }, rightInfo: { name: session.roleName, level: 1, image: 1 } });
      break;
    }
    case 'battle_action': {
      const opp = session.farPeerId ? tcpSessions.get(session.farPeerId) : null;
      if (opp) tcpSend(opp, { type: 'battle_action', from: session.peerId, data: msg.data });
      break;
    }
    case 'battle_end':
      if (session.farPeerId) { const o = tcpSessions.get(session.farPeerId); if (o) o.farPeerId = null; session.farPeerId = null; }
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
      try { tcpHandleMessage(session, JSON.parse(payload)); } catch(e) {}
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
tcpServer.listen(3001, '0.0.0.0', () => console.log('TCP server on 3001 (ChatManager)'));
console.log('Ready: HTTP 3000 + TCP 3001');
