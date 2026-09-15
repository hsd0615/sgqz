/**
 * 伤害计算公式 — 从 game/Logic.as 1:1 移植
 *
 * 包含完整的 9 种组合公式:
 *   - 兵种克制 (Bingzhong Kezhi): 根据克制等级提升攻/防
 *   - 属性克制 (Shuxiang Kezhi): 火冰风雷暗五行相克
 *   - 装备加成: 增伤/减伤/暴击/暴伤/吸血
 *   - 闪避
 *   - 投石车特殊公式
 */

import { SoldierType, GUNNER_TYPE } from '../types';

// ========== 常量 (来自 Logic.as) ==========

/** 克制系数 — 10级, 每级递增5% */
export const KEZHI_XISHU: number[] = [
  1, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45, 1.5
];

/** 克制进阶概率 — 10级 (%) */
export const KEZHI_JILV: number[] = [
  100, 85, 70, 55, 40, 28, 20, 14, 10, 7
];

/** 克制加成比例 — 10级 (%) */
export const KEZHI_BILV: number[] = [
  0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50
];

/** 进化成功率 */
export const JINHUA_JILV: number[] = [
  100, 70, 30, 15, 5, 3, 2, 1.5, 1, 0.5
];

/** 进化属性加成系数 */
export const EVOLUTION_ADDITION: number[] = [
  0.05, 0.08, 0.11, 0.15, 0.22, 0.26, 0.32, 0.38, 0.42, 0.50
];

// ========== 伤害计算输入 ==========

export interface DamageInput {
  /** 攻击方攻击力 */
  attack: number;
  /** 攻击方兵种类型 */
  attackerType: number;
  /** 攻击方克制集: [kezhi1, kezhi2, kezhi3] */
  attackerKezhi: number[];
  /** 攻击方克制等级: [level1, level2, level3] */
  attackerKezhiLevel: number[];
  /** 攻击方属性 (0-4) */
  attackerFeature: number;
  /** 攻击方装备增伤 % */
  equipDmgBonus: number;
  /** 攻击方装备暴击率 % */
  equipCritRate: number;
  /** 攻击方装备暴击伤害 % */
  equipCritDmg: number;
  /** 攻击方装备吸血 % */
  equipLifesteal: number;

  /** 防御方防御力 */
  defense: number;
  /** 防御方兵种类型 */
  defenderType: number;
  /** 防御方属性 (0-4) */
  defenderFeature: number;
  /** 防御方闪避率 % */
  shanbi: number;
  /** 防御方装备减伤 % */
  equipDmgReduce: number;
}

export interface DamageOutput {
  damage: number;
  isCrit: boolean;
  isDodged: boolean;
  lifestealHeal: number;
}

// ========== 辅助函数 ==========

/** 检查攻击方是否克制防御方兵种 */
function checkBingzhongKezhi(
  attackerKezhi: number[],
  defenderType: number
): { kezhi: number; levelIndex: number } {
  for (let i = 0; i < attackerKezhi.length; i++) {
    if (attackerKezhi[i] === defenderType && attackerKezhi[i] > 0) {
      return { kezhi: 1, levelIndex: i };
    }
  }
  // TODO: 逆向克制: 若防御方克制攻击方, kezhi = -1
  // 此处需要防御方的克制数据, 先简化处理
  return { kezhi: 0, levelIndex: 0 };
}

/** 检查属性克制 (五行相克) */
function checkShuxiangKezhi(
  attackerFeature: number,
  defenderFeature: number
): number {
  if (attackerFeature === 0 || defenderFeature === 0) return 0;

  const diff = attackerFeature - defenderFeature;
  // 正向: diff==-1 或 diff==3 → 攻击方克制
  if (diff === -1 || diff === 3) return 1;
  // 反向: diff==1 或 diff==-3 → 防御方克制
  if (diff === 1 || diff === -3) return -1;
  return 0;
}

/** 获取克制系数 (根据等级) */
function getKezhiXishu(level: number): number {
  const idx = Math.max(0, Math.min(level, KEZHI_XISHU.length - 1));
  return KEZHI_XISHU[idx];
}

