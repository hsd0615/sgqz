#!/usr/bin/env node
// 从 EquipData.as 数据生成 staticequip.xml（服务端客户端名称统一）
const fs = require('fs');
const path = require('path');
const BASE = path.dirname(__dirname);

// === EquipData.as 完整数据 ===
const items = [
  {c:'proto_4_31',s:1,n:'铁剑',atk:50,def:8,hp:25,lr:1,q:1,ii:18},
  {c:'proto_4_32',s:1,n:'精钢剑',atk:130,def:20,hp:60,lr:15,q:2,ii:17},
  {c:'proto_4_33',s:1,n:'青釭剑',atk:240,def:40,hp:110,lr:30,q:3,ii:19},
  {c:'proto_4_34',s:1,n:'倚天剑',atk:380,ap:4,def:70,hp:180,lr:50,q:4,ii:12},
  {c:'proto_4_35',s:1,n:'方天画戟',atk:580,ap:7,def:120,hp:290,lr:80,q:5,ii:14},
  {c:'proto_4_36',s:1,n:'青龙偃月',atk:800,ap:9,def:160,hp:460,lr:100,q:6,ii:20,cr:16,cd:15},
  {c:'proto_4_37',s:1,n:'丈八蛇矛',atk:2200,ap:15,def:-60,hp:1400,lr:130,q:7,ii:11,db:10},
  {c:'proto_4_38',s:1,n:'神罚',atk:3500,ap:20,def:900,hp:2600,lr:160,q:8,ii:16,db:8,ls:10},
  {c:'proto_4_81',s:1,n:'寒月刀',atk:5000,ap:25,def:1400,hp:3600,lr:185,q:9,ii:13,ls:12},
  {c:'proto_4_82',s:1,n:'灭世',atk:7000,ap:30,def:2000,hp:5200,lr:200,q:10,ii:15,db:15,cr:30},
  {c:'proto_4_83',s:1,n:'血祭之刃',atk:5500,ap:28,def:600,hp:3000,lr:170,q:10,ii:15,ls:20,db:12},
  // 铠甲
  {c:'proto_4_39',s:2,n:'皮甲',def:48,atk:12,hp:22,lr:8,q:1,ii:9},
  {c:'proto_4_40',s:2,n:'锁子甲',def:130,atk:30,hp:65,lr:20,q:2,ii:9},
  {c:'proto_4_41',s:2,n:'明光铠',def:235,atk:60,hp:130,lr:35,q:3,ii:9},
  {c:'proto_4_42',s:2,n:'龙鳞甲',def:360,dp:3,atk:100,hp:230,lr:55,q:4,ii:8},
  {c:'proto_4_43',s:2,n:'玄武战甲',def:520,dp:6,atk:130,hp:370,lr:75,q:5,ii:8,dr:5},
  {c:'proto_4_44',s:2,n:'麒麟铠',def:750,dp:9,atk:200,hp:580,lr:100,q:6,ii:10,dr:8},
  {c:'proto_4_45',s:2,n:'朱雀战袍',def:2200,dp:16,atk:-60,hp:2000,lr:130,q:7,ii:10,dr:12},
  {c:'proto_4_46',s:2,n:'不灭金身',def:3500,dp:22,atk:1000,hp:3400,lr:160,q:8,ii:10,dr:16,ls:6},
  {c:'proto_4_84',s:2,n:'龙纹战甲',def:5000,dp:28,atk:1500,hp:4800,lr:185,q:9,ii:10,dr:20},
  {c:'proto_4_85',s:2,n:'万古不朽',def:7000,dp:35,atk:2200,hp:6800,lr:200,q:10,ii:10,dr:25,ls:10},
  {c:'proto_4_86',s:2,n:'荆棘反甲',def:5000,dp:25,atk:1200,hp:4500,lr:170,q:10,ii:10,dr:15,db:15},
  // 饰品I
  {c:'proto_4_47',s:3,n:'木符',hp:320,atk:18,def:25,lr:10,q:1,ii:30},
  {c:'proto_4_48',s:3,n:'翡翠环',hp:700,atk:42,def:60,lr:25,q:2,ii:27},
  {c:'proto_4_49',s:3,n:'护心镜',hp:1250,atk:80,def:110,lr:40,q:3,ii:22},
  {c:'proto_4_50',s:3,n:'和氏璧',hp:2000,hpct:4,atk:130,ap:2,def:180,lr:60,q:4,ii:22},
  {c:'proto_4_51',s:3,n:'天地令',hp:3100,hpct:7,atk:200,def:280,lr:80,q:5,ii:24,ls:4},
  {c:'proto_4_52',s:3,n:'嗜血魔符',hp:4800,hpct:10,atk:320,def:430,lr:105,q:6,ii:23,ls:8,db:4},
  {c:'proto_4_53',s:3,n:'七杀戒',hp:16000,hpct:18,atk:1200,def:1500,lr:135,q:7,ii:21,cr:30,cd:20},
  {c:'proto_4_54',s:3,n:'紫微星',hp:24000,hpct:24,atk:1800,def:2200,lr:165,q:8,ii:26,db:10,ls:8},
  {c:'proto_4_87',s:3,n:'混沌珠',hp:36000,hpct:30,atk:2800,def:3200,lr:185,q:9,ii:25,dr:12,db:12},
  {c:'proto_4_88',s:3,n:'贪狼令',hp:55000,hpct:40,atk:4000,def:4800,lr:200,q:10,ii:28,cr:30,cd:30},
  {c:'proto_4_89',s:3,n:'轮回印',hp:45000,hpct:35,atk:3200,def:3800,lr:180,q:10,ii:29,dr:18,ls:15},
  // 头盔
  {c:'proto_4_55',s:4,n:'布帽',hp:140,def:18,lr:5,q:1,ii:4},
  {c:'proto_4_56',s:4,n:'铁盔',hp:400,def:48,lr:20,q:2,ii:4},
  {c:'proto_4_57',s:4,n:'银盔',hp:780,def:95,lr:35,q:3,ii:4},
  {c:'proto_4_58',s:4,n:'金冠',hp:1300,hpct:4,def:165,lr:55,q:4,ii:3},
  {c:'proto_4_59',s:4,n:'龙盔',hp:2100,hpct:7,def:270,lr:75,q:5,ii:3,dr:4},
  {c:'proto_4_60',s:4,n:'灵蛇盔',hp:3300,hpct:10,def:420,lr:100,q:6,ii:3,dr:6},
  {c:'proto_4_61',s:4,n:'天尊冠',hp:14000,hpct:20,def:1800,dp:8,lr:130,q:7,ii:2},
  {c:'proto_4_62',s:4,n:'九龙冠',hp:24000,hpct:26,def:2800,dp:12,lr:160,q:8,ii:1},
  {c:'proto_4_90',s:4,n:'混沌盔',hp:38000,hpct:34,def:4000,lr:185,q:9,ii:2,dr:16},
  {c:'proto_4_91',s:4,n:'洞察之眼',hp:55000,hpct:42,def:5500,lr:200,q:10,ii:1,cr:30,cd:35},
  // 战靴
  {c:'proto_4_63',s:5,n:'草鞋',def:32,atk:8,hp:35,lr:8,q:1,ii:5},
  {c:'proto_4_64',s:5,n:'皮靴',def:105,atk:22,hp:95,lr:20,q:2,ii:5},
  {c:'proto_4_65',s:5,n:'铁靴',def:200,atk:48,hp:195,lr:35,q:3,ii:5},
  {c:'proto_4_66',s:5,n:'银靴',def:320,dp:3,atk:85,hp:330,lr:55,q:4,ii:6},
  {c:'proto_4_67',s:5,n:'神行靴',def:490,dp:6,atk:140,hp:520,lr:75,q:5,ii:6,cr:20,cd:10},
  {c:'proto_4_68',s:5,n:'凌波靴',def:720,dp:9,atk:220,hp:800,lr:100,q:6,ii:6,ls:4,db:3},
  {c:'proto_4_69',s:5,n:'追月靴',def:2800,dp:18,atk:1000,hp:3400,lr:130,q:7,ii:7,cr:20},
  {c:'proto_4_70',s:5,n:'风云靴',def:4200,dp:24,atk:1600,hp:5200,lr:160,q:8,ii:7,dr:12,ls:6},
  {c:'proto_4_92',s:5,n:'虚空靴',def:6000,dp:32,atk:2400,hp:7200,lr:185,q:9,ii:7,dr:18,cr:25},
  {c:'proto_4_93',s:5,n:'破灭靴',def:8500,dp:40,atk:3500,hp:10000,lr:200,q:10,ii:7,dr:24,cd:35},
  {c:'proto_4_94',s:5,n:'疾风之足',def:6500,dp:30,atk:2600,hp:7800,lr:170,q:10,ii:7,cr:30,cd:40},
  // 饰品II
  {c:'proto_4_71',s:6,n:'铜戒指',atk:55,def:12,hp:70,lr:12,q:1,ii:30},
  {c:'proto_4_72',s:6,n:'银戒指',atk:125,def:28,hp:170,lr:28,q:2,ii:27},
  {c:'proto_4_73',s:6,n:'金戒指',atk:220,def:55,hp:330,lr:45,q:3,ii:22},
  {c:'proto_4_74',s:6,n:'龙戒',atk:350,ap:4,def:95,hp:550,lr:65,q:4,ii:22},
  {c:'proto_4_75',s:6,n:'神戒',atk:540,ap:8,def:160,hp:880,lr:95,q:5,ii:24,ls:5},
  {c:'proto_4_76',s:6,n:'乾坤圈',atk:800,ap:12,def:260,hp:1400,lr:140,q:6,ii:23,cr:30,cd:15},
  {c:'proto_4_95',s:6,n:'破军环',atk:3000,ap:22,def:1100,hp:5800,lr:160,q:7,ii:21,cr:25},
  {c:'proto_4_96',s:6,n:'贪狼令',atk:4200,ap:28,def:1600,hp:8200,lr:180,q:8,ii:26,db:12,ls:10},
  {c:'proto_4_97',s:6,n:'星辰令',atk:6000,ap:35,def:2200,hp:11500,lr:195,q:9,ii:25,cr:30,cd:30},
  {c:'proto_4_98',s:6,n:'轮回印',atk:8500,ap:42,def:3200,hp:15500,lr:200,q:10,ii:29,dr:16,ls:15}
];

