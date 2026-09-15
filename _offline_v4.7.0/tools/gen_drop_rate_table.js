#!/usr/bin/env node
/**
 * 三国Q战 - 各关卡装备掉落概率分析
 *
 * 按服务端 start_fixed.js 实际公式计算每关掉率
 * 用法: node tools/gen_drop_rate_table.js
 * 输出: 桌面/三国Q战_掉落概率分析.html
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

const BASE = path.dirname(__dirname);

// ============ 读取数据文件 ============

function loadXML(filePath) {
  return fs.readFileSync(filePath, 'utf-8');
}

// 读取 staticgeneral.xml → 武将品质映射 (title字段)
function loadGeneralQuality() {
  const xml = loadXML(path.join(BASE, 'staticgeneral.xml'));
  const recs = xml.split('<RECORD>');
  const map = {};
  for (let i = 1; i < recs.length; i++) {
    const cm = recs[i].match(/<code>([^<]+)<\/code>/);
    const tm = recs[i].match(/<title>(\d+)<\/title>/);
    const nm = recs[i].match(/<name>([^<]+)<\/name>/);
    if (cm && tm) {
      map[cm[1]] = { quality: parseInt(tm[1]), name: nm ? nm[1] : cm[1] };
    }
  }
  return map;
}

// 读取 stage.xml → 每关敌人数据
function loadStageData() {
  const xml = loadXML(path.join(BASE, 'stage.xml'));
  const gates = xml.split('<gate');
  const stages = [];
  for (let i = 1; i < gates.length; i++) {
    const pm = gates[i].match(/part="(\d+)"/);
    const lm = gates[i].match(/level="(\d+)"/);
    const nm = gates[i].match(/name="([^"]+)"/);
    if (!pm || !lm) continue;
    const part = parseInt(pm[1]);
    const level = parseInt(lm[1]);
    const stageName = nm ? nm[1] : '';
    const partNameMatch = gates[i].match(/partName="([^"]+)"/);
    const partName = partNameMatch ? partNameMatch[1] : '';

    const gens = gates[i].match(/<general[^>]*\/>/g) || [];
    const enemies = [];
    for (let j = 0; j < gens.length; j++) {
      const cm = gens[j].match(/code="([^"]+)"/);
      const lvm = gens[j].match(/level="(\d+)"/);
      const enm = gens[j].match(/name="([^"]+)"/);
      enemies.push({
        code: cm ? cm[1] : '',
        level: parseInt(lvm ? lvm[1] : '1'),
        name: enm ? enm[1] : ''
      });
    }
    stages.push({ part, level, stageName, partName, enemies });
  }
  return stages;
}

// 读取 staticequip.xml → 装备品质分布
function loadEquipData() {
  const xml = loadXML(path.join(BASE, 'staticequip.xml'));
  const recs = xml.split('<RECORD>');
  const qualityCount = {};
  const qualityItems = {};
  for (let i = 1; i < recs.length; i++) {
    const qm = recs[i].match(/<quality>(\d+)<\/quality>/);
    const nm = recs[i].match(/<name>([^<]+)<\/name>/);
    const cm = recs[i].match(/<code>([^<]+)<\/code>/);
    if (qm) {
      const q = parseInt(qm[1]);
      qualityCount[q] = (qualityCount[q] || 0) + 1;
      if (!qualityItems[q]) qualityItems[q] = [];
      qualityItems[q].push(nm ? nm[1] : (cm ? cm[1] : '?'));
    }
  }
  return { qualityCount, qualityItems };
}

// ============ 掉落计算公式 (完全复刻 start_fixed.js) ============

// 投石车(type=0)不掉装备
function canDropEquip(code) {
  return !(code || '').match(/^general_0_/);
}

// 根据品质获取掉率参数
function getDropParams(genQ) {
  if (genQ === 0) return { minQ: 7, maxQ: 10, rateDiv: 3000 };
  if (genQ === 1) return { minQ: 4, maxQ: 7, rateDiv: 1800 };
  if (genQ === 2) return { minQ: 2, maxQ: 5, rateDiv: 900 };
  return { minQ: 1, maxQ: 3, rateDiv: 450 }; // genQ >= 3
}

// 单个敌人掉率
function calcEnemyDropProb(genLevel, genQ) {
  if (genLevel < 1) genLevel = 1;
  const { rateDiv } = getDropParams(genQ);
  return Math.min(0.40, Math.max(0.003, genLevel / rateDiv));
}

const QUALITY_NAMES = ['', '普通', '精良', '稀有', '史诗', '传说', '神话', '远古', '至尊', '超凡', '入圣'];

// ============ 计算 ============

const genQualityMap = loadGeneralQuality();
const stages = loadStageData();
const equipData = loadEquipData();

console.log(`武将品质映射: ${Object.keys(genQualityMap).length} 个`);
console.log(`关卡总数: ${stages.length} 个`);
console.log(`装备品质分布: ${JSON.stringify(equipData.qualityCount)}`);

// 为每个关卡计算掉率
const stageResults = [];
let globalMaxPart = 0;

for (const stage of stages) {
  if (stage.part > globalMaxPart) globalMaxPart = stage.part;

  const enemyProbs = [];
  let totalProb = 0;
  let bestQuality = 0;
  let worstQuality = 10;
  let dropEnemies = 0;
  const enemyDetails = [];

  for (const enemy of stage.enemies) {
    if (!canDropEquip(enemy.code)) {
      enemyDetails.push({
        ...enemy,
        canDrop: false,
        reason: '投石车',
        genQ: 0,
        prob: 0,
        qRange: '-'
      });
      continue;
    }

    const genInfo = genQualityMap[enemy.code];
    const genQ = genInfo ? genInfo.quality : 3; // 默认三流
    const genName = genInfo ? genInfo.name : enemy.code;

    const { minQ, maxQ, rateDiv } = getDropParams(genQ);
    const prob = calcEnemyDropProb(enemy.level, genQ);

    enemyDetails.push({
      ...enemy,
      canDrop: true,
      genQ,
      genName,
      prob,
      qRange: `Q${minQ}-Q${maxQ}`,
      rateDiv,
      minQ,
      maxQ
    });

    enemyProbs.push(prob);
    if (prob > 0) {
      dropEnemies++;
      if (minQ < worstQuality) worstQuality = minQ;
      if (maxQ > bestQuality) bestQuality = maxQ;
    }
  }

  // 每局至少有一个掉落的总概率
  let stageProb = 0;
  if (enemyProbs.length > 0) {
    stageProb = 1 - enemyProbs.reduce((acc, p) => acc * (1 - p), 1);
  }
  totalProb = stageProb;

  // 计算平均掉率信息
  const avgEnemyLevel = stage.enemies.reduce((s, e) => s + e.level, 0) / Math.max(1, stage.enemies.length);

  // 战后兜底 (fn = 敌方平均等级)
  const fn = Math.max(1, Math.round(avgEnemyLevel));
  const fallbackActive = fn >= 5;
  let fallbackParams = null;
  if (fallbackActive) {
    // fpart-based quality determination
    let eqQuality = 3; // fpart <= 2
    if (stage.part <= 2) eqQuality = 3;
    else if (stage.part <= 4) eqQuality = 2;
    else if (stage.part <= 7) eqQuality = 1;
    else eqQuality = 0;
    const fbParams = getDropParams(eqQuality);
    const fbProb = Math.min(0.40, Math.max(0.003, fn / fbParams.rateDiv));
    fallbackParams = {
      eqQuality,
      minQ: fbParams.minQ,
      maxQ: fbParams.maxQ,
      rateDiv: fbParams.rateDiv,
      prob: fbProb,
      fn
    };
  }

  stageResults.push({
    part: stage.part,
    level: stage.level,
    stageName: stage.stageName,
    partName: stage.partName,
    enemyCount: stage.enemies.length,
    dropEnemies,
    avgEnemyLevel: avgEnemyLevel.toFixed(1),
    stageProb,
    bestQuality,
    worstQuality,
    fallbackActive,
    fallbackParams,
    enemyDetails,
    fn
  });
}

// ============ 后处理: 按part分组聚合 ============

const partGroups = {};
for (const r of stageResults) {
  if (!partGroups[r.part]) {
    partGroups[r.part] = {
      part: r.part,
      partName: r.partName,
      stages: [],
      totalStages: 0,
      avgProb: 0,
      minProb: 1,
      maxProb: 0,
      qualityRange: ''
    };
  }
  const g = partGroups[r.part];
  g.stages.push(r);
  g.totalStages++;
  g.avgProb += r.stageProb;
  if (r.stageProb < g.minProb) g.minProb = r.stageProb;
  if (r.stageProb > g.maxProb) g.maxProb = r.stageProb;
}
for (const key of Object.keys(partGroups)) {
  const g = partGroups[key];
  g.avgProb = g.avgProb / g.totalStages;
  // quality range
  const allQ = new Set();
  for (const s of g.stages) {
    for (const e of s.enemyDetails) {
      if (e.canDrop) {
        for (let q = e.minQ; q <= e.maxQ; q++) allQ.add(q);
      }
    }
  }
  const qArr = Array.from(allQ).sort((a, b) => a - b);
  g.qualityRange = qArr.length > 0 ? `Q${qArr[0]}-Q${qArr[qArr.length - 1]}` : '-';
}

// ============ HTML 生成 ============

function pctStr(v) { return (v * 100).toFixed(2) + '%'; }
function pctColor(v) {
  if (v >= 0.10) return '#00cc00';
  if (v >= 0.05) return '#cccc00';
  if (v >= 0.02) return '#cc8800';
  if (v >= 0.01) return '#cc4400';
  return '#cc0000';
}
function qColor(q) {
  const colors = ['#999','#CCC','#CCC','#CCC','#4bea13','#16d2fa','#e720f9','#FFD700','#FF6600','#FF4444','#FF0000'];
  return colors[q] || '#CCC';
}

const html = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<title>三国Q战 - 装备掉落概率分析</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body { font-family: 'Microsoft YaHei', sans-serif; background: #1a1a2e; color: #eee; padding: 20px; }
h1 { text-align:center; color: #FFD700; margin-bottom: 5px; }
.subtitle { text-align:center; color: #999; margin-bottom: 20px; font-size: 13px; }
.toc { max-width: 1200px; margin: 0 auto 30px; background: #16213e; border-radius: 8px; padding: 20px; }
.toc h2 { color: #FFD700; margin-bottom: 15px; font-size: 16px; }
.toc table { width: 100%; border-collapse: collapse; font-size: 13px; }
.toc th { background: #0f3460; padding: 8px 10px; text-align: center; }
.toc td { padding: 6px 10px; text-align: center; border-bottom: 1px solid #333; }
.toc tr:hover { background: rgba(255,255,255,0.03); }
.part-link { color: #4bea13; text-decoration: none; }
.part-link:hover { text-decoration: underline; }

.formula-box { max-width: 1200px; margin: 0 auto 30px; background: #16213e; border-radius: 8px; padding: 20px; }
.formula-box h2 { color: #FFD700; margin-bottom: 10px; font-size: 16px; }
.formula-box pre { background: #0a0a1a; padding: 15px; border-radius: 4px; overflow-x: auto; font-size: 12px; line-height: 1.6; color: #aaa; }
.formula-box .hl { color: #FFD700; }
.formula-box .hl2 { color: #4bea13; }

.part-section { max-width: 1200px; margin: 0 auto 30px; background: #16213e; border-radius: 8px; overflow: hidden; }
.part-header { background: #0f3460; padding: 12px 20px; cursor: pointer; display: flex; justify-content: space-between; align-items: center; }
.part-header:hover { background: #1a4a80; }
.part-header h2 { color: #FFD700; font-size: 15px; }
.part-header .part-stats { font-size: 12px; color: #aaa; }
.part-body { padding: 15px; }
.part-body table { width: 100%; border-collapse: collapse; font-size: 12px; }
.part-body th { background: #0f3460; padding: 6px 8px; text-align: center; position: sticky; top: 0; }
.part-body td { padding: 5px 8px; text-align: center; border-bottom: 1px solid #2a2a4a; }
.part-body tr:hover { background: rgba(255,255,255,0.03); }
.enemy-pop { cursor: pointer; position: relative; }
.enemy-pop:hover .popup { display: block; }
.popup { display: none; position: absolute; bottom: 100%; left: 50%; transform: translateX(-50%); background: #0f3460; border: 1px solid #4bea13; border-radius: 6px; padding: 8px 12px; white-space: nowrap; z-index: 10; font-size: 11px; }
.no-drop { color: #cc0000; }
.has-drop { color: #4bea13; }
.fallback-yes { color: #4bea13; }
.fallback-no { color: #cc0000; }
.legend { max-width: 1200px; margin: 20px auto; font-size: 12px; color: #999; }
.legend span { margin-right: 20px; }
</style>
</head>
<body>

<h1>⚔ 三国Q战 - 装备掉落概率分析</h1>
<div class="subtitle">基于服务端 start_fixed.js 实际公式计算 | 版本 v4.0.3 | ${new Date().toISOString().slice(0, 10)}</div>

<div class="formula-box">
<h2>📐 掉落计算公式（战前预计算 /api/game/fight-prepare）</h2>
<pre>
<b class="hl">对每个敌方武将:</b>
  genQ = parseGeneralQuality(code)    <span class="hl2">// 0=超级 1=一流 2=二流 3=三流 (默认)</span>
  genLevel = 武将个体等级

  <b class="hl">根据genQ确定参数:</b>
  genQ=0(超级): minQ=7, maxQ=10, rateDiv=3000  → 可掉落Q7-Q10装备
  genQ=1(一流): minQ=4, maxQ=7,  rateDiv=1800  → 可掉落Q4-Q7装备
  genQ=2(二流): minQ=2, maxQ=5,  rateDiv=900   → 可掉落Q2-Q5装备
  genQ=3(三流): minQ=1, maxQ=3,  rateDiv=450   → 可掉落Q1-Q3装备

  <b class="hl">掉率 = min(40%, max(0.3%, genLevel / rateDiv))</b>
  高品质装备从该品质的装备池中随机选择一件

<b class="hl">每关掉率 = 1 - ∏(1 - 每个武将掉率)</b>  (至少掉落一件的概率)

<b class="hl">投石车(type=0):</b> genQ=0但canDropEquip返回false → <span class="no-drop">不掉装</span>

<b class="hl">战后兜底(仅prepare未产生掉落时):</b>
  fn = 敌方平均等级, 条件 fn ≥ 5 才触发
  品质范围依章节: 1-2章Q1-3, 3-4章Q2-5, 5-7章Q4-7, 8+章Q7-10
</pre>
</div>

<div class="toc">
<h2>📊 各章节掉落概览</h2>
<table>
<tr><th>章节</th><th>名称</th><th>关卡数</th><th>平均掉率</th><th>最低掉率</th><th>最高掉率</th><th>可掉品质</th></tr>
${Object.values(partGroups).map(g => `
<tr>
  <td>第${g.part}章</td>
  <td>${g.partName}</td>
  <td>${g.totalStages}</td>
  <td style="color:${pctColor(g.avgProb)}">${pctStr(g.avgProb)}</td>
  <td style="color:${pctColor(g.minProb)}">${pctStr(g.minProb)}</td>
  <td style="color:${pctColor(g.maxProb)}">${pctStr(g.maxProb)}</td>
  <td>${g.qualityRange}</td>
</tr>`).join('')}
</table>
</div>

${stageResults.map(r => {
  const sortedParts = Object.keys(partGroups).map(Number).sort((a,b)=>a-b);
  const partIdx = sortedParts.indexOf(r.part);
  const prevPart = partIdx > 0 ? sortedParts[partIdx-1] : null;
  const showHeader = !prevPart || prevPart !== r.part;

  let sectionHtml = '';
  if (showHeader) {
    const g = partGroups[r.part];
    sectionHtml += `
<div class="part-section" id="part${r.part}">
<div class="part-header" onclick="this.nextElementSibling.style.display=this.nextElementSibling.style.display==='none'?'block':'none'">
  <h2>第${r.part}章 · ${r.partName} (${g.totalStages}关)</h2>
  <div class="part-stats">均掉率 ${pctStr(g.avgProb)} | 品质 ${g.qualityRange} | 兜底 ${g.stages.filter(s=>s.fallbackActive).length}/${g.totalStages}关</div>
</div>
<div class="part-body">
<table>
<tr><th>关卡</th><th>名称</th><th>敌人数</th><th>可掉敌数</th><th>敌均等级</th><th>本关掉率</th><th>掉品范围</th><th>兜底启用</th><th>敌人详情</th></tr>`;
  }

  sectionHtml += `
<tr>
  <td>${r.part}-${String(r.level).padStart(2,'0')}</td>
  <td>${r.stageName}</td>
  <td>${r.enemyCount}</td>
  <td>${r.dropEnemies}</td>
  <td>${r.avgEnemyLevel}</td>
  <td style="color:${pctColor(r.stageProb)};font-weight:bold">${pctStr(r.stageProb)}</td>
  <td><span style="color:${qColor(r.bestQuality)}">Q${r.worstQuality}-Q${r.bestQuality}</span></td>
  <td class="${r.fallbackActive ? 'fallback-yes' : 'fallback-no'}">${r.fallbackActive ? '✓ (fn=' + r.fn + ')' : '✗ (fn=' + r.fn + '<5)'}</td>
  <td style="text-align:left;font-size:10px">
    ${r.enemyDetails.map((e, ei) => {
      const shortCode = e.code.replace('general_', '');
      if (!e.canDrop) {
        return `<span class="no-drop" title="${e.name} ${e.code}">🚫${shortCode} Lv${e.level}</span>`;
      }
      return `<span class="enemy-pop has-drop" title="${e.genName} Q${e.genQ} ${e.qRange}">
        ${shortCode} Lv${e.level} <small>(${pctStr(e.prob)})</small>
        <span class="popup">${e.genName} | 品质${e.genQ} | ${e.qRange} | 掉率${pctStr(e.prob)}</span>
      </span>`;
    }).join(' &nbsp;|&nbsp; ')}
  </td>
</tr>`;

  // Check if next stage is different part
  const nextIdx = stageResults.indexOf(r) + 1;
  const nextStage = nextIdx < stageResults.length ? stageResults[nextIdx] : null;
  if (!nextStage || nextStage.part !== r.part) {
    sectionHtml += `</table></div></div>`;
  }

  return sectionHtml;
}).join('')}

<div class="legend">
  <span>🟢 绿色: ≥10%</span>
  <span>🟡 黄色: ≥5%</span>
  <span>🟠 橙色: ≥2%</span>
  <span>🔴 红色: ≥1%</span>
  <span>⭕ 深红: &lt;1%</span>
  <span>|</span>
  <span>⚠ 兜底门槛 fn≥5: 敌均等级&lt;5时战后也不补掉落</span>
  <span>|</span>
  <span>🚫 投石车(type=0): 不掉装备</span>
  <span>|</span>
  <span>鼠标悬停敌人查看详情</span>
</div>

<div class="formula-box">
<h2>🔍 关键发现</h2>
<pre>
<b class="hl">1. 低等级关卡掉率极低</b>
   敌方等级1-3时，每武将掉率固定在0.30%（受 max(0.003, level/rateDiv) 下限保护）
   6个Lv1敌将的关卡：本关掉率仅 <span style="color:#cc0000">1.79%</span>（约56局才出1件）

<b class="hl">2. 战后兜底对前期完全无效</b>
   兜底条件 fn ≥ 5（敌方平均等级≥5），前期大部分关卡敌方均等1-3，兜底永不触发

<b class="hl">3. 掉率随关卡深入逐步提升</b>
   第1-2章低品质(Q1-3)低掉率，第5-7章(Q4-7)和第8+章(Q7-10)有显著提升
   高等级敌人(>Lv30)掉率可达10%+

<b class="hl">4. 投石车被明确排除</b>
   canDropEquip检查 general_0_X 模式 → 投石车不掉落任何装备
</pre>
</div>

<div style="text-align:center;color:#666;font-size:11px;margin-top:30px">
  Generated by tools/gen_drop_rate_table.js | 三国Q战 v4.0.3
</div>

</body>
</html>`;

// ============ 写入桌面 ============
const desktop = path.join(os.homedir(), 'Desktop');
const outPath = path.join(desktop, '三国Q战_掉落概率分析.html');
fs.writeFileSync(outPath, html, 'utf-8');
console.log(`\n✅ HTML已生成: ${outPath}`);
console.log(`   共 ${stages.length} 个关卡 × ${Object.keys(genQualityMap).length} 个武将品质映射`);

// 统计低掉率关卡
const lowProbStages = stageResults.filter(s => s.stageProb < 0.02);
const veryLowStages = stageResults.filter(s => s.stageProb < 0.01);
console.log(`\n📊 统计:`);
console.log(`   掉率<2%的关卡: ${lowProbStages.length} 个`);
console.log(`   掉率<1%的关卡: ${veryLowStages.length} 个`);
console.log(`   兜底全覆盖: ${stageResults.filter(s => s.fallbackActive).length} 个关卡`);
console.log(`   兜底不生效: ${stageResults.filter(s => !s.fallbackActive).length} 个关卡`);
