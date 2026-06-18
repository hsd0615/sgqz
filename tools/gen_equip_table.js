var fs = require('fs');

var equip = {};

function add(c,s,n,a,ap,d,dp,h,hp,ls,db,dr,cr,cd,lv,q,ix){
  equip[n]={code:c,slot:s,name:n,attack:a||0,attackPct:ap||0,defense:d||0,defensePct:dp||0,hp:h||0,hpPct:hp||0,
    lifesteal:ls||0,dmgBonus:db||0,dmgReduce:dr||0,critRate:cr||0,critDmg:cd||0,levelReq:lv,quality:q,iconIdx:ix||0};
}

const S={武器:1,铠甲:2,饰品Ⅰ:3,头盔:4,战靴:5,饰品Ⅱ:6};
const Q={1:'普通',2:'精良',3:'稀有',4:'史诗',5:'传说',6:'神话',7:'远古',8:'至尊'};
const QC={1:'#999',2:'#CCC',3:'#4bea13',4:'#16d2fa',5:'#e720f9',6:'#FFD700',7:'#FF6600',8:'#FF0000'};
const SN=['','武器','铠甲','饰品Ⅰ','头盔','战靴','饰品Ⅱ'];

// 武器
add('1',1,'铁剑',50,0,8,0,0,0,0,0,0,0,0,1,1);
add('2',1,'精钢剑',130,0,20,0,30,0,0,0,0,0,0,15,2);
add('3',1,'青釭剑',240,0,40,0,60,0,0,0,0,0,0,30,3);
add('4',1,'倚天剑',380,4,70,0,110,0,0,0,0,0,0,50,4);
add('5',1,'方天画戟',580,7,120,0,190,0,0,0,0,0,0,80,5);
add('31',1,'柳叶刀',70,0,12,0,25,0,0,0,0,0,0,8,1,1);
add('32',1,'雁翎刀',160,0,28,0,60,0,0,0,0,0,0,20,2,2);
add('33',1,'鱼鳞刀',270,0,52,0,110,0,0,0,0,0,0,35,3,3);
add('34',1,'金背刀',420,3,85,0,180,0,0,0,0,0,0,55,4,4);
add('35',1,'斩马刀',550,7,80,0,200,0,5,3,0,0,0,75,5,5);
add('36',1,'青龙偃月',780,9,160,0,380,0,0,0,0,8,15,100,6,6);
add('37',1,'丈八蛇矛',1400,14,-80,-5,-100,0,0,8,0,0,0,130,7,7);
add('38',1,'神罚',1800,15,500,5,1100,6,8,6,0,0,0,160,8,8);
// 铠甲
add('11',2,'皮甲',10,0,35,0,15,0,0,0,0,0,0,1,1);
add('12',2,'锁子甲',25,0,110,0,50,0,0,0,0,0,0,15,2);
add('13',2,'明光铠',50,0,200,0,100,0,0,0,0,0,0,30,3);
add('14',2,'龙鳞甲',85,0,310,4,180,0,0,0,0,0,0,50,4);
add('15',2,'玄武战甲',140,0,480,6,300,0,0,0,0,0,0,80,5);
add('39',2,'藤甲',12,0,48,0,22,0,0,0,0,0,0,8,1,9);
add('40',2,'铁叶甲',30,0,130,0,65,0,0,0,0,0,0,20,2,10);
add('41',2,'连环甲',60,0,235,0,130,0,0,0,0,0,0,35,3,11);
add('42',2,'犀牛甲',100,0,360,3,230,0,0,0,0,0,0,55,4,12);
add('43',2,'狻猊甲',130,0,520,6,320,0,0,0,5,0,0,75,5,13);
add('44',2,'麒麟铠',200,0,750,9,500,4,0,0,8,0,0,100,6,14);
add('45',2,'朱雀战袍',-60,0,1200,14,1000,8,0,0,10,0,0,130,7,15);
add('46',2,'不灭金身',500,4,1600,16,1300,8,3,0,12,0,0,160,8,16);
// 饰品Ⅰ
add('21',3,'护身符',15,0,20,0,250,0,0,0,0,0,0,5,1);
add('22',3,'翡翠环',35,0,50,0,550,0,0,0,0,0,0,20,2);
add('23',3,'护心镜',65,0,90,0,1000,0,0,0,0,0,0,35,3);
add('24',3,'和氏璧',110,3,150,2,1700,4,0,0,0,0,0,55,4);
add('25',3,'传国玉玺',180,5,250,4,2800,6,0,0,0,0,0,100,5);
add('47',3,'木符',18,0,25,0,320,0,0,0,0,0,0,10,1,17);
add('48',3,'石符',42,0,60,0,700,0,0,0,0,0,0,25,2,18);
add('49',3,'铜符',80,0,110,0,1250,0,0,0,0,0,0,40,3,19);
add('50',3,'银符',130,2,180,0,2000,4,0,0,0,0,0,60,4,20);
add('51',3,'金符',160,0,220,0,2800,7,4,2,0,0,0,80,5,21);
add('52',3,'龙符',250,0,360,0,4300,10,0,0,0,6,12,105,6,22);
add('53',3,'凤符',550,9,-50,0,6500,13,0,12,0,0,0,135,7,23);
add('54',3,'天地令',700,10,900,7,10000,17,6,5,0,0,0,165,8,24);
// 头盔
add('6',4,'布帽',0,0,12,0,100,0,0,0,0,0,0,1,1);
add('7',4,'铁盔',0,0,35,0,320,0,0,0,0,0,0,15,2);
add('8',4,'银盔',0,0,70,0,650,0,0,0,0,0,0,30,3);
add('9',4,'金冠',0,0,120,0,1100,4,0,0,0,0,0,50,4);
add('10',4,'龙盔',0,0,200,0,1900,7,0,0,0,0,0,80,5);
add('55',4,'方巾',0,0,18,0,140,0,0,0,0,0,0,5,1,25);
add('56',4,'铜冠',0,0,48,0,400,0,0,0,0,0,0,20,2,26);
add('57',4,'镔铁盔',0,0,95,0,780,0,0,0,0,0,0,35,3,27);
add('58',4,'凤翅冠',0,0,165,0,1300,4,0,0,0,0,0,55,4,28);
add('59',4,'紫金冠',0,0,250,0,2000,7,0,0,4,0,0,75,5,29);
add('60',4,'灵蛇盔',0,0,400,2,3200,10,0,0,6,0,0,100,6,30);
add('61',4,'虎头盔',-30,0,700,4,5200,14,0,0,8,0,0,130,7,31);
add('62',4,'九龙冠',0,0,1000,5,7500,17,0,0,10,0,0,160,8,32);
// 战靴
add('16',5,'草鞋',5,0,22,0,25,0,0,0,0,0,0,1,1);
add('17',5,'皮靴',15,0,85,0,75,0,0,0,0,0,0,15,2);
add('18',5,'铁靴',35,0,165,0,150,0,0,0,0,0,0,30,3);
add('19',5,'银靴',65,0,260,3,260,0,0,0,0,0,0,50,4);
add('20',5,'神行靴',110,0,400,5,420,0,0,0,0,0,0,80,5);
add('63',5,'麻鞋',8,0,32,0,35,0,0,0,0,0,0,8,1,33);
add('64',5,'快靴',22,0,105,0,95,0,0,0,0,0,0,20,2,34);
add('65',5,'虎头靴',48,0,200,0,195,0,0,0,0,0,0,35,3,35);
add('66',5,'飞云靴',85,0,320,3,330,0,0,0,0,0,0,55,4,36);
add('67',5,'踏云靴',120,0,450,6,450,0,0,0,0,5,10,75,5,37);
add('68',5,'凌波靴',200,0,680,8,700,0,4,3,0,0,0,100,6,38);
add('69',5,'追月靴',450,8,400,3,800,0,0,0,0,8,0,130,7,39);
add('70',5,'风云靴',450,4,1400,15,1600,6,3,0,8,0,0,160,8,40);
// 饰品Ⅱ
add('26',6,'铜戒指',38,0,8,0,50,0,0,0,0,0,0,10,1);
add('27',6,'银戒指',95,0,20,0,130,0,0,0,0,0,0,25,2);
add('28',6,'金戒指',180,0,40,0,260,0,0,0,0,0,0,40,3);
add('29',6,'龙戒',300,4,75,0,440,0,0,0,0,0,0,60,4);
add('30',6,'神戒',460,7,130,0,700,0,0,0,0,0,0,90,5);
add('71',6,'骨戒',55,0,12,0,70,0,0,0,0,0,0,12,1,41);
add('72',6,'银环',125,0,28,0,170,0,0,0,0,0,0,28,2,42);
add('73',6,'玉扳指',220,0,55,0,330,0,0,0,0,0,0,45,3,43);
add('74',6,'血玉环',350,4,95,0,550,0,0,0,0,0,0,65,4,44);
add('75',6,'龙环',500,8,120,0,750,0,5,2,0,0,0,95,5,45);
add('76',6,'乾坤圈',750,12,200,0,1200,5,0,0,0,7,15,140,6,46);

