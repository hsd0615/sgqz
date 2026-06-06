import { Router, Request, Response } from 'express';
import { PlayerRepo, GeneralRepo, BagItemRepo } from '../db/repository';
import { APIResponse } from '../models/types';

const router = Router();

// POST /api/general/recruit - 武将招募 (Head.HTTP_NEW_PUTONG_ZHAOMU = 10001)
//                                    (Head.HTTP_NEW_QIUXIAN_ZHAOMU = 10002)
//                                    (Head.HTTP_NEW_DIANKA_ZHAOMU = 10003)
router.post('/recruit', (req: Request, res: Response) => {
  const { roleID, code, head, name } = req.body;
  console.log(`[General] 招募: roleID=${roleID}, code=${code}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(head) };

  if (!player) {
    response.success = false; response.message = '玩家不存在'; res.json(response); return;
  }

  const headCode = parseInt(head);
  let success = false;

  switch (headCode) {
    case 10001: // 普通招募 - 扣金币+声望
      if (player.money >= 1000 && player.reverence >= 1000) {
        PlayerRepo.update(player.id, {
          money: player.money - 1000,
          reverence: player.reverence - 1000
        } as any);
        success = Math.random() < 0.5;
      }
      break;
    case 10002: // 求贤招募 - 扣声望
      if (player.reverence >= 1000) {
        PlayerRepo.update(player.id, { reverence: player.reverence - 1000 } as any);
        success = Math.random() < 0.6;
        // Remove recruit item
        BagItemRepo.removeItem(player.id, 'proto_3_3', 1);
      }
      break;
    case 10003: // 点卡招募 - 扣点卡+声望
      if (player.dianka >= 20 && player.reverence >= 1000) {
        PlayerRepo.update(player.id, {
          dianka: player.dianka - 20,
          reverence: player.reverence - 1000
        } as any);
        success = Math.random() < 0.8;
      }
      break;
  }

  response.data = {
    money: PlayerRepo.findById(player.id)!.money,
    dianka: PlayerRepo.findById(player.id)!.dianka,
    reverence: PlayerRepo.findById(player.id)!.reverence,
  };

  if (success && code) {
    const generalName = name || ('武将_' + code);
    const starterLevel = player.level > 50 ? 30 : 1;
    const general = GeneralRepo.create(player.id, {
      code,
      name: generalName,
      level: starterLevel,
      evolution: 0,
      feature: 0,
    });
    response.data.general = {
      id: general.general_id,
      code: general.code,
      level: general.level,
      evolution: general.evolution,
      feature: general.feature,
      genius: general.tianfu,
      kezhi: `${general.kezhi1}:${general.kezhi1_level}|${general.kezhi2}:${general.kezhi2_level}|${general.kezhi3}:${general.kezhi3_level}`,
    };
  }

  // Update item ID for recruit token
  const item = BagItemRepo.findItem(player.id, 'proto_3_3');
  if (item) {
    response.data.itemID = item.id;
  }

  res.json(response);
});

// POST /api/general/upgrade - 武将升级 (Head.HTTP_NEW_GENERAL_SHENGJI = 10004)
router.post('/upgrade', (req: Request, res: Response) => {
  const { roleID, id: generalId } = req.body;
  console.log(`[General] 升级: roleID=${roleID}, generalId=${generalId}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) { response.success = false; response.message = '玩家不存在'; res.json(response); return; }

  const general = GeneralRepo.findById(parseInt(generalId));
  if (!general) { response.success = false; response.message = '武将不存在'; res.json(response); return; }

  if (general.level >= 220) {
    response.success = false;
    response.message = '武将已经顶级，无法继续升级';
    res.json(response);
    return;
  }

  const costMoney = 100;
  const costExploit = 100;
  if (player.money < costMoney || player.exploit < costExploit) {
    response.success = false;
    response.message = '资源不足';
    res.json(response);
    return;
  }

  GeneralRepo.update(general.id, { level: general.level + 1 });
  PlayerRepo.update(player.id, {
    money: player.money - costMoney,
    exploit: player.exploit - costExploit
  } as any);

  response.data = {
    money: player.money - costMoney,
    exploit: player.exploit - costExploit,
    id: generalId,
    level: general.level + 1
  };

  res.json(response);
});

