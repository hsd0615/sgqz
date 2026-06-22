package game.model
{
   import game.Config;
   import game.Data;
   import game.Logic;
   import game.model.EquipData;
   
   public class ArmyInfo
   {
       
      
      public var id:Number;
      
      public var code:String;
      
      public var name:String;
      
      public var type:int;
      
      public var skin:String;
      
      private var _level:String;
      
      public var title:int;
      
      private var _baseHp:String;
      
      private var _baseAttack:String;
      
      private var _baseDefense:String;
      
      private var _cd:String;
      
      private var _baoji:String;
      
      private var _attackDistance:String;
      
      private var _moveDistance:String;
      
      private var _energy:String;
      
      private var _feature:String;
      
      private var _evolution:String;
      
      public var sortFlag:int;
      
      public var proto:String;
      
      public var delay:int;
      
      public var ai:int;
      
      private var _hp:String;
      
      private var _tianfu:String;
      
      private var _kezhi1:int = -1;
      
      private var _kezhiLevel1:String;
      
      private var _kezhi2:int = -1;
      
      private var _kezhiLevel2:String;
      
      private var _kezhi3:int = -1;
      
      private var _kezhiLevel3:String;
      
      private var _tianfuHP:Number;
      
      private var _tianfuAttack:Number;
      
      private var _tianfuDefence:Number;
      
      private var _shanbi:Number;
      public var isEnemy:Boolean = false;
      public var dropEquipCode:String = "";
      public var forceHp:Boolean = false;
      
      public function ArmyInfo()
      {
         super();
      }
      
      public function clone() : ArmyInfo
      {
         var _loc1_:ArmyInfo = new ArmyInfo();
         _loc1_.id = this.id;
         _loc1_.code = this.code;
         _loc1_.name = this.name;
         _loc1_.type = this.type;
         _loc1_.skin = this.skin;
         _loc1_.level = this.level;
         _loc1_.title = this.title;
         _loc1_.baseHp = this.baseHp;
         _loc1_.baseAttack = this.baseAttack;
         _loc1_.baseDefense = this.baseDefense;
         _loc1_.cd = this.cd;
         _loc1_.baoji = this.baoji;
         _loc1_.attackDistance = this.attackDistance;
         _loc1_.moveDistance = this.moveDistance;
         _loc1_.feature = this.feature;
         _loc1_.evolution = this.evolution;
         _loc1_.sortFlag = this.sortFlag;
         _loc1_.proto = this.proto;
         _loc1_.delay = this.delay;
         _loc1_.ai = this.ai;
         _loc1_.tianfu = this.tianfu;
         _loc1_.setKezhiStr(this.getKezhiStr());
         _loc1_.setEquipmentStr(this.getEquipmentStr());
         _loc1_.hp = this.hp;
         _loc1_.forceHp = this.forceHp;
         _loc1_.isEnemy = this.isEnemy;
         _loc1_.dropEquipCode = this.dropEquipCode;
         return _loc1_;
      }
      
      public function get level() : int
      {
         var _loc1_:int = int(this._level) - Config.timer;
         if(_loc1_ < 1)
         {
            _loc1_ = 1;
         }
         return _loc1_;
      }
      
      public function set level(param1:int) : *
      {
         if(param1 > 280)
         {
            param1 = 280;
         }
         if(param1 < 1)
         {
            param1 = 1;
         }
         this._level = (Config.timer + param1).toString();
      }
      
      public function get baseHp() : int
      {
         return int(this._baseHp) - Config.timer;
      }
      
      public function set baseHp(param1:int) : *
      {
         this._baseHp = (Config.timer + param1).toString();
      }
      
      public function get baseAttack() : int
      {
         var _loc1_:int = int(this._baseAttack) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set baseAttack(param1:int) : *
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._baseAttack = (Config.timer + param1).toString();
      }
      
      public function get baseDefense() : int
      {
         var _loc1_:int = int(this._baseDefense) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set baseDefense(param1:int) : *
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._baseDefense = (Config.timer + param1).toString();
      }
      
      public function get cd() : int
      {
         var _loc1_:int = int(this._cd) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set cd(param1:int) : *
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._cd = (Config.timer + param1).toString();
      }
      
      public function get baoji() : int
      {
         var _loc1_:int = int(this._baoji) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set baoji(param1:int) : *
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._baoji = (Config.timer + param1).toString();
      }
      
      public function get attackDistance() : int
      {
         var _loc1_:int = int(this._attackDistance) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set attackDistance(param1:int) : *
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._attackDistance = (Config.timer + param1).toString();
      }
      
      public function get moveDistance() : int
      {
         var _loc1_:int = int(this._moveDistance) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set moveDistance(param1:int) : *
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._moveDistance = (Config.timer + param1).toString();
      }
      
      public function get feature() : int
      {
         var _loc1_:int = int(this._feature) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         else if(_loc1_ > 4)
         {
            _loc1_ = 4;
         }
         return _loc1_;
      }
      
      public function set feature(param1:int) : *
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 4)
         {
            param1 = 4;
         }
         this._feature = (Config.timer + param1).toString();
      }
      
      public function get evolution() : int
      {
         var _loc1_:int = int(this._evolution) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         else if(_loc1_ > 10)
         {
            _loc1_ = 10;
         }
         return _loc1_;
      }
      
      public function set evolution(param1:int) : *
      {
         if(param1 > 10)
         {
            param1 = 10;
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._evolution = (Config.timer + param1).toString();
      }
      
      public function setLevel(param1:int) : *
      {
         this.level = param1;
         this.baseHp = Logic.getBaseHp(this.type,this.level,int(Data.getInstance().getAttributes("general",this.code,"hp")),this.title);
         this.baseAttack = Logic.getBaseAttack(this.type,this.level,int(Data.getInstance().getAttributes("general",this.code,"attack")),this.title);
         this.baseDefense = Logic.getBaseDefense(this.type,this.level,int(Data.getInstance().getAttributes("general",this.code,"defense")),this.title);
         this.tianfu = this.tianfu;
      }
      
      public function getAddtion() : Number
      {
         return Logic.getAddtion(this.evolution);
      }
      
      public function get attackAddtion() : int
      {
         return int(this.baseAttack * this.getAddtion());
      }
      
      public function get defenceAddion() : int
      {
         return int(this.baseDefense * this.getAddtion());
      }
      
      public function get hpAddtion() : int
      {
         return int(this.baseHp * this.getAddtion());
      }
      
      public function get tianfuAttack() : int
      {
         return int(this.baseAttack * this._tianfuAttack);
      }
      
      public function get tianfuDefence() : int
      {
         return int(this.baseDefense * this._tianfuDefence);
      }
      
      public function get tianfuHP() : int
      {
         return int(this.baseHp * this._tianfuHP);
      }
      
      public function get shanbi() : Number
      {
         return this._shanbi;
      }
      
      private var _equip1:String = "";
      private var _equip2:String = "";
      private var _equip3:String = "";
      private var _equip4:String = "";
      private var _equip5:String = "";
      private var _equip6:String = "";

      public function get equip1():String { return this._equip1 || ""; }
      public function set equip1(param1:String):void { this._equip1 = param1; }
      public function get equip2():String { return this._equip2 || ""; }
      public function set equip2(param1:String):void { this._equip2 = param1; }
      public function get equip3():String { return this._equip3 || ""; }
      public function set equip3(param1:String):void { this._equip3 = param1; }
      public function get equip4():String { return this._equip4 || ""; }
      public function set equip4(param1:String):void { this._equip4 = param1; }
      public function get equip5():String { return this._equip5 || ""; }
      public function set equip5(param1:String):void { this._equip5 = param1; }
      public function get equip6():String { return this._equip6 || ""; }
      public function set equip6(param1:String):void { this._equip6 = param1; }

      public function getEquipSlot(param1:int):String
      {
         if(param1 == 0) return this._equip1;
         if(param1 == 1) return this._equip2;
         if(param1 == 2) return this._equip3;
         if(param1 == 3) return this._equip4;
         if(param1 == 4) return this._equip5;
         if(param1 == 5) return this._equip6;
         return "";
      }

      public function setEquipSlot(param1:int, param2:String):void
      {
         if(param1 == 0) this._equip1 = param2;
         else if(param1 == 1) this._equip2 = param2;
         else if(param1 == 2) this._equip3 = param2;
         else if(param1 == 3) this._equip4 = param2;
         else if(param1 == 4) this._equip5 = param2;
         else if(param1 == 5) this._equip6 = param2;
      }

      private function getEquipBonus(param1:String, param2:String):int
      {
         if(param1 == "" || param1 == null || param1 == "0") return 0;
         var _val:* = EquipData.get(param1,param2);
         if(!_val) return 0;
         var _n:int = int(Number(_val));
         if(this.dropEquipCode != "" && param1 == this.dropEquipCode) _n = int(_n * 0.3);
         return _n;
      }

      // 装备白值加成(攻/防/HP基础值) -- 6槽汇总
      public function get equipAttackFlat():int
      {
         return getEquipBonus(this._equip1,"attack") + getEquipBonus(this._equip2,"attack") + getEquipBonus(this._equip3,"attack")
              + getEquipBonus(this._equip4,"attack") + getEquipBonus(this._equip5,"attack") + getEquipBonus(this._equip6,"attack");
      }
      public function get equipDefenseFlat():int
      {
         return getEquipBonus(this._equip1,"defense") + getEquipBonus(this._equip2,"defense") + getEquipBonus(this._equip3,"defense")
              + getEquipBonus(this._equip4,"defense") + getEquipBonus(this._equip5,"defense") + getEquipBonus(this._equip6,"defense");
      }
      public function get equipHPFlat():int
      {
         return getEquipBonus(this._equip1,"hp") + getEquipBonus(this._equip2,"hp") + getEquipBonus(this._equip3,"hp")
              + getEquipBonus(this._equip4,"hp") + getEquipBonus(this._equip5,"hp") + getEquipBonus(this._equip6,"hp");
      }

      // 装备百分比加成(基于基础属性) -- 6槽汇总
      public function get equipAttackPct():int
      {
         var _total:int = 0;
         _total += getEquipBonus(this._equip1,"attackPct");
         _total += getEquipBonus(this._equip2,"attackPct");
         _total += getEquipBonus(this._equip3,"attackPct");
         _total += getEquipBonus(this._equip4,"attackPct");
         _total += getEquipBonus(this._equip5,"attackPct");
         _total += getEquipBonus(this._equip6,"attackPct");
         return _total;
      }
      public function get equipDefensePct():int
      {
         var _total:int = 0;
         _total += getEquipBonus(this._equip1,"defensePct");
         _total += getEquipBonus(this._equip2,"defensePct");
         _total += getEquipBonus(this._equip3,"defensePct");
         _total += getEquipBonus(this._equip4,"defensePct");
         _total += getEquipBonus(this._equip5,"defensePct");
         _total += getEquipBonus(this._equip6,"defensePct");
         return _total;
      }
      public function get equipHPPct():int
      {
         var _total:int = 0;
         _total += getEquipBonus(this._equip1,"hpPct");
         _total += getEquipBonus(this._equip2,"hpPct");
         _total += getEquipBonus(this._equip3,"hpPct");
         _total += getEquipBonus(this._equip4,"hpPct");
         _total += getEquipBonus(this._equip5,"hpPct");
         _total += getEquipBonus(this._equip6,"hpPct");
         return _total;
      }

      // 百分比部分计算的加成值
      public function get equipAttackPctBonus():int
      {
         return int(this.baseAttack * this.equipAttackPct / 100);
      }
      public function get equipDefensePctBonus():int
      {
         return int(this.baseDefense * this.equipDefensePct / 100);
      }
      public function get equipHPPctBonus():int
      {
         return int((this.baseHp + this.hpAddtion + this.tianfuHP) * this.equipHPPct / 100);
      }

      // 装备总加成(白值+百分比)
      public function get equipAttackBonus():int { return this.equipAttackFlat + this.equipAttackPctBonus; }
      public function get equipDefenseBonus():int { return this.equipDefenseFlat + this.equipDefensePctBonus; }
      public function get equipHPBonus():int { return this.equipHPFlat + this.equipHPPctBonus; }

      // ── 新装备属性 ──
      // 增伤% (对敌方造成伤害增加)
      public function get equipDmgBonus():int {
         var _t:int = 0;
         _t += getEquipBonus(this._equip1,"dmgBonus") + getEquipBonus(this._equip2,"dmgBonus") + getEquipBonus(this._equip3,"dmgBonus");
         _t += getEquipBonus(this._equip4,"dmgBonus") + getEquipBonus(this._equip5,"dmgBonus") + getEquipBonus(this._equip6,"dmgBonus");
         return _t;
      }
      // 减伤% (受到伤害减免)
      public function get equipDmgReduce():int {
         var _t:int = 0;
         _t += getEquipBonus(this._equip1,"dmgReduce") + getEquipBonus(this._equip2,"dmgReduce") + getEquipBonus(this._equip3,"dmgReduce");
         _t += getEquipBonus(this._equip4,"dmgReduce") + getEquipBonus(this._equip5,"dmgReduce") + getEquipBonus(this._equip6,"dmgReduce");
         return _t;
      }
      // 吸血% (造成伤害时回复百分比)
      public function get equipLifesteal():int {
         var _t:int = 0;
         _t += getEquipBonus(this._equip1,"lifesteal") + getEquipBonus(this._equip2,"lifesteal") + getEquipBonus(this._equip3,"lifesteal");
         _t += getEquipBonus(this._equip4,"lifesteal") + getEquipBonus(this._equip5,"lifesteal") + getEquipBonus(this._equip6,"lifesteal");
         return _t;
      }
      // 暴击率%
      public function get equipCritRate():int {
         var _t:int = 0;
         _t += getEquipBonus(this._equip1,"critRate") + getEquipBonus(this._equip2,"critRate") + getEquipBonus(this._equip3,"critRate");
         _t += getEquipBonus(this._equip4,"critRate") + getEquipBonus(this._equip5,"critRate") + getEquipBonus(this._equip6,"critRate");
         return _t;
      }
      // 暴击伤害% (额外暴击倍率)
      public function get equipCritDmg():int {
         var _t:int = 0;
         _t += getEquipBonus(this._equip1,"critDmg") + getEquipBonus(this._equip2,"critDmg") + getEquipBonus(this._equip3,"critDmg");
         _t += getEquipBonus(this._equip4,"critDmg") + getEquipBonus(this._equip5,"critDmg") + getEquipBonus(this._equip6,"critDmg");
         return _t;
      }

      public function get attack() : int
      {
         return this.baseAttack + this.attackAddtion + this.tianfuAttack + this.equipAttackBonus;
      }

      public function get defense() : int
      {
         return this.baseDefense + this.defenceAddion + this.tianfuDefence + this.equipDefenseBonus;
      }

      public function get hp() : int
      {
         var _raw:int = int(this._hp) - Config.timer;
         var _max:int = this.maxHp;
         if(!this.forceHp && _raw > _max) _raw = _max;
         if(_raw < 0) _raw = 0;
         return _raw;
      }

      public function get maxHp() : int
      {
         return this.baseHp + this.hpAddtion + this.tianfuHP + this.equipHPBonus;
      }
      
      public function set hp(param1:int) : *
      {
         this._hp = (Config.timer + param1).toString();
      }
      
      public function get energy() : int
      {
         var _loc1_:int = int(this._energy) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         if(_loc1_ > 100)
         {
            _loc1_ = 100;
         }
         return _loc1_;
      }
      
      public function set energy(param1:int) : *
      {
         if(param1 > 100)
         {
            param1 = 100;
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._energy = (Config.timer + param1).toString();
      }
      
      public function get tianfu() : String
      {
         return this._tianfu;
      }
      
      public function set tianfu(param1:String) : *
      {
         this._tianfu = param1;
         if(this._tianfu == null)
         {
            this._tianfuHP = 0;
            this._tianfuAttack = 0;
            this._tianfuDefence = 0;
            this._shanbi = 0;
            this.hp = this.maxHp;
            return;
         }
         var _loc2_:int = int(Data.getInstance().getAttributes("tianfu",this._tianfu,"type"));
         var _loc3_:Number = Number(Data.getInstance().getAttributes("tianfu",this._tianfu,"value"));
         switch(_loc2_)
         {
            case 1:
               this._tianfuHP = _loc3_;
               this._tianfuAttack = 0;
               this._tianfuDefence = 0;
               this._shanbi = 0;
               break;
            case 2:
               this._tianfuHP = 0;
               this._tianfuAttack = 0;
               this._tianfuDefence = _loc3_;
               this._shanbi = 0;
               break;
            case 3:
               this._tianfuHP = 0;
               this._tianfuAttack = _loc3_;
               this._tianfuDefence = 0;
               this._shanbi = 0;
               break;
            case 7:
               this._tianfuHP = 0;
               this._tianfuAttack = 0;
               this._tianfuDefence = 0;
               this._shanbi = _loc3_;
               break;
            default:
               this._tianfuHP = 0;
               this._tianfuAttack = 0;
               this._tianfuDefence = 0;
               this._shanbi = 0;
         }
         this.hp = this.maxHp;
      }
      
      public function get kezhi1() : int
      {
         return this._kezhi1;
      }
      
      public function set kezhi1(param1:int) : void
      {
         this._kezhi1 = param1;
      }
      
      public function get kezhi2() : int
      {
         return this._kezhi2;
      }
      
      public function set kezhi2(param1:int) : void
      {
         this._kezhi2 = param1;
      }
      
      public function get kezhi3() : int
      {
         return this._kezhi3;
      }
      
      public function set kezhi3(param1:int) : void
      {
         this._kezhi3 = param1;
      }
      
      public function get kezhiLevel1() : int
      {
         return int(this._kezhiLevel1) - Config.timer;
      }
      
      public function set kezhiLevel1(param1:int) : void
      {
         this._kezhiLevel1 = (Config.timer + param1).toString();
      }
      
      public function get kezhiLevel2() : int
      {
         return int(this._kezhiLevel2) - Config.timer;
      }
      
      public function set kezhiLevel2(param1:int) : void
      {
         this._kezhiLevel2 = (Config.timer + param1).toString();
      }
      
      public function get kezhiLevel3() : int
      {
         return int(this._kezhiLevel3) - Config.timer;
      }
      
      public function set kezhiLevel3(param1:int) : void
      {
         this._kezhiLevel3 = (Config.timer + param1).toString();
      }
      
      public function getKezhiStr() : String
      {
         return this._kezhi1 + ":" + this.kezhiLevel1 + "|" + this._kezhi2 + ":" + this.kezhiLevel2 + "|" + this._kezhi3 + ":" + this.kezhiLevel3;
      }
      
      public function setKezhiStr(param1:String) : *
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         var _loc2_:Array = param1.split("|");
         this._kezhi1 = int(_loc2_[0].split(":")[0]);
         this.kezhiLevel1 = int(_loc2_[0].split(":")[1]);
         this._kezhi2 = int(_loc2_[1].split(":")[0]);
         this.kezhiLevel2 = int(_loc2_[1].split(":")[1]);
         this._kezhi3 = int(_loc2_[2].split(":")[0]);
         this.kezhiLevel3 = int(_loc2_[2].split(":")[1]);
      }

      public function getEquipmentStr() : String
      {
         return (this._equip1||"0") + "," + (this._equip2||"0") + "," + (this._equip3||"0")
              + "," + (this._equip4||"0") + "," + (this._equip5||"0") + "," + (this._equip6||"0");
      }

      public function setEquipmentStr(param1:String) : *
      {
         if(param1 == null || param1 == "") return;
         var _parts:Array = param1.split(",");
         var _changed:Boolean = false;
         // 兼容3段旧格式(自动扩展到6段, 新槽位默认空)
         if(_parts.length > 0 && _parts[0] != "0") { this._equip1 = _parts[0]; _changed = true; }
         if(_parts.length > 1 && _parts[1] != "0") { this._equip2 = _parts[1]; _changed = true; }
         if(_parts.length > 2 && _parts[2] != "0") { this._equip3 = _parts[2]; _changed = true; }
         if(_parts.length > 3 && _parts[3] != "0") { this._equip4 = _parts[3]; _changed = true; }
         if(_parts.length > 4 && _parts[4] != "0") { this._equip5 = _parts[4]; _changed = true; }
         if(_parts.length > 5 && _parts[5] != "0") { this._equip6 = _parts[5]; _changed = true; }
         if(_changed) this.hp = this.maxHp;
      }
   }
}