var items = Object.values(equip).sort((a,b)=>a.slot!=b.slot?a.slot-b.slot:a.levelReq-b.levelReq);

function fmt(n,p){if(!n&&!p)return'-';var s='';if(n>0)s+='+'+n;else if(n<0)s+=n;if(p>0)s+='+'+p+'%';else if(p<0)s+=p+'%';return s||'-';}
function sp(n){if(!n)return'';return n>0?'<span class="bonus">+'+n+'%</span>':'<span class="neg">'+n+'%</span>';}

var html='<!DOCTYPE html><html><head><meta charset="UTF-8"><title>三国Q战 装备属性表 v2.11.3</title><style>'
+'body{font-family:"Microsoft YaHei",sans-serif;background:#111;color:#ccc;padding:20px;max-width:1200px;margin:0 auto}'
+'h1{color:#FFD700;text-align:center;font-size:24px}h2{color:#C8A84E;border-bottom:1px solid #333;padding-top:24px;margin-bottom:8px}'
+'table{border-collapse:collapse;width:100%;margin:8px 0;font-size:13px}'
+'th{background:#222;padding:8px 5px;font-size:12px;text-align:center;position:sticky;top:0}'
+'td{padding:5px;text-align:center;border-bottom:1px solid #2a2a2a;font-size:12px}'
+'tr:hover{background:#1a1a1a}'
+'.q1{color:#999}.q2{color:#CCC}.q3{color:#4bea13}.q4{color:#16d2fa}.q5{color:#e720f9}.q6{color:#FFD700}.q7{color:#FF6600}.q8{color:#FF0000}'
+'.bonus{color:#FFD700}.neg{color:#FF4444}.tag{font-size:10px;padding:1px 4px;border-radius:2px;margin:0 1px}'
+'.t-suck{background:#440}.t-dmg{background:#404}.t-tank{background:#044}.t-crit{background:#404}.t-berserk{background:#400}.t-balance{background:#333}'
+'</style></head><body><h1>⚔️ 三国Q战 装备属性表 v2.11.3</h1>'
+'<p style="text-align:center;color:#888;font-size:12px">76件装备 · 6槽位 · 8品质 · 新增吸血/增伤/减伤/暴击</p>';

