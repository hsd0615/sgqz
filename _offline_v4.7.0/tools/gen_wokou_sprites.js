/**
 * 生成倭寇精兵和头领的高品质像素风精灵图
 * 使用 canvas 模拟三国游戏的半写实风格
 */
const { createCanvas } = require('canvas');
const fs = require('fs');
const path = require('path');

const OUT = path.join(require('os').homedir(), 'Desktop');

function shadow(g, x, y, w, h, c, a) {
  g.save(); g.fillStyle = c || 'rgba(0,0,0,0.3)'; g.globalAlpha = a || 0.3;
  g.fillRect(x, y, w, h); g.restore();
}

function armorPlate(g, x, y, w, h, base, light, dark) {
  g.fillStyle = base; g.fillRect(x, y, w, h);
  g.fillStyle = light; g.fillRect(x+1, y+1, w-2, 1);
  g.strokeStyle = dark; g.lineWidth = 0.5; g.strokeRect(x, y, w, h);
}

function roundArmor(g, x, y, w, h, r, base, light, dark) {
  g.fillStyle = base; g.beginPath(); g.roundRect(x, y, w, h, r); g.fill();
  g.fillStyle = light; g.beginPath(); g.roundRect(x+1, y+1, w-4, h-5, r-1); g.fill();
  g.strokeStyle = dark; g.lineWidth = 0.5; g.beginPath(); g.roundRect(x, y, w, h, r); g.stroke();
}

function drawSoldier() {
  const c = createCanvas(80, 100);
  const g = c.getContext('2d');
  g.translate(40, 8);

  // Shadow
  shadow(g, -18, 75, 36, 6);

  // === 斗笠 ===
  const hatY = -12;
  g.fillStyle = '#5C3A1E'; g.beginPath(); g.moveTo(-16, hatY); g.lineTo(16, hatY);
  g.lineTo(12, hatY+12); g.lineTo(-12, hatY+12); g.closePath(); g.fill();
  g.fillStyle = '#4A2E14'; g.beginPath(); g.moveTo(-13, hatY+2); g.lineTo(13, hatY+2);
  g.lineTo(10, hatY+10); g.lineTo(-10, hatY+10); g.fill();
  // Hat weave lines
  g.strokeStyle = '#3A1E0A'; g.lineWidth = 0.5;
  for (let i = 0; i < 5; i++) { g.beginPath(); g.moveTo(-10 + i*3, hatY+2); g.lineTo(-6 + i*2, hatY+10); g.stroke(); }
  // Hat string
  g.strokeStyle = '#9B7530'; g.lineWidth = 1; g.beginPath(); g.moveTo(-8, hatY+4); g.lineTo(-12, hatY+16); g.stroke();
  g.moveTo(8, hatY+4); g.lineTo(12, hatY+16);

  // === Head ===
  g.fillStyle = '#E8C8A0'; g.beginPath(); g.arc(0, 6, 8, 0, Math.PI * 2); g.fill();
  g.fillStyle = '#222'; g.beginPath(); g.arc(-3, 5, 1.2, 0, Math.PI*2); g.fill();
  g.arc(3, 5, 1.2, 0, Math.PI*2); g.fill();
  g.strokeStyle = '#A08060'; g.lineWidth = 0.8;
  g.beginPath(); g.moveTo(-2, 11); g.lineTo(0, 13); g.lineTo(2, 11); g.stroke();

  // === Neck ===
  g.fillStyle = '#D8B080'; g.fillRect(-3, 13, 6, 4);

  // === Body (dark blue cloth) ===
  g.fillStyle = '#1C3254'; g.beginPath(); g.roundRect(-10, 17, 20, 26, 3); g.fill();
  g.fillStyle = '#1E385C'; g.beginPath(); g.roundRect(-8, 17, 16, 22, 2); g.fill();
  g.strokeStyle = '#2A4A6E'; g.lineWidth = 0.3;
  g.beginPath(); g.moveTo(-3, 19); g.lineTo(-3, 39); g.moveTo(3, 19); g.lineTo(3, 39); g.stroke();
  g.strokeStyle = '#4A2A0A'; g.lineWidth = 0.5; g.beginPath(); g.moveTo(-10, 27); g.lineTo(10, 27); g.stroke();

  // === Belt ===
  g.fillStyle = '#8B6914'; g.fillRect(-10, 40, 20, 5);
  g.fillStyle = '#6B4A0A'; g.fillRect(-3, 40, 6, 5);

  // === Left Arm ===
  g.fillStyle = '#1C3254'; g.beginPath(); g.roundRect(-18, 19, 9, 18, 2); g.fill();
  g.fillStyle = '#D8B080'; g.beginPath(); g.arc(-13, 40, 3.5, 0, Math.PI*2); g.fill();

  // === Right Arm (holding katana) ===
  g.fillStyle = '#1C3254'; g.beginPath(); g.roundRect(9, 19, 9, 18, 2); g.fill();
  g.fillStyle = '#D8B080'; g.beginPath(); g.arc(14, 40, 3.5, 0, Math.PI*2); g.fill();

  // === Katana ===
  g.fillStyle = '#888'; g.fillRect(16, 22, 3, 24);
  g.fillStyle = '#CCC'; g.fillRect(17, 22, 1, 24);
  g.fillStyle = '#6B4A0A'; g.fillRect(15, 22, 5, 4);
  g.strokeStyle = '#DDD'; g.lineWidth = 0.5; g.beginPath(); g.moveTo(17, 23); g.lineTo(17, 43); g.stroke();

  // === Legs ===
  g.fillStyle = '#182230'; g.beginPath(); g.roundRect(-7, 44, 7, 15, 2); g.fill();
  g.beginPath(); g.roundRect(0, 44, 7, 15, 2); g.fill();

  // === Straw sandals ===
  g.fillStyle = '#6B5A3A'; g.beginPath(); g.roundRect(-8, 58, 9, 4, 2); g.fill();
  g.beginPath(); g.roundRect(-1, 58, 9, 4, 2); g.fill();

  // === Red headband ===
  g.strokeStyle = '#CC3333'; g.lineWidth = 2; g.beginPath(); g.moveTo(-10, -10); g.lineTo(-16, -8); g.stroke();

  return c;
}

