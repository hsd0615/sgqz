// 副本+主线关卡 敌方装备分配表生成工具 v2
var fs = require('fs');
var path = require('path');
var os = require('os');
var baseDir = __dirname.replace(/tools$/, '');

// 1. 读取敌方武将数据
var genXml = fs.readFileSync(path.join(baseDir, 'staticgeneral.xml'), 'utf8');
var genMap = {};
var genPattern = /<RECORD>[\s\S]*?<code>(.*?)<\/code>[\s\S]*?<name>(.*?)<\/name>[\s\S]*?<type>(.*?)<\/type>[\s\S]*?<title>(.*?)<\/title>[\s\S]*?<\/RECORD>/g;
var m;
while ((m = genPattern.exec(genXml)) !== null) {
    genMap[m[1]] = { code: m[1], name: m[2], type: parseInt(m[3]), title: parseInt(m[4]) };
}

// 2. 读取装备数据 (staticequip.xml — 服务端运行时加载源)
var EQUIP_DATA = {};
var eqXml = fs.readFileSync(path.join(baseDir, 'staticequip.xml'), 'utf8');
var eqBlocks = eqXml.split('<RECORD>');
for (var ei = 1; ei < eqBlocks.length; ei++) {
    var block = eqBlocks[ei];
    var ecm = block.match(/<code>([^<]+)<\/code>/);
    var esm = block.match(/<slot>([^<]+)<\/slot>/);
    var enm = block.match(/<name>([^<]+)<\/name>/);
    var eqm2 = block.match(/<quality>([^<]+)<\/quality>/);
    var elm = block.match(/<levelReq>([^<]+)<\/levelReq>/);
    if (ecm && esm && eqm2) {
        EQUIP_DATA[ecm[1]] = {
            slot: parseInt(esm[1]),
            name: enm ? enm[1] : ecm[1],
            quality: parseInt(eqm2[1]),
            levelReq: elm ? parseInt(elm[1]) : 1
        };
    }
}

// 3. 解析stage.xml — 副本+主线
var stageXml = fs.readFileSync(path.join(baseDir, 'stage.xml'), 'utf8');
var allEntries = []; // {type:'fuben'|'gate', id, level, enemies:[{code,name,quality}]}

// 解析副本
var fubenPattern = /<fuben\s+stageID="(\d+)">([\s\S]*?)<\/fuben>/g;
var fm;
while ((fm = fubenPattern.exec(stageXml)) !== null) {
    var fubenID = parseInt(fm[1]);
    var fubenName = fubenID === 1 ? '袭杀匈奴' : (fubenID === 2 ? '荡平倭寇' : '副本' + fubenID);
    var genContent = fm[2];
    var enemies = [];
    var gPattern = /<general\s+code="(.*?)"[^>]*name="(.*?)"/g;
    var gm2;
    while ((gm2 = gPattern.exec(genContent)) !== null) {
        var genCd = gm2[1];
        var genNm = gm2[2];
        var genInfo = genMap[genCd] || { title: 3 };
        enemies.push({ code: genCd, name: genNm, quality: genInfo.title });
    }
    if (enemies.length > 0) {
        allEntries.push({ type: 'fuben', name: fubenName, id: fubenID, enemies: enemies, stages: [
            { stageIdx: 1, enemies: enemies.filter(function(e) { return e.code.indexOf('general_10') >= 0 || e.code.indexOf('general_11') >= 0 || e.code.indexOf('general_14') >= 0 || e.code.indexOf('general_12') >= 0; }) },
            { stageIdx: 2, enemies: [ { code: enemies[0] ? enemies[0].code.replace(/general_(\d+)_\d+/, 'general_$1_1') : 'general_10_1', name: fubenID === 1 ? '匈奴铁卫(镜像)' : '倭寇武士(镜像)', quality: 1 } ] },
            { stageIdx: 3, enemies: enemies.filter(function(e) { return e.code.indexOf('general_13') >= 0 || e.code.indexOf('general_15') >= 0; }) }
        ] });
    }
}

