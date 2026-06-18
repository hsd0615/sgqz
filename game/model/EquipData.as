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

         // 头盔 slot=4 (proto_4_6~10)
         _data["proto_4_6"] = {slot:4,name:"布帽",attack:0,attackPct:0,defense:0,defensePct:0,hp:100,hpPct:0,levelReq:1,quality:1};
         _data["proto_4_7"] = {slot:4,name:"铁盔",attack:0,attackPct:0,defense:0,defensePct:0,hp:300,hpPct:0,levelReq:15,quality:2};
         _data["proto_4_8"] = {slot:4,name:"银盔",attack:0,attackPct:0,defense:0,defensePct:0,hp:600,hpPct:0,levelReq:30,quality:3};
         _data["proto_4_9"] = {slot:4,name:"金冠",attack:0,attackPct:0,defense:0,defensePct:0,hp:1000,hpPct:5,levelReq:50,quality:4};
         _data["proto_4_10"] = {slot:4,name:"龙盔",attack:0,attackPct:0,defense:0,defensePct:0,hp:2000,hpPct:8,levelReq:80,quality:5};

         // 战靴 slot=5 (proto_4_16~20)
         _data["proto_4_16"] = {slot:5,name:"草鞋",attack:0,attackPct:0,defense:20,defensePct:0,hp:0,hpPct:0,levelReq:1,quality:1};
         _data["proto_4_17"] = {slot:5,name:"皮靴",attack:0,attackPct:0,defense:80,defensePct:0,hp:0,hpPct:0,levelReq:15,quality:2};
         _data["proto_4_18"] = {slot:5,name:"铁靴",attack:0,attackPct:0,defense:150,defensePct:0,hp:0,hpPct:0,levelReq:30,quality:3};
         _data["proto_4_19"] = {slot:5,name:"银靴",attack:0,attackPct:0,defense:220,defensePct:5,hp:0,hpPct:0,levelReq:50,quality:4};
         _data["proto_4_20"] = {slot:5,name:"神行靴",attack:0,attackPct:0,defense:350,defensePct:8,hp:0,hpPct:0,levelReq:80,quality:5};

         // 饰品Ⅱ slot=6 (proto_4_26~30)
         _data["proto_4_26"] = {slot:6,name:"铜戒指",attack:30,attackPct:0,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:10,quality:1};
         _data["proto_4_27"] = {slot:6,name:"银戒指",attack:80,attackPct:0,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:25,quality:2};
         _data["proto_4_28"] = {slot:6,name:"金戒指",attack:150,attackPct:0,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:40,quality:3};
         _data["proto_4_29"] = {slot:6,name:"龙戒",attack:250,attackPct:5,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:60,quality:4};
         _data["proto_4_30"] = {slot:6,name:"神戒",attack:400,attackPct:8,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:90,quality:5};

         // === 武侠扩展装备 (46件) ===
         // 武器 slot=1 (proto_4_31~38)
         _data["proto_4_31"] = {slot:1,name:"柳叶刀",attack:80,attackPct:0,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:8,quality:1,iconIdx:1};
         _data["proto_4_32"] = {slot:1,name:"雁翎刀",attack:150,attackPct:0,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:20,quality:2,iconIdx:2};
         _data["proto_4_33"] = {slot:1,name:"鱼鳞刀",attack:230,attackPct:0,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:35,quality:3,iconIdx:3};
         _data["proto_4_34"] = {slot:1,name:"金背刀",attack:330,attackPct:3,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:55,quality:4,iconIdx:4};
         _data["proto_4_35"] = {slot:1,name:"斩马刀",attack:450,attackPct:6,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:75,quality:5,iconIdx:5};
         _data["proto_4_36"] = {slot:1,name:"青龙偃月",attack:600,attackPct:8,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:100,quality:6,iconIdx:6};
         _data["proto_4_37"] = {slot:1,name:"丈八蛇矛",attack:800,attackPct:10,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:130,quality:7,iconIdx:7};
         _data["proto_4_38"] = {slot:1,name:"神罚",attack:1200,attackPct:15,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:160,quality:8,iconIdx:8};
         // 铠甲 slot=2 (proto_4_39~46)
         _data["proto_4_39"] = {slot:2,name:"藤甲",attack:0,attackPct:0,defense:50,defensePct:0,hp:0,hpPct:0,levelReq:8,quality:1,iconIdx:9};
         _data["proto_4_40"] = {slot:2,name:"铁叶甲",attack:0,attackPct:0,defense:120,defensePct:0,hp:0,hpPct:0,levelReq:20,quality:2,iconIdx:10};
         _data["proto_4_41"] = {slot:2,name:"连环甲",attack:0,attackPct:0,defense:200,defensePct:0,hp:0,hpPct:0,levelReq:35,quality:3,iconIdx:11};
         _data["proto_4_42"] = {slot:2,name:"犀牛甲",attack:0,attackPct:0,defense:280,defensePct:3,hp:0,hpPct:0,levelReq:55,quality:4,iconIdx:12};
         _data["proto_4_43"] = {slot:2,name:"狻猊甲",attack:0,attackPct:0,defense:380,defensePct:6,hp:0,hpPct:0,levelReq:75,quality:5,iconIdx:13};
         _data["proto_4_44"] = {slot:2,name:"麒麟铠",attack:0,attackPct:0,defense:500,defensePct:8,hp:0,hpPct:0,levelReq:100,quality:6,iconIdx:14};
         _data["proto_4_45"] = {slot:2,name:"朱雀战袍",attack:0,attackPct:0,defense:650,defensePct:10,hp:0,hpPct:0,levelReq:130,quality:7,iconIdx:15};
         _data["proto_4_46"] = {slot:2,name:"不灭金身",attack:0,attackPct:0,defense:900,defensePct:15,hp:0,hpPct:0,levelReq:160,quality:8,iconIdx:16};
         // 饰品Ⅰ slot=3 (proto_4_47~54)
         _data["proto_4_47"] = {slot:3,name:"木符",attack:0,attackPct:0,defense:0,defensePct:0,hp:400,hpPct:0,levelReq:10,quality:1,iconIdx:17};
         _data["proto_4_48"] = {slot:3,name:"石符",attack:0,attackPct:0,defense:0,defensePct:0,hp:800,hpPct:0,levelReq:25,quality:2,iconIdx:18};
         _data["proto_4_49"] = {slot:3,name:"铜符",attack:0,attackPct:0,defense:0,defensePct:0,hp:1300,hpPct:0,levelReq:40,quality:3,iconIdx:19};
         _data["proto_4_50"] = {slot:3,name:"银符",attack:0,attackPct:0,defense:0,defensePct:0,hp:2000,hpPct:5,levelReq:60,quality:4,iconIdx:20};
         _data["proto_4_51"] = {slot:3,name:"金符",attack:0,attackPct:0,defense:0,defensePct:0,hp:3000,hpPct:8,levelReq:80,quality:5,iconIdx:21};
         _data["proto_4_52"] = {slot:3,name:"龙符",attack:0,attackPct:0,defense:0,defensePct:0,hp:4500,hpPct:10,levelReq:105,quality:6,iconIdx:22};
         _data["proto_4_53"] = {slot:3,name:"凤符",attack:0,attackPct:0,defense:0,defensePct:0,hp:6500,hpPct:12,levelReq:135,quality:7,iconIdx:23};
         _data["proto_4_54"] = {slot:3,name:"天地令",attack:0,attackPct:0,defense:0,defensePct:0,hp:10000,hpPct:18,levelReq:165,quality:8,iconIdx:24};
         // 头盔 slot=4 (proto_4_55~62)
         _data["proto_4_55"] = {slot:4,name:"方巾",attack:0,attackPct:0,defense:0,defensePct:0,hp:150,hpPct:0,levelReq:5,quality:1,iconIdx:25};
         _data["proto_4_56"] = {slot:4,name:"铜冠",attack:0,attackPct:0,defense:0,defensePct:0,hp:400,hpPct:0,levelReq:20,quality:2,iconIdx:26};
         _data["proto_4_57"] = {slot:4,name:"镔铁盔",attack:0,attackPct:0,defense:0,defensePct:0,hp:750,hpPct:0,levelReq:35,quality:3,iconIdx:27};
         _data["proto_4_58"] = {slot:4,name:"凤翅冠",attack:0,attackPct:0,defense:0,defensePct:0,hp:1200,hpPct:5,levelReq:55,quality:4,iconIdx:28};
         _data["proto_4_59"] = {slot:4,name:"紫金冠",attack:0,attackPct:0,defense:0,defensePct:0,hp:1800,hpPct:8,levelReq:75,quality:5,iconIdx:29};
         _data["proto_4_60"] = {slot:4,name:"灵蛇盔",attack:0,attackPct:0,defense:0,defensePct:0,hp:2800,hpPct:10,levelReq:100,quality:6,iconIdx:30};
         _data["proto_4_61"] = {slot:4,name:"虎头盔",attack:0,attackPct:0,defense:0,defensePct:0,hp:4200,hpPct:12,levelReq:130,quality:7,iconIdx:31};
         _data["proto_4_62"] = {slot:4,name:"九龙冠",attack:0,attackPct:0,defense:0,defensePct:0,hp:6500,hpPct:18,levelReq:160,quality:8,iconIdx:32};
         // 战靴 slot=5 (proto_4_63~70)
         _data["proto_4_63"] = {slot:5,name:"麻鞋",attack:0,attackPct:0,defense:35,defensePct:0,hp:0,hpPct:0,levelReq:8,quality:1,iconIdx:33};
         _data["proto_4_64"] = {slot:5,name:"快靴",attack:0,attackPct:0,defense:100,defensePct:0,hp:0,hpPct:0,levelReq:20,quality:2,iconIdx:34};
         _data["proto_4_65"] = {slot:5,name:"虎头靴",attack:0,attackPct:0,defense:180,defensePct:0,hp:0,hpPct:0,levelReq:35,quality:3,iconIdx:35};
         _data["proto_4_66"] = {slot:5,name:"飞云靴",attack:0,attackPct:0,defense:260,defensePct:3,hp:0,hpPct:0,levelReq:55,quality:4,iconIdx:36};
         _data["proto_4_67"] = {slot:5,name:"踏云靴",attack:0,attackPct:0,defense:360,defensePct:6,hp:0,hpPct:0,levelReq:75,quality:5,iconIdx:37};
         _data["proto_4_68"] = {slot:5,name:"凌波靴",attack:0,attackPct:0,defense:480,defensePct:8,hp:0,hpPct:0,levelReq:100,quality:6,iconIdx:38};
         _data["proto_4_69"] = {slot:5,name:"追月靴",attack:0,attackPct:0,defense:620,defensePct:10,hp:0,hpPct:0,levelReq:130,quality:7,iconIdx:39};
         _data["proto_4_70"] = {slot:5,name:"风云靴",attack:0,attackPct:0,defense:850,defensePct:15,hp:0,hpPct:0,levelReq:160,quality:8,iconIdx:40};
         // 饰品Ⅱ slot=6 (proto_4_71~76)
         _data["proto_4_71"] = {slot:6,name:"骨戒",attack:50,attackPct:0,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:12,quality:1,iconIdx:41};
         _data["proto_4_72"] = {slot:6,name:"银环",attack:100,attackPct:0,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:28,quality:2,iconIdx:42};
         _data["proto_4_73"] = {slot:6,name:"玉扳指",attack:180,attackPct:0,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:45,quality:3,iconIdx:43};
         _data["proto_4_74"] = {slot:6,name:"血玉环",attack:300,attackPct:5,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:65,quality:4,iconIdx:44};
         _data["proto_4_75"] = {slot:6,name:"龙环",attack:480,attackPct:8,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:95,quality:5,iconIdx:45};
         _data["proto_4_76"] = {slot:6,name:"乾坤圈",attack:700,attackPct:12,defense:0,defensePct:0,hp:0,hpPct:0,levelReq:140,quality:6,iconIdx:46};
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
            {id:"shop046",name:"铁剑",category:5,code:"proto_4_1",count:1,payType:2,oldPrice:100,newPrice:50,icon:"proto_3_4",desc:"武器 攻+50 Lv1 [普通]"},
            {id:"shop047",name:"精钢剑",category:5,code:"proto_4_2",count:1,payType:2,oldPrice:300,newPrice:150,icon:"proto_3_4",desc:"武器 攻+120 Lv15 [精良]"},
            {id:"shop048",name:"青釭剑",category:5,code:"proto_4_3",count:1,payType:2,oldPrice:600,newPrice:300,icon:"proto_3_4",desc:"武器 攻+200 Lv30 [稀有]"},
            {id:"shop049",name:"倚天剑",category:5,code:"proto_4_4",count:1,payType:2,oldPrice:1200,newPrice:600,icon:"proto_3_4",desc:"武器 攻+300 攻+5% Lv50 [史诗]"},
            {id:"shop050",name:"方天画戟",category:5,code:"proto_4_5",count:1,payType:2,oldPrice:3000,newPrice:1500,icon:"proto_3_4",desc:"武器 攻+500 攻+10% Lv80 [传说]"},
            {id:"shop051",name:"皮甲",category:5,code:"proto_4_11",count:1,payType:2,oldPrice:80,newPrice:40,icon:"proto_3_4",desc:"防具 防+30 Lv1 [普通]"},
            {id:"shop052",name:"锁子甲",category:5,code:"proto_4_12",count:1,payType:2,oldPrice:240,newPrice:120,icon:"proto_3_4",desc:"防具 防+100 Lv15 [精良]"},
            {id:"shop053",name:"明光铠",category:5,code:"proto_4_13",count:1,payType:2,oldPrice:500,newPrice:250,icon:"proto_3_4",desc:"防具 防+180 Lv30 [稀有]"},
            {id:"shop054",name:"龙鳞甲",category:5,code:"proto_4_14",count:1,payType:2,oldPrice:1000,newPrice:500,icon:"proto_3_4",desc:"防具 防+250 防+5% Lv50 [史诗]"},
            {id:"shop055",name:"玄武战甲",category:5,code:"proto_4_15",count:1,payType:2,oldPrice:2500,newPrice:1200,icon:"proto_3_4",desc:"防具 防+400 防+8% Lv80 [传说]"},
            {id:"shop056",name:"护身符",category:5,code:"proto_4_21",count:1,payType:2,oldPrice:120,newPrice:60,icon:"proto_3_4",desc:"饰品 HP+300 Lv5 [普通]"},
            {id:"shop057",name:"翡翠环",category:5,code:"proto_4_22",count:1,payType:2,oldPrice:360,newPrice:180,icon:"proto_3_4",desc:"饰品 HP+600 Lv20 [精良]"},
            {id:"shop058",name:"护心镜",category:5,code:"proto_4_23",count:1,payType:2,oldPrice:700,newPrice:350,icon:"proto_3_4",desc:"饰品 HP+1000 Lv35 [稀有]"},
            {id:"shop059",name:"和氏璧",category:5,code:"proto_4_24",count:1,payType:2,oldPrice:1500,newPrice:800,icon:"proto_3_4",desc:"饰品 全属性+5% HP+1500 Lv55 [史诗]"},
            {id:"shop060",name:"传国玉玺",category:5,code:"proto_4_25",count:1,payType:2,oldPrice:5000,newPrice:2500,icon:"proto_3_4",desc:"饰品 全属性+8% HP+3000 Lv100 [传说]"},
            // 头盔 slot=4
            {id:"shop061",name:"布帽",category:5,code:"proto_4_6",count:1,payType:2,oldPrice:60,newPrice:30,icon:"proto_3_4",desc:"头盔 HP+100 Lv1 [普通]"},
            {id:"shop062",name:"铁盔",category:5,code:"proto_4_7",count:1,payType:2,oldPrice:200,newPrice:100,icon:"proto_3_4",desc:"头盔 HP+300 Lv15 [精良]"},
            {id:"shop063",name:"银盔",category:5,code:"proto_4_8",count:1,payType:2,oldPrice:450,newPrice:220,icon:"proto_3_4",desc:"头盔 HP+600 Lv30 [稀有]"},
            {id:"shop064",name:"金冠",category:5,code:"proto_4_9",count:1,payType:2,oldPrice:900,newPrice:450,icon:"proto_3_4",desc:"头盔 HP+1000 HP+5% Lv50 [史诗]"},
            {id:"shop065",name:"龙盔",category:5,code:"proto_4_10",count:1,payType:2,oldPrice:2000,newPrice:1000,icon:"proto_3_4",desc:"头盔 HP+2000 HP+8% Lv80 [传说]"},
            // 战靴 slot=5
            {id:"shop066",name:"草鞋",category:5,code:"proto_4_16",count:1,payType:2,oldPrice:50,newPrice:25,icon:"proto_3_4",desc:"战靴 防+20 Lv1 [普通]"},
            {id:"shop067",name:"皮靴",category:5,code:"proto_4_17",count:1,payType:2,oldPrice:180,newPrice:90,icon:"proto_3_4",desc:"战靴 防+80 Lv15 [精良]"},
            {id:"shop068",name:"铁靴",category:5,code:"proto_4_18",count:1,payType:2,oldPrice:400,newPrice:200,icon:"proto_3_4",desc:"战靴 防+150 Lv30 [稀有]"},
            {id:"shop069",name:"银靴",category:5,code:"proto_4_19",count:1,payType:2,oldPrice:800,newPrice:400,icon:"proto_3_4",desc:"战靴 防+220 防+5% Lv50 [史诗]"},
            {id:"shop070",name:"神行靴",category:5,code:"proto_4_20",count:1,payType:2,oldPrice:1800,newPrice:900,icon:"proto_3_4",desc:"战靴 防+350 防+8% Lv80 [传说]"},
            // 饰品Ⅱ slot=6
            {id:"shop071",name:"铜戒指",category:5,code:"proto_4_26",count:1,payType:2,oldPrice:80,newPrice:40,icon:"proto_3_4",desc:"饰品Ⅱ 攻+30 Lv10 [普通]"},
            {id:"shop072",name:"银戒指",category:5,code:"proto_4_27",count:1,payType:2,oldPrice:250,newPrice:120,icon:"proto_3_4",desc:"饰品Ⅱ 攻+80 Lv25 [精良]"},
            {id:"shop073",name:"金戒指",category:5,code:"proto_4_28",count:1,payType:2,oldPrice:550,newPrice:280,icon:"proto_3_4",desc:"饰品Ⅱ 攻+150 Lv40 [稀有]"},
            {id:"shop074",name:"龙戒",category:5,code:"proto_4_29",count:1,payType:2,oldPrice:1100,newPrice:550,icon:"proto_3_4",desc:"饰品Ⅱ 攻+250 攻+5% Lv60 [史诗]"},
            {id:"shop075",name:"神戒",category:5,code:"proto_4_30",count:1,payType:2,oldPrice:2500,newPrice:1200,icon:"proto_3_4",desc:"饰品Ⅱ 攻+400 攻+8% Lv90 [传说]"}
         ];
      }
   }
}
