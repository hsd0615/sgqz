package game.fuben
{
   import com.iflashigame.utils.Tools;
   import game.Data;
   import game.Logic;
   import game.display.AbstractSoldier;
   import game.display.JiantaSoldier;
   import game.model.ArmyInfo;
   import game.model.Type;
   
   public class XiongnuConfig
   {
       
      
      private var _xiaobingTalkArr:Array;
      
      private var _wujiangTalkArr:Array;
      
      private var _bossTalkArr:Array;
      
      public function XiongnuConfig()
      {
         super();
         this._xiaobingTalkArr = [];
         this._wujiangTalkArr = [];
         this._bossTalkArr = [];
         this.createXiaobingTalk();
         this.createWujiangTalk();
         this.createBossTalk();
      }
      
      public static function checkGeneralLevel(param1:Vector.<ArmyInfo>) : Boolean
      {
         var _loc2_:int = 0;
         if(param1.length == 1)
         {
            return true;
         }
         var _loc3_:int = 0;
         while(_loc3_ < param1.length - 1)
         {
            _loc2_ = 1;
            while(_loc2_ < param1.length)
            {
               if(Math.abs(param1[_loc3_].level - param1[_loc2_].level) > 10)
               {
                  return false;
               }
               _loc2_++;
            }
            _loc3_++;
         }
         return true;
      }
      
      private function createXiaobingTalk() : *
      {
         this._xiaobingTalkArr.push("冲啊……人头归我了");
         this._xiaobingTalkArr.push("看我不把你打下马来！");
         this._xiaobingTalkArr.push("哎哟哟，不知死活的家伙，看我灭了你！");
         this._xiaobingTalkArr.push("立刻通知大王，有人闯入。");
         this._xiaobingTalkArr.push("弟兄们都给我上啊！");
         this._xiaobingTalkArr.push("布阵、布阵……");
      }
      
      private function createWujiangTalk() : *
      {
         this._wujiangTalkArr.push("那厮跟俺长的这么像，大战三百回合看谁更厉害！");
         this._wujiangTalkArr.push("快快报上名来，我手下没有无名之鬼。");
         this._wujiangTalkArr.push("你们退后，我一人全挑了。");
         this._wujiangTalkArr.push("敢在爷爷面前撒野，让你有来无回。");
         this._wujiangTalkArr.push("小贼来啊，吃我一招。");
      }
      
      private function createBossTalk() : *
      {
         this._bossTalkArr.push("来着何人，还不快快报上名来。");
         this._bossTalkArr.push("看你武艺不错，放下武器受降于我，保你一条性命。");
         this._bossTalkArr.push("小的们，给我上");
         this._bossTalkArr.push("放箭，给我射。");
      }
      
      public function xiaoBingTalk() : String
      {
         return Tools.randomFromArr(this._xiaobingTalkArr) as String;
      }
      
      public function getJiantaData() : ArmyInfo
      {
         var _loc1_:Object = Data.getInstance().getFubenAIDelay(1,"general_11_1");
         var _loc2_:ArmyInfo = Data.getInstance().getArmyInfo("general_11_1",1,0,0,"匈奴前哨",int(_loc1_.delay),int(_loc1_.ai));
         _loc2_.baseHp = 100;
         return _loc2_;
      }
      
      public function getBossData(param1:Vector.<ArmyInfo>) : ArmyInfo
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Object = Data.getInstance().getFubenAIDelay(1,"general_13_1");
         var _loc5_:ArmyInfo = Data.getInstance().getArmyInfo("general_13_1",1,0,0,"匈奴头目",int(_loc4_.delay),int(_loc4_.ai));
         var _loc6_:int = 0;
         while(_loc6_ < param1.length)
         {
            _loc2_ += param1[_loc6_].hp;
            _loc3_ += param1[_loc6_].defense;
            _loc6_++;
         }
         _loc5_.hp = _loc2_ * 12;
         _loc5_.baseDefense = int(_loc3_ / param1.length);
         return _loc5_;
      }
      
      public function getQianggongData(param1:Vector.<ArmyInfo>) : ArmyInfo
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Object = Data.getInstance().getFubenAIDelay(1,"general_12_1");
         var _loc5_:ArmyInfo = Data.getInstance().getArmyInfo("general_12_1",1,0,0,"匈奴长弓手",int(_loc4_.delay),int(_loc4_.ai));
         var _loc6_:int = 0;
         while(_loc6_ < param1.length)
         {
            _loc2_ += param1[_loc6_].hp;
            _loc3_ += param1[_loc6_].defense;
            _loc6_++;
         }
         _loc5_.hp = int(_loc2_ / param1.length);
         _loc5_.baseDefense = int(_loc3_ / param1.length);
         return _loc5_;
      }
      
      public function getWandaoData(param1:int, param2:int, param3:int) : ArmyInfo
      {
         var _loc4_:Object = Data.getInstance().getFubenAIDelay(1,"general_10_1");
         var _loc5_:ArmyInfo;
         (_loc5_ = Data.getInstance().getArmyInfo("general_10_1",1,0,0,"匈奴杂兵",int(_loc4_.delay),int(_loc4_.ai))).baseDefense = int(param2 / param3);
         _loc5_.hp = int(param1 / param3);
         _loc5_.attackDistance = 3 + Number((1.5 * Math.random()).toFixed(1));
         return _loc5_;
      }
      
      public function getHurtVale(param1:AbstractSoldier, param2:AbstractSoldier, param3:String = null, param4:int = -1) : int
      {
         var _loc5_:int = param1.type == Type.JUNZHU ? Type.QIBING : param1.type;
         var _loc6_:int = param2.type == Type.JUNZHU ? Type.QIBING : param2.type;
         if(_loc5_ < Type.WANDAOBING && _loc6_ < Type.WANDAOBING)
         {
            return Logic.getHurtVale(param1,param2,param3);
         }
         if(_loc5_ == Type.TOUSHICHE)
         {
            switch(_loc6_)
            {
               case Type.JIANTABING:
                  (param2 as JiantaSoldier).hurt2(int(param1.attack / 2));
                  return int(param2.maxHP * 0.05);
               default:
                  return Logic.getHurtVale(param1,param2,param3);
            }
         }
         else if(_loc5_ < Type.WANDAOBING && _loc6_ > Type.QIBING)
         {
            switch(_loc6_)
            {
               case Type.WANDAOBING:
                  return int(param1.attack - param2.defense / 5);
               case Type.JIANTABING:
                  (param2 as JiantaSoldier).hurt2(int(param1.attack / 2));
                  return int(param2.maxHP * 0.05);
               case Type.QIANGGONGBING:
                  return int(param1.attack - param2.defense / 5);
               default:
                  return int(param1.attack - param2.defense / 5);
            }
         }
         else if(_loc5_ > Type.QIBING && _loc6_ < Type.WANDAOBING)
         {
            switch(_loc5_)
            {
               case Type.WANDAOBING:
                  return int(param2.maxHP * 0.03);
               case Type.JIANTABING:
                  return int(param2.maxHP * 0.05);
               case Type.QIANGGONGBING:
                  return int(param2.maxHP * 0.03);
               default:
                  if(param4 == 1)
                  {
                     return int(param2.maxHP * 0.05);
                  }
                  return int(param2.maxHP * 0.03);
            }
         }
         else
         {
            return 0;
         }
      }
   }
}