// 兼容映射
const compat = {
  'proto_4_1':'proto_4_31','proto_4_2':'proto_4_32','proto_4_3':'proto_4_33','proto_4_4':'proto_4_34','proto_4_5':'proto_4_35',
  'proto_4_11':'proto_4_39','proto_4_12':'proto_4_40','proto_4_13':'proto_4_41','proto_4_14':'proto_4_42','proto_4_15':'proto_4_43',
  'proto_4_21':'proto_4_47','proto_4_22':'proto_4_48','proto_4_23':'proto_4_49','proto_4_24':'proto_4_50','proto_4_25':'proto_4_51',
  'proto_4_6':'proto_4_55','proto_4_7':'proto_4_56','proto_4_8':'proto_4_57','proto_4_9':'proto_4_58','proto_4_10':'proto_4_59',
  'proto_4_16':'proto_4_63','proto_4_17':'proto_4_64','proto_4_18':'proto_4_65','proto_4_19':'proto_4_66','proto_4_20':'proto_4_67',
  'proto_4_26':'proto_4_71','proto_4_27':'proto_4_72','proto_4_28':'proto_4_73','proto_4_29':'proto_4_74','proto_4_30':'proto_4_75'
};

const byCode = {};
items.forEach(it => byCode[it.c] = it);

