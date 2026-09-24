// Execute the AS3 factory body with constructor stubs to catch switch fallthrough.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const source = fs.readFileSync(path.join(root, 'game/Fight.as'), 'utf8');
const match = source.match(/private function armyFactory\([^]*?\) : AbstractSoldier\s*\{([^]*?)\n      \}/);
assert.ok(match, 'armyFactory must exist');
const typeSource = fs.readFileSync(path.join(root, 'game/model/Type.as'), 'utf8');
const Type = Object.fromEntries([...typeSource.matchAll(/const (\w+):int = (\d+);/g)].map(m => [m[1], Number(m[2])]));
const classes = ['Gunner', 'Saber', 'PartSoldier', 'Junzhu', 'Shooter'];
const constructors = classes.map(kind => function (army) { this.kind = kind; this.army = army; });
const factory = new Function('Type', ...classes, 'param1', 'param2', 'param3', match[1]);
const create = army => factory(Type, ...constructors, army, 1, false);
const xml = fs.readFileSync(path.join(root, 'staticgeneral.xml'), 'utf8');
const records = [...xml.matchAll(/<RECORD>([^]*?)<\/RECORD>/g)].map(m =>
  Object.fromEntries([...m[1].matchAll(/<(\w+)>([^<]*)<\/\1>/g)].map(v => [v[1], v[2]]))
);
const affected = records.filter(r => Number(r.type) === Type.WUDOUBING);
assert.ok(affected.some(r => r.code === 'general_6_5'), 'Include Guan Hai');
for (const record of affected) {
  for (const evolution of [0, 1, 2, 3]) {
    const army = {...record, type: Number(record.type), evolution};
    const result = create(army);
    assert.equal(result.kind, 'Saber', `${record.code} ${record.name}, evolution ${evolution}`);
    assert.equal(result.army, army, 'Preserve the configured army and skin');
  }
}
for (const [type, kind] of [[Type.PART_SOLDIER, 'PartSoldier'], [Type.TOUSHICHE, 'Gunner'], [Type.QIBING, 'Saber'], [Type.JUNZHU, 'Junzhu'], [Type.GONGBING, 'Shooter']]) {
  assert.equal(create({type}).kind, kind, `Unrelated type ${type}`);
}
console.log(`PASS: ${affected.length} martial records at 4 evolution levels; 5 control branches`);
