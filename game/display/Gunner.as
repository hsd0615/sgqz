package game.display
{
   import com.iflashigame.utils.Tools;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.system.ApplicationDomain;
   import flash.utils.Timer;
   import game.events.SoldierEvent;
   import game.model.ArmyInfo;
   
   public class Gunner extends AbstractSoldier
   {
       
      
      private var _pos:Number;
      
      private var _angle:Number;
      
      private var _power:Number;
      
      private var _ammo:String = "";
      
      private var _repairTime:Number = 1.5;
      
      public function Gunner(param1:ArmyInfo, param2:int = 1, param3:Boolean = false, param4:IWorld = null)
      {
         super(param1,param2,param3,param4);
         _speed = 1.3;
         _timer = new Timer(40);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
      }
      
      override protected function initEvent() : *
      {
         addEventListener(MouseEvent.MOUSE_OVER,super.onMouseOverHandler,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,super.onMouseOutHandler,false,0,true);
         _skin.addEventListener(MouseEvent.CLICK,super.onMouseClickHandler,false,0,true);
      }
      
      override protected function initSkin() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(_armyInfo.skin) as Class;
         _skin = new _loc1_() as MovieClip;
         if(_armyInfo.evolution > 1)
         {
            _skin.scaleX = _direct * 0.6;
            _skin.scaleY = 0.6;
         }
         else
         {
            _skin.scaleX = _direct * 0.65;
            _skin.scaleY = 0.65;
         }
         _skin.mouseChildren = false;
         _skin.buttonMode = true;
         addChild(_skin);
      }
      
      override public function fire(param1:Object = null) : void
      {
         if(_isDead)
         {
            return;
         }
         dispatchP2PActionEvent({
            "direct":_direct,
            "code":code,
            "act":"fire",
            "obj":param1
         });
         addEventListener(Event.ENTER_FRAME,this.onFireHandler);
         _cooling = true;
         _fireing = true;
         _skin.gotoAndPlay("_attackBegin");
         if(param1 != null)
         {
            this._angle = param1.angle;
            this._power = param1.power;
            this._ammo = param1.ammo;
         }
      }
      
      private function onFireHandler(param1:Event) : *
      {
         if(_skin.currentFrameLabel == "_attackEnd")
         {
            _fireing = false;
            removeEventListener(Event.ENTER_FRAME,this.onFireHandler);
            dispatchEvent(new SoldierEvent(SoldierEvent.FIRE_COMPLETE,true,{
               "angle":this._angle,
               "power":this._power,
               "ammo":this._ammo
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
            _skin.gotoAndPlay("_fillBegin");
            addEventListener(Event.ENTER_FRAME,this.onFillHandler);
         }
         else
         {
            _coolingBar.setCurrent(_coolingBar.getCurrent() - 40);
         }
      }
      
      private function onFillHandler(param1:Event) : *
      {
         if(_skin.currentFrameLabel == "_fillEnd")
         {
            removeEventListener(Event.ENTER_FRAME,this.onFillHandler);
            _coolingBar.setMax(_armyInfo.cd * 1000);
            _timer.addEventListener(TimerEvent.TIMER,this.repairTimeHandler);
         }
      }
      
      private function repairTimeHandler(param1:TimerEvent) : *
      {
         if(_coolingBar.getCurrent() == _coolingBar.getMax())
         {
            _timer.removeEventListener(TimerEvent.TIMER,this.repairTimeHandler);
            _cooling = false;
            _timer.reset();
            _skin.gotoAndStop("_stand");
            dispatchEvent(new SoldierEvent(SoldierEvent.FILL_COMPLETE,true));
         }
         else
         {
            _coolingBar.setCurrent(_coolingBar.getCurrent() + 40);
         }
      }
      
      override public function stand() : void
      {
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
         if(_isDead)
         {
            return;
         }
         Tools.setBright(this,0.9);
         var _loc3_:Timer = new Timer(100,1);
         _loc3_.addEventListener(TimerEvent.TIMER_COMPLETE,this.onBrightTimerCompleteHandler);
         _loc3_.start();
         _armyInfo.hp -= param1;
         if(_armyInfo.hp < 0)
         {
            _armyInfo.hp = 0;
         }
         _bloodBar.setCurrent(_armyInfo.hp);
         dispatchEvent(new SoldierEvent(SoldierEvent.BEHURT,true,param1));
         // 吸血
         if(param2 != null && param2.armyInfo != null && param2.armyInfo.equipLifesteal > 0 && !param2.isDead)
         {
            var _lsh:int = int(param1 * param2.armyInfo.equipLifesteal / 100);
            if(_lsh > 0)
            {
               param2.armyInfo.hp += _lsh;
               if(param2.armyInfo.hp > param2.maxHP) param2.armyInfo.hp = param2.maxHP;
               param2.bloodBar.setCurrent(param2.armyInfo.hp);
            }
         }
         if(_armyInfo.hp <= 0)
         {
            this.removeAllEvent();
            addEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
            dispatchEvent(new SoldierEvent(SoldierEvent.DEAD,true));
            dead();
         }
      }
      
      private function onBrightTimerCompleteHandler(param1:TimerEvent) : *
      {
         Tools.setBright(this,0);
         param1.currentTarget.reset();
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
      
      private function onRemoveFromStageHandler(param1:Event) : *
      {
         _world = null;
         _skin.stop();
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
         this.removeAllEvent();
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
      }
      
      private function removeAllEvent() : *
      {
         _timer.reset();
         _timer.removeEventListener(TimerEvent.TIMER,this.afterFireHandler);
         _timer.removeEventListener(TimerEvent.TIMER,this.repairTimeHandler);
         removeEventListener(Event.ENTER_FRAME,this.onFireHandler);
         removeEventListener(Event.ENTER_FRAME,this.onFillHandler);
      }
   }
}
