package game.model
{
   import com.iflashigame.utils.AESTools;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.Timer;
   import game.Config;
   import game.Data;
   import utils.JsonFormatter;
   
   public class RoleModel extends EventDispatcher
   {
      
      private static var _instance:RoleModel;
       
      
      public var token:String;
      
      private var _roleID:Number;
      
      private var _agent:String;
      
      private var _userID:String;
      
      private var _userName:String;
      
      private var _roleName:String;
      
      private var _imageID:int;
      
      private var _winCount:String;
      
      private var _lostCount:String;
      
      private var _ranking:int;
      
      private var _level:String;
      
      private var _exp:String;
      
      private var _reverence:String;
      
      private var _exploit:String;
      
      private var _money:String;
      
      private var _score:String;
      
      private var _rongyu:String;
      
      private var _paiming:String;
      
      private var _dianka:String;
      
      public var loginServer:int = 1;
      
      private var _armys:Vector.<ArmyInfo>;
      
      private var _chooseSoldiers:Vector.<String>;
      
      private var _bag:Array;
      
      private var _finished:Vector.<int>;
      
      private var _history:Vector.<int>;
      
      private var _status:int = 3;
      
      private var _saveTimer:Timer;
      
      public function RoleModel(param1:SingletonEnforcer)
      {
         this._bag = [];
         super();
         this._finished = new Vector.<int>();
         this._history = new <int>[2,1,1,1,1,1,1,1,1,1];
      }
      
      public static function getInstance() : RoleModel
      {
         if(RoleModel._instance == null)
         {
            RoleModel._instance = new RoleModel(new SingletonEnforcer());
         }
         return RoleModel._instance;
      }
      
      public function initData(param1:Object) : *
      {
         this.dianka = int(param1.dianka);
         this.initArmyModel(param1.armyModel);
         this.initRoleModel(param1.roleModel);
         this.initBagModel(param1.bagModel);
         this.initProcess(param1.process);
      }
      
      public function addSoldier(param1:ArmyInfo) : *
      {
         if(this._armys == null)
         {
            this._armys = new Vector.<ArmyInfo>();
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._armys.length)
         {
            if(this._armys[_loc2_].code == param1.code)
            {
               return;
            }
            _loc2_++;
         }
         param1.delay = 2500 + int(Math.random() * 1000);
         param1.ai = 85 + int(Math.random() * 10);
         param1.energy = 100;
         this._armys.push(param1);
      }
      
      public function removeSoldier(param1:String) : *
      {
         this.removeChooseSoldier(param1);
         this.removeSoldierFromArr(param1,this._armys);
      }
      
      public function findSoldier(param1:Number) : ArmyInfo
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._armys.length)
         {
            if(this._armys[_loc2_].id == param1)
            {
               return this._armys[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      public function modifySoldier(param1:String, param2:int, param3:int = 0, param4:int = 0) : *
      {
         if(this._armys == null)
         {
            return;
         }
         var _loc5_:int = 0;
         while(_loc5_ < this._armys.length)
         {
            if(this._armys[_loc5_].code == param1)
            {
               this._armys[_loc5_].setLevel(param2);
               this._armys[_loc5_].evolution = param3;
               this._armys[_loc5_].feature = param4;
               this._armys[_loc5_].skin = Data.getInstance().getAttributes("general",this._armys[_loc5_].code,"skin") + "_" + (this._armys[_loc5_].evolution > 1 ? 1 : 0).toString();
            }
            _loc5_++;
         }
      }
      
      public function getAllSoldierCode() : Vector.<String>
      {
         if(this._armys == null)
         {
            return null;
         }
         var _loc1_:Vector.<String> = new Vector.<String>();
         var _loc2_:int = 0;
         while(_loc2_ < this._armys.length)
         {
            _loc1_.push(this._armys[_loc2_].code);
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getAllSoldiers() : Vector.<ArmyInfo>
      {
         return this._armys;
      }
      
      public function getAllSoldierClone() : Vector.<ArmyInfo>
      {
         var _loc1_:Vector.<ArmyInfo> = new Vector.<ArmyInfo>();
         var _loc2_:int = 0;
         while(_loc2_ < this._armys.length)
         {
            _loc1_.push(this._armys[_loc2_].clone());
            _loc2_++;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this._chooseSoldiers.length)
         {
            this.removeSoldierFromArr(this._chooseSoldiers[_loc3_],_loc1_);
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function removeSoldierFromArr(param1:String, param2:Vector.<ArmyInfo>) : *
      {
         var _loc3_:int = 0;
         while(_loc3_ < param2.length)
         {
            if(param2[_loc3_].code == param1)
            {
               param2.splice(_loc3_,1);
               return;
            }
            _loc3_++;
         }
      }
      
      public function getSoldierByCode(param1:String) : ArmyInfo
      {
         if(this._armys == null)
         {
            return null;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._armys.length)
         {
            if(this._armys[_loc2_].code == param1)
            {
               return this._armys[_loc2_].clone();
            }
            _loc2_++;
         }
         return null;
      }
      
      public function getChooseSoldiers() : Vector.<ArmyInfo>
      {
         var _loc1_:Vector.<ArmyInfo> = new Vector.<ArmyInfo>();
         var _loc2_:int = 0;
         while(_loc2_ < this._chooseSoldiers.length)
         {
            _loc1_.push(this.getSoldierByCode(this._chooseSoldiers[_loc2_]));
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getChooseSoldiersSimpleList() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:Vector.<ArmyInfo> = this.getChooseSoldiers();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc1_.push(this.getSoldierSimpleInfo(_loc2_[_loc3_]));
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function getSoldierSimpleInfo(param1:ArmyInfo) : Object
      {
         var _loc2_:Object = {};
         _loc2_.code = param1.code;
         _loc2_.level = param1.level;
         _loc2_.feature = param1.feature;
         _loc2_.evolution = param1.evolution;
         _loc2_.name = param1.name;
         _loc2_.delay = param1.delay;
         _loc2_.ai = param1.ai;
         _loc2_.kezhi = param1.getKezhiStr();
         _loc2_.tianfu = param1.tianfu;
         return _loc2_;
      }
      
      public function addChooseSoldier(param1:String) : *
      {
         var _loc2_:Vector.<String> = this.getAllSoldierCode();
         if(_loc2_.indexOf(param1) == -1)
         {
            try { var _f1:File = File.applicationStorageDirectory.resolvePath("choose_debug.txt"); var _s1:FileStream = new FileStream(); _s1.open(_f1, FileMode.APPEND); _s1.writeUTFBytes("SKIP " + param1 + " not in army(" + _loc2_.length + ")\n"); _s1.close(); } catch(_e:Error) {}
            return;
         }
         if(this._chooseSoldiers.length < 6 && this._chooseSoldiers.indexOf(param1) == -1)
         {
            this._chooseSoldiers.push(param1);
            try { var _f2:File = File.applicationStorageDirectory.resolvePath("choose_debug.txt"); var _s2:FileStream = new FileStream(); _s2.open(_f2, FileMode.APPEND); _s2.writeUTFBytes("ADDED " + param1 + " (total:" + this._chooseSoldiers.length + ")\n"); _s2.close(); } catch(_e:Error) {}
         }
      }
      
      public function removeChooseSoldier(param1:String) : *
      {
         var _loc2_:int = int(this._chooseSoldiers.indexOf(param1));
         if(_loc2_ != -1)
         {
            this._chooseSoldiers.splice(_loc2_,1);
         }
      }
      
      public function getChooseSoldierStr() : String
      {
         var _loc1_:* = "";
         var _loc2_:int = int(this._chooseSoldiers.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ += this._chooseSoldiers[_loc3_];
            if(_loc3_ < _loc2_ - 1)
            {
               _loc1_ += "|";
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function addBagItem(param1:Number, param2:String, param3:int) : *
      {
         var _loc4_:int = 0;
         if(param3 <= 0)
         {
            return;
         }
         var _loc5_:int = 0;
         while(_loc5_ < this._bag.length)
         {
            if(this._bag[_loc5_].code == param2 && this._bag[_loc5_].id == param1)
            {
               if((_loc4_ = int(this._bag[_loc5_].count) - Config.timer + param3) > 99)
               {
                  _loc4_ = 99;
               }
               this._bag[_loc5_].count = (_loc4_ + Config.timer).toString();
               return;
            }
            _loc5_++;
         }
         if(param3 > 99)
         {
            param3 = 99;
         }
         this._bag.push({
            "id":param1,
            "code":param2,
            "count":(Config.timer + param3).toString()
         });
      }
      
      public function modiBagItem(param1:Number, param2:String, param3:int) : *
      {
         if(param3 <= 0)
         {
            return;
         }
         var _loc4_:int = 0;
         while(_loc4_ < this._bag.length)
         {
            if(this._bag[_loc4_].code == param2 && this._bag[_loc4_].id == param1)
            {
               if(param3 > 99)
               {
                  param3 = 99;
               }
               this._bag[_loc4_].count = (param3 + Config.timer).toString();
               return;
            }
            _loc4_++;
         }
         if(param3 > 99)
         {
            param3 = 99;
         }
         this._bag.push({
            "id":param1,
            "code":param2,
            "count":(Config.timer + param3).toString()
         });
      }
      
      public function delBagItem(param1:String, param2:int = 1) : *
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < this._bag.length)
         {
            if(this._bag[_loc4_].code == param1)
            {
               _loc3_ = int(this._bag[_loc4_].count) - Config.timer;
               _loc3_ -= param2;
               this._bag[_loc4_].count = (Config.timer + _loc3_).toString();
               if(_loc3_ <= 0)
               {
                  this._bag.splice(_loc4_,1);
               }
               return;
            }
            _loc4_++;
         }
      }
      
      public function delBagItemByID(param1:Number, param2:int = 1) : *
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < this._bag.length)
         {
            if(this._bag[_loc4_].id == param1)
            {
               _loc3_ = int(this._bag[_loc4_].count) - Config.timer;
               _loc3_ -= param2;
               this._bag[_loc4_].count = (Config.timer + _loc3_).toString();
               if(_loc3_ <= 0)
               {
                  this._bag.splice(_loc4_,1);
               }
               return;
            }
            _loc4_++;
         }
      }
      
      public function getBagData() : Array
      {
         return this._bag;
      }
      
      public function findBagItem(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._bag.length)
         {
            if(this._bag[_loc3_].code == param1)
            {
               _loc2_ = int(this._bag[_loc3_].count) - Config.timer;
               if(_loc2_ > 0)
               {
                  return true;
               }
               return false;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function findBagItemID(param1:String) : Number
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._bag.length)
         {
            if(this._bag[_loc2_].code == param1)
            {
               return this._bag[_loc2_].id;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function getBagItemCount(param1:String) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._bag.length)
         {
            if(this._bag[_loc3_].code == param1)
            {
               _loc2_ = int(this._bag[_loc3_].count) - Config.timer;
               if(_loc2_ > 0)
               {
                  return _loc2_;
               }
               return 0;
            }
            _loc3_++;
         }
         return 0;
      }
      
      public function getFinished() : Vector.<int>
      {
         return this._finished.concat();
      }
      
      public function addFinished(param1:int) : Boolean
      {
         if(this._finished.indexOf(param1) == -1)
         {
            this._finished.push(param1);
            this._finished.sort(this.compare);
            this.checkHistory();
            dispatchEvent(new Event(Event.CHANGE));
            return true;
         }
         return false;
      }
      
      private function compare(param1:int, param2:int) : Number
      {
         if(param1 > param2)
         {
            return 1;
         }
         if(param1 < param2)
         {
            return -1;
         }
         return 0;
      }
      
      public function checkHistory() : int
      {
         var _loc1_:int = int(this._finished.length);
         switch(_loc1_)
         {
            case 10:
               this._history[0] = 4;
               this._history[1] = 2;
               return 1;
            case 20:
               this._history[1] = 4;
               this._history[2] = 2;
               return 2;
            case 30:
               this._history[2] = 4;
               this._history[3] = 2;
               return 3;
            case 40:
               this._history[3] = 4;
               this._history[4] = 2;
               return 4;
            case 50:
               this._history[4] = 4;
               this._history[5] = 2;
               return 5;
            case 60:
               this._history[5] = 4;
               this._history[6] = 2;
               return 6;
            case 70:
               this._history[6] = 4;
               this._history[7] = 2;
               return 7;
            case 80:
               this._history[7] = 4;
               this._history[8] = 2;
               return 8;
            case 90:
               this._history[8] = 4;
               this._history[9] = 2;
               return 9;
            case 100:
               if(this._history[9] == 4)
               {
                  return -1;
               }
               this._history[9] = 4;
               return 10;
               break;
            default:
               return -1;
         }
      }
      
      public function getHistory() : Vector.<int>
      {
         return this._history.concat();
      }
      
      public function setHistory(param1:int) : *
      {
         param1--;
         if(this._history[param1] == 2)
         {
            this._history[param1] = 3;
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      public function get soldierNumbers() : int
      {
         if(this._armys == null)
         {
            return 0;
         }
         return this._armys.length;
      }
      
      public function makeGameData() : String
      {
         var _loc1_:* = "";
         _loc1_ += this._roleName + "/";
         _loc1_ += this._imageID + "/";
         _loc1_ += this.level + "/";
         _loc1_ += this.reverence + "/";
         _loc1_ += this.exploit + "/";
         _loc1_ += this.money + "/";
         _loc1_ += this.winCount + "/";
         _loc1_ += this.lostCount + "/";
         _loc1_ += this.score;
         _loc1_ += "#";
         var _loc2_:int = int(this._armys.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ += this._armys[_loc3_].code + "/";
            _loc1_ += this._armys[_loc3_].level + "/";
            _loc1_ += this._armys[_loc3_].evolution + "/";
            _loc1_ += this._armys[_loc3_].feature + "/";
            _loc1_ += this._armys[_loc3_].getKezhiStr() + "/";
            _loc1_ += this._armys[_loc3_].tianfu;
            if(_loc3_ < _loc2_ - 1)
            {
               _loc1_ += "|";
            }
            _loc3_++;
         }
         _loc1_ += "#";
         var _loc4_:int = int(this._chooseSoldiers.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc1_ += this._chooseSoldiers[_loc5_];
            if(_loc5_ < _loc4_ - 1)
            {
               _loc1_ += "|";
            }
            _loc5_++;
         }
         _loc1_ += "#";
         var _loc6_:int = int(this._bag.length);
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc1_ += this._bag[_loc7_].code + "/";
            _loc1_ += (int(this._bag[_loc7_].count) - Config.timer).toString();
            if(_loc7_ < _loc6_ - 1)
            {
               _loc1_ += "|";
            }
            _loc7_++;
         }
         _loc1_ += "#";
         var _loc8_:int = int(this._finished.length);
         var _loc9_:int = 0;
         while(_loc9_ < _loc8_)
         {
            _loc1_ += this._finished[_loc9_];
            if(_loc9_ < _loc8_ - 1)
            {
               _loc1_ += "|";
            }
            _loc9_++;
         }
         _loc1_ += "#";
         var _loc10_:int = int(this._history.length);
         var _loc11_:int = 0;
         while(_loc11_ < _loc10_)
         {
            _loc1_ += this._history[_loc11_];
            if(_loc11_ < _loc10_ - 1)
            {
               _loc1_ += "|";
            }
            _loc11_++;
         }
         return AESTools.encrypt(_loc1_,this.openStr(Config.ARR5),this.openStr(Config.ARR6));
      }
      
      public function importGameData(param1:String) : *
      {
         param1 = AESTools.decrypt(param1,this.openStr(Config.ARR5),this.openStr(Config.ARR6));
         var _loc2_:Array = param1.split("#");
         var _loc3_:String = String(_loc2_[0]);
         var _loc4_:String = String(_loc2_[1]);
         var _loc5_:String = String(_loc2_[2]);
         var _loc6_:String = String(_loc2_[3]);
         var _loc7_:String = String(_loc2_[4]);
         var _loc8_:String = String(_loc2_[5]);
         this.importInfo(_loc3_);
         this.importArmy(_loc4_);
         this.importChoose(_loc5_);
         this.importBag(_loc6_);
         this.importFinished(_loc7_);
         this.importHistory(_loc8_);
      }
      
      private function importInfo(param1:String) : *
      {
         var _loc2_:Array = param1.split("/");
         this._roleName = _loc2_[0];
         this._imageID = _loc2_[1];
         this.level = int(_loc2_[2]);
         this.reverence = int(_loc2_[3]);
         this.exploit = int(_loc2_[4]);
         this.money = int(_loc2_[5]);
         this.winCount = int(_loc2_[6]);
         this.lostCount = int(_loc2_[7]);
         this.score = int(_loc2_[8]);
      }
      
      private function importArmy(param1:String) : *
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:String = null;
         if(this._armys == null)
         {
            this._armys = new Vector.<ArmyInfo>();
         }
         else
         {
            while(this._armys.length > 0)
            {
               this._armys.pop();
            }
         }
         var _loc9_:Array = param1.split("|");
         var _loc10_:int = 0;
         while(_loc10_ < _loc9_.length)
         {
            _loc2_ = _loc9_[_loc10_].split("/");
            _loc3_ = String(_loc2_[0]);
            _loc4_ = int(_loc2_[1]);
            _loc5_ = int(_loc2_[2]);
            _loc6_ = int(_loc2_[3]);
            _loc7_ = String(_loc2_[4]);
            _loc8_ = String(_loc2_[5]);
            this.addSoldier(Data.getInstance().getArmyInfo(_loc3_,_loc4_,_loc5_,_loc6_,null,3000,100,_loc7_,_loc8_));
            _loc10_++;
         }
      }
      
      public function importChoose(param1:String) : *
      {
         try { var _f:File = File.applicationStorageDirectory.resolvePath("choose_debug.txt"); var _s:FileStream = new FileStream(); _s.open(_f, FileMode.WRITE); _s.writeUTFBytes("importChoose: '" + (param1||"(null)") + "'\n"); _s.close(); } catch(_e:Error) {}
         if(this._chooseSoldiers == null)
         {
            this._chooseSoldiers = new Vector.<String>();
         }
         else
         {
            while(this._chooseSoldiers.length > 0)
            {
               this._chooseSoldiers.pop();
            }
         }
         if(param1 != null && param1 != "")
         {
            var _loc2_:Array = param1.split("|");
            var _loc3_:int = 0;
            while(_loc3_ < _loc2_.length)
            {
               this.addChooseSoldier(_loc2_[_loc3_]);
               _loc3_++;
            }
         }
      }
      
      private function importBag(param1:String) : *
      {
         var _loc2_:Array = null;
         if(this._bag == null)
         {
            this._bag = [];
         }
         else
         {
            while(this._bag.length > 0)
            {
               this._bag.pop();
            }
         }
         var _loc3_:Array = param1.split("|");
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc2_ = _loc3_[_loc4_].split("/");
            this.addBagItem(1,_loc2_[0],int(_loc2_[1]));
            _loc4_++;
         }
      }
      
      public function importFinished(param1:String) : *
      {
         this._finished = new Vector.<int>();
         if(param1 == "")
         {
            return;
         }
         var _loc2_:Array = param1.split("|");
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            this.addFinished(int(_loc2_[_loc3_]));
            _loc3_++;
         }
      }
      
      public function importHistory(param1:String) : *
      {
         var _loc2_:int = int(this._history.length);
         this._history = new Vector.<int>();
         var _loc3_:Array = param1.split("|");
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            this._history.push(int(_loc3_[_loc4_]));
            _loc4_++;
         }
         var _loc5_:int = int(this._history.length);
         while(_loc5_ < _loc2_)
         {
            this._history.push(1);
            _loc5_++;
         }
      }
      
      public function openStr(param1:Array) : String
      {
         var _loc2_:String = "-M+GHIP8v=yQR1.fghz567aSJ@no/sti3#4u90UV[]NEFbcdeW!XYZ:OTAw^xpqrjkl&m2BKLCD";
         var _loc3_:int = int(param1.length);
         var _loc4_:String = "";
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_ += _loc2_.charAt(param1[_loc5_]);
            _loc5_++;
         }
         return _loc4_;
      }
      
      public function get roleActive() : Boolean
      {
         if(this._roleName != null && this._imageID != 0)
         {
            return true;
         }
         return false;
      }
      
      public function get netActive() : Boolean
      {
         if(this._userID != null && this._userName != null)
         {
            return true;
         }
         return false;
      }
      
      public function get roleID() : Number
      {
         return this._roleID;
      }
      
      public function set roleID(param1:Number) : void
      {
         this._roleID = param1;
      }
      
      public function get agent() : String
      {
         return this._agent;
      }
      
      public function set agent(param1:String) : void
      {
         this._agent = param1;
      }
      
      public function get userID() : String
      {
         return this._userID;
      }
      
      public function set userID(param1:String) : void
      {
         this._userID = param1;
      }
      
      public function get userName() : String
      {
         return this._userName;
      }
      
      public function set userName(param1:String) : void
      {
         this._userName = param1;
      }
      
      public function get roleName() : String
      {
         return this._roleName;
      }
      
      public function set roleName(param1:String) : void
      {
         this._roleName = param1;
      }
      
      public function get imageID() : int
      {
         return this._imageID;
      }
      
      public function set imageID(param1:int) : void
      {
         this._imageID = param1;
      }
      
      public function get winCount() : int
      {
         var _loc1_:int = int(this._winCount) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set winCount(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._winCount = (Config.timer + param1).toString();
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get lostCount() : int
      {
         var _loc1_:int = int(this._lostCount) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set lostCount(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._lostCount = (Config.timer + param1).toString();
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get fightCount() : int
      {
         return this.winCount + this.lostCount;
      }
      
      public function get ranking() : int
      {
         return this._ranking;
      }
      
      public function set ranking(param1:int) : *
      {
         this._ranking = param1;
      }
      
      public function get level() : int
      {
         var _loc1_:int = int(this._level) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set level(param1:int) : void
      {
         if(param1 > 130)
         {
            param1 = 130;
         }
         else if(param1 < 0)
         {
            param1 = 0;
         }
         this._level = (Config.timer + param1).toString();
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get exp() : Number
      {
         var _loc1_:Number = Number(this._exp) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set exp(param1:Number) : void
      {
         if(this.exp < 0)
         {
            this.exp = 0;
         }
         this._exp = (Config.timer + param1).toString();
      }
      
      public function get reverence() : int
      {
         var _loc1_:int = int(this._reverence) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set reverence(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._reverence = (Config.timer + param1).toString();
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get exploit() : int
      {
         var _loc1_:int = int(this._exploit) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set exploit(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._exploit = (Config.timer + param1).toString();
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get money() : int
      {
         var _loc1_:int = int(this._money) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set money(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._money = (Config.timer + param1).toString();
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get dianka() : int
      {
         var _loc1_:int = int(this._dianka) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set dianka(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._dianka = (Config.timer + param1).toString();
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get status() : int
      {
         return this._status;
      }
      
      public function set status(param1:int) : *
      {
         this._status = param1;
      }
      
      public function get score() : int
      {
         var _loc1_:int = int(this._score) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set score(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._score = (Config.timer + param1).toString();
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get rongyu() : int
      {
         var _loc1_:int = int(this._rongyu) - Config.timer;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      public function set rongyu(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._rongyu = (Config.timer + param1).toString();
      }
      
      public function initRoleModel(param1:Object) : *
      {
         this.roleID = Number(param1.roleID);
         this.agent = param1.agent;
         this.userID = param1.userID;
         this.userName = param1.userName;
         this.roleName = param1.roleName;
         this.imageID = int(param1.imageID);
         this.winCount = int(param1.winCount);
         this.lostCount = int(param1.lostCount);
         this.ranking = int(param1.ranking);
         this.level = int(param1.level);
         this.exp = Number(param1.exp);
         this.reverence = int(param1.reverence);
         this.exploit = int(param1.exploit);
         this.money = int(param1.money);
         this.score = int(param1.score);
         this.importChoose(param1.choose);
      }
      
      public function initArmyModel(param1:Array) : *
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:ArmyInfo = null;
         if(this._armys == null)
         {
            this._armys = new Vector.<ArmyInfo>();
         }
         else
         {
            while(this._armys.length > 0)
            {
               this._armys.pop();
            }
         }
         var _loc9_:int = 0;
         while(_loc9_ < param1.length)
         {
            _loc2_ = String(param1[_loc9_].code);
            _loc3_ = int(param1[_loc9_].level);
            _loc4_ = int(param1[_loc9_].evolution);
            _loc5_ = int(param1[_loc9_].feature);
            _loc6_ = String(param1[_loc9_].kezhi);
            _loc7_ = String(param1[_loc9_].genius);
            (_loc8_ = Data.getInstance().getArmyInfo(_loc2_,_loc3_,_loc4_,_loc5_,null,3000,100,_loc6_,_loc7_)).id = Number(param1[_loc9_].id);
            this.addSoldier(_loc8_);
            _loc9_++;
         }
      }
      
      public function initBagModel(param1:Array) : *
      {
         if(this._bag == null)
         {
            this._bag = [];
         }
         else
         {
            while(this._bag.length > 0)
            {
               this._bag.pop();
            }
         }
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            this.addBagItem(param1[_loc2_].id,param1[_loc2_].code,int(param1[_loc2_].count));
            _loc2_++;
         }
      }
      
      public function initProcess(param1:Object) : *
      {
         this.importHistory(param1.history);
         this.importFinished(param1.finished);
      }
      
      public function makeHistory() : String
      {
         var _loc1_:* = "";
         var _loc2_:int = int(this._history.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ += this._history[_loc3_];
            if(_loc3_ < _loc2_ - 1)
            {
               _loc1_ += "|";
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function toObject() : Object
      {
         var _loc3_:Object = null;
         var _loc1_:Object = {};
         _loc1_.dianka = this.dianka;
         _loc1_.token = this.token;
         _loc1_.roleModel = {
            "roleID":this._roleID,
            "agent":this._agent,
            "userID":this._userID,
            "userName":this._userName,
            "roleName":this._roleName,
            "imageID":this._imageID,
            "winCount":this._winCount,
            "lostCount":this._lostCount,
            "ranking":this._ranking,
            "level":this._level,
            "exp":this._exp,
            "reverence":this._reverence,
            "exploit":this._exploit,
            "money":this._money,
            "score":this._score,
            "choose":this._chooseSoldiers.join("|")
         };
         _loc1_.armyModel = [];
         var _loc2_:int = 0;
         while(_loc2_ < this._armys.length)
         {
            _loc3_ = {
               "id":this._armys[_loc2_].id,
               "code":this._armys[_loc2_].code,
               "level":this._armys[_loc2_].level,
               "evolution":this._armys[_loc2_].evolution,
               "feature":this._armys[_loc2_].feature,
               "genius":this._armys[_loc2_].tianfu,
               "kezhi":this._armys[_loc2_].getKezhiStr()
            };
            _loc1_.armyModel.push(_loc3_);
            _loc2_++;
         }
         _loc1_.bagModel = this._bag;
         _loc1_.process = {
            "history":this._history.join("|"),
            "finished":this._finished.join("|")
         };
         return _loc1_;
      }
      
      public function throttleSave() : void
      {
         if(this._saveTimer == null)
         {
            this._saveTimer = new Timer(1000,1);
            this._saveTimer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
            {
               saveToLocal();
               _saveTimer = null;
            });
            this._saveTimer.start();
         }
      }
      
      private function testWrite() : void
      {
         var file:File = File.applicationStorageDirectory.resolvePath("test.txt");
         var fs:FileStream = new FileStream();
         try
         {
            fs.open(file,FileMode.WRITE);
            fs.writeUTFBytes("测试写入！");
            fs.close();
            trace("写入成功！路径：" + file.nativePath);
         }
         catch(e:Error)
         {
            trace("测试写入失败：" + e.message);
         }
      }
      
      private function saveToLocal() : void
      {
         var file:File = null;
         var fs:FileStream = null;
         try
         {
            file = File.applicationStorageDirectory.resolvePath("data.json");
            trace("将尝试写入路径：" + file.nativePath);
            fs = new FileStream();
            fs.open(file,FileMode.WRITE);
            fs.writeUTFBytes(JsonFormatter.formatJson(this.toObject()));
            fs.close();
            trace("保存成功：" + file.nativePath);
         }
         catch(e:Error)
         {
            trace("保存失败：" + e.message);
            trace("错误堆栈：" + e.getStackTrace());
         }
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
