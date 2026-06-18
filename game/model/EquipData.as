package game.model
{
   public class EquipData
   {
      private static var _data:Object = {};

      private static function init() : void
      {
         if(_data["proto_4_1"] != null) return;

         // ═══════════ 武器 (slot=1) ═══════════
         _data["proto_4_1"]  = {slot:1,name:"铁剑",    attack:50,defense:8,hp:0,levelReq:1,quality:1,iconIdx:1};
         _data["proto_4_2"]  = {slot:1,name:"精钢剑",  attack:130,defense:20,hp:30,levelReq:15,quality:2,iconIdx:2};
         _data["proto_4_3"]  = {slot:1,name:"青釭剑",  attack:240,defense:40,hp:60,levelReq:30,quality:3,iconIdx:3};
         _data["proto_4_4"]  = {slot:1,name:"倚天剑",  attack:380,attackPct:4,defense:70,hp:110,levelReq:50,quality:4,iconIdx:4};
         _data["proto_4_5"]  = {slot:1,name:"方天画戟",attack:580,attackPct:7,defense:120,hp:190,levelReq:80,quality:5,iconIdx:5};
         _data["proto_4_31"] = {slot:1,name:"柳叶刀",  attack:70,defense:12,hp:25,levelReq:8,quality:1,iconIdx:1};
         _data["proto_4_32"] = {slot:1,name:"雁翎刀",  attack:160,defense:28,hp:60,levelReq:20,quality:2,iconIdx:2};
         _data["proto_4_33"] = {slot:1,name:"鱼鳞刀",  attack:270,defense:52,hp:110,levelReq:35,quality:3,iconIdx:3};
         _data["proto_4_34"] = {slot:1,name:"金背刀",  attack:420,attackPct:3,defense:85,hp:180,levelReq:55,quality:4,iconIdx:4};
         // Q5传说: 吸血+增伤
         _data["proto_4_35"] = {slot:1,name:"斩马刀",  attack:550,attackPct:7,lifesteal:5,dmgBonus:3,defense:80,hp:200,levelReq:75,quality:5,iconIdx:5};
         // Q6神话: 暴击
         _data["proto_4_36"] = {slot:1,name:"青龙偃月",attack:780,attackPct:9,critRate:8,critDmg:15,defense:160,hp:380,levelReq:100,quality:6,iconIdx:6};
         // Q7远古: 狂暴型(极高攻击,降低防御)
         _data["proto_4_37"] = {slot:1,name:"丈八蛇矛",attack:1400,attackPct:14,dmgBonus:8,defense:-80,defensePct:-5,hp:-100,levelReq:130,quality:7,iconIdx:7};
         // Q8至尊: 均衡全能
         _data["proto_4_38"] = {slot:1,name:"神罚",    attack:1800,attackPct:15,lifesteal:8,dmgBonus:6,defense:500,defensePct:5,hp:1100,hpPct:6,levelReq:160,quality:8,iconIdx:8};

         // ═══════════ 铠甲 (slot=2) ═══════════
         _data["proto_4_11"] = {slot:2,name:"皮甲",    defense:35,attack:10,hp:15,levelReq:1,quality:1,iconIdx:9};
         _data["proto_4_12"] = {slot:2,name:"锁子甲",  defense:110,attack:25,hp:50,levelReq:15,quality:2,iconIdx:10};
         _data["proto_4_13"] = {slot:2,name:"明光铠",  defense:200,attack:50,hp:100,levelReq:30,quality:3,iconIdx:11};
         _data["proto_4_14"] = {slot:2,name:"龙鳞甲",  defense:310,defensePct:4,attack:85,hp:180,levelReq:50,quality:4,iconIdx:12};
         _data["proto_4_15"] = {slot:2,name:"玄武战甲",defense:480,defensePct:6,attack:140,hp:300,levelReq:80,quality:5,iconIdx:13};
         _data["proto_4_39"] = {slot:2,name:"藤甲",    defense:48,attack:12,hp:22,levelReq:8,quality:1,iconIdx:9};
         _data["proto_4_40"] = {slot:2,name:"铁叶甲",  defense:130,attack:30,hp:65,levelReq:20,quality:2,iconIdx:10};
         _data["proto_4_41"] = {slot:2,name:"连环甲",  defense:235,attack:60,hp:130,levelReq:35,quality:3,iconIdx:11};
         _data["proto_4_42"] = {slot:2,name:"犀牛甲",  defense:360,defensePct:3,attack:100,hp:230,levelReq:55,quality:4,iconIdx:12};
         // Q5: 减伤型
         _data["proto_4_43"] = {slot:2,name:"狻猊甲",  defense:520,defensePct:6,dmgReduce:5,attack:130,hp:320,levelReq:75,quality:5,iconIdx:13};
         // Q6: 高减伤
         _data["proto_4_44"] = {slot:2,name:"麒麟铠",  defense:750,defensePct:9,dmgReduce:8,attack:200,hp:500,hpPct:4,levelReq:100,quality:6,iconIdx:14};
         // Q7: 磐石型(极高防御+HP,降低攻击)
         _data["proto_4_45"] = {slot:2,name:"朱雀战袍",defense:1200,defensePct:14,dmgReduce:10,attack:-60,hp:1000,hpPct:8,levelReq:130,quality:7,iconIdx:15};
         // Q8: 全能
         _data["proto_4_46"] = {slot:2,name:"不灭金身",defense:1600,defensePct:16,dmgReduce:12,lifesteal:3,attack:500,attackPct:4,hp:1300,hpPct:8,levelReq:160,quality:8,iconIdx:16};

         // ═══════════ 饰品Ⅰ (slot=3) ═══════════
         _data["proto_4_21"] = {slot:3,name:"木符",attack:18,attackPct:0,defense:25,defensePct:0,hp:320,hpPct:0,levelReq:10,quality:1,iconIdx:33};
         _data["proto_4_22"] = {slot:3,name:"翡翠环",  hp:550,attack:35,defense:50,levelReq:20,quality:2,iconIdx:34};
         _data["proto_4_23"] = {slot:3,name:"护心镜",  hp:1000,attack:65,defense:90,levelReq:35,quality:3,iconIdx:35};
         _data["proto_4_24"] = {slot:3,name:"和氏璧",  hp:1700,hpPct:4,attack:110,attackPct:3,defense:150,defensePct:2,levelReq:55,quality:4,iconIdx:36};
         _data["proto_4_25"] = {slot:3,name:"传国玉玺",hp:2800,hpPct:6,attack:180,attackPct:5,defense:250,defensePct:4,levelReq:100,quality:5,iconIdx:37};
         _data["proto_4_47"] = {slot:3,name:"木符",attack:18,attackPct:0,defense:25,defensePct:0,hp:320,hpPct:0,levelReq:10,quality:1,iconIdx:33};
         _data["proto_4_48"] = {slot:3,name:"石符",    hp:700,attack:42,defense:60,levelReq:25,quality:2,iconIdx:34};
         _data["proto_4_49"] = {slot:3,name:"铜符",    hp:1250,attack:80,defense:110,levelReq:40,quality:3,iconIdx:35};
         _data["proto_4_50"] = {slot:3,name:"银符",    hp:2000,hpPct:4,attack:130,attackPct:2,defense:180,levelReq:60,quality:4,iconIdx:36};
         // Q5: 吸血型
         _data["proto_4_51"] = {slot:3,name:"金符",    hp:2800,hpPct:7,lifesteal:4,dmgBonus:2,attack:160,defense:220,levelReq:80,quality:5,iconIdx:37};
         // Q6: 暴击型
         _data["proto_4_52"] = {slot:3,name:"龙符",    hp:4300,hpPct:10,critRate:6,critDmg:12,attack:250,defense:360,levelReq:105,quality:6,iconIdx:38};
         // Q7: 增伤型(牺牲防御)
         _data["proto_4_53"] = {slot:3,name:"凤符",    hp:6500,hpPct:13,dmgBonus:12,attack:550,attackPct:9,defense:-50,levelReq:135,quality:7,iconIdx:39};
         // Q8: 全能
         _data["proto_4_54"] = {slot:3,name:"天地令",  hp:10000,hpPct:17,lifesteal:6,dmgBonus:5,attack:700,attackPct:10,defense:900,defensePct:7,levelReq:165,quality:8,iconIdx:40};

         // ═══════════ 头盔 (slot=4) ═══════════
         _data["proto_4_6"]  = {slot:4,name:"布帽",    hp:100,defense:12,levelReq:1,quality:1,iconIdx:17};
         _data["proto_4_7"]  = {slot:4,name:"铁盔",    hp:320,defense:35,levelReq:15,quality:2,iconIdx:18};
         _data["proto_4_8"]  = {slot:4,name:"银盔",    hp:650,defense:70,levelReq:30,quality:3,iconIdx:19};
         _data["proto_4_9"]  = {slot:4,name:"金冠",    hp:1100,hpPct:4,defense:120,levelReq:50,quality:4,iconIdx:20};
         _data["proto_4_10"] = {slot:4,name:"龙盔",    hp:1900,hpPct:7,defense:200,levelReq:80,quality:5,iconIdx:21};
         _data["proto_4_55"] = {slot:4,name:"方巾",    hp:140,defense:18,levelReq:5,quality:1,iconIdx:17};
         _data["proto_4_56"] = {slot:4,name:"铜冠",    hp:400,defense:48,levelReq:20,quality:2,iconIdx:18};
         _data["proto_4_57"] = {slot:4,name:"镔铁盔",  hp:780,defense:95,levelReq:35,quality:3,iconIdx:19};
         _data["proto_4_58"] = {slot:4,name:"凤翅冠",  hp:1300,hpPct:4,defense:165,levelReq:55,quality:4,iconIdx:20};
         // Q5: 减伤型
         _data["proto_4_59"] = {slot:4,name:"紫金冠",  hp:2000,hpPct:7,dmgReduce:4,defense:250,levelReq:75,quality:5,iconIdx:21};
         // Q6: 均衡
         _data["proto_4_60"] = {slot:4,name:"灵蛇盔",  hp:3200,hpPct:10,dmgReduce:6,defense:400,defensePct:2,levelReq:100,quality:6,iconIdx:22};
         // Q7: 磐石(高防+HP, 低攻)
         _data["proto_4_61"] = {slot:4,name:"虎头盔",  hp:5200,hpPct:14,defense:700,defensePct:4,dmgReduce:8,attack:-30,levelReq:130,quality:7,iconIdx:23};
         // Q8: 全能
         _data["proto_4_62"] = {slot:4,name:"九龙冠",  hp:7500,hpPct:17,defense:1000,defensePct:5,dmgReduce:10,levelReq:160,quality:8,iconIdx:24};

         // ═══════════ 战靴 (slot=5) ═══════════
         _data["proto_4_16"] = {slot:5,name:"草鞋",defense:22,attack:5,hp:25,levelReq:1,quality:1,iconIdx:25};
         _data["proto_4_17"] = {slot:5,name:"皮靴",defense:85,attack:15,hp:75,levelReq:15,quality:2,iconIdx:26};
         _data["proto_4_18"] = {slot:5,name:"铁靴",defense:165,attack:35,hp:150,levelReq:30,quality:3,iconIdx:27};
         _data["proto_4_19"] = {slot:5,name:"银靴",defense:260,defensePct:3,attack:65,hp:260,levelReq:50,quality:4,iconIdx:28};
         _data["proto_4_20"] = {slot:5,name:"神行靴",defense:400,defensePct:5,attack:110,hp:420,levelReq:80,quality:5,iconIdx:29};
         _data["proto_4_63"] = {slot:5,name:"草鞋",defense:22,attack:5,hp:25,levelReq:1,quality:1,iconIdx:25};
         _data["proto_4_64"] = {slot:5,name:"皮靴",defense:85,attack:15,hp:75,levelReq:15,quality:2,iconIdx:26};
         _data["proto_4_65"] = {slot:5,name:"铁靴",defense:165,attack:35,hp:150,levelReq:30,quality:3,iconIdx:27};
         _data["proto_4_66"] = {slot:5,name:"银靴",defense:260,defensePct:3,attack:65,hp:260,levelReq:50,quality:4,iconIdx:28};
         // Q5: 敏捷(暴击)
         _data["proto_4_67"] = {slot:5,name:"神行靴",defense:400,defensePct:5,attack:110,hp:420,levelReq:80,quality:5,iconIdx:29};
         // Q6: 吸血
         _data["proto_4_68"] = {slot:5,name:"凌波靴",defense:680,defensePct:8,lifesteal:4,dmgBonus:3,attack:200,hp:700,levelReq:100,quality:6,iconIdx:30};
         // Q7: 狂暴(高攻, 低防)
         _data["proto_4_69"] = {slot:5,name:"追月靴",attack:450,attackPct:8,critRate:8,defense:400,defensePct:3,hp:800,levelReq:130,quality:7,iconIdx:31};
         // Q8: 全能
         _data["proto_4_70"] = {slot:5,name:"风云靴",defense:1400,defensePct:15,dmgReduce:8,lifesteal:3,attack:450,attackPct:4,hp:1600,hpPct:6,levelReq:160,quality:8,iconIdx:32};

         // ═══════════ 饰品Ⅱ (slot=6) ═══════════
         _data["proto_4_26"] = {slot:6,name:"铜戒指",  attack:38,defense:8,hp:50,levelReq:10,quality:1,iconIdx:41};
         _data["proto_4_27"] = {slot:6,name:"银戒指",  attack:95,defense:20,hp:130,levelReq:25,quality:2,iconIdx:42};
         _data["proto_4_28"] = {slot:6,name:"金戒指",  attack:180,defense:40,hp:260,levelReq:40,quality:3,iconIdx:43};
         _data["proto_4_29"] = {slot:6,name:"龙戒",    attack:300,attackPct:4,defense:75,hp:440,levelReq:60,quality:4,iconIdx:44};
         _data["proto_4_30"] = {slot:6,name:"神戒",    attack:460,attackPct:7,defense:130,hp:700,levelReq:90,quality:5,iconIdx:45};
         _data["proto_4_71"] = {slot:6,name:"骨戒",    attack:55,defense:12,hp:70,levelReq:12,quality:1,iconIdx:41};
         _data["proto_4_72"] = {slot:6,name:"银环",    attack:125,defense:28,hp:170,levelReq:28,quality:2,iconIdx:42};
         _data["proto_4_73"] = {slot:6,name:"玉扳指",  attack:220,defense:55,hp:330,levelReq:45,quality:3,iconIdx:43};
         _data["proto_4_74"] = {slot:6,name:"血玉环",  attack:350,attackPct:4,defense:95,hp:550,levelReq:65,quality:4,iconIdx:44};
         // Q5: 吸血
         _data["proto_4_75"] = {slot:6,name:"龙环",    attack:500,attackPct:8,lifesteal:5,dmgBonus:2,defense:120,hp:750,levelReq:95,quality:5,iconIdx:45};
         // Q6: 暴击
         _data["proto_4_76"] = {slot:6,name:"乾坤圈",  attack:750,attackPct:12,critRate:7,critDmg:15,defense:200,hp:1200,hpPct:5,levelReq:140,quality:6,iconIdx:46};
      }

      public static function get(code:String, key:String) : *
      {
         init();
         if(_data[code] && _data[code][key] != undefined) return _data[code][key];
         return null;
      }

      public static function getBySlot(slot:int) : Array
      {
         init();
         var arr:Array = [];
         for(var k:String in _data) { if(_data[k].slot == slot) arr.push(k); }
         return arr;
      }

      public static function getAllCodes() : Array { init(); var a:Array=[]; for(var k:String in _data) a.push(k); return a; }

      public static function getShopEquipItems() : Array
      {
         return [
            {id:"shop046",name:"铁剑",category:5,code:"proto_4_1",count:1,payType:2,oldPrice:100,newPrice:50,icon:"proto_3_4",desc:"武器 攻+50防+8 Lv1"},
            {id:"shop047",name:"精钢剑",category:5,code:"proto_4_2",count:1,payType:2,oldPrice:300,newPrice:150,icon:"proto_3_4",desc:"武器 攻+130防+20HP+30 Lv15"},
            {id:"shop048",name:"青釭剑",category:5,code:"proto_4_3",count:1,payType:2,oldPrice:600,newPrice:300,icon:"proto_3_4",desc:"武器 攻+240防+40HP+60 Lv30"},
            {id:"shop049",name:"倚天剑",category:5,code:"proto_4_4",count:1,payType:2,oldPrice:1200,newPrice:600,icon:"proto_3_4",desc:"武器 攻+380+4% Lv50"},
            {id:"shop050",name:"方天画戟",category:5,code:"proto_4_5",count:1,payType:2,oldPrice:3000,newPrice:1500,icon:"proto_3_4",desc:"武器 攻+580+7% Lv80"},
            {id:"shop051",name:"皮甲",category:5,code:"proto_4_11",count:1,payType:2,oldPrice:80,newPrice:40,icon:"proto_3_4",desc:"防具 防+35攻+10HP+15 Lv1"},
            {id:"shop052",name:"锁子甲",category:5,code:"proto_4_12",count:1,payType:2,oldPrice:240,newPrice:120,icon:"proto_3_4",desc:"防具 防+110攻+25HP+50 Lv15"},
            {id:"shop053",name:"明光铠",category:5,code:"proto_4_13",count:1,payType:2,oldPrice:500,newPrice:250,icon:"proto_3_4",desc:"防具 防+200攻+50HP+100 Lv30"},
            {id:"shop054",name:"龙鳞甲",category:5,code:"proto_4_14",count:1,payType:2,oldPrice:1000,newPrice:500,icon:"proto_3_4",desc:"防具 防+310+4% Lv50"},
            {id:"shop055",name:"玄武战甲",category:5,code:"proto_4_15",count:1,payType:2,oldPrice:2500,newPrice:1200,icon:"proto_3_4",desc:"防具 防+480+6% Lv80"},
            {id:"shop056",name:"护身符",category:5,code:"proto_4_21",count:1,payType:2,oldPrice:120,newPrice:60,icon:"proto_3_4",desc:"饰品 HP+250攻+15防+20 Lv5"},
            {id:"shop057",name:"翡翠环",category:5,code:"proto_4_22",count:1,payType:2,oldPrice:360,newPrice:180,icon:"proto_3_4",desc:"饰品 HP+550攻+35防+50 Lv20"},
            {id:"shop058",name:"护心镜",category:5,code:"proto_4_23",count:1,payType:2,oldPrice:700,newPrice:350,icon:"proto_3_4",desc:"饰品 HP+1000攻+65防+90 Lv35"},
            {id:"shop059",name:"和氏璧",category:5,code:"proto_4_24",count:1,payType:2,oldPrice:1500,newPrice:800,icon:"proto_3_4",desc:"饰品 全属性+2~4%HP+1700 Lv55"},
            {id:"shop060",name:"传国玉玺",category:5,code:"proto_4_25",count:1,payType:2,oldPrice:5000,newPrice:2500,icon:"proto_3_4",desc:"饰品 全属性+4~6%HP+2800 Lv100"},
            {id:"shop061",name:"布帽",category:5,code:"proto_4_6",count:1,payType:2,oldPrice:60,newPrice:30,icon:"proto_3_4",desc:"头盔 HP+100防+12 Lv1"},
            {id:"shop062",name:"铁盔",category:5,code:"proto_4_7",count:1,payType:2,oldPrice:200,newPrice:100,icon:"proto_3_4",desc:"头盔 HP+320防+35 Lv15"},
            {id:"shop063",name:"银盔",category:5,code:"proto_4_8",count:1,payType:2,oldPrice:450,newPrice:220,icon:"proto_3_4",desc:"头盔 HP+650防+70 Lv30"},
            {id:"shop064",name:"金冠",category:5,code:"proto_4_9",count:1,payType:2,oldPrice:900,newPrice:450,icon:"proto_3_4",desc:"头盔 HP+1100+4% Lv50"},
            {id:"shop065",name:"龙盔",category:5,code:"proto_4_10",count:1,payType:2,oldPrice:2000,newPrice:1000,icon:"proto_3_4",desc:"头盔 HP+1900+7% Lv80"},
            {id:"shop066",name:"草鞋",category:5,code:"proto_4_16",count:1,payType:2,oldPrice:50,newPrice:25,icon:"proto_3_4",desc:"战靴 防+22攻+5HP+25 Lv1"},
            {id:"shop067",name:"皮靴",category:5,code:"proto_4_17",count:1,payType:2,oldPrice:180,newPrice:90,icon:"proto_3_4",desc:"战靴 防+85攻+15HP+75 Lv15"},
            {id:"shop068",name:"铁靴",category:5,code:"proto_4_18",count:1,payType:2,oldPrice:400,newPrice:200,icon:"proto_3_4",desc:"战靴 防+165攻+35HP+150 Lv30"},
            {id:"shop069",name:"银靴",category:5,code:"proto_4_19",count:1,payType:2,oldPrice:800,newPrice:400,icon:"proto_3_4",desc:"战靴 防+260+3% Lv50"},
            {id:"shop070",name:"神行靴",category:5,code:"proto_4_20",count:1,payType:2,oldPrice:1800,newPrice:900,icon:"proto_3_4",desc:"战靴 防+400+5% Lv80"},
            {id:"shop071",name:"铜戒指",category:5,code:"proto_4_26",count:1,payType:2,oldPrice:80,newPrice:40,icon:"proto_3_4",desc:"饰品Ⅱ 攻+38防+8HP+50 Lv10"},
            {id:"shop072",name:"银戒指",category:5,code:"proto_4_27",count:1,payType:2,oldPrice:250,newPrice:120,icon:"proto_3_4",desc:"饰品Ⅱ 攻+95防+20HP+130 Lv25"},
            {id:"shop073",name:"金戒指",category:5,code:"proto_4_28",count:1,payType:2,oldPrice:550,newPrice:280,icon:"proto_3_4",desc:"饰品Ⅱ 攻+180防+40HP+260 Lv40"},
            {id:"shop074",name:"龙戒",category:5,code:"proto_4_29",count:1,payType:2,oldPrice:1100,newPrice:550,icon:"proto_3_4",desc:"饰品Ⅱ 攻+300+4% Lv60"},
            {id:"shop075",name:"神戒",category:5,code:"proto_4_30",count:1,payType:2,oldPrice:2500,newPrice:1200,icon:"proto_3_4",desc:"饰品Ⅱ 攻+460+7% Lv90"}
         ];
      }
   }
}
