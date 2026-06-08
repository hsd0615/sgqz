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
export interface BagItem {
    id: number;
    player_id: number;
    item_code: string;
    item_count: number;
}
export interface LeitaiRoom {
    r_id: number;
    room_level: number;
    room_status: number;
    room_type: number;
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
export interface WSMessage {
    type: string;
    [key: string]: any;
}
export interface APIResponse {
    success: boolean;
    message?: string;
    data?: any;
    stamp?: string;
    head?: string;
    fun?: Function | null;
    funParamer?: any[];
}
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
    farPeerId: string | null;
}
