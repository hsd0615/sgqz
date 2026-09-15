// 修复所有 kezhi 类型为 0 的武将，从 staticgeneral.xml 读取正确的克制类型
var fs = require('fs');
var db = JSON.parse(fs.readFileSync('/opt/data/sanguo.json','utf8'));

// 解析 staticgeneral.xml 中的 kezhi 默认值 (element-based XML)
var xml = fs.readFileSync('/opt/staticgeneral.xml','utf8');
var kezhiMap = {};
// Match: <code>general_X_Y</code> ... <kezhi>a:1|b:1|c:1</kezhi>
var blocks = xml.split('<RECORD>');
for (var bi = 0; bi < blocks.length; bi++) {
  var codeMatch = blocks[bi].match(/<code>([^<]+)<\/code>/);
  var kezhiMatch = blocks[bi].match(/<kezhi>([^<]+)<\/kezhi>/);
  if (codeMatch && kezhiMatch && kezhiMatch[1].length > 0) {
    kezhiMap[codeMatch[1]] = kezhiMatch[1];
  }
}
console.log('Loaded ' + Object.keys(kezhiMap).length + ' kezhi from XML');

var fixed = 0;
for (var i = 0; i < db.generals.length; i++) {
  var g = db.generals[i];
  if ((g.kezhi1||0) + (g.kezhi2||0) + (g.kezhi3||0) === 0) {
    var kz = kezhiMap[g.code];
    if (kz) {
      var parts = kz.split('|');
      if (parts.length >= 3) {
        g.kezhi1 = parseInt(parts[0].split(':')[0]) || 0;
        g.kezhi1_level = g.kezhi1_level || 1;
        g.kezhi2 = parseInt(parts[1].split(':')[0]) || 0;
        g.kezhi2_level = g.kezhi2_level || 1;
        g.kezhi3 = parseInt(parts[2].split(':')[0]) || 0;
        g.kezhi3_level = g.kezhi3_level || 1;
        console.log('Fixed: ' + g.code + ' ' + (g.name||'?') + ' k1=' + g.kezhi1 + ' k2=' + g.kezhi2 + ' k3=' + g.kezhi3);
        fixed++;
      }
    }
  }
}
if (fixed > 0) {
  fs.writeFileSync('/opt/data/sanguo.json', JSON.stringify(db));
  console.log('Migrated ' + fixed + ' generals');
} else {
  console.log('No migration needed');
}
