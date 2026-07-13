const fs = require('fs');

function round5(v) { return Math.round(v / 5) * 5; }

// ===== 饰品特殊效果——按名称差异化 =====
function getAccessorySpecials(name, quality) {
  let s = {critRate:0, critDmg:0, dmgBonus:0, dmgReduce:0, lifesteal:0};

  if (name.includes('戒指') || name.includes('龙戒') || name.includes('神戒') || name.includes('乾坤圈') || name.includes('破军环') || name.includes('贪狼令') && quality <= 8 || name.includes('星辰令') || name.includes('轮回印') && quality >= 8) {
    // 饰品II (戒指类): 功能性为主
    switch(quality) {
      case 1: s.dmgBonus = 4; break;
      case 2: s.dmgBonus = 6; break;
      case 3: s.dmgBonus = 8; break;
      case 4: s.dmgBonus = 10; s.lifesteal = 5; break;
      case 5: s.dmgBonus = 12; s.lifesteal = 8; break;
      case 6: s.critRate = 15; s.critDmg = 15; break;
      case 7: s.critRate = 20; s.critDmg = 20; break;
      case 8: s.dmgBonus = 15; s.lifesteal = 12; s.critRate = 15; break;
      case 9: s.dmgBonus = 18; s.lifesteal = 15; s.critRate = 18; break;
      case 10: s.dmgReduce = 20; s.lifesteal = 20; s.dmgBonus = 15; break;
    }
  } else {
    // 饰品I (符/环/镜/璧/令/魔符/杀戒/微星/混沌珠/贪狼/轮回): 攻击向
    switch(quality) {
      case 1: s.dmgBonus = 3; break;
      case 2: s.dmgBonus = 5; break;
      case 3: s.dmgBonus = 6; break;
      case 4: s.dmgBonus = 8; s.lifesteal = 3; break;
      case 5: s.dmgBonus = 10; s.lifesteal = 6; break;
      case 6: s.critRate = 18; s.critDmg = 12; s.dmgBonus = 6; break;
      case 7: s.critRate = 24; s.critDmg = 20; break;
      case 8: s.dmgBonus = 18; s.lifesteal = 15; s.dmgReduce = 10; break;
      case 9: s.dmgBonus = 22; s.dmgReduce = 15; s.lifesteal = 12; break;
      case 10: s.critRate = 30; s.critDmg = 35; s.dmgBonus = 15; break;
    }
  }
  return s;
}

