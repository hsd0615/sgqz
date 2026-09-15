const fs = require('fs');
const path = require('path');
const { createCanvas, loadImage } = require('canvas');

const ROOT = path.resolve(__dirname, '..');
const PARTS = path.join(ROOT, 'assets', 'parts');
const SCALE = 0.18;
const DISPLAY_SCALE = 1.3;

const definitions = {
  spear: ['warrior_part_10_spear.png', 760, 80, -31, -83],
  rearArm: ['warrior_part_04_rear_arm.png', 42, 38, -19, -91],
  rearLeg: ['warrior_part_06_rear_thigh.png', 82, 22, -11, -42],
  rearBoot: ['warrior_part_08_rear_boot.png', 78, 20, -12, -17],
  torso: ['warrior_part_02_torso.png', 159, 188, 0, -65],
  frontLeg: ['warrior_part_07_front_thigh.png', 92, 22, 10, -42],
  frontBoot: ['warrior_part_09_front_boot.png', 79, 18, 11, -17],
  waist: ['warrior_part_03_waist_skirt.png', 206, 30, 0, -68],
  headRight: ['warrior_part_01_head_right.png', 176, 390, 0, -94],
  headFront: ['warrior_part_11_head_front.png', 198, 418, 0, -94],
  frontArm: ['warrior_part_05_front_arm.png', 38, 34, 18, -91],
};

const order = ['spear', 'rearArm', 'rearLeg', 'rearBoot', 'torso', 'frontLeg', 'frontBoot', 'waist', 'headRight', 'frontArm'];

function basePose() {
  const pose = { body: { x: 0, y: 0, rotation: 0 }, parts: {} };
  for (const [name, value] of Object.entries(definitions)) {
    pose.parts[name] = { x: value[3], y: value[4], rotation: 0 };
  }
  return pose;
}

function poseFor(name) {
  const p = basePose();
  if (name === 'walk') {
    const stride = 1;
    p.body.y = -2;
    p.parts.torso.rotation = -2;
    p.parts.headRight.rotation = 2;
    p.parts.rearLeg.rotation = 18 * stride;
    p.parts.frontLeg.rotation = -18 * stride;
    p.parts.rearBoot.rotation = -8 * stride;
    p.parts.frontBoot.rotation = 8 * stride;
    p.parts.rearArm.rotation = -10 * stride;
    p.parts.frontArm.rotation = 8 * stride;
    p.parts.spear.y = -84;
    p.parts.spear.rotation = -2;
  } else if (name === 'attack') {
    p.body.x = 9;
    p.body.y = -2;
    p.parts.torso.rotation = 7;
    p.parts.headRight.rotation = -3;
    p.parts.spear.x = 13;
    p.parts.spear.rotation = 1;
    p.parts.rearArm.rotation = 6;
    p.parts.frontArm.rotation = 5;
    p.parts.rearLeg.rotation = -8;
    p.parts.frontLeg.rotation = 12;
  } else if (name === 'dead') {
    p.body.x = -8;
    p.body.y = 27;
    p.body.rotation = -68;
    p.parts.torso.rotation = 10;
    p.parts.waist.rotation = -7;
    p.parts.headFront.x = 5;
    p.parts.headFront.y = -81;
    p.parts.headFront.rotation = 28;
    p.parts.spear.x = -1;
    p.parts.spear.y = -41;
    p.parts.spear.rotation = 78;
    p.parts.rearArm.rotation = -55;
    p.parts.frontArm.rotation = 42;
    p.parts.rearLeg.rotation = 28;
    p.parts.frontLeg.rotation = -34;
    p.parts.rearBoot.rotation = -25;
    p.parts.frontBoot.rotation = 20;
  }
  return p;
}

async function main() {
  const images = {};
  for (const [name, value] of Object.entries(definitions)) {
    images[name] = await loadImage(fs.readFileSync(path.join(PARTS, value[0])));
  }

  const canvas = createCanvas(1200, 380);
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = '#20252b';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  const states = ['stand', 'walk', 'attack', 'dead'];
  states.forEach((state, index) => {
    const pose = poseFor(state);
    ctx.save();
    ctx.translate(150 + index * 300, 275);
    ctx.scale(DISPLAY_SCALE, DISPLAY_SCALE);
    ctx.strokeStyle = 'rgba(255,255,255,0.25)';
    ctx.beginPath();
    ctx.moveTo(-115, 0);
    ctx.lineTo(115, 0);
    ctx.stroke();
    ctx.translate(pose.body.x, pose.body.y);
    ctx.rotate(pose.body.rotation * Math.PI / 180);

    const renderOrder = state === 'dead'
      ? order.map(n => n === 'headRight' ? 'headFront' : n)
      : order;
    for (const partName of renderOrder) {
      const def = definitions[partName];
      const part = pose.parts[partName];
      ctx.save();
      ctx.translate(part.x, part.y);
      ctx.rotate(part.rotation * Math.PI / 180);
      ctx.drawImage(images[partName], -def[1] * SCALE, -def[2] * SCALE, images[partName].width * SCALE, images[partName].height * SCALE);
      ctx.restore();
    }
    ctx.restore();

    ctx.fillStyle = '#ffffff';
    ctx.font = '20px sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(state, 150 + index * 300, 345);
  });

  const output = path.join(ROOT, 'preview_part_soldier.png');
  fs.writeFileSync(output, canvas.toBuffer('image/png'));
  console.log(output);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
