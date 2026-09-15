/**
 * SVG矢量生成倭寇模型 → 转高清PNG
 * 模拟三国游戏2.5D美术风格
 */
const fs=require('fs'),path=require('path');
const {createCanvas,loadImage}=require('canvas');
const OUT=path.join(require('os').homedir(),'Desktop');

const S=`
<svg xmlns="http://www.w3.org/2000/svg" width="120" height="140" viewBox="0 0 120 140">
  <defs>
    <linearGradient id="hat" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#6B4A2A"/><stop offset="100%" stop-color="#3A1E0A"/></linearGradient>
    <linearGradient id="cloth" x1="0" y1="0" x2="1" y2="0"><stop offset="0%" stop-color="#1A2540"/><stop offset="50%" stop-color="#1E3A5A"/><stop offset="100%" stop-color="#1A2540"/></linearGradient>
    <linearGradient id="blade" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#E8E8E8"/><stop offset="40%" stop-color="#CCCCCC"/><stop offset="100%" stop-color="#888888"/></linearGradient>
    <linearGradient id="skin" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#F5D5A0"/><stop offset="100%" stop-color="#D4A870"/></linearGradient>
  </defs>
  <!-- Shadow -->
  <ellipse cx="60" cy="128" rx="35" ry="6" fill="rgba(0,0,0,0.25)"/>
  <!-- Straw Hat -->
  <path d="M35,28 L85,28 L78,48 L42,48 Z" fill="url(#hat)" stroke="#2A1004" stroke-width="1.5"/>
  <path d="M38,30 L82,30 L76,46 L44,46 Z" fill="#4A2E14"/>
  <line x1="45" y1="32" x2="50" y2="44" stroke="#3A1E0A" stroke-width="0.5"/>
  <line x1="55" y1="32" x2="55" y2="44" stroke="#3A1E0A" stroke-width="0.5"/>
  <line x1="65" y1="32" x2="60" y2="44" stroke="#3A1E0A" stroke-width="0.5"/>
  <line x1="75" y1="32" x2="70" y2="44" stroke="#3A1E0A" stroke-width="0.5"/>
  <path d="M42,34 Q38,42 35,48" stroke="#9B7530" stroke-width="1" fill="none"/>
  <path d="M78,34 Q82,42 85,48" stroke="#9B7530" stroke-width="1" fill="none"/>
  <!-- Head -->
  <circle cx="60" cy="58" r="12" fill="url(#skin)" stroke="#C4A060" stroke-width="1"/>
  <circle cx="56" cy="56" r="1.5" fill="#1A1A1A"/>
  <circle cx="64" cy="56" r="1.5" fill="#1A1A1A"/>
  <path d="M56,62 Q60,66 64,62" stroke="#A08060" stroke-width="1" fill="none"/>
  <!-- Neck -->
  <rect x="55" y="68" width="10" height="6" fill="#E5B878"/>
  <!-- Body (dark blue cloth) -->
  <rect x="44" y="74" width="32" height="40" rx="4" fill="url(#cloth)" stroke="#0A1820" stroke-width="1"/>
  <line x1="52" y1="77" x2="52" y2="110" stroke="#2A3A5A" stroke-width="0.4"/>
  <line x1="60" y1="77" x2="60" y2="110" stroke="#2A3A5A" stroke-width="0.4"/>
  <line x1="68" y1="77" x2="68" y2="110" stroke="#2A3A5A" stroke-width="0.4"/>
  <!-- Cloth fold lines -->
  <path d="M46,90 Q60,94 74,90" stroke="#2A3A5A" stroke-width="0.5" fill="none"/>
  <!-- Belt -->
  <rect x="44" y="108" width="32" height="6" fill="#8B6914" stroke="#6B4A0A" stroke-width="1"/>
  <rect x="57" y="108" width="6" height="6" fill="#6B4A0A"/>
  <!-- Left Arm -->
  <rect x="30" y="77" width="14" height="28" rx="3" fill="url(#cloth)" stroke="#0A1820" stroke-width="0.8"/>
  <circle cx="37" cy="108" r="5" fill="url(#skin)" stroke="#C4A060" stroke-width="0.5"/>
  <!-- Right Arm (holding weapon) -->
  <rect x="76" y="77" width="14" height="28" rx="3" fill="url(#cloth)" stroke="#0A1820" stroke-width="0.8"/>
  <circle cx="83" cy="108" r="5" fill="url(#skin)" stroke="#C4A060" stroke-width="0.5"/>
  <!-- Katana -->
  <rect x="90" y="82" width="4" height="38" rx="1" fill="url(#blade)" stroke="#777" stroke-width="0.8"/>
  <rect x="89" y="80" width="6" height="6" rx="1" fill="#8B6914"/>
  <!-- Legs -->
  <rect x="50" y="116" width="9" height="18" rx="2" fill="#181A28" stroke="#0A0810" stroke-width="0.8"/>
  <rect x="61" y="116" width="9" height="18" rx="2" fill="#181A28" stroke="#0A0810" stroke-width="0.8"/>
  <!-- Sandals -->
  <rect x="48" y="130" width="13" height="5" rx="2" fill="#5A4A2A"/>
  <rect x="59" y="130" width="13" height="5" rx="2" fill="#5A4A2A"/>
  <line x1="52" y1="132" x2="56" y2="132" stroke="#4A3A1A" stroke-width="0.5"/>
  <line x1="62" y1="132" x2="66" y2="132" stroke="#4A3A1A" stroke-width="0.5"/>
  <!-- Red headband tail -->
  <path d="M42,30 Q30,25 28,18" stroke="#CC3333" stroke-width="2" fill="none" stroke-linecap="round"/>
</svg>`;

