import fs from 'fs';
import path from 'path';

const DATA_DIR = path.join(__dirname, '..', '..', 'data');

// In-memory data store (persisted to JSON files)
export interface DBData {
  players: any[];
  generals: any[];
  bagItems: any[];
  leitaiRooms: any[];
  battles: any[];
  nextId: {
    players: number;
    generals: number;
    bagItems: number;
    leitaiRooms: number;
    battles: number;
  };
}

let data: DBData = {
  players: [],
  generals: [],
  bagItems: [],
  leitaiRooms: [],
  battles: [],
  nextId: {
    players: 1,
    generals: 1,
    bagItems: 1,
    leitaiRooms: 1,
    battles: 1,
  },
};

// Ensure data directory exists
if (!fs.existsSync(DATA_DIR)) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
}

// Load from disk
const DB_FILE = path.join(DATA_DIR, 'sanguo.json');
if (fs.existsSync(DB_FILE)) {
  try {
    const loaded = JSON.parse(fs.readFileSync(DB_FILE, 'utf-8'));
    data = { ...data, ...loaded };
    console.log(`数据库加载成功: ${data.players.length} 玩家, ${data.generals.length} 武将`);
  } catch (e) {
    console.error('数据库加载失败，使用空数据库:', e);
  }
}

// Persistence
let saveTimer: NodeJS.Timeout | null = null;

function scheduleSave(): void {
  if (saveTimer) return;
  saveTimer = setTimeout(() => {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), 'utf-8');
    saveTimer = null;
  }, 1000); // Debounce: save at most once per second
}

// ============== Query helpers ==============

export function getAll(collection: keyof DBData): any[] {
  if (collection === 'nextId') return [];
  return (data as any)[collection] as any[];
}

export function findOne(collection: string, predicate: (item: any) => boolean): any | undefined {
  const arr = (data as any)[collection];
  if (!arr) return undefined;
  return arr.find(predicate);
}

export function findMany(collection: string, predicate: (item: any) => boolean): any[] {
  const arr = (data as any)[collection];
  if (!arr) return [];
  return arr.filter(predicate);
}

export function insert(collection: string, item: any): any {
  const arr = (data as any)[collection];
  const id = data.nextId[collection as keyof typeof data.nextId] || 1;
  const newItem = { id, ...item };
  arr.push(newItem);
  data.nextId[collection as keyof typeof data.nextId] = id + 1;
  scheduleSave();
  return newItem;
}

export function update(collection: string, id: number, updates: any): void {
  const arr = (data as any)[collection];
  const index = arr.findIndex((item: any) => item.id === id);
  if (index !== -1) {
    arr[index] = { ...arr[index], ...updates };
    scheduleSave();
  }
}

export function updateWhere(collection: string, predicate: (item: any) => boolean, updates: any): void {
  const arr = (data as any)[collection];
  let changed = false;
  for (let i = 0; i < arr.length; i++) {
    if (predicate(arr[i])) {
      arr[i] = { ...arr[i], ...updates };
      changed = true;
    }
  }
  if (changed) scheduleSave();
}

export function remove(collection: string, id: number): void {
  const arr = (data as any)[collection];
  const index = arr.findIndex((item: any) => item.id === id);
  if (index !== -1) {
    arr.splice(index, 1);
    scheduleSave();
  }
}

export function getNextId(collection: string): number {
  return data.nextId[collection as keyof typeof data.nextId] || 1;
}

// Force immediate save (for shutdown)
export function forceSave(): void {
  fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), 'utf-8');
  console.log('数据库已保存');
}

export function initDB(): void {
  console.log(`数据库初始化完成 (JSON 文件模式)`);
}
