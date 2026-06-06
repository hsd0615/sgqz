import express from 'express';
import http from 'http';
import { initDB, forceSave } from './db/database';
import { LeitaiRepo } from './db/repository';
import { setupWebSocket } from './ws/handler';
import { setupTCPServer } from './tcp/handler';
import { createTestAccounts } from './testdata';

import authRoutes from './api/auth';
import gameRoutes from './api/game';
import generalRoutes from './api/general';
import shopRoutes from './api/shop';
import fubenRoutes from './api/fuben';
import leitaiRoutes from './api/leitai';
import miscRoutes from './api/misc';

const PORT = parseInt(process.env.PORT || '3000');
const app = express();
const server = http.createServer(app);

// RAW body capture for debugging
app.use((req, res, next) => {
  let body = '';
  req.on('data', chunk => { body += chunk; });
  req.on('end', () => {
    (req as any).rawBody = body;
  });
  next();
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
    return;
  }
  next();
});

app.use((req, res, next) => {
  const logLine = `[HTTP] ${req.method} ${req.url} Content-Type=${req.headers['content-type']} Body=${(req as any).rawBody?.substring(0,200) || '(empty)'}`;
  console.log(logLine);
  next();
});

app.get('/crossdomain.xml', (req, res) => {
  res.type('xml');
  res.send(`<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
  <allow-access-from domain="*" />
  <allow-http-request-headers-from domain="*" headers="*"/>
</cross-domain-policy>`);
});

app.use('/api/auth', authRoutes);
app.use('/api/game', gameRoutes);
app.use('/api/general', generalRoutes);
app.use('/api/shop', shopRoutes);
app.use('/api/fuben', fubenRoutes);
app.use('/api/leitai', leitaiRoutes);
app.use('/api/misc', miscRoutes);

app.all('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

app.all('*', (req, res) => {
  console.log(`[HTTP] 404 NOT FOUND: ${req.method} ${req.url}`);
  res.status(404).json({ success: false, message: `路由不存在: ${req.url}` });
});

const wss = setupWebSocket(server);
const tcpServer = setupTCPServer(3001);
initDB();
LeitaiRepo.initDefaultRooms();
createTestAccounts();

server.listen(PORT, () => {
  console.log(`服务器已启动: http://localhost:${PORT}/api`);
  console.log(`WebSocket: ws://localhost:${PORT}/ws`);
  console.log(`TCP 对战: tcp://localhost:3001`);
});

process.on('SIGINT', () => {
  console.log('\n关闭中...');
  forceSave();
  wss.close(() => { server.close(() => process.exit(0)); });
});

export { app, server };
