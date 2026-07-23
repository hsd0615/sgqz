package game.display
{
   import com.greensock.TweenLite;
   import com.iflashigame.utils.Tools;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import game.Config;
   import game.Data;
   import game.events.SoldierEvent;
   import game.model.ArmyInfo;
   import game.model.Type;

   public class PartSoldier extends AbstractSoldier
   {

      // === 嵌入11张PNG身体部件 ===
      [Embed(source="../../assets/parts/warrior_part_01_head_right.png")]
      private static const HEAD_R:Class;

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
      private static const HEAD_F:Class;

      // === 部件Bitmap引用 ===
      private var _head:Bitmap;
      private var _headF:Bitmap;
      private var _torso:Bitmap;
      private var _waist:Bitmap;
      private var _rearArm:Bitmap;
      private var _frontArm:Bitmap;
      private var _rearThigh:Bitmap;
      private var _frontThigh:Bitmap;
      private var _rearBoot:Bitmap;
      private var _frontBoot:Bitmap;
      private var _spear:Bitmap;

      // === 部件容器(用于组合旋转+位移) ===
      private var _armContainer:MovieClip;
      private var _spearContainer:MovieClip;
      private var _thighContainer:MovieClip;
      private var _bodyContainer:MovieClip;

      // === 动画状态 ===
      private var _animState:String = "_stand";
      private var _walkPhase:Number = 0;
      private var _repairTime:Number = 1;
      private var _pos:Number;
      private var _canLeft:Boolean = true;
      private var _canRight:Boolean = true;

      // === 部件锚点偏移(相对于_skin原点, 可调整) ===
      // 原点定位在角色脚底中心
      private static const BODY_OX:Number = -80;
      private static const BODY_OY:Number = -280;

      public function PartSoldier(param1:ArmyInfo, param2:int = 1, param3:Boolean = false, param4:IWorld = null)
      {
         super(param1, param2, param3, param4);
         _speed = 3;
         _timer = new Timer(40);
         addEventListener(Event.REMOVED_FROM_STAGE, this.onRemoveFromStageHandler);
      }

      override protected function initSkin() : *
      {
         // 创建皮肤容器MovieClip
         this._skin = new MovieClip();
         this._skin.mouseChildren = false;
         this._skin.buttonMode = true;

         // 初始化所有身体部件Bitmap ([Embed]图片为BitmapAsset,取bitmapData)
         _rearBoot = new Bitmap(Bitmap(new REAR_BOOT()).bitmapData.clone());
         _frontBoot = new Bitmap(Bitmap(new FRONT_BOOT()).bitmapData.clone());
         _rearThigh = new Bitmap(Bitmap(new REAR_THIGH()).bitmapData.clone());
         _frontThigh = new Bitmap(Bitmap(new FRONT_THIGH()).bitmapData.clone());
         _rearArm = new Bitmap(Bitmap(new REAR_ARM()).bitmapData.clone());
         _frontArm = new Bitmap(Bitmap(new FRONT_ARM()).bitmapData.clone());
         _torso = new Bitmap(Bitmap(new TORSO()).bitmapData.clone());
         _waist = new Bitmap(Bitmap(new WAIST()).bitmapData.clone());
         _head = new Bitmap(Bitmap(new HEAD_R()).bitmapData.clone());
         _headF = new Bitmap(Bitmap(new HEAD_F()).bitmapData.clone());
         _spear = new Bitmap(Bitmap(new SPEAR()).bitmapData.clone());

         // 创建容器用于组合动画(臂+矛一起移动)
         _armContainer = new MovieClip();
         _spearContainer = new MovieClip();
         _thighContainer = new MovieClip();
         _bodyContainer = new MovieClip();

         // 组装图层(从后到前)
         // Layer 0: 后腿+后靴
         _skin.addChild(_rearBoot);
         _skin.addChild(_rearThigh);
         // Layer 1: 身体(躯干+腰裙)
         _bodyContainer.addChild(_waist);
         _bodyContainer.addChild(_torso);
         _skin.addChild(_bodyContainer);
         // Layer 2: 前腿+前靴
         _thighContainer.addChild(_frontThigh);
         _thighContainer.addChild(_frontBoot);
         _skin.addChild(_thighContainer);
         // Layer 3: 后臂
         _skin.addChild(_rearArm);
         // Layer 4: 武器(长矛)
         _spearContainer.addChild(_spear);
         _skin.addChild(_spearContainer);
         // Layer 5: 前臂
         _armContainer.addChild(_frontArm);
         _skin.addChild(_armContainer);
         // Layer 6: 头部
         _skin.addChild(_head);
         _skin.addChild(_headF);

         // 设置初始位置(所有部件原点在脚底)
         this.setPartPositions();

         // 初始显示侧脸, 隐藏正面脸
         _headF.visible = false;

         // 缩放
         this._skin.scaleX = 0.65 * this._direct;
         this._skin.scaleY = 0.65;

         addChild(this._skin);
      }

      /**
       * 设置所有部件的初始锚点位置
       * 坐标系: 原点在角色脚底
       */
      private function setPartPositions() : void
      {
         // 后靴(左后)
         _rearBoot.x = BODY_OX - 15;
         _rearBoot.y = BODY_OY + 100;
         // 后大腿
         _rearThigh.x = BODY_OX - 10;
         _rearThigh.y = BODY_OY + 40;

         // 身体容器
         _bodyContainer.x = BODY_OX;
         _bodyContainer.y = BODY_OY;
         // 腰裙(在躯干下方)
         _waist.x = 0;
         _waist.y = 80;
         // 躯干
         _torso.x = 0;
         _torso.y = 0;

         // 前大腿
         _frontThigh.x = 0;
         _frontThigh.y = 40;
         // 前靴
         _frontBoot.x = 0;
         _frontBoot.y = 100;
         // 大腿容器
         _thighContainer.x = BODY_OX + 10;
         _thighContainer.y = BODY_OY;

         // 后臂
         _rearArm.x = BODY_OX + 10;
         _rearArm.y = BODY_OY + 20;

         // 长矛(在武器容器中)
         _spear.x = 0;
         _spear.y = 0;
         _spearContainer.x = BODY_OX + 50;
         _spearContainer.y = BODY_OY + 30;

         // 前臂(在前臂容器中)
         _frontArm.x = 0;
         _frontArm.y = 0;
         // 前臂容器
         _armContainer.x = BODY_OX + 40;
         _armContainer.y = BODY_OY + 20;

         // 头部
         _head.x = BODY_OX + 10;
         _head.y = BODY_OY - 40;
         _headF.x = BODY_OX + 10;
         _headF.y = BODY_OY - 50;
      }

      // ============================================================
      // 动画方法
      // ============================================================

      override public function stand() : void
      {
         removeEventListener(Event.ENTER_FRAME, this.goLeftHandler);
         removeEventListener(Event.ENTER_FRAME, this.goRightHandler);
         removeEventListener(Event.ENTER_FRAME, this.onWalkAnimHandler);
         removeEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
         removeEventListener(SoldierEvent.MOVE_COMPLETE, this.afterTempMoveHandler);
         removeEventListener(SoldierEvent.FILL_COMPLETE, this.afterTempFireHandler);
         TweenLite.killTweensOf(_armContainer);
         TweenLite.killTweensOf(_spearContainer);
         TweenLite.killTweensOf(_bodyContainer);
         this.setPartPositions();
         _animState = "_stand";
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
         _animState = "_moveBegin";
         _walkPhase = 0;
         this._pos = x - param1;
         if(this._pos > stage.stageWidth) this._pos = stage.stageWidth;
         if(this._pos < 0) this._pos = 0;
         addEventListener(Event.ENTER_FRAME, this.goLeftHandler);
         addEventListener(Event.ENTER_FRAME, this.onWalkAnimHandler);
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
         _animState = "_moveBegin";
         _walkPhase = 0;
         this._pos = x + param1;
         if(this._pos > stage.stageWidth) this._pos = stage.stageWidth;
         if(this._pos < 0) this._pos = 0;
         addEventListener(Event.ENTER_FRAME, this.goRightHandler);
         addEventListener(Event.ENTER_FRAME, this.onWalkAnimHandler);
      }

      /**
       * 步行动画 — 每帧更新部件旋转
       */
      private function onWalkAnimHandler(param1:Event) : void
      {
         if(!_walking) return;
         _walkPhase += 0.15;
         var _swing:Number = Math.sin(_walkPhase) * 15;  // ±15度摆动
         var _bob:Number = Math.abs(Math.sin(_walkPhase * 2)) * 3;  // 身体弹跳

         // 手臂交替摆动
         _armContainer.rotation = _swing;
         _rearArm.rotation = -_swing * 0.5;

         // 大腿交替摆动
         _thighContainer.rotation = -_swing * 0.7;
         _rearThigh.rotation = _swing * 0.7;

         // 身体弹跳
         _bodyContainer.y = BODY_OY - _bob;
         _head.y = BODY_OY - 40 - _bob;
         _armContainer.y = BODY_OY + 20 - _bob;
         _spearContainer.y = BODY_OY + 30 - _bob;
      }

      private function goLeftHandler(param1:Event) : void
      {
         var _loc2_:Number;
         if(_direct == 1)
         {
            _loc2_ = x - _speed;
            if(_loc2_ <= this._pos)
            {
               removeEventListener(Event.ENTER_FRAME, this.goLeftHandler);
               removeEventListener(Event.ENTER_FRAME, this.onWalkAnimHandler);
               x = this._pos;
               _animState = "_moveEnd";
               _walking = false;
               this.stand();
               dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE, true));
            }
            else { x = _loc2_; }
         }
         else if(_world != null && !_world.checkLeft(this))
         {
            removeEventListener(Event.ENTER_FRAME, this.goLeftHandler);
            removeEventListener(Event.ENTER_FRAME, this.onWalkAnimHandler);
            _animState = "_moveEnd";
            _walking = false;
            this.stand();
            dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE, true));
         }
         else
         {
            _loc2_ = x - _speed;
            if(_loc2_ <= this._pos)
            {
               removeEventListener(Event.ENTER_FRAME, this.goLeftHandler);
               removeEventListener(Event.ENTER_FRAME, this.onWalkAnimHandler);
               x = this._pos;
               _animState = "_moveEnd";
               _walking = false;
               this.stand();
               dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE, true));
            }
            else { x = _loc2_; }
         }
      }

      private function goRightHandler(param1:Event) : void
      {
         var _loc2_:Number;
         if(_direct == -1)
         {
            _loc2_ = x + _speed;
            if(_loc2_ >= this._pos)
            {
               removeEventListener(Event.ENTER_FRAME, this.goRightHandler);
               removeEventListener(Event.ENTER_FRAME, this.onWalkAnimHandler);
               x = this._pos;
               _animState = "_moveEnd";
               _walking = false;
               this.stand();
               dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE, true));
            }
            else { x = _loc2_; }
         }
         else if(_world != null && !_world.checkRight(this))
         {
            removeEventListener(Event.ENTER_FRAME, this.goRightHandler);
            removeEventListener(Event.ENTER_FRAME, this.onWalkAnimHandler);
            _animState = "_moveEnd";
            _walking = false;
            this.stand();
            dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE, true));
         }
         else
         {
            _loc2_ = x + _speed;
            if(_loc2_ >= this._pos)
            {
               removeEventListener(Event.ENTER_FRAME, this.goRightHandler);
               removeEventListener(Event.ENTER_FRAME, this.onWalkAnimHandler);
               x = this._pos;
               _animState = "_moveEnd";
               _walking = false;
               this.stand();
               dispatchEvent(new SoldierEvent(SoldierEvent.MOVE_COMPLETE, true));
            }
            else { x = _loc2_; }
         }
      }

      override public function fire(param1:Object = null) : void
      {
         if(_isDead) return;
         if(param1 != null && Boolean(param1.distance))
         {
            addEventListener(SoldierEvent.MOVE_COMPLETE, this.onMoveCompleteHandler);
            if(_direct == 1) { this.goRight(param1.distance); }
            else { this.goLeft(param1.distance); }
         }
         else
         {
            dispatchP2PActionEvent({
               "direct":_direct, "code":code, "act":"fire",
               "posX":x, "posY":y
            });
            _fireing = true;
            _cooling = true;
            this._canLeft = false;
            this._canRight = false;
            _animState = "_attackBegin";
            this.playAttackAnim();
         }
      }

      /**
       * 攻击动画: 前臂+长矛快速前刺
       */
      private function playAttackAnim() : void
      {
         var _origArmX:Number = _armContainer.x;
         var _origSpearX:Number = _spearContainer.x;
         var _thrustDist:Number = 50 * _direct;

         // 阶段1: 前刺
         TweenLite.to(_armContainer, 0.15, {
            x: _origArmX + _thrustDist,
            onComplete: function():void {
               // 阶段2: 收回
               TweenLite.to(_armContainer, 0.2, {
                  x: _origArmX,
                  onComplete: function():void {
                     _animState = "_attackEnd";
                     onAttackComplete();
                  }
               });
            }
         });
         // 长矛跟随前臂但幅度更大
         TweenLite.to(_spearContainer, 0.15, {
            x: _origSpearX + _thrustDist * 1.5
         });
         TweenLite.to(_spearContainer, 0.2, {
            x: _origSpearX,
            delay: 0.15
         });
      }

      private function onAttackComplete() : void
      {
         _fireing = false;
         this._canLeft = true;
         this._canRight = true;
         dispatchEvent(new SoldierEvent(SoldierEvent.FIRE_COMPLETE, true));
         _coolingBar.setMax(this._repairTime * 1000, true);
         _timer.addEventListener(TimerEvent.TIMER, this.afterFireHandler);
         _timer.start();
      }

      override public function fire2(param1:Object = null) : void
      {
         var _loc2_:Number;
         var _loc3_:Number;
         if(_isDead) return;
         if(param1 != null && param1.target != null)
         {
            removeEventListener(SoldierEvent.MOVE_COMPLETE, this.afterTempMoveHandler);
            removeEventListener(SoldierEvent.FILL_COMPLETE, this.afterTempFireHandler);
            _locked = param1.target as AbstractSoldier;
            if(_locked.isDead == true)
            {
               this.stand();
            }
            else
            {
               if(_cooling == true) return;
               _loc2_ = _world.getAllDistance(this, _locked);
               _loc3_ = _armyInfo.attackDistance * Config.MERIC;
               if(_loc2_ > _loc3_)
               {
                  addEventListener(SoldierEvent.MOVE_COMPLETE, this.afterTempMoveHandler);
                  if(_direct == 1) { this.goRight(_loc2_ - _loc3_); }
                  else { this.goLeft(_loc2_ - _loc3_); }
               }
               else { this.fire(); }
               addEventListener(SoldierEvent.FILL_COMPLETE, this.afterTempFireHandler);
            }
         }
         else { this.stand(); }
      }

      private function afterTempFireHandler(param1:SoldierEvent) : void
      {
         this.fire2({"target": _locked});
      }

      private function afterTempMoveHandler(param1:SoldierEvent) : void
      {
         removeEventListener(SoldierEvent.MOVE_COMPLETE, this.afterTempMoveHandler);
         if(_world.getAllDistance(this, _locked) > _armyInfo.attackDistance * Config.MERIC)
         {
            this.fire();
         }
         else { this.fire2({"target": _locked}); }
      }

      private function onMoveCompleteHandler(param1:SoldierEvent) : void
      {
         removeEventListener(SoldierEvent.MOVE_COMPLETE, this.onMoveCompleteHandler);
         this.fire();
      }

      private function afterFireHandler(param1:TimerEvent) : void
      {
         if(_coolingBar.getCurrent() == 0)
         {
            _timer.removeEventListener(TimerEvent.TIMER, this.afterFireHandler);
            _coolingBar.setMax(_armyInfo.cd * 1000);
            _timer.addEventListener(TimerEvent.TIMER, this.repairTimeHandler);
         }
         else { _coolingBar.setCurrent(_coolingBar.getCurrent() - 40); }
      }

      private function repairTimeHandler(param1:TimerEvent) : void
      {
         if(_coolingBar.getCurrent() == _coolingBar.getMax())
         {
            _timer.removeEventListener(TimerEvent.TIMER, this.repairTimeHandler);
            _cooling = false;
            _timer.reset();
            dispatchEvent(new SoldierEvent(SoldierEvent.FILL_COMPLETE, true));
         }
         else { _coolingBar.setCurrent(_coolingBar.getCurrent() + 40); }
      }

      override public function hurt(param1:int, param2:AbstractSoldier = null) : void
      {
         var _loc3_:int;
         var _loc4_:Number;
         var _loc5_:int;
         if(_isDead) return;
         Tools.setBright(this, 0.9);
         var _loc6_:Timer;
         (_loc6_ = new Timer(100, 1)).addEventListener(TimerEvent.TIMER_COMPLETE, this.onBrightTimerCompleteHandler);
         _loc6_.start();
         if(_armyInfo.tianfu != null)
         {
            _loc3_ = int(Data.getInstance().getAttributes("tianfu", _armyInfo.tianfu, "type"));
            _loc4_ = Number(Data.getInstance().getAttributes("tianfu", _armyInfo.tianfu, "value"));
            if(_loc3_ == 6)
            {
               showHudun();
               param1 = int(param1 * (1 - _loc4_));
            }
         }
         if(param1 < 1) param1 = 1;
         _armyInfo.hp -= param1;
         if(_armyInfo.hp < 0) _armyInfo.hp = 0;
         _bloodBar.setCurrent(_armyInfo.hp);
         dispatchEvent(new SoldierEvent(SoldierEvent.BEHURT, true, param1));
         // 吸血
         if(param2 != null && param2.armyInfo != null && param2.armyInfo.equipLifesteal > 0 && !param2.isDead)
         {
            var _lsh:int = int(param1 * param2.armyInfo.equipLifesteal / 100);
            if(_lsh > 0)
            {
               param2.armyInfo.hp += _lsh;
               if(param2.hp > param2.maxHP) param2.armyInfo.hp = param2.maxHP;
               param2.bloodBar.setCurrent(param2.hp);
               param2.dispatchEvent(new SoldierEvent(SoldierEvent.HUIFU, true, _lsh));
            }
         }
         if(_armyInfo.hp <= 0)
         {
            this.removeAllEvent();
            addEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
            dead();
            dispatchEvent(new SoldierEvent(SoldierEvent.DEAD, true));
         }
         else if(_armyInfo.tianfu != null)
         {
            _loc3_ = int(Data.getInstance().getAttributes("tianfu", _armyInfo.tianfu, "type"));
            if(_loc3_ == 4)
            {
               _loc4_ = Number(Data.getInstance().getAttributes("tianfu", _armyInfo.tianfu, "value"));
               _loc5_ = int(param1 * _loc4_);
               _armyInfo.hp += _loc5_;
               dispatchEvent(new SoldierEvent(SoldierEvent.HUIFU, true, _loc5_));
            }
            else if(_loc3_ == 5)
            {
               _loc4_ = Number(Data.getInstance().getAttributes("tianfu", _armyInfo.tianfu, "value"));
               if(param2 != null && param2.type != Type.TOUSHICHE && param2.type != Type.FEIDAOBING && param2.type != Type.GONGBING)
               {
                  showFanshang();
                  param2.hurt(param1 * _loc4_);
               }
            }
         }
      }

      /**
       * 死亡动画: 身体部件旋转散落
       */
      override public function dead() : void
      {
         _animState = "_deadBegin";
         // 取消所有动画
         TweenLite.killTweensOf(_armContainer);
         TweenLite.killTweensOf(_spearContainer);
         TweenLite.killTweensOf(_bodyContainer);

         // 身体后倾并散落
         TweenLite.to(_bodyContainer, 0.8, { rotation: 30 * _direct, y: BODY_OY + 50 });
         TweenLite.to(_armContainer, 0.6, { rotation: -45 * _direct, y: BODY_OY + 60 });
         TweenLite.to(_spearContainer, 0.7, { rotation: 60 * _direct, x: BODY_OX + 100 * _direct, y: BODY_OY + 80 });
         TweenLite.to(_head, 0.5, { rotation: -20 * _direct, y: BODY_OY + 10 });
         // 整体淡出
         TweenLite.to(_skin, 0.4, {
            alpha: 0.3,
            delay: 0.6,
            onComplete: function():void {
               _animState = "_deadEnd";
            }
         });
      }

      override protected function onEnterFrameHandler(param1:Event) : *
      {
         if(_animState == "_deadEnd")
         {
            removeEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
            dispatchEvent(new SoldierEvent(SoldierEvent.DEAD_COMPLETE, true));
         }
      }

      private function onRemoveFromStageHandler(param1:Event) : void
      {
         TweenLite.killTweensOf(_armContainer);
         TweenLite.killTweensOf(_spearContainer);
         TweenLite.killTweensOf(_bodyContainer);
         TweenLite.killTweensOf(_head);
         TweenLite.killTweensOf(_skin);
         removeEventListener(Event.REMOVED_FROM_STAGE, this.onRemoveFromStageHandler);
         removeEventListener(Event.ENTER_FRAME, this.onEnterFrameHandler);
         this.removeAllEvent();
      }

      private function onBrightTimerCompleteHandler(param1:TimerEvent) : void
      {
         Tools.setBright(this, 0);
         param1.currentTarget.stop();
         param1.currentTarget.removeEventListener(TimerEvent.TIMER_COMPLETE, this.onBrightTimerCompleteHandler);
      }

      private function removeAllEvent() : void
      {
         removeEventListener(SoldierEvent.MOVE_COMPLETE, this.onMoveCompleteHandler);
         removeEventListener(Event.ENTER_FRAME, this.goLeftHandler);
         removeEventListener(Event.ENTER_FRAME, this.goRightHandler);
         removeEventListener(Event.ENTER_FRAME, this.onWalkAnimHandler);
         removeEventListener(SoldierEvent.MOVE_COMPLETE, this.afterTempMoveHandler);
         removeEventListener(SoldierEvent.FILL_COMPLETE, this.afterTempFireHandler);
         _timer.reset();
         _timer.removeEventListener(TimerEvent.TIMER, this.afterFireHandler);
         _timer.removeEventListener(TimerEvent.TIMER, this.repairTimeHandler);
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
