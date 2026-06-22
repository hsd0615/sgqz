#!/usr/bin/env node
/**
 * 生成武将10/50/100/200级数值表格 (仅HTML)
 * 包含实际游戏招募概率 + 超级武将数值分析
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

const BASE = path.dirname(path.dirname(__filename));
const GENERAL_XML = path.join(BASE, 'staticgeneral.xml');
const XISHU_XML = path.join(BASE, 'staticxishu.xml');

// ===================== Data =====================

const TYPE_NAMES = {
    0: "投石车", 1: "弓兵", 2: "飞刀兵", 3: "朴刀兵",
    4: "斧兵", 5: "锤兵", 6: "武斗兵", 7: "长枪兵",
    8: "藤甲兵", 9: "骑兵", 10: "弯刀兵", 11: "箭塔兵",
    12: "强弓兵", 13: "BOSS", 20: "君主"
};

const TITLE_NAMES = { 0: "超级武将", 1: "一流武将", 2: "二流武将", 3: "三流武将" };
const TITLE_COLORS = { 0: "#ff6600", 1: "#33ccff", 2: "#99ff33", 3: "#ffcc99" };
const TITLE_ORDER = { 0: 0, 1: 1, 2: 2, 3: 3 }; // for sorting

// ===================== XML Parsing =====================

function parseRecords(xmlPath) {
    const content = fs.readFileSync(xmlPath, 'utf-8');
    const records = [];
    const recordRegex = /<RECORD>([\s\S]*?)<\/RECORD>/g;
    let match;
    while ((match = recordRegex.exec(content)) !== null) {
        const block = match[1];
        const obj = {};
        const childRegex = /<(\w+)>([\s\S]*?)<\/\1>/g;
        let cm;
        while ((cm = childRegex.exec(block)) !== null) {
            obj[cm[1]] = cm[2].trim();
        }
        const emptyRegex = /<(\w+)\/>/g;
        let em;
        while ((em = emptyRegex.exec(block)) !== null) {
            if (!(em[1] in obj)) obj[em[1]] = '';
        }
        records.push(obj);
    }
    return records;
}

function safeInt(val, defaultVal) {
    if (val === undefined || val === null || val === '') return defaultVal;
    const n = parseInt(val);
    return isNaN(n) ? defaultVal : n;
}

function parseGenerals() {
    const records = parseRecords(GENERAL_XML);
    return records.map(r => ({
        code: r.code || '',
        name: r.name || '',
        type: safeInt(r.type, 0),
        title: safeInt(r.title, 3),
        hp: safeInt(r.hp, 0),
        attack: safeInt(r.attack, 0),
        defense: safeInt(r.defense, 0),
        recruitLevel: safeInt(r.recruitLevel, 0),
        moneyRate: safeInt(r.money, 0),      // 普通招募成功率(%)
        diankaRate: safeInt(r.dianka, 0),    // 点卡招募成功率(%)
        jinbi: safeInt(r.jinbi, 0),
        coint: safeInt(r.coint, 0),
        price: r.price !== undefined && r.price !== '' ? parseInt(r.price) : -1,
        proto: r.proto || ''
    }));
}

function parseXishu() {
    const records = parseRecords(XISHU_XML);
    const xishu = {};
    records.forEach(r => {
        xishu[r.code] = {
            hp: parseFloat(r.hp) || 1.0,
            attack: parseFloat(r.attack) || 1.0,
            defence: parseFloat(r.defence) || 1.0
        };
    });
    return xishu;
}

// ===================== Stats Calculation =====================

function calcStat(gtype, level, baseVal, title, xishu, statKey) {
    const code = `${gtype}_${title}`;
    const xs = xishu[code] || { hp: 1.0, attack: 1.0, defence: 1.0 };
    // Map statKey: the XML uses British spelling 'defence', code uses 'defense'
    const xishuKey = statKey === 'defense' ? 'defence' : statKey;
    const coeff = xs[xishuKey];
    const multiplier = statKey === 'hp' ? 50 : 30;
    const part1 = (level - 1) * multiplier * coeff;
    const part2 = baseVal * (1 + level * 0.03);
    return Math.floor(part1 + part2);
}

// ===================== Recruitment Analysis =====================

function getRecruitPoolSize(generals, playerLevel) {
    // All generals recruitable at or below this player level
    return generals.filter(g => g.recruitLevel > 0 && g.recruitLevel <= playerLevel).length;
}

function getRecruitInfo(g, generals) {
    const parts = [];
    const rl = g.recruitLevel;
    const moneyRate = g.moneyRate;
    const diankaRate = g.diankaRate;
    const price = g.price;

    if (rl === 1000) {
        parts.push(`<span class="label-default">系统默认拥有</span>`);
    } else if (rl > 0) {
        const poolSize = getRecruitPoolSize(generals, rl);
        parts.push(`<span class="label-level">招募等级≥${rl}</span>`);

        if (moneyRate > 0) {
            parts.push(`普募<span class="rate">${moneyRate}%</span>`);
        }
        if (diankaRate > 0) {
            parts.push(`点卡<span class="rate">${diankaRate}%</span>`);
        }
        parts.push(`<span class="pool">池${poolSize}将</span>`);
    } else if (rl === -1) {
        if (price > 0) {
            parts.push(`<span class="label-shop">点卡购买(${price}元)</span>`);
        } else {
            parts.push(`<span class="label-special">活动/特殊获取</span>`);
        }
    } else if (rl === 0) {
        parts.push(`<span class="label-special">活动/特殊获取</span>`);
    } else {
        parts.push(`<span class="label-special">活动/特殊获取</span>`);
    }

    return parts.join(' ');
}

// ===================== HTML Generation =====================

function genHTML(generals, xishu) {
    const levels = [10, 50, 100, 200];

    // ===== Super General Analysis =====
    const superGens = generals.filter(g => g.title === 0 && g.recruitLevel !== 1000);
    const tier1Gens = generals.filter(g => g.title === 1);
    const tier2Gens = generals.filter(g => g.title === 2);
    const tier3Gens = generals.filter(g => g.title === 3);

    function avgStat(gens, level, statKey) {
        if (gens.length === 0) return 0;
        const sum = gens.reduce((s, g) => s + calcStat(g.type, level, g[statKey], g.title, xishu, statKey), 0);
        return Math.round(sum / gens.length);
    }

    function maxStat(gens, level, statKey) {
        if (gens.length === 0) return 0;
        return Math.max(...gens.map(g => calcStat(g.type, level, g[statKey], g.title, xishu, statKey)));
    }

    // Build analysis table
    let analysisRows = '';
    const tiers = [
        { name: '超级武将', gens: superGens, color: TITLE_COLORS[0] },
        { name: '一流武将', gens: tier1Gens, color: TITLE_COLORS[1] },
        { name: '二流武将', gens: tier2Gens, color: TITLE_COLORS[2] },
        { name: '三流武将', gens: tier3Gens, color: TITLE_COLORS[3] },
    ];

    const compLevels = [10, 50, 100, 200];
    for (const t of tiers) {
        if (t.gens.length === 0) continue;
        analysisRows += '<tr>';
        analysisRows += `<td style="color:${t.color};font-weight:bold">${t.name}</td>`;
        analysisRows += `<td>${t.gens.length}</td>`;
        for (const lv of compLevels) {
            const avgHp = avgStat(t.gens, lv, 'hp');
            const avgAtk = avgStat(t.gens, lv, 'attack');
            const avgDef = avgStat(t.gens, lv, 'defense');
            analysisRows += `<td>${avgHp}</td><td>${avgAtk}</td><td>${avgDef}</td>`;
        }
        analysisRows += '</tr>';
    }

    // Ratio rows: how much higher are supers vs others
    let ratioRows = '';
    for (const t of tiers.slice(1)) {
        if (superGens.length === 0 || t.gens.length === 0) continue;
        ratioRows += '<tr style="background:#fff9e6">';
        ratioRows += `<td>超级/${t.name.split('武将')[0]}武将</td>`;
        ratioRows += `<td>-</td>`;
        for (const lv of compLevels) {
            const sHp = avgStat(superGens, lv, 'hp');
            const sAtk = avgStat(superGens, lv, 'attack');
            const sDef = avgStat(superGens, lv, 'defense');
            const tHp = avgStat(t.gens, lv, 'hp');
            const tAtk = avgStat(t.gens, lv, 'attack');
            const tDef = avgStat(t.gens, lv, 'defense');
            const rHp = tHp > 0 ? (sHp / tHp).toFixed(2) : '-';
            const rAtk = tAtk > 0 ? (sAtk / tAtk).toFixed(2) : '-';
            const rDef = tDef > 0 ? (sDef / tDef).toFixed(2) : '-';
            ratioRows += `<td>${rHp}x</td><td>${rAtk}x</td><td>${rDef}x</td>`;
        }
        ratioRows += '</tr>';
    }

    // Top 5 stat holders per level
    function topN(gens, level, statKey, n) {
        return [...gens]
            .map(g => ({ name: g.name, val: calcStat(g.type, level, g[statKey], g.title, xishu, statKey), title: g.title }))
            .sort((a, b) => b.val - a.val)
            .slice(0, n);
    }

    let topTables = '';
    const statNames = ['hp', 'attack', 'defense'];
    const statLabels = ['生命', '攻击', '防御'];
    for (let si = 0; si < 3; si++) {
        topTables += `<div class="top-block"><h4>Lv200 ${statLabels[si]} Top 10</h4><table class="top-table"><tr><th>#</th><th>武将</th><th>品质</th><th>${statLabels[si]}</th></tr>`;
        const top = topN(generals, 200, statNames[si], 10);
        top.forEach((t, i) => {
            topTables += `<tr><td>${i+1}</td><td>${t.name}</td><td style="color:${TITLE_COLORS[t.title] || '#000'}">${TITLE_NAMES[t.title]}</td><td>${t.val}</td></tr>`;
        });
        topTables += '</table></div>';
    }

    // Growth coefficient comparison
    let coefTable = '<h3>📈 成长系数对比 (staticxishu.xml)</h3>';
    coefTable += '<table class="coef-table"><tr><th>兵种</th><th>品质</th><th>HP系数</th><th>攻击系数</th><th>防御系数</th></tr>';
    const sortedTypes = [...new Set(generals.map(g => g.type))].sort((a,b) => a-b);
    for (const t of sortedTypes) {
        for (const ti of [0,1,2,3]) {
            const code = `${t}_${ti}`;
            const xs = xishu[code];
            if (!xs) continue;
            const typeName = TYPE_NAMES[t] || `类型${t}`;
            const titleName = TITLE_NAMES[ti] || `品质${ti}`;
            const rowStyle = ti === 0 ? 'style="background:#fff0e0;font-weight:bold"' : '';
            coefTable += `<tr ${rowStyle}><td>${typeName}</td><td style="color:${TITLE_COLORS[ti]}">${titleName}</td><td>${xs.hp.toFixed(1)}</td><td>${xs.attack.toFixed(1)}</td><td>${xs.defence.toFixed(1)}</td></tr>`;
        }
    }
    coefTable += '</table>';

    // ===== Main Table =====
    let rows = '';
    // Sort: by type, then title (super first), then name
    const sorted = [...generals].sort((a, b) => {
        if (a.type !== b.type) return a.type - b.type;
        if (a.title !== b.title) return TITLE_ORDER[a.title] - TITLE_ORDER[b.title];
        return a.name.localeCompare(b.name, 'zh');
    });

    for (const g of sorted) {
        const gtypeName = TYPE_NAMES[g.type] || `未知(${g.type})`;
        const titleName = TITLE_NAMES[g.title] || `未知(${g.title})`;
        const titleColor = TITLE_COLORS[g.title] || '#000';
        const recruitInfo = getRecruitInfo(g, generals);

        rows += '<tr>';
        rows += `<td>${g.name}</td>`;
        rows += `<td>${gtypeName}</td>`;
        rows += `<td style="color:${titleColor};font-weight:bold">${titleName}</td>`;
        rows += `<td class="recruit-cell">${recruitInfo}</td>`;

        for (const lv of levels) {
            const hp = calcStat(g.type, lv, g.hp, g.title, xishu, 'hp');
            const atk = calcStat(g.type, lv, g.attack, g.title, xishu, 'attack');
            const df = calcStat(g.type, lv, g.defense, g.title, xishu, 'defense');
            rows += `<td>${hp}</td><td>${atk}</td><td>${df}</td>`;
        }
        rows += '</tr>';
    }

    // ===== Full HTML =====
    return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<title>三国Q战4399版 - 武将数值表</title>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: "Microsoft YaHei", "SimHei", sans-serif; font-size: 13px; background: #1a1a2e; color: #eee; padding: 20px; }
.container { max-width: 100%; overflow-x: auto; }
h1 { text-align: center; color: #ffd700; margin-bottom: 5px; font-size: 22px; }
h2 { color: #ffd700; margin: 25px 0 10px; font-size: 18px; border-bottom: 2px solid #ffd700; padding-bottom: 5px; }
h3 { color: #ffcc80; margin: 15px 0 8px; }
.subtitle { text-align: center; color: #aaa; margin-bottom: 20px; font-size: 13px; }
.subtitle span { color: #ff6600; font-weight: bold; }

/* Main table */
.main-table { border-collapse: collapse; width: 100%; font-size: 11px; }
.main-table th, .main-table td { border: 1px solid #444; padding: 3px 5px; text-align: center; white-space: nowrap; }
.main-table th { background: #2d5a27; color: #fff; position: sticky; top: 0; z-index: 2; }
.main-table th.col-name { min-width: 70px; }
.main-table th.col-type { min-width: 55px; }
.main-table th.col-quality { min-width: 65px; }
.main-table th.col-recruit { min-width: 160px; }
.main-table tr:nth-child(even) { background: #252540; }
.main-table tr:nth-child(odd) { background: #1e1e35; }
.main-table tr:hover { background: #2a2a50; }

/* Recruitment cell styles */
.label-default { color: #ffd700; font-weight: bold; }
.label-level { color: #8be0fd; }
.label-shop { color: #ff9800; }
.label-special { color: #888; }
.rate { color: #4cff4c; font-weight: bold; }
.pool { color: #aaa; font-size: 10px; }

/* Analysis section */
.analysis-section { background: #252540; border-radius: 8px; padding: 20px; margin-top: 20px; }
.insight-box { background: #1a1a2e; border-left: 4px solid #ffd700; padding: 12px 16px; margin: 15px 0; border-radius: 0 4px 4px 0; }
.insight-box.warn { border-left-color: #ff5722; }
.insight-box.info { border-left-color: #4caf50; }

.analysis-table, .coef-table, .top-table { border-collapse: collapse; margin: 10px 0; font-size: 12px; width: auto; }
.analysis-table th, .coef-table th, .top-table th { background: #3a3a5c; color: #ffd700; padding: 5px 10px; border: 1px solid #555; }
.analysis-table td, .coef-table td, .top-table td { padding: 4px 10px; border: 1px solid #444; text-align: center; }
.analysis-table tr:nth-child(even), .coef-table tr:nth-child(even), .top-table tr:nth-child(even) { background: #2a2a45; }

.top-blocks { display: flex; gap: 15px; flex-wrap: wrap; margin: 15px 0; }
.top-block { flex: 1; min-width: 220px; }
.top-block h4 { color: #ffcc80; margin-bottom: 5px; }

.note { color: #aaa; font-size: 11px; margin-top: 20px; padding: 10px; background: #1a1a2e; border-radius: 4px; }

/* Scroll hint */
.scroll-hint { background: #ff6600; color: white; text-align: center; padding: 5px; border-radius: 4px; margin-bottom: 10px; font-size: 12px; }
@media (min-width: 1400px) { .scroll-hint { display: none; } }

.footer { text-align: center; color: #666; margin-top: 30px; font-size: 11px; }
</style>
</head>
<body>
<div class="container">

<h1>⚔️ 三国Q战4399版 - 武将数值表</h1>
<p class="subtitle">
    总计 <span>${generals.length}</span> 名武将 |
    等级: 10 / 50 / 100 / 200 |
</p>

<div class="scroll-hint">⬅ ➡ 表格较宽，可左右滚动查看完整数据</div>

<h2>📋 武将数值总表</h2>
<table class="main-table">
<thead>
<tr>
    <th class="col-name">武将名称</th>
    <th class="col-type">兵种</th>
    <th class="col-quality">品质</th>
    <th class="col-recruit">招募系统详情</th>
    ${levels.map(lv => `<th>Lv${lv}<br>生命</th><th>Lv${lv}<br>攻击</th><th>Lv${lv}<br>防御</th>`).join('')}
</tr>
</thead>
<tbody>
${rows}
</tbody>
</table>

<!-- ==================== 超级武将分析 ==================== -->
<div class="analysis-section">
<h2>🔍 超级武将数值分析</h2>

<div class="insight-box">
<strong>分析目的：</strong>评估超级武将(title=0)的数值是否过高，与一流/二流/三流武将的差距是否合理。
分析基于未进化(evolution=0)、无天赋(tianfu=0)的纯基础数值，使用游戏原始成长公式计算。
</div>

<h3>📊 各品质等级平均数值对比</h3>
<table class="analysis-table">
<tr><th>品质等级</th><th>数量</th>
${compLevels.map(lv => `<th>Lv${lv}<br>平均生命</th><th>Lv${lv}<br>平均攻击</th><th>Lv${lv}<br>平均防御</th>`).join('')}
</tr>
${analysisRows}
</table>

<h3>📐 超级武将 vs 其他品质 比值</h3>
<table class="analysis-table">
<tr><th>对比</th><th></th>
${compLevels.map(lv => `<th>Lv${lv}<br>生命比</th><th>Lv${lv}<br>攻击比</th><th>Lv${lv}<br>防御比</th>`).join('')}
</tr>
${ratioRows}
</table>

<div class="insight-box info">
<strong>📈 分析结论：</strong>
<ul style="margin:8px 0 0 20px; line-height:1.8">
<li><strong>攻击力差距显著缩小：</strong>超级攻击系数经两次削弱共降0.4。如弓兵超级2.1已略低于一流2.2，骑兵超级2.1与一流持平。超级武将的成长优势已基本消除，仅靠基础攻击值维持优势。</li>
<li><strong>生命值差距适中：</strong>超级武将生命系数通常比一流高8%-15%，差距在可接受范围内。</li>
<li><strong>防御差距最小：</strong>部分超级武将的防御系数反而低于低品质（如type=20君主所有品质系数相同），说明防御不是超级武将的优势维度。</li>
<li><strong>成长放大效应：</strong>由于公式中成长系数乘以(等级-1)，等级越高差距越大。Lv10时差距不明显，Lv200时差距被放大20倍。</li>
<li><strong>兵种差异显著：</strong>投石车(type=0)超级攻击系数经削弱后为2.6，已与一流(2.6)持平，但基础攻击高达3000，Lv200攻击36522（超级），三流攻击35328（系数2.4），超级与三流差距仅3.4%。</li>
</ul>
</div>

<div class="insight-box warn">
<strong>⚠️ 潜在平衡问题：</strong>
<ul style="margin:8px 0 0 20px; line-height:1.8">
<li><strong>超级弓兵大幅削弱：</strong>黄忠(超级弓兵) Lv200攻击从30619降至28231(-7.8%)。顶尖超级武将相比原始版均削弱7-9%。基础攻击值差距仍是主要区分因素。</li>
<li><strong>超级武将基础值差异大：</strong>同样是超级品质，陆逊(baseAtk=1650)和黄忠(baseAtk=2242)基础值差36%，导致最终数值拉开较大差距。</li>
<li><strong>君主类全品质同系数：</strong>type=20(君主)所有品质使用相同成长系数(HP=4.2, ATK=2.5, DEF=2.9)，品质差异仅体现在基础值上，超级与其他品质差距较小。</li>
</ul>
</div>

${coefTable}

<div class="top-blocks">
${topTables}
</div>

<div class="insight-box">
<strong>💡 总结：</strong>超级武将的核心优势在于<strong>攻击力</strong>，这是设计上有意为之——超级武将作为稀有角色，
通过高攻击力在战斗中更快消灭敌方单位。生命和防御的差距相对可控。如果觉得超级武将太强，
可以考虑：(1)降低超级攻击系数0.2-0.3；(2)提高一流/二流武将的基础攻击值以缩小差距；
(3)限制超级武将的进化等级上限。当前数值体系下，超级武将确实是PvP和后期关卡的核心战力，
但并非不可战胜——克制关系和战术操作仍是决定性因素。
</div>
</div>

<div class="note">
<h3>📝 公式说明</h3>
<p>生命 = ⌊(等级-1) × 50 × HP系数 + 基础HP × (1 + 等级 × 0.03)⌋</p>
<p>攻击 = ⌊(等级-1) × 30 × 攻击系数 + 基础攻击 × (1 + 等级 × 0.03)⌋</p>
<p>防御 = ⌊(等级-1) × 30 × 防御系数 + 基础防御 × (1 + 等级 × 0.03)⌋</p>
<p>系数取自 staticxishu.xml，键 = "兵种类型_品质等级"（如 1_0 = 弓兵/超级）</p>

<h3 style="margin-top:12px">🎯 招募系统说明</h3>
<p><strong>招募等级：</strong>玩家需达到该等级，该武将才会出现在招募池中（recruitLevel字段）</p>
<p><strong>普通招募成功率：</strong>消耗1000声望+1000银两，成功率为XML中money字段值(%)，消耗1次招募机会(共3次/轮)</p>
<p><strong>点卡招募成功率：</strong>消耗1000声望+20点卡(或求贤令道具)，成功率为XML中dianka字段值(%)，不消耗招募机会</p>
<p><strong>招募池：</strong>显示该武将首次可招募时，招募池中的总武将数(不含已拥有)，系统随机从池中抽取1个进行招募</p>
<p><strong>招募等级：</strong>若玩家等级&lt;50，招募到的武将等级 = max(1, 玩家等级-20)；若≥50，则为30级</p>
</div>

<div class="footer">
Generated: ${new Date().toLocaleString('zh-CN')} | 三国Q战4399版 v1.042 | 数据来源: staticgeneral.xml + staticxishu.xml
</div>

</div>
</body>
</html>`;
}

// ===================== Main =====================

function main() {
    const generals = parseGenerals();
    const xishu = parseXishu();

    const html = genHTML(generals, xishu);
    const htmlPath = path.join(os.homedir(), 'Desktop', '武将数值表.html');
    fs.writeFileSync(htmlPath, html, 'utf-8');
    console.log(`HTML saved: ${htmlPath}`);
    console.log(`Total generals: ${generals.length}`);
}

main();