// ===== EquipData.as =====
let asContent = fs.readFileSync('game/model/EquipData.as', 'utf8');
asContent = asContent.replace(/_data\["(proto_4_\d+)"\]=\{slot:(\d),name:"([^"]+)",([^}]*)\}/g, function(match, code, slot, name, attrs) {
  slot = parseInt(slot);
  let m;
  let atk = 0, def = 0, hp = 0, atkPct = 0, defPct = 0, hpPct = 0;
  let critRate = 0, critDmg = 0, dmgBonus = 0, dmgReduce = 0, lifesteal = 0;
  let levelReq = 1, quality = 1, iconIdx = 0;

  m = attrs.match(/attack:(-?\d+)/); if(m) atk = parseInt(m[1]);
  m = attrs.match(/attackPct:(-?\d+)/); if(m) atkPct = parseInt(m[1]);
  m = attrs.match(/defense:(-?\d+)/); if(m) def = parseInt(m[1]);
  m = attrs.match(/defensePct:(-?\d+)/); if(m) defPct = parseInt(m[1]);
  m = attrs.match(/hp:(-?\d+)/); if(m) hp = parseInt(m[1]);
  m = attrs.match(/hpPct:(-?\d+)/); if(m) hpPct = parseInt(m[1]);
  m = attrs.match(/critRate:(-?\d+)/); if(m) critRate = parseInt(m[1]);
  m = attrs.match(/critDmg:(-?\d+)/); if(m) critDmg = parseInt(m[1]);
  m = attrs.match(/dmgBonus:(-?\d+)/); if(m) dmgBonus = parseInt(m[1]);
  m = attrs.match(/dmgReduce:(-?\d+)/); if(m) dmgReduce = parseInt(m[1]);
  m = attrs.match(/lifesteal:(-?\d+)/); if(m) lifesteal = parseInt(m[1]);
  m = attrs.match(/levelReq:(\d+)/); if(m) levelReq = parseInt(m[1]);
  m = attrs.match(/quality:(\d+)/); if(m) quality = parseInt(m[1]);
  m = attrs.match(/iconIdx:(\d+)/); if(m) iconIdx = parseInt(m[1]);

  // 当前值恢复到约70%
  const SCALE = 1.3;

  // 同类型装备差异化: 根据iconIdx给不同装备不同特殊属性偏向
  function addVariation(s, iconId, quality) {
    var theme = iconId % 5;
    var bonus = Math.floor(quality / 2) + 1;
    if (theme === 0) s.dmgBonus = (s.dmgBonus || 0) + bonus;
    else if (theme === 1) s.critRate = (s.critRate || 0) + bonus;
    else if (theme === 2) s.critDmg = (s.critDmg || 0) + bonus;
    else if (theme === 3) s.lifesteal = (s.lifesteal || 0) + bonus;
    else s.dmgReduce = (s.dmgReduce || 0) + Math.floor(bonus / 2);
    return s;
  }

  // 取整到最近的5的倍数
  function round5(v) { return Math.round(v / 5) * 5; }

  if (slot === 3) {
    // 饰品: 零白值, 差异化特殊属性
    atk = 0; def = 0; hp = 0; atkPct = 0; defPct = 0; hpPct = 0;
    let spec = getAccessorySpecials(name, quality);
    critRate = spec.critRate; critDmg = spec.critDmg;
    dmgBonus = spec.dmgBonus; dmgReduce = spec.dmgReduce;
    lifesteal = spec.lifesteal;
  } else if (slot === 1) {
    // 武器: 只有攻击力
    atk = Math.floor(atk * SCALE);
    atkPct = Math.floor(atkPct * 1.0); // 保持百分比
    def = 0; hp = 0; defPct = 0; hpPct = 0;
    critRate = Math.min(Math.floor(critRate * 1.0), 10);
    critDmg = Math.min(Math.floor(critDmg * 1.0), 12);
    dmgBonus = Math.min(Math.floor(dmgBonus * 1.0), 6);
    dmgReduce = 0;
    lifesteal = Math.min(Math.floor(lifesteal * 1.0), 8);
  } else if (slot === 2) {
    // 铠甲: 只有防御力
    def = Math.floor(def * SCALE);
    defPct = Math.floor(defPct * 1.0);
    atk = 0; hp = 0; atkPct = 0; hpPct = 0;
    critRate = 0; critDmg = 0;
    dmgBonus = 0;
    dmgReduce = Math.min(Math.floor(dmgReduce * 1.0), 6);
    lifesteal = 0;
  } else if (slot === 4) {
    // 头盔: 只有生命值
    hp = Math.floor(hp * SCALE);
    hpPct = Math.floor(hpPct * 1.0);
    atk = 0; def = 0; atkPct = 0; defPct = 0;
    critRate = Math.min(Math.floor(critRate * 1.0), 6);
    critDmg = Math.min(Math.floor(critDmg * 1.0), 8);
    dmgBonus = 0;
    dmgReduce = Math.min(Math.floor(dmgReduce * 1.0), 5);
    lifesteal = 0;
  } else if (slot === 5) {
    // 战靴: 只有防御力
    def = Math.floor(def * SCALE);
    defPct = Math.floor(defPct * 1.0);
    atk = 0; hp = 0; atkPct = 0; hpPct = 0;
    critRate = Math.min(Math.floor(critRate * 1.0), 6);
    critDmg = Math.min(Math.floor(critDmg * 1.0), 8);
    dmgBonus = 0;
    dmgReduce = Math.min(Math.floor(dmgReduce * 1.0), 5);
    lifesteal = Math.min(Math.floor(lifesteal * 1.0), 4);
  }

  let parts = ['slot:'+slot, 'name:"'+name+'"'];
  if (atk !== 0) parts.push('attack:'+atk);
  if (atkPct !== 0) parts.push('attackPct:'+atkPct);
  if (def !== 0) parts.push('defense:'+def);
  if (defPct !== 0) parts.push('defensePct:'+defPct);
  if (hp !== 0) parts.push('hp:'+hp);
  if (hpPct !== 0) parts.push('hpPct:'+hpPct);
  if (critRate > 0) parts.push('critRate:'+critRate);
  if (critDmg > 0) parts.push('critDmg:'+critDmg);
  if (dmgBonus > 0) parts.push('dmgBonus:'+dmgBonus);
  if (dmgReduce > 0) parts.push('dmgReduce:'+dmgReduce);
  if (lifesteal > 0) parts.push('lifesteal:'+lifesteal);
  parts.push('levelReq:'+levelReq);
  parts.push('quality:'+quality);
  parts.push('iconIdx:'+iconIdx);

  return '_data["'+code+'"]={' + parts.join(',') + '}';
});
fs.writeFileSync('game/model/EquipData.as', asContent);
console.log('EquipData.as updated');

