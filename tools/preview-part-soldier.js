const fs = require('fs');
const path = require('path');
const { createCanvas, loadImage } = require('canvas');

const ROOT = path.resolve(__dirname, '..');
const PART_DIR = path.join(ROOT, 'assets', 'parts', 'longspear');

async function main() {
  const metadata = JSON.parse(fs.readFileSync(path.join(PART_DIR, 'atlas.json'), 'utf8'));
  const atlas = await loadImage(fs.readFileSync(path.join(PART_DIR, 'longspear_atlas.png')));
  const samples = [
    ['stand', metadata.labels.stand],
    ['move', 7],
    ['attack wind-up', metadata.labels.attackBegin],
    ['attack hit', metadata.labels.attackEnd],
    ['death', 44],
    ['death end', metadata.labels.deadEnd],
  ];
  const scale = 1.45;
  const panelWidth = 260;
  const panelHeight = 250;
  const canvas = createCanvas(samples.length * panelWidth, panelHeight);
  const context = canvas.getContext('2d');
  context.fillStyle = '#20252b';
  context.fillRect(0, 0, canvas.width, canvas.height);

  for (let index = 0; index < samples.length; index++) {
    const [label, frame] = samples[index];
    const frameIndex = frame - 1;
    const sourceX = frameIndex % metadata.columns * metadata.cellWidth;
    const sourceY = Math.floor(frameIndex / metadata.columns) * metadata.cellHeight;
    const drawWidth = metadata.cellWidth * scale;
    const drawHeight = metadata.cellHeight * scale;
    const drawX = index * panelWidth + (panelWidth - drawWidth) / 2;
    const drawY = 0;
    context.drawImage(
      atlas,
      sourceX,
      sourceY,
      metadata.cellWidth,
      metadata.cellHeight,
      drawX,
      drawY,
      drawWidth,
      drawHeight
    );
    context.fillStyle = '#ffffff';
    context.font = '16px sans-serif';
    context.textAlign = 'center';
    context.fillText(`${label} (f${frame})`,index * panelWidth + panelWidth / 2,235);
  }

  const output = path.join(ROOT, 'preview_part_soldier.png');
  fs.writeFileSync(output,canvas.toBuffer('image/png'));
  console.log(output);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
