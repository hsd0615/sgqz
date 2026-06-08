"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.rooms = exports.sessions = void 0;
exports.setupWebSocket = setupWebSocket;
exports.sendTo = sendTo;
const ws_1 = require("ws");
const repository_1 = require("../db/repository");
// ============== Global State ==============
const sessions = new Map(); // peerID → ClientSession
exports.sessions = sessions;
const clientToWS = new Map(); // WS → ClientSession
const rooms = new Map(); // roomName → Set<peerID>
exports.rooms = rooms;
function getOrCreateRoom(name) {
    if (!rooms.has(name)) {
        rooms.set(name, new Set());
    }
    return rooms.get(name);
}
// ============== Message Handlers ==============
function setupWebSocket(httpServer) {
    const wss = new ws_1.WebSocketServer({ server: httpServer, path: '/ws' });
    wss.on('connection', (ws) => {
        console.log('[WS] 新连接');
        ws.on('message', (data) => {
            try {
                const msg = JSON.parse(data.toString('utf-8'));
                handleMessage(ws, msg);
            }
            catch (e) {
                console.error('[WS] 消息解析失败:', e);
                sendTo(ws, { type: 'error', message: '消息格式错误' });
            }
        });
        ws.on('close', () => {
            const session = clientToWS.get(ws);
            if (session) {
                console.log(`[WS] 断开连接: ${session.roleName} (${session.peerId})`);
                handleDisconnect(session);
                clientToWS.delete(ws);
                sessions.delete(session.peerId);
            }
        });
        ws.on('error', (err) => {
            console.error('[WS] 连接错误:', err.message);
        });
    });
    return wss;
}
function handleMessage(ws, msg) {
    console.log(`[WS] 收到消息: type=${msg.type} from=${msg.peerId || 'anon'}`);
    switch (msg.type) {
        case 'auth':
            handleAuth(ws, msg);
            break;
        case 'join_room':
            handleJoinRoom(ws, msg);
            break;
        case 'leave_room':
            handleLeaveRoom(ws, msg);
            break;
        case 'chat':
            handleChat(ws, msg);
            break;
        case 'neighbor_list':
            handleNeighborList(ws, msg);
            break;
        case 'battle_request':
            handleBattleRequest(ws, msg);
            break;
        case 'battle_accept':
            handleBattleAccept(ws, msg);
            break;
        case 'battle_decline':
            handleBattleDecline(ws, msg);
            break;
        case 'battle_action':
            handleBattleAction(ws, msg);
            break;
        case 'battle_result':
            handleBattleResult(ws, msg);
            break;
        case 'server_info':
            handleServerInfo(ws, msg);
            break;
        case 'p2p_message':
            handleP2PMessage(ws, msg);
            break;
        default:
            sendTo(ws, { type: 'error', message: `未知消息类型: ${msg.type}` });
    }
}
// ============== Auth ==============
function handleAuth(ws, msg) {
    const { roleID, token, peerID, roleName, level, imageId, agent } = msg;
    // Validate token
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    if (!player && roleID) {
        sendTo(ws, { type: 'auth_fail', message: '认证失败' });
        return;
    }
    const session = {
        ws,
        playerId: player?.id || 0,
        roleId: String(roleID),
        peerId: peerID || generatePeerId(),
        roleName: roleName || player?.role_name || 'Unknown',
        level: level || player?.level || 1,
        imageId: imageId || player?.image_id || 1,
        agent: agent || '4399',
        rooms: new Set(),
        farPeerId: null,
    };
    sessions.set(session.peerId, session);
    clientToWS.set(ws, session);
    sendTo(ws, {
        type: 'auth_success',
        peerId: session.peerId,
        message: '连接成功',
    });
    console.log(`[WS] 认证成功: ${session.roleName} (${session.peerId})`);
}
function generatePeerId() {
    return 'p' + Date.now().toString(36) + Math.random().toString(36).substr(2, 6);
}
// ============== Room Management ==============
function handleJoinRoom(ws, msg) {
    const session = clientToWS.get(ws);
    if (!session) {
        sendTo(ws, { type: 'error', message: '请先认证' });
        return;
    }
    const roomName = msg.room;
    const room = getOrCreateRoom(roomName);
    // Notify existing members
    for (const peerId of room) {
        const other = sessions.get(peerId);
        if (other) {
            sendTo(other.ws, {
                type: 'neighbor_join',
                peer: makePeerInfo(session),
            });
        }
    }
    room.add(session.peerId);
    session.rooms.add(roomName);
    // Send current room members to new member
    const neighbors = [];
    for (const peerId of room) {
        if (peerId !== session.peerId) {
            const other = sessions.get(peerId);
            if (other)
                neighbors.push(makePeerInfo(other));
        }
    }
    sendTo(ws, {
        type: 'room_joined',
        room: roomName,
        neighbors,
    });
    console.log(`[WS] ${session.roleName} 加入房间 ${roomName}, 成员数=${room.size}`);
}
function handleLeaveRoom(ws, msg) {
    const session = clientToWS.get(ws);
    if (!session)
        return;
    const roomName = msg.room;
    const room = rooms.get(roomName);
    if (room) {
        room.delete(session.peerId);
        // Notify remaining members
        for (const peerId of room) {
            const other = sessions.get(peerId);
            if (other) {
                sendTo(other.ws, {
                    type: 'neighbor_leave',
                    peerId: session.peerId,
                });
            }
        }
        if (room.size === 0) {
            rooms.delete(roomName);
        }
    }
    session.rooms.delete(roomName);
}
// ============== Chat ==============
function handleChat(ws, msg) {
    const session = clientToWS.get(ws);
    if (!session) {
        sendTo(ws, { type: 'error', message: '请先认证' });
        return;
    }
    const { room, text } = msg;
    const targetRoom = rooms.get(room);
    if (!targetRoom)
        return;
    const chatMsg = {
        type: 'chat',
        from: session.peerId,
        fromName: session.roleName,
        fromImage: session.imageId,
        text,
        timestamp: Date.now(),
    };
    // Broadcast to room
    for (const peerId of targetRoom) {
        const other = sessions.get(peerId);
        if (other && other.peerId !== session.peerId) {
            sendTo(other.ws, chatMsg);
        }
    }
}
// ============== Neighbor List ==============
function handleNeighborList(ws, msg) {
    const session = clientToWS.get(ws);
    if (!session)
        return;
    const roomName = msg.room;
    const room = rooms.get(roomName);
    if (!room) {
        sendTo(ws, { type: 'neighbor_list', neighbors: [] });
        return;
    }
    const neighbors = [];
    for (const peerId of room) {
        if (peerId !== session.peerId) {
            const other = sessions.get(peerId);
            if (other)
                neighbors.push(makePeerInfo(other));
        }
    }
    sendTo(ws, { type: 'neighbor_list', neighbors });
}
// ============== Battle (P2P Relay) ==============
function handleBattleRequest(ws, msg) {
    const session = clientToWS.get(ws);
    if (!session)
        return;
    const targetPeerId = msg.targetPeerId;
    const target = sessions.get(targetPeerId);
    if (!target) {
        sendTo(ws, { type: 'battle_request_fail', reason: '对手不在线' });
        return;
    }
    if (target.farPeerId) {
        sendTo(ws, { type: 'battle_request_fail', reason: '对手正在战斗中' });
        return;
    }
    session.farPeerId = targetPeerId;
    sendTo(target.ws, {
        type: 'battle_request',
        from: session.peerId,
        fromName: session.roleName,
        fromLevel: session.level,
        fromImage: session.imageId,
        server: msg.server,
    });
}
function handleBattleAccept(ws, msg) {
    const session = clientToWS.get(ws);
    if (!session)
        return;
    const fromPeerId = msg.fromPeerId;
    const opponent = sessions.get(fromPeerId);
    if (!opponent) {
        sendTo(ws, { type: 'error', message: '对手已离线' });
        return;
    }
    session.farPeerId = fromPeerId;
    opponent.farPeerId = session.peerId;
    // Send battle start to both
    const battleStartMsg = {
        type: 'battle_start',
        leftInfo: {
            name: session.roleName,
            level: session.level,
            image: session.imageId,
        },
        rightInfo: {
            name: opponent.roleName,
            level: opponent.level,
            image: opponent.imageId,
        },
    };
    sendTo(ws, { ...battleStartMsg, direct: 1, opponentPID: opponent.peerId });
    sendTo(opponent.ws, {
        ...battleStartMsg,
        direct: -1,
        opponentPID: session.peerId,
        server: true,
    });
    console.log(`[WS] 战斗开始: ${session.roleName} vs ${opponent.roleName}`);
}
function handleBattleDecline(ws, msg) {
    const session = clientToWS.get(ws);
    if (!session)
        return;
    const fromPeerId = msg.fromPeerId;
    const opponent = sessions.get(fromPeerId);
    if (opponent) {
        sendTo(opponent.ws, { type: 'battle_decline', from: session.peerId });
        opponent.farPeerId = null;
    }
    session.farPeerId = null;
}
function handleBattleAction(ws, msg) {
    const session = clientToWS.get(ws);
    if (!session)
        return;
    const opponent = sessions.get(session.farPeerId || '');
    if (!opponent) {
        sendTo(ws, { type: 'battle_error', message: '对手已断开' });
        return;
    }
    // Relay the action data directly to the opponent
    sendTo(opponent.ws, {
        type: 'battle_action',
        from: session.peerId,
        data: msg.data,
    });
}
function handleBattleResult(ws, msg) {
    const session = clientToWS.get(ws);
    if (!session)
        return;
    const opponent = sessions.get(session.farPeerId || '');
    if (opponent) {
        sendTo(opponent.ws, {
            type: 'battle_result',
            from: session.peerId,
            result: msg.result,
        });
        opponent.farPeerId = null;
    }
    session.farPeerId = null;
}
// ============== Server Info ==============
function handleServerInfo(ws, msg) {
    // Return online player count and server info
    sendTo(ws, {
        type: 'server_info_response',
        onlineCount: sessions.size,
        roomsCount: rooms.size,
        timestamp: Date.now(),
    });
}
// ============== P2P Messages (generic relay) ==============
function handleP2PMessage(ws, msg) {
    const session = clientToWS.get(ws);
    if (!session)
        return;
    const targetId = msg.to || session.farPeerId;
    const target = sessions.get(targetId);
    if (!target) {
        sendTo(ws, { type: 'error', message: '消息接收者不在线' });
        return;
    }
    sendTo(target.ws, {
        type: 'p2p_message',
        from: session.peerId,
        data: msg.data,
    });
}
// ============== Disconnect ==============
function handleDisconnect(session) {
    // Remove from all rooms
    for (const roomName of session.rooms) {
        const room = rooms.get(roomName);
        if (room) {
            room.delete(session.peerId);
            if (room.size === 0) {
                rooms.delete(roomName);
            }
            else {
                // Notify remaining members
                for (const peerId of room) {
                    const other = sessions.get(peerId);
                    if (other) {
                        sendTo(other.ws, {
                            type: 'neighbor_leave',
                            peerId: session.peerId,
                        });
                    }
                }
            }
        }
    }
    // Notify battle opponent
    if (session.farPeerId) {
        const opponent = sessions.get(session.farPeerId);
        if (opponent) {
            sendTo(opponent.ws, {
                type: 'battle_opponent_disconnected',
                peerId: session.peerId,
            });
            opponent.farPeerId = null;
        }
    }
}
// ============== Helpers ==============
function sendTo(ws, msg) {
    if (ws.readyState === ws_1.WebSocket.OPEN) {
        ws.send(JSON.stringify(msg));
    }
}
function makePeerInfo(session) {
    return {
        pID: session.peerId,
        roleID: session.roleId,
        roleName: session.roleName,
        level: session.level,
        imageID: session.imageId,
        agent: session.agent,
        status: 0,
    };
}
