#!/usr/bin/env node
/**
 * 三国Q战 - 云端一键部署
 *
 * 用法:
 *   node tools/cloud-deploy.js --full       # 编译SWF+完整部署(改.as源码后必须用这个)
 *   node tools/cloud-deploy.js              # 部署server+XML(没改.as时用)
 *   node tools/cloud-deploy.js --server     # 仅服务端代码
 *   node tools/cloud-deploy.js --xml        # 仅XML数据文件
 *   node tools/cloud-deploy.js --restart    # 仅重启
 *   node tools/cloud-deploy.js --status     # 查看状态
 *   node tools/cloud-deploy.js --gen-html   # 仅生成武将数值HTML
 */

const fs = require('fs');
const path = require('path');
const http = require('http');
const { execSync } = require('child_process');

const BASE = path.dirname(__dirname);
const CONFIG_FILE = path.join(__dirname, 'cloud-config.json');
const ADMIN_KEY = 'sanguoq_admin_2024';
const FLEX_SDK = 'D:/BaiduNetdiskDownload/flex_home';

function loadConfig() {
  if (!fs.existsSync(CONFIG_FILE)) {
    console.error('配置文件不存在: tools/cloud-config.json');
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf-8'));
}

function apiPost(host, port, apiPath, data) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify(data);
    const req = http.request({
      hostname: host, port: port,
      path: apiPath, method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) },
      timeout: 15000
    }, (res) => {
      let d = ''; res.on('data', c => d += c);
      res.on('end', () => {
        try { resolve(JSON.parse(d)); } catch(e) { resolve(d); }
      });
    });
    req.on('error', e => reject(e));
    req.on('timeout', () => { req.destroy(); reject(new Error('timeout')); });
    req.write(payload);
    req.end();
  });
}

async function execRemote(host, port, cmd, label) {
  process.stdout.write('  ' + (label || cmd.substring(0, 50)) + '... ');
  try {
    const r = await apiPost(host, port, '/api/admin/exec', { key: ADMIN_KEY, cmd: cmd });
    if (r && r.ok) {
      console.log('✓');
      if (r.stdout && r.stdout.trim()) console.log('    ' + r.stdout.trim().replace(/\n/g, '\n    '));
      return r;
    }
    console.log('✗ ' + JSON.stringify(r).substring(0, 100));
    return null;
  } catch(e) {
    console.log('✗ ' + e.message);
    return null;
  }
}

async function uploadFile(host, port, localPath, remoteName, label) {
  const content = fs.readFileSync(path.join(BASE, localPath), 'utf-8');
  const b64 = Buffer.from(content, 'utf-8').toString('base64');
  const remoteFile = '/opt/' + remoteName;
  const sizeKB = (content.length / 1024).toFixed(1);

  console.log(`\n[${label || remoteName}] ${sizeKB}KB → ${remoteFile}`);

  if (b64.length < 50000) {
    // Small file - single command
    const cmd = `echo '${b64}' | base64 -d > ${remoteFile} && ls -la ${remoteFile} && echo OK`;
    return await execRemote(host, port, cmd, 'Upload');
  }

  // Large file - chunked
  const CHUNK = 40000;
  const totalChunks = Math.ceil(b64.length / CHUNK);
  console.log(`  分${totalChunks}块上传...`);
  const tmpFile = '/tmp/_upload_' + remoteName.replace(/[^a-zA-Z0-9]/g, '_');

  // Init
  await execRemote(host, port, `> ${tmpFile}`, 'Init');

  for (let i = 0; i < totalChunks; i++) {
    const chunk = b64.substring(i * CHUNK, (i + 1) * CHUNK);
    const r = await execRemote(host, port,
      `echo '${chunk}' >> ${tmpFile} && echo OK`, `Chunk ${i+1}/${totalChunks}`);
    if (!r) {
      console.log(`  ✗ 第${i+1}块失败`);
      return false;
    }
  }

  // Decode
  return await execRemote(host, port,
    `base64 -d ${tmpFile} > ${remoteFile} && ls -la ${remoteFile} && rm ${tmpFile} && echo DEPLOY_OK`,
    'Decode');
}

async function restart(host, port) {
  console.log('\n[重启服务]');
  // Write restart script
  const restartScript = `#!/bin/bash
sleep 2
cd /opt
pkill -f "node start_fixed" 2>/dev/null
sleep 2
nohup node start_fixed.js > server.log 2>&1 &
echo "Server PID: $(pgrep -f 'node start_fixed')"`;

  const scriptB64 = Buffer.from(restartScript, 'utf-8').toString('base64');
  const cmd = `echo '${scriptB64}' | base64 -d > /tmp/restart.sh && chmod +x /tmp/restart.sh && nohup bash /tmp/restart.sh > /tmp/restart.log 2>&1 & echo "Restart triggered"`;
  return await execRemote(host, port, cmd, 'Trigger restart');
}

async function checkStatus(host, port) {
  console.log('服务端状态:');
  try {
    const v = await apiPost(host, port, '/api/version', {});
    console.log('  版本: v' + (v.version || '?'));
    const h = await apiPost(host, port, '/api/health', {});
    console.log('  状态: ' + (h.status || '?'));
    const oc = await apiPost(host, port, '/api/online-count', {});
    console.log('  在线: ' + (oc.count || '?') + ' 人');
  } catch(e) {
    console.log('  离线: ' + e.message);
  }
}