// ========== 核心伤害公式 ==========

/**
 * 计算伤害值
 * 完全复刻 Logic.getHurtVale() — 9种组合
 */
export function calculateDamage(input: DamageInput): DamageOutput {
  const {
    attack, attackerType, attackerKezhi, attackerKezhiLevel,
    attackerFeature, equipDmgBonus, equipCritRate, equipCritDmg,
    equipLifesteal, defense, defenderType, defenderFeature,
    shanbi, equipDmgReduce,
  } = input;

  const result: DamageOutput = {
    damage: 0,
    isCrit: false,
    isDodged: false,
    lifestealHeal: 0,
  };

  // --- 闪避判定 ---
  if (shanbi > 0 && Math.random() * 100 < shanbi) {
    result.isDodged = true;
    return result;
  }

  // --- 兵种克制 & 属性克制 ---
  const bk = checkBingzhongKezhi(attackerKezhi, defenderType);
  const sk = checkShuxiangKezhi(attackerFeature, defenderFeature);

  const bingzhongKezhi = bk.kezhi;
  const kezhiLevel = attackerKezhiLevel[bk.levelIndex] || 0;

  // --- 9 种组合公式 ---
  let baseDamage: number;
  const kx = getKezhiXishu(kezhiLevel);

  // 类型转换: 君主 → 骑兵
  const atkType = attackerType === SoldierType.JUNZHU ? SoldierType.QIBING : attackerType;
  const defType = defenderType === SoldierType.JUNZHU ? SoldierType.QIBING : defenderType;

  // 投石车特殊处理
  if (atkType === GUNNER_TYPE) {
    baseDamage = getToushicheDamage(attack, defense, attackerFeature, defenderFeature);
  } else if (bingzhongKezhi === 0 && sk === 0) {
    // 情况1: 无克制
    baseDamage = attack - defense / 5;
  } else if (bingzhongKezhi === 1 && sk === 0) {
    // 情况2: 仅兵种克制 (正向)
    baseDamage = attack * kx - defense / 5;
  } else if (bingzhongKezhi === -1 && sk === 0) {
    // 情况3: 仅兵种被克 (反向)
    baseDamage = attack - (defense * kx) / 5;
  } else if (bingzhongKezhi === 0 && sk === 1) {
    // 情况4: 仅属性克制 (正向)
    baseDamage = attack * 1.2 - defense / 5;
  } else if (bingzhongKezhi === 0 && sk === -1) {
    // 情况5: 仅属性被克 (反向)
    baseDamage = attack - (defense * 1.2) / 5;
  } else if (bingzhongKezhi === 1 && sk === 1) {
    // 情况6: 双重克制 (正向+正向)
    baseDamage = attack * kx * 1.2 - defense / 5;
  } else if (bingzhongKezhi === -1 && sk === 1) {
    // 情况7: 兵种被克 属性克制
    baseDamage = attack * 1.2 - (defense * kx) / 5;
  } else if (bingzhongKezhi === 1 && sk === -1) {
    // 情况8: 兵种克制 属性被克
    baseDamage = attack * kx - (defense * 1.2) / 5;
  } else if (bingzhongKezhi === -1 && sk === -1) {
    // 情况9: 双重被克
    baseDamage = attack - (defense * kx * 1.2) / 5;
  } else {
    baseDamage = attack - defense / 5;
  }

  // 保证最小伤害为 1
  let damage = Math.max(1, Math.round(baseDamage));

  // --- 装备增伤 ---
  if (equipDmgBonus > 0) {
    damage = Math.round(damage * (1 + equipDmgBonus / 100));
  }

  // --- 装备减伤 ---
  if (equipDmgReduce > 0) {
    damage = Math.round(damage * (1 - equipDmgReduce / 100));
  }

  // --- 暴击判定 ---
  if (equipCritRate > 0 && Math.random() * 100 < equipCritRate) {
    damage = Math.round(damage * (150 + equipCritDmg) / 100);
    result.isCrit = true;
  }

  // --- 吸血 ---
  if (equipLifesteal > 0) {
    result.lifestealHeal = Math.round(damage * equipLifesteal / 100);
  }

  result.damage = Math.max(1, damage);
  return result;
}

