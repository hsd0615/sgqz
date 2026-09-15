/**
 * 原始 TCP 服务 — 处理 ChatManager/SocketConnection 的二进制协议
 * 协议: [4 bytes big-endian: payload length] [UTF-8 JSON payload]
 *
 * 运行在独立端口（3001），与 HTTP(3000)/WebSocket 分离
 */
import net from 'net';
import { PlayerRepo } from '../db/repository';

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

const sessions: Map<string, TCPSession> = new Map();
const tcpToSession: Map<net.Socket, TCPSession> = new Map();
const rooms: Map<string, Set<string>> = new Map();

export function setupTCPServer(port: number = 3001): net.Server {
  const server = net.createServer((socket: net.Socket) => {
    console.log(`[TCP] 新连接: ${socket.remoteAddress}`);

    const session: TCPSession = {
      socket,
      peerId: '',
      playerId: 0,
      roleName: '',
      rooms: new Set(),
      farPeerId: null,
      buffer: Buffer.alloc(0),
      expectedLength: -1,
    };

    socket.on('data', (data: Buffer) => {
      session.buffer = Buffer.concat([session.buffer, data]);

      while (true) {
        if (session.expectedLength < 0) {
          if (session.buffer.length < 4) break;
          session.expectedLength = session.buffer.readInt32BE(0);
          session.buffer = session.buffer.slice(4);
        }

        if (session.buffer.length < session.expectedLength) break;

        const payload = session.buffer.slice(0, session.expectedLength).toString('utf-8');
        session.buffer = session.buffer.slice(session.expectedLength);
        session.expectedLength = -1;

        try {
          const msg = JSON.parse(payload);
          handleTCPMessage(session, msg);
        } catch (e) {
          console.error('[TCP] 消息解析失败:', e);
        }
      }
    });

    socket.on('close', () => {
      const s = tcpToSession.get(socket);
      if (s) {
        console.log(`[TCP] 断开: ${s.roleName} (${s.peerId})`);
        handleDisconnect(s);
        sessions.delete(s.peerId);
        tcpToSession.delete(socket);
      }
    });

    socket.on('error', (err) => {
      console.error('[TCP] 连接错误:', err.message);
    });
  });

  server.listen(port, '0.0.0.0', () => {
    console.log(`TCP 服务已启动: 0.0.0.0:${port}`);
  });

  return server;
}

function handleTCPMessage(session: TCPSession, msg: any): void {
  console.log(`[TCP] 收到: type=${msg.type} from=${session.peerId || 'anon'}`);

  switch (msg.type) {
    case 'auth':
      handleAuth(session, msg);
      break;
    case 'join_room':
      handleJoinRoom(session, msg);
      break;
    case 'leave_room':
      handleLeaveRoom(session, msg);
      break;
    case 'chat':
      handleChat(session, msg);
      break;
    case 'neighbor_list':
      handleNeighborList(session, msg);
      break;
    case 'battle_request':
      handleBattleRequest(session, msg);
      break;
    case 'battle_accept':
      handleBattleAccept(session, msg);
      break;
    case 'battle_decline':
      handleBattleDecline(session, msg);
      break;
    case 'battle_action':
      handleBattleAction(session, msg);
      break;
    case 'battle_result':
    case 'battle_end':
      handleBattleEnd(session, msg);
      break;
    case 'server_info':
      handleServerInfo(session);
      break;
    default:
      sendTCP(session, { type: 'error', message: `未知消息类型: ${msg.type}` });
  }
}

function handleAuth(session: TCPSession, msg: any): void {
  const { roleID, token, roleName, level, imageId } = msg;

  const player = roleID ? PlayerRepo.findByRoleId(String(roleID)) : undefined;
  if (!player && roleID) {
    sendTCP(session, { type: 'auth_fail', message: '认证失败' });
    return;
  }

  session.peerId = generatePeerId();
  session.playerId = player?.id || 0;
  session.roleName = roleName || player?.role_name || 'Unknown';

  sessions.set(session.peerId, session);
  tcpToSession.set(session.socket, session);

  sendTCP(session, {
    type: 'auth_success',
    peerId: session.peerId,
    message: '连接成功',
  });

  console.log(`[TCP] 认证成功: ${session.roleName} (${session.peerId})`);
}

function handleJoinRoom(session: TCPSession, msg: any): void {
  const roomName = msg.room;
  if (!rooms.has(roomName)) rooms.set(roomName, new Set());
  const room = rooms.get(roomName)!;

  // Notify existing members
  for (const pid of room) {
    const other = sessions.get(pid);
    if (other) sendTCP(other, { type: 'neighbor_join', peer: makePeerInfo(session) });
  }

  room.add(session.peerId);
  session.rooms.add(roomName);

  const neighbors: any[] = [];
  for (const pid of room) {
    if (pid !== session.peerId) {
      const other = sessions.get(pid);
      if (other) neighbors.push(makePeerInfo(other));
    }
  }

  sendTCP(session, { type: 'room_joined', room: roomName, neighbors });
}

function handleLeaveRoom(session: TCPSession, msg: any): void {
  const room = rooms.get(msg.room);
  if (room) {
    room.delete(session.peerId);
    if (room.size === 0) rooms.delete(msg.room);
    else {
      for (const pid of room) {
        const other = sessions.get(pid);
        if (other) sendTCP(other, { type: 'neighbor_leave', peerId: session.peerId });
      }
    }
  }
  session.rooms.delete(msg.room);
}

