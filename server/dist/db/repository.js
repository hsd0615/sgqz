"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LeitaiRepo = exports.BagItemRepo = exports.GeneralRepo = exports.PlayerRepo = void 0;
const database_1 = require("./database");
const uuid_1 = require("uuid");
// ============== Player Repository ==============
exports.PlayerRepo = {
    findByUserId(userId) {
        return (0, database_1.findOne)('players', (p) => String(p.user_id) === String(userId));
    },
    findById(id) {
        return (0, database_1.findOne)('players', (p) => p.id === id);
    },
    findByRoleId(roleId) {
        return (0, database_1.findOne)('players', (p) => p.id === parseInt(roleId));
    },
    findByUserIdAndPassword(userId, password) {
        return (0, database_1.findOne)('players', (p) => String(p.user_id) === String(userId) && p.password === password);
    },
    create(userId, roleName, imageId, agent, password = '') {
        const token = (0, uuid_1.v4)().replace(/-/g, '');
        const player = (0, database_1.insert)('players', {
            user_id: String(userId),
            agent: agent || '4399',
            password: password || '',
            role_name: roleName,
            image_id: imageId,
            level: 1,
            exp: 0,
            money: 5000,
            dianka: 0,
            exploit: 0,
            reverence: 0,
            rongyu: 0,
            win_count: 0,
            lost_count: 0,
            finished_stages: '',
            history: '',
            login_server: 0,
            token,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
        });
        return player;
    },
    update(id, data) {
        (0, database_1.update)('players', id, { ...data, updated_at: new Date().toISOString() });
    },
    generateToken(id) {
        const token = (0, uuid_1.v4)().replace(/-/g, '');
        exports.PlayerRepo.update(id, { token });
        return token;
    }
};
// ============== General Repository ==============
exports.GeneralRepo = {
    findByPlayerId(playerId) {
        return (0, database_1.findMany)('generals', (g) => g.player_id === playerId);
    },
    findById(id) {
        return (0, database_1.findOne)('generals', (g) => g.id === id);
    },
    create(playerId, data) {
        const general = (0, database_1.insert)('generals', {
            player_id: playerId,
            general_id: data.general_id || Math.floor(Math.random() * 100000),
            code: data.code || '',
            name: data.name || 'Unknown',
            level: data.level || 1,
            evolution: data.evolution || 0,
            feature: data.feature || 0,
            tianfu: data.tianfu || null,
            kezhi1: data.kezhi1 || 0,
            kezhi1_level: data.kezhi1_level || 0,
            kezhi2: data.kezhi2 || 0,
            kezhi2_level: data.kezhi2_level || 0,
            kezhi3: data.kezhi3 || 0,
            kezhi3_level: data.kezhi3_level || 0,
            is_deployed: 0,
            created_at: new Date().toISOString(),
        });
        return general;
    },
    update(id, data) {
        (0, database_1.update)('generals', id, data);
    },
    delete(id) {
        (0, database_1.remove)('generals', id);
    },
    getDeployed(playerId) {
        return (0, database_1.findMany)('generals', (g) => g.player_id === playerId && g.is_deployed === 1);
    },
    setDeployed(playerId, generalIds) {
        (0, database_1.updateWhere)('generals', (g) => g.player_id === playerId, { is_deployed: 0 });
        if (generalIds.length > 0) {
            for (const gid of generalIds) {
                (0, database_1.updateWhere)('generals', (g) => g.player_id === playerId && g.general_id === gid, { is_deployed: 1 });
            }
        }
    }
};
// ============== BagItem Repository ==============
exports.BagItemRepo = {
    findByPlayerId(playerId) {
        return (0, database_1.findMany)('bagItems', (b) => b.player_id === playerId);
    },
    findItem(playerId, itemCode) {
        return (0, database_1.findOne)('bagItems', (b) => b.player_id === playerId && b.item_code === itemCode);
    },
    updateOrCreate(playerId, itemCode, count, itemId) {
        const existing = exports.BagItemRepo.findItem(playerId, itemCode);
        if (existing) {
            (0, database_1.update)('bagItems', existing.id, { item_count: count });
        }
        else {
            (0, database_1.insert)('bagItems', {
                player_id: playerId,
                item_code: itemCode,
                item_count: count,
                created_at: new Date().toISOString(),
            });
        }
    },
    getCount(playerId, itemCode) {
        const item = exports.BagItemRepo.findItem(playerId, itemCode);
        return item ? item.item_count : 0;
    },
    addItem(playerId, itemCode, addCount) {
        const current = exports.BagItemRepo.getCount(playerId, itemCode);
        exports.BagItemRepo.updateOrCreate(playerId, itemCode, current + addCount);
    },
    removeItem(playerId, itemCode, removeCount) {
        const current = exports.BagItemRepo.getCount(playerId, itemCode);
        const newCount = Math.max(0, current - removeCount);
        exports.BagItemRepo.updateOrCreate(playerId, itemCode, newCount);
    }
};
// ============== Leitai Repository ==============
exports.LeitaiRepo = {
    findAll() {
        return (0, database_1.getAll)('leitaiRooms').sort((a, b) => b.room_level - a.room_level || a.r_id - b.r_id);
    },
    findById(rId) {
        return (0, database_1.findOne)('leitaiRooms', (r) => r.r_id === rId);
    },
    update(rId, data) {
        (0, database_1.updateWhere)('leitaiRooms', (r) => r.r_id === rId, data);
    },
    initDefaultRooms() {
        if ((0, database_1.getAll)('leitaiRooms').length > 0)
            return;
        const levels = [
            { lv: 200, prices: [10000, 10000, 30, 5000, 5000, 10] },
            { lv: 180, prices: [10000, 10000, 30, 5000, 5000, 10] },
            { lv: 160, prices: [8000, 8000, 30, 5000, 5000, 10] },
            { lv: 140, prices: [8000, 8000, 30, 5000, 5000, 10] },
            { lv: 120, prices: [5000, 5000, 30, 2000, 2000, 10] },
            { lv: 90, prices: [5000, 5000, 30, 2000, 2000, 10] },
            { lv: 60, prices: [3000, 3000, 30, 1000, 1000, 10] },
            { lv: 30, prices: [3000, 3000, 30, 1000, 1000, 10] },
        ];
        for (const level of levels) {
            for (let type = 0; type < 6; type++) {
                (0, database_1.insert)('leitaiRooms', {
                    r_id: (0, database_1.getNextId)('leitaiRooms') + (level.lv * 100) + type,
                    room_level: level.lv,
                    room_status: 0,
                    room_type: (type % 3) + 1,
                    room_price: level.prices[type],
                    master_id: null,
                    master_pid: null,
                    master_name: null,
                    master_level: null,
                    master_image: null,
                    slave_id: null,
                    slave_pid: null,
                    slave_name: null,
                    slave_level: null,
                    slave_image: null,
                    rongyu_pool: 0,
                    battle_count: 0,
                    created_at: new Date().toISOString(),
                });
            }
        }
        console.log(`初始化擂台房间完成: ${(0, database_1.getAll)('leitaiRooms').length} 个房间`);
    }
};
