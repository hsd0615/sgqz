var fs = require('fs');
var db = JSON.parse(fs.readFileSync('/opt/data/sanguo.json', 'utf8'));

// Find or create test1
var pid;
var p = db.players.find(function(x) { return String(x.user_id) === 'test1'; });
if (!p) {
  pid = db.nextId.players++;
  db.players.push({
    id: pid, user_id: 'test1', agent: '4399', password: '123456',
    role_name: '测试一号', image_id: 1, level: 1,
    money: 99999999, dianka: 999999, exploit: 99999999,
    reverence: 99999999, rongyu: 99999, win_count: 0, lost_count: 0,
    finished_stages: '', history: '', login_server: 0, token: ''
  });
  console.log('Created test1, id=' + pid);
} else {
  pid = p.id;
  p.dianka = 999999;
  console.log('Found test1, id=' + pid + ', dianka set to 999999');
}

// Give 99 of all proto items
var allItems = [];
for (var a = 1; a <= 3; a++) {
  var max = (a === 1) ? 23 : (a === 2) ? 8 : 4;
  for (var b = 0; b <= max; b++) {
    allItems.push('proto_' + a + '_' + b);
  }
}
// Add 进化道具 codes that might be in DB
allItems.push('proto_3_1', 'proto_3_2', 'proto_3_3', 'proto_3_4');

if (!db.bagItems) db.bagItems = [];
var count = 0;
allItems.forEach(function(code) {
  var found = false;
  for (var i = 0; i < db.bagItems.length; i++) {
    var item = db.bagItems[i];
    if (String(item.player_id) === String(pid) && (item.code === code || item.item_code === code)) {
      item.count = 99;
      found = true;
      break;
    }
  }
  if (!found) {
    var nid = db.nextId.bagItems++;
    db.bagItems.push({ id: nid, player_id: pid, code: code, count: 99 });
  }
  count++;
});

fs.writeFileSync('/opt/data/sanguo.json', JSON.stringify(db));
console.log('Done: ' + count + ' items x99, dianka=' + (p ? p.dianka : 999999));

// Also add some starter generals
var starters = [
  ['general_1_0','王平','5:1|7:1|9:1'],['general_3_0','吕翔','2:1|1:1|6:1'],
  ['general_0_1','投石车','3:1|8:1|9:1'],['general_4_3','陈震','6:1|1:1|8:1'],
  ['general_9_0','鞠义','3:1|4:1|8:1'],
];
var existingGenerals = db.generals.filter(function(g) { return g.player_id === pid; });
if (existingGenerals.length === 0) {
  starters.forEach(function(s) {
    var kp = s[2].split('|');
    var g = {
      id: db.nextId.generals++, player_id: pid,
      general_id: Math.floor(Math.random() * 100000),
      code: s[0], name: s[1], level: 1, evolution: 0, feature: 0, tianfu: null,
      kezhi1: parseInt(kp[0].split(':')[0]), kezhi1_level: 1,
      kezhi2: parseInt(kp[1].split(':')[0]), kezhi2_level: 1,
      kezhi3: parseInt(kp[2].split(':')[0]), kezhi3_level: 1,
      is_deployed: 0
    };
    db.generals.push(g);
  });
  console.log('Added ' + starters.length + ' starter generals');
}
fs.writeFileSync('/opt/data/sanguo.json', JSON.stringify(db));
console.log('All done for test1');