// ===== staticequip.xml =====
let xmlContent = fs.readFileSync('staticequip.xml', 'utf8');
xmlContent = xmlContent.replace(/<RECORD><code>(proto_4_\d+)<\/code><slot>(\d)<\/slot><name>([^<]+)<\/name>(.*?)<\/RECORD>/g, function(match, code, slot, name, rest) {
  slot = parseInt(slot);
  function getTag(tag) {
    var re = new RegExp('<'+tag+'>(-?\\d+)<\/'+tag+'>');
    var m = rest.match(re);
    return m ? parseInt(m[1]) : 0;
  }
  let atk = getTag('attack'), atkPct = getTag('attackPct');
  let def = getTag('defense'), defPct = getTag('defensePct');
  let hp = getTag('hp'), hpPct = getTag('hpPct');
  let critRate = getTag('critRate'), critDmg = getTag('critDmg');
  let dmgBonus = getTag('dmgBonus'), dmgReduce = getTag('dmgReduce');
  let lifesteal = getTag('lifesteal');
  let levelReq = getTag('levelReq'), quality = getTag('quality'), iconIdx = getTag('iconIdx');

  const SCALE = 1.2;

  if (slot === 3) {
    atk = 0; def = 0; hp = 0; atkPct = 0; defPct = 0; hpPct = 0;
    let spec = getAccessorySpecials(name, quality);
    critRate = spec.critRate; critDmg = spec.critDmg;
    dmgBonus = spec.dmgBonus; dmgReduce = spec.dmgReduce;
    lifesteal = spec.lifesteal;
  } else if (slot === 1) {
    atk = round5(Math.floor(atk * SCALE)); atkPct = Math.floor(atkPct * 1.0);
    def = 0; hp = 0; defPct = 0; hpPct = 0;
    critRate = Math.min(Math.floor(critRate * 1.5), 15);
    critDmg = Math.min(Math.floor(critDmg * 1.5), 18);
    dmgBonus = Math.min(Math.floor(dmgBonus * 1.5), 10);
    dmgReduce = 0;
    lifesteal = Math.min(Math.floor(lifesteal * 1.5), 12);
  } else if (slot === 2) {
    def = round5(Math.floor(def * SCALE)); defPct = Math.floor(defPct * 1.0);
    atk = 0; hp = 0; atkPct = 0; hpPct = 0;
    critRate = 0; critDmg = 0;
    dmgBonus = 0;
    dmgReduce = Math.min(Math.floor(dmgReduce * 2.0), 10);
    lifesteal = 0;
  } else if (slot === 4) {
    hp = round5(Math.floor(hp * SCALE)); hpPct = Math.floor(hpPct * 1.0);
    atk = 0; def = 0; atkPct = 0; defPct = 0;
    critRate = Math.min(Math.floor(critRate * 2.0), 10);
    critDmg = Math.min(Math.floor(critDmg * 2.0), 12);
    dmgBonus = 0;
    dmgReduce = Math.min(Math.floor(dmgReduce * 2.0), 8);
    lifesteal = 0;
  } else if (slot === 5) {
    def = round5(Math.floor(def * SCALE)); defPct = Math.floor(defPct * 1.0);
    atk = 0; hp = 0; atkPct = 0; hpPct = 0;
    critRate = Math.min(Math.floor(critRate * 2.0), 10);
    critDmg = Math.min(Math.floor(critDmg * 2.0), 12);
    dmgBonus = 0;
    dmgReduce = Math.min(Math.floor(dmgReduce * 2.0), 8);
    lifesteal = Math.min(Math.floor(lifesteal * 2.0), 6);
  }

  let descParts = [];
  if (atk !== 0) descParts.push('攻击+'+atk);
  if (atkPct > 0) descParts.push('攻击+'+atkPct+'%');
  if (def !== 0) descParts.push('防御+'+def);
  if (defPct > 0) descParts.push('防御+'+defPct+'%');
  if (hp !== 0) descParts.push('生命+'+hp);
  if (hpPct > 0) descParts.push('生命+'+hpPct+'%');
  if (critRate > 0) descParts.push('暴击率+'+critRate+'%');
  if (critDmg > 0) descParts.push('暴伤+'+critDmg+'%');
  if (dmgBonus > 0) descParts.push('增伤+'+dmgBonus+'%');
  if (dmgReduce > 0) descParts.push('减伤+'+dmgReduce+'%');
  if (lifesteal > 0) descParts.push('吸血+'+lifesteal+'%');
  let qNames = ['','普通','精良','稀有','史诗','传说','神话','远古','至尊','超凡','入圣'];
  let desc = descParts.join(' ') + ' [' + (qNames[quality]||'') + ']';

  let xml = '<RECORD><code>'+code+'</code><slot>'+slot+'</slot><name>'+name+'</name>';
  xml += '<attack>'+atk+'</attack><attackPct>'+atkPct+'</attackPct>';
  xml += '<defense>'+def+'</defense><defensePct>'+defPct+'</defensePct>';
  xml += '<hp>'+hp+'</hp><hpPct>'+hpPct+'</hpPct>';
  if (critRate > 0) xml += '<critRate>'+critRate+'</critRate>';
  if (critDmg > 0) xml += '<critDmg>'+critDmg+'</critDmg>';
  if (dmgBonus > 0) xml += '<dmgBonus>'+dmgBonus+'</dmgBonus>';
  if (dmgReduce > 0) xml += '<dmgReduce>'+dmgReduce+'</dmgReduce>';
  if (lifesteal > 0) xml += '<lifesteal>'+lifesteal+'</lifesteal>';
  xml += '<levelReq>'+levelReq+'</levelReq><quality>'+quality+'</quality><iconIdx>'+iconIdx+'</iconIdx>';
  xml += '<desc>'+desc+'</desc></RECORD>';
  return xml;
});
fs.writeFileSync('staticequip.xml', xmlContent);
console.log('staticequip.xml updated');

