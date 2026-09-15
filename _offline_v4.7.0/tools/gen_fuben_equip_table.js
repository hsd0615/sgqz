// 副本敌方装备分配表生成工具
var fs = require('fs');
var path = require('path');
var os = require('os');

var baseDir = __dirname.replace(/tools$/, '');

// 1. 读取敌方武将数据
var genXml = fs.readFileSync(path.join(baseDir, 'staticgeneral.xml'), 'utf8');
var genMap = {};
var genPattern = /<general>[\s\S]*?<code>(.*?)<\/code>[\s\S]*?<name>(.*?)<\/name>[\s\S]*?<type>(.*?)<\/type>[\s\S]*?<title>(.*?)<\/title>[\s\S]*?<\/general>/g;
var m;
while ((m = genPattern.exec(genXml)) !== null) {
    genMap[m[1]] = { code: m[1], name: m[2], type: parseInt(m[3]), title: parseInt(m[4]) };
}

// 2. 读取装备数据
var EQUIP_DATA = {};
var eqContent = fs.readFileSync(path.join(baseDir, 'server', 'start_fixed.js'), 'utf8');
var eqPattern = /EQUIP_DATA\["(.*?)"\]\s*=\s*\{([^}]+)\}/g;
var eqm;
while ((eqm = eqPattern.exec(eqContent)) !== null) {
    var props = {};
    var pms = eqm[2].matchAll(/(\w+):([^,}]+)/g);
    for (var pm of pms) props[pm[1].trim()] = pm[2].trim();
    EQUIP_DATA[eqm[1]] = props;
}

// 3. 从代码中提取副本敌方数据 (XiongnuConfig硬编码)
// 格式: fubenID, stageIndex, [{code, name, quality}]
var fubenStages = [
    {
        fubenID: 1, fubenName: '袭杀匈奴', stages: [
            { stageIdx: 1, enemies: [
                { code: 'general_11_1', name: '匈奴前哨', count: 2, quality: 3 },
                { code: 'general_10_1', name: '匈奴杂兵', count: 20, quality: 2 }
            ]},
            { stageIdx: 2, enemies: [
                { code: 'general_10_1', name: '匈奴铁卫(镜像)', count: '玩家数+1', quality: 1 }
            ]},
            { stageIdx: 3, enemies: [
                { code: 'general_13_1', name: '匈奴头目(Boss)', count: 1, quality: 0 }
            ]}
        ]
    },
    {
        fubenID: 2, fubenName: '荡平倭寇', stages: [
            { stageIdx: 1, enemies: [
                { code: 'general_11_1', name: '倭寇前哨', count: 2, quality: 3 },
                { code: 'general_14_0', name: '倭寇杂兵', count: 20, quality: 2 }
            ]},
            { stageIdx: 2, enemies: [
                { code: 'general_14_0', name: '倭寇武士(镜像)', count: '玩家数+1', quality: 1 }
            ]},
            { stageIdx: 3, enemies: [
                { code: 'general_15_0', name: '倭寇头目(Boss)', count: 1, quality: 0 }
            ]}
        ]
    }
];

// 4. 装备分配函数
var fubenNames = { 1: '袭杀匈奴', 2: '荡平倭寇' };
var qualityNames = ['超级', '一流', '二流', '三流'];
var slotNames = ['武器', '铠甲', '饰品I', '头盔', '战靴', '饰品II'];

function getEquipForQuality(genQuality, stageIdx) {
    var maxQ = 1;
    if (genQuality == 0) maxQ = Math.min(10, 4 + stageIdx);
    else if (genQuality == 1) maxQ = Math.min(7, 2 + stageIdx);
    else if (genQuality == 2) maxQ = Math.min(5, 1 + stageIdx);
    else maxQ = Math.min(3, 1 + Math.floor(stageIdx / 2));
    var minQ = Math.max(1, maxQ - 3);
    var slots = [];
    for (var s = 1; s <= 6; s++) {
        var candidates = [];
        for (var ek in EQUIP_DATA) {
            var eq = EQUIP_DATA[ek];
            if (parseInt(eq.quality) >= minQ && parseInt(eq.quality) <= maxQ && parseInt(eq.slot) === s) {
                candidates.push(ek + '|' + eq.name + '|Q' + eq.quality);
            }
        }
        if (candidates.length > 0) slots.push(candidates);
        else slots.push([]);
    }
    return { minQ: minQ, maxQ: maxQ, slots: slots };
}

