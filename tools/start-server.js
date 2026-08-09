#!/usr/bin/env node
/**
 * 通过阿里云 ECS Cloud Assistant 启动游戏服务
 * 解决服务离线后 admin API 不可用的鸡生蛋问题
 */
const Core = require('@alicloud/pop-core');
const path = require('path');
const fs = require('fs');

const config = JSON.parse(fs.readFileSync(path.join(__dirname, 'cloud-config.json'), 'utf-8'));

const client = new Core({
  accessKeyId: config.accessKeyId,
  accessKeySecret: config.accessKeySecret,
  endpoint: 'https://ecs.aliyuncs.com',
  apiVersion: '2014-05-26'
});

const cmd = `cd /opt
pkill -f "node start_fixed" 2>/dev/null || true
sleep 1
nohup node start_fixed.js > server.log 2>&1 &
sleep 3
PID=$(pgrep -f "start_fixed" || echo "NONE")
echo "Server PID: $PID"
ss -tlnp | grep 3000 || echo "Port 3000 not listening"`;

const params = {
  RegionId: config.region,
  InstanceId: [config.instanceId],
  Type: 'RunShellScript',
  CommandContent: cmd,
  Timeout: 60,
  WorkingDir: '/opt'
};

console.log('正在通过阿里云 Cloud Assistant 在 ECS 上启动游戏服务...\n');

client.request('RunCommand', params)
  .then(async (result) => {
    console.log('Command sent:', JSON.stringify(result, null, 2));

    // Wait for command to execute and poll result
    if (result.InvocationId) {
      console.log('\n等待执行结果...');
      await new Promise(r => setTimeout(r, 10000));

      try {
        const desc = await client.request('DescribeInvocationResults', {
          RegionId: config.region,
          InvokeId: result.InvocationId,
          InstanceId: config.instanceId
        });

        if (desc.Invocation && desc.Invocation.InvocationResults) {
          const res = desc.Invocation.InvocationResults.InvocationResult;
          if (Array.isArray(res)) {
            res.forEach(r => {
              console.log('\n--- 执行结果 ---');
              console.log('ExitCode:', r.ExitCode);
              console.log('Output:', r.Output || '(empty)');
              if (r.ErrorInfo) console.log('Error:', r.ErrorInfo);
            });
          }
        }
      } catch (e) {
        console.log('获取执行结果失败:', e.message);
      }
    }

    // Now check server status
    console.log('\n=========================');
    console.log('检查服务器状态...');

    const http = require('http');
    const checkApi = (apiPath) => new Promise((resolve, reject) => {
      const req = http.request({
        hostname: config.serverIp,
        port: config.serverPort,
        path: apiPath,
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        timeout: 5000
      }, (res) => {
        let d = '';
        res.on('data', c => d += c);
        res.on('end', () => {
          try { resolve(JSON.parse(d)); } catch(e) { resolve(d); }
        });
      });
      req.on('error', e => reject(e));
      req.write('{}');
      req.end();
    });

    try {
      const v = await checkApi('/api/version');
      console.log('版本:', JSON.stringify(v));
    } catch(e) {
      console.log('版本检查失败:', e.message);
    }

    try {
      const h = await checkApi('/api/health');
      console.log('状态:', JSON.stringify(h));
    } catch(e) {
      console.log('健康检查失败:', e.message);
    }
  })
  .catch(e => {
    console.error('启动失败:', e.message);
    if (e.data) console.error('Response:', JSON.stringify(e.data));
  });
