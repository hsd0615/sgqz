"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.server = exports.app = void 0;
const express_1 = __importDefault(require("express"));
const http_1 = __importDefault(require("http"));
const database_1 = require("./db/database");
const repository_1 = require("./db/repository");
const handler_1 = require("./ws/handler");
const handler_2 = require("./tcp/handler");
const testdata_1 = require("./testdata");
const auth_1 = __importDefault(require("./api/auth"));
const game_1 = __importDefault(require("./api/game"));
const general_1 = __importDefault(require("./api/general"));
const shop_1 = __importDefault(require("./api/shop"));
const fuben_1 = __importDefault(require("./api/fuben"));
const leitai_1 = __importDefault(require("./api/leitai"));
const misc_1 = __importDefault(require("./api/misc"));
const PORT = parseInt(process.env.PORT || '3000');
const app = (0, express_1.default)();
exports.app = app;
app.set('json spaces', 0);
const server = http_1.default.createServer(app);
exports.server = server;
// RAW body capture for debugging
app.use((req, res, next) => {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
        req.rawBody = body;
    });
    next();
});
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
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
    const logLine = `[HTTP] ${req.method} ${req.url} Content-Type=${req.headers['content-type']} Body=${req.rawBody?.substring(0, 200) || '(empty)'}`;
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
app.use('/api/auth', auth_1.default);
app.use('/api/game', game_1.default);
app.use('/api/general', general_1.default);
app.use('/api/shop', shop_1.default);
app.use('/api/fuben', fuben_1.default);
app.use('/api/leitai', leitai_1.default);
app.use('/api/misc', misc_1.default);
app.all('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: Date.now() });
});
app.all('*', (req, res) => {
    console.log(`[HTTP] 404 NOT FOUND: ${req.method} ${req.url}`);
    res.status(404).json({ success: false, message: `路由不存在: ${req.url}` });
});
const wss = (0, handler_1.setupWebSocket)(server);
const tcpServer = (0, handler_2.setupTCPServer)(3001);
(0, database_1.initDB)();
repository_1.LeitaiRepo.initDefaultRooms();
(0, testdata_1.createTestAccounts)();
server.listen(PORT, () => {
    console.log(`服务器已启动: http://localhost:${PORT}/api`);
    console.log(`WebSocket: ws://localhost:${PORT}/ws`);
    console.log(`TCP 对战: tcp://localhost:3001`);
});
process.on('SIGINT', () => {
    console.log('\n关闭中...');
    (0, database_1.forceSave)();
    wss.close(() => { server.close(() => process.exit(0)); });
});