/**
 * 投石车特殊伤害公式
 * 来自 Logic.getHurtByToushiche()
 */
function getToushicheDamage(
  attack: number,
  defense: number,
  attackerFeature: number,
  defenderFeature: number
): number {
  let dmg = attack - defense / 5;

  // 属性克制 (简化版: 仅 ±20%)
  if (attackerFeature > 0 && defenderFeature > 0) {
    const diff = attackerFeature - defenderFeature;
    if (diff === -1 || diff === 3) {
      dmg = attack * 1.2 - defense / 5;
    } else if (diff === 1 || diff === -3) {
      dmg = attack - (defense * 1.2) / 5;
    }
  }

  return dmg;
}

/**
 * 投石车带弹药伤害
 * 来自 Logic.getHurtByToushiche() 完整版
 */
export function getToushicheDamageWithAmmo(
  attack: number,
  defense: number,
  attackerFeature: number,
  defenderFeature: number,
  ammoFlatDamage: number,
  ammoHpPercent: number,
  targetMaxHp: number
): number {
  let dmg = getToushicheDamage(attack, defense, attackerFeature, defenderFeature);
  dmg += ammoFlatDamage;
  dmg += Math.round(targetMaxHp * ammoHpPercent / 100);
  return dmg;
}

// ========== 其他公式 ==========

/** 升级所需银子 */
export function getMoneyByLevel(level: number): number {
  return 2 * level * (level - 1) + 100;
}

/** 升级所需功勋 */
export function getExploitByLevel(level: number): number {
  return level * (level - 1) + 100;
}

/** 关卡战斗奖励 — 银子 */
export function getMoneyByFight(levelDiff: number): number {
  return 100 + levelDiff * 50;
}

/** 关卡战斗奖励 — 功勋 */
export function getExploitByFight(levelDiff: number): number {
  return 50 + levelDiff * 20;
}

/** 关卡战斗奖励 — 声望 */
export function getReverenceByFight(levelDiff: number): number {
  return 30 + levelDiff * 10;
}

/** 进化加成 */
export function getEvolutionAddition(evolution: number): number {
  const idx = Math.max(0, Math.min(evolution - 1, EVOLUTION_ADDITION.length - 1));
  return evolution > 0 ? EVOLUTION_ADDITION[idx] : 0;
}

// 品质乘数: 超级(0)=1.3, 一流(1)=1.0, 二流(2)=0.8, 三流(3)=0.65
const TITLE_MULTIPLIER: number[] = [1.3, 1.0, 0.8, 0.65];

/** 基础 HP 计算公式 */
export function getBaseHP(
  type: number,
  title: number,
  level: number,
  hpA: number,
  hpB: number,
  hpC: number
): number {
  const titleBonus = (4 - title) * 0.1; // 品质加成: 超级+40%, 一流+30%...
  const raw = Math.round(hpA * level * level + hpB * level + hpC * (1 + titleBonus));
  return Math.round(raw * (TITLE_MULTIPLIER[title] || 1.0));
}

/** 基础攻击计算公式 */
export function getBaseAttack(
  type: number,
  title: number,
  level: number,
  attackA: number,
  attackB: number,
  attackC: number
): number {
  const titleBonus = (4 - title) * 0.1;
  const raw = Math.round(attackA * level * level + attackB * level + attackC * (1 + titleBonus));
  return Math.round(raw * (TITLE_MULTIPLIER[title] || 1.0));
}

/** 基础防御计算公式 */
export function getBaseDefense(
  type: number,
  title: number,
  level: number,
  defenseA: number,
  defenseB: number,
  defenseC: number
): number {
  const titleBonus = (4 - title) * 0.1;
  const raw = Math.round(defenseA * level * level + defenseB * level + defenseC * (1 + titleBonus));
  return Math.round(raw * (TITLE_MULTIPLIER[title] || 1.0));
}