const B=`
<svg xmlns="http://www.w3.org/2000/svg" width="140" height="170" viewBox="0 0 140 170">
  <defs>
    <linearGradient id="gold" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#FFD700"/><stop offset="50%" stop-color="#DAA520"/><stop offset="100%" stop-color="#8B6508"/></linearGradient>
    <linearGradient id="red" x1="0" y1="0" x2="1" y2="0"><stop offset="0%" stop-color="#5A0A15"/><stop offset="40%" stop-color="#8B1520"/><stop offset="60%" stop-color="#8B1520"/><stop offset="100%" stop-color="#5A0A15"/></linearGradient>
    <linearGradient id="blade2" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#F0F0F0"/><stop offset="30%" stop-color="#DDD"/><stop offset="100%" stop-color="#888"/></linearGradient>
    <linearGradient id="face" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#F0C090"/><stop offset="100%" stop-color="#C89860"/></linearGradient>
  </defs>
  <!-- Shadow -->
  <ellipse cx="70" cy="158" rx="45" ry="8" fill="rgba(0,0,0,0.3)"/>
  <!-- Back Banner -->
  <rect x="64" y="10" width="12" height="45" rx="2" fill="#8B1520" stroke="#5A0A10" stroke-width="1"/>
  <line x1="66" y1="16" x2="74" y2="16" stroke="#DAA520" stroke-width="0.8"/>
  <line x1="66" y1="24" x2="74" y2="24" stroke="#DAA520" stroke-width="0.8"/>
  <line x1="66" y1="32" x2="74" y2="32" stroke="#DAA520" stroke-width="0.8"/>
  <!-- Gold Kabuto -->
  <rect x="38" y="30" width="64" height="22" rx="8" fill="url(#gold)" stroke="#6B4A0A" stroke-width="1.5"/>
  <polygon points="70,20 80,30 60,30" fill="#FFD700" stroke="#DAA520" stroke-width="0.8"/>
  <!-- Face -->
  <circle cx="70" cy="62" r="14" fill="url(#face)" stroke="#A87040" stroke-width="1"/>
  <circle cx="64" cy="60" r="2" fill="#111"/>
  <circle cx="76" cy="60" r="2" fill="#111"/>
  <path d="M62,68 Q66,74 70,68 Q74,74 78,68" stroke="#A87040" stroke-width="1" fill="none"/>
  <!-- Mustache/beard -->
  <path d="M58,66 Q54,74 50,78" stroke="#3A2A10" stroke-width="1.5" fill="none"/>
  <path d="M82,66 Q86,74 90,78" stroke="#3A2A10" stroke-width="1.5" fill="none"/>
  <path d="M65,68 Q70,74 75,68" stroke="#3A2A10" stroke-width="1" fill="none"/>
  <!-- Jinbaori Cape -->
  <path d="M42,78 Q24,100 18,118 Q28,112 34,96 Z" fill="rgba(139,21,32,0.65)"/>
  <path d="M98,78 Q116,100 122,118 Q112,112 106,96 Z" fill="rgba(139,21,32,0.65)"/>
  <!-- Neck -->
  <rect x="64" y="74" width="12" height="6" fill="#D8A868"/>
  <!-- Red Armor Body -->
  <rect x="48" y="80" width="44" height="50" rx="6" fill="url(#red)" stroke="#3A0508" stroke-width="1.2"/>
  <line x1="52" y1="90" x2="88" y2="90" stroke="#DAA520" stroke-width="0.6"/>
  <line x1="52" y1="100" x2="88" y2="100" stroke="#DAA520" stroke-width="0.6"/>
  <line x1="52" y1="110" x2="88" y2="110" stroke="#DAA520" stroke-width="0.6"/>
  <line x1="52" y1="120" x2="88" y2="120" stroke="#DAA520" stroke-width="0.6"/>
  <!-- Gold Belt -->
  <rect x="48" y="126" width="44" height="8" rx="2" fill="url(#gold)" stroke="#6B4A0A" stroke-width="1"/>
  <circle cx="70" cy="130" r="5" fill="#FFD700" stroke="#DAA520" stroke-width="1"/>
  <!-- Left Arm -->
  <rect x="28" y="84" width="18" height="34" rx="4" fill="url(#red)" stroke="#3A0508" stroke-width="1"/>
  <circle cx="37" cy="120" r="6" fill="url(#face)" stroke="#A87040" stroke-width="0.8"/>
  <!-- Right Arm -->
  <rect x="94" y="84" width="18" height="34" rx="4" fill="url(#red)" stroke="#3A0508" stroke-width="1"/>
  <circle cx="103" cy="120" r="6" fill="url(#face)" stroke="#A87040" stroke-width="0.8"/>
  <!-- Odachi -->
  <rect x="112" y="92" width="5" height="50" rx="2" fill="url(#blade2)" stroke="#777" stroke-width="1"/>
  <rect x="110" y="90" width="9" height="8" rx="2" fill="url(#gold)"/>
  <!-- Legs -->
  <rect x="54" y="136" width="12" height="20" rx="3" fill="#2A1A10" stroke="#150A05" stroke-width="0.8"/>
  <rect x="74" y="136" width="12" height="20" rx="3" fill="#2A1A10" stroke="#150A05" stroke-width="0.8"/>
  <!-- Boots -->
  <rect x="52" y="152" width="14" height="7" rx="3" fill="#3A2515"/>
  <rect x="72" y="152" width="14" height="7" rx="3" fill="#3A2515"/>
  <line x1="56" y1="155" x2="62" y2="155" stroke="#DAA520" stroke-width="0.5"/>
  <line x1="76" y1="155" x2="82" y2="155" stroke="#DAA520" stroke-width="0.5"/>
</svg>`;

async function svgToPng(svg,outFile,w,h){
  const c=createCanvas(w,h);
  const ctx=c.getContext('2d');
  // Convert SVG to data URL
  const b64=Buffer.from(svg).toString('base64');
  const dataUrl='data:image/svg+xml;base64,'+b64;
  const img=await loadImage(dataUrl);
  ctx.drawImage(img,0,0,w,h);
  fs.writeFileSync(outFile,c.toBuffer('image/png'));
  console.log(path.basename(outFile),'created',fs.statSync(outFile).size,'bytes');
}

async function main(){
  await svgToPng(S,path.join(OUT,'wokou_soldier_svg.png'),120,140);
  await svgToPng(B,path.join(OUT,'wokou_boss_svg.png'),140,170);
  console.log('Done. Open wokou_preview.html to view.');
}
main().catch(e=>console.error(e));
