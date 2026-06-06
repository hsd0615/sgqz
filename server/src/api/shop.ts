import { Router, Request, Response } from 'express';
import { PlayerRepo, BagItemRepo } from '../db/repository';
import { APIResponse } from '../models/types';

const router = Router();

// Shop item definitions (matches game XML config)
const SHOP_ITEMS: Record<number, { code: string; count: number; payType: number; price: number }> = {
  1:  { code: 'proto_1_1', count: 1,  payType: 1, price: 500 },   // 金币购买
  2:  { code: 'proto_1_2', count: 1,  payType: 1, price: 500 },
  3:  { code: 'proto_1_3', count: 1,  payType: 1, price: 500 },
  4:  { code: 'proto_1_4', count: 1,  payType: 1, price: 500 },
  5:  { code: 'proto_1_5', count: 1,  payType: 1, price: 500 },
  6:  { code: 'proto_2_1', count: 1,  payType: 2, price: 10 },   // 点卡购买
  7:  { code: 'proto_2_2', count: 1,  payType: 2, price: 10 },
  8:  { code: 'proto_2_3', count: 1,  payType: 2, price: 10 },
  9:  { code: 'proto_2_4', count: 1,  payType: 2, price: 10 },
  10: { code: 'proto_2_5', count: 1,  payType: 2, price: 10 },
  11: { code: 'proto_2_6', count: 1,  payType: 2, price: 10 },
  12: { code: 'proto_2_7', count: 1,  payType: 2, price: 10 },
  13: { code: 'proto_2_8', count: 1,  payType: 2, price: 10 },
  14: { code: 'proto_3_1', count: 1,  payType: 1, price: 2000 },
  15: { code: 'proto_3_2', count: 1,  payType: 1, price: 2000 },
  16: { code: 'proto_3_3', count: 1,  payType: 1, price: 5000 },
  17: { code: 'proto_3_4', count: 1,  payType: 1, price: 10000 },
};

// POST /api/shop/buy - 购买道具 (Head.HTTP_NEW_BUYITEM = 10010)
router.post('/buy', (req: Request, res: Response) => {
  const { roleID, shopID } = req.body;
  console.log(`[Shop] 购买: roleID=${roleID}, shopID=${shopID}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) { response.success = false; response.message = '玩家不存在'; res.json(response); return; }

  const shopItem = SHOP_ITEMS[parseInt(shopID)];
  if (!shopItem) {
    response.success = false;
    response.message = '商品不存在';
    res.json(response);
    return;
  }

  // Check affordability
  if (shopItem.payType === 1 && player.money < shopItem.price) {
    response.success = false;
    response.message = '金币不足';
    res.json(response);
    return;
  }
  if (shopItem.payType === 2 && player.dianka < shopItem.price) {
    response.success = false;
    response.message = '点卡不足';
    res.json(response);
    return;
  }

  // Process purchase
  if (shopItem.payType === 1) {
    PlayerRepo.update(player.id, { money: player.money - shopItem.price } as any);
  } else {
    PlayerRepo.update(player.id, { dianka: player.dianka - shopItem.price } as any);
  }

  // Add item to bag
  const existingItem = BagItemRepo.findItem(player.id, shopItem.code);
  let itemId: number;
  let itemCount: number;

  if (existingItem) {
    itemId = existingItem.id;
    itemCount = existingItem.item_count + shopItem.count;
  } else {
    itemId = Math.floor(Math.random() * 100000);
    itemCount = shopItem.count;
  }
  BagItemRepo.updateOrCreate(player.id, shopItem.code, itemCount, itemId);

  const updatedPlayer = PlayerRepo.findById(player.id)!;
  response.data = {
    money: updatedPlayer.money,
    dianka: updatedPlayer.dianka,
    exploit: updatedPlayer.exploit,
    reverence: updatedPlayer.reverence,
    item: {
      id: itemId,
      code: shopItem.code,
      count: itemCount,
    }
  };

  res.json(response);
});

// POST /api/shop/dianka - 查询点卡余额 (Head.HTTP_NEW_DIANKA = 10009)
router.post('/dianka', (req: Request, res: Response) => {
  const { roleID } = req.body;
  console.log(`[Shop] 查询点卡: roleID=${roleID}`);

  const player = PlayerRepo.findByRoleId(String(roleID));
  const response: APIResponse = { success: true, stamp: req.body.stamp, head: String(req.body.head) };

  if (!player) { response.success = false; response.message = '玩家不存在'; res.json(response); return; }

  response.data = { dianka: player.dianka };
  res.json(response);
});

export default router;
