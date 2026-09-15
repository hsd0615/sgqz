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
export declare function getAll(collection: keyof DBData): any[];
export declare function findOne(collection: string, predicate: (item: any) => boolean): any | undefined;
export declare function findMany(collection: string, predicate: (item: any) => boolean): any[];
export declare function insert(collection: string, item: any): any;
export declare function update(collection: string, id: number, updates: any): void;
export declare function updateWhere(collection: string, predicate: (item: any) => boolean, updates: any): void;
export declare function remove(collection: string, id: number): void;
export declare function getNextId(collection: string): number;
export declare function forceSave(): void;
export declare function initDB(): void;
