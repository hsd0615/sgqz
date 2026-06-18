var fs = require('fs');

var equipData = {};

function add(code, slot, name, attack, attackPct, defense, defensePct, hp, hpPct, levelReq, quality, iconIdx) {
    equipData[code] = {slot:slot, name:name, attack:attack||0, attackPct:attackPct||0,
        defense:defense||0, defensePct:defensePct||0, hp:hp||0, hpPct:hpPct||0,
        levelReq:levelReq, quality:quality, iconIdx:iconIdx||0};
}

// 旧装备 (proto_4_1~30)
add('proto_4_1',1,'铁剑',50,0,0,0,0,0,1,1);
add('proto_4_2',1,'精钢剑',120,0,0,0,0,0,15,2);
add('proto_4_3',1,'青釭剑',200,0,0,0,0,0,30,3);
add('proto_4_4',1,'倚天剑',300,5,0,0,0,0,50,4);
add('proto_4_5',1,'方天画戟',500,10,0,0,0,0,80,5);
add('proto_4_11',2,'皮甲',0,0,30,0,0,0,1,1);
add('proto_4_12',2,'锁子甲',0,0,100,0,0,0,15,2);
add('proto_4_13',2,'明光铠',0,0,180,0,0,0,30,3);
add('proto_4_14',2,'龙鳞甲',0,0,250,5,0,0,50,4);
add('proto_4_15',2,'玄武战甲',0,0,400,8,0,0,80,5);
add('proto_4_21',3,'护身符',0,0,0,0,300,0,5,1);
add('proto_4_22',3,'翡翠环',0,0,0,0,600,0,20,2);
add('proto_4_23',3,'护心镜',0,0,0,0,1000,0,35,3);
add('proto_4_24',3,'和氏璧',50,5,50,5,1500,5,55,4);
add('proto_4_25',3,'传国玉玺',100,8,100,8,3000,8,100,5);
add('proto_4_6',4,'布帽',0,0,0,0,100,0,1,1);
add('proto_4_7',4,'铁盔',0,0,0,0,300,0,15,2);
add('proto_4_8',4,'银盔',0,0,0,0,600,0,30,3);
add('proto_4_9',4,'金冠',0,0,0,0,1000,5,50,4);
add('proto_4_10',4,'龙盔',0,0,0,0,2000,8,80,5);
add('proto_4_16',5,'草鞋',0,0,20,0,0,0,1,1);
add('proto_4_17',5,'皮靴',0,0,80,0,0,0,15,2);
add('proto_4_18',5,'铁靴',0,0,150,0,0,0,30,3);
add('proto_4_19',5,'银靴',0,0,220,5,0,0,50,4);
add('proto_4_20',5,'神行靴',0,0,350,8,0,0,80,5);
add('proto_4_26',6,'铜戒指',30,0,0,0,0,0,10,1);
add('proto_4_27',6,'银戒指',80,0,0,0,0,0,25,2);
add('proto_4_28',6,'金戒指',150,0,0,0,0,0,40,3);
add('proto_4_29',6,'龙戒',250,5,0,0,0,0,60,4);
add('proto_4_30',6,'神戒',400,8,0,0,0,0,90,5);

// 武侠新装备
add('proto_4_31',1,'柳叶刀',80,0,0,0,0,0,8,1,1);
add('proto_4_32',1,'雁翎刀',150,0,0,0,0,0,20,2,2);
add('proto_4_33',1,'鱼鳞刀',230,0,0,0,0,0,35,3,3);
add('proto_4_34',1,'金背刀',330,3,0,0,0,0,55,4,4);
add('proto_4_35',1,'斩马刀',450,6,0,0,0,0,75,5,5);
add('proto_4_36',1,'青龙偃月',600,8,0,0,0,0,100,6,6);
add('proto_4_37',1,'丈八蛇矛',800,10,0,0,0,0,130,7,7);
add('proto_4_38',1,'神罚',1200,15,0,0,0,0,160,8,8);
add('proto_4_39',2,'藤甲',0,0,50,0,0,0,8,1,9);
add('proto_4_40',2,'铁叶甲',0,0,120,0,0,0,20,2,10);
add('proto_4_41',2,'连环甲',0,0,200,0,0,0,35,3,11);
add('proto_4_42',2,'犀牛甲',0,0,280,3,0,0,55,4,12);
add('proto_4_43',2,'狻猊甲',0,0,380,6,0,0,75,5,13);
add('proto_4_44',2,'麒麟铠',0,0,500,8,0,0,100,6,14);
add('proto_4_45',2,'朱雀战袍',0,0,650,10,0,0,130,7,15);
add('proto_4_46',2,'不灭金身',0,0,900,15,0,0,160,8,16);
add('proto_4_47',3,'木符',0,0,0,0,400,0,10,1,17);
add('proto_4_48',3,'石符',0,0,0,0,800,0,25,2,18);
add('proto_4_49',3,'铜符',0,0,0,0,1300,0,40,3,19);
add('proto_4_50',3,'银符',0,0,0,0,2000,5,60,4,20);
add('proto_4_51',3,'金符',0,0,0,0,3000,8,80,5,21);
add('proto_4_52',3,'龙符',0,0,0,0,4500,10,105,6,22);
add('proto_4_53',3,'凤符',0,0,0,0,6500,12,135,7,23);
add('proto_4_54',3,'天地令',0,0,0,0,10000,18,165,8,24);
add('proto_4_55',4,'方巾',0,0,0,0,150,0,5,1,25);
add('proto_4_56',4,'铜冠',0,0,0,0,400,0,20,2,26);
add('proto_4_57',4,'镔铁盔',0,0,0,0,750,0,35,3,27);
add('proto_4_58',4,'凤翅冠',0,0,0,0,1200,5,55,4,28);
add('proto_4_59',4,'紫金冠',0,0,0,0,1800,8,75,5,29);
add('proto_4_60',4,'灵蛇盔',0,0,0,0,2800,10,100,6,30);
add('proto_4_61',4,'虎头盔',0,0,0,0,4200,12,130,7,31);
add('proto_4_62',4,'九龙冠',0,0,0,0,6500,18,160,8,32);
add('proto_4_63',5,'麻鞋',0,0,35,0,0,0,8,1,33);
add('proto_4_64',5,'快靴',0,0,100,0,0,0,20,2,34);
add('proto_4_65',5,'虎头靴',0,0,180,0,0,0,35,3,35);
add('proto_4_66',5,'飞云靴',0,0,260,3,0,0,55,4,36);
add('proto_4_67',5,'踏云靴',0,0,360,6,0,0,75,5,37);
add('proto_4_68',5,'凌波靴',0,0,480,8,0,0,100,6,38);
add('proto_4_69',5,'追月靴',0,0,620,10,0,0,130,7,39);
add('proto_4_70',5,'风云靴',0,0,850,15,0,0,160,8,40);
add('proto_4_71',6,'骨戒',50,0,0,0,0,0,12,1,41);
add('proto_4_72',6,'银环',100,0,0,0,0,0,28,2,42);
add('proto_4_73',6,'玉扳指',180,0,0,0,0,0,45,3,43);
add('proto_4_74',6,'血玉环',300,5,0,0,0,0,65,4,44);
add('proto_4_75',6,'龙环',480,8,0,0,0,0,95,5,45);
add('proto_4_76',6,'乾坤圈',700,12,0,0,0,0,140,6,46);

