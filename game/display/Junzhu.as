package game.display
{
   import com.iflashigame.utils.Tools;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import game.Config;
   import game.Data;
   import game.events.SoldierEvent;
   import game.model.ArmyInfo;
   import game.model.Type;
   
   public class Junzhu extends AbstractSoldier
   {
       
      
      private var _repairTime:Number = 1;
      
      private var _pos:Number;
      
      private var _target:AbstractSoldier;
      
      private var _baoji:Number = 0.2;
      
      private var _area:Number = 75;
      
      public var _canLeft:Boolean = true;
      
      public var _canRight:Boolean = true;
      
      public function Junzhu(param1:ArmyInfo, param2:int = 1, param3:Boolean = false, param4:IWorld = null)
      {
         super(param1,param2,param3,param4);
         _speed = 1.8;
         _timer = new Timer(40);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
      }
      
      override public function fire2(param1:Object = null) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(_isDead)
         {
            return;
         }
         if(param1 != null && param1.target != null)
         {
            removeEventListener(SoldierEvent.MOVE_COMPLETE,this.afterTempMoveHandler);
            removeEventListener(SoldierEvent.FILL_COMPLETE,this.afterTempFireHandler);
            _locked = param1.target as AbstractSoldier;
            if(_locked.isDead == true)
            {
               this.stand();
            }
            else
            {
               if(_cooling == true)
               {
                  trace("弓兵冷冻时间没有到");
               }
               else
               {
                  _loc2_ = _world.getAllDistance(this,_locked);
                  _loc3_ = _armyInfo.attackDistance * Config.MERIC;
                  if(_loc2_ > _loc3_)
                  {
                     addEventListener(SoldierEvent.MOVE_COMPLETE,this.afterTempMoveHandler);
                     if(_direct == 1)
                     {
                        this.goRight(_loc2_ - _loc3_ + 1);
                     }
                     else
                     {
                        this.goLeft(_loc2_ - _loc3_ + 1);
                     }
                  }
                  else
                  {
                     this.fire({"target":_locked});
                  }
               }
               addEventListener(SoldierEvent.FILL_COMPLETE,this.afterTempFireHandler);
            }
         }
         else
         {
            this.stand();
         }
      }
      
      private function afterTempFireHandler(param1:SoldierEvent) : *
      {
         this.fire2({"target":_locked});
      }
      
      private function afterTempMoveHandler(param1:SoldierEvent) : *
      {
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.afterTempMoveHandler);
         var _loc2_:Number = _world.getAllDistance(this,_locked);
         var _loc3_:Number = _armyInfo.attackDistance * Config.MERIC;
         if(_loc2_ > _loc3_)
         {
            this.fire({"target":_world.findSoldier(-_direct)});
         }
         else
         {
            this.fire2({"target":_locked});
         }
      }
      
      override public function fire(param1:Object = null) : void
      {
         if(param1.p2p == null && Tools.getJilv(this._baoji) == true)
         {
            this.baojiAttack(param1);
            return;
         }
         if(_isDead)
         {
            return;
         }
         if(param1 != null && Boolean(param1.target))
         {
            dispatchP2PActionEvent({
               "direct":_direct,
               "code":code,
               "act":"fire",
               "obj":param1.target.code,
               "posX":x,
               "posY":y
            });
            _fireing = true;
            _cooling = true;
            this._canLeft = false;
            this._canRight = false;
            addEventListener(Event.ENTER_FRAME,this.onFireHandler);
            this._target = param1.target;
            _skin.gotoAndPlay("_attackBegin");
         }
      }
      
      override public function baojiAttack(param1:Object = null) : void
      {
         if(_isDead)
         {
            return;
         }
         if(param1 != null && Boolean(param1.target))
         {
            dispatchP2PActionEvent({
               "direct":_direct,
               "code":code,
               "act":"baoji",
               "obj":param1.target.code,
               "posX":x,
               "posY":y
            });
            _fireing = true;
            _cooling = true;
            this._canLeft = false;
            this._canRight = false;
            addEventListener(Event.ENTER_FRAME,this.onFireHandler);
            this._target = param1.target;
            _skin.gotoAndPlay("_baojiBegin");
         }
      }
      
      private function onFireHandler(param1:Event) : *
      {
         if(_skin.currentFrameLabel == "_attackEnd")
         {
            removeEventListener(Event.ENTER_FRAME,this.onFireHandler);
            _fireing = false;
            this._canLeft = true;
            this._canRight = true;
            dispatchEvent(new SoldierEvent(SoldierEvent.FIRE_COMPLETE,true,{
               "target":this._target,
               "type":"putong"
            }));
            _coolingBar.setMax(this._repairTime * 1000,true);
            _timer.addEventListener(TimerEvent.TIMER,this.afterFireHandler);
            _timer.start();
         }
         else if(_skin.currentFrameLabel == "_baojiEnd")
         {
            removeEventListener(Event.ENTER_FRAME,this.onFireHandler);
            _fireing = false;
            this._canLeft = true;
            this._canRight = true;
            dispatchEvent(new SoldierEvent(SoldierEvent.FIRE_COMPLETE,true,{
               "target":this._target,
               "type":"baoji"
            }));
            _coolingBar.setMax(this._repairTime * 1000,true);
            _timer.addEventListener(TimerEvent.TIMER,this.afterFireHandler);
            _timer.start();
         }
      }
      
      private function afterFireHandler(param1:TimerEvent) : *
      {
         if(_coolingBar.getCurrent() == 0)
         {
            _timer.removeEventListener(TimerEvent.TIMER,this.afterFireHandler);
            _coolingBar.setMax(_armyInfo.cd * 1000);
            _timer.addEventListener(TimerEvent.TIMER,this.repairTimeHandler);
         }
         else
         {
            _coolingBar.setCurrent(_coolingBar.getCurrent() - 40);
         }
      }
      
      private function repairTimeHandler(param1:TimerEvent) : *
      {
         if(_coolingBar.getCurrent() == _coolingBar.getMax())
         {
            _timer.removeEventListener(TimerEvent.TIMER,this.repairTimeHandler);
            _cooling = false;
            _timer.reset();
            dispatchEvent(new SoldierEvent(SoldierEvent.FILL_COMPLETE,true));
         }
         else
         {
            _coolingBar.setCurrent(_coolingBar.getCurrent() + 40);
         }
      }
      
      private function onRemoveFromStageHandler(param1:Event) : *
      {
         _skin.stop();
         _world = null;
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
         this.removeAllEvent();
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
      }
      
      override public function stand() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.goLeftHandler);
         removeEventListener(Event.ENTER_FRAME,this.goRightHandler);
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.afterTempMoveHandler);
         removeEventListener(SoldierEvent.FILL_COMPLETE,this.afterTempFireHandler);
         _skin.gotoAndStop("_stand");
         _walking = false;
         _fireing = false;
         _locked = null;
         dispatchP2PActionEvent({
            "direct":_direct,
            "code":code,
            "act":"stand",
            "posX":x,
            "posY":y
         });
      }
      
      override public function goLeft(param1:Number = 0) : void
      {
         if(_isDead)
         {
            return;
         }
         dispatchP2PActionEvent({
            "direct":_direct,
            "code":code,
            "act":"goLeft",
            "obj":param1,
            "posX":x,
            "posY":y
         });
         _walking = true;
         _skin.gotoAndPlay("_moveBegin");
         this._pos = x - param1;
         if(this._pos > stage.stageWidth)
         {
            this._pos = stage.stageWidth;
         }
         if(this._pos < 0)
         {
            this._pos = 0;
         }
         addEventListener(Event.ENTER_FRAME,this.goLeftHandler);
      }
      
      private function goLeftHandler(param1:Event) : *
      {
         var _loc2_:Number = NaN;
         if(_direct == 1)
         {
            _loc2_ = x - _speed;
            if(_loc2_ <= this._pos)
            {
               removeEventListener(Event.ENTER_FRAME,this.goLeftHandler);
               x = this._pos;
               _skin.gotoAndStop("_stand");
               _walking = false;
               dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE,true));
            }
            else
            {
               x = _loc2_;
            }
         }
         else if(_world != null && !_world.checkLeft(this))
         {
            removeEventListener(Event.ENTER_FRAME,this.goLeftHandler);
            _skin.gotoAndStop("_stand");
            _walking = false;
            dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE,true));
         }
         else
         {
            _loc2_ = x - _speed;
            if(_loc2_ <= this._pos)
            {
               removeEventListener(Event.ENTER_FRAME,this.goLeftHandler);
               x = this._pos;
               _skin.gotoAndStop("_stand");
               _walking = false;
               dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE,true));
            }
            else
            {
               x = _loc2_;
            }
         }
      }
      
      override public function goRight(param1:Number = 0) : void
      {
         if(_isDead)
         {
            return;
         }
         dispatchP2PActionEvent({
            "direct":_direct,
            "code":code,
            "act":"goRight",
            "obj":param1,
            "posX":x,
            "posY":y
         });
         _walking = true;
         _skin.gotoAndPlay("_moveBegin");
         this._pos = x + param1;
         if(this._pos > stage.stageWidth)
         {
            this._pos = stage.stageWidth;
         }
         if(this._pos < 0)
         {
            this._pos = 0;
         }
         addEventListener(Event.ENTER_FRAME,this.goRightHandler);
      }
      
      private function goRightHandler(param1:Event) : *
      {
         var _loc2_:Number = NaN;
         if(_direct == -1)
         {
            _loc2_ = x + _speed;
            if(_loc2_ >= this._pos)
            {
               removeEventListener(Event.ENTER_FRAME,this.goRightHandler);
               x = this._pos;
               _skin.gotoAndStop("_stand");
               _walking = false;
               dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE,true));
            }
            else
            {
               x = _loc2_;
            }
         }
         else if(_world != null && !_world.checkRight(this))
         {
            removeEventListener(Event.ENTER_FRAME,this.goRightHandler);
            _skin.gotoAndStop("_stand");
            _walking = false;
            dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE,true));
         }
         else
         {
            _loc2_ = x + _speed;
            if(_loc2_ >= this._pos)
            {
               removeEventListener(Event.ENTER_FRAME,this.goRightHandler);
               x = this._pos;
               _skin.gotoAndStop("_stand");
               _walking = false;
               dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE,true));
            }
            else
            {
               x = _loc2_;
            }
         }
      }
      
      override public function hurt(param1:int, param2:AbstractSoldier = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         if(_isDead)
         {
            return;
         }
         Tools.setBright(this,0.9);
         var _loc6_:Timer;
         (_loc6_ = new Timer(100,1)).addEventListener(TimerEvent.TIMER_COMPLETE,this.onBrightTimerCompleteHandler);
         _loc6_.start();
         if(_armyInfo.tianfu != null)
         {
            _loc3_ = int(Data.getInstance().getAttributes("tianfu",_armyInfo.tianfu,"type"));
            _loc4_ = Number(Data.getInstance().getAttributes("tianfu",_armyInfo.tianfu,"value"));
            if(_loc3_ == 6)
            {
               showHudun();
               param1 = int(param1 * (1 - _loc4_));
            }
         }
         if(param1 < 1)
         {
            param1 = 1;
         }
         _armyInfo.hp -= param1;
         if(_armyInfo.hp < 0)
         {
            _armyInfo.hp = 0;
         }
         _bloodBar.setCurrent(_armyInfo.hp);
         dispatchEvent(new SoldierEvent(SoldierEvent.BEHURT,true,param1));
         if(_armyInfo.hp <= 0)
         {
            this.removeAllEvent();
            addEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
            dead();
            dispatchEvent(new SoldierEvent(SoldierEvent.DEAD,true));
         }
         else if(_armyInfo.tianfu != null)
         {
            _loc3_ = int(Data.getInstance().getAttributes("tianfu",_armyInfo.tianfu,"type"));
            if(_loc3_ == 4)
            {
               _loc4_ = Number(Data.getInstance().getAttributes("tianfu",_armyInfo.tianfu,"value"));
               _loc5_ = int(param1 * _loc4_);
               _armyInfo.hp += _loc5_;
               dispatchEvent(new SoldierEvent(SoldierEvent.HUIFU,true,_loc5_));
            }
            else if(_loc3_ == 5)
            {
               _loc4_ = Number(Data.getInstance().getAttributes("tianfu",_armyInfo.tianfu,"value"));
               if(param2 != null && param2.type != Type.TOUSHICHE && param2.type != Type.FEIDAOBING && param2.type != Type.GONGBING)
               {
                  showFanshang();
                  param2.hurt(param1 * _loc4_);
               }
            }
         }
      }
      
      private function onBrightTimerCompleteHandler(param1:TimerEvent) : *
      {
         Tools.setBright(this,0);
         param1.currentTarget.stop();
         param1.currentTarget.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onBrightTimerCompleteHandler);
      }
      
      override protected function onEnterFrameHandler(param1:Event) : *
      {
         if(_skin.currentFrameLabel == "_deadEnd")
         {
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
            dispatchEvent(new SoldierEvent(SoldierEvent.DEAD_COMPLETE,true));
         }
      }
      
      private function removeAllEvent() : *
      {
         removeEventListener(Event.ENTER_FRAME,this.onFireHandler);
         _timer.reset();
         _timer.removeEventListener(TimerEvent.TIMER,this.afterFireHandler);
         _timer.removeEventListener(TimerEvent.TIMER,this.repairTimeHandler);
         removeEventListener(Event.ENTER_FRAME,this.goLeftHandler);
         removeEventListener(Event.ENTER_FRAME,this.goRightHandler);
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.afterTempMoveHandler);
         removeEventListener(SoldierEvent.FILL_COMPLETE,this.afterTempFireHandler);
      }
      
      override public function get canLeft() : Boolean
      {
         return this._canLeft;
      }
      
      override public function get canRight() : Boolean
      {
         return this._canRight;
      }
   }
}
