"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const repository_1 = require("../db/repository");
const router = (0, express_1.Router)();
// POST /api/misc/award - 领取奖励 (Head.HTTP_NEW_GETAWARD = 10021)
router.post('/award', (req, res) => {
    const { roleID } = req.body;
    console.log(`[Misc] 领取奖励: roleID=${roleID}`);
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    if (!player) {
        response.success = false;
        response.message = '玩家不存在';
        res.json(response);
        return;
    }
    // Daily login reward
    const moneyBonus = 100;
    const exploitBonus = 100;
    repository_1.PlayerRepo.update(player.id, {
        money: player.money + moneyBonus,
        exploit: player.exploit + exploitBonus,
    });
    response.data = {
        money: player.money + moneyBonus,
        exploit: player.exploit + exploitBonus,
        general: [],
        item: [],
    };
    res.json(response);
});
// POST /api/misc/compensate - 补偿领取 (Head.HTTP_NEW_BUCHANG = 10022)
router.post('/compensate', (req, res) => {
    const { roleID } = req.body;
    console.log(`[Misc] 补偿: roleID=${roleID}`);
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    if (!player) {
        response.success = false;
        response.message = '玩家不存在';
        res.json(response);
        return;
    }
    // Compensation rewards
    const moneyBonus = 1000;
    const exploitBonus = 200;
    const reverenceBonus = 300;
    repository_1.PlayerRepo.update(player.id, {
        money: player.money + moneyBonus,
        exploit: player.exploit + exploitBonus,
        reverence: player.reverence + reverenceBonus,
    });
    response.data = {
        money: player.money + moneyBonus,
        exploit: player.exploit + exploitBonus,
        reverence: player.reverence + reverenceBonus,
        item: [{ id: 2, code: 'proto_3_2', count: 19 }],
        general: [],
    };
    res.json(response);
});
// POST /api/misc/claim-dianka - 领取点卡 (Head.HTTP_NEW_LING_DIANKA = 10040)
router.post('/claim-dianka', (req, res) => {
    const { roleID } = req.body;
    console.log(`[Misc] 领取点卡: roleID=${roleID}`);
    const player = repository_1.PlayerRepo.findByRoleId(String(roleID));
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    if (!player) {
        response.success = false;
        response.message = '玩家不存在';
        res.json(response);
        return;
    }
    repository_1.PlayerRepo.update(player.id, { dianka: player.dianka + 10 });
    response.data = {
        dianka: player.dianka + 10,
    };
    res.json(response);
});
// POST /api/misc/guoqing - 国庆活动 (Head.HTTP_NEW_GUOQING = 10041)
router.post('/guoqing', (req, res) => {
    console.log(`[Misc] 国庆活动`);
    const player = repository_1.PlayerRepo.findByRoleId(String(req.body.roleID));
    const response = { success: true, stamp: req.body.stamp, head: String(req.body.head) };
    if (player) {
        repository_1.PlayerRepo.update(player.id, {
            money: player.money + 500,
            exploit: player.exploit + 200,
        });
    }
    response.data = {
        money: (player?.money || 0) + 500,
        exploit: (player?.exploit || 0) + 200,
    };
    res.json(response);
});
exports.default = router;
