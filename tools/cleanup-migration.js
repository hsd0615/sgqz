// 启动时清理全服Q7以下装备
function cleanLowQualityEquip() {
  var lowQ = {};
  for (var ek in EQUIP_DATA) { if (EQUIP_DATA[ek].quality < 8) lowQ[ek] = true; }
  var br = 0, er = 0;
  db.bagItems = db.bagItems.filter(function(b) {
    if (!b.code || !b.code.startsWith('proto_4_')) return true;
    if (lowQ[b.code]) { br++; return false; }
    return true;
  });
  db.generals.forEach(function(g) {
    for (var s = 1; s <= 6; s++) {
      var eq = g['equip' + s];
      if (eq && eq !== '0' && lowQ[eq]) { g['equip' + s] = '0'; er++; }
    }
  });
  if (br > 0 || er > 0) console.log('[Cleanup] 移除低品质装备: 背包' + br + '件, 卸下' + er + '件');
}
