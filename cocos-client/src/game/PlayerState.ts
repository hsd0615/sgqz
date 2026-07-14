/**
 * 玩家状态管理 — 替代 game/model/RoleModel.as
 *
 * 管理: 货币、武将列表、背包、关卡进度、装备
 * 支持: 存档/读档 (完整 data.json 格式)
 */

import {
  PlayerData, ArmyInfo, BagItem, SoldierType,
} from '../types';
import { GeneralData } from '../data/DataAccess';

// ========== 默认初始数据 ==========

const DEFAULT_PLAYER: PlayerData = {
  roleID: 1, userID: 'player', roleName: '刘备', imageID: 1,
  level: 1, exp: 0, money: 5000, dianka: 100, exploit: 1000,
  reverence: 500, rongyu: 0,
  winCount: 0, lostCount: 0, ranking: 0,
  chooseSoldiers: [],
  finishedStages: [], history: [],
  unlockedRecruits: [],
};

// ========== 玩家状态类 ==========

export class PlayerState {
  data: PlayerData;
  generals: ArmyInfo[] = [];
  bag: BagItem[] = [];

  constructor(data?: Partial<PlayerData>) {
    this.data = { ...DEFAULT_PLAYER, ...data };
  }

  // ========== 属性访问 ==========

  get level() { return this.data.level; }
  set level(v: number) { this.data.level = v; }
  get money() { return this.data.money; }
  set money(v: number) { this.data.money = v; }
  get dianka() { return this.data.dianka; }
  set dianka(v: number) { this.data.dianka = v; }
  get exploit() { return this.data.exploit; }
  set exploit(v: number) { this.data.exploit = v; }
  get reverence() { return this.data.reverence; }
  set reverence(v: number) { this.data.reverence = v; }
  get rongyu() { return this.data.rongyu; }
  set rongyu(v: number) { this.data.rongyu = v; }

  // ========== 武将管理 ==========

  /** 添加武将 */
  addGeneral(gen: ArmyInfo): void {
    // 检查重复
    if (this.generals.some(g => g.code === gen.code && g.id === gen.id)) {
      return;
    }
    this.generals.push(gen);
  }

  /** 查找武将 */
  findGeneral(id: number): ArmyInfo | null {
    return this.generals.find(g => g.id === id) || null;
  }

  /** 获取所有武将 */
  getAllGenerals(): ArmyInfo[] {
    return [...this.generals];
  }

  /** 获取上阵武将 */
  getDeployed(): ArmyInfo[] {
    if (this.data.chooseSoldiers.length === 0) {
      // 自动选前5个
      return this.generals.slice(0, Math.min(5, this.generals.length));
    }
    return this.data.chooseSoldiers
      .map(code => this.generals.find(g => g.code === code))
      .filter(Boolean) as ArmyInfo[];
  }

  /** 设置上阵 */
  deployGenerals(codes: string[]): void {
    this.data.chooseSoldiers = codes;
  }

  /** 获取已拥有的所有武将 code */
  getOwnedCodes(): string[] {
    return this.generals.map(g => g.code);
  }

  /** 武将升级 */
  upgradeGeneral(id: number, costMoney: number, costExploit: number): boolean {
    const gen = this.findGeneral(id);
    if (!gen) return false;

    if (this.money < costMoney || this.exploit < costExploit) return false;
    // 已解除武将等级不能超过君主等级的限制

    this.money -= costMoney;
    this.exploit -= costExploit;
    gen.level += 1;

    // 重新计算属性 (简化)
    const scale = 1 + (gen.level - 1) * 0.08;
    const quality = 1 + (4 - gen.title) * 0.1;
    gen.attack = Math.round(gen.baseAttack! * scale * quality / (1 + (gen.level - 2) * 0.08));
    gen.defense = Math.round(gen.baseDefense! * scale * quality / (1 + (gen.level - 2) * 0.08));
    gen.maxHp = Math.round(gen.baseHp! * scale * quality / (1 + (gen.level - 2) * 0.08));
    gen.hp = gen.maxHp;

    return true;
  }

  // ========== 背包管理 ==========

  addItem(code: string, count: number = 1): void {
    const existing = this.bag.find(i => i.code === code);
    if (existing) {
      existing.count += count;
    } else {
      this.bag.push({ id: Date.now(), code, count });
    }
  }

  removeItem(code: string, count: number = 1): boolean {
    const existing = this.bag.find(i => i.code === code);
    if (!existing || existing.count < count) return false;
    existing.count -= count;
    if (existing.count <= 0) {
      this.bag = this.bag.filter(i => i.code !== code);
    }
    return true;
  }

  getItemCount(code: string): number {
    const item = this.bag.find(i => i.code === code);
    return item?.count || 0;
  }

  // ========== 关卡进度 ==========

  isStageFinished(stageId: number): boolean {
    return this.data.finishedStages.includes(stageId);
  }

  completeStage(stageId: number): void {
    if (!this.data.finishedStages.includes(stageId)) {
      this.data.finishedStages.push(stageId);
    }
  }

  // ========== 招募解锁 ==========

  unlockRecruit(code: string): void {
    if (!this.data.unlockedRecruits.includes(code)) {
      this.data.unlockedRecruits.push(code);
    }
  }

  getUnlockedRecruits(): string[] {
    return [...this.data.unlockedRecruits];
  }

  // ========== 经验 & 升级 ==========

  addExp(exp: number): boolean {
    this.data.exp += exp;
    const nextLevelExp = this.data.level * 100;
    if (this.data.exp >= nextLevelExp) {
      this.data.exp -= nextLevelExp;
      this.data.level += 1;
      return true; // 升级了
    }
    return false;
  }

  // ========== 序列化 ==========

  toJSON(): object {
    return {
      player: this.data,
      generals: this.generals,
      bag: this.bag,
    };
  }

  static fromJSON(json: any): PlayerState {
    const state = new PlayerState(json.player || {});
    state.generals = json.generals || [];
    state.bag = json.bag || [];
    return state;
  }
}
