package game
{
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import game.model.ArmyInfo;
   import game.model.EquipData;
   import game.model.Type;

   public class Data
   {
      
      private static var _instance:Data;
       
      
      private var _generalXML:XML;
      
      private var _xishuXML:XML;
      
      private var _protoXML:XML;
      
      private var _shopXML:XML;
      
      private var _stageXML:XML;
      
      private var _xml:XML;
      
      private var _paomaXML:XML;
      
      private var _tianfuXML:XML;

      private var _equipXML:XML;
      private var _equipData:Object = {};
      private var _shopJSON:Array = null;
      private var _protoJSON:Array = null;

      public function initEquipJSON(param1:Array) : void
      {
         for(var _ei:int = 0; _ei < param1.length; _ei++)
            this._equipData[param1[_ei].code] = param1[_ei];
      }
      public function getEquipAttr(param1:String, param2:String) : *
      {
         if(this._equipData && this._equipData[param1] && this._equipData[param1][param2] != undefined)
            return this._equipData[param1][param2];
         return this.getAttributes("equip", param1, param2);
      }
      public function mergeShopJSON(param1:Array) : void { this._shopJSON = param1; }
      public function getShopJSON() : Array { return this._shopJSON; }
      public function mergeProtoJSON(param1:Array) : void { this._protoJSON = param1; }
      public function getProtoJSON() : Array { return this._protoJSON; }

      public function Data(param1:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : Data
      {
         if(Data._instance == null)
         {
            Data._instance = new Data(new SingletonEnforcer());
         }
         return Data._instance;
      }
      
      public function initGeneralXML(param1:*) : *
      {
         if(param1 is XML)
         {
            this._generalXML = param1;
         }
         else if(param1 is String)
         {
            this._generalXML = XML(param1);
         }
      }
      
      public function initXishuXML(param1:*) : *
      {
         if(param1 is XML)
         {
            this._xishuXML = param1;
         }
         else if(param1 is String)
         {
            this._xishuXML = XML(param1);
         }
      }
      
      public function initProtoXML(param1:*) : *
      {
         if(param1 is XML)
         {
            this._protoXML = param1;
         }
         else if(param1 is String)
         {
            this._protoXML = XML(param1);
         }
      }
      
      public function initShopXML(param1:*) : *
      {
         if(param1 is XML)
         {
            this._shopXML = param1;
         }
         else if(param1 is String)
         {
            this._shopXML = XML(param1);
         }
      }
      
      public function initStageXML(param1:*) : *
      {
         if(param1 is XML)
         {
            this._stageXML = param1;
         }
         else if(param1 is String)
         {
            this._stageXML = XML(param1);
         }
         this._xml = this._stageXML;
      }
      
      public function initPaomaXML(param1:*) : *
      {
         if(param1 is XML)
         {
            this._paomaXML = param1;
         }
         else if(param1 is String)
         {
            this._paomaXML = XML(param1);
         }
      }
      
      public function initTianfuXML(param1:*) : *
      {
         if(param1 is XML)
         {
            this._tianfuXML = param1;
         }
         else if(param1 is String)
         {
            this._tianfuXML = XML(param1);
         }
      }

      public function initEquipXML(param1:*) : *
      {
         if(param1 is XML)
         {
            this._equipXML = param1;
         }
         else if(param1 is String)
         {
            this._equipXML = XML(param1);
         }
      }

      public function get xml() : XML
      {
         return this._xml;
      }
      
      private function getXMLByName(param1:String) : XML
      {
         var _loc2_:XML = null;
         switch(param1)
         {
            case "general":
               _loc2_ = this._generalXML;
               break;
            case "proto":
               _loc2_ = this._protoXML;
               break;
            case "paoma":
               _loc2_ = this._paomaXML;
               break;
            case "shop":
               _loc2_ = this._shopXML;
               break;
            case "xishu":
               _loc2_ = this._xishuXML;
               break;
            case "tianfu":
               _loc2_ = this._tianfuXML;
               break;
            case "equip":
               _loc2_ = this._equipXML;
         }
         return _loc2_;
      }
      
      private function xml2obj(param1:XMLList) : Object
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc2_:XMLList = param1.children();
         var _loc3_:int = int(_loc2_.length());
         if(_loc3_ == 0)
         {
            return null;
         }
         var _loc4_:Object = {};
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_[_loc2_[_loc5_].name()] = _loc2_[_loc5_];
            _loc5_++;
         }
         return _loc4_;
      }
      
      public function getPaomadeng() : Array
      {
         if(this._paomaXML == null)
         {
            return null;
         }
         var _loc1_:Array = [];
         var _loc2_:int = int(this._paomaXML.RECORD.content.length());
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_.push(this._paomaXML.RECORD.content[_loc3_]);
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function getLine(param1:String, param2:String) : Object
      {
         var table:String = param1;
         var myCode:String = param2;
         var xml:XML = this.getXMLByName(table);
         if(xml == null)
         {
            return null;
         }
         return this.xml2obj(xml.RECORD.(code == myCode));
      }
      
      public function getAttributes(param1:String, param2:String, param3:String) : *
      {
         var val:XMLList = null;
         var xmlList:XMLList = null;
         var table:String = param1;
         var ID:String = param2;
         var key:String = param3;
         // JSON数据优先(从/api/game-data加载, 比本地XML更新)
         if(table == "equip" && this._equipData && this._equipData[ID])
         {
            return this._equipData[ID][key];
         }
         var xml:XML = this.getXMLByName(table);
         if(xml == null)
         {
            return null;
         }
         switch(table)
         {
            case "shop":
            case "paoma":
               xmlList = xml.RECORD.(id == ID);
               break;
            default:
               xmlList = xml.RECORD.(code == ID);
         }
         if(xmlList.length() == 0)
         {
            return null;
         }
         val = xmlList.child(key);
         if(val.length() == 0)
         {
            return null;
         }
         return val.toString();
      }
      
      public function getFubenAIDelay(param1:int, param2:String) : Object
      {
         var stageID:int = param1;
         var code:String = param2;
         var obj:Object = {};
         obj.ai = this._xml.fuben.(@stageID == stageID).general.(@code == code).@ai;
         obj.delay = this._xml.fuben.(@stageID == stageID).general.(@code == code).@delay;
         return obj;
      }
      
      public function getArmyInfo(param1:String, param2:int, param3:int = 0, param4:int = 0, param5:String = null, param6:int = 3000, param7:int = 100, param8:String = null, param9:String = null) : ArmyInfo
      {
         var _loc10_:String = null;
         var _loc11_:ArmyInfo = new ArmyInfo();
         var _loc12_:Object = this.getLine("general",param1);
         if(_loc12_ == null) return null;
         _loc11_.code = param1;
         _loc11_.name = _loc12_.name;
         _loc11_.type = int(_loc12_.type);
         _loc11_.proto = _loc12_.proto;
         _loc11_.delay = param6;
         _loc11_.ai = param7;
         if(param9 == null)
         {
            _loc11_.tianfu = param9;
         }
         else if(param9.indexOf("tf") == -1)
         {
            _loc11_.tianfu = null;
         }
         else
         {
            _loc11_.tianfu = param9;
         }
         if(param8 == null || param8 == "" || param8 == "null")
         {
            _loc10_ = this.getAttributes("general",param1,"kezhi");
            _loc11_.setKezhiStr(_loc10_);
         }
         else
         {
            _loc11_.setKezhiStr(param8);
         }
         _loc11_.skin = _loc12_.skin + "_" + (param3 > 1 ? 1 : 0).toString();
         _loc11_.level = param2;
         _loc11_.title = int(_loc12_.title);
         _loc11_.evolution = param3;
         _loc11_.baseHp = Logic.getBaseHp(_loc11_.type,_loc11_.level,int(_loc12_.hp),_loc11_.title);
         _loc11_.baseAttack = Logic.getBaseAttack(_loc11_.type,_loc11_.level,int(_loc12_.attack),_loc11_.title);
         _loc11_.baseDefense = Logic.getBaseDefense(_loc11_.type,_loc11_.level,int(_loc12_.defense),_loc11_.title);
         _loc11_.hp = _loc11_.baseHp + _loc11_.hpAddtion + _loc11_.tianfuHP;
         if(param5 != null)
         {
            _loc11_.name = param5;
         }
         _loc11_.cd = int(_loc12_.cd);
         _loc11_.baoji = _loc12_.baoji;
         _loc11_.attackDistance = Number(_loc12_.attackDistance);
         _loc11_.moveDistance = Number(_loc12_.moveDistance);
         _loc11_.feature = param4;
         if(_loc11_.type == Type.TOUSHICHE)
         {
            _loc11_.sortFlag = 1;
         }
         else if(_loc11_.type == Type.QIBING)
         {
            _loc11_.sortFlag = 0;
         }
         else if(_loc11_.type == Type.CHANGQIANGBING)
         {
            _loc11_.sortFlag = 7;
         }
         else if(_loc11_.type == Type.WUDOUBING)
         {
            _loc11_.sortFlag = 8;
         }
         else if(_loc11_.type == Type.FEIDAOBING)
         {
            _loc11_.sortFlag = 9;
         }
         else if(_loc11_.type == Type.GONGBING)
         {
            _loc11_.sortFlag = 10;
         }
         else
         {
            _loc11_.sortFlag = 2;
         }
         return _loc11_;
      }
      
      public function getDefaultArmys() : Vector.<ArmyInfo>
      {
         var _loc1_:XML = null;
         var _loc2_:Vector.<ArmyInfo> = new Vector.<ArmyInfo>();
         var _loc3_:int = int(this._xml.defaultArmy.general.length());
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc1_ = this._xml.defaultArmy.general[_loc4_];
            _loc2_.push(this.getArmyInfo(_loc1_.@code,_loc1_.@level,_loc1_.@evolution == undefined ? 0 : int(_loc1_.@evolution),_loc1_.@feature == undefined ? 0 : int(_loc1_.@feature),_loc1_.@name == undefined ? null : _loc1_.@name));
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function getGateArmys(param1:int, param2:int) : Vector.<ArmyInfo>
      {
         var arr:Vector.<ArmyInfo> = null;
         var partAI:int = 0;
         var ai:int = 0;
         var partDelay:int = 0;
         var delay:int = 0;
         var list:XMLList = null;
         var length:int = 0;
         var i:int = 0;
         var xml:XML = null;
         var gateAI:int = 0;
         var gateDelay:int = 0;
         var part:int = param1;
         var level:int = param2;
         arr = new Vector.<ArmyInfo>();
         partAI = int(this._xml.gate.(@part == part && @level == level).@ai);
         partDelay = int(this._xml.gate.(@part == part && @level == level).@delay);
         list = this._xml.gate.(@part == part && @level == level).general;
         length = int(list.length());
         i = 0;
         while(i < length)
         {
            xml = list[i];
            gateAI = int(xml.@ai);
            gateDelay = int(xml.@delay);
            if(gateAI == 0)
            {
               ai = partAI;
            }
            if(ai == 0)
            {
               ai = 100;
            }
            if(gateDelay == 0)
            {
               delay = partDelay;
            }
            if(delay == 0)
            {
               delay = 3000;
            }
            var _enemy:ArmyInfo = this.getArmyInfo(xml.@code,xml.@level,xml.@evolution == undefined ? 0 : int(xml.@evolution),xml.@feature == undefined ? 0 : int(xml.@feature),xml.@name == undefined ? null : xml.@name,delay,ai,xml.@kezhi == undefined ? null : xml.@kezhi,xml.@tianfu == undefined ? null : xml.@tianfu);
            this.assignGateEquip(_enemy, int(xml.@level), level);
            _enemy.isEnemy = true;
            arr.push(_enemy);
            i++;
         }
         return arr;
      }

      // 给主线关卡敌方武将分配装备
      public function assignGateEquip(param1:ArmyInfo, param2:int, param3:int) : void
      {
         if(param1 == null || param2 < 5) return;
         // 投石车不掉装备
         if(param1.type == Type.TOUSHICHE) return;
         var _genQuality:int = param1.title; // 0=超级 1=一流 2=三流 3=杂兵
         var _gateLevel:int = param3; // 关卡层级
         // 根据品质和关卡深度决定装备品质范围 (支持Q11魔器)
         var _maxQ:int = 1;
         if(_genQuality == 0) _maxQ = Math.min(11, 2 + int(_gateLevel / 20));
         else if(_genQuality == 1) _maxQ = Math.min(9, 2 + int(_gateLevel / 25));
         else if(_genQuality == 2) _maxQ = Math.min(7, 1 + int(_gateLevel / 30));
         else _maxQ = Math.min(5, 1 + int(_gateLevel / 35));
         var _minQ:int = Math.max(1, _maxQ - 3);
         var _equipSlots:Array = [];
         var _s:int = 1;
         while(_s <= 6)
         {
            if(Math.random() < Math.min(0.45, 0.12 + param2 * 0.002))
            {
               var _slotCodes:Array = EquipData.getBySlot(_s);
               var _candidates:Array = [];
               var _c:int = 0;
               while(_c < _slotCodes.length)
               {
                  var _code:String = _slotCodes[_c];
                  var _q:int = int(EquipData.get(_code, "quality"));
                  if(_q >= _minQ && _q <= _maxQ) _candidates.push(_code);
                  _c++;
               }
               if(_candidates.length > 0)
               {
                  _equipSlots.push(_candidates[int(Math.random() * _candidates.length)]);
               }
               else
               {
                  _equipSlots.push("0");
               }
            }
            else
            {
               _equipSlots.push("0");
            }
            _s++;
         }
         if(_equipSlots.length == 6)
         {
            param1.setEquipmentStr(_equipSlots.join(","));
         }
      }
      
      public function getZhaomuByLevel(param1:int, param2:Vector.<String> = null) : Vector.<String>
      {
         var arr:Vector.<String> = null;
         var xmlList:XMLList = null;
         var i:* = undefined;
         var maxLevel:int = param1;
         if(this._generalXML == null)
         {
            return null;
         }
         arr = new Vector.<String>();
         xmlList = this._generalXML.RECORD.(recruitLevel > 0 && recruitLevel <= maxLevel).code;
         for(i in xmlList)
         {
            arr.push(xmlList[i]);
         }
         // 合并关卡解锁的"在野"武将 (确保其在招募池中)
         if(param2 != null && param2.length > 0)
         {
            var _ui:int = 0;
            while(_ui < param2.length)
            {
               if(arr.indexOf(param2[_ui]) < 0)
               {
                  arr.push(param2[_ui]);
               }
               _ui++;
            }
         }
         return arr;
      }

      public function getZhaomuByLevelExcludeSuper(param1:int, param2:Vector.<String> = null) : Vector.<String>
      {
         var arr:Vector.<String> = getZhaomuByLevel(param1,param2);
         if(arr == null) return null;
         var filtered:Vector.<String> = new Vector.<String>();
         var _i:int = 0;
         while(_i < arr.length)
         {
            var _title:String = this.getAttributes("general",arr[_i],"title");
            if(_title != "0")
            {
               filtered.push(arr[_i]);
            }
            _i++;
         }
         return filtered;
      }

      public function getGateList(param1:int, param2:Vector.<int>) : Array
      {
         var arr:Array = null;
         var list:XMLList = null;
         var length:int = 0;
         var i:int = 0;
         var xml:XML = null;
         var status:int = 0;
         var part:int = param1;
         var finished:Vector.<int> = param2;
         arr = [];
         list = this._xml.gate.(@part == part);
         length = int(list.length());
         if(part >= 11)
         {
            try {
               var _df:File = File.applicationStorageDirectory.resolvePath("debug_stage.txt");
               var _ds:FileStream = new FileStream();
               _ds.open(_df, FileMode.APPEND);
               _ds.writeUTFBytes("[getGateList] part=" + part + " listLen=" + length + " xmlHasGates=" + (this._xml != null ? this._xml.gate.length() : -1) + "\n");
               _ds.close();
            } catch(_e:Error) {}
         }
         i = 0;
         while(i < length)
         {
            xml = list[i];
            if(finished.indexOf(int(xml.@id)) != -1)
            {
               status = 1;
            }
            else
            {
               status = 0;
            }
            arr.push({
               "name":xml.@name,
               "level":xml.@level,
               "group":xml.@group,
               "part":part,
               "status":status
            });
            i++;
         }
         return arr;
      }
      
      public function getAward(param1:int, param2:int) : Object
      {
         var xml:XML = null;
         var obj:Object = null;
         var part:int = param1;
         var level:int = param2;
         xml = this._xml.gate.(@part == part && @level == level)[0];
         if(xml.award == undefined)
         {
            return null;
         }
         obj = {};
         if(xml.award.@soldier != "")
         {
            obj.soldier = xml.award.@soldier.split("|");
         }
         if(xml.award.@recruit != "")
         {
            obj.recruit = xml.award.@recruit;
         }
         if(xml.award.@proto != "")
         {
            obj.proto = xml.award.@proto.split("|");
         }
         if(xml.award.@money != "")
         {
            obj.money = int(xml.award.@money);
         }
         if(xml.award.@reverence != "")
         {
            obj.reverence = int(xml.award.@reverence);
         }
         if(xml.award.@exploit != "")
         {
            obj.exploit = int(xml.award.@exploit);
         }
         return obj;
      }
      
      public function getStageID(param1:int, param2:int) : int
      {
         var xml:XML = null;
         var part:int = param1;
         var level:int = param2;
         xml = this._xml.gate.(@part == part && @level == level)[0];
         if(xml != null)
         {
            return int(xml.@id);
         }
         return 1;
      }
      
      public function getStageName(param1:int, param2:int) : String
      {
         var xml:XML = null;
         var part:int = param1;
         var level:int = param2;
         xml = this._xml.gate.(@part == part && @level == level)[0];
         if(xml != null)
         {
            return xml.@name;
         }
         return "未知关卡";
      }
      
      public function getArmyBySimpleList(param1:Array) : Vector.<ArmyInfo>
      {
         var _loc2_:int = int(param1.length);
         var _loc3_:Vector.<ArmyInfo> = new Vector.<ArmyInfo>();
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_.push(this.getArmyInfo(param1[_loc4_].code,param1[_loc4_].level,param1[_loc4_].evolution,param1[_loc4_].feature,param1[_loc4_].name,param1[_loc4_].delay,param1[_loc4_].ai,param1[_loc4_].kezhi,param1[_loc4_].tianfu));
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function getShopData(param1:int) : Array
      {
         var arr:Array = [];
         var mycategory:int = param1;
         // 从XML读取
         if(this._shopXML != null)
         {
            var xmlList:XMLList = this._shopXML.RECORD.(category == mycategory);
            for each(var _rec:XML in xmlList)
            {
               var _tmpXML:XMLList = this._protoXML != null ? this._protoXML.RECORD.(code == _rec.code.toString()) : null;
               arr.push({
                  id: _rec.id.toString(), code: _rec.code.toString(),
                  count: int(_rec.count), payType: int(_rec.payType),
                  oldPrice: int(_rec.oldPrice), newPrice: int(_rec.newPrice),
                  name: _rec.name.toString(), icon: _tmpXML != null ? _tmpXML.icon.toString() : "", desc: _tmpXML != null ? _tmpXML.desc.toString() : ""
               });
            }
         }
         // 合并服务端JSON
         if(this._shopJSON != null)
         {
            for(var _j:int = 0; _j < this._shopJSON.length; _j++)
            {
               var _sitem:Object = this._shopJSON[_j];
               if(int(_sitem.category) != mycategory) continue;
               var _dup:Boolean = false;
               for(var _k:int = 0; _k < arr.length; _k++) { if(arr[_k].id == _sitem.id) { _dup = true; break; } }
               if(!_dup) arr.push({id:_sitem.id, code:_sitem.code, count:int(_sitem.count), payType:int(_sitem.payType), oldPrice:int(_sitem.oldPrice), newPrice:int(_sitem.newPrice), name:_sitem.name, icon:_sitem.icon||"proto_1_0", desc:_sitem.desc||_sitem.name});
            }
         }
         // 始终合并硬编码装备数据
         var _eqItems:Array = EquipData.getShopEquipItems();
         for(var _ej:int = 0; _ej < _eqItems.length; _ej++)
         {
            var _eitem:Object = _eqItems[_ej];
            if(int(_eitem.category) != mycategory) continue;
            var _edup:Boolean = false;
            for(var _ek:int = 0; _ek < arr.length; _ek++) { if(arr[_ek].id == _eitem.id) { _edup = true; break; } }
            if(!_edup) arr.push({id:_eitem.id, code:_eitem.code, count:int(_eitem.count), payType:int(_eitem.payType), oldPrice:int(_eitem.oldPrice), newPrice:int(_eitem.newPrice), name:_eitem.name, icon:_eitem.icon||"proto_1_0", desc:_eitem.desc||_eitem.name});
         }
         if(arr.length == 0) return null;
         arr.sortOn("id");
         return arr;
      }
   }
}

class SingletonEnforcer
{
    
   
   public function SingletonEnforcer()
   {
      super();
   }
}
