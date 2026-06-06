import { Router, Request, Response } from 'express';
import { getAll } from '../db/database';
import { PlayerRepo, GeneralRepo } from '../db/repository';
import { APIResponse } from '../models/types';

const router = Router();

// POST /api/auth/login - 登录 (Head.HTTP_NEW_LOGIN = 9999)
router.post('/login', (req: Request, res: Response) => {
  const { userID, agent, ver, head, password } = req.body;
  console.log(`[Auth] 登录请求: userID=${userID}, agent=${agent}, ver=${ver}`);

  const response: APIResponse = {
    success: true,
    stamp: req.body.stamp,
    head: String(head),
  };

  if (userID && password) {
    // 带密码：验证登录
    let player = PlayerRepo.findByUserIdAndPassword(String(userID), String(password));

    if (player) {
      const token = PlayerRepo.generateToken(player.id);

      // Login returns minimal data only — generals loaded separately
      response.data = {
        flag: 1,
        token: token,
        currentTime: Date.now(),
        dianka: player.dianka,
        armyModel: [],
        bagModel: [],
        process: {history: player.history || '', finished: player.finished_stages || ''},
        roleModel: {
          roleID: player.id,
          agent: player.agent,
          userID: player.user_id,
          userName: '',
          roleName: player.role_name,
          imageID: player.image_id,
          level: player.level,
          exp: player.exp,
          money: player.money,
          dianka: player.dianka,
          exploit: player.exploit,
          reverence: player.reverence,
          rongyu: player.rongyu,
          winCount: player.win_count,
          lostCount: player.lost_count,
          ranking: 0,
          score: 0,
          choose: '',
          finished: player.finished_stages,
          history: player.history,
          loginServer: player.login_server,
        }
      };
    } else {
      // 密码错误或用户不存在
      const existingPlayer = PlayerRepo.findByUserId(String(userID));
      if (existingPlayer) {
        response.success = false;
        response.message = '密码错误';
      } else {
        response.success = false;
        response.message = '账号不存在，请先注册';
      }
    }
  } else {
    // 无密码：新玩家
    const existing = PlayerRepo.findByUserId(String(userID));
    if (existing) {
      response.success = false;
      response.message = '该账号已存在，请输入密码';
    } else {
      response.data = {
      flag: 2,
      token: '',
      currentTime: Date.now(),
      dianka: 0,
      armyModel: [],
      bagModel: [],
      process: {history: '', finished: ''},
    };
  }
  }

  res.json(response);
});

// POST /api/auth/register - 注册 (Head.HTTP_NEW_REGISTER = 10000)
router.post('/register', (req: Request, res: Response) => {
  const { userID, roleName, imageID, password, token: reqToken, agent, ver, head } = req.body;
  console.log(`[Auth] 注册请求: userID=${userID}, roleName=${roleName}, imageID=${imageID}`);

  const response: APIResponse = {
    success: true,
    stamp: req.body.stamp,
    head: String(head),
  };

  // Check if user already exists
  const existing = PlayerRepo.findByUserId(String(userID));
  if (existing) {
    response.success = false;
    response.message = '该账号已创建过角色';
    res.json(response);
    return;
  }

  const player = PlayerRepo.create(String(userID), roleName, imageID, agent || '4399', password || '');

  // 初始武将（三国Q战新春版）
  const starterGenerals = [
    { code: 'general_1_0', name: '王平', kezhi: '5:1|7:1|9:1' },
    { code: 'general_3_0', name: '吕翔', kezhi: '2:1|1:1|6:1' },
    { code: 'general_0_1', name: '投石车', kezhi: '3:1|8:1|9:1' },
    { code: 'general_4_3', name: '陈震', kezhi: '6:1|1:1|8:1' },
    { code: 'general_9_0', name: '鞠义', kezhi: '6:1|1:1|8:1' },
  ];

  const armyModel: any[] = [];
  const chooseCodes: string[] = [];
  for (const g of starterGenerals) {
    const kezhiParts = g.kezhi.split('|');
    const general = GeneralRepo.create(player.id, {
      code: g.code,
      name: g.name,
      level: 1, evolution: 0, feature: 0, tianfu: null,
      kezhi1: parseInt(kezhiParts[0]?.split(':')[0]) || 0,
      kezhi1_level: parseInt(kezhiParts[0]?.split(':')[1]) || 1,
      kezhi2: parseInt(kezhiParts[1]?.split(':')[0]) || 0,
      kezhi2_level: parseInt(kezhiParts[1]?.split(':')[1]) || 1,
      kezhi3: parseInt(kezhiParts[2]?.split(':')[0]) || 0,
      kezhi3_level: parseInt(kezhiParts[2]?.split(':')[1]) || 1,
    });
    armyModel.push({
      id: general.general_id,
      code: general.code,
      genius: general.tianfu,
      level: general.level,
      feature: general.feature,
      evolution: general.evolution,
      kezhi: g.kezhi,
    });
    chooseCodes.push(g.code);
  }

  response.data = {
    token: player.token,
    dianka: 99999999,
    armyModel: armyModel,
    bagModel: [],
    process: {history: '', finished: ''},
    roleModel: {
      roleID: player.id,
      agent: player.agent,
      userID: player.user_id,
      userName: '',
      roleName: player.role_name,
      imageID: player.image_id,
      level: player.level,
      exp: player.exp,
      money: player.money,
      dianka: player.dianka,
      exploit: player.exploit,
      reverence: player.reverence,
      rongyu: player.rongyu,
      winCount: player.win_count,
      lostCount: player.lost_count,
      ranking: 0,
      score: 0,
      choose: chooseCodes.join('|'),
      finished: '',
      history: '',
      loginServer: 0,
    }
  };

  res.json(response);
});

// GET /api/auth/players - 获取所有角色列表（无需密码）
router.get('/players', (req: Request, res: Response) => {
  const allPlayers = getAll('players');
  const list = allPlayers.map((p: any) => ({
    userID: p.user_id,
    roleName: p.role_name,
    level: p.level,
    imageID: p.image_id,
    money: p.money,
    exploit: p.exploit,
    dianka: p.dianka,
  }));
  res.json({ success: true, data: list });
});

// POST /api/auth/active - 激活旧账号 (Head.HTTP_NEW_ACTIVE = 9998)
router.post('/active', (req: Request, res: Response) => {
  const { userID } = req.body;
  console.log(`[Auth] 激活账号: userID=${userID}`);

  const player = PlayerRepo.findByUserId(String(userID));
  const response: APIResponse = {
    success: true,
    stamp: req.body.stamp,
    head: String(req.body.head),
    data: { token: player?.token || '' }
  };

  if (!player) {
    response.success = false;
    response.message = '账号不存在';
  }

  res.json(response);
});

export default router;
