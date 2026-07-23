const fs = require('fs');
const path = require('path');
const { createCanvas, loadImage } = require('canvas');

const ROOT = path.resolve(__dirname, '..');
const SOURCE_DIR = path.join(ROOT, 'assets', 'parts');
const OUTPUT_DIR = path.join(SOURCE_DIR, 'longspear');
const TIMELINE_PATH = path.join(SOURCE_DIR, 'longspear_timeline.json');
const CELL_WIDTH = 256;
const CELL_HEIGHT = 160;
const COLUMNS = 13;
const ORIGIN_X = 128;
const ORIGIN_Y = 130;

// Original generalSkin_7_0 local bounds, converted from SWF twips to pixels.
const bounds = {
  524: [-2301 / 20, -1337 / 20, -675 / 20, -923 / 20],
  526: [456 / 20, -1936 / 20, 2262 / 20, -1343 / 20],
  531: [-82 / 20, -208 / 20, 357 / 20, 389 / 20],
  532: [-391 / 20, -157 / 20, -61 / 20, 373 / 20],
  533: [-345 / 20, -5 / 20, 71 / 20, 585 / 20],
  534: [-45 / 20, -5 / 20, 391 / 20, 581 / 20],
  535: [-365 / 20, -275 / 20, 779 / 20, 843 / 20],
  536: [-5 / 20, -5 / 20, 738 / 20, 358 / 20],
  537: [-5 / 20, -5 / 20, 779 / 20, 377 / 20],
  538: [-5 / 20, -5 / 20, 2488 / 20, 2389 / 20],
  539: [-210 / 20, -185 / 20, 826 / 20, 644 / 20],
  541: [-7 / 20, -1114 / 20, 856 / 20, 1820 / 20],
  542: [94 / 20, -772 / 20, 112 / 20, -734 / 20],
  543: [292 / 20, 828 / 20, 945 / 20, 1398 / 20],
};

const sourceFiles = {
  531: 'warrior_part_04_rear_arm.png',
  532: 'warrior_part_05_front_arm.png',
  533: 'warrior_part_06_rear_thigh.png',
  534: 'warrior_part_07_front_thigh.png',
  536: 'warrior_part_08_rear_boot.png',
  537: 'warrior_part_09_front_boot.png',
  538: 'warrior_part_11_head_front.png',
};

function cropAlpha(source) {
  const sourceCanvas = createCanvas(source.width, source.height);
  const sourceContext = sourceCanvas.getContext('2d');
  sourceContext.drawImage(source, 0, 0);
  const pixels = sourceContext.getImageData(0, 0, source.width, source.height).data;
  let minX = source.width;
  let minY = source.height;
  let maxX = -1;
  let maxY = -1;
  for (let y = 0; y < source.height; y++) {
    for (let x = 0; x < source.width; x++) {
      if (pixels[(y * source.width + x) * 4 + 3] > 8) {
        minX = Math.min(minX, x);
        minY = Math.min(minY, y);
        maxX = Math.max(maxX, x);
        maxY = Math.max(maxY, y);
      }
    }
  }
  const width = Math.max(1, maxX - minX + 1);
  const height = Math.max(1, maxY - minY + 1);
  const result = createCanvas(width, height);
  result.getContext('2d').drawImage(sourceCanvas, minX, minY, width, height, 0, 0, width, height);
  return result;
}

function combineBody(torso, waist) {
  const canvas = createCanvas(430, 360);
  const context = canvas.getContext('2d');
  context.drawImage(torso, (430 - torso.width) / 2, 0);
  context.drawImage(waist, (430 - waist.width) / 2, 145);
  return cropAlpha(canvas);
}

function rotateSpear(spear) {
  const canvas = createCanvas(spear.height, spear.width);
  const context = canvas.getContext('2d');
  context.translate(0, spear.width);
  context.rotate(-Math.PI / 2);
  context.drawImage(spear, 0, 0);
  return cropAlpha(canvas);
}

async function loadPng(filePath) {
  return loadImage(fs.readFileSync(filePath));
}

