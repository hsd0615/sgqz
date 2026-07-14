package game.model {
   public class EquipData {
      private static var _data:Object = {};
      private static function init():void {
         if(_data["proto_4_31"]!=null) return;

         // iconIdx: 头盔1-4,战靴5-7,护甲8-10,武器11-20,饰品21-30
         // ====== 基础装备 proto_4_1~30 (与31+重复code, 服务端兼容) ======
         // 武器 Q1-5
         _data["proto_4_1"]={slot:1,name:"铁剑",attack:20,levelReq:1,quality:1,iconIdx:18};
         _data["proto_4_2"]={slot:1,name:"精钢剑",attack:67,levelReq:15,quality:2,iconIdx:17};
         _data["proto_4_3"]={slot:1,name:"青釭剑",attack:126,levelReq:30,quality:3,iconIdx:19};
         _data["proto_4_4"]={slot:1,name:"倚天剑",attack:209,attackPct:4,levelReq:50,quality:4,iconIdx:12};
         _data["proto_4_5"]={slot:1,name:"方天画戟",attack:323,attackPct:7,levelReq:80,quality:5,iconIdx:14};
         // 头盔 Q1-5
         _data["proto_4_6"]={slot:4,name:"布帽",hp:20,levelReq:5,quality:1,iconIdx:1};
         _data["proto_4_7"]={slot:4,name:"铁盔",hp:88,levelReq:18,quality:2,iconIdx:1};
         _data["proto_4_8"]={slot:4,name:"银盔",hp:171,levelReq:35,quality:3,iconIdx:2};
         _data["proto_4_9"]={slot:4,name:"金冠",hp:728,hpPct:4,levelReq:55,quality:4,iconIdx:3};
         _data["proto_4_10"]={slot:4,name:"龙盔",hp:1461,hpPct:5,levelReq:75,quality:5,iconIdx:3};
         // 铠甲 Q1-5
         _data["proto_4_11"]={slot:2,name:"皮甲",defense:20,levelReq:8,quality:1,iconIdx:9};
         _data["proto_4_12"]={slot:2,name:"锁子甲",defense:68,levelReq:20,quality:2,iconIdx:9};
         _data["proto_4_13"]={slot:2,name:"明光铠",defense:141,levelReq:35,quality:3,iconIdx:9};
         _data["proto_4_14"]={slot:2,name:"龙鳞甲",defense:221,defensePct:3,levelReq:55,quality:4,iconIdx:8};
         _data["proto_4_15"]={slot:2,name:"玄武战甲",defense:323,defensePct:6,dmgReduce:1,levelReq:75,quality:5,iconIdx:8};
         // 战靴 Q1-5
         _data["proto_4_16"]={slot:5,name:"草鞋",levelReq:3,quality:1,iconIdx:5};
         _data["proto_4_17"]={slot:5,name:"皮靴",defense:14,levelReq:16,quality:2,iconIdx:5};
         _data["proto_4_18"]={slot:5,name:"铁靴",defense:31,levelReq:32,quality:3,iconIdx:6};
         _data["proto_4_19"]={slot:5,name:"银靴",defense:58,levelReq:50,quality:4,iconIdx:6};
         _data["proto_4_20"]={slot:5,name:"神行靴",defense:84,levelReq:70,quality:5,iconIdx:7};
         // 饰品I Q1-5
         _data["proto_4_21"]={slot:3,name:"木符",dmgBonus:3,levelReq:1,quality:1,iconIdx:30};
         _data["proto_4_22"]={slot:3,name:"翡翠环",dmgBonus:5,levelReq:18,quality:2,iconIdx:27};
         _data["proto_4_23"]={slot:3,name:"护心镜",dmgBonus:6,levelReq:35,quality:3,iconIdx:27};
         _data["proto_4_24"]={slot:3,name:"和氏璧",dmgBonus:8,lifesteal:3,levelReq:55,quality:4,iconIdx:22};
         _data["proto_4_25"]={slot:3,name:"天地令",dmgBonus:10,lifesteal:6,levelReq:80,quality:5,iconIdx:24};
         // 饰品II Q1-5
         _data["proto_4_26"]={slot:3,name:"铜戒指",dmgBonus:4,levelReq:12,quality:1,iconIdx:30};
         _data["proto_4_27"]={slot:3,name:"银戒指",dmgBonus:6,levelReq:28,quality:2,iconIdx:27};
         _data["proto_4_28"]={slot:3,name:"金戒指",dmgBonus:8,levelReq:45,quality:3,iconIdx:22};
         _data["proto_4_29"]={slot:3,name:"龙戒",dmgBonus:10,lifesteal:5,levelReq:65,quality:4,iconIdx:22};
         _data["proto_4_30"]={slot:3,name:"神戒",dmgBonus:12,lifesteal:8,levelReq:95,quality:5,iconIdx:24};

         // 武器 (slot=1) Q1-10+特殊
         _data["proto_4_31"]={slot:1,name:"铁剑",attack:20,levelReq:1,quality:1,iconIdx:18};
         _data["proto_4_32"]={slot:1,name:"精钢剑",attack:67,levelReq:15,quality:2,iconIdx:17};
         _data["proto_4_33"]={slot:1,name:"青釭剑",attack:126,levelReq:30,quality:3,iconIdx:19};
         _data["proto_4_34"]={slot:1,name:"倚天剑",attack:209,attackPct:4,levelReq:50,quality:4,iconIdx:12};
         _data["proto_4_35"]={slot:1,name:"方天画戟",attack:323,attackPct:7,levelReq:80,quality:5,iconIdx:14};
         _data["proto_4_36"]={slot:1,name:"青龙偃月",attack:447,attackPct:9,critRate:4,critDmg:3,levelReq:100,quality:6,iconIdx:20};
         _data["proto_4_37"]={slot:1,name:"丈八蛇矛",attack:1237,attackPct:15,dmgBonus:2,levelReq:130,quality:7,iconIdx:11};
         _data["proto_4_38"]={slot:1,name:"神罚",attack:1972,attackPct:20,dmgBonus:2,lifesteal:2,levelReq:160,quality:8,iconIdx:16};
         _data["proto_4_81"]={slot:1,name:"寒月刀",attack:2817,attackPct:25,lifesteal:3,levelReq:185,quality:9,iconIdx:13};
         _data["proto_4_82"]={slot:1,name:"灭世",attack:3944,attackPct:30,critRate:6,dmgBonus:3,levelReq:200,quality:10,iconIdx:15};
         _data["proto_4_83"]={slot:1,name:"血祭之刃",attack:3099,attackPct:28,dmgBonus:3,lifesteal:5,levelReq:170,quality:10,iconIdx:15};

         // 铠甲 (slot=2) Q1-10+特殊  icon:9皮甲/8玄武/10麒麟
         _data["proto_4_39"]={slot:2,name:"皮甲",defense:20,levelReq:8,quality:1,iconIdx:9};
         _data["proto_4_40"]={slot:2,name:"锁子甲",defense:68,levelReq:20,quality:2,iconIdx:9};
         _data["proto_4_41"]={slot:2,name:"明光铠",defense:141,levelReq:35,quality:3,iconIdx:9};
         _data["proto_4_42"]={slot:2,name:"龙鳞甲",defense:221,defensePct:3,levelReq:55,quality:4,iconIdx:8};
         _data["proto_4_43"]={slot:2,name:"玄武战甲",defense:323,defensePct:6,dmgReduce:1,levelReq:75,quality:5,iconIdx:8};
         _data["proto_4_44"]={slot:2,name:"麒麟铠",defense:470,defensePct:9,dmgReduce:2,levelReq:100,quality:6,iconIdx:10};
         _data["proto_4_45"]={slot:2,name:"朱雀战袍",defense:1237,defensePct:16,dmgReduce:3,levelReq:130,quality:7,iconIdx:10};
         _data["proto_4_46"]={slot:2,name:"不灭金身",defense:2250,defensePct:22,dmgReduce:4,levelReq:160,quality:8,iconIdx:10};
         _data["proto_4_84"]={slot:2,name:"龙纹战甲",defense:3239,defensePct:28,dmgReduce:5,levelReq:185,quality:9,iconIdx:10};
         _data["proto_4_85"]={slot:2,name:"万古不朽",defense:4569,defensePct:35,dmgReduce:5,levelReq:200,quality:10,iconIdx:10};
         _data["proto_4_86"]={slot:2,name:"荆棘反甲",defense:3156,defensePct:25,dmgReduce:3,levelReq:170,quality:10,iconIdx:10};

         // 饰品 (slot=3) Q1-10+特殊  icon:30铜戒指/27翡翠/22和氏璧/24天地/23嗜血/21七杀/26紫微/25混沌/28贪狼/29轮回
         _data["proto_4_47"]={slot:3,name:"木符",dmgBonus:3,levelReq:10,quality:1,iconIdx:30};
         _data["proto_4_48"]={slot:3,name:"翡翠环",dmgBonus:5,levelReq:25,quality:2,iconIdx:27};
         _data["proto_4_49"]={slot:3,name:"护心镜",dmgBonus:6,levelReq:40,quality:3,iconIdx:22};
         _data["proto_4_50"]={slot:3,name:"和氏璧",dmgBonus:8,lifesteal:3,levelReq:60,quality:4,iconIdx:22};
         _data["proto_4_51"]={slot:3,name:"天地令",dmgBonus:10,lifesteal:6,levelReq:80,quality:5,iconIdx:24};
         _data["proto_4_52"]={slot:3,name:"嗜血魔符",critRate:18,critDmg:12,dmgBonus:6,levelReq:105,quality:6,iconIdx:23};
         _data["proto_4_53"]={slot:3,name:"七杀戒",critRate:24,critDmg:20,levelReq:135,quality:7,iconIdx:21};
         _data["proto_4_54"]={slot:3,name:"紫微星",dmgBonus:18,dmgReduce:10,lifesteal:15,levelReq:165,quality:8,iconIdx:26};
         _data["proto_4_87"]={slot:3,name:"混沌珠",dmgBonus:22,dmgReduce:15,lifesteal:12,levelReq:185,quality:9,iconIdx:25};
         _data["proto_4_88"]={slot:3,name:"贪狼令",critRate:30,critDmg:35,dmgBonus:15,levelReq:200,quality:10,iconIdx:28};
         _data["proto_4_89"]={slot:3,name:"轮回印",dmgBonus:15,dmgReduce:20,lifesteal:20,levelReq:180,quality:10,iconIdx:29};

         // 头盔 (slot=4) Q1-10+特殊  icon:4灵蛇/3混沌/2天尊/1九龙
         _data["proto_4_55"]={slot:4,name:"布帽",hp:68,levelReq:5,quality:1,iconIdx:4};
         _data["proto_4_56"]={slot:4,name:"铁盔",hp:221,levelReq:20,quality:2,iconIdx:4};
         _data["proto_4_57"]={slot:4,name:"银盔",hp:434,levelReq:35,quality:3,iconIdx:4};
         _data["proto_4_58"]={slot:4,name:"金冠",hp:728,hpPct:4,levelReq:55,quality:4,iconIdx:3};
         _data["proto_4_59"]={slot:4,name:"龙盔",hp:1180,hpPct:7,dmgReduce:1,levelReq:75,quality:5,iconIdx:3};
         _data["proto_4_60"]={slot:4,name:"灵蛇盔",hp:1856,hpPct:10,dmgReduce:1,levelReq:100,quality:6,iconIdx:3};
         _data["proto_4_61"]={slot:4,name:"天尊冠",hp:7896,hpPct:20,levelReq:130,quality:7,iconIdx:2};
         _data["proto_4_62"]={slot:4,name:"九龙冠",hp:13540,hpPct:26,levelReq:160,quality:8,iconIdx:1};
         _data["proto_4_90"]={slot:4,name:"混沌盔",hp:21443,hpPct:34,dmgReduce:4,levelReq:185,quality:9,iconIdx:2};
         _data["proto_4_91"]={slot:4,name:"洞察之眼",hp:31040,hpPct:42,critRate:6,critDmg:8,levelReq:200,quality:10,iconIdx:1};

         // 战靴 (slot=5) Q1-10+特殊  icon:5凌波/6虚空/7风云
         _data["proto_4_63"]={slot:5,name:"草鞋",defense:14,levelReq:8,quality:1,iconIdx:5};
         _data["proto_4_64"]={slot:5,name:"皮靴",defense:67,levelReq:20,quality:2,iconIdx:5};
         _data["proto_4_65"]={slot:5,name:"铁靴",defense:135,levelReq:35,quality:3,iconIdx:5};
         _data["proto_4_66"]={slot:5,name:"银靴",defense:221,defensePct:3,levelReq:55,quality:4,iconIdx:6};
         _data["proto_4_67"]={slot:5,name:"神行靴",defense:345,defensePct:6,critRate:5,critDmg:2,levelReq:75,quality:5,iconIdx:6};
         _data["proto_4_68"]={slot:5,name:"凌波靴",defense:520,defensePct:9,lifesteal:1,levelReq:100,quality:6,iconIdx:6};
         _data["proto_4_69"]={slot:5,name:"追月靴",defense:2141,defensePct:18,critRate:5,levelReq:130,quality:7,iconIdx:7};
         _data["proto_4_70"]={slot:5,name:"风云靴",defense:3269,defensePct:24,dmgReduce:3,lifesteal:1,levelReq:160,quality:8,iconIdx:7};
         _data["proto_4_92"]={slot:5,name:"虚空靴",defense:4734,defensePct:32,critRate:6,dmgReduce:4,levelReq:185,quality:9,iconIdx:7};
         _data["proto_4_93"]={slot:5,name:"破灭靴",defense:6769,defensePct:40,critDmg:8,dmgReduce:5,levelReq:200,quality:10,iconIdx:7};
         _data["proto_4_94"]={slot:5,name:"疾风之足",defense:5129,defensePct:30,critRate:6,critDmg:8,levelReq:170,quality:10,iconIdx:7};

         // 饰品 (slot=3) Q1-10  饰品Ⅰ+饰品Ⅱ合并
         _data["proto_4_71"]={slot:3,name:"铜戒指",dmgBonus:4,levelReq:12,quality:1,iconIdx:30};
         _data["proto_4_72"]={slot:3,name:"银戒指",dmgBonus:6,levelReq:28,quality:2,iconIdx:27};
         _data["proto_4_73"]={slot:3,name:"金戒指",dmgBonus:8,levelReq:45,quality:3,iconIdx:22};
         _data["proto_4_74"]={slot:3,name:"龙戒",dmgBonus:10,lifesteal:5,levelReq:65,quality:4,iconIdx:22};
         _data["proto_4_75"]={slot:3,name:"神戒",dmgBonus:12,lifesteal:8,levelReq:95,quality:5,iconIdx:24};
         _data["proto_4_76"]={slot:3,name:"乾坤圈",critRate:15,critDmg:15,levelReq:140,quality:6,iconIdx:23};
         _data["proto_4_95"]={slot:3,name:"破军环",critRate:20,critDmg:20,levelReq:160,quality:7,iconIdx:21};
         _data["proto_4_96"]={slot:3,name:"贪狼令",critRate:15,dmgBonus:15,lifesteal:12,levelReq:180,quality:8,iconIdx:26};
         _data["proto_4_97"]={slot:3,name:"星辰令",critRate:18,dmgBonus:18,lifesteal:15,levelReq:195,quality:9,iconIdx:25};
         _data["proto_4_98"]={slot:3,name:"轮回印",dmgBonus:15,dmgReduce:20,lifesteal:20,levelReq:200,quality:10,iconIdx:29};

         // ====== 烈焰系列 Q9 (Lv185) ======
         _data["proto_4_101"]={slot:1,name:"焚天刃",attack:3050,attackPct:28,critRate:10,critDmg:8,dmgBonus:5,levelReq:185,quality:9,iconIdx:31};
         _data["proto_4_102"]={slot:2,name:"烈焰战甲",attack:800,attackPct:10,defense:2400,defensePct:22,dmgReduce:3,levelReq:185,quality:9,iconIdx:32};
         _data["proto_4_103"]={slot:3,name:"烈焰之心",dmgBonus:25,critDmg:20,critRate:8,levelReq:185,quality:9,iconIdx:33};

         // ====== 冰霜系列 Q9 (Lv185) ======
         _data["proto_4_106"]={slot:1,name:"霜华剑",attack:2700,attackPct:24,lifesteal:8,dmgReduce:5,levelReq:185,quality:9,iconIdx:34};
         _data["proto_4_107"]={slot:2,name:"冰霜壁垒",defense:3400,defensePct:30,hp:3000,dmgReduce:8,levelReq:185,quality:9,iconIdx:35};
         _data["proto_4_108"]={slot:3,name:"冰晶之魂",dmgReduce:18,lifesteal:15,hpPct:10,levelReq:185,quality:9,iconIdx:36};

         // ====== 雷霆系列 Q10 (Lv200) ======
         _data["proto_4_111"]={slot:1,name:"雷霆战戟",attack:4200,attackPct:32,critRate:14,critDmg:18,levelReq:200,quality:10,iconIdx:37};
         _data["proto_4_112"]={slot:2,name:"雷霆神甲",defense:4300,defensePct:33,dmgReduce:6,critRate:7,levelReq:200,quality:10,iconIdx:38};
         _data["proto_4_113"]={slot:3,name:"雷霆之怒",critRate:28,critDmg:38,dmgBonus:18,levelReq:200,quality:10,iconIdx:39};
         _data["proto_4_114"]={slot:4,name:"雷霆冠冕",hp:26500,hpPct:38,critRate:10,critDmg:12,levelReq:200,quality:10,iconIdx:40};
         _data["proto_4_115"]={slot:5,name:"雷霆战靴",defense:6000,defensePct:36,critRate:7,critDmg:15,levelReq:200,quality:10,iconIdx:41};

         // ====== 魔系列 Q11 ★魔器★ (Lv210) ======
         _data["proto_4_121"]={slot:1,name:"魔渊·噬",attack:0,attackPct:0,hp:-5000,hpPct:-25,critRate:18,critDmg:25,dmgBonus:40,lifesteal:10,levelReq:210,quality:11,iconIdx:51};
         _data["proto_4_122"]={slot:2,name:"魔渊·怨",attack:3500,attackPct:18,defense:-800,defensePct:-22,critRate:12,dmgReduce:-8,levelReq:210,quality:11,iconIdx:52};
         _data["proto_4_123"]={slot:3,name:"魔渊·嗜",defense:-500,hpPct:-20,dmgBonus:20,critDmg:18,lifesteal:45,levelReq:210,quality:11,iconIdx:53};
         _data["proto_4_124"]={slot:4,name:"魔渊·妄",defense:-600,hp:45000,hpPct:55,dmgBonus:12,critRate:10,dmgReduce:-8,levelReq:210,quality:11,iconIdx:54};
         _data["proto_4_125"]={slot:5,name:"魔渊·疾",defense:3500,defensePct:20,hpPct:-15,critRate:12,critDmg:15,dmgReduce:-5,atkInterval:-28,levelReq:210,quality:11,iconIdx:55};
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
