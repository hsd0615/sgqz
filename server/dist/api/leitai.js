"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const repository_1 = require("../db/repository");
const router = (0, express_1.Router)();
// POST /api/leitai/list - 擂台列表 (Head.HTTP_NEW_LEITAI_LIST = 10030)
router.post('/list', (req, res) => {
    const { roleID } = req.body;
    console.log(`[Leitai] 列表: roleID=${roleID}`);
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    repository_1.LeitaiRepo.initDefaultRooms();
    const rooms = repository_1.LeitaiRepo.findAll();
    const leitaiData = rooms.map(r => {
        const room = {
            rID: r.r_id,
            rLevel: r.room_level,
            rStatus: r.room_status,
            rType: r.room_type,
            rPrice: r.room_price,
            rValue: r.rongyu_pool,
            rCount: r.battle_count,
        };
        if (r.master_id) {
            room.mInfo = {
                id: r.master_id,
                pID: r.master_pid,
                roleName: r.master_name,
                level: r.master_level,
                imageID: r.master_image,
            };
        }
        if (r.slave_id) {
            room.sInfo = {
                id: r.slave_id,
                pID: r.slave_pid,
                roleName: r.slave_name,
                level: r.slave_level,
                imageID: r.slave_image,
            };
        }
        return room;
    });
    response.data = {
        rongyu: player?.rongyu || 1000,
        ranking: 32, // TODO: calculate real ranking
        leitai: leitaiData,
        paihang: [
            { roleName: '虚位以待', score: 0 },
            { roleName: '虚位以待', score: 0 },
            { roleName: '虚位以待', score: 0 },
        ],
    };
    res.json(response);
});
// POST /api/leitai/flush - 刷新擂台 (Head.HTTP_NEW_LEITAI_FLUSH = 10031)
router.post('/flush', (req, res) => {
    console.log(`[Leitai] 刷新`);
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    const rooms = repository_1.LeitaiRepo.findAll();
    response.data = {
        leitai: rooms.map(r => ({
            rID: r.r_id,
            rLevel: r.room_level,
            rStatus: r.room_status,
            rType: r.room_type,
            rPrice: r.room_price,
            rValue: r.rongyu_pool,
            rCount: r.battle_count,
            mInfo: r.master_id ? {
                id: r.master_id,
                pID: r.master_pid,
                roleName: r.master_name,
                level: r.master_level,
                imageID: r.master_image,
            } : undefined,
        }))
    };
    res.json(response);
});
// POST /api/leitai/be-master - 成为擂主 (Head.HTTP_NEW_LEITAI_BEMASTER = 10032)
router.post('/be-master', (req, res) => {
    const { roleID, rID } = req.body;
    console.log(`[Leitai] 擂主: roleID=${roleID}, rID=${rID}`);
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    if (!player) {
        response.success = false;
        response.message = '玩家不存在';
        res.json(response);
        return;
    }
    const room = repository_1.LeitaiRepo.findById(parseInt(rID));
    if (!room) {
        response.success = false;
        response.message = '房间号错误!';
        res.json(response);
        return;
    }
    // Check level requirement
    if (player.level < room.room_level) {
        response.success = false;
        response.message = '等级不足';
        res.json(response);
        return;
    }
    // Check affordability
    if (room.room_type === 1 && player.money < room.room_price) {
        response.success = false;
        response.message = '金币不足';
        res.json(response);
        return;
    }
    if (room.room_type === 2 && player.exploit < room.room_price) {
        response.success = false;
        response.message = '功勋不足';
        res.json(response);
        return;
    }
    if (room.room_type === 3 && player.dianka < room.room_price) {
        response.success = false;
        response.message = '点卡不足';
        res.json(response);
        return;
    }
    // Deduct cost
    if (room.room_type === 1)
        repository_1.PlayerRepo.update(player.id, { money: player.money - room.room_price });
    else if (room.room_type === 2)
        repository_1.PlayerRepo.update(player.id, { exploit: player.exploit - room.room_price });
    else
        repository_1.PlayerRepo.update(player.id, { dianka: player.dianka - room.room_price });
    // Update room
    repository_1.LeitaiRepo.update(room.r_id, {
        room_status: 1,
        master_id: player.id,
        master_pid: req.body.pID || '',
        master_name: player.role_name,
        master_level: player.level,
        master_image: player.image_id,
    });
    const updatedPlayer = repository_1.PlayerRepo.findById(player.id);
    const updatedRoom = repository_1.LeitaiRepo.findById(room.r_id);
    response.data = {
        rID: rID,
        money: updatedPlayer.money,
        exploit: updatedPlayer.exploit,
        dianka: updatedPlayer.dianka,
        rongyu: updatedPlayer.rongyu,
        leitai: [{
                rID: updatedRoom.r_id,
                rLevel: updatedRoom.room_level,
                rStatus: updatedRoom.room_status,
                rType: updatedRoom.room_type,
                rPrice: updatedRoom.room_price,
                rValue: updatedRoom.rongyu_pool,
                rCount: updatedRoom.battle_count,
                mInfo: {
                    id: updatedRoom.master_id,
                    pID: updatedRoom.master_pid,
                    roleName: updatedRoom.master_name,
                    level: updatedRoom.master_level,
                    imageID: updatedRoom.master_image,
                }
            }]
    };
    res.json(response);
});
// POST /api/leitai/be-slave - 挑战擂主 (Head.HTTP_NEW_LEITAI_BESLAVE = 10034)
router.post('/be-slave', (req, res) => {
    const { roleID, rID } = req.body;
    console.log(`[Leitai] 攻擂: roleID=${roleID}, rID=${rID}`);
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    if (!player) {
        response.success = false;
        response.message = '玩家不存在';
        res.json(response);
        return;
    }
    const room = repository_1.LeitaiRepo.findById(parseInt(rID));
    if (!room) {
        response.success = false;
        response.message = '房间号错误!';
        res.json(response);
        return;
    }
    if (room.room_status !== 1) {
        response.success = false;
        response.message = '擂台状态错误';
        res.json(response);
        return;
    }
    // Deduct cost
    let costPaid = false;
    if (room.room_type === 1 && player.money >= room.room_price) {
        repository_1.PlayerRepo.update(player.id, { money: player.money - room.room_price });
        costPaid = true;
    }
    else if (room.room_type === 2 && player.exploit >= room.room_price) {
        repository_1.PlayerRepo.update(player.id, { exploit: player.exploit - room.room_price });
        costPaid = true;
    }
    else if (room.room_type === 3 && player.dianka >= room.room_price) {
        repository_1.PlayerRepo.update(player.id, { dianka: player.dianka - room.room_price });
        costPaid = true;
    }
    if (!costPaid) {
        response.success = false;
        response.message = '资源不足';
        res.json(response);
        return;
    }
    repository_1.LeitaiRepo.update(room.r_id, {
        room_status: 2,
        slave_id: player.id,
        slave_pid: req.body.pID || '',
        slave_name: player.role_name,
        slave_level: player.level,
        slave_image: player.image_id,
    });
    const updatedPlayer = repository_1.PlayerRepo.findById(player.id);
    response.data = {
        rID,
        money: updatedPlayer.money,
        exploit: updatedPlayer.exploit,
        dianka: updatedPlayer.dianka,
        rongyu: updatedPlayer.rongyu,
        masterPID: room.master_pid,
        masterName: room.master_name,
        slaveName: player.role_name,
    };
    res.json(response);
});
// POST /api/leitai/continue - 擂主继续守擂 (Head.HTTP_NEW_LEITAI_CONTINUE = 10035)
router.post('/continue', (req, res) => {
    const { roleID, rID, type } = req.body;
    console.log(`[Leitai] 继续: roleID=${roleID}, rID=${rID}`);
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    if (!player) {
        response.success = false;
        response.message = '玩家不存在';
        res.json(response);
        return;
    }
    const room = repository_1.LeitaiRepo.findById(parseInt(rID));
    if (!room) {
        response.success = false;
        response.message = '房间号错误!';
        res.json(response);
        return;
    }
    if (room.master_id !== player.id) {
        response.success = false;
        response.message = '你不是此擂台的擂主。';
        res.json(response);
        return;
    }
    // Reset room to waiting status
    repository_1.LeitaiRepo.update(room.r_id, {
        room_status: 1,
        slave_id: null,
        slave_pid: null,
        slave_name: null,
        slave_level: null,
        slave_image: null,
    });
    response.data = {
        rID,
        type: type || room.room_type,
        money: player.money,
        exploit: player.exploit,
        dianka: player.dianka,
        rongyu: player.rongyu,
        leitai: [{
                rID: room.r_id,
                rLevel: room.room_level,
                rStatus: 1,
                rType: room.room_type,
                rPrice: room.room_price,
                rValue: room.rongyu_pool,
                rCount: room.battle_count,
                mInfo: {
                    id: player.id, pID: '', roleName: player.role_name,
                    level: player.level, imageID: player.image_id,
                }
            }]
    };
    res.json(response);
});
// POST /api/leitai/exit - 退出擂台 (Head.HTTP_NEW_LEITAI_EXIT = 10033)
router.post('/exit', (req, res) => {
    const { roleID, rID } = req.body;
    console.log(`[Leitai] 退出: roleID=${roleID}, rID=${rID}`);
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    if (!player) {
        response.success = false;
        response.message = '玩家不存在';
        res.json(response);
        return;
    }
    const room = repository_1.LeitaiRepo.findById(parseInt(rID));
    if (!room) {
        response.success = false;
        response.message = '房间号错误!';
        res.json(response);
        return;
    }
    if (room.master_id !== player.id) {
        response.success = false;
        response.message = '你不是此擂台的擂主。';
        res.json(response);
        return;
    }
    // Reset room
    repository_1.LeitaiRepo.update(room.r_id, {
        room_status: 0,
        master_id: null, master_pid: null, master_name: null, master_level: null, master_image: null,
        slave_id: null, slave_pid: null, slave_name: null, slave_level: null, slave_image: null,
    });
    res.json(response);
});
// POST /api/leitai/fight-over - 擂台战斗结束 (Head.HTTP_NEW_LEITAI_FIGHTOVER = 10036)
router.post('/fight-over', (req, res) => {
    const { roleID, rID, flag, win, relativeName } = req.body;
    console.log(`[Leitai] 战斗结束: roleID=${roleID}, rID=${rID}, win=${win}`);
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    if (!player) {
        response.success = false;
        response.message = '玩家不存在';
        res.json(response);
        return;
    }
    const room = repository_1.LeitaiRepo.findById(parseInt(rID));
    if (!room) {
        response.success = false;
        response.message = '房间号错误!';
        res.json(response);
        return;
    }
    const isWin = parseInt(win) === 1;
    const rongyuGain = isWin ? 100 : 0;
    const moneyGain = isWin ? room.room_price : 0;
    if (isWin) {
        repository_1.PlayerRepo.update(player.id, {
            money: player.money + moneyGain,
            rongyu: player.rongyu + rongyuGain,
        });
        repository_1.LeitaiRepo.update(room.r_id, {
            room_status: 1,
            slave_id: null, slave_pid: null, slave_name: null, slave_level: null, slave_image: null,
            rongyu_pool: room.rongyu_pool + Math.floor(room.room_price * 0.1),
            battle_count: room.battle_count + 1,
        });
    }
    else {
        // Loser - opponent (master) gets reward, handled by master's request
        repository_1.LeitaiRepo.update(room.r_id, {
            room_status: 1,
            slave_id: null, slave_pid: null, slave_name: null, slave_level: null, slave_image: null,
            battle_count: room.battle_count + 1,
        });
    }
    const updatedPlayer = repository_1.PlayerRepo.findById(player.id);
    response.data = {
        win: isWin ? 1 : 0,
        money: updatedPlayer.money,
        exploit: updatedPlayer.exploit,
        dianka: updatedPlayer.dianka,
        rongyu: updatedPlayer.rongyu,
        relativeName,
    };
    res.json(response);
});
// POST /api/leitai/heartbeat - 擂台心跳 (Head.HTTP_NEW_LEITAI_HEARTBEAT = 10037)
router.post('/heartbeat', (req, res) => {
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    res.json(response);
});
// POST /api/leitai/rank - 擂台排行榜 (Head.HTTP_NEW_LEITAI_PAIHANG = 10038)
router.post('/rank', (req, res) => {
    console.log(`[Leitai] 排行榜`);
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    response.data = {
        paihang: [
            { roleName: '虚位以待', score: 0 },
            { roleName: '虚位以待', score: 0 },
            { roleName: '虚位以待', score: 0 },
        ]
    };
    res.json(response);
});
exports.default = router;
