var fs = require('fs');
var db = JSON.parse(fs.readFileSync('/opt/data/sanguo.json', 'utf8'));

var accounts = ['gm_admin', 'test_pro', 'test1'];
accounts.forEach(function(uid) {
  var p = db.players.find(function(x) { return String(x.user_id) === uid; });
  if (!p) { console.log(uid + ' not found'); return; }
  p.dianka = 999999;
  p.money = 99999999;
  p.exploit = 99999999;
  p.reverence = 99999999;
  p.rongyu = 99999;

  // 给所有道具99个
  var codes = [];
  for (var a = 1; a <= 3; a++) {
    var max = (a === 1) ? 23 : (a === 2) ? 8 : 4;
    for (var b = 0; b <= max; b++) codes.push('proto_' + a + '_' + b);
  }
  if (!db.bagItems) db.bagItems = [];
  codes.forEach(function(code) {
    var found = false;
    for (var i = 0; i < db.bagItems.length; i++) {
      var item = db.bagItems[i];
      if (String(item.player_id) === String(p.id) && (item.code === code || item.item_code === code)) {
        item.count = 99; found = true; break;
      }
    }
    if (!found) {
      db.bagItems.push({ id: db.nextId.bagItems++, player_id: p.id, code: code, count: 99 });
    }
  });
  console.log(uid + ': dianka=' + p.dianka + ' items=' + codes.length + 'x99');
});

fs.writeFileSync('/opt/data/sanguo.json', JSON.stringify(db));
console.log('All done');