// ===== Cocos JSON =====
let json = JSON.parse(fs.readFileSync('cocos-client/assets/resources/data/equip_data.json', 'utf8'));
for (let code in json) {
  let e = json[code];
  let slot = e.slot;
  let name = e.name || '';
  let quality = e.quality || 1;
  const SCALE = 1.2;

  if (slot === 3) {
    e.attack = 0; e.defense = 0; e.hp = 0; e.attackPct = 0; e.defensePct = 0; e.hpPct = 0;
    let spec = getAccessorySpecials(name, quality);
    e.critRate = spec.critRate; e.critDmg = spec.critDmg;
    e.dmgBonus = spec.dmgBonus; e.dmgReduce = spec.dmgReduce;
    e.lifesteal = spec.lifesteal;
  } else if (slot === 1) {
    e.attack = Math.floor((e.attack||0) * SCALE); e.attackPct = Math.floor((e.attackPct||0) * 1.0);
    e.defense = 0; e.hp = 0; e.defensePct = 0; e.hpPct = 0;
    e.critRate = Math.min(Math.floor((e.critRate||0) * 1.0), 10);
    e.critDmg = Math.min(Math.floor((e.critDmg||0) * 1.0), 12);
    e.dmgBonus = Math.min(Math.floor((e.dmgBonus||0) * 1.0), 6);
    e.dmgReduce = 0;
    e.lifesteal = Math.min(Math.floor((e.lifesteal||0) * 1.0), 8);
  } else if (slot === 2) {
    e.defense = Math.floor((e.defense||0) * SCALE); e.defensePct = Math.floor((e.defensePct||0) * 1.0);
    e.attack = 0; e.hp = 0; e.attackPct = 0; e.hpPct = 0;
    e.critRate = 0; e.critDmg = 0;
    e.dmgBonus = 0;
    e.dmgReduce = Math.min(Math.floor((e.dmgReduce||0) * 1.0), 6);
    e.lifesteal = 0;
  } else if (slot === 4) {
    e.hp = Math.floor((e.hp||0) * SCALE); e.hpPct = Math.floor((e.hpPct||0) * 1.0);
    e.attack = 0; e.defense = 0; e.attackPct = 0; e.defensePct = 0;
    e.critRate = Math.min(Math.floor((e.critRate||0) * 1.0), 6);
    e.critDmg = Math.min(Math.floor((e.critDmg||0) * 1.0), 8);
    e.dmgBonus = 0;
    e.dmgReduce = Math.min(Math.floor((e.dmgReduce||0) * 1.0), 5);
    e.lifesteal = 0;
  } else if (slot === 5) {
    e.defense = Math.floor((e.defense||0) * SCALE); e.defensePct = Math.floor((e.defensePct||0) * 1.0);
    e.attack = 0; e.hp = 0; e.attackPct = 0; e.hpPct = 0;
    e.critRate = Math.min(Math.floor((e.critRate||0) * 1.0), 6);
    e.critDmg = Math.min(Math.floor((e.critDmg||0) * 1.0), 8);
    e.dmgBonus = 0;
    e.dmgReduce = Math.min(Math.floor((e.dmgReduce||0) * 1.0), 5);
    e.lifesteal = Math.min(Math.floor((e.lifesteal||0) * 1.0), 4);
  }
}
fs.writeFileSync('cocos-client/assets/resources/data/equip_data.json', JSON.stringify(json, null, 2));
console.log('equip_data.json updated');

// 打印预览
console.log('\n===== 饰品差异化预览 =====');
for (let q = 1; q <= 10; q++) {
  let s1 = getAccessorySpecials("木符", q);
  let s2 = getAccessorySpecials("铜戒指", q);
  console.log('Q'+q+' 饰品I: 增伤='+s1.dmgBonus+' 暴击='+s1.critRate+' 暴伤='+s1.critDmg+' 吸血='+s1.lifesteal+' 减伤='+s1.dmgReduce);
  console.log('Q'+q+' 饰品II: 增伤='+s2.dmgBonus+' 暴击='+s2.critRate+' 暴伤='+s2.critDmg+' 吸血='+s2.lifesteal+' 减伤='+s2.dmgReduce);
}
console.log('Done!');
