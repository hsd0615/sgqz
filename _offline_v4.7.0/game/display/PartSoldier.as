package game.display
{
   import com.iflashigame.utils.Tools;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import game.Config;
   import game.Data;
   import game.events.SoldierEvent;
   import game.model.ArmyInfo;
   import game.model.Type;

   /**
    * PNG part-based melee soldier.
    *
    * The original Saber skin is a 60-frame MovieClip. Its labels define the
    * movement, attack and death contracts used by Saber.as. This class keeps
    * those contracts, but drives a joint hierarchy because embedded PNG parts
    * cannot provide a Flash authoring timeline of their own.
    */
   public class PartSoldier extends AbstractSoldier
   {
      private static const ASSET_SCALE:Number = 0.18;
      private static const SKIN_SCALE:Number = 0.65;
      private static const ATTACK_TIME:int = 500;
      private static const DEATH_TIME:int = 1400;

      [Embed(source="../../assets/parts/warrior_part_01_head_right.png")]
      private static const HEAD_RIGHT:Class;
      [Embed(source="../../assets/parts/warrior_part_02_torso.png")]
      private static const TORSO:Class;
      [Embed(source="../../assets/parts/warrior_part_03_waist_skirt.png")]
      private static const WAIST:Class;
      [Embed(source="../../assets/parts/warrior_part_04_rear_arm.png")]
      private static const REAR_ARM:Class;
      [Embed(source="../../assets/parts/warrior_part_05_front_arm.png")]
      private static const FRONT_ARM:Class;
      [Embed(source="../../assets/parts/warrior_part_06_rear_thigh.png")]
      private static const REAR_THIGH:Class;
      [Embed(source="../../assets/parts/warrior_part_07_front_thigh.png")]
      private static const FRONT_THIGH:Class;
      [Embed(source="../../assets/parts/warrior_part_08_rear_boot.png")]
      private static const REAR_BOOT:Class;
      [Embed(source="../../assets/parts/warrior_part_09_front_boot.png")]
      private static const FRONT_BOOT:Class;
      [Embed(source="../../assets/parts/warrior_part_10_spear.png")]
      private static const SPEAR:Class;
      [Embed(source="../../assets/parts/warrior_part_11_head_front.png")]
      private static const HEAD_FRONT:Class;

      private var _repairTime:Number = 1;
      private var _pos:Number;
      private var _canLeft:Boolean = true;
      private var _canRight:Boolean = true;

      private var _body:Sprite;
      private var _torso:Sprite;
      private var _waist:Sprite;
      private var _head:Sprite;
      private var _rearArm:Sprite;
      private var _frontArm:Sprite;
      private var _rearLeg:Sprite;
      private var _frontLeg:Sprite;
      private var _rearBoot:Sprite;
      private var _frontBoot:Sprite;
      private var _spear:Sprite;
      private var _headRight:Bitmap;
      private var _headFront:Bitmap;

      private var _animState:String = "stand";
      private var _animStart:int;

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
         this._body = new Sprite();
         this._skin.addChild(this._body);

         // Back-to-front layer order follows the authored Saber skins.
         this._spear = this.createJoint(SPEAR,760,80,-31,-83);
         this._rearArm = this.createJoint(REAR_ARM,42,38,-19,-91);
         this._rearLeg = this.createJoint(REAR_THIGH,82,22,-11,-42);
         this._rearBoot = this.createJoint(REAR_BOOT,78,20,-12,-17);
         this._torso = this.createJoint(TORSO,159,188,0,-65);
         this._frontLeg = this.createJoint(FRONT_THIGH,92,22,10,-42);
         this._frontBoot = this.createJoint(FRONT_BOOT,79,18,11,-17);
         this._waist = this.createJoint(WAIST,206,30,0,-68);
         this._head = new Sprite();
         this._head.x = 0;
         this._head.y = -94;
         this._headRight = this.createPart(HEAD_RIGHT,176,390);
         this._headFront = this.createPart(HEAD_FRONT,198,418);
         this._headFront.visible = false;
         this._head.addChild(this._headRight);
         this._head.addChild(this._headFront);
         this._frontArm = this.createJoint(FRONT_ARM,38,34,18,-91);

         this._body.addChild(this._spear);
         this._body.addChild(this._rearArm);
         this._body.addChild(this._rearLeg);
         this._body.addChild(this._rearBoot);
         this._body.addChild(this._torso);
         this._body.addChild(this._frontLeg);
         this._body.addChild(this._frontBoot);
         this._body.addChild(this._waist);
         this._body.addChild(this._head);
         this._body.addChild(this._frontArm);

         var _hurtPoint:MovieClip = new MovieClip();
         _hurtPoint.name = "_hurtPoint";
         _hurtPoint.x = 4;
         _hurtPoint.y = -72;
         this._skin.addChild(_hurtPoint);

         this._skin.scaleX = SKIN_SCALE * this._direct;
         this._skin.scaleY = SKIN_SCALE;
         this._skin.mouseChildren = false;
         this._skin.buttonMode = true;
         addChild(this._skin);
         this.resetPose();
      }

      private function createJoint(param1:Class, param2:Number, param3:Number, param4:Number, param5:Number) : Sprite
      {
         var _joint:Sprite = new Sprite();
         _joint.x = param4;
         _joint.y = param5;
         _joint.addChild(this.createPart(param1,param2,param3));
         return _joint;
      }

      private function createPart(param1:Class, param2:Number, param3:Number) : Bitmap
      {
         var _source:Bitmap = new param1() as Bitmap;
         var _part:Bitmap = new Bitmap(_source.bitmapData);
         _part.smoothing = true;
         _part.scaleX = ASSET_SCALE;
         _part.scaleY = ASSET_SCALE;
         _part.x = -param2 * ASSET_SCALE;
         _part.y = -param3 * ASSET_SCALE;
         return _part;
      }

      private function resetPose() : void
      {
         this._body.x = 0;
         this._body.y = 0;
         this._body.rotation = 0;
         this._body.alpha = 1;
         this.resetJoint(this._torso,0,-65);
         this.resetJoint(this._waist,0,-68);
         this.resetJoint(this._head,0,-94);
         this.resetJoint(this._rearArm,-19,-91);
         this.resetJoint(this._frontArm,18,-91);
         this.resetJoint(this._rearLeg,-11,-42);
         this.resetJoint(this._frontLeg,10,-42);
         this.resetJoint(this._rearBoot,-12,-17);
         this.resetJoint(this._frontBoot,11,-17);
         this.resetJoint(this._spear,-31,-83);
         this._headRight.visible = true;
         this._headFront.visible = false;
      }

      private function resetJoint(param1:Sprite, param2:Number, param3:Number) : void
      {
         param1.x = param2;
         param1.y = param3;
         param1.rotation = 0;
         param1.scaleX = 1;
         param1.scaleY = 1;
         param1.alpha = 1;
      }

      private function startAnimation(param1:String) : void
      {
         this._animState = param1;
         this._animStart = getTimer();
         if(!hasEventListener(Event.ENTER_FRAME))
         {
            addEventListener(Event.ENTER_FRAME,this.animatePose);
         }
         else
         {
            removeEventListener(Event.ENTER_FRAME,this.animatePose);
            addEventListener(Event.ENTER_FRAME,this.animatePose);
         }
      }

      private function animatePose(param1:Event) : void
      {
         var _elapsed:int = getTimer() - this._animStart;
         if(this._animState == "walk")
         {
            this.applyWalkPose(_elapsed);
         }
         else if(this._animState == "attack")
         {
            this.applyAttackPose(Math.min(1,_elapsed / ATTACK_TIME));
            if(_elapsed >= ATTACK_TIME)
            {
               this.finishAttack();
            }
         }
         else if(this._animState == "dead")
         {
            this.applyDeathPose(Math.min(1,_elapsed / DEATH_TIME));
            if(_elapsed >= DEATH_TIME)
            {
               removeEventListener(Event.ENTER_FRAME,this.animatePose);
               this._animState = "deadEnd";
            }
         }
      }

      private function applyWalkPose(param1:int) : void
      {
         // The original Saber move segment spans frames 3-11. A roughly
         // 470 ms cycle keeps the foot cadence aligned with its movement speed.
         var _phase:Number = param1 / 75;
         var _stride:Number = Math.sin(_phase);
         var _lift:Number = Math.abs(Math.sin(_phase));
         this._body.y = -2 * _lift;
         this._torso.rotation = -2 * _stride;
         this._head.rotation = 2 * _stride;
         this._rearLeg.rotation = 18 * _stride;
         this._frontLeg.rotation = -18 * _stride;
         this._rearBoot.rotation = -8 * _stride;
         this._frontBoot.rotation = 8 * _stride;
         this._rearArm.rotation = -10 * _stride;
         this._frontArm.rotation = 8 * _stride;
         this._spear.y = -83 - _lift;
         this._spear.rotation = -2 * _stride;
      }

      private function applyAttackPose(param1:Number) : void
      {
         var _amount:Number;
         if(param1 < 0.28)
         {
            _amount = this.easeOut(param1 / 0.28);
            this._body.x = -5 * _amount;
            this._body.y = 2 * _amount;
            this._torso.rotation = -7 * _amount;
            this._head.rotation = 4 * _amount;
            this._spear.x = -31 - 18 * _amount;
            this._spear.rotation = -7 * _amount;
            this._rearArm.rotation = -16 * _amount;
            this._frontArm.rotation = -20 * _amount;
         }
         else if(param1 < 0.62)
         {
            _amount = this.easeOut((param1 - 0.28) / 0.34);
            this._body.x = -5 + 14 * _amount;
            this._body.y = 2 - 4 * _amount;
            this._torso.rotation = -7 + 14 * _amount;
            this._head.rotation = 4 - 7 * _amount;
            this._spear.x = -49 + 62 * _amount;
            this._spear.rotation = -7 + 8 * _amount;
            this._rearArm.rotation = -16 + 22 * _amount;
            this._frontArm.rotation = -20 + 25 * _amount;
            this._rearLeg.rotation = -8 * _amount;
            this._frontLeg.rotation = 12 * _amount;
         }
         else
         {
            _amount = this.easeInOut((param1 - 0.62) / 0.38);
            this._body.x = 9 * (1 - _amount);
            this._body.y = -2 * (1 - _amount);
            this._torso.rotation = 7 * (1 - _amount);
            this._head.rotation = -3 * (1 - _amount);
            this._spear.x = 13 - 44 * _amount;
            this._spear.rotation = 1 * (1 - _amount);
            this._rearArm.rotation = 6 * (1 - _amount);
            this._frontArm.rotation = 5 * (1 - _amount);
            this._rearLeg.rotation = -8 * (1 - _amount);
            this._frontLeg.rotation = 12 * (1 - _amount);
         }
      }

      private function applyDeathPose(param1:Number) : void
      {
         var _fall:Number = this.easeInOut(Math.min(1,param1 / 0.72));
         var _settle:Number = param1 > 0.72 ? (param1 - 0.72) / 0.28 : 0;
         this._headRight.visible = false;
         this._headFront.visible = true;
         this._body.x = -8 * _fall;
         this._body.y = 24 * _fall + 3 * _settle;
         this._body.rotation = -68 * _fall;
         this._torso.rotation = 10 * _fall;
         this._waist.rotation = -7 * _fall;
         this._head.x = 5 * _fall;
         this._head.y = -94 + 13 * _fall;
         this._head.rotation = 28 * _fall;
         this._spear.x = -31 + 30 * _fall;
         this._spear.y = -83 + 42 * _fall;
         this._spear.rotation = 78 * _fall;
         this._rearArm.rotation = -55 * _fall;
         this._frontArm.rotation = 42 * _fall;
         this._rearLeg.rotation = 28 * _fall;
         this._frontLeg.rotation = -34 * _fall;
         this._rearBoot.rotation = -25 * _fall;
         this._frontBoot.rotation = 20 * _fall;
      }

      private function easeOut(param1:Number) : Number
      {
         return 1 - (1 - param1) * (1 - param1);
      }

      private function easeInOut(param1:Number) : Number
      {
         return param1 < 0.5 ? 2 * param1 * param1 : 1 - Math.pow(-2 * param1 + 2,2) / 2;
      }

      override public function stand() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.goLeftHandler);
         removeEventListener(Event.ENTER_FRAME,this.goRightHandler);
         removeEventListener(Event.ENTER_FRAME,this.animatePose);
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.afterTempMoveHandler);
         removeEventListener(SoldierEvent.FILL_COMPLETE,this.afterTempFireHandler);
         this._animState = "stand";
         this._walking = false;
         this._fireing = false;
         this._locked = null;
         this.resetPose();
         dispatchP2PActionEvent({"direct":_direct,"code":code,"act":"stand","posX":x,"posY":y});
      }

      override public function goLeft(param1:Number = 0) : void
      {
         if(_isDead) return;
         dispatchP2PActionEvent({"direct":_direct,"code":code,"act":"goLeft","obj":param1,"posX":x,"posY":y});
         this._walking = true;
         this._pos = Math.max(0,Math.min(stage.stageWidth,x - param1));
         this.startAnimation("walk");
         addEventListener(Event.ENTER_FRAME,this.goLeftHandler);
      }

      override public function goRight(param1:Number = 0) : void
      {
         if(_isDead) return;
         dispatchP2PActionEvent({"direct":_direct,"code":code,"act":"goRight","obj":param1,"posX":x,"posY":y});
         this._walking = true;
         this._pos = Math.max(0,Math.min(stage.stageWidth,x + param1));
         this.startAnimation("walk");
         addEventListener(Event.ENTER_FRAME,this.goRightHandler);
      }

      private function goLeftHandler(param1:Event) : void
      {
         if(_direct != 1 && _world != null && !_world.checkLeft(this))
         {
            this.finishMove();
            return;
         }
         var _next:Number = x - _speed;
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

      private function goRightHandler(param1:Event) : void
      {
         if(_direct != -1 && _world != null && !_world.checkRight(this))
         {
            this.finishMove();
            return;
         }
         var _next:Number = x + _speed;
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
         removeEventListener(Event.ENTER_FRAME,this.animatePose);
         this._animState = "stand";
         this._walking = false;
         this.resetPose();
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
         dispatchP2PActionEvent({"direct":_direct,"code":code,"act":"fire","posX":x,"posY":y});
         this._fireing = true;
         this._cooling = true;
         this._canLeft = false;
         this._canRight = false;
         this.resetPose();
         this.startAnimation("attack");
      }

      private function finishAttack() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.animatePose);
         this._animState = "stand";
         this._fireing = false;
         this._canLeft = true;
         this._canRight = true;
         this.resetPose();
         dispatchEvent(new SoldierEvent(SoldierEvent.FIRE_COMPLETE,true));
         _coolingBar.setMax(this._repairTime * 1000,true);
         _timer.addEventListener(TimerEvent.TIMER,this.afterFireHandler);
         _timer.start();
      }

      private function onMoveCompleteHandler(param1:SoldierEvent) : void
      {
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.onMoveCompleteHandler);
         this.fire();
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

      override public function dead() : void
      {
         mouseChildren = false;
         mouseEnabled = false;
         _isDead = true;
         this.resetPose();
         this.startAnimation("dead");
      }

      override protected function onEnterFrameHandler(param1:Event) : *
      {
         if(this._animState == "deadEnd")
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
            this.removeAllEvents();
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
         this.removeAllEvents();
      }

      private function removeAllEvents() : void
      {
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.onMoveCompleteHandler);
         removeEventListener(Event.ENTER_FRAME,this.goLeftHandler);
         removeEventListener(Event.ENTER_FRAME,this.goRightHandler);
         removeEventListener(Event.ENTER_FRAME,this.animatePose);
         removeEventListener(SoldierEvent.MOVE_COMPLETE,this.afterTempMoveHandler);
         removeEventListener(SoldierEvent.FILL_COMPLETE,this.afterTempFireHandler);
         _timer.reset();
         _timer.removeEventListener(TimerEvent.TIMER,this.afterFireHandler);
         _timer.removeEventListener(TimerEvent.TIMER,this.repairTimeHandler);
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
