package game
{
   import game.display.AbstractSoldier;
   import game.model.Type;
   
   public class Logic
   {
      
      public static var kezhiXishu:Array = [1,1.05,1.1,1.15,1.2,1.25,1.3,1.35,1.4,1.45,1.5];
      
      public static var kezhiBilv:Array = [0,5,10,15,20,25,30,35,40,45,50];
       
      
      public function Logic()
      {
         super();
      }
      
      public static function getHurtVale(param1:AbstractSoldier, param2:AbstractSoldier, param3:String = null) : int
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param1.type == Type.TOUSHICHE)
         {
            return getHurtByToushiche(param1,param2,param3);
         }
         if(param2.type == Type.TOUSHICHE)
         {
            return getHurtValeOld(param1,param2,param3);
         }
         _loc4_ = checkBingzhongKezhi(param1,param2);
         _loc5_ = checkShuxiangKezhi(param1,param2);
         if(_loc4_ == 1 && _loc5_ == 0)
         {
            if(param1.armyInfo.kezhi1 == param2.type)
            {
               _loc6_ = param1.attack * kezhiXishu[param1.armyInfo.kezhiLevel1] - param2.defense / 5;
            }
            else if(param1.armyInfo.kezhi2 == param2.type)
            {
               _loc6_ = param1.attack * kezhiXishu[param1.armyInfo.kezhiLevel2] - param2.defense / 5;
            }
            else
            {
               _loc6_ = param1.attack * kezhiXishu[param1.armyInfo.kezhiLevel3] - param2.defense / 5;
            }
            return _loc6_ <= 0 ? 1 : _loc6_;
         }
         if(_loc4_ == -1 && _loc5_ == 0)
         {
            if(param2.armyInfo.kezhi1 == param1.type)
            {
               _loc6_ = param1.attack - param2.defense * kezhiXishu[param2.armyInfo.kezhiLevel1] / 5;
            }
            else if(param2.armyInfo.kezhi2 == param1.type)
            {
               _loc6_ = param1.attack - param2.defense * kezhiXishu[param2.armyInfo.kezhiLevel2] / 5;
            }
            else
            {
               _loc6_ = param1.attack - param2.defense * kezhiXishu[param2.armyInfo.kezhiLevel3] / 5;
            }
            return _loc6_ <= 0 ? 1 : _loc6_;
         }
         if(_loc4_ == 0 && _loc5_ == 1)
         {
            return (_loc6_ = param1.attack * 1.2 - param2.defense / 5) <= 0 ? 1 : _loc6_;
         }
         if(_loc4_ == 0 && _loc5_ == -1)
         {
            return (_loc6_ = param1.attack - param2.defense * 1.2 / 5) <= 0 ? 1 : _loc6_;
         }
         if(_loc4_ == 1 && _loc5_ == 1)
         {
            if(param1.armyInfo.kezhi1 == param2.type)
            {
               _loc6_ = param1.attack * kezhiXishu[param1.armyInfo.kezhiLevel1] * 1.2 - param2.defense / 5;
            }
            else if(param1.armyInfo.kezhi2 == param2.type)
            {
               _loc6_ = param1.attack * kezhiXishu[param1.armyInfo.kezhiLevel2] * 1.2 - param2.defense / 5;
            }
            else
            {
               _loc6_ = param1.attack * kezhiXishu[param1.armyInfo.kezhiLevel3] * 1.2 - param2.defense / 5;
            }
            return _loc6_ <= 0 ? 1 : _loc6_;
         }
         if(_loc4_ == -1 && _loc5_ == 1)
         {
            if(param2.armyInfo.kezhi1 == param1.type)
            {
               _loc6_ = param1.attack * 1.2 - param2.defense * kezhiXishu[param2.armyInfo.kezhiLevel1] / 5;
            }
            else if(param2.armyInfo.kezhi2 == param1.type)
            {
               _loc6_ = param1.attack * 1.2 - param2.defense * kezhiXishu[param2.armyInfo.kezhiLevel2] / 5;
            }
            else
            {
               _loc6_ = param1.attack * 1.2 - param2.defense * kezhiXishu[param2.armyInfo.kezhiLevel3] / 5;
            }
            return _loc6_ <= 0 ? 1 : _loc6_;
         }
         if(_loc4_ == 1 && _loc5_ == -1)
         {
            if(param1.armyInfo.kezhi1 == param2.type)
            {
               _loc6_ = param1.attack * kezhiXishu[param1.armyInfo.kezhiLevel1] - param2.defense * 1.2 / 5;
            }
            else if(param1.armyInfo.kezhi2 == param2.type)
            {
               _loc6_ = param1.attack * kezhiXishu[param1.armyInfo.kezhiLevel2] - param2.defense * 1.2 / 5;
            }
            else
            {
               _loc6_ = param1.attack * kezhiXishu[param1.armyInfo.kezhiLevel3] - param2.defense * 1.2 / 5;
            }
            return _loc6_ <= 0 ? 1 : _loc6_;
         }
         if(_loc4_ == -1 && _loc5_ == -1)
         {
            if(param2.armyInfo.kezhi1 == param1.type)
            {
               _loc6_ = param1.attack - param2.defense * kezhiXishu[param2.armyInfo.kezhiLevel1] * 1.2 / 5;
            }
            else if(param2.armyInfo.kezhi2 == param1.type)
            {
               _loc6_ = param1.attack - param2.defense * kezhiXishu[param2.armyInfo.kezhiLevel2] * 1.2 / 5;
            }
            else
            {
               _loc6_ = param1.attack - param2.defense * kezhiXishu[param2.armyInfo.kezhiLevel3] * 1.2 / 5;
            }
            return _loc6_ <= 0 ? 1 : _loc6_;
         }
         return (_loc6_ = getHurtValeOld(param1,param2,param3)) <= 0 ? 1 : _loc6_;
      }
      
      private static function getHurtByToushiche(param1:AbstractSoldier, param2:AbstractSoldier, param3:String = null) : int
      {
         var _loc4_:int = 0;
         var _loc5_:int = param1.attack;
         var _loc6_:int = param2.defense;
         var _loc7_:String = Data.getInstance().getAttributes("proto",param3,"value");
         var _loc8_:int = int(_loc7_.split(":")[0]);
         var _loc9_:int = int(_loc7_.split(":")[1]);
         var _loc10_:int = int(_loc7_.split(":")[2]);
         var _loc11_:int = _loc8_ - param2.feature;
         if(param2.evolution == 0 || _loc11_ == 0)
         {
            _loc4_ = _loc5_ - _loc6_ / 5 + _loc9_ + param2.maxHP * _loc10_ * 0.01;
         }
         else if(_loc11_ == -1 || _loc11_ == 3)
         {
            _loc4_ = _loc5_ * 1.2 - _loc6_ / 5 + _loc9_ + param2.maxHP * _loc10_ * 0.01;
         }
         else if(_loc11_ == 1 || _loc11_ == -3)
         {
            _loc4_ = _loc5_ - _loc6_ / 5 * 1.2 + _loc9_ + param2.maxHP * _loc10_ * 0.01;
         }
         else
         {
            _loc4_ = _loc5_ - _loc6_ / 5 + _loc9_ + param2.maxHP * _loc10_ * 0.01;
         }
         return _loc4_ <= 0 ? 1 : _loc4_;
      }
      
      public static function checkBingzhongKezhi(param1:AbstractSoldier, param2:AbstractSoldier) : int
      {
         if(param1.armyInfo.kezhi1 == param2.type || param1.armyInfo.kezhi2 == param2.type || param1.armyInfo.kezhi3 == param2.type)
         {
            return 1;
         }
         if(param2.armyInfo.kezhi1 == param1.type || param2.armyInfo.kezhi2 == param1.type || param2.armyInfo.kezhi3 == param1.type)
         {
            return -1;
         }
         return 0;
      }
      
      public static function checkShuxiangKezhi(param1:AbstractSoldier, param2:AbstractSoldier) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(param1.feature == 0 || param2.feature == 0)
         {
            return 0;
         }
         _loc3_ = param1.feature - param2.feature;
         _loc4_ = param2.feature - param1.feature;
         if(_loc3_ == -1 || _loc3_ == 3)
         {
            return 1;
         }
         if(_loc4_ == -1 || _loc4_ == 3)
         {
            return -1;
         }
         return 0;
      }
      
      public static function getHurtValeOld(param1:AbstractSoldier, param2:AbstractSoldier, param3:String = null) : int
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = param1.attack;
         var _loc8_:int = param1.feature;
         var _loc9_:int = param2.defense;
         var _loc10_:int;
         var _loc11_:int = (_loc10_ = param2.feature) - _loc8_;
         if(param3 == null)
         {
            if(_loc8_ > 0 && _loc10_ <= 0)
            {
               _loc4_ = int(_loc7_ * 1.2 - _loc9_ / 5);
            }
            else if(_loc11_ == -1 || _loc11_ == 3)
            {
               _loc4_ = int(_loc7_ - _loc9_ * 1.2 / 5);
            }
            else
            {
               _loc4_ = int(_loc7_ - _loc9_ / 5);
            }
            return _loc4_ <= 0 ? 1 : _loc4_;
         }
         if(param3 == "")
         {
            _loc5_ = 0;
            _loc6_ = 0;
         }
         else
         {
            _loc5_ = int(Data.getInstance().getAttributes("proto",param3,"value").split(":")[0]);
            _loc6_ = int(Data.getInstance().getAttributes("proto",param3,"value").split(":")[1]);
         }
         if(param1.type == Type.TOUSHICHE && param2.type == Type.TOUSHICHE)
         {
            return (_loc4_ = int(_loc7_ + _loc6_ - _loc9_ / 5)) <= 0 ? 1 : _loc4_;
         }
         if((_loc11_ = _loc10_ - _loc5_) == -1 || _loc11_ == 3 || _loc11_ == 0)
         {
            _loc4_ = int(_loc7_ + _loc6_ - _loc9_ / 5);
         }
         else
         {
            _loc4_ = int(_loc7_ + _loc6_ * 1.2 - _loc9_ / 5);
         }
         return _loc4_ <= 0 ? 1 : _loc4_;
      }
      
      public static function getExploitByLevel(param1:int) : int
      {
         return param1 * (param1 - 1) + 100;
      }
      
      public static function getMoneyByLevel(param1:int) : int
      {
         return 2 * param1 * (param1 - 1) + 100;
      }
      
      public static function getJinhuaJilv(param1:int) : Number
      {
         if(param1 == 0)
         {
            return 1;
         }
         if(param1 == 1)
         {
            return 0.7;
         }
         if(param1 == 2)
         {
            return 0.3;
         }
         if(param1 == 3)
         {
            return 0.15;
         }
         if(param1 == 4)
         {
            return 0.05;
         }
         if(param1 == 5)
         {
            return 0.08;
         }
         if(param1 == 6)
         {
            return 0.08;
         }
         if(param1 == 7)
         {
            return 0.05;
         }
         if(param1 == 8)
         {
            return 0.03;
         }
         if(param1 == 9)
         {
            return 0.01;
         }
         return 0.01;
      }
      
      public static function getKezhiJilv(param1:int) : Number
      {
         if(param1 == 0)
         {
            return 1;
         }
         if(param1 == 1)
         {
            return 0.8;
         }
         if(param1 == 2)
         {
            return 0.6;
         }
         if(param1 == 3)
         {
            return 0.3;
         }
         if(param1 == 4)
         {
            return 0.15;
         }
         if(param1 == 5)
         {
            return 0.1;
         }
         if(param1 == 6)
         {
            return 0.08;
         }
         if(param1 == 7)
         {
            return 0.05;
         }
         if(param1 == 8)
         {
            return 0.03;
         }
         if(param1 == 9)
         {
            return 0.02;
         }
         return 0.01;
      }
      
      public static function getMoneyByFight(param1:Number, param2:Number) : int
      {
         var _loc3_:Number = param1 - param2;
         if(_loc3_ < 0)
         {
            return 200;
         }
         return int(600 + _loc3_ * 10);
      }
      
      public static function getExploitByFight(param1:Number, param2:Number) : int
      {
         var _loc3_:Number = param1 - param2;
         if(_loc3_ < 0)
         {
            return 50;
         }
         return int(100 + _loc3_ * 10);
      }
      
      public static function getReverenceByFight(param1:Number, param2:Number) : int
      {
         var _loc3_:Number = param1 - param2;
         if(_loc3_ < 0)
         {
            return 10;
         }
         return int(50 + _loc3_ * 2);
      }
      
      public static function getScoreByFight(param1:Number, param2:Number) : int
      {
         var _loc3_:Number = param1 - param2;
         if(_loc3_ < 0)
         {
            return 5;
         }
         return 5 + int(_loc3_ * 2);
      }
      
      public static function getAddtion(param1:int) : Number
      {
         var _loc2_:Array = ["0","1","2","3","4","5","6","7","8","9","."];
         if(param1 == 1)
         {
            return Number(_loc2_[0] + _loc2_[10] + _loc2_[0] + _loc2_[5]);
         }
         if(param1 == 2)
         {
            return Number(_loc2_[0] + _loc2_[10] + _loc2_[0] + _loc2_[8]);
         }
         if(param1 == 3)
         {
            return Number(_loc2_[0] + _loc2_[10] + _loc2_[1] + _loc2_[1]);
         }
         if(param1 == 4)
         {
            return Number(_loc2_[0] + _loc2_[10] + _loc2_[1] + _loc2_[5]);
         }
         if(param1 == 5)
         {
            return Number(_loc2_[0] + _loc2_[10] + _loc2_[2] + _loc2_[2]);
         }
         if(param1 == 6)
         {
            return Number(_loc2_[0] + _loc2_[10] + _loc2_[2] + _loc2_[6]);
         }
         if(param1 == 7)
         {
            return Number(_loc2_[0] + _loc2_[10] + _loc2_[3] + _loc2_[2]);
         }
         if(param1 == 8)
         {
            return Number(_loc2_[0] + _loc2_[10] + _loc2_[3] + _loc2_[8]);
         }
         if(param1 == 9)
         {
            return Number(_loc2_[0] + _loc2_[10] + _loc2_[4] + _loc2_[2]);
         }
         if(param1 == 10)
         {
            return Number(_loc2_[0] + _loc2_[10] + _loc2_[5] + _loc2_[0]);
         }
         return 0;
      }
      
      public static function getBaseHp(param1:int, param2:int, param3:int, param4:int) : int
      {
         var _loc5_:Number = Number(Data.getInstance().getAttributes("xishu",param1 + "_" + param4,"hp"));
         return int((param2 - 1) * 50 * _loc5_ + param3);
      }
      
      public static function getBaseAttack(param1:int, param2:int, param3:int, param4:int) : int
      {
         var _loc5_:Number = Number(Data.getInstance().getAttributes("xishu",param1 + "_" + param4,"attack"));
         return int((param2 - 1) * 30 * _loc5_ + param3);
      }
      
      public static function getBaseDefense(param1:int, param2:int, param3:int, param4:int) : int
      {
         var _loc5_:Number = Number(Data.getInstance().getAttributes("xishu",param1 + "_" + param4,"defence"));
         return int((param2 - 1) * 30 * _loc5_ + param3);
      }
   }
}