// POST /api/general/evolve - 武将进化 (Head.HTTP_NEW_GENERAL_JINHUA = 10005)
router.post('/evolve', (req: Request, res: Response) => {
  const { roleID, id: generalId } = req.body;
  console.log(`[General] 进化: roleID=${roleID}, generalId=${generalId}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) { response.success = false; response.message = '玩家不存在'; res.json(response); return; }

  const general = GeneralRepo.findById(parseInt(generalId));
  if (!general) { response.success = false; response.message = '武将不存在'; res.json(response); return; }

  if (general.evolution >= 10) {
    response.success = false;
    response.message = '武将已经为进化上限';
    res.json(response);
    return;
  }

  if (player.money < 1000) {
    response.success = false;
    response.message = '金币不足';
    res.json(response);
    return;
  }

  // Evolution success rate: 50% + 5% per evolution level (capped)
  const rate = Math.min(0.5 + general.evolution * 0.05, 0.95);
  const success = Math.random() < rate;

  const updates: any = {};
  if (success) {
    updates.evolution = general.evolution + 1;
    // Assign random feature on first evolution for non-siege units
    if (general.evolution === 0 && !general.code.includes('toushiche')) {
      updates.feature = Math.floor(Math.random() * 4) + 1; // 1-4: 冰火风雷
    }
  }

  PlayerRepo.update(player.id, { money: player.money - 1000 } as any);

  response.data = {
    money: player.money - 1000,
  };

  if (success) {
    GeneralRepo.update(general.id, updates);
    const updated = GeneralRepo.findById(general.id)!;
    response.data.general = {
      id: updated.general_id,
      code: updated.code,
      level: updated.level,
      evolution: updated.evolution,
      feature: updated.feature,
      genius: updated.tianfu,
      kezhi: `${updated.kezhi1}:${updated.kezhi1_level}|${updated.kezhi2}:${updated.kezhi2_level}|${updated.kezhi3}:${updated.kezhi3_level}`,
    };
  }

  res.json(response);
});

// POST /api/general/kezhi - 克制升级 (Head.HTTP_NEW_GENERAL_KEZHI_SHENGJI = 10006)
router.post('/kezhi', (req: Request, res: Response) => {
  const { roleID, id: generalId, index } = req.body;
  console.log(`[General] 克制升级: roleID=${roleID}, generalId=${generalId}, index=${index}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) { response.success = false; response.message = '玩家不存在'; res.json(response); return; }

  const general = GeneralRepo.findById(parseInt(generalId));
  if (!general) { response.success = false; response.message = '武将不存在'; res.json(response); return; }

  if (player.money < 1000 || player.exploit < 1000) {
    response.success = false;
    response.message = '资源不足';
    res.json(response);
    return;
  }

  // Success rate based on current level
  const currentLevel = index === 0 ? general.kezhi1_level : (index === 1 ? general.kezhi2_level : general.kezhi3_level);
  const rate = Math.max(0.1, 1.0 - currentLevel * 0.1);
  const success = Math.random() < rate;

  PlayerRepo.update(player.id, { money: player.money - 1000, exploit: player.exploit - 1000 } as any);

  // Consume item
  BagItemRepo.removeItem(player.id, 'proto_3_4', 1);
  const item = BagItemRepo.findItem(player.id, 'proto_3_4');

  response.data = {
    money: player.money - 1000,
    exploit: player.exploit - 1000,
    itemID: item?.id || null,
    index,
  };

  if (success) {
    const updates: any = {};
    if (index === 0) updates.kezhi1_level = general.kezhi1_level + 1;
    else if (index === 1) updates.kezhi2_level = general.kezhi2_level + 1;
    else updates.kezhi3_level = general.kezhi3_level + 1;
    GeneralRepo.update(general.id, updates);

    const updated = GeneralRepo.findById(general.id)!;
    response.data.general = {
      id: updated.general_id,
      code: updated.code,
      level: updated.level,
      evolution: updated.evolution,
      feature: updated.feature,
      genius: updated.tianfu,
      kezhi: `${updated.kezhi1}:${updated.kezhi1_level}|${updated.kezhi2}:${updated.kezhi2_level}|${updated.kezhi3}:${updated.kezhi3_level}`,
    };
  }

  res.json(response);
});