const qNames = ['','普通','精良','稀有','史诗','传说','神话','远古','至尊','超凡','入圣'];
const slotNames = {1:'武器',2:'铠甲',3:'饰品Ⅰ',4:'头盔',5:'战靴',6:'饰品Ⅱ'};

function makeRecord(it, code) {
  const desc = [
    it.atk ? '攻击+' + it.atk : '', it.ap ? '攻击+' + it.ap + '%' : '',
    it.def ? '防御+' + it.def : '', it.dp ? '防御+' + it.dp + '%' : '',
    it.hp ? '生命+' + it.hp : '', it.hpct ? '生命+' + it.hpct + '%' : '',
    it.db ? ' 增伤+' + it.db + '%' : '', it.dr ? ' 减伤+' + it.dr + '%' : '',
    it.ls ? ' 吸血+' + it.ls + '%' : '', it.cr ? ' 暴击率+' + it.cr + '%' : '',
    it.cd ? ' 暴伤+' + it.cd + '%' : ''
  ].filter(Boolean).join(' ');
  const descStr = desc + ' [' + qNames[it.q] + ']';

  let rec = '  <RECORD>';
  rec += '<code>' + code + '</code><slot>' + it.s + '</slot><name>' + it.n + '</name>';
  rec += '<attack>' + (it.atk || 0) + '</attack><attackPct>' + (it.ap || 0) + '</attackPct>';
  rec += '<defense>' + (it.def || 0) + '</defense><defensePct>' + (it.dp || 0) + '</defensePct>';
  rec += '<hp>' + (it.hp || 0) + '</hp><hpPct>' + (it.hpct || 0) + '</hpPct>';
  if (it.db) rec += '<dmgBonus>' + it.db + '</dmgBonus>';
  if (it.dr) rec += '<dmgReduce>' + it.dr + '</dmgReduce>';
  if (it.ls) rec += '<lifesteal>' + it.ls + '</lifesteal>';
  if (it.cr) rec += '<critRate>' + it.cr + '</critRate>';
  if (it.cd) rec += '<critDmg>' + it.cd + '</critDmg>';
  rec += '<levelReq>' + it.lr + '</levelReq><quality>' + it.q + '</quality>';
  rec += '<iconIdx>' + it.ii + '</iconIdx><desc>' + descStr + '</desc>';
  rec += '</RECORD>\n';
  return rec;
}

let xml = '<RECORDS>\n';
let currentSlot = 0;

// 输出新码 (31-98)
const sorted = items.slice().sort((a, b) => a.s - b.s || parseInt(a.c.split('_')[2]) - parseInt(b.c.split('_')[2]));
sorted.forEach(it => {
  if (it.s !== currentSlot) {
    if (currentSlot > 0) xml += '\n';
    xml += '  <!-- ====== ' + slotNames[it.s] + ' (slot=' + it.s + ') ====== -->\n';
    currentSlot = it.s;
  }
  xml += makeRecord(it, it.c);
});

// 输出旧码别名 (1-30)
xml += '\n  <!-- ====== 旧码兼容 (1-30) ====== -->\n';
Object.keys(compat).sort().forEach(oldCode => {
  const newCode = compat[oldCode];
  const it = byCode[newCode];
  if (!it) return;
  xml += makeRecord(it, oldCode);
});

xml += '</RECORDS>\n';

const outPath = path.join(BASE, 'staticequip.xml');
fs.writeFileSync(outPath, xml, 'utf-8');
const count = xml.split('<RECORD>').length - 1;
console.log('staticequip.xml rewritten: ' + count + ' records → ' + outPath);
