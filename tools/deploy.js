#!/usr/bin/env node
const https = require('http');
const fs = require('fs');
const path = require('path');

const SERVER = '47.96.41.243';
const PORT = 3000;
const BASE = path.dirname(__dirname);

function deployFile(localPath, remotePath, label) {
  const content = fs.readFileSync(localPath, 'utf-8');
  const b64 = Buffer.from(content, 'utf-8').toString('base64');

  console.log(`[${label}] Uploading ${localPath} (${content.length}B)`);

  const payload = JSON.stringify({
    secret: 'sanguoq_deploy_2024',
    code: b64
  });

  return new Promise((resolve, reject) => {
    const req = https.request({
      hostname: SERVER,
      port: PORT,
      path: '/api/admin/deploy',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
      },
      timeout: 30000
    }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const resp = JSON.parse(data);
          if (resp.success) {
            console.log(`[${label}] ✓ ${resp.message} (backup: ${resp.backup || 'N/A'})`);
            resolve(true);
          } else {
            console.log(`[${label}] ✗ ${resp.message}`);
            reject(new Error(resp.message));
          }
        } catch(e) {
          console.log(`[${label}] Response: ${data.substring(0, 200)}`);
          resolve(true); // restart killed the connection, assume success
        }
      });
    });

    req.on('error', (e) => {
      // After deploy, server restarts which may cause ECONNRESET - that's OK
      if (e.code === 'ECONNRESET') {
        console.log(`[${label}] Server restarting (connection reset - expected)`);
        resolve(true);
      } else {
        console.log(`[${label}] Error: ${e.message}`);
        reject(e);
      }
    });

    req.on('timeout', () => {
      req.destroy();
      console.log(`[${label}] Timeout (server may be restarting - OK)`);
      resolve(true);
    });

    req.write(payload);
    req.end();
  });
}

async function main() {
  console.log('=== 三国Q战 v2.5.0 云端部署 ===\n');

  // 1. Deploy server code
  try {
    await deployFile(
      path.join(BASE, 'server', 'start_fixed.js'),
      '/opt/start_fixed.js',
      'Server'
    );
  } catch(e) {
    console.log('Server deploy issue: ' + e.message);
  }

  // Wait for server to restart
  console.log('\nWaiting 5s for server restart...');
  await new Promise(r => setTimeout(r, 5000));

  // 2. Upload staticxishu.xml to /opt/ (via base64 exec)
  console.log('\n[XML] Uploading staticxishu.xml...');
  const xmlContent = fs.readFileSync(path.join(BASE, 'staticxishu.xml'), 'utf-8');
  const xmlB64 = Buffer.from(xmlContent, 'utf-8').toString('base64');

  // Use exec approach for file upload
  const execPayload = JSON.stringify({
    key: 'sanguoq_admin_2024',
    cmd: `echo '${xmlB64}' | base64 -d > /opt/staticxishu.xml && ls -la /opt/staticxishu.xml && echo DONE`
  });

  try {
    await new Promise((resolve) => {
      const req = https.request({
        hostname: SERVER,
        port: PORT,
        path: '/api/admin/exec',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(execPayload)
        },
        timeout: 10000
      }, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          console.log('[XML] Response: ' + data.substring(0, 200));
          resolve(true);
        });
      });
      req.on('error', () => resolve(true));
      req.on('timeout', () => { req.destroy(); resolve(true); });
      req.write(execPayload);
      req.end();
    });
  } catch(e) {
    console.log('XML upload issue: ' + e.message);
  }

  // 3. Verify version
  console.log('\n=== Verifying deployment ===');
  try {
    await new Promise((resolve) => {
      const req = https.request({
        hostname: SERVER,
        port: PORT,
        path: '/api/version',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      }, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          try {
            const v = JSON.parse(data);
            console.log('Server version: ' + v.version);
            console.log(v.version === '2.5.0' ? '✓ Version matches!' : '⚠ Version mismatch');
          } catch(e) { console.log('Verify: ' + data.substring(0, 100)); }
          resolve(true);
        });
      });
      req.on('error', (e) => { console.log('Verify error: ' + e.message); resolve(true); });
      req.write('{}');
      req.end();
    });
  } catch(e) {}

  console.log('\n=== Deploy complete ===');
}

main().catch(e => { console.error(e); process.exit(1); });