async function main() {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  const timeline = JSON.parse(fs.readFileSync(TIMELINE_PATH, 'utf8'));
  if (timeline.frameCount !== 65) {
    throw new Error(`Expected 65 long-spear frames, got ${timeline.frameCount}`);
  }

  const parts = {};
  for (const [characterId, fileName] of Object.entries(sourceFiles)) {
    parts[characterId] = cropAlpha(await loadPng(path.join(SOURCE_DIR, fileName)));
  }
  const torso = cropAlpha(await loadPng(path.join(SOURCE_DIR, 'warrior_part_02_torso.png')));
  const waist = cropAlpha(await loadPng(path.join(SOURCE_DIR, 'warrior_part_03_waist_skirt.png')));
  parts[535] = combineBody(torso, waist);
  parts[541] = rotateSpear(cropAlpha(await loadPng(path.join(SOURCE_DIR, 'warrior_part_10_spear.png'))));

  // Keep the original long-spear slash/death accents. They are timeline effects,
  // not body parts, and therefore remain at their authored depths.
  for (const characterId of [524, 526, 543]) {
    const storedEffectPath = path.join(OUTPUT_DIR, `effect_${characterId}.png`);
    const extractedEffectPath = path.join(ROOT, 'cocos-client', 'assets', 'resources', 'general', 'shapes', `${characterId}.png`);
    const effectPath = fs.existsSync(storedEffectPath) ? storedEffectPath : extractedEffectPath;
    parts[characterId] = cropAlpha(await loadPng(effectPath));
    if (!fs.existsSync(storedEffectPath)) {
      fs.writeFileSync(storedEffectPath,parts[characterId].toBuffer('image/png'));
    }
  }

  const partNames = {
    531: 'rear_arm', 532: 'front_arm', 533: 'rear_leg', 534: 'front_leg',
    535: 'body', 536: 'rear_foot', 537: 'front_foot', 538: 'head', 541: 'spear',
  };
  for (const [characterId, name] of Object.entries(partNames)) {
    fs.writeFileSync(path.join(OUTPUT_DIR, `${name}.png`), parts[characterId].toBuffer('image/png'));
  }

  const rows = Math.ceil(timeline.frameCount / COLUMNS);
  const atlas = createCanvas(COLUMNS * CELL_WIDTH, rows * CELL_HEIGHT);
  const context = atlas.getContext('2d');
  context.imageSmoothingEnabled = true;

  for (const frame of timeline.frames) {
    const cellX = ((frame.index - 1) % COLUMNS) * CELL_WIDTH;
    const cellY = Math.floor((frame.index - 1) / COLUMNS) * CELL_HEIGHT;
    context.save();
    context.beginPath();
    context.rect(cellX,cellY,CELL_WIDTH,CELL_HEIGHT);
    context.clip();
    context.translate(cellX + ORIGIN_X, cellY + ORIGIN_Y);
    for (const item of frame.items.sort((left, right) => left.depth - right.depth)) {
      const image = parts[item.characterId];
      const partBounds = bounds[item.characterId];
      // Head artwork already contains the eyes; _hurtPoint and empty markers do
      // not render into the atlas.
      if (!image || !partBounds || item.characterId === 539) continue;
      const matrix = item.matrix;
      context.save();
      context.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      context.drawImage(
        image,
        partBounds[0],
        partBounds[1],
        partBounds[2] - partBounds[0],
        partBounds[3] - partBounds[1]
      );
      context.restore();
    }
    context.restore();
  }

  const atlasPath = path.join(OUTPUT_DIR, 'longspear_atlas.png');
  fs.writeFileSync(atlasPath, atlas.toBuffer('image/png'));
  fs.writeFileSync(path.join(OUTPUT_DIR, 'atlas.json'), JSON.stringify({
    frameCount: timeline.frameCount,
    cellWidth: CELL_WIDTH,
    cellHeight: CELL_HEIGHT,
    columns: COLUMNS,
    originX: ORIGIN_X,
    originY: ORIGIN_Y,
    labels: { stand: 1, moveBegin: 3, moveEnd: 12, attackBegin: 13, attackEnd: 17, deadBegin: 31, deadEnd: 65 },
  }, null, 2));
  console.log(atlasPath);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
