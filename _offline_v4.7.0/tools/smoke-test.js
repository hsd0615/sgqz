// 三国Q战冒烟测试 — 每次代码修改后必跑
// Usage: node tools/smoke-test.js

const http = require('http');
const HOST = '47.96.41.243', PORT = 3000;
const ADMIN_KEY = 'sanguoq_admin_2024';

function apiPost(path, data) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);
    const options = { hostname: HOST, port: PORT, path, method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(postData) } };
    const req = http.request(options, res => { let body = ''; res.on('data', c => body += c); res.on('end', () => { try { resolve(JSON.parse(body)); } catch(e) { resolve(body); } }); });
    req.on('error', reject); req.setTimeout(10000, () => { req.destroy(); reject(new Error('timeout')); });
    req.write(postData); req.end();
  });
}

let pass = 0, fail = 0;
function ok(name, cond, detail) {
  if (cond) { pass++; console.log('  ✅ ' + name + (detail ? ' — ' + detail : '')); }
  else { fail++; console.log('  ❌ ' + name + (detail ? ' — ' + detail : '')); }
}

async function main() {
  console.log('═══════════════════════');
  console.log(' 三国Q战 冒烟测试');
  console.log('═══════════════════════\n');

  // ── 1. 服务健康 ──
  console.log('[1] 服务健康');
  const ver = await apiPost('/api/version', {});
  ok('服务在线', ver.success && ver.version);

  let token, rid, uid, bag, gens;

  // ── 2. 登录 ──
  console.log('\n[2] 登录');
  const login = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
  ok('登录成功', login.success, login.message||'');
  if (!login.success) { console.log('登录失败, 终止'); process.exit(1); }
  token = login.data.token; rid = login.data.roleID; uid = login.data.userID;
  bag = login.data.bagModel || [];

  // ── 3. 弹药消耗+持久化 ──
  console.log('\n[3] 弹药');
  const ammo = bag.find(b => (b.code||'').startsWith('proto_2_'));
  if (ammo) {
    const before = ammo.count;
    const r = await apiPost('/api/game/use-ammo', { head: 10013, agent: '4399', ver: '2.1.4', token, roleID: rid, userID: uid, id: ammo.id });
    ok('消耗请求', r.success);
    const relogin = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
    token = relogin.data.token;
    const after = (relogin.data.bagModel||[]).find(b => b.id === ammo.id);
    ok('持久化', after && after.count === before - 1, before + '→' + (after?after.count:'?'));
  } else { ok('弹药存在', false, '无弹药'); }

  // ── 4. 进化卷消耗 ──
  console.log('\n[4] 进化');
  gens = (await apiPost('/api/game/load-generals', { token, roleID: rid, userID: uid })).data.armyModel;
  const evoGen = (gens||[]).find(g => (g.evolution||0) < 10);
  if (evoGen) {
    const evoRes = await apiPost('/api/general/evolve', { head: 10005, agent: '4399', ver: '2.1.4', token, roleID: rid, userID: uid, id: evoGen.id });
    ok('进化请求', evoRes.success, evoRes.message||'');
    ok('进化卷消耗', evoRes.data && evoRes.data.itemID > 0, 'itemID=' + ((evoRes.data||{}).itemID||0));
    if (evoRes.data && evoRes.data.general) ok('进化升级', true, 'evo→' + evoRes.data.general.evolution);
  }

  // ── 5. 饰品slot5 ──
  console.log('\n[5] 饰品装备');
  const login2 = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
  token = login2.data.token; bag = login2.data.bagModel;
  // 已知饰品code集合(slot=3)
  const ACC_CODES = ['proto_4_47','proto_4_48','proto_4_49','proto_4_50','proto_4_51','proto_4_52','proto_4_53','proto_4_54','proto_4_71','proto_4_72','proto_4_73','proto_4_74','proto_4_75','proto_4_76','proto_4_95','proto_4_96','proto_4_97','proto_4_98'];
  const acc = bag.find(b => ACC_CODES.includes(b.code||''));
  gens = (await apiPost('/api/game/load-generals', { token, roleID: rid, userID: uid })).data.armyModel;
  const gen = gens[0];
  if (acc && gen) {
    const eqRes = await apiPost('/api/general/equip', { head: 10050, agent: '4399', ver: '2.1.4', token, roleID: rid, userID: uid, id: gen.id, slot: 5, itemCode: acc.code });
    ok('饰品槽5', eqRes.success, eqRes.message || acc.code);

    // 卸下测试
    if (eqRes.success) {
      const uneqRes = await apiPost('/api/general/unequip', { head: 10051, agent: '4399', ver: '2.1.4', token, roleID: rid, userID: uid, id: gen.id, slot: 5 });
      ok('卸下', uneqRes.success, uneqRes.message||'');
      // 验证卸下后背包有该装备
      const login3 = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
      const backInBag = (login3.data.bagModel||[]).some(b => b.code === acc.code);
      ok('卸下后背包有', backInBag, acc.code);
    }
  }

  // ── 6. 批量售卖 ──
  console.log('\n[6] 批量售卖');
  const login4 = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
  token = login4.data.token; bag = login4.data.bagModel;
  const sellItems = bag.filter(b => (b.code||'').startsWith('proto_4_')).slice(0, 3);
  if (sellItems.length > 0) {
    const codes = sellItems.map(b => b.code).join(',');
    const sellRes = await apiPost('/api/general/sell', { head: 10052, agent: '4399', ver: '2.1.4', token, roleID: rid, userID: uid, itemCodes: codes });
    ok('批量售卖', sellRes.success && sellRes.data.soldCount > 0, '售出' + (sellRes.data||{}).soldCount + '件 银+' + (sellRes.data||{}).totalSilver);
  }

  // ── 7. 克制概率 ──
  console.log('\n[7] 克制进阶');
  const login5 = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
  token = login5.data.token;
  gens = (await apiPost('/api/game/load-generals', { token, roleID: rid, userID: uid })).data.armyModel;
  const kg = gens.find(g => { const lv = g['kezhi1_level']||1; return lv < 5; });
  if (kg) {
    let suc = 0;
    for (let i = 0; i < 3; i++) {
      const kr = await apiPost('/api/general/kezhi', { head: 10006, agent: '4399', ver: '2.1.4', token, roleID: rid, userID: uid, id: kg.id, index: 0 });
      if (kr.data && kr.data.general) suc++;
    }
    ok('概率生效', suc < 3, '3次成功' + suc + '次 (非100%)');
  }

  // ── 8. 副本翻牌 ──
  console.log('\n[8] 副本翻牌');
  const login6 = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
  token = login6.data.token;
  for (const lv of [25, 60, 120]) {
    const award = await apiPost('/api/fuben/award', { head: 10018, stageID: 1, index: 3, result: 1, level: lv, token, roleID: rid, userID: uid, agent: '4399', ver: '2.1.4' });
    if (award.success && award.data.pai) {
      const eqPart = award.data.pai[1].split('|');
      const eqQ = eqPart[1].startsWith('proto_4_') ? '装备' : '?';
      const expQ = Math.min(10, Math.floor(lv/15)+1);
      ok('Lv'+lv+'翻牌', eqPart[1].startsWith('proto_4_'), '预期Q'+expQ+' → ' + eqPart[1]);
    }
  }

  // ── 9. 升级 ──
  console.log('\n[9] 武将升级');
  const login7 = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
  token = login7.data.token; rid = login7.data.roleID; uid = login7.data.userID;
  gens = (await apiPost('/api/game/load-generals', { token, roleID: rid, userID: uid })).data.armyModel;
  if (gens && gens[0]) {
    const upRes = await apiPost('/api/general/upgrade', { head: 10003, agent: '4399', ver: '2.1.4', token, roleID: rid, userID: uid, id: gens[0].id });
    ok('升级请求', upRes.success, upRes.message || 'lv=' + ((upRes.data||{}).level||'?'));
  }

  // ── 结果 ──
  console.log('\n═══════════════════════');
  console.log(' ' + pass + ' passed, ' + fail + ' failed');
  console.log('═══════════════════════');
  process.exit(fail > 0 ? 1 : 0);
}

main().catch(e => { console.log('Fatal:', e.message); process.exit(1); });
