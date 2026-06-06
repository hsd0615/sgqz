package game.ai
{
   import com.iflashigame.utils.Tools;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import game.Fight;
   import game.display.AbstractSoldier;
   import game.display.Boss;
   import game.display.Gunner;
   import game.display.JiantaSoldier;
   import game.display.Junzhu;
   import game.display.QianggongSoldier;
   import game.display.Saber;
   import game.display.Shooter;
   import game.display.WandaoSoldier;
   import game.fuben.XiongnuConfig;
   
   public class XiongnuAI
   {
       
      
      private var _fight:IAI;
      
      private var _delay:Number;
      
      private var _roleArmy:Array;
      
      private var _otherArmy:Array;
      
      private var _gunnerArr:Array;
      
      private var _saberArr:Array;
      
      private var _shooterArr:Array;
      
      private var _bossArr:Array;
      
      private var _jiantaArr:Array;
      
      private var _wandaoArr:Array;
      
      private var _qianggongArr:Array;
      
      private var _junzhuArr:Array;
      
      private var _pause:Boolean;
      
      private var _busy:Boolean;
      
      private var _time:Timer;
      
      private var _direct:int;
      
      private var _config:XiongnuConfig;
      
      public function XiongnuAI(param1:IAI, param2:Number, param3:int, param4:XiongnuConfig)
      {
         super();
         this._fight = param1;
         this._delay = param2;
         this._direct = param3;
         this._config = param4;
         this._gunnerArr = [];
         this._saberArr = [];
         this._shooterArr = [];
         this._bossArr = [];
         this._jiantaArr = [];
         this._qianggongArr = [];
         this._wandaoArr = [];
         this._junzhuArr = [];
         this.init();
      }
      
      public function startAI() : *
      {
         this._fight.addEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
      }
      
      private function init() : *
      {
         this._time = new Timer(this._delay,1);
         if(this._direct == -1)
         {
            this._roleArmy = this._fight.leftSoldiers;
            this._otherArmy = this._fight.rightSoldiers;
         }
         else
         {
            this._roleArmy = this._fight.rightSoldiers;
            this._otherArmy = this._fight.leftSoldiers;
         }
         var _loc1_:int = 0;
         while(_loc1_ < this._otherArmy.length)
         {
            if(this._otherArmy[_loc1_] is Gunner)
            {
               this._gunnerArr.push(this._otherArmy[_loc1_]);
            }
            else if(this._otherArmy[_loc1_] is Saber)
            {
               this._saberArr.push(this._otherArmy[_loc1_]);
            }
            else if(this._otherArmy[_loc1_] is Shooter)
            {
               this._shooterArr.push(this._otherArmy[_loc1_]);
            }
            else if(this._otherArmy[_loc1_] is Boss)
            {
               this._bossArr.push(this._otherArmy[_loc1_]);
            }
            else if(this._otherArmy[_loc1_] is WandaoSoldier)
            {
               this._wandaoArr.push(this._otherArmy[_loc1_]);
            }
            else if(this._otherArmy[_loc1_] is QianggongSoldier)
            {
               this._qianggongArr.push(this._otherArmy[_loc1_]);
            }
            else if(this._otherArmy[_loc1_] is JiantaSoldier)
            {
               this._jiantaArr.push(this._otherArmy[_loc1_]);
            }
            else if(this._otherArmy[_loc1_] is Junzhu)
            {
               this._junzhuArr.push(this._otherArmy[_loc1_]);
            }
            _loc1_++;
         }
      }
      
      private function onEnterFrameHandler(param1:Event) : *
      {
         if(this._busy || this._pause || this._roleArmy.length == 0)
         {
            return;
         }
         var _loc2_:Saber = Tools.randomFromArr(this._saberArr) as Saber;
         var _loc3_:Gunner = Tools.randomFromArr(this._gunnerArr) as Gunner;
         var _loc4_:Shooter = Tools.randomFromArr(this._shooterArr) as Shooter;
         var _loc5_:Boss = Tools.randomFromArr(this._bossArr) as Boss;
         var _loc6_:WandaoSoldier = Tools.randomFromArr(this._wandaoArr,3) as WandaoSoldier;
         var _loc7_:QianggongSoldier = Tools.randomFromArr(this._qianggongArr) as QianggongSoldier;
         var _loc8_:JiantaSoldier = Tools.randomFromArr(this._jiantaArr) as JiantaSoldier;
         var _loc9_:Junzhu = Tools.randomFromArr(this._junzhuArr) as Junzhu;
         var _loc10_:int = int(Math.round(Math.random() * 8)) + 1;
         switch(_loc10_)
         {
            case 8:
               if(_loc9_ != null && _loc9_.canAI)
               {
                  this._busy = true;
                  this.junzhuAttack(_loc9_);
               }
               break;
            case 7:
               if(_loc5_ != null && _loc5_.canAI)
               {
                  this._busy = true;
                  this.bossAttack(_loc5_);
               }
               break;
            case 6:
               if(_loc7_ != null && _loc7_.canAI)
               {
                  this._busy = true;
                  this.qianggongAttack(_loc7_);
               }
               break;
            case 5:
               if(_loc6_ != null)
               {
                  if(_loc6_.canAI)
                  {
                     this._busy = true;
                     this.wandaoAttack(_loc6_);
                  }
                  else if(Math.random() < 0.1)
                  {
                     _loc6_.talk({
                        "text":this._config.xiaoBingTalk(),
                        "delay":1000
                     });
                  }
               }
               break;
            case 4:
               if(_loc8_ != null && _loc8_.canAI)
               {
                  this._busy = true;
                  this.jiantaAttack(_loc8_);
               }
               break;
            case 3:
               if(_loc2_ != null && _loc2_.canAI)
               {
                  this._busy = true;
                  this.saberAttack(_loc2_);
               }
               break;
            case 2:
               if(_loc4_ != null && _loc4_.canAI)
               {
                  this._busy = true;
                  this.shooterAttack(_loc4_);
               }
               break;
            case 1:
               if(_loc3_ != null && _loc3_.canAI)
               {
                  this._busy = true;
                  this.gunnerAttack(_loc3_);
               }
         }
      }
      
      public function stopAI() : *
      {
         this._time.reset();
         this._time.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerCompleteHandler);
         if(this._fight != null)
         {
            this._fight.removeEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
            this._fight = null;
         }
         this._roleArmy = null;
         this._otherArmy = null;
         this._gunnerArr = null;
         this._saberArr = null;
         this._shooterArr = null;
         this._bossArr = null;
         this._wandaoArr = null;
         this._qianggongArr = null;
         this._jiantaArr = null;
      }
      
      public function killSoldier(param1:AbstractSoldier) : *
      {
         var _loc2_:int = -1;
         _loc2_ = int(this._gunnerArr.indexOf(param1));
         if(_loc2_ != -1)
         {
            this._gunnerArr.splice(_loc2_,1);
            return;
         }
         _loc2_ = int(this._saberArr.indexOf(param1));
         if(_loc2_ != -1)
         {
            this._saberArr.splice(_loc2_,1);
            return;
         }
         _loc2_ = int(this._shooterArr.indexOf(param1));
         if(_loc2_ != -1)
         {
            this._shooterArr.splice(_loc2_,1);
            return;
         }
         _loc2_ = int(this._bossArr.indexOf(param1));
         if(_loc2_ != -1)
         {
            this._bossArr.splice(_loc2_,1);
            return;
         }
         _loc2_ = int(this._wandaoArr.indexOf(param1));
         if(_loc2_ != -1)
         {
            this._wandaoArr.splice(_loc2_,1);
            return;
         }
         _loc2_ = int(this._qianggongArr.indexOf(param1));
         if(_loc2_ != -1)
         {
            this._qianggongArr.splice(_loc2_,1);
            return;
         }
         _loc2_ = int(this._jiantaArr.indexOf(param1));
         if(_loc2_ != -1)
         {
            this._jiantaArr.splice(_loc2_,1);
            return;
         }
      }
      
      public function get pause() : Boolean
      {
         return this._pause;
      }
      
      public function get qianggongArr() : Array
      {
         return this._qianggongArr;
      }
      
      public function set pause(param1:Boolean) : *
      {
         this._pause = param1;
      }
      
      public function junzhuAttack(param1:Junzhu) : *
      {
         if(Tools.getJilv(param1.ai / 100) == true)
         {
            this.junzhuAction(param1);
            this.sleep(param1.delay);
         }
         else
         {
            this.sleep(param1.delay / 2);
         }
      }
      
      private function junzhuAction(param1:Junzhu) : *
      {
         var _loc2_:AbstractSoldier = param1.direct == 1 ? this._fight.findSoldier(-1) : this._fight.findSoldier(1);
         var _loc3_:Number = this._fight.getAllDistance(param1,_loc2_);
         var _loc4_:Number = param1.attckDistance * Fight.MERIC;
         if(_loc3_ <= _loc4_)
         {
            param1.fire({"target":_loc2_});
         }
         else if(param1.direct == 1)
         {
            param1.goRight(this._fight.getDistance(param1,this._fight.findSoldier(-1)));
         }
         else
         {
            param1.goLeft(this._fight.getDistance(param1,this._fight.findSoldier(1)));
         }
      }
      
      public function saberAttack(param1:Saber) : *
      {
         if(Tools.getJilv(param1.ai / 100) == true)
         {
            if(param1.direct == 1)
            {
               param1.fire({"distance":this._fight.getAllDistance(param1,this._fight.findSoldier(-1))});
            }
            else
            {
               param1.fire({"distance":this._fight.getAllDistance(param1,this._fight.findSoldier(1))});
            }
            this.sleep(param1.delay);
         }
         else
         {
            this.sleep(param1.delay / 2);
         }
      }
      
      public function gunnerAttack(param1:Gunner) : *
      {
         var _loc2_:int = 0;
         var _loc3_:AbstractSoldier = this._roleArmy[int(Math.random() * this._roleArmy.length)] as AbstractSoldier;
         var _loc4_:Number = _loc3_.x;
         var _loc5_:Number = -45 * param1.direct;
         if(Tools.getJilv(param1.ai / 100) == true)
         {
            if(param1.direct == -1)
            {
               if(_loc4_ < 72)
               {
                  _loc2_ = 90;
               }
               else if(_loc4_ < 154)
               {
                  _loc2_ = 80;
               }
               else if(_loc4_ < 204)
               {
                  _loc2_ = 75;
               }
               else if(_loc4_ < 252)
               {
                  _loc2_ = 70;
               }
               else if(_loc4_ < 321)
               {
                  _loc2_ = 60;
               }
               else if(_loc4_ < 362)
               {
                  _loc2_ = 55;
               }
               else if(_loc4_ < 422)
               {
                  _loc2_ = 45;
               }
               else if(_loc4_ < 476)
               {
                  _loc2_ = 35;
               }
               else if(_loc4_ < 537)
               {
                  _loc2_ = 25;
               }
               else if(_loc4_ < 594)
               {
                  _loc2_ = 10;
               }
               else if(_loc4_ < 629)
               {
                  _loc2_ = 0;
               }
            }
            else if(_loc4_ > 770 - 72)
            {
               _loc2_ = 90;
            }
            else if(_loc4_ > 770 - 154)
            {
               _loc2_ = 80;
            }
            else if(_loc4_ > 770 - 204)
            {
               _loc2_ = 75;
            }
            else if(_loc4_ > 770 - 252)
            {
               _loc2_ = 70;
            }
            else if(_loc4_ > 770 - 321)
            {
               _loc2_ = 60;
            }
            else if(_loc4_ > 770 - 362)
            {
               _loc2_ = 55;
            }
            else if(_loc4_ > 770 - 422)
            {
               _loc2_ = 45;
            }
            else if(_loc4_ > 770 - 476)
            {
               _loc2_ = 35;
            }
            else if(_loc4_ > 770 - 537)
            {
               _loc2_ = 25;
            }
            else if(_loc4_ > 770 - 594)
            {
               _loc2_ = 10;
            }
            else if(_loc4_ > 770 - 629)
            {
               _loc2_ = 0;
            }
            param1.fire({
               "angle":_loc5_,
               "power":_loc2_
            });
            this.sleep(param1.delay);
         }
         else
         {
            this.sleep(param1.delay / 2);
         }
      }
      
      private function shooterAction(param1:Shooter) : *
      {
         var _loc2_:AbstractSoldier = param1.direct == 1 ? this._fight.findSoldier(-1) : this._fight.findSoldier(1);
         var _loc3_:Number = this._fight.getAllDistance(param1,_loc2_);
         if(_loc3_ <= param1.attckDistance * Fight.MERIC)
         {
            param1.fire({"target":_loc2_});
         }
         else if(param1.direct == 1)
         {
            param1.goRight(this._fight.getDistance(param1,this._fight.findSoldier(-1)));
         }
         else
         {
            param1.goLeft(this._fight.getDistance(param1,this._fight.findSoldier(1)));
         }
      }
      
      public function shooterAttack(param1:Shooter) : *
      {
         if(Tools.getJilv(param1.ai / 100) == true)
         {
            this.shooterAction(param1);
            this.sleep(param1.delay);
         }
         else
         {
            this.sleep(param1.delay / 2);
         }
      }
      
      public function sleep(param1:Number) : *
      {
         this._time.reset();
         this._time.delay = int(param1 / 2 + param1 / 2 * Math.random());
         this._time.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerCompleteHandler);
         this._time.start();
      }
      
      private function onTimerCompleteHandler(param1:TimerEvent) : *
      {
         this._time.reset();
         this._busy = false;
      }
      
      public function jiantaAttack(param1:JiantaSoldier) : *
      {
         var _loc2_:AbstractSoldier = null;
         if(Tools.getJilv(param1.ai / 100) == true)
         {
            _loc2_ = param1.direct == 1 ? this._fight.findSoldier(-1) : this._fight.findSoldier(1);
            param1.fire({"target":_loc2_});
            this.sleep(param1.delay);
         }
         else
         {
            this.sleep(param1.delay / 2);
         }
      }
      
      public function wandaoAttack(param1:WandaoSoldier) : *
      {
         if(Tools.getJilv(param1.ai / 100) == true)
         {
            this.wandaoAction(param1);
            this.sleep(param1.delay);
         }
         else
         {
            this.sleep(param1.delay / 2);
         }
      }
      
      private function wandaoAction(param1:WandaoSoldier) : *
      {
         var _loc2_:AbstractSoldier = param1.direct == 1 ? this._fight.findSoldier(-1) : this._fight.findSoldier(1);
         var _loc3_:Number = this._fight.getAllDistance(param1,_loc2_);
         if(_loc3_ <= param1.attckDistance * Fight.MERIC)
         {
            param1.fire({"target":_loc2_});
         }
         else if(param1.direct == 1)
         {
            param1.goRight(this._fight.getDistance(param1,this._fight.findSoldier(-1)));
         }
         else
         {
            param1.goLeft(this._fight.getDistance(param1,this._fight.findSoldier(1)));
         }
      }
      
      public function qianggongAttack(param1:QianggongSoldier) : *
      {
         var _loc2_:AbstractSoldier = null;
         if(Tools.getJilv(param1.ai / 100) == true)
         {
            _loc2_ = Tools.randomFromArr(this._roleArmy);
            param1.fire({"target":_loc2_});
            this.sleep(param1.delay);
         }
         else
         {
            this.sleep(param1.delay / 2);
         }
      }
      
      public function bossAttack(param1:Boss) : *
      {
         if(this._qianggongArr.length == 0)
         {
            param1.zhaohuan(3);
            this.sleep(param1.delay / 2);
         }
         else if(Tools.getJilv(param1.ai / 100) == true)
         {
            if(param1.hp < param1.maxHP * 0.1 && param1.qunCount < 9)
            {
               ++param1.qunCount;
               param1.fire({"attackType":2});
            }
            else if(param1.hp < param1.maxHP * 0.2 && param1.qunCount < 8)
            {
               ++param1.qunCount;
               param1.fire({"attackType":2});
            }
            else if(param1.hp < param1.maxHP * 0.3 && param1.qunCount < 7)
            {
               ++param1.qunCount;
               param1.fire({"attackType":2});
            }
            else if(param1.hp < param1.maxHP * 0.4 && param1.qunCount < 6)
            {
               ++param1.qunCount;
               param1.fire({"attackType":2});
            }
            else if(param1.hp < param1.maxHP * 0.5 && param1.qunCount < 5)
            {
               ++param1.qunCount;
               param1.fire({"attackType":2});
            }
            else if(param1.hp < param1.maxHP * 0.6 && param1.qunCount < 4)
            {
               ++param1.qunCount;
               param1.fire({"attackType":2});
            }
            else if(param1.hp < param1.maxHP * 0.7 && param1.qunCount < 3)
            {
               ++param1.qunCount;
               param1.fire({"attackType":2});
            }
            else if(param1.hp < param1.maxHP * 0.8 && param1.qunCount < 2)
            {
               ++param1.qunCount;
               param1.fire({"attackType":2});
            }
            else if(param1.hp < param1.maxHP * 0.9 && param1.qunCount < 1)
            {
               ++param1.qunCount;
               param1.fire({"attackType":2});
            }
            else if(param1.direct == 1)
            {
               param1.fire({
                  "attackType":1,
                  "distance":this._fight.getAllDistance(param1,this._fight.findSoldier(-1))
               });
            }
            else
            {
               param1.fire({
                  "attackType":1,
                  "distance":this._fight.getAllDistance(param1,this._fight.findSoldier(1))
               });
            }
            this.sleep(param1.delay);
         }
         else
         {
            this.sleep(param1.delay / 2);
         }
      }
   }
}