async function genHTML() {
  console.log('生成武将数值HTML...');
  const { execSync } = require('child_process');
  try {
    const r = execSync('node tools/gen_general_table.js', { cwd: BASE, encoding: 'utf-8', timeout: 30000 });
    console.log(r.trim());
  } catch(e) {
    console.log('HTML生成失败: ' + e.message);
  }
}

async function compileAndUploadSWF(host, port) {
  console.log('\n[编译SWF]');
  const cmd = `java -jar ${FLEX_SDK}/lib/mxmlc.jar +flexlib=${FLEX_SDK}/frameworks -compiler.source-path=. -default-size=770,500 -target-player=32.0 -static-link-runtime-shared-libraries=true -external-library-path=air_stubs.swc -- game/Sanguo4399.as`;
  try {
    const out = execSync(cmd, { cwd: BASE, encoding: 'utf-8', timeout: 120000, stdio: ['pipe','pipe','pipe'] });
    console.log('  ' + out.replace(/\n/g, '\n  ').substring(0, 300));
  } catch(e) {
    console.log('  编译错误: ' + (e.stderr || e.message).substring(0, 300));
    return false;
  }

  // Copy to main.swf
  const swfSrc = path.join(BASE, 'game', 'Sanguo4399.swf');
  const swfDst = path.join(BASE, 'main.swf');
  if (!fs.existsSync(swfSrc)) { console.log('  SWF未生成'); return false; }
  fs.copyFileSync(swfSrc, swfDst);
  const size = fs.statSync(swfDst).size;
  console.log('  main.swf: ' + (size/1024).toFixed(0) + 'KB');

  // Upload
  console.log('\n[上传SWF]');
  const swf = fs.readFileSync(swfDst);
  const b64 = swf.toString('base64');
  const chunks = [];
  for (let i = 0; i < b64.length; i += 40000) chunks.push(b64.substring(i, i + 40000));

  await execRemote(host, port, '> /tmp/swf.b64', 'Init');
  for (let i = 0; i < chunks.length; i++) {
    const r = await execRemote(host, port, `echo '${chunks[i]}' >> /tmp/swf.b64`, `Chunk ${i+1}/${chunks.length}`);
    if (!r) { console.log('  ✗ 上传失败'); return false; }
  }
  const r = await execRemote(host, port,
    'base64 -d /tmp/swf.b64 > /opt/client/main.swf && cp /opt/client/main.swf /opt/client/sanguo_web.swf && ls -la /opt/client/main.swf /opt/client/sanguo_web.swf && rm /tmp/swf.b64 && echo SWF_OK', 'Decode');
  if (r && r.stdout && r.stdout.includes('SWF_OK')) {
    console.log('  ✓ SWF已部署');
    return true;
  }
  console.log('  ✗ SWF部署失败');
  return false;
}

async function main() {
  const args = process.argv.slice(2);
  const config = loadConfig();
  const host = config.serverIp;
  const port = config.serverPort;

  console.log('═══════════════════════════════════');
  console.log('  三国Q战 云端部署 v' + (config.version || '?'));
  console.log('  ' + host + ':' + port);
  console.log('═══════════════════════════════════\n');

  if (args.includes('--status')) {
    await checkStatus(host, port);
    return;
  }

  if (args.includes('--gen-html')) {
    await genHTML();
    return;
  }

  if (args.includes('--full')) {
    await compileAndUploadSWF(host, port);
  }

  const restartOnly = args.includes('--restart');
  const serverOnly = args.includes('--server');
  const xmlOnly = args.includes('--xml');

  try {
    if (!restartOnly && !xmlOnly) {
      await uploadFile(host, port, 'server/start_fixed.js', 'start_fixed.js', 'Server');
    }

    if (!restartOnly && !serverOnly) {
      for (const [local, remote] of Object.entries(config.files || {})) {
        if (local === 'server/start_fixed.js') continue;
        if (!fs.existsSync(path.join(BASE, local))) {
          console.log('[跳过] ' + local);
          continue;
        }
        await uploadFile(host, port, local, remote, path.basename(remote));
        await new Promise(r => setTimeout(r, 1000));
      }
    }

    // Sync XML to /opt/client/ for client downloads
    console.log('\n[同步客户端文件]');
    const syncCmd = 'cp /opt/*.xml /opt/client/ && echo SYNC_OK';
    const syncResult = await execRemote(host, port, syncCmd, 'Sync XML to /opt/client/');
    if (syncResult && syncResult.stdout && syncResult.stdout.includes('SYNC_OK')) {
      console.log('  ✓ XML已同步到 /opt/client/');
    }

    if (!args.includes('--no-restart')) {
      await restart(host, port);
      console.log('\n等待服务端重启...');
      await new Promise(r => setTimeout(r, 8000));
    }

    await checkStatus(host, port);

    // Auto-generate HTML
    await genHTML();

    console.log('\n═══════════════════════════════════');
    console.log('  部署完成!');
    console.log('═══════════════════════════════════');
  } catch(e) {
    console.error('\n部署失败: ' + e.message);
    process.exit(1);
  }
}

main();