var lastSlot=0;
for(var i=0;i<items.length;i++){
  var d=items[i];
  if(d.slot!=lastSlot){
    if(lastSlot) html+='</tbody></table>';
    html+='<h2>'+SN[d.slot]+'</h2>';
    html+='<table><thead><tr><th>品质</th><th>名称</th><th>Lv</th><th>攻击</th><th>防御</th><th>气血</th><th>特殊属性</th></tr></thead><tbody>';
    lastSlot=d.slot;
  }
  var spec='';
  if(d.lifesteal) spec+='<span class="tag t-suck">吸血+'+d.lifesteal+'%</span> ';
  if(d.dmgBonus) spec+='<span class="tag t-dmg">增伤+'+d.dmgBonus+'%</span> ';
  if(d.dmgReduce) spec+='<span class="tag t-tank">减伤+'+d.dmgReduce+'%</span> ';
  if(d.critRate) spec+='<span class="tag t-crit">暴击+'+d.critRate+'%</span> ';
  if(d.critDmg) spec+='<span class="tag t-crit">暴伤+'+d.critDmg+'%</span> ';
  if(d.attack<0||d.defense<0||d.hp<0) spec+='<span class="tag t-berserk">负面</span> ';
  if(!spec) spec='-';

  html+='<tr>';
  html+='<td class="q'+d.quality+'"><b>'+Q[d.quality]+'</b></td>';
  html+='<td>'+(d.iconIdx?'🖼'+d.iconIdx+' ':'')+d.name+'</td>';
  html+='<td>Lv'+d.levelReq+'</td>';
  html+='<td>'+fmt(d.attack,d.attackPct)+'</td>';
  html+='<td>'+fmt(d.defense,d.defensePct)+'</td>';
  html+='<td>'+fmt(d.hp,d.hpPct)+'</td>';
  html+='<td style="text-align:left">'+spec+'</td>';
  html+='</tr>';
}
html+='</tbody></table><p style="text-align:center;color:#666;margin-top:30px;font-size:11px">'
+'<span class="tag t-suck">吸血</span> <span class="tag t-dmg">增伤</span> <span class="tag t-tank">减伤</span> '
+'<span class="tag t-crit">暴击</span> <span class="tag t-berserk">含负面</span></p></body></html>';

var out=process.env.USERPROFILE+'/Desktop/装备属性表.html';
fs.writeFileSync(out,html);
console.log('OK: '+out);