// 解析主线关卡
var gatePattern = /<gate\s[^>]*part="(\d+)"[^>]*level="(\d+)"[^>]*>([\s\S]*?)<\/gate>/g;
var gateMap = {}; // part -> levels
var gateCount = 0;
var gm3;
while ((gm3 = gatePattern.exec(stageXml)) !== null) {
    var part = parseInt(gm3[1]);
    var level = parseInt(gm3[2]);
    var genContent2 = gm3[3];
    var enemies2 = [];
    var gp = /<general\s+code="(.*?)"\s+level="(.*?)"\s+name="(.*?)"/g;
    var gm4;
    while ((gm4 = gp.exec(genContent2)) !== null) {
        var cd = gm4[1];
        var lv = parseInt(gm4[2]) || 1;
        var nm = gm4[3] || '';
        var info = genMap[cd] || { title: 3, name: cd };
        enemies2.push({ code: cd, name: nm || info.name, level: lv, quality: info.title });
    }
    if (enemies2.length > 0) {
        if (!gateMap[part]) gateMap[part] = [];
        gateMap[part].push({ level: level, enemies: enemies2 });
        gateCount++;
    }
}

// 4. 装备计算
var qualityNames = ['超级', '一流', '二流', '三流'];
var slotNames = ['武器', '铠甲', '饰品I', '头盔', '战靴', '饰品II'];

function getEquipForQuality(genQuality, depth) {
    var maxQ = 1;
    if (genQuality == 0) maxQ = Math.min(10, 3 + Math.floor(depth / 10));
    else if (genQuality == 1) maxQ = Math.min(7, 1 + Math.floor(depth / 15));
    else if (genQuality == 2) maxQ = Math.min(5, 1 + Math.floor(depth / 20));
    else maxQ = Math.min(3, 1 + Math.floor(depth / 30));
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
        slots.push(candidates);
    }
    return { minQ: minQ, maxQ: maxQ, slots: slots };
}

// 5. 生成HTML
var html = '<!DOCTYPE html>\n<html>\n<head>\n<meta charset="utf-8">\n<title>全关卡敌方装备一览</title>\n';
html += '<style>\n';
html += 'body{font-family:"Microsoft YaHei",sans-serif;background:#1a1a2e;color:#e0e0e0;padding:20px;max-width:1500px;margin:0 auto}\n';
html += 'h1{color:#ffd700;text-align:center;font-size:24px}\n';
html += 'h2{color:#ff8c00;margin-top:30px;font-size:18px;border-bottom:1px solid #444;padding-bottom:8px}\n';
html += 'h3{color:#4ea4ff;margin-top:20px;font-size:15px}\n';
html += '.info{text-align:center;color:#888;margin-bottom:20px}\n';
html += 'table{width:100%;border-collapse:collapse;margin:10px 0;font-size:11px}\n';
html += 'th{background:#2a2a4e;color:#ffd700;padding:5px 3px;border:1px solid #444;font-size:11px}\n';
html += 'td{padding:4px 3px;border:1px solid #333;text-align:center;font-size:10px}\n';
html += 'tr:nth-child(even){background:#222240}\n';
html += 'tr:nth-child(odd){background:#1e1e38}\n';
html += '.q0{color:#ff4444;font-weight:bold}\n';
html += '.q1{color:#ff8c00;font-weight:bold}\n';
html += '.q2{color:#4ea4ff}\n';
html += '.q3{color:#aaa}\n';
html += '.eq-name{font-size:9px;line-height:1.3}\n';
html += '.eq-q7{color:#ff8c00}\n';
html += '.eq-q8{color:#ff6600}\n';
html += '.eq-q9{color:#ff3366}\n';
html += '.eq-q10{color:#ff0000}\n';
html += '.highlight{background:#2a1a0a !important}\n';
html += '.footer{text-align:center;color:#666;margin-top:40px;font-size:11px}\n';
html += '.section-divider{color:#ffd700;margin:30px 0 10px;padding:10px;background:#2a2a3e;text-align:center;font-size:20px;border-radius:4px}\n';
html += '</style>\n</head>\n<body>\n';
html += '<h1>⚔ 三国Q战全关卡敌方武将装备分配表</h1>\n';
html += '<div class="info">覆盖主线关卡 + 副本 | 敌方品质(超级/一流/二流/三流) + 关卡深度 → 装备品质范围<br>';
html += '橙色Q7+为稀有掉落，Q10为传说掉落 | 装备槽位独立随机</div>\n';