// 5. 生成HTML
var html = '<!DOCTYPE html>\n<html>\n<head>\n<meta charset="utf-8">\n<title>副本敌方装备一览</title>\n';
html += '<style>\n';
html += 'body{font-family:"Microsoft YaHei",sans-serif;background:#1a1a2e;color:#e0e0e0;padding:20px;max-width:1400px;margin:0 auto}\n';
html += 'h1{color:#ffd700;text-align:center;font-size:24px}\n';
html += 'h2{color:#ff8c00;margin-top:30px;font-size:18px;border-bottom:1px solid #444;padding-bottom:8px}\n';
html += '.info{text-align:center;color:#888;margin-bottom:20px}\n';
html += 'table{width:100%;border-collapse:collapse;margin:10px 0;font-size:12px}\n';
html += 'th{background:#2a2a4e;color:#ffd700;padding:6px 4px;border:1px solid #444;font-size:12px}\n';
html += 'td{padding:5px 4px;border:1px solid #333;text-align:center;font-size:11px}\n';
html += 'tr:nth-child(even){background:#222240}\n';
html += 'tr:nth-child(odd){background:#1e1e38}\n';
html += '.q0{color:#ff4444;font-weight:bold}\n';
html += '.q1{color:#ff8c00;font-weight:bold}\n';
html += '.q2{color:#4ea4ff}\n';
html += '.q3{color:#aaa}\n';
html += '.eq-name{font-size:10px;line-height:1.4}\n';
html += '.eq-q7{color:#ff8c00}\n';
html += '.eq-q8{color:#ff6600}\n';
html += '.eq-q9{color:#ff3366}\n';
html += '.eq-q10{color:#ff0000}\n';
html += '.highlight{background:#2a1a0a !important}\n';
html += '.footer{text-align:center;color:#666;margin-top:40px;font-size:11px}\n';
html += '</style>\n</head>\n<body>\n';
html += '<h1>⚔ 副本敌方武将装备分配表</h1>\n';
html += '<div class="info">装备品质由武将品质(超级/一流/二流/三流)和关卡深度共同决定<br>';
html += '每个装备槽位独立随机，可能为空</div>\n';

fubenStages.forEach(function (fuben) {
    html += '<h2 style="color:#ffd700">▸ ' + fuben.fubenName + ' (副本ID=' + fuben.fubenID + ')</h2>\n';
    fuben.stages.forEach(function (stage) {
        html += '<h3>第' + stage.stageIdx + '关</h3>\n';
        html += '<table>\n';
        html += '<tr><th>武将</th><th>数量</th><th>品质</th><th>装备范围</th>';
        for (var si = 0; si < 6; si++) html += '<th>' + slotNames[si] + '</th>';
        html += '</tr>\n';

        stage.enemies.forEach(function (enemy) {
            var genInfo = genMap[enemy.code] || { title: enemy.quality, type: 0 };
            var q = enemy.quality;
            var qName = qualityNames[q] || '三流';
            var qClass = 'q' + q;
            var equip = getEquipForQuality(q, stage.stageIdx);
            html += '<tr>\n';
            html += '<td><b>' + enemy.name + '</b><br><span style="color:#888;font-size:10px">' + enemy.code + '</span></td>\n';
            html += '<td>' + enemy.count + '</td>\n';
            html += '<td class="' + qClass + '">' + qName + '</td>\n';
            html += '<td>Q' + equip.minQ + ' ~ Q' + equip.maxQ + '</td>\n';
            for (var si = 0; si < 6; si++) {
                var slotEquips = equip.slots[si];
                if (slotEquips.length === 0) {
                    html += '<td style="color:#555">无</td>';
                } else {
                    var cellHtml = '';
                    slotEquips.forEach(function (eqStr) {
                        var parts = eqStr.split('|');
                        var eqName = parts[1];
                        var eqQ = parts[2];
                        var qNum = parseInt(eqQ.replace('Q', ''));
                        var qHighlight = qNum >= 7 ? ' eq-q' + qNum + ' highlight' : '';
                        cellHtml += '<span class="eq-name' + qHighlight + '">' + eqName + ' ' + eqQ + '</span><br>';
                    });
                    html += '<td>' + cellHtml + '</td>';
                }
            }
            html += '</tr>\n';
        });
        html += '</table>\n';
    });
});

html += '<div class="footer">生成时间: ' + new Date().toLocaleString() + ' | 三国Q战 | 橙色及以上为高品质掉落</div>\n';
html += '</body>\n</html>';

var outPath = path.join(os.homedir(), 'Desktop', '副本敌方装备表.html');
fs.writeFileSync(outPath, html, 'utf8');
console.log('Saved: ' + outPath);
var totalEnemies = fubenStages.reduce(function(s, f) { return s + f.stages.reduce(function(ss, st) { return ss + st.enemies.length; }, 0); }, 0);
console.log('Fuben: ' + fubenStages.length + ', Stages: ' + fubenStages.reduce(function(s,f){return s+f.stages.length},0) + ', Enemy types: ' + totalEnemies);
