import { findOne, findMany, insert, update, remove, getAll, updateWhere, getNextId } from './database';
import { Player, General, BagItem, LeitaiRoom } from '../models/types';
import { v4 as uuidv4 } from 'uuid';

// ============== Player Repository ==============
export const PlayerRepo = {
  findByUserId(userId: string): Player | undefined {
    return findOne('players', (p: any) => String(p.user_id) === String(userId)) as Player | undefined;
  },

  findById(id: number): Player | undefined {
    return findOne('players', (p: any) => p.id === id) as Player | undefined;
  },

  findByRoleId(roleId: string): Player | undefined {
    return findOne('players', (p: any) => p.id === parseInt(roleId)) as Player | undefined;
  },

  findByUserIdAndPassword(userId: string, password: string): Player | undefined {
    return findOne('players', (p: any) => String(p.user_id) === String(userId) && p.password === password) as Player | undefined;
  },

  create(userId: string, roleName: string, imageId: number, agent: string, password: string = ''): Player {
    const token = uuidv4().replace(/-/g, '');
    const player = insert('players', {
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
    return player as any as Player;
  },

  update(id: number, data: Partial<Player>): void {
    update('players', id, { ...data, updated_at: new Date().toISOString() });
  },

  generateToken(id: number): string {
    const token = uuidv4().replace(/-/g, '');
    PlayerRepo.update(id, { token } as any);
    return token;
  }
};

// ============== General Repository ==============
export const GeneralRepo = {
  findByPlayerId(playerId: number): General[] {
    return findMany('generals', (g: any) => g.player_id === playerId) as General[];
  },

  findById(id: number): General | undefined {
    return findOne('generals', (g: any) => g.id === id) as General | undefined;
  },

  create(playerId: number, data: Partial<General>): General {
    const general = insert('generals', {
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
    return general as any as General;
  },

  update(id: number, data: Partial<General>): void {
    update('generals', id, data);
  },

  delete(id: number): void {
    remove('generals', id);
  },

  getDeployed(playerId: number): General[] {
    return findMany('generals', (g: any) => g.player_id === playerId && g.is_deployed === 1) as General[];
  },

  setDeployed(playerId: number, generalIds: number[]): void {
    updateWhere('generals', (g: any) => g.player_id === playerId, { is_deployed: 0 });
    if (generalIds.length > 0) {
      for (const gid of generalIds) {
        updateWhere('generals', (g: any) => g.player_id === playerId && g.general_id === gid, { is_deployed: 1 });
      }
    }
  }
};

// ============== BagItem Repository ==============
export const BagItemRepo = {
  findByPlayerId(playerId: number): BagItem[] {
    return findMany('bagItems', (b: any) => b.player_id === playerId) as BagItem[];
  },

  findItem(playerId: number, itemCode: string): BagItem | undefined {
    return findOne('bagItems', (b: any) => b.player_id === playerId && b.item_code === itemCode) as BagItem | undefined;
  },

  updateOrCreate(playerId: number, itemCode: string, count: number, itemId?: number): void {
    const existing = BagItemRepo.findItem(playerId, itemCode);
    if (existing) {
      update('bagItems', existing.id, { item_count: count });
    } else {
      insert('bagItems', {
        player_id: playerId,
        item_code: itemCode,
        item_count: count,
        created_at: new Date().toISOString(),
      });
    }
  },

  getCount(playerId: number, itemCode: string): number {
    const item = BagItemRepo.findItem(playerId, itemCode);
    return item ? item.item_count : 0;
  },

  addItem(playerId: number, itemCode: string, addCount: number): void {
    const current = BagItemRepo.getCount(playerId, itemCode);
    BagItemRepo.updateOrCreate(playerId, itemCode, current + addCount);
  },

  removeItem(playerId: number, itemCode: string, removeCount: number): void {
    const current = BagItemRepo.getCount(playerId, itemCode);
    const newCount = Math.max(0, current - removeCount);
    BagItemRepo.updateOrCreate(playerId, itemCode, newCount);
  }
};

// ============== Leitai Repository ==============
export const LeitaiRepo = {
  findAll(): LeitaiRoom[] {
    return getAll('leitaiRooms').sort((a: any, b: any) =>
      b.room_level - a.room_level || a.r_id - b.r_id
    ) as LeitaiRoom[];
  },

  findById(rId: number): LeitaiRoom | undefined {
    return findOne('leitaiRooms', (r: any) => r.r_id === rId) as LeitaiRoom | undefined;
  },

  update(rId: number, data: Partial<LeitaiRoom>): void {
    updateWhere('leitaiRooms', (r: any) => r.r_id === rId, data);
  },

  initDefaultRooms(): void {
    if (getAll('leitaiRooms').length > 0) return;

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
        insert('leitaiRooms', {
          r_id: getNextId('leitaiRooms') + (level.lv * 100) + type,
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
    console.log(`初始化擂台房间完成: ${getAll('leitaiRooms').length} 个房间`);
  }
};