function handleChat(session: TCPSession, msg: any): void {
  const room = rooms.get(msg.room);
  if (!room) return;

  const chatMsg = {
    type: 'chat',
    room: msg.room,
    from: session.peerId,
    fromName: session.roleName,
    text: msg.text || msg.data,
  };

  for (const pid of room) {
    if (pid !== session.peerId) {
      const other = sessions.get(pid);
      if (other) sendTCP(other, chatMsg);
    }
  }
}

function handleNeighborList(session: TCPSession, msg: any): void {
  const room = rooms.get(msg.room);
  if (!room) { sendTCP(session, { type: 'neighbor_list', neighbors: [] }); return; }

  const neighbors: any[] = [];
  for (const pid of room) {
    if (pid !== session.peerId) {
      const other = sessions.get(pid);
      if (other) neighbors.push(makePeerInfo(other));
    }
  }
  sendTCP(session, { type: 'neighbor_list', neighbors });
}

function handleBattleRequest(session: TCPSession, msg: any): void {
  const target = sessions.get(msg.targetPeerId);
  if (!target) {
    sendTCP(session, { type: 'battle_request_fail', reason: '对手不在线' });
    return;
  }
  if (target.farPeerId) {
    sendTCP(session, { type: 'battle_request_fail', reason: '对手正在战斗中' });
    return;
  }

  session.farPeerId = msg.targetPeerId;
  sendTCP(target, {
    type: 'battle_request',
    from: session.peerId,
    fromName: session.roleName,
    server: msg.server,
  });
}

function handleBattleAccept(session: TCPSession, msg: any): void {
  const opponent = sessions.get(msg.fromPeerId);
  if (!opponent) {
    sendTCP(session, { type: 'error', message: '对手已离线' });
    return;
  }

  session.farPeerId = msg.fromPeerId;
  opponent.farPeerId = session.peerId;

  sendTCP(session, {
    type: 'battle_start',
    direct: 1,
    opponentPID: opponent.peerId,
    leftInfo: { name: session.roleName, level: 1, image: 1 },
    rightInfo: { name: opponent.roleName, level: 1, image: 1 },
  });

  sendTCP(opponent, {
    type: 'battle_start',
    direct: -1,
    opponentPID: session.peerId,
    server: true,
    leftInfo: { name: opponent.roleName, level: 1, image: 1 },
    rightInfo: { name: session.roleName, level: 1, image: 1 },
  });

  console.log(`[TCP] 战斗开始: ${session.roleName} vs ${opponent.roleName}`);
}

function handleBattleDecline(session: TCPSession, msg: any): void {
  const opponent = sessions.get(msg.fromPeerId);
  if (opponent) {
    sendTCP(opponent, { type: 'battle_decline', from: session.peerId });
    opponent.farPeerId = null;
  }
  session.farPeerId = null;
}

function handleBattleAction(session: TCPSession, msg: any): void {
  const opponent = session.farPeerId ? sessions.get(session.farPeerId) : undefined;
  if (!opponent) {
    sendTCP(session, { type: 'battle_error', message: '对手已断开' });
    return;
  }
  sendTCP(opponent, { type: 'battle_action', from: session.peerId, data: msg.data });
}

function handleBattleEnd(session: TCPSession, msg: any): void {
  const opponent = session.farPeerId ? sessions.get(session.farPeerId) : undefined;
  if (opponent) {
    opponent.farPeerId = null;
  }
  session.farPeerId = null;
}

function handleServerInfo(session: TCPSession): void {
  sendTCP(session, {
    type: 'server_info_response',
    onlineCount: sessions.size,
    roomsCount: rooms.size,
  });
}

function handleDisconnect(session: TCPSession): void {
  for (const roomName of session.rooms) {
    const room = rooms.get(roomName);
    if (room) {
      room.delete(session.peerId);
      if (room.size === 0) rooms.delete(roomName);
      else {
        for (const pid of room) {
          const other = sessions.get(pid);
          if (other) sendTCP(other, { type: 'neighbor_leave', peerId: session.peerId });
        }
      }
    }
  }

  if (session.farPeerId) {
    const opponent = sessions.get(session.farPeerId);
    if (opponent) {
      sendTCP(opponent, { type: 'battle_opponent_disconnected', peerId: session.peerId });
      opponent.farPeerId = null;
    }
  }
}

function sendTCP(session: TCPSession, msg: object): void {
  try {
    const json = JSON.stringify(msg);
    const payload = Buffer.from(json, 'utf-8');
    const header = Buffer.alloc(4);
    header.writeInt32BE(payload.length, 0);
    session.socket.write(Buffer.concat([header, payload]));
  } catch (e) {
    console.error('[TCP] 发送失败:', e);
  }
}

function makePeerInfo(session: TCPSession): any {
  return {
    pID: session.peerId,
    roleID: String(session.playerId),
    roleName: session.roleName,
    level: 1,
    imageID: 1,
    agent: '4399',
    status: 0,
  };
}

function generatePeerId(): string {
  return 'p' + Date.now().toString(36) + Math.random().toString(36).substr(2, 6);
}

export { sessions, rooms, sendTCP };
