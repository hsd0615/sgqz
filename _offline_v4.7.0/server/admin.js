// 远程管理微服务 - 监听 3002 端口
const net = require('net');
const { exec } = require('child_process');
const ADMIN_KEY = 'sanguoq_admin_2024';

function jsonResponse(socket, data) {
  const body = JSON.stringify(data);
  socket.end('HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nContent-Length: ' + Buffer.byteLength(body) + '\r\nAccess-Control-Allow-Origin: *\r\nConnection: close\r\n\r\n' + body);
}

net.createServer(socket => {
  socket.on('data', raw => {
    try {
      const str = raw.toString();
      const bodyStart = str.indexOf('\r\n\r\n');
      const body = bodyStart > 0 ? JSON.parse(str.substring(bodyStart + 4)) : {};
      const url = str.split(' ')[1] || '';
      const key = body.key || '';

      if (key !== ADMIN_KEY) {
        return jsonResponse(socket, { ok: false, error: 'unauthorized' });
      }

      if (url === '/exec' && body.cmd) {
        exec(body.cmd, { timeout: 15000 }, (err, stdout, stderr) => {
          jsonResponse(socket, { ok: !err, stdout: stdout||'', stderr: stderr||'' });
        });
      } else if (url === '/crontab') {
        exec('echo "@reboot cd /opt && node start_fixed.js" | crontab - && crontab -l', (err, stdout) => {
          jsonResponse(socket, { ok: !err, output: stdout||'' });
        });
      } else if (url === '/ping') {
        jsonResponse(socket, { ok: true, time: new Date().toISOString() });
      } else {
        jsonResponse(socket, { ok: false, error: 'unknown command' });
      }
    } catch(e) {
      jsonResponse(socket, { ok: false, error: e.message });
    }
  });
}).listen(3002, () => console.log('Admin API on :3002'));
