package game.model {
   public class EquipData {
      private static var _data:Object = {};
      private static function init():void {
         if(_data["proto_4_31"]!=null) return;

         // iconIdx: 头盔1-4,战靴5-7,护甲8-10,武器11-20,饰品21-30
         // ====== 基础装备 proto_4_1~30 (与31+重复code, 服务端兼容) ======
         // 武器 Q1-5
         _data["proto_4_1"]={slot:1,name:"铁剑",attack:50,defense:8,hp:25,levelReq:1,quality:1,iconIdx:18};
         _data["proto_4_2"]={slot:1,name:"精钢剑",attack:130,defense:20,hp:60,levelReq:15,quality:2,iconIdx:17};
         _data["proto_4_3"]={slot:1,name:"青釭剑",attack:240,defense:40,hp:110,levelReq:30,quality:3,iconIdx:19};
         _data["proto_4_4"]={slot:1,name:"倚天剑",attack:380,attackPct:4,defense:70,hp:180,levelReq:50,quality:4,iconIdx:12};
         _data["proto_4_5"]={slot:1,name:"方天画戟",attack:580,attackPct:7,defense:120,hp:290,levelReq:80,quality:5,iconIdx:14};
         // 头盔 Q1-5
         _data["proto_4_6"]={slot:4,name:"布帽",defense:22,hp:55,levelReq:5,quality:1,iconIdx:1};
         _data["proto_4_7"]={slot:4,name:"铁盔",defense:70,hp:170,levelReq:18,quality:2,iconIdx:1};
         _data["proto_4_8"]={slot:4,name:"银盔",defense:115,hp:320,levelReq:35,quality:3,iconIdx:2};
         _data["proto_4_9"]={slot:4,name:"金冠",defense:165,hpPct:4,hp:1300,levelReq:55,quality:4,iconIdx:3};
         _data["proto_4_10"]={slot:4,name:"龙盔",defense:230,hpPct:5,hp:2600,levelReq:75,quality:5,iconIdx:3};
         // 铠甲 Q1-5
         _data["proto_4_11"]={slot:2,name:"皮甲",defense:48,attack:12,hp:22,levelReq:8,quality:1,iconIdx:9};
         _data["proto_4_12"]={slot:2,name:"锁子甲",defense:130,attack:30,hp:65,levelReq:20,quality:2,iconIdx:9};
         _data["proto_4_13"]={slot:2,name:"明光铠",defense:235,attack:60,hp:130,levelReq:35,quality:3,iconIdx:9};
         _data["proto_4_14"]={slot:2,name:"龙鳞甲",defense:360,defensePct:3,attack:100,hp:230,levelReq:55,quality:4,iconIdx:8};
         _data["proto_4_15"]={slot:2,name:"玄武战甲",defense:520,defensePct:6,dmgReduce:5,attack:130,hp:370,levelReq:75,quality:5,iconIdx:8};
         // 战靴 Q1-5
         _data["proto_4_16"]={slot:5,name:"草鞋",defense:12,hp:30,levelReq:3,quality:1,iconIdx:5};
         _data["proto_4_17"]={slot:5,name:"皮靴",defense:40,hp:100,levelReq:16,quality:2,iconIdx:5};
         _data["proto_4_18"]={slot:5,name:"铁靴",defense:75,hp:210,levelReq:32,quality:3,iconIdx:6};
         _data["proto_4_19"]={slot:5,name:"银靴",defense:115,hp:370,levelReq:50,quality:4,iconIdx:6};
         _data["proto_4_20"]={slot:5,name:"神行靴",defense:165,hpPct:3,hp:700,levelReq:70,quality:5,iconIdx:7};
         // 饰品I Q1-5
         _data["proto_4_21"]={slot:3,name:"木符",hp:0,hpPct:2,attack:10,defense:8,levelReq:1,quality:1,iconIdx:30};
         _data["proto_4_22"]={slot:3,name:"翡翠环",hp:200,hpPct:2,attack:50,defense:30,levelReq:18,quality:2,iconIdx:27};
         _data["proto_4_23"]={slot:3,name:"护心镜",hp:500,hpPct:2,attack:105,defense:75,levelReq:35,quality:3,iconIdx:27};
         _data["proto_4_24"]={slot:3,name:"和氏璧",hp:950,hpPct:3,attack:170,defense:135,levelReq:55,quality:4,iconIdx:22};
         _data["proto_4_25"]={slot:3,name:"天地令",hp:3100,hpPct:7,lifesteal:4,attack:200,defense:280,levelReq:80,quality:5,iconIdx:24};
         // 饰品II Q1-5
         _data["proto_4_26"]={slot:3,name:"铜戒指",attack:55,defense:12,hp:70,levelReq:12,quality:1,iconIdx:30};
         _data["proto_4_27"]={slot:3,name:"银戒指",attack:125,defense:28,hp:170,levelReq:28,quality:2,iconIdx:27};
         _data["proto_4_28"]={slot:3,name:"金戒指",attack:220,defense:55,hp:330,levelReq:45,quality:3,iconIdx:22};
         _data["proto_4_29"]={slot:3,name:"龙戒",attack:350,attackPct:4,defense:95,hp:550,levelReq:65,quality:4,iconIdx:22};
         _data["proto_4_30"]={slot:3,name:"神戒",attack:540,attackPct:8,lifesteal:5,defense:160,hp:880,levelReq:95,quality:5,iconIdx:24};

         // 武器 (slot=1) Q1-10+特殊
         _data["proto_4_31"]={slot:1,name:"铁剑",attack:50,defense:8,hp:25,levelReq:1,quality:1,iconIdx:18};
         _data["proto_4_32"]={slot:1,name:"精钢剑",attack:130,defense:20,hp:60,levelReq:15,quality:2,iconIdx:17};
         _data["proto_4_33"]={slot:1,name:"青釭剑",attack:240,defense:40,hp:110,levelReq:30,quality:3,iconIdx:19};
         _data["proto_4_34"]={slot:1,name:"倚天剑",attack:380,attackPct:4,defense:70,hp:180,levelReq:50,quality:4,iconIdx:12};
         _data["proto_4_35"]={slot:1,name:"方天画戟",attack:580,attackPct:7,defense:120,hp:290,levelReq:80,quality:5,iconIdx:14};
         _data["proto_4_36"]={slot:1,name:"青龙偃月",attack:800,attackPct:9,critRate:16,critDmg:15,defense:160,hp:460,levelReq:100,quality:6,iconIdx:20};
         _data["proto_4_37"]={slot:1,name:"丈八蛇矛",attack:2200,attackPct:15,dmgBonus:10,defense:-60,hp:1400,levelReq:130,quality:7,iconIdx:11};
         _data["proto_4_38"]={slot:1,name:"神罚",attack:3500,attackPct:20,lifesteal:10,dmgBonus:8,defense:900,hp:2600,levelReq:160,quality:8,iconIdx:16};
         _data["proto_4_81"]={slot:1,name:"寒月刀",attack:5000,attackPct:25,lifesteal:12,defense:1400,hp:3600,levelReq:185,quality:9,iconIdx:13};
         _data["proto_4_82"]={slot:1,name:"灭世",attack:7000,attackPct:30,dmgBonus:15,critRate:30,defense:2000,hp:5200,levelReq:200,quality:10,iconIdx:15};
         _data["proto_4_83"]={slot:1,name:"血祭之刃",attack:5500,attackPct:28,lifesteal:20,dmgBonus:12,defense:600,hp:3000,levelReq:170,quality:10,iconIdx:15};

         // 铠甲 (slot=2) Q1-10+特殊  icon:9皮甲/8玄武/10麒麟
         _data["proto_4_39"]={slot:2,name:"皮甲",defense:48,attack:12,hp:22,levelReq:8,quality:1,iconIdx:9};
         _data["proto_4_40"]={slot:2,name:"锁子甲",defense:130,attack:30,hp:65,levelReq:20,quality:2,iconIdx:9};
         _data["proto_4_41"]={slot:2,name:"明光铠",defense:235,attack:60,hp:130,levelReq:35,quality:3,iconIdx:9};
         _data["proto_4_42"]={slot:2,name:"龙鳞甲",defense:360,defensePct:3,attack:100,hp:230,levelReq:55,quality:4,iconIdx:8};
         _data["proto_4_43"]={slot:2,name:"玄武战甲",defense:520,defensePct:6,dmgReduce:5,attack:130,hp:370,levelReq:75,quality:5,iconIdx:8};
         _data["proto_4_44"]={slot:2,name:"麒麟铠",defense:750,defensePct:9,dmgReduce:8,attack:200,hp:580,levelReq:100,quality:6,iconIdx:10};
         _data["proto_4_45"]={slot:2,name:"朱雀战袍",defense:2200,defensePct:16,dmgReduce:12,attack:-60,hp:2000,levelReq:130,quality:7,iconIdx:10};
         _data["proto_4_46"]={slot:2,name:"不灭金身",defense:3500,defensePct:22,dmgReduce:16,lifesteal:6,attack:1000,hp:3400,levelReq:160,quality:8,iconIdx:10};
         _data["proto_4_84"]={slot:2,name:"龙纹战甲",defense:5000,defensePct:28,dmgReduce:20,attack:1500,hp:4800,levelReq:185,quality:9,iconIdx:10};
         _data["proto_4_85"]={slot:2,name:"万古不朽",defense:7000,defensePct:35,dmgReduce:25,lifesteal:10,attack:2200,hp:6800,levelReq:200,quality:10,iconIdx:10};
         _data["proto_4_86"]={slot:2,name:"荆棘反甲",defense:5000,defensePct:25,dmgReduce:15,dmgBonus:15,attack:1200,hp:4500,levelReq:170,quality:10,iconIdx:10};

         // 饰品 (slot=3) Q1-10+特殊  icon:30铜戒指/27翡翠/22和氏璧/24天地/23嗜血/21七杀/26紫微/25混沌/28贪狼/29轮回
         _data["proto_4_47"]={slot:3,name:"木符",hp:320,attack:18,defense:25,levelReq:10,quality:1,iconIdx:30};
         _data["proto_4_48"]={slot:3,name:"翡翠环",hp:700,attack:42,defense:60,levelReq:25,quality:2,iconIdx:27};
         _data["proto_4_49"]={slot:3,name:"护心镜",hp:1250,attack:80,defense:110,levelReq:40,quality:3,iconIdx:22};
         _data["proto_4_50"]={slot:3,name:"和氏璧",hp:2000,hpPct:4,attack:130,attackPct:2,defense:180,levelReq:60,quality:4,iconIdx:22};
         _data["proto_4_51"]={slot:3,name:"天地令",hp:3100,hpPct:7,lifesteal:4,attack:200,defense:280,levelReq:80,quality:5,iconIdx:24};
         _data["proto_4_52"]={slot:3,name:"嗜血魔符",hp:4800,hpPct:10,lifesteal:8,dmgBonus:4,attack:320,defense:430,levelReq:105,quality:6,iconIdx:23};
         _data["proto_4_53"]={slot:3,name:"七杀戒",hp:16000,hpPct:18,critRate:30,critDmg:20,attack:1200,defense:1500,levelReq:135,quality:7,iconIdx:21};
         _data["proto_4_54"]={slot:3,name:"紫微星",hp:24000,hpPct:24,dmgBonus:10,lifesteal:8,attack:1800,defense:2200,levelReq:165,quality:8,iconIdx:26};
         _data["proto_4_87"]={slot:3,name:"混沌珠",hp:36000,hpPct:30,dmgReduce:12,dmgBonus:12,attack:2800,defense:3200,levelReq:185,quality:9,iconIdx:25};
         _data["proto_4_88"]={slot:3,name:"贪狼令",hp:55000,hpPct:40,critRate:30,critDmg:30,attack:4000,defense:4800,levelReq:200,quality:10,iconIdx:28};
         _data["proto_4_89"]={slot:3,name:"轮回印",hp:45000,hpPct:35,dmgReduce:18,lifesteal:15,attack:3200,defense:3800,levelReq:180,quality:10,iconIdx:29};

         // 头盔 (slot=4) Q1-10+特殊  icon:4灵蛇/3混沌/2天尊/1九龙
         _data["proto_4_55"]={slot:4,name:"布帽",hp:140,defense:18,levelReq:5,quality:1,iconIdx:4};
         _data["proto_4_56"]={slot:4,name:"铁盔",hp:400,defense:48,levelReq:20,quality:2,iconIdx:4};
         _data["proto_4_57"]={slot:4,name:"银盔",hp:780,defense:95,levelReq:35,quality:3,iconIdx:4};
         _data["proto_4_58"]={slot:4,name:"金冠",hp:1300,hpPct:4,defense:165,levelReq:55,quality:4,iconIdx:3};
         _data["proto_4_59"]={slot:4,name:"龙盔",hp:2100,hpPct:7,dmgReduce:4,defense:270,levelReq:75,quality:5,iconIdx:3};
         _data["proto_4_60"]={slot:4,name:"灵蛇盔",hp:3300,hpPct:10,dmgReduce:6,defense:420,levelReq:100,quality:6,iconIdx:3};
         _data["proto_4_61"]={slot:4,name:"天尊冠",hp:14000,hpPct:20,defense:1800,defensePct:8,levelReq:130,quality:7,iconIdx:2};
         _data["proto_4_62"]={slot:4,name:"九龙冠",hp:24000,hpPct:26,defense:2800,defensePct:12,levelReq:160,quality:8,iconIdx:1};
         _data["proto_4_90"]={slot:4,name:"混沌盔",hp:38000,hpPct:34,dmgReduce:16,defense:4000,levelReq:185,quality:9,iconIdx:2};
         _data["proto_4_91"]={slot:4,name:"洞察之眼",hp:55000,hpPct:42,critRate:30,critDmg:35,defense:5500,levelReq:200,quality:10,iconIdx:1};

         // 战靴 (slot=5) Q1-10+特殊  icon:5凌波/6虚空/7风云
         _data["proto_4_63"]={slot:5,name:"草鞋",defense:32,attack:8,hp:35,levelReq:8,quality:1,iconIdx:5};
         _data["proto_4_64"]={slot:5,name:"皮靴",defense:105,attack:22,hp:95,levelReq:20,quality:2,iconIdx:5};
         _data["proto_4_65"]={slot:5,name:"铁靴",defense:200,attack:48,hp:195,levelReq:35,quality:3,iconIdx:5};
         _data["proto_4_66"]={slot:5,name:"银靴",defense:320,defensePct:3,attack:85,hp:330,levelReq:55,quality:4,iconIdx:6};
         _data["proto_4_67"]={slot:5,name:"神行靴",defense:490,defensePct:6,critRate:20,critDmg:10,attack:140,hp:520,levelReq:75,quality:5,iconIdx:6};
         _data["proto_4_68"]={slot:5,name:"凌波靴",defense:720,defensePct:9,lifesteal:4,dmgBonus:3,attack:220,hp:800,levelReq:100,quality:6,iconIdx:6};
         _data["proto_4_69"]={slot:5,name:"追月靴",defense:2800,defensePct:18,critRate:20,attack:1000,hp:3400,levelReq:130,quality:7,iconIdx:7};
         _data["proto_4_70"]={slot:5,name:"风云靴",defense:4200,defensePct:24,dmgReduce:12,lifesteal:6,attack:1600,hp:5200,levelReq:160,quality:8,iconIdx:7};
         _data["proto_4_92"]={slot:5,name:"虚空靴",defense:6000,defensePct:32,dmgReduce:18,critRate:25,attack:2400,hp:7200,levelReq:185,quality:9,iconIdx:7};
         _data["proto_4_93"]={slot:5,name:"破灭靴",defense:8500,defensePct:40,dmgReduce:24,critDmg:35,attack:3500,hp:10000,levelReq:200,quality:10,iconIdx:7};
         _data["proto_4_94"]={slot:5,name:"疾风之足",defense:6500,defensePct:30,critRate:30,critDmg:40,attack:2600,hp:7800,levelReq:170,quality:10,iconIdx:7};

         // 饰品 (slot=3) Q1-10  饰品Ⅰ+饰品Ⅱ合并
         _data["proto_4_71"]={slot:3,name:"铜戒指",attack:55,defense:12,hp:70,levelReq:12,quality:1,iconIdx:30};
         _data["proto_4_72"]={slot:3,name:"银戒指",attack:125,defense:28,hp:170,levelReq:28,quality:2,iconIdx:27};
         _data["proto_4_73"]={slot:3,name:"金戒指",attack:220,defense:55,hp:330,levelReq:45,quality:3,iconIdx:22};
         _data["proto_4_74"]={slot:3,name:"龙戒",attack:350,attackPct:4,defense:95,hp:550,levelReq:65,quality:4,iconIdx:22};
         _data["proto_4_75"]={slot:3,name:"神戒",attack:540,attackPct:8,lifesteal:5,defense:160,hp:880,levelReq:95,quality:5,iconIdx:24};
         _data["proto_4_76"]={slot:3,name:"乾坤圈",attack:800,attackPct:12,critRate:30,critDmg:15,defense:260,hp:1400,levelReq:140,quality:6,iconIdx:23};
         _data["proto_4_95"]={slot:3,name:"破军环",attack:3000,attackPct:22,critRate:25,defense:1100,hp:5800,levelReq:160,quality:7,iconIdx:21};
         _data["proto_4_96"]={slot:3,name:"贪狼令",attack:4200,attackPct:28,dmgBonus:12,lifesteal:10,defense:1600,hp:8200,levelReq:180,quality:8,iconIdx:26};
         _data["proto_4_97"]={slot:3,name:"星辰令",attack:6000,attackPct:35,critRate:30,critDmg:30,defense:2200,hp:11500,levelReq:195,quality:9,iconIdx:25};
         _data["proto_4_98"]={slot:3,name:"轮回印",attack:8500,attackPct:42,dmgReduce:16,lifesteal:15,defense:3200,hp:15500,levelReq:200,quality:10,iconIdx:29};
      }
      // 兼容旧装备码(proto_4_1~30) → 映射到新数据
      private static var _compat:Object = {
         "proto_4_1":"proto_4_31","proto_4_2":"proto_4_32","proto_4_3":"proto_4_33","proto_4_4":"proto_4_34","proto_4_5":"proto_4_35",
         "proto_4_11":"proto_4_39","proto_4_12":"proto_4_40","proto_4_13":"proto_4_41","proto_4_14":"proto_4_42","proto_4_15":"proto_4_43",
         "proto_4_21":"proto_4_47","proto_4_22":"proto_4_48","proto_4_23":"proto_4_49","proto_4_24":"proto_4_50","proto_4_25":"proto_4_51",
         "proto_4_6":"proto_4_55","proto_4_7":"proto_4_56","proto_4_8":"proto_4_57","proto_4_9":"proto_4_58","proto_4_10":"proto_4_59",
         "proto_4_16":"proto_4_63","proto_4_17":"proto_4_64","proto_4_18":"proto_4_65","proto_4_19":"proto_4_66","proto_4_20":"proto_4_67",
         "proto_4_26":"proto_4_71","proto_4_27":"proto_4_72","proto_4_28":"proto_4_73","proto_4_29":"proto_4_74","proto_4_30":"proto_4_75"
      };
      public static function get(c:String,k:String):* {
         init();
         var _r:Object = _data[c];
         if(!_r && _compat[c]) _r = _data[_compat[c]];
         return (_r && _r[k] != undefined) ? _r[k] : null;
      }
      public static function getBySlot(s:int):Array { init(); var a:Array=[]; for(var k:String in _data) if(_data[k].slot==s) a.push(k); return a; }
      public static function getAllCodes():Array { init(); var a:Array=[]; for(var k:String in _data) a.push(k); return a; }
      public static function getShopEquipItems():Array { return []; /* 装备改为通关掉落
      OLD:
         {id:"shop046",name:"铁剑",category:5,code:"proto_4_31",count:1,payType:2,oldPrice:100,newPrice:50,icon:"proto_3_4",desc:"武器 Lv1"},
         {id:"shop047",name:"精钢剑",category:5,code:"proto_4_32",count:1,payType:2,oldPrice:300,newPrice:150,icon:"proto_3_4",desc:"武器 Lv15"},
         {id:"shop048",name:"青釭剑",category:5,code:"proto_4_33",count:1,payType:2,oldPrice:600,newPrice:300,icon:"proto_3_4",desc:"武器 Lv30"},
         {id:"shop049",name:"倚天剑",category:5,code:"proto_4_34",count:1,payType:2,oldPrice:1200,newPrice:600,icon:"proto_3_4",desc:"武器 Lv50"},
         {id:"shop050",name:"方天画戟",category:5,code:"proto_4_35",count:1,payType:2,oldPrice:3000,newPrice:1500,icon:"proto_3_4",desc:"武器 Lv80"},
         {id:"shop051",name:"皮甲",category:5,code:"proto_4_39",count:1,payType:2,oldPrice:80,newPrice:40,icon:"proto_3_4",desc:"护甲 Lv8"},
         {id:"shop052",name:"锁子甲",category:5,code:"proto_4_40",count:1,payType:2,oldPrice:240,newPrice:120,icon:"proto_3_4",desc:"护甲 Lv20"},
         {id:"shop053",name:"明光铠",category:5,code:"proto_4_41",count:1,payType:2,oldPrice:500,newPrice:250,icon:"proto_3_4",desc:"护甲 Lv35"},
         {id:"shop054",name:"龙鳞甲",category:5,code:"proto_4_42",count:1,payType:2,oldPrice:1000,newPrice:500,icon:"proto_3_4",desc:"护甲 Lv55"},
         {id:"shop055",name:"玄武战甲",category:5,code:"proto_4_43",count:1,payType:2,oldPrice:2500,newPrice:1200,icon:"proto_3_4",desc:"护甲 Lv75"},
         {id:"shop056",name:"木符",category:5,code:"proto_4_47",count:1,payType:2,oldPrice:120,newPrice:60,icon:"proto_3_4",desc:"饰品 Lv10"},
         {id:"shop057",name:"翡翠环",category:5,code:"proto_4_48",count:1,payType:2,oldPrice:360,newPrice:180,icon:"proto_3_4",desc:"饰品 Lv25"},
         {id:"shop058",name:"护心镜",category:5,code:"proto_4_49",count:1,payType:2,oldPrice:700,newPrice:350,icon:"proto_3_4",desc:"饰品 Lv40"},
         {id:"shop059",name:"和氏璧",category:5,code:"proto_4_50",count:1,payType:2,oldPrice:1500,newPrice:800,icon:"proto_3_4",desc:"饰品 Lv60"},
         {id:"shop060",name:"天地令",category:5,code:"proto_4_51",count:1,payType:2,oldPrice:5000,newPrice:2500,icon:"proto_3_4",desc:"饰品 Lv80"},
         {id:"shop061",name:"布帽",category:5,code:"proto_4_55",count:1,payType:2,oldPrice:60,newPrice:30,icon:"proto_3_4",desc:"头盔 Lv5"},
         {id:"shop062",name:"铁盔",category:5,code:"proto_4_56",count:1,payType:2,oldPrice:200,newPrice:100,icon:"proto_3_4",desc:"头盔 Lv20"},
         {id:"shop063",name:"银盔",category:5,code:"proto_4_57",count:1,payType:2,oldPrice:450,newPrice:220,icon:"proto_3_4",desc:"头盔 Lv35"},
         {id:"shop064",name:"金冠",category:5,code:"proto_4_58",count:1,payType:2,oldPrice:900,newPrice:450,icon:"proto_3_4",desc:"头盔 Lv55"},
         {id:"shop065",name:"龙盔",category:5,code:"proto_4_59",count:1,payType:2,oldPrice:2000,newPrice:1000,icon:"proto_3_4",desc:"头盔 Lv75"},
         {id:"shop066",name:"草鞋",category:5,code:"proto_4_63",count:1,payType:2,oldPrice:50,newPrice:25,icon:"proto_3_4",desc:"战靴 Lv8"},
         {id:"shop067",name:"皮靴",category:5,code:"proto_4_64",count:1,payType:2,oldPrice:180,newPrice:90,icon:"proto_3_4",desc:"战靴 Lv20"},
         {id:"shop068",name:"铁靴",category:5,code:"proto_4_65",count:1,payType:2,oldPrice:400,newPrice:200,icon:"proto_3_4",desc:"战靴 Lv35"},
         {id:"shop069",name:"银靴",category:5,code:"proto_4_66",count:1,payType:2,oldPrice:800,newPrice:400,icon:"proto_3_4",desc:"战靴 Lv55"},
         {id:"shop070",name:"神行靴",category:5,code:"proto_4_67",count:1,payType:2,oldPrice:1800,newPrice:900,icon:"proto_3_4",desc:"战靴 Lv75"},
         {id:"shop071",name:"铜戒指",category:5,code:"proto_4_71",count:1,payType:2,oldPrice:80,newPrice:40,icon:"proto_3_4",desc:"饰品Ⅱ Lv12"},
         {id:"shop072",name:"银戒指",category:5,code:"proto_4_72",count:1,payType:2,oldPrice:250,newPrice:120,icon:"proto_3_4",desc:"饰品Ⅱ Lv28"},
         {id:"shop073",name:"金戒指",category:5,code:"proto_4_73",count:1,payType:2,oldPrice:550,newPrice:280,icon:"proto_3_4",desc:"饰品Ⅱ Lv45"},
         {id:"shop074",name:"龙戒",category:5,code:"proto_4_74",count:1,payType:2,oldPrice:1100,newPrice:550,icon:"proto_3_4",desc:"饰品Ⅱ Lv65"},
         {id:"shop075",name:"神戒",category:5,code:"proto_4_75",count:1,payType:2,oldPrice:2500,newPrice:1200,icon:"proto_3_4",desc:"饰品Ⅱ Lv95"}
      ];*/ }
   }
}
