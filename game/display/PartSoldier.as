package game.display
{
   import com.iflashigame.utils.Tools;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import game.Config;
   import game.Data;
   import game.events.SoldierEvent;
   import game.model.ArmyInfo;
   import game.model.Type;

   /**
    * Long-spear soldier rendered from the original generalSkin_7_0 timeline.
    * The atlas is generated with the original 65-frame display-list matrices,
    * depths and labels; only the authored body-part artwork is replaced.
    */
   public class PartSoldier extends AbstractSoldier
   {
      private static const FRAME_TIME:int = 40;
      private static const CELL_WIDTH:int = 256;
      private static const CELL_HEIGHT:int = 160;
      private static const COLUMNS:int = 13;
      private static const ORIGIN_X:int = 128;
      private static const ORIGIN_Y:int = 130;

      private static const STAND_FRAME:int = 1;
      private static const MOVE_BEGIN:int = 3;
      private static const MOVE_END:int = 12;
      private static const ATTACK_BEGIN:int = 13;
      private static const ATTACK_END:int = 17;
      private static const DEAD_BEGIN:int = 31;
      private static const DEAD_END:int = 65;

      [Embed(source="../../assets/parts/longspear/longspear_atlas.png")]
      private static const LONGSPEAR_ATLAS:Class;

      private var _repairTime:Number = 1;
      private var _pos:Number;
      private var _canLeft:Boolean = true;
      private var _canRight:Boolean = true;

      private var _atlasData:BitmapData;
      private var _frameData:BitmapData;
      private var _frameBitmap:Bitmap;
      private var _visualBounds:Rectangle;
      private var _currentFrame:int = STAND_FRAME;
      private var _playStartFrame:int;
      private var _playEndFrame:int;
      private var _playStartedAt:int;
      private var _playLoop:Boolean;

      public function PartSoldier(param1:ArmyInfo, param2:int = 1, param3:Boolean = false, param4:IWorld = null)
      {
         super(param1,param2,param3,param4);
         _speed = 3;
         _timer = new Timer(40);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
      }

      override protected function initSkin() : *
      {
         this._skin = new MovieClip();
         var _atlas:Bitmap = new LONGSPEAR_ATLAS() as Bitmap;
         this._atlasData = _atlas.bitmapData;
         this._frameData = new BitmapData(CELL_WIDTH,CELL_HEIGHT,true,0);
         this._frameBitmap = new Bitmap(this._frameData);
         this._frameBitmap.smoothing = true;
         this._frameBitmap.x = -ORIGIN_X;
         this._frameBitmap.y = -ORIGIN_Y;
         this._skin.addChild(this._frameBitmap);

         var _hurtPoint:MovieClip = new MovieClip();
         _hurtPoint.name = "_hurtPoint";
         _hurtPoint.x = -42;
         _hurtPoint.y = -70;
         this._skin.addChild(_hurtPoint);

         this._skin.scaleX = 0.65 * this._direct;
         this._skin.scaleY = 0.65;
         this._skin.mouseChildren = false;
         this._skin.buttonMode = true;
         addChild(this._skin);
         this.showFrame(STAND_FRAME);
      }

      private function showFrame(param1:int) : void
      {
         if(param1 < 1) param1 = 1;
         if(param1 > DEAD_END) param1 = DEAD_END;
         this._currentFrame = param1;
         var _index:int = param1 - 1;
         var _source:Rectangle = new Rectangle(
            _index % COLUMNS * CELL_WIDTH,
            int(_index / COLUMNS) * CELL_HEIGHT,
            CELL_WIDTH,
            CELL_HEIGHT
         );
         this._frameData.fillRect(this._frameData.rect,0);
         this._frameData.copyPixels(this._atlasData,_source,new Point(0,0),null,null,true);
         this._visualBounds = this._frameData.getColorBoundsRect(0xFF000000,0x00000000,false);
      }

      private function playFrames(param1:int, param2:int, param3:Boolean) : void
      {
         this._playStartFrame = param1;
         this._playEndFrame = param2;
         this._playLoop = param3;
         this._playStartedAt = getTimer();
         this.showFrame(param1);
         removeEventListener(Event.ENTER_FRAME,this.onTimelineFrame);
         addEventListener(Event.ENTER_FRAME,this.onTimelineFrame);
      }

      private function stopAt(param1:int) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onTimelineFrame);
         this.showFrame(param1);
      }

      private function onTimelineFrame(param1:Event) : void
      {
         var _frameCount:int = this._playEndFrame - this._playStartFrame + 1;
         var _offset:int = int((getTimer() - this._playStartedAt) / FRAME_TIME);
         if(this._playLoop)
         {
            this.showFrame(this._playStartFrame + _offset % _frameCount);
         }
         else if(_offset >= _frameCount - 1)
         {
            this.stopAt(this._playEndFrame);
         }
         else
         {
            this.showFrame(this._playStartFrame + _offset);
         }
      }

      override public function stand() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.goLeftHandler);
         removeEventListener(Event.ENTER_FRAME,this.goRightHandler);
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.afterTempMoveHandler);
         removeEventListener(SoldierEvent.FILL_COMPLETE,this.afterTempFireHandler);
         this.stopAt(STAND_FRAME);
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
         if(_isDead) return;
         dispatchP2PActionEvent({
            "direct":_direct,
            "code":code,
            "act":"goLeft",
            "obj":param1,
            "posX":x,
            "posY":y
         });
         _walking = true;
         this.playFrames(MOVE_BEGIN,MOVE_END - 1,true);
         this._pos = Math.max(0,Math.min(stage.stageWidth,x - param1));
         addEventListener(Event.ENTER_FRAME,this.goLeftHandler);
      }

      private function goLeftHandler(param1:Event) : void
      {
         var _next:Number;
         if(_direct != 1 && _world != null && !_world.checkLeft(this))
         {
            this.finishMove();
            return;
         }
         _next = x - _speed;
         if(_next <= this._pos)
         {
            x = this._pos;
            this.finishMove();
         }
         else
         {
            x = _next;
         }
      }

      override public function goRight(param1:Number = 0) : void
      {
         if(_isDead) return;
         dispatchP2PActionEvent({
            "direct":_direct,
            "code":code,
            "act":"goRight",
            "obj":param1,
            "posX":x,
            "posY":y
         });
         _walking = true;
         this.playFrames(MOVE_BEGIN,MOVE_END - 1,true);
         this._pos = Math.max(0,Math.min(stage.stageWidth,x + param1));
         addEventListener(Event.ENTER_FRAME,this.goRightHandler);
      }

      private function goRightHandler(param1:Event) : void
      {
         var _next:Number;
         if(_direct != -1 && _world != null && !_world.checkRight(this))
         {
            this.finishMove();
            return;
         }
         _next = x + _speed;
         if(_next >= this._pos)
         {
            x = this._pos;
            this.finishMove();
         }
         else
         {
            x = _next;
         }
      }

      private function finishMove() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.goLeftHandler);
         removeEventListener(Event.ENTER_FRAME,this.goRightHandler);
         this.stopAt(STAND_FRAME);
         _walking = false;
         dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE,true));
      }

      override public function fire(param1:Object = null) : void
      {
         if(_isDead) return;
         if(param1 != null && Boolean(param1.distance))
         {
            addEventListener(SoldierEvent.MOVE_COMPLETE,this.onMoveCompleteHandler);
            if(_direct == 1) this.goRight(param1.distance); else this.goLeft(param1.distance);
            return;
         }
         dispatchP2PActionEvent({
            "direct":_direct,
            "code":code,
            "act":"fire",
            "posX":x,
            "posY":y
         });
         addEventListener(Event.ENTER_FRAME,this.onFireHandler);
         _fireing = true;
         _cooling = true;
         this._canLeft = false;
         this._canRight = false;
         this.playFrames(ATTACK_BEGIN,ATTACK_END,false);
      }

      private function onMoveCompleteHandler(param1:SoldierEvent) : void
      {
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.onMoveCompleteHandler);
         this.fire();
      }

      private function onFireHandler(param1:Event) : void
      {
         if(this._currentFrame == ATTACK_END)
         {
            removeEventListener(Event.ENTER_FRAME,this.onFireHandler);
            _fireing = false;
            this._canLeft = true;
            this._canRight = true;
            dispatchEvent(new SoldierEvent(SoldierEvent.FIRE_COMPLETE,true));
            _coolingBar.setMax(this._repairTime * 1000,true);
            _timer.addEventListener(TimerEvent.TIMER,this.afterFireHandler);
            _timer.start();
         }
      }

      private function afterFireHandler(param1:TimerEvent) : void
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

      private function repairTimeHandler(param1:TimerEvent) : void
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

      override public function fire2(param1:Object = null) : void
      {
         if(_isDead) return;
         if(param1 == null || param1.target == null)
         {
            this.stand();
            return;
         }
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.afterTempMoveHandler);
         removeEventListener(SoldierEvent.FILL_COMPLETE,this.afterTempFireHandler);
         _locked = param1.target as AbstractSoldier;
         if(_locked == null || _locked.isDead)
         {
            this.stand();
            return;
         }
         if(_cooling) return;
         var _distance:Number = _world.getAllDistance(this,_locked);
         var _range:Number = _armyInfo.attackDistance * Config.MERIC;
         if(_distance > _range)
         {
            addEventListener(SoldierEvent.MOVE_COMPLETE,this.afterTempMoveHandler);
            if(_direct == 1) this.goRight(_distance - _range); else this.goLeft(_distance - _range);
         }
         else
         {
            this.fire();
         }
         addEventListener(SoldierEvent.FILL_COMPLETE,this.afterTempFireHandler);
      }

      private function afterTempFireHandler(param1:SoldierEvent) : void
      {
         this.fire2({"target":_locked});
      }

      private function afterTempMoveHandler(param1:SoldierEvent) : void
      {
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.afterTempMoveHandler);
         if(_locked == null || _locked.isDead)
         {
            this.stand();
         }
         else if(_world.getAllDistance(this,_locked) > _armyInfo.attackDistance * Config.MERIC)
         {
            this.fire();
         }
         else
         {
            this.fire2({"target":_locked});
         }
      }

      override public function dead() : void
      {
         mouseChildren = false;
         mouseEnabled = false;
         _isDead = true;
         this.playFrames(DEAD_BEGIN,DEAD_END,false);
      }

      override protected function onEnterFrameHandler(param1:Event) : *
      {
         if(this._currentFrame == DEAD_END)
         {
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
            dispatchEvent(new SoldierEvent(SoldierEvent.DEAD_COMPLETE,true));
         }
      }

      override public function hurt(param1:int, param2:AbstractSoldier = null) : void
      {
         var _talentType:int;
         var _talentValue:Number;
         if(_isDead) return;
         Tools.setBright(this,0.9);
         var _brightTimer:Timer = new Timer(100,1);
         _brightTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onBrightTimerCompleteHandler);
         _brightTimer.start();
         if(_armyInfo.tianfu != null)
         {
            _talentType = int(Data.getInstance().getAttributes("tianfu",_armyInfo.tianfu,"type"));
            _talentValue = Number(Data.getInstance().getAttributes("tianfu",_armyInfo.tianfu,"value"));
            if(_talentType == 6)
            {
               showHudun();
               param1 = int(param1 * (1 - _talentValue));
            }
         }
         if(param1 < 1) param1 = 1;
         _armyInfo.hp -= param1;
         if(_armyInfo.hp < 0) _armyInfo.hp = 0;
         _bloodBar.setCurrent(_armyInfo.hp);
         dispatchEvent(new SoldierEvent(SoldierEvent.BEHURT,true,param1));
         if(param2 != null && param2.armyInfo != null && param2.armyInfo.equipLifesteal > 0 && !param2.isDead)
         {
            var _heal:int = int(param1 * param2.armyInfo.equipLifesteal / 100);
            if(_heal > 0)
            {
               param2.armyInfo.hp += _heal;
               if(param2.hp > param2.maxHP) param2.armyInfo.hp = param2.maxHP;
               param2.bloodBar.setCurrent(param2.hp);
               param2.dispatchEvent(new SoldierEvent(SoldierEvent.HUIFU,true,_heal));
            }
         }
         if(_armyInfo.hp <= 0)
         {
            this.removeAllEvent();
            addEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
            this.dead();
            dispatchEvent(new SoldierEvent(SoldierEvent.DEAD,true));
         }
         else if(_armyInfo.tianfu != null)
         {
            _talentType = int(Data.getInstance().getAttributes("tianfu",_armyInfo.tianfu,"type"));
            if(_talentType == 4)
            {
               _talentValue = Number(Data.getInstance().getAttributes("tianfu",_armyInfo.tianfu,"value"));
               var _recovery:int = int(param1 * _talentValue);
               _armyInfo.hp += _recovery;
               dispatchEvent(new SoldierEvent(SoldierEvent.HUIFU,true,_recovery));
            }
            else if(_talentType == 5)
            {
               _talentValue = Number(Data.getInstance().getAttributes("tianfu",_armyInfo.tianfu,"value"));
               if(param2 != null && param2.type != Type.TOUSHICHE && param2.type != Type.FEIDAOBING && param2.type != Type.GONGBING)
               {
                  showFanshang();
                  param2.hurt(param1 * _talentValue);
               }
            }
         }
      }

      private function onBrightTimerCompleteHandler(param1:TimerEvent) : void
      {
         Tools.setBright(this,0);
         param1.currentTarget.stop();
         param1.currentTarget.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onBrightTimerCompleteHandler);
      }

      private function onRemoveFromStageHandler(param1:Event) : void
      {
         _world = null;
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
         this.removeAllEvent();
         if(this._frameData != null) this._frameData.dispose();
      }

      private function removeAllEvent() : void
      {
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.onMoveCompleteHandler);
         removeEventListener(Event.ENTER_FRAME,this.onFireHandler);
         removeEventListener(Event.ENTER_FRAME,this.onTimelineFrame);
         removeEventListener(Event.ENTER_FRAME,this.goLeftHandler);
         removeEventListener(Event.ENTER_FRAME,this.goRightHandler);
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.afterTempMoveHandler);
         removeEventListener(SoldierEvent.FILL_COMPLETE,this.afterTempFireHandler);
         _timer.reset();
         _timer.removeEventListener(TimerEvent.TIMER,this.afterFireHandler);
         _timer.removeEventListener(TimerEvent.TIMER,this.repairTimeHandler);
      }

      override public function getRectangle(param1:DisplayObject) : Rectangle
      {
         if(this._visualBounds == null || this._visualBounds.isEmpty())
         {
            return super.getRectangle(param1);
         }
         var _topLeft:Point = this._skin.localToGlobal(new Point(
            this._visualBounds.x - ORIGIN_X,
            this._visualBounds.y - ORIGIN_Y
         ));
         var _bottomRight:Point = this._skin.localToGlobal(new Point(
            this._visualBounds.right - ORIGIN_X,
            this._visualBounds.bottom - ORIGIN_Y
         ));
         _topLeft = param1.globalToLocal(_topLeft);
         _bottomRight = param1.globalToLocal(_bottomRight);
         return new Rectangle(
            Math.min(_topLeft.x,_bottomRight.x),
            Math.min(_topLeft.y,_bottomRight.y),
            Math.abs(_bottomRight.x - _topLeft.x),
            Math.abs(_bottomRight.y - _topLeft.y)
         );
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
