import { Player, General, BagItem, LeitaiRoom } from '../models/types';
export declare const PlayerRepo: {
    findByUserId(userId: string): Player | undefined;
    findById(id: number): Player | undefined;
    findByRoleId(roleId: string): Player | undefined;
    findByUserIdAndPassword(userId: string, password: string): Player | undefined;
    create(userId: string, roleName: string, imageId: number, agent: string, password?: string): Player;
    update(id: number, data: Partial<Player>): void;
    generateToken(id: number): string;
};
export declare const GeneralRepo: {
    findByPlayerId(playerId: number): General[];
    findById(id: number): General | undefined;
    create(playerId: number, data: Partial<General>): General;
    update(id: number, data: Partial<General>): void;
    delete(id: number): void;
    getDeployed(playerId: number): General[];
    setDeployed(playerId: number, generalIds: number[]): void;
};
export declare const BagItemRepo: {
    findByPlayerId(playerId: number): BagItem[];
    findItem(playerId: number, itemCode: string): BagItem | undefined;
    updateOrCreate(playerId: number, itemCode: string, count: number, itemId?: number): void;
    getCount(playerId: number, itemCode: string): number;
    addItem(playerId: number, itemCode: string, addCount: number): void;
    removeItem(playerId: number, itemCode: string, removeCount: number): void;
};
export declare const LeitaiRepo: {
    findAll(): LeitaiRoom[];
    findById(rId: number): LeitaiRoom | undefined;
    update(rId: number, data: Partial<LeitaiRoom>): void;
    initDefaultRooms(): void;
};
