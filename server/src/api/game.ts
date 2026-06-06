import { Router, Request, Response } from 'express';
import { PlayerRepo, GeneralRepo, BagItemRepo } from '../db/repository';
import { APIResponse } from '../models/types';

const router = Router();

// POST /api/game/fight-result - 单机关卡战斗结果 (Head.HTTP_NEW_FIGHT_RESULT = 10011)
router.post('/fight-result', (req: Request, res: Response) => {
  const { roleID, part, level, m, n } = req.body;
  console.log(`[Game] 战斗结果: roleID=${roleID}, part=${part}, level=${level}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) {
    response.success = false;
    response.message = '玩家不存在';
    res.json(response);
    return;
  }

  // Simple reward calculation
  const moneyReward = 100 + (part * 50) + (level * 20);
  const exploitReward = 50 + (part * 20) + (level * 10);
  const reverenceReward = 30 + (part * 10) + (level * 5);

  const newMoney = player.money + moneyReward;
  const newExploit = player.exploit + exploitReward;
  const newReverence = player.reverence + reverenceReward;

  // Update finished stages
  const stageId = `${part}_${level}`;
  const finished = player.finished_stages ? player.finished_stages.split('|') : [];
  if (!finished.includes(stageId)) {
    finished.push(stageId);
  }

  PlayerRepo.update(player.id, {
    money: newMoney,
    exploit: newExploit,
    reverence: newReverence,
    level: Math.max(player.level, level),
    finished_stages: finished.join('|'),
  } as any);

  response.data = {
    m: newMoney,
    e: newExploit,
    r: newReverence,
    money: moneyReward,
    exploit: exploitReward,
    reverence: reverenceReward,
    part: part,
    level: level,
    finished: finished.join('|'),
  };

  res.json(response);
});

// POST /api/game/p2p-result - P2P 战斗结果 (Head.HTTP_NEW_P2PFIGHT_RESULT = 10012)
router.post('/p2p-result', (req: Request, res: Response) => {
  const { roleID, flag, m, n, relativeName } = req.body;
  console.log(`[Game] P2P结果: roleID=${roleID}, flag=${flag}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) {
    response.success = false;
    response.message = '玩家不存在';
    res.json(response);
    return;
  }

  if (flag === 1) {
    // Win
    const moneyGain = 100 + (m || 0) * 10;
    const exploitGain = 50 + (n || 0) * 5;
    PlayerRepo.update(player.id, {
      money: player.money + moneyGain,
      exploit: player.exploit + exploitGain,
      reverence: player.reverence + 10,
      win_count: player.win_count + 1,
    } as any);
    response.data = {
      flag: 1,
      money: player.money + moneyGain,
      exploit: player.exploit + exploitGain,
      reverence: player.reverence + 10,
      winCount: player.win_count + 1,
      lostCount: player.lost_count,
      relativeName,
    };
  } else if (flag === 0) {
    // Lose
    PlayerRepo.update(player.id, {
      lost_count: player.lost_count + 1,
    } as any);
    response.data = {
      flag: 0,
      money: player.money,
      exploit: player.exploit,
      reverence: player.reverence,
      winCount: player.win_count,
      lostCount: player.lost_count + 1,
      relativeName,
    };
  } else {
    // Offline (opponent disconnected)
    PlayerRepo.update(player.id, {
      money: player.money + 50,
      exploit: player.exploit + 200,
      reverence: player.reverence + 10,
    } as any);
    response.data = {
      flag: -1,
      money: player.money + 50,
      exploit: player.exploit + 200,
      reverence: player.reverence + 10,
      winCount: player.win_count,
      lostCount: player.lost_count,
      relativeName,
    };
  }

  res.json(response);
});

// POST /api/game/save - 存档 (HTTP_SAVE_DATA = 18)
router.post('/save', (req: Request, res: Response) => {
  const { roleID, roleModel } = req.body;
  console.log(`[Game] 存档: roleID=${roleID}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) {
    response.success = false;
    response.message = '玩家不存在';
    res.json(response);
    return;
  }

  if (roleModel) {
    const updateData: any = {};
    if (roleModel.level !== undefined) updateData.level = roleModel.level;
    if (roleModel.money !== undefined) updateData.money = roleModel.money;
    if (roleModel.exploit !== undefined) updateData.exploit = roleModel.exploit;
    if (roleModel.reverence !== undefined) updateData.reverence = roleModel.reverence;
    if (roleModel.dianka !== undefined) updateData.dianka = roleModel.dianka;
    if (roleModel.finished !== undefined) updateData.finished_stages = roleModel.finished;
    if (roleModel.history !== undefined) updateData.history = roleModel.history;
    if (Object.keys(updateData).length > 0) {
      PlayerRepo.update(player.id, updateData);
    }
  }

  res.json(response);
});

// POST /api/game/history - 保存历史进度 (Head.HTTP_NEW_SAVE_HISTORY = 10014)
router.post('/history', (req: Request, res: Response) => {
  const { roleID, history } = req.body;
  console.log(`[Game] 保存历史: roleID=${roleID}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) {
    response.success = false;
    response.message = '玩家不存在';
    res.json(response);
    return;
  }

  PlayerRepo.update(player.id, { history } as any);
  response.data = { history };

  res.json(response);
});

// POST /api/game/use-ammo - 使用弹药 (Head.HTTP_NEW_USE_AMMO = 10013)
router.post('/use-ammo', (req: Request, res: Response) => {
  const { roleID, id: itemId } = req.body;
  console.log(`[Game] 使用弹药: roleID=${roleID}, itemId=${itemId}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) {
    response.success = false;
    response.message = '玩家不存在';
    res.json(response);
    return;
  }

  // Decrease ammo count by 1
  const items = BagItemRepo.findByPlayerId(player.id);
  const item = items.find(i => i.id === parseInt(itemId));
  if (item && item.item_count > 0) {
    BagItemRepo.updateOrCreate(player.id, item.item_code, item.item_count - 1, item.id);
  }

  response.data = { itemID: itemId };
  res.json(response);
});

// POST /api/game/verify - 验证码验证 (Head.HTTP_NEW_YANZHENG = 10015)
router.post('/verify', (req: Request, res: Response) => {
  const { roleID } = req.body;
  console.log(`[Game] 验证: roleID=${roleID}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (player) {
    PlayerRepo.update(player.id, { money: player.money + 500 } as any);
    response.data = { money: (player.money + 500) };
  } else {
    response.success = false;
    response.message = '验证失败';
  }

  res.json(response);
});

export default router;
