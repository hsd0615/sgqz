"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createTestAccounts = createTestAccounts;
const repository_1 = require("./db/repository");
function createTestAccounts() {
    // 检查是否已存在
    const existing = repository_1.PlayerRepo.findByUserId('gm_admin');
    if (existing) {
        console.log('[TestData] 测试账号已存在，跳过');
        return;
    }
    console.log('[TestData] 创建测试账号...');
    // ===== 测试账号1: gm_admin (满级超级武将) =====
    const p1 = repository_1.PlayerRepo.create('gm_admin', 'GM管理员', 1, '4399', 'admin123');
    repository_1.PlayerRepo.update(p1.id, {
        level: 220,
        money: 99999999,
        dianka: 999999,
        exploit: 99999999,
        reverence: 99999999,
        rongyu: 99999,
        finished_stages: Array.from({ length: 30 }, (_, i) => (i + 1)).join('|'),
        history: '1,1,1,1,1,1,1,1,1,1',
    });
    // 超级武将列表 (max level 220)
    const superGenerals = [
        { code: 'general_9_18', name: '吕布', kezhi: '6:1|1:1|8:1' }, // 骑兵超级
        { code: 'general_9_20', name: '马超', kezhi: '6:1|1:1|8:1' }, // 骑兵超级
        { code: 'general_9_16', name: '夏侯惇', kezhi: '6:1|1:1|8:1' }, // 骑兵超级
        { code: 'general_7_19', name: '赵云', kezhi: '5:1|4:1|7:1' }, // 长枪超级
        { code: 'general_7_14', name: '张飞', kezhi: '5:1|4:1|7:1' }, // 长枪超级
        { code: 'general_3_13', name: '关羽', kezhi: '2:1|1:1|6:1' }, // 朴刀超级
        { code: 'general_1_15', name: '黄忠', kezhi: '5:1|7:1|9:1' }, // 弓兵超级
        { code: 'general_1_23', name: '姜维', kezhi: '5:1|7:1|9:1' }, // 弓兵超级
        { code: 'general_2_11', name: '貂蝉', kezhi: '5:1|4:1|7:1' }, // 飞刀超级
        { code: 'general_6_15', name: '魏延', kezhi: '6:1|1:1|8:1' }, // 武斗超级
        { code: 'general_0_1', name: '投石车', kezhi: '3:1|8:1|9:1' }, // 攻城超级
    ];
    const chooseCodes = [];
    for (const g of superGenerals) {
        const kezhiParts = g.kezhi.split('|');
        const general = repository_1.GeneralRepo.create(p1.id, {
            code: g.code, name: g.name,
            level: 220, evolution: 10, feature: 1, tianfu: 'tf_20',
            kezhi1: parseInt(kezhiParts[0]?.split(':')[0]) || 0,
            kezhi1_level: 10,
            kezhi2: parseInt(kezhiParts[1]?.split(':')[0]) || 0,
            kezhi2_level: 10,
            kezhi3: parseInt(kezhiParts[2]?.split(':')[0]) || 0,
            kezhi3_level: 10,
        });
        repository_1.GeneralRepo.setDeployed(p1.id, [general.general_id]);
        chooseCodes.push(g.code);
    }
    // Add some bag items
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_1_1', 999, 90001);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_1_2', 999, 90002);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_1_3', 999, 90003);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_1_4', 999, 90004);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_1_5', 999, 90005);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_2_1', 99, 90006);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_2_2', 99, 90007);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_2_3', 99, 90008);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_2_4', 99, 90009);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_2_5', 99, 90010);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_2_6', 99, 90011);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_2_7', 99, 90012);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_2_8', 99, 90013);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_3_1', 99, 90014);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_3_2', 99, 90015);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_3_3', 99, 90016);
    repository_1.BagItemRepo.updateOrCreate(p1.id, 'proto_3_4', 99, 90017);
    console.log('[TestData] 测试账号1: gm_admin / admin123 (11个满级超级武将)');
    // ===== 测试账号2: test_pro (通关前3图) =====
    const p2 = repository_1.PlayerRepo.create('test_pro', '测试高手', 1, '4399', 'pro123');
    repository_1.PlayerRepo.update(p2.id, {
        level: 100,
        money: 500000,
        dianka: 50000,
        exploit: 500000,
        reverence: 500000,
        rongyu: 5000,
        finished_stages: Array.from({ length: 40 }, (_, i) => (i + 1)).join('|'),
        history: '1,1,1,1,1,1,1,1,1,1',
    });
    // 给一些一流武将
    const proGenerals = [
        { code: 'general_9_15', name: '张辽', kezhi: '6:1|1:1|8:1' },
        { code: 'general_9_13', name: '徐晃', kezhi: '6:1|1:1|8:1' },
        { code: 'general_1_13', name: '吕蒙', kezhi: '5:1|7:1|9:1' },
        { code: 'general_1_11', name: '黄盖', kezhi: '5:1|7:1|9:1' },
        { code: 'general_9_0', name: '鞠义', kezhi: '3:1|4:1|8:1' },
        { code: 'general_1_0', name: '王平', kezhi: '5:1|7:1|9:1' },
        { code: 'general_3_0', name: '吕翔', kezhi: '2:1|1:1|6:1' },
        { code: 'general_0_1', name: '投石车', kezhi: '3:1|8:1|9:1' },
        { code: 'general_4_3', name: '陈震', kezhi: '6:1|1:1|8:1' },
    ];
    for (const g of proGenerals) {
        const kezhiParts = g.kezhi.split('|');
        repository_1.GeneralRepo.create(p2.id, {
            code: g.code, name: g.name,
            level: 80, evolution: 5, feature: 2,
            kezhi1: parseInt(kezhiParts[0]?.split(':')[0]) || 0, kezhi1_level: 5,
            kezhi2: parseInt(kezhiParts[1]?.split(':')[0]) || 0, kezhi2_level: 5,
            kezhi3: parseInt(kezhiParts[2]?.split(':')[0]) || 0, kezhi3_level: 5,
        });
    }
    repository_1.GeneralRepo.setDeployed(p2.id, proGenerals.map((g, i) => i + 1));
    repository_1.BagItemRepo.updateOrCreate(p2.id, 'proto_1_1', 50, 80001);
    repository_1.BagItemRepo.updateOrCreate(p2.id, 'proto_2_1', 20, 80002);
    repository_1.BagItemRepo.updateOrCreate(p2.id, 'proto_3_1', 20, 80003);
    repository_1.BagItemRepo.updateOrCreate(p2.id, 'proto_3_4', 20, 80004);
    console.log('[TestData] 测试账号2: test_pro / pro123 (通关4图, 80级武将)');
    // ===== 测试账号3: new_player (新玩家) =====
    const p3 = repository_1.PlayerRepo.create('new_player', '新兵报到', 1, '4399', 'new123');
    console.log('[TestData] 测试账号3: new_player / new123 (新玩家，5初始武将)');
    console.log('[TestData] 所有测试账号创建完成!');
}
