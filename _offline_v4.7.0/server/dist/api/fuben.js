"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const repository_1 = require("../db/repository");
const router = (0, express_1.Router)();
// POST /api/fuben/count - 获取副本次数 (Head.HTTP_NEW_FUBEN_COUNT = 10016)
router.post('/count', (req, res) => {
    const { roleID, stageID } = req.body;
    console.log(`[Fuben] 副本次数: roleID=${roleID}, stageID=${stageID}`);
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    response.data = { stageID, count: 2 }; // Default 2 entries per dungeon
    res.json(response);
});
// POST /api/fuben/enter - 进入副本 (Head.HTTP_NEW_FUBEN_LOGIN = 10017)
router.post('/enter', (req, res) => {
    const { roleID, stageID, proto } = req.body;
    console.log(`[Fuben] 进入副本: roleID=${roleID}, stageID=${stageID}`);
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    if (!player) {
        response.success = false;
        response.message = '玩家不存在';
        res.json(response);
        return;
    }
    response.data = { stageID, proto };
    res.json(response);
});
// POST /api/fuben/award - 副本奖励 (Head.HTTP_NEW_FUBEN_AWARD = 10018)
router.post('/award', (req, res) => {
    const { roleID, stageID, index, level, result } = req.body;
    console.log(`[Fuben] 副本奖励: roleID=${roleID}, stageID=${stageID}, index=${index}`);
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    if (!player) {
        response.success = false;
        response.message = '玩家不存在';
        res.json(response);
        return;
    }
    const stageLevel = parseInt(level) || 1;
    let multiplier = 1;
    switch (parseInt(index)) {
        case 1:
            multiplier = 100;
            break;
        case 2:
            multiplier = 200;
            break;
        case 3:
            multiplier = 300;
            break;
    }
    const moneyReward = stageLevel * multiplier;
    const exploitReward = stageLevel * multiplier / 2;
    const reverenceReward = stageLevel * multiplier / 2;
    repository_1.PlayerRepo.update(player.id, {
        money: player.money + moneyReward,
        exploit: player.exploit + exploitReward,
        reverence: player.reverence + reverenceReward,
    });
    const updatedPlayer = repository_1.PlayerRepo.findById(player.id);
    response.data = {
        stageID,
        index,
        result,
        forward: [updatedPlayer.money, updatedPlayer.exploit, updatedPlayer.reverence],
    };
    // Add flip cards on index 3
    if (parseInt(index) === 3) {
        response.data.pai = [
            '2|10000', // 金币奖励
            '1|proto_2_1|1', // 道具
            '1|proto_2_6|5',
            '1|proto_3_1|1',
            '1|proto_3_3|1',
            '1|proto_3_4|1',
        ];
    }
    res.json(response);
});
// POST /api/fuben/flip - 翻牌 (Head.HTTP_NEW_FUBEN_FANPAI = 10019)
router.post('/flip', (req, res) => {
    const { roleID, result } = req.body;
    console.log(`[Fuben] 翻牌: roleID=${roleID}, result=${result}`);
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    if (!player) {
        response.success = false;
        response.message = '玩家不存在';
        res.json(response);
        return;
    }
    if (result) {
        const parts = String(result).split('|');
        if (parts[0] === '2') {
            // Money reward
            const moneyAmount = parseInt(parts[1]) || 0;
            repository_1.PlayerRepo.update(player.id, { money: player.money + moneyAmount });
            response.data = { money: player.money + moneyAmount };
        }
        else {
            // Item reward
            const itemCode = parts[1];
            const itemCount = parseInt(parts[2]) || 1;
            response.data = {
                item: { id: Math.floor(Math.random() * 100000), code: itemCode, count: itemCount }
            };
        }
    }
    res.json(response);
});
exports.default = router;
