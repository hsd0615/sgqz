"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAll = getAll;
exports.findOne = findOne;
exports.findMany = findMany;
exports.insert = insert;
exports.update = update;
exports.updateWhere = updateWhere;
exports.remove = remove;
exports.getNextId = getNextId;
exports.forceSave = forceSave;
exports.initDB = initDB;
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const DATA_DIR = path_1.default.join(__dirname, '..', '..', 'data');
let data = {
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
if (!fs_1.default.existsSync(DATA_DIR)) {
    fs_1.default.mkdirSync(DATA_DIR, { recursive: true });
}
// Load from disk
const DB_FILE = path_1.default.join(DATA_DIR, 'sanguo.json');
if (fs_1.default.existsSync(DB_FILE)) {
    try {
        const loaded = JSON.parse(fs_1.default.readFileSync(DB_FILE, 'utf-8'));
        data = { ...data, ...loaded };
        console.log(`数据库加载成功: ${data.players.length} 玩家, ${data.generals.length} 武将`);
    }
    catch (e) {
        console.error('数据库加载失败，使用空数据库:', e);
    }
}
// Persistence
let saveTimer = null;
function scheduleSave() {
    if (saveTimer)
        return;
    saveTimer = setTimeout(() => {
        fs_1.default.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), 'utf-8');
        saveTimer = null;
    }, 1000); // Debounce: save at most once per second
}
// ============== Query helpers ==============
function getAll(collection) {
    if (collection === 'nextId')
        return [];
    return data[collection];
}
function findOne(collection, predicate) {
    const arr = data[collection];
    if (!arr)
        return undefined;
    return arr.find(predicate);
}
function findMany(collection, predicate) {
    const arr = data[collection];
    if (!arr)
        return [];
    return arr.filter(predicate);
}
function insert(collection, item) {
    const arr = data[collection];
    const id = data.nextId[collection] || 1;
    const newItem = { id, ...item };
    arr.push(newItem);
    data.nextId[collection] = id + 1;
    scheduleSave();
    return newItem;
}
function update(collection, id, updates) {
    const arr = data[collection];
    const index = arr.findIndex((item) => item.id === id);
    if (index !== -1) {
        arr[index] = { ...arr[index], ...updates };
        scheduleSave();
    }
}
function updateWhere(collection, predicate, updates) {
    const arr = data[collection];
    let changed = false;
    for (let i = 0; i < arr.length; i++) {
        if (predicate(arr[i])) {
            arr[i] = { ...arr[i], ...updates };
            changed = true;
        }
    }
    if (changed)
        scheduleSave();
}
function remove(collection, id) {
    const arr = data[collection];
    const index = arr.findIndex((item) => item.id === id);
    if (index !== -1) {
        arr.splice(index, 1);
        scheduleSave();
    }
}
function getNextId(collection) {
    return data.nextId[collection] || 1;
}
// Force immediate save (for shutdown)
function forceSave() {
    fs_1.default.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), 'utf-8');
    console.log('数据库已保存');
}
function initDB() {
    console.log(`数据库初始化完成 (JSON 文件模式)`);
}
