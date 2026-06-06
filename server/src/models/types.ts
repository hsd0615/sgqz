// ============== Player 相关 ==============
export interface Player {
  id: number;
  user_id: string;
  agent: string;
  password: string;
  role_name: string;
  image_id: number;
  level: number;
  exp: number;
  money: number;
  dianka: number;
  exploit: number;
  reverence: number;
  rongyu: number;
  win_count: number;
  lost_count: number;
  finished_stages: string;
  history: string;
  login_server: number;
  token: string;
}

// ============== General 相关 ==============
export interface General {
  id: number;
  player_id: number;
  general_id: number;
  code: string;
  name: string;
  level: number;
  evolution: number;
  feature: number;
  tianfu: string | null;
  kezhi1: number;
  kezhi1_level: number;
  kezhi2: number;
  kezhi2_level: number;
  kezhi3: number;
  kezhi3_level: number;
  is_deployed: number;
}

// ============== BagItem 相关 ==============
export interface BagItem {
  id: number;
  player_id: number;
  item_code: string;
  item_count: number;
}

// ============== Leitai 相关 ==============
export interface LeitaiRoom {
  r_id: number;
  room_level: number;
  room_status: number;   // 0=空闲, 1=等待中, 2=战斗中
  room_type: number;     // 1=金币, 2=功勋, 3=点卡
  room_price: number;
  master_id: number | null;
  master_pid: string | null;
  master_name: string | null;
  master_level: number | null;
  master_image: number | null;
  slave_id: number | null;
  slave_pid: string | null;
  slave_name: string | null;
  slave_level: number | null;
  slave_image: number | null;
  rongyu_pool: number;
  battle_count: number;
}

// ============== WebSocket 消息 ==============
export interface WSMessage {
  type: string;
  [key: string]: any;
}

// ============== HTTP 响应格式（兼容原客户端） ==============
export interface APIResponse {
  success: boolean;
  message?: string;
  data?: any;
  stamp?: string;
  head?: string;
  fun?: Function | null;
  funParamer?: any[];
}

// ============== 客户端 Session ==============
export interface ClientSession {
  ws: any;
  playerId: number;
  roleId: string;
  peerId: string;
  roleName: string;
  level: number;
  imageId: number;
  agent: string;
  rooms: Set<string>;
  farPeerId: string | null;  // 当前对手
}
