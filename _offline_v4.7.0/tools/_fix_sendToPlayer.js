var fs = require('fs');
var src = fs.readFileSync('server/start_fixed.js', 'utf8');

var oldFunc = /function sendToPlayer\(p, msg\) \{[\s\S]*?^  \}/m;
var newFunc = `function sendToPlayer(p, msg) {
  if (!p) return false;
  // poll: 转义方括号(防HttpPollConnection JSON截断)
  var pollMsg = msg;
  if (msg.text && typeof msg.text === 'string') {
    pollMsg = Object.assign({}, msg, { text: msg.text.replace(/\\[/g, '&#91;').replace(/\\]/g, '&#93;') });
  }
  if (msg.plain && typeof msg.plain === 'string') {
    pollMsg = Object.assign({}, pollMsg, { plain: msg.plain.replace(/\\[/g, '&#91;').replace(/\\]/g, '&#93;') });
  }
  if (!p._pollQueue) p._pollQueue = [];
  p._pollQueue.push({ time: Date.now(), msg: pollMsg });
  // TCP: 原始消息(不转义) — AIR客户端不需要
  var sessions = Array.from(tcpSessions.values());
  for (var si = 0; si < sessions.length; si++) {
    if (String(sessions[si].playerId) === String(p.id)) {
      tcpSend(sessions[si], msg);
    }
  }
  return true;
}`;

src = src.replace(oldFunc, newFunc);
fs.writeFileSync('server/start_fixed.js', src);
console.log('Replaced sendToPlayer');
