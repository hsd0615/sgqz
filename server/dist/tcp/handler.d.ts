/**
 * 原始 TCP 服务 — 处理 ChatManager/SocketConnection 的二进制协议
 * 协议: [4 bytes big-endian: payload length] [UTF-8 JSON payload]
 *
 * 运行在独立端口（3001），与 HTTP(3000)/WebSocket 分离
 */
import net from 'net';
interface TCPSession {
    socket: net.Socket;
    peerId: string;
    playerId: number;
    roleName: string;
    rooms: Set<string>;
    farPeerId: string | null;
    buffer: Buffer;
    expectedLength: number;
}
declare const sessions: Map<string, TCPSession>;
declare const rooms: Map<string, Set<string>>;
export declare function setupTCPServer(port?: number): net.Server;
declare function sendTCP(session: TCPSession, msg: object): void;
export { sessions, rooms, sendTCP };
