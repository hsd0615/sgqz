package game.display
{
   import com.iflashigame.utils.Tools;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.utils.Timer;
   import game.events.SoldierEvent;
   import game.model.ArmyInfo;
   import game.ui.SkinCode;
   
   public class WandaoSoldier extends AbstractSoldier
   {
       
      
      private var _repairTime:Number = 1;
      
      private var _pos:Number;
      
      private var _target:AbstractSoldier;
      
      public var _canLeft:Boolean = true;
      
      public var _canRight:Boolean = true;
      
      public function WandaoSoldier(param1:ArmyInfo, param2:int = 1, param3:Boolean = false, param4:IWorld = null)
      {
         super(param1,param2,param3,param4);
         _speed = 1.8;
         _timer = new Timer(40);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
      }
      
      override protected function initSkin() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(_armyInfo.skin) as Class;
         _skin = new _loc1_() as MovieClip;
         _skin.scaleX = _direct * 0.75;
         _skin.scaleY = 0.75;
         _skin.mouseChildren = false;
         _skin.buttonMode = true;
         _skin.doubleClickEnabled = true;
         addChild(_skin);
      }
      
      override protected function createName() : *
      {
         var _loc1_:Class = null;
         _nameTF = new TextField();
         _nameTF.selectable = false;
         _nameTF.text = _armyInfo.name;
         _nameTF.mouseEnabled = false;
         _nameTF.width = _nameTF.textWidth + 4;
         _nameTF.height = _nameTF.textHeight + 4;
         _nameTF.y = _bloodBar.y - 20;
         _nameTF.x = -_nameTF.width / 2;
         _nameTF.filters = [new GlowFilter(13421772,1,2,2,50)];
         _nameTF.mouseEnabled = false;
         addChild(_nameTF);
         if(_armyInfo.feature > 0)
         {
            _loc1_ = ApplicationDomain.currentDomain.getDefinition(SkinCode.ATTACK_ICON) as Class;
            _icon = new _loc1_() as MovieClip;
            _icon.mouseChildren = false;
            _icon.mouseEnabled = false;
            _nameTF.x += _icon.width / 2;
            _icon.x = _nameTF.x - _icon.width;
            _icon.y = _nameTF.y;
            addChild(_icon);
            _icon.gotoAndStop(_armyInfo.feature);
         }
      }
      
      override public function fire(param1:Object = null) : void
      {
         if(_isDead)
         {
            return;
         }
         if(param1 != null && Boolean(param1.target))
         {
            _fireing = true;
            _cooling = true;
            this._canLeft = false;
            this._canRight = false;
            addEventListener(Event.ENTER_FRAME,this.onFireHandler);
            this._target = param1.target;
            _skin.gotoAndPlay("_attackBegin");
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
            dispatchEvent(new SoldierEvent(SoldierEvent.FIRE_COMPLETE,true,{"target":this._target}));
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
      
      override public function goLeft(param1:Number = 0) : void
      {
         if(_isDead)
         {
            return;
         }
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
            dead();
            dispatchEvent(new SoldierEvent(SoldierEvent.DEAD,true));
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