// 副本部分
html += '<div class="section-divider">▣ 副本（袭杀匈奴 / 荡平倭寇）</div>\n';
allEntries.forEach(function (entry) {
    html += '<h2>' + entry.name + '</h2>\n';
    entry.stages.forEach(function (stage) {
        html += '<h3>第' + stage.stageIdx + '关</h3>\n';
        html += '<table><tr><th>武将</th><th>品质</th><th>装备范围</th>';
        for (var si = 0; si < 6; si++) html += '<th>' + slotNames[si] + '</th>';
        html += '</tr>\n';
        stage.enemies.forEach(function (enemy) {
            var q = enemy.quality;
            var qn = qualityNames[q] || '三流';
            var qc = 'q' + q;
            var isTS = enemy.code && enemy.code.indexOf('general_0_') === 0;
            var equip = isTS ? {minQ:0, maxQ:0, slots:[[],[],[],[],[],[]]} : getEquipForQuality(q, stage.stageIdx);
            html += '<tr>';
            html += '<td><b>' + enemy.name + '</b>' + (isTS ? ' <span style=\"color:#ff4444;font-size:9px\">[不掉]</span>' : '') + '<br><span style=\"color:#888;font-size:9px\">' + enemy.code + '</span></td>';
            html += '<td class="' + qc + '">' + qn + '</td>';
            html += '<td>' + (isTS ? '<span style=\"color:#ff4444\">不掉装备</span>' : 'Q' + equip.minQ + '~Q' + equip.maxQ) + '</td>';
            for (var si = 0; si < 6; si++) {
                var seq = equip.slots[si];
                if (seq.length === 0) {
                    html += '<td style="color:#555">—</td>';
                } else {
                    var ch = '';
                    seq.forEach(function (eqs) {
                        var parts = eqs.split('|');
                        var qn2 = parseInt(parts[2].replace('Q', ''));
                        var hc = qn2 >= 7 ? ' eq-q' + qn2 + ' highlight' : '';
                        ch += '<span class="eq-name' + hc + '">' + parts[1] + ' ' + parts[2] + '</span><br>';
                    });
                    html += '<td>' + ch + '</td>';
                }
            }
            html += '</tr>\n';
        });
        html += '</table>\n';
    });
});

// 主线关卡部分
html += '<div class="section-divider">▣ 主线关卡</div>\n';
var partKeys = Object.keys(gateMap).sort(function (a, b) { return parseInt(a) - parseInt(b); });
partKeys.forEach(function (part) {
    html += '<h2>Part ' + part + '</h2>\n';
    var levels = gateMap[part].sort(function (a, b) { return a.level - b.level; });
    levels.forEach(function (lv) {
        html += '<h3>Level ' + lv.level + '</h3>\n';
        html += '<table><tr><th>武将</th><th>等级</th><th>品质</th><th>装备范围</th>';
        for (var si = 0; si < 6; si++) html += '<th>' + slotNames[si] + '</th>';
        html += '</tr>\n';
        lv.enemies.forEach(function (enemy) {
            var q = enemy.quality;
            var qn = qualityNames[q] || '三流';
            var qc = 'q' + q;
            var isTS2 = enemy.code && enemy.code.indexOf('general_0_') === 0;
            var equip = isTS2 ? {minQ:0, maxQ:0, slots:[[],[],[],[],[],[]]} : getEquipForQuality(q, lv.level);
            html += '<tr><td><b>' + (enemy.name || enemy.code) + '</b>' + (isTS2 ? ' <span style=\"color:#ff4444;font-size:9px\">[不掉]</span>' : '') + '<br><span style=\"color:#888;font-size:9px\">' + enemy.code + '</span></td>';
            html += '<td>' + enemy.level + '</td>';
            html += '<td class="' + qc + '">' + qn + '</td>';
            html += '<td>' + (isTS2 ? '<span style=\"color:#ff4444\">不掉装备</span>' : 'Q' + equip.minQ + '~Q' + equip.maxQ) + '</td>';
            for (var si = 0; si < 6; si++) {
                var seq = equip.slots[si];
                if (seq.length === 0) {
                    html += '<td style="color:#555">—</td>';
                } else {
                    var ch = '';
                    seq.forEach(function (eqs) {
                        var parts = eqs.split('|');
                        var qn2 = parseInt(parts[2].replace('Q', ''));
                        var hc = qn2 >= 7 ? ' eq-q' + qn2 + ' highlight' : '';
                        ch += '<span class="eq-name' + hc + '">' + parts[1] + ' ' + parts[2] + '</span><br>';
                    });
                    html += '<td>' + ch + '</td>';
                }
            }
            html += '</tr>\n';
        });
        html += '</table>\n';
    });
});

html += '<div class="footer">生成时间: ' + new Date().toLocaleString() + ' | 三国Q战 v4.0.0 | 橙色及以上为稀有掉落</div>\n';
html += '</body>\n</html>';

var outPath = path.join(os.homedir(), 'Desktop', '全关卡敌方装备表.html');
fs.writeFileSync(outPath, html, 'utf8');
console.log('Saved: ' + outPath);
console.log('Fuben: ' + allEntries.length + ', Main gates: ' + gateCount + ', Parts: ' + partKeys.length);