var qualities = ['','普通','精良','稀有','史诗','传说','神话','远古','至尊'];
var slotNames = ['','武器','铠甲','饰品Ⅰ','头盔','战靴','饰品Ⅱ'];

var items = [];
for(var k in equipData) items.push({code:k, d:equipData[k]});
items.sort(function(a,b){return a.d.slot!=b.d.slot?a.d.slot-b.d.slot:a.d.levelReq-b.d.levelReq;});

var html = '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>三国Q战 装备属性表 v2.11.0</title>';
html += '<style>body{font-family:Microsoft YaHei,sans-serif;background:#1a1a1a;color:#ddd;padding:20px}';
html += 'h1{color:#FFD700;text-align:center}h2{color:#C8A84E;border-bottom:1px solid #333;padding-top:20px}';
html += 'table{border-collapse:collapse;width:100%;margin:10px 0}';
html += 'th{background:#2a2a2a;padding:8px 6px;font-size:13px;text-align:center}';
html += 'td{padding:6px;font-size:12px;text-align:center;border-bottom:1px solid #333}';
html += 'tr:hover{background:#2a2a2a} .new{color:#FFD700}';
html += '.stat{font-weight:bold} .q1{color:#999} .q2{color:#CCC} .q3{color:#4bea13} .q4{color:#16d2fa} .q5{color:#e720f9} .q6{color:#FFD700} .q7{color:#FF6600} .q8{color:#FF0000}</style></head><body>';
html += '<h1>三国Q战 装备属性表 v2.11.0</h1>';
html += '<p style="text-align:center">共 ' + items.length + ' 件装备 | 6槽位 | 8品质 | 46件新装备</p>';

var lastSlot = 0;
for(var i=0; i<items.length; i++){
    var it = items[i];
    var d = it.d;
    var isNew = parseInt(it.code.split('_')[2]) >= 31;
    if(d.slot != lastSlot){
        if(lastSlot) html += '</tbody></table>';
        html += '<h2>' + slotNames[d.slot] + ' (' + (isNew ? '含新装备' : '基础装备') + ')</h2>';
        html += '<table><thead><tr><th>图标#</th><th>名称</th><th>品质</th><th>Lv</th><th>攻击</th><th>防御</th><th>生命</th><th>说明</th></tr></thead><tbody>';
        lastSlot = d.slot;
    }
    var attStr = '', defStr = '', hpStr = '';
    if(d.attack>0) attStr = '+' + d.attack + (d.attackPct>0?' +'+d.attackPct+'%':'');
    if(d.defense>0) defStr = '+' + d.defense + (d.defensePct>0?' +'+d.defensePct+'%':'');
    if(d.hp>0) hpStr = '+' + d.hp + (d.hpPct>0?' +'+d.hpPct+'%':'');
    var ico = d.iconIdx ? '<span class="new">'+(d.iconIdx<10?'0':'')+d.iconIdx+'</span>' : '-';
    html += '<tr>';
    html += '<td>' + ico + '</td>';
    html += '<td>' + (isNew?'<b>':'') + d.name + (isNew?'</b>':'') + '</td>';
    html += '<td class="q' + d.quality + ' stat">' + qualities[d.quality] + '</td>';
    html += '<td>Lv' + d.levelReq + '</td>';
    html += '<td>' + (attStr||'-') + '</td>';
    html += '<td>' + (defStr||'-') + '</td>';
    html += '<td>' + (hpStr||'-') + '</td>';
    html += '<td style="text-align:left;font-size:11px">' + d.name + '</td>';
    html += '</tr>';
}
html += '</tbody></table><p style="text-align:center;color:#666;margin-top:30px">新装备 = 粗体 | 图标# = 对应素材文件编号</p></body></html>';

var outPath = process.env.USERPROFILE + '/Desktop/装备属性表.html';
fs.writeFileSync(outPath, html);
console.log('OK: ' + outPath);
