// 给 start_fixed.js 添加远程管理端点，并安装 crontab 自启
const fs = require('fs');
const { exec } = require('child_process');

let code = fs.readFileSync('/opt/start_fixed.js', 'utf8');

// 1. 添加 child_process 引入
code = code.replace(
  "const net = require('net');",
  "const net = require('net');\nconst { exec } = require('child_process');"
);

// 2. 在 "// Crossdomain" 前插入管理路由
const adminRoutes = `  // ============ 远程管理 ============
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

  // Crossdomain`;

code = code.replace('  // Crossdomain', adminRoutes);

fs.writeFileSync('/opt/start_fixed.js', code);
console.log('Patched OK');

// 3. 重启服务
exec('pkill node && sleep 1 && cd /opt && nohup node start_fixed.js > server.log 2>&1 &', (e, o) => {
  console.log('Restart:', e ? e.message : 'OK', o||'');
  // 4. 安装 crontab
  exec('echo "@reboot cd /opt && node start_fixed.js" | crontab - && crontab -l', (e2, o2) => {
    console.log('Crontab:', e2 ? e2.message : 'OK');
    console.log(o2||'');
  });
});