// POST /api/general/talent - 天赋洗练 (Head.HTTP_NEW_GENERAL_TIANFU = 10007)
router.post('/talent', (req: Request, res: Response) => {
  const { roleID, id: generalId } = req.body;
  console.log(`[General] 天赋: roleID=${roleID}, generalId=${generalId}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) { response.success = false; response.message = '玩家不存在'; res.json(response); return; }

  const general = GeneralRepo.findById(parseInt(generalId));
  if (!general) { response.success = false; response.message = '武将不存在'; res.json(response); return; }

  const costDianka = general.tianfu ? 100 : 0;
  if (costDianka > 0 && player.dianka < costDianka) {
    response.success = false;
    response.message = '点卡不足';
    res.json(response);
    return;
  }

  // Random talent
  const talentPool = Array.from({ length: 21 }, (_, i) => `tf_${i + 1}`);
  const newTalent = talentPool[Math.floor(Math.random() * talentPool.length)];

  GeneralRepo.update(general.id, { tianfu: newTalent } as any);
  if (costDianka > 0) {
    PlayerRepo.update(player.id, { dianka: player.dianka - costDianka } as any);
  }

  const updated = GeneralRepo.findById(general.id)!;
  response.data = {
    dianka: player.dianka - costDianka,
    general: {
      id: updated.general_id,
      code: updated.code,
      level: updated.level,
      evolution: updated.evolution,
      feature: updated.feature,
      genius: updated.tianfu,
      kezhi: `${updated.kezhi1}:${updated.kezhi1_level}|${updated.kezhi2}:${updated.kezhi2_level}|${updated.kezhi3}:${updated.kezhi3_level}`,
    }
  };

  res.json(response);
});

// POST /api/general/deploy - 上阵 (Head.HTTP_NEW_SHANGZHEN = 10008)
router.post('/deploy', (req: Request, res: Response) => {
  const { roleID, choose } = req.body;
  console.log(`[General] 上阵: roleID=${roleID}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) { response.success = false; response.message = '玩家不存在'; res.json(response); return; }

  const chooseIds = choose ? choose.split('|').map(Number) : [];
  GeneralRepo.setDeployed(player.id, chooseIds);

  response.data = { choose };
  res.json(response);
});

// POST /api/general/reforge - 属性重铸 (Head.HTTP_NEW_SHUXINGCHONGXI = 10020)
router.post('/reforge', (req: Request, res: Response) => {
  const { roleID, id: generalId } = req.body;
  console.log(`[General] 重铸: roleID=${roleID}, generalId=${generalId}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) { response.success = false; response.message = '玩家不存在'; res.json(response); return; }

  if (player.dianka < 100) {
    response.success = false;
    response.message = '点卡不足';
    res.json(response);
    return;
  }

  const general = GeneralRepo.findById(parseInt(generalId));
  if (!general) { response.success = false; response.message = '武将不存在'; res.json(response); return; }

  // Random new feature
  const newFeature = Math.floor(Math.random() * 4) + 1;
  GeneralRepo.update(general.id, { feature: newFeature } as any);
  PlayerRepo.update(player.id, { dianka: player.dianka - 100 } as any);

  response.data = {
    dianka: player.dianka - 100,
    feature: newFeature,
  };

  res.json(response);
});

export default router;
