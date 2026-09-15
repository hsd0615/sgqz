const fs = require('fs');
const path = require('path');

const f = path.join(__dirname, '..', 'server', 'start_fixed.js');
let c = fs.readFileSync(f, 'utf-8');

// Add migration call after migrateEquipment()
c = c.replace(
  'migrateEquipment();\n\t//cleanLowQualityEquip();',
  'migrateEquipment();\n\tmigrateBagItems();  // 统一背包旧格式\n\t//cleanLowQualityEquip();'
);

// Add the migration function
const funcInsert = '\n\t// 统一背包道具格式: 旧格式(item_code/item_count) -> 新格式(code/count)\n' +
  '\tfunction migrateBagItems() {\n' +
  '\t  if (!db.bagItems) return;\n' +
  '\t  var migrated = 0;\n' +
  '\t  for (var bi = 0; bi < db.bagItems.length; bi++) {\n' +
  '\t    var item = db.bagItems[bi];\n' +
  '\t    if (item.item_code && !item.code) { item.code = item.item_code; delete item.item_code; migrated++; }\n' +
  '\t    if (item.item_count !== undefined && item.count === undefined) { item.count = item.item_count; delete item.item_count; migrated++; }\n' +
  '\t  }\n' +
  '\t  if (migrated > 0) console.log(\'[Migrate] Fixed \' + migrated + \' bag item format issues\');\n' +
  '\t}\n';

c = c.replace('// 启动时清理全服Q7以下装备', funcInsert + '\n// 启动时清理全服Q7以下装备');

fs.writeFileSync(f, c);
console.log('OK - migration function added');