function drawBoss() {
  const c = createCanvas(100, 120);
  const g = c.getContext('2d');
  g.translate(50, 5);

  // Shadow
  shadow(g, -22, 100, 44, 8);

  // === Back flag (指物) ===
  g.fillStyle = '#8B1520'; g.fillRect(-3, -40, 8, 30);
  g.strokeStyle = '#DAA520'; g.lineWidth = 0.8;
  g.beginPath(); g.moveTo(-1, -36); g.lineTo(6, -36); g.stroke();
  g.beginPath(); g.moveTo(-1, -30); g.lineTo(6, -30); g.stroke();

  // === Gold Kabuto Helmet ===
  g.fillStyle = '#8B6508'; g.beginPath(); g.roundRect(-15, -18, 30, 18, 6); g.fill();
  g.fillStyle = '#DAA520'; g.beginPath(); g.roundRect(-13, -16, 26, 14, 5); g.fill();
  g.strokeStyle = '#FFD700'; g.lineWidth = 1.2; g.beginPath(); g.roundRect(-13, -16, 26, 14, 5); g.stroke();
  // Front crest
  g.fillStyle = '#FFD700'; g.beginPath(); g.moveTo(0, -24); g.lineTo(6, -16); g.lineTo(-6, -16); g.fill();
  g.strokeStyle = '#6B4A0A'; g.lineWidth = 0.5;
  g.beginPath(); g.moveTo(-9, -12); g.lineTo(-12, -2); g.moveTo(9, -12); g.lineTo(12, -2); g.stroke();

  // === Face ===
  g.fillStyle = '#DDB088'; g.beginPath(); g.arc(0, 4, 10, 0, Math.PI*2); g.fill();
  g.fillStyle = '#111'; g.beginPath(); g.arc(-4, 2, 1.8, 0, Math.PI*2); g.fill();
  g.arc(4, 2, 1.8, 0, Math.PI*2); g.fill();
  g.strokeStyle = '#3A2510'; g.lineWidth = 0.8;
  g.beginPath(); g.moveTo(-6, 8); g.lineTo(-10, 14); g.moveTo(6, 8); g.lineTo(10, 14); g.stroke();
  g.beginPath(); g.moveTo(-3, 9); g.lineTo(3, 9); g.lineTo(0, 12); g.stroke();

  // === Neck ===
  g.fillStyle = '#C8A078'; g.fillRect(-4, 13, 8, 4);

  // === Red Armor ===
  roundArmor(g, -14, 17, 28, 36, 4, '#6A1020', '#7A1525', '#DAA520');
  g.strokeStyle = '#DAA520'; g.lineWidth = 0.4;
  for (let i = 0; i < 5; i++) { g.beginPath(); g.moveTo(-12, 22 + i*6); g.lineTo(12, 22 + i*6); g.stroke(); }

  // === Gold Belt ===
  g.fillStyle = '#DAA520'; g.fillRect(-14, 50, 28, 6);
  g.fillStyle = '#FFD700'; g.beginPath(); g.arc(0, 53, 4, 0, Math.PI*2); g.fill();

  // === Jinbaori (shoulder cape) ===
  g.fillStyle = 'rgba(139, 21, 32, 0.7)';
  g.beginPath(); g.moveTo(-14, 19); g.lineTo(-32, 36); g.lineTo(-26, 48); g.lineTo(-16, 30); g.fill();
  g.beginPath(); g.moveTo(14, 19); g.lineTo(32, 36); g.lineTo(26, 48); g.lineTo(16, 30); g.fill();

  // === Arms ===
  roundArmor(g, -24, 19, 11, 24, 3, '#6A1020', '#7A1525', '#4A0A10');
  roundArmor(g, 13, 19, 11, 24, 3, '#6A1020', '#7A1525', '#4A0A10');
  g.fillStyle = '#DDB088'; g.beginPath(); g.arc(-18, 46, 4, 0, Math.PI*2); g.fill();
  g.arc(18, 46, 4, 0, Math.PI*2); g.fill();

  // === Odachi (great sword) ===
  g.fillStyle = '#777'; g.fillRect(20, 26, 4, 32);
  g.fillStyle = '#CCC'; g.fillRect(21, 26, 1.5, 32);
  g.fillStyle = '#8B6508'; g.fillRect(18, 26, 7, 5);
  g.strokeStyle = '#EEE'; g.lineWidth = 0.5; g.beginPath(); g.moveTo(21.5, 27); g.lineTo(21.5, 55); g.stroke();

  // === Legs ===
  g.fillStyle = '#2A1A10'; g.beginPath(); g.roundRect(-8, 55, 8, 18, 2); g.fill();
  g.beginPath(); g.roundRect(0, 55, 8, 18, 2); g.fill();

  // === Boots ===
  g.fillStyle = '#4A3020'; g.beginPath(); g.roundRect(-9, 72, 10, 5, 2); g.fill();
  g.beginPath(); g.roundRect(-1, 72, 10, 5, 2); g.fill();
  g.strokeStyle = '#DAA520'; g.lineWidth = 0.5;
  g.beginPath(); g.moveTo(-6, 74); g.lineTo(-2, 74); g.moveTo(2, 74); g.lineTo(6, 74); g.stroke();

  return c;
}

function main() {
  const soldier = drawSoldier();
  const boss = drawBoss();

  fs.writeFileSync(path.join(OUT, 'wokou_soldier.png'), soldier.toBuffer('image/png'));
  fs.writeFileSync(path.join(OUT, 'wokou_boss.png'), boss.toBuffer('image/png'));

  // Also create a simple HTML preview
  const html = `<!DOCTYPE html><html><head><meta charset="UTF-8"><title>倭寇模型</title>
<style>body{background:#2a1a0c;text-align:center;padding:20px;color:#d4a840;font-family:SimHei}
img{margin:10px;border:2px solid #5a3a14;image-rendering:pixelated}
.c{display:inline-block;margin:0 30px}</style></head><body>
<h1>倭寇精兵 80x100</h1><img src="wokou_soldier.png">
<h1>倭寇头领 100x120</h1><img src="wokou_boss.png">
</body></html>`;
  fs.writeFileSync(path.join(OUT, 'wokou_preview.html'), html);

  console.log('Generated:');
  console.log('  ' + path.join(OUT, 'wokou_soldier.png'));
  console.log('  ' + path.join(OUT, 'wokou_boss.png'));
  console.log('  ' + path.join(OUT, 'wokou_preview.html'));
}

main();
