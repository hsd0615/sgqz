// 三国Q战冒烟测试 — 自动化验证关键功能
// Usage: node tools/smoke-test.js

const http = require('http');
const HOST = '47.96.41.243', PORT = 3000;
const ADMIN_KEY = 'sanguoq_admin_2024';

function apiPost(path, data) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);
    const options = { hostname: HOST, port: PORT, path, method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(postData) } };
    const req = http.request(options, res => { let body = ''; res.on('data', c => body += c); res.on('end', () => { try { resolve(JSON.parse(body)); } catch(e) { resolve(body); } }); });
    req.on('error', reject); req.setTimeout(10000, () => { req.destroy(); reject(new Error('timeout')); });
    req.write(postData); req.end();
  });
}

let passed = 0, failed = 0;
function check(name, condition, detail) {
  if (condition) { passed++; console.log('  ✅ ' + name + (detail ? ' — ' + detail : '')); }
  else { failed++; console.log('  ❌ ' + name + (detail ? ' — ' + detail : '')); }
}

(async () => {
  console.log('═══════════════════════');
  console.log(' 三国Q战 冒烟测试');
  console.log('═══════════════════════\n');

  // 1. Login
  console.log('[1] 登录');
  let loginRes = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
  check('登录成功', loginRes.success, loginRes.message);
  if (!loginRes.success) { console.log('\n登录失败, 终止测试'); process.exit(1); }
  const { token, roleID: rid, userID: uid } = loginRes.data;

  // 2. Ammo
  console.log('\n[2] 弹药消耗');
  const bagRes = await apiPost('/api/game/load-generals', { token, roleID: rid, userID: uid });
  const bag = loginRes.data.bagModel;
  const ammo = bag.find(b => (b.code||'').startsWith('proto_2_'));
  if (ammo) {
    const before = ammo.count;
    const res = await apiPost('/api/game/use-ammo', { head: 10013, agent: '4399', ver: '2.1.4', token, roleID: rid, userID: uid, id: ammo.id });
    check('弹药扣减', res.success, 'id=' + ammo.id);
    // Re-login to verify persistence
    const relogin = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
    const afterAmmo = (relogin.data.bagModel||[]).find(b => b.id === ammo.id);
    check('弹药持久化', afterAmmo && afterAmmo.count === before - 1, 'before=' + before + ' after=' + (afterAmmo?afterAmmo.count:'?'));

  // 3. Evolution
  console.log('\n[3] 进化');
  const gens = (await apiPost('/api/game/load-generals', { token: relogin.data.token, roleID: rid, userID: uid })).data.armyModel;
  const evoGen = gens.find(g => (g.evolution||0) < 10);
  if (evoGen) {
    const evoBefore = evoGen.evolution||0;
    const evoRes = await apiPost('/api/general/evolve', { head: 10005, agent: '4399', ver: '2.1.4', token: relogin.data.token, roleID: rid, userID: uid, id: evoGen.id });
    check('进化请求成功', evoRes.success);
    check('进化卷消耗', evoRes.data && evoRes.data.itemID > 0, 'itemID=' + (evoRes.data||{}).itemID);
    if (evoRes.data && evoRes.data.general) {
      check('进化升级', (evoRes.data.general.evolution||0) > evoBefore, 'evo ' + evoBefore + '→' + evoRes.data.general.evolution);
    }
  }

  // 4. Accessory equip
  console.log('\n[4] 饰品装备(slot5)');
  const login2 = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
  const accItem = (login2.data.bagModel||[]).find(b => {
    const c = b.code||''; return c.startsWith('proto_4_') && ['proto_4_50','proto_4_51','proto_4_71','proto_4_76'].includes(c);
  });
  const gen2 = (await apiPost('/api/game/load-generals', { token: login2.data.token, roleID: rid, userID: uid })).data.armyModel[0];
  if (accItem && gen2) {
    const eqRes = await apiPost('/api/general/equip', { head: 10050, agent: '4399', ver: '2.1.4', token: login2.data.token, roleID: rid, userID: uid, id: gen2.id, slot: 5, itemCode: accItem.code });
    check('饰品槽5装备', eqRes.success, eqRes.message || accItem.code);
  }

  // 5. Batch sell
  console.log('\n[5] 批量售卖');
  const login3 = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
  const sellItems = (login3.data.bagModel||[]).filter(b => (b.code||'').startsWith('proto_4_')).slice(0, 5);
  if (sellItems.length > 0) {
    const codes = sellItems.map(b => b.code).join(',');
    const sellRes = await apiPost('/api/general/sell', { head: 10052, agent: '4399', ver: '2.1.4', token: login3.data.token, roleID: rid, userID: uid, itemCodes: codes });
    check('批量售卖成功', sellRes.success && sellRes.data.soldCount > 0, 'sold=' + (sellRes.data||{}).soldCount + ' silver=' + (sellRes.data||{}).totalSilver);
  }

  // 6. Kezhi probability
  console.log('\n[6] 克制进阶概率');
  const login4 = await apiPost('/api/auth/login', { userID: 'gm_admin', password: 'admin123' });
  const gen4 = (await apiPost('/api/game/load-generals', { token: login4.data.token, roleID: rid, userID: uid })).data.armyModel[0];
  if (gen4) {
    let successCount = 0;
    for (let i = 0; i < 5; i++) {
      const kRes = await apiPost('/api/general/kezhi', { head: 10006, agent: '4399', ver: '2.1.4', token: login4.data.token, roleID: rid, userID: uid, id: gen4.id, index: 0 });
      if (kRes.data && kRes.data.general) successCount++;
    }
    check('克制概率生效', successCount < 5, '5次尝试成功' + successCount + '次(概率非100%)');
  }

  } // end if ammo

  console.log('\n═══════════════════════');
  console.log(' 结果: ' + passed + ' passed, ' + failed + ' failed');
  console.log('═══════════════════════');
  process.exit(failed > 0 ? 1 : 0);
})().catch(e => { console.log('Fatal:', e.message); process.exit(1); });
