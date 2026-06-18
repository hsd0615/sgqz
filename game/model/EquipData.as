package game.model
{
   // 装备数据硬编码 - 不依赖XML/JSON加载, SWF内始终可用
   public class EquipData
   {
      // code → {slot, name, attack, attackPct, defense, defensePct, hp, hpPct, levelReq, quality}
      private static var _data:Object = {};

      private static function init() : void
      {
         if(_data["proto_4_1"] != null) return; // already inited

         // 武器 slot=1
         _data["proto_4_1"] = {slot:1,name:"铁剑",attack:50,attackPct:0,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:1,quality:1};
         _data["proto_4_2"] = {slot:1,name:"精钢剑",attack:120,attackPct:0,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:15,quality:2};
         _data["proto_4_3"] = {slot:1,name:"青釭剑",attack:200,attackPct:0,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:30,quality:3};
         _data["proto_4_4"] = {slot:1,name:"倚天剑",attack:300,attackPct:5,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:50,quality:4};
         _data["proto_4_5"] = {slot:1,name:"方天画戟",attack:500,attackPct:10,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:80,quality:5};

         // 防具 slot=2
         _data["proto_4_11"] = {slot:2,name:"皮甲",attack:0,attackPct:0,defense:30,defensePct:0,hp:0,hpPct:0,levelReq:1,quality:1};
         _data["proto_4_12"] = {slot:2,name:"锁子甲",attack:0,attackPct:0,defense:100,defensePct:0,hp:0,hpPct:0,levelReq:15,quality:2};
         _data["proto_4_13"] = {slot:2,name:"明光铠",attack:0,attackPct:0,defense:180,defensePct:0,hp:0,hpPct:0,levelReq:30,quality:3};
         _data["proto_4_14"] = {slot:2,name:"龙鳞甲",attack:0,attackPct:0,defense:250,defensePct:5,hp:0,hpPct:0,levelReq:50,quality:4};
         _data["proto_4_15"] = {slot:2,name:"玄武战甲",attack:0,attackPct:0,defense:400,defensePct:8,hp:0,hpPct:0,levelReq:80,quality:5};

         // 饰品 slot=3
         _data["proto_4_21"] = {slot:3,name:"护身符",attack:0,attackPct:0,defense:0,defensePct:0,hp:300,hpPct:0,levelReq:5,quality:1};
         _data["proto_4_22"] = {slot:3,name:"翡翠环",attack:0,attackPct:0,defense:0,defensePct:0,hp:600,hpPct:0,levelReq:20,quality:2};
         _data["proto_4_23"] = {slot:3,name:"护心镜",attack:0,attackPct:0,defense:0,defensePct:0,hp:1000,hpPct:0,levelReq:35,quality:3};
         _data["proto_4_24"] = {slot:3,name:"和氏璧",attack:50,attackPct:5,defense:50,defensePct:5,hp:1500,hpPct:5,levelReq:55,quality:4};
         _data["proto_4_25"] = {slot:3,name:"传国玉玺",attack:100,attackPct:8,defense:100,defensePct:8,hp:3000,hpPct:8,levelReq:100,quality:5};
      }

      // 获取装备属性
      public static function get(code:String, key:String) : *
      {
         init();
         if(_data[code] && _data[code][key] != undefined)
            return _data[code][key];
         return null;
      }

      // 获取某个slot的所有装备code列表
      public static function getBySlot(slot:int) : Array
      {
         init();
         var arr:Array = [];
         for(var k:String in _data)
         {
            if(_data[k].slot == slot) arr.push(k);
         }
         return arr;
      }

      // 获取所有装备code
      public static function getAllCodes() : Array
      {
         init();
         var arr:Array = [];
         for(var k:String in _data) arr.push(k);
         return arr;
      }

      // 内置的shop装备商品数据 (category=5装备部分)
      public static function getShopEquipItems() : Array
      {
         // icon使用已有的proto图标(proto_1_X系列), 避免getDefinition失败
         return [
            {id:"shop046",name:"铁剑",category:5,code:"proto_4_1",count:1,payType:2,oldPrice:100,newPrice:50,icon:"proto_1_0",desc:"武器 攻+50 Lv1 [普通]"},
            {id:"shop047",name:"精钢剑",category:5,code:"proto_4_2",count:1,payType:2,oldPrice:300,newPrice:150,icon:"proto_1_0",desc:"武器 攻+120 Lv15 [精良]"},
            {id:"shop048",name:"青釭剑",category:5,code:"proto_4_3",count:1,payType:2,oldPrice:600,newPrice:300,icon:"proto_1_0",desc:"武器 攻+200 Lv30 [稀有]"},
            {id:"shop049",name:"倚天剑",category:5,code:"proto_4_4",count:1,payType:2,oldPrice:1200,newPrice:600,icon:"proto_1_0",desc:"武器 攻+300 攻+5% Lv50 [史诗]"},
            {id:"shop050",name:"方天画戟",category:5,code:"proto_4_5",count:1,payType:2,oldPrice:3000,newPrice:1500,icon:"proto_1_0",desc:"武器 攻+500 攻+10% Lv80 [传说]"},
            {id:"shop051",name:"皮甲",category:5,code:"proto_4_11",count:1,payType:2,oldPrice:80,newPrice:40,icon:"proto_1_1",desc:"防具 防+30 Lv1 [普通]"},
            {id:"shop052",name:"锁子甲",category:5,code:"proto_4_12",count:1,payType:2,oldPrice:240,newPrice:120,icon:"proto_1_1",desc:"防具 防+100 Lv15 [精良]"},
            {id:"shop053",name:"明光铠",category:5,code:"proto_4_13",count:1,payType:2,oldPrice:500,newPrice:250,icon:"proto_1_1",desc:"防具 防+180 Lv30 [稀有]"},
            {id:"shop054",name:"龙鳞甲",category:5,code:"proto_4_14",count:1,payType:2,oldPrice:1000,newPrice:500,icon:"proto_1_1",desc:"防具 防+250 防+5% Lv50 [史诗]"},
            {id:"shop055",name:"玄武战甲",category:5,code:"proto_4_15",count:1,payType:2,oldPrice:2500,newPrice:1200,icon:"proto_1_1",desc:"防具 防+400 防+8% Lv80 [传说]"},
            {id:"shop056",name:"护身符",category:5,code:"proto_4_21",count:1,payType:2,oldPrice:120,newPrice:60,icon:"proto_1_2",desc:"饰品 HP+300 Lv5 [普通]"},
            {id:"shop057",name:"翡翠环",category:5,code:"proto_4_22",count:1,payType:2,oldPrice:360,newPrice:180,icon:"proto_1_2",desc:"饰品 HP+600 Lv20 [精良]"},
            {id:"shop058",name:"护心镜",category:5,code:"proto_4_23",count:1,payType:2,oldPrice:700,newPrice:350,icon:"proto_1_2",desc:"饰品 HP+1000 Lv35 [稀有]"},
            {id:"shop059",name:"和氏璧",category:5,code:"proto_4_24",count:1,payType:2,oldPrice:1500,newPrice:800,icon:"proto_1_2",desc:"饰品 全属性+5% HP+1500 Lv55 [史诗]"},
            {id:"shop060",name:"传国玉玺",category:5,code:"proto_4_25",count:1,payType:2,oldPrice:5000,newPrice:2500,icon:"proto_1_2",desc:"饰品 全属性+8% HP+3000 Lv100 [传说]"}
         ];
      }
   }
}
