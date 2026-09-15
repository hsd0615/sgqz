import { WebSocketServer, WebSocket } from 'ws';
import { Server } from 'http';
import { ClientSession } from '../models/types';
declare const sessions: Map<string, ClientSession>;
declare const rooms: Map<string, Set<string>>;
export declare function setupWebSocket(httpServer: Server): WebSocketServer;
declare function sendTo(ws: WebSocket, msg: object): void;
export { sessions, rooms, sendTo };
