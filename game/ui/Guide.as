package game.ui
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Elastic;
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.ui.Mouse;
   import game.Data;
   import game.Logic;
   import game.display.AbstractSoldier;
   import game.display.Gunner;
   import game.display.IWorld;
   import game.display.Shooter;
   import game.display.StoneWeapon;
   import game.display.Weapon;
   import game.events.ConEvent;
   import game.events.SoldierEvent;
   import game.events.UIEvent;
   import game.events.WeaponEvent;
   import game.model.ArmyInfo;
   import game.model.Type;
   
   public class Guide extends BaseUI implements IWorld
   {
      
      private static const POS1:Point = new Point(200,425);
      
      private static const POS2:Point = new Point(250,425);
      
      private static const POS3:Point = new Point(100,425);
      
      public static const MERIC:int = 30;
       
      
      private var __toushicheInfo:MovieClip;
      
      private var __bubingInfo:MovieClip;
      
      private var __tryBtn:SimpleButton;
      
      private var __nextBtn:SimpleButton;
      
      private var __closeBtn:SimpleButton;
      
      private var _leftArmy:ArmyInfo;
      
      private var _rightArmy:ArmyInfo;
      
      private var _leftSoldier:AbstractSoldier;
      
      private var _rightSoldier:AbstractSoldier;
      
      private var _type:int;
      
      private var _try:Boolean;
      
      private var _bk:MovieClip;
      
      private var _mouseMC:MovieClip;
      
      private var _yuanchengCon:AngleController;
      
      private var _miaozhunjing:MovieClip;
      
      private var _currentSoldier:AbstractSoldier;
      
      private var _tipsLayer:NumTips;
      
      private var _lockedEnemy:AbstractSoldier;
      
      private var _fightUI:FightUI;
      
      public var flag:Boolean;
      
      public function Guide(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__toushicheInfo = _skin.getChildByName("_toushicheInfo") as MovieClip;
         this.__bubingInfo = _skin.getChildByName("_bubingInfo") as MovieClip;
         this.__tryBtn = _skin.getChildByName("_tryBtn") as SimpleButton;
         this.__nextBtn = _skin.getChildByName("_nextBtn") as SimpleButton;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__toushicheInfo.visible = false;
         this.__bubingInfo.visible = false;
         this.__toushicheInfo.mouseEnabled = false;
         this.__toushicheInfo.mouseChildren = false;
         this.__bubingInfo.mouseEnabled = false;
         this.__bubingInfo.mouseChildren = false;
      }
      
      override protected function initEvent() : void
      {
         this.__tryBtn.addEventListener(MouseEvent.CLICK,this.tryBtnClickHandler);
         this.__nextBtn.addEventListener(MouseEvent.CLICK,this.nextBtnClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this._type = param1 as int;
         this.createArmy();
         this.createBK();
         this.createInfo();
         this.createController();
         this.createDemo();
         this.setButton();
         this.createTipsLayer();
         this.createMouse();
         addEventListener(SoldierEvent.BEHURT,this.onSoldierBehurtHandler);
         this.run();
      }
      
      private function createArmy() : *
      {
         trace("type:",this._type);
         switch(this._type)
         {
            case 2:
               this._leftArmy = Data.getInstance().getArmyInfo("general_1_0",1);
               trace("_leftArmy",this._leftArmy);
               break;
            case 3:
               this._leftArmy = Data.getInstance().getArmyInfo("general_0_1",1);
         }
         this._leftArmy.cd = 2;
         this._rightArmy = Data.getInstance().getArmyInfo("general_1_1",100,5,2,"禁军教头");
      }
      
      private function setButton() : *
      {
         switch(this._type)
         {
            case 2:
               this.__closeBtn.visible = false;
               this.__nextBtn.visible = true;
               break;
            case 3:
               this.__closeBtn.visible = true;
               this.__nextBtn.visible = false;
         }
      }
      
      private function createGIcon() : *
      {
         var _loc1_:Vector.<ArmyInfo> = null;
         if(this._leftArmy.type != Type.TOUSHICHE)
         {
            this._fightUI = new FightUI();
            this._fightUI.y = 447;
            addChild(this._fightUI);
            _loc1_ = new Vector.<ArmyInfo>();
            _loc1_.push(this._leftArmy);
            this._fightUI.initData(_loc1_);
         }
      }
      
      private function removeGIcon() : *
      {
         if(this._fightUI != null)
         {
            removeChild(this._fightUI);
            this._fightUI = null;
         }
      }
      
      private function createBK() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(SkinCode.FIGHT_STAGE) as Class;
         this._bk = new _loc1_() as MovieClip;
         this._bk.x = stage.stageWidth / 2;
         this._bk.y = stage.stageHeight / 2;
         addChildAt(this._bk,0);
      }
      
      private function createInfo() : *
      {
         switch(this._type)
         {
            case 2:
               this.__bubingInfo.visible = true;
               this.__toushicheInfo.visible = false;
               break;
            case 3:
               this.__bubingInfo.visible = false;
               this.__toushicheInfo.visible = true;
         }
      }
      
      private function createTipsLayer() : *
      {
         this._tipsLayer = new NumTips();
         addChild(this._tipsLayer);
      }
      
      private function createDemo() : *
      {
         this.createSoldier();
      }
      
      private function removeDemo() : *
      {
         this.removeSoldier();
      }
      
      private function createSoldier(param1:Boolean = true) : *
      {
         switch(this._type)
         {
            case 2:
               this._leftSoldier = new Shooter(this._leftArmy,1,param1,this);
               break;
            case 3:
               this._leftSoldier = new Gunner(this._leftArmy,1,param1,this);
         }
         this._leftSoldier.x = Guide["POS" + this._type].x;
         this._leftSoldier.y = Guide["POS" + this._type].y;
         addChildAt(this._leftSoldier,2);
         this._rightSoldier = new Shooter(this._rightArmy,-1,false);
         this._rightSoldier.x = 770 - Guide["POS" + this._type].x;
         this._rightSoldier.y = Guide["POS" + this._type].y;
         addChildAt(this._rightSoldier,3);
         this.createGIcon();
      }
      
      private function removeSoldier() : *
      {
         removeChild(this._leftSoldier);
         this._leftSoldier = null;
         removeChild(this._rightSoldier);
         this._rightSoldier = null;
         this.removeGIcon();
      }
      
      private function setEvent() : *
      {
         addEventListener(SoldierEvent.SELECTED,this.onSoldierSelectedHandler);
         addEventListener(SoldierEvent.ENEMY_SELECTED,this.onEnemySelectedHandler);
         addEventListener(MouseEvent.CLICK,this.onMouseClickHandler);
         addEventListener(ConEvent.SELECT_SOLDIER,this.onSelectSoldierHandler);
         addEventListener(ConEvent.CREATE_MIAOZHUNJING,this.createMiaozhunjingHandler);
         addEventListener(ConEvent.FIRE,this.conFireHandler);
         addEventListener(SoldierEvent.FILL_COMPLETE,this.onSoldierFillCompleteHandler);
         addEventListener(SoldierEvent.FIRE_COMPLETE,this.onSoldierFireCompleteHandler);
      }
      
      private function removeEvent() : *
      {
         removeEventListener(SoldierEvent.SELECTED,this.onSoldierSelectedHandler);
         removeEventListener(SoldierEvent.ENEMY_SELECTED,this.onEnemySelectedHandler);
         removeEventListener(MouseEvent.CLICK,this.onMouseClickHandler);
         removeEventListener(ConEvent.SELECT_SOLDIER,this.onSelectSoldierHandler);
         removeEventListener(ConEvent.CREATE_MIAOZHUNJING,this.createMiaozhunjingHandler);
         removeEventListener(ConEvent.FIRE,this.conFireHandler);
         removeEventListener(SoldierEvent.FILL_COMPLETE,this.onSoldierFillCompleteHandler);
         removeEventListener(SoldierEvent.FIRE_COMPLETE,this.onSoldierFireCompleteHandler);
         this._miaozhunjing.removeEventListener(Event.ENTER_FRAME,this.onMiaozhunjingEnterFrameHandler);
      }
      
      private function createController() : *
      {
         this._yuanchengCon = new AngleController(SkinCode.ANGLE_CON);
         this._yuanchengCon.visible = false;
         addChild(this._yuanchengCon);
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(SkinCode.MIAOZHUN_CON) as Class;
         this._miaozhunjing = new _loc1_() as MovieClip;
         this._miaozhunjing.mouseChildren = false;
         this._miaozhunjing.mouseEnabled = false;
         this._miaozhunjing.visible = false;
         addChild(this._miaozhunjing);
      }
      
      private function resetController() : *
      {
         this._yuanchengCon.stopBar();
         this._yuanchengCon.visible = false;
         this._yuanchengCon.setEnabled(true);
         this._miaozhunjing.removeEventListener(Event.ENTER_FRAME,this.onMiaozhunjingEnterFrameHandler);
         this._miaozhunjing.gotoAndStop(1);
         removeEventListener(SoldierEvent.ENEMY_LOCKED,this.enemyLockHandler);
         removeEventListener(SoldierEvent.ENEMY_UNLOCKED,this.enemyUnlockHandler);
         this._lockedEnemy = null;
      }
      
      private function clearCurrentSoldier() : *
      {
         if(this._currentSoldier != null)
         {
            this._currentSoldier.setUnSelected();
            this._currentSoldier.setNameVisible(true);
            this._currentSoldier = null;
         }
      }
      
      private function setCurrentSoldier(param1:AbstractSoldier) : *
      {
         if(param1 == null)
         {
            return;
         }
         if(param1.fireing == true)
         {
            return;
         }
         if(param1.isDead == true)
         {
            return;
         }
         if(this._try != true)
         {
            return;
         }
         this._currentSoldier = param1;
         this._currentSoldier.setSelected();
         param1.setNameVisible(false);
         switch(param1.type)
         {
            case Type.TOUSHICHE:
               this._yuanchengCon.visible = true;
               this._yuanchengCon.x = param1.x;
               this._yuanchengCon.y = param1.y - param1.long - 15;
               this._yuanchengCon.direct = param1.direct;
               if(param1.cooling == false)
               {
                  this._yuanchengCon.startBar();
               }
               else
               {
                  this._yuanchengCon.setEnabled(false);
               }
               break;
            default:
               dispatchEvent(new ConEvent(ConEvent.CREATE_MIAOZHUNJING,true));
         }
      }
      
      private function onMouseClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this._try != true)
         {
            return;
         }
         if(this._currentSoldier != null && this._currentSoldier.isDead == false)
         {
            if(this._currentSoldier.fireing == false && this._currentSoldier.type != Type.TOUSHICHE)
            {
               _loc2_ = this._currentSoldier.x;
               _loc3_ = Math.abs(mouseX - _loc2_);
               if(mouseX < _loc2_)
               {
                  this._currentSoldier.stand();
                  this._currentSoldier.goLeft(_loc3_);
               }
               else
               {
                  this._currentSoldier.stand();
                  this._currentSoldier.goRight(_loc3_);
               }
            }
         }
         this.clearCurrentSoldier();
         this.resetController();
         Mouse.show();
         Mouse.prototype.isHide = false;
         Mouse.prototype.canFire = false;
         this._miaozhunjing.visible = false;
      }
      
      private function onSoldierSelectedHandler(param1:SoldierEvent) : *
      {
         if(this._miaozhunjing.visible == true)
         {
            Mouse.show();
            Mouse.prototype.isHide = false;
            Mouse.prototype.canFire = false;
            this._miaozhunjing.visible = false;
         }
         if(this._currentSoldier != null)
         {
            this._currentSoldier.setUnSelected();
            this._currentSoldier.setNameVisible(true);
         }
         this.resetController();
         this.setCurrentSoldier(param1.target as AbstractSoldier);
      }
      
      private function onSelectSoldierHandler(param1:ConEvent) : *
      {
         if(this._miaozhunjing.visible == true)
         {
            Mouse.show();
            Mouse.prototype.isHide = false;
            Mouse.prototype.canFire = false;
            this._miaozhunjing.visible = false;
         }
         if(this._currentSoldier != null)
         {
            this._currentSoldier.setUnSelected();
            this._currentSoldier.setNameVisible(true);
         }
         this.resetController();
         this.setCurrentSoldier(this._leftSoldier);
      }
      
      private function onEnemySelectedHandler(param1:SoldierEvent) : *
      {
         if(this._miaozhunjing.visible == true)
         {
            Mouse.show();
            Mouse.prototype.isHide = false;
            this._miaozhunjing.visible = false;
            if(Mouse.prototype.canFire == true && this._currentSoldier != null && this._currentSoldier.isDead == false)
            {
               if(this._currentSoldier.fireing == false)
               {
                  this._currentSoldier.stand();
                  dispatchEvent(new ConEvent(ConEvent.FIRE,false,{
                     "type":ConType.JINCHENG,
                     "target":param1.target
                  }));
               }
            }
            Mouse.prototype.canFire = false;
         }
      }
      
      private function createMiaozhunjingHandler(param1:ConEvent) : void
      {
         this._miaozhunjing.addEventListener(Event.ENTER_FRAME,this.onMiaozhunjingEnterFrameHandler);
         addEventListener(SoldierEvent.ENEMY_LOCKED,this.enemyLockHandler);
         addEventListener(SoldierEvent.ENEMY_UNLOCKED,this.enemyUnlockHandler);
         this._miaozhunjing.visible = true;
         Mouse.prototype.isHide = true;
         Mouse.hide();
      }
      
      private function onMiaozhunjingEnterFrameHandler(param1:Event) : *
      {
         this._miaozhunjing.x = mouseX;
         this._miaozhunjing.y = mouseY;
         if(this._lockedEnemy != null && this._currentSoldier != null)
         {
            this._miaozhunjing.gotoAndStop(3);
            Mouse.prototype.canFire = true;
         }
         else
         {
            this._miaozhunjing.gotoAndStop(1);
            Mouse.prototype.canFire = false;
         }
      }
      
      private function enemyLockHandler(param1:SoldierEvent) : *
      {
         this._lockedEnemy = param1.target as AbstractSoldier;
      }
      
      private function enemyUnlockHandler(param1:SoldierEvent) : *
      {
         this._lockedEnemy = null;
      }
      
      private function conFireHandler(param1:ConEvent) : void
      {
         if(this._currentSoldier == null)
         {
            return;
         }
         if(this._currentSoldier.isDead == true)
         {
            return;
         }
         if(this._try != true)
         {
            return;
         }
         switch(param1.data.type)
         {
            case ConType.YUANCHENG:
               this._currentSoldier.fire({
                  "angle":param1.data.angle,
                  "power":param1.data.power
               });
               break;
            case ConType.JINCHENG:
               this._currentSoldier.fire2({"target":param1.data.target});
         }
         this.clearCurrentSoldier();
         this.resetController();
      }
      
      public function checkLeft(param1:AbstractSoldier) : Boolean
      {
         if(param1.direct == 1)
         {
            return true;
         }
         var _loc2_:AbstractSoldier = this.findSoldier(1);
         var _loc3_:Number = this.getAllDistance(param1,_loc2_);
         if(_loc3_ <= 0)
         {
            return false;
         }
         return true;
      }
      
      public function checkRight(param1:AbstractSoldier) : Boolean
      {
         if(param1.direct == -1)
         {
            return true;
         }
         var _loc2_:AbstractSoldier = this.findSoldier(-1);
         var _loc3_:Number = this.getAllDistance(param1,_loc2_);
         if(_loc3_ <= 0)
         {
            return false;
         }
         return true;
      }
      
      public function getDistance(param1:AbstractSoldier, param2:AbstractSoldier) : Number
      {
         if(param1 == null || param2 == null)
         {
            return 0;
         }
         var _loc3_:Number = param1.moveDistance * MERIC;
         var _loc4_:Number = param1.attckDistance * MERIC;
         var _loc5_:Number;
         if((_loc5_ = this.getAllDistance(param1,param2)) >= _loc3_)
         {
            return _loc3_;
         }
         return _loc5_;
      }
      
      public function getAllDistance(param1:AbstractSoldier, param2:AbstractSoldier) : Number
      {
         var _loc3_:Number = NaN;
         if(param1 == null || param2 == null)
         {
            return 0;
         }
         var _loc4_:Rectangle = param1.getRectangle(this);
         var _loc5_:Rectangle = param2.getRectangle(this);
         if(param1.direct == 1)
         {
            _loc3_ = _loc5_.left - _loc4_.right;
         }
         else
         {
            _loc3_ = _loc4_.left - _loc5_.right;
         }
         if(_loc3_ < 0)
         {
            _loc3_ = 0;
         }
         return _loc3_;
      }
      
      public function findSoldier(param1:int) : AbstractSoldier
      {
         if(param1 == 1)
         {
            return this._leftSoldier;
         }
         return this._rightSoldier;
      }
      
      public function hurtByRec(param1:AbstractSoldier, param2:Point, param3:Array, param4:int) : *
      {
         var _loc5_:AbstractSoldier = null;
         var _loc6_:Rectangle = new Rectangle(param2.x - param4,0,param4 * 2,stage.stageHeight);
         var _loc7_:int = 0;
         while(_loc7_ < param3.length)
         {
            _loc5_ = param3[_loc7_] as AbstractSoldier;
            if(_loc6_.intersects(_loc5_.getRect(this)))
            {
               _loc5_.hurt(Logic.getHurtVale(param1,_loc5_,"proto_2_3"));
               return;
            }
            _loc7_++;
         }
      }
      
      public function clear() : *
      {
         this.removeEvent();
         removeEventListener(SoldierEvent.BEHURT,this.onSoldierBehurtHandler);
         Mouse.show();
         Mouse.prototype.isHide = false;
         Mouse.prototype.canFire = false;
         this._yuanchengCon.stopBar();
         this._yuanchengCon.visible = false;
         this._miaozhunjing.visible = false;
      }
      
      private function onSoldierFillCompleteHandler(param1:SoldierEvent) : *
      {
         param1.stopPropagation();
         var _loc2_:AbstractSoldier = param1.target as AbstractSoldier;
         if(this._yuanchengCon.visible == true && this._yuanchengCon.getEnabled() == false && this._currentSoldier == _loc2_)
         {
            this._yuanchengCon.setEnabled(true);
            this._yuanchengCon.startBar();
         }
      }
      
      private function onSoldierFireCompleteHandler(param1:SoldierEvent) : *
      {
         var _loc2_:AbstractSoldier = null;
         var _loc3_:StoneWeapon = null;
         var _loc4_:Point = null;
         var _loc5_:AbstractSoldier = null;
         var _loc6_:Weapon = null;
         var _loc7_:Point = null;
         param1.stopPropagation();
         _loc2_ = param1.target as AbstractSoldier;
         switch(_loc2_.type)
         {
            case Type.TOUSHICHE:
               if(_loc2_.isPlayer == true)
               {
                  _loc3_ = new StoneWeapon(_loc2_,param1.data.angle,param1.data.power,"",400);
               }
               else
               {
                  _loc3_ = new StoneWeapon(_loc2_,param1.data.angle,param1.data.power,"",400);
               }
               _loc4_ = _loc2_.getHurPoint(this);
               _loc3_.x = _loc4_.x;
               _loc3_.y = _loc4_.y;
               addChild(_loc3_);
               _loc3_.addEventListener(WeaponEvent.WEAPON_END,this.onStoneWeaponEndHandler);
               _loc3_.run();
               break;
            case Type.QIBING:
               if(_loc2_.direct == 1)
               {
                  _loc5_ = this.findSoldier(-1);
               }
               else
               {
                  _loc5_ = this.findSoldier(1);
               }
               if(_loc5_ != null)
               {
                  _loc5_.hurt(Logic.getHurtVale(_loc2_,_loc5_));
               }
               break;
            default:
               _loc6_ = new Weapon(_loc2_,param1.data.target as AbstractSoldier);
               _loc7_ = _loc2_.getHurPoint(this);
               _loc6_.x = _loc7_.x;
               _loc6_.y = _loc7_.y;
               _loc6_.addEventListener(WeaponEvent.WEAPON_END,this.onWeaponEndHandler);
               addChildAt(_loc6_,getChildIndex(_loc2_));
               _loc6_.run();
         }
      }
      
      private function onWeaponEndHandler(param1:WeaponEvent) : *
      {
         param1.currentTarget.removeEventListener(WeaponEvent.WEAPON_END,this.onWeaponEndHandler);
         removeChild(param1.currentTarget as Weapon);
         var _loc2_:AbstractSoldier = param1.data.behurt;
         var _loc3_:AbstractSoldier = param1.data.hurt;
         if(_loc2_ != null && _loc3_ != null)
         {
            _loc2_.hurt(Logic.getHurtVale(_loc3_,_loc2_));
         }
      }
      
      private function onStoneWeaponEndHandler(param1:WeaponEvent) : *
      {
         param1.currentTarget.removeEventListener(WeaponEvent.WEAPON_END,this.onStoneWeaponEndHandler);
         var _loc2_:AbstractSoldier = param1.data.hurt;
         this.shake();
         if(_loc2_.direct == 1)
         {
            this.hurtByRec(_loc2_,new Point(param1.currentTarget.x,param1.currentTarget.y),[this._rightSoldier],param1.data.radiu);
         }
         else
         {
            this.hurtByRec(_loc2_,new Point(param1.currentTarget.x,param1.currentTarget.y),[this._leftSoldier],param1.data.radiu);
         }
      }
      
      private function shake() : *
      {
         var _loc1_:int = 0;
         if(Math.random() > 0.5)
         {
            _loc1_ = -1;
         }
         else
         {
            _loc1_ = 1;
         }
         y += (5 + Math.random() * 10) * _loc1_;
         TweenLite.to(this,0.6,{
            "y":0,
            "x":0,
            "rotation":0,
            "ease":Elastic.easeOut
         });
      }
      
      private function onSoldierBehurtHandler(param1:SoldierEvent) : *
      {
         var _loc2_:Point = new Point(param1.target.x,param1.target.y - 50);
         var _loc3_:Point = _loc2_.clone();
         _loc3_.y -= 50;
         var _loc4_:int = param1.data as int;
         this._tipsLayer.addTips(_loc4_,_loc2_);
      }
      
      private function nextBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.removeDemoEveryThing();
         this.removeSoldier();
         this.removeEvent();
         ++this._type;
         this._try = false;
         this.resetController();
         this.createArmy();
         this.setButton();
         this.createInfo();
         this.createDemo();
         this._mouseMC.visible = true;
         this.run();
      }
      
      private function tryBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._try == true)
         {
            return;
         }
         this.removeDemoEveryThing();
         this._try = true;
         this.removeSoldier();
         this.createSoldier();
         this.resetController();
         this.setEvent();
      }
      
      private function removeDemoEveryThing() : *
      {
         TweenLite.killTweensOf(this._mouseMC);
         TweenLite.killTweensOf(this._miaozhunjing);
         this._mouseMC.visible = false;
         this._miaozhunjing.visible = false;
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete21);
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete22);
         this._leftSoldier.removeEventListener(SoldierEvent.MOVE_COMPLETE,this.shooterRightComplete);
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete23);
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete24);
         this._leftSoldier.removeEventListener(SoldierEvent.MOVE_COMPLETE,this.shooterLeftComplete);
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete25);
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete26);
         this._leftSoldier.removeEventListener(SoldierEvent.FIRE_COMPLETE,this.fireComplete21);
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete31);
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete32);
         this._leftSoldier.removeEventListener(SoldierEvent.FIRE_COMPLETE,this.fireComplete31);
      }
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.removeDemoEveryThing();
         this.clear();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
      
      private function createMouse() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(SkinCode.MOUSE_MC) as Class;
         this._mouseMC = new _loc1_() as MovieClip;
         this._mouseMC.x = 385;
         this._mouseMC.y = 200;
         addChild(this._mouseMC);
      }
      
      private function run() : *
      {
         switch(this._type)
         {
            case 2:
               this.run2();
               break;
            case 3:
               this.run3();
         }
      }
      
      private function run2() : *
      {
         var _loc1_:Number = this._leftSoldier.x;
         var _loc2_:Number = this._leftSoldier.y - 30;
         TweenLite.to(this._mouseMC,1,{
            "x":_loc1_,
            "y":_loc2_,
            "onComplete":this.select21
         });
      }
      
      private function select21() : *
      {
         this._mouseMC.addEventListener(Event.COMPLETE,this.mouseComplete21);
         this._mouseMC.gotoAndPlay(2);
         this._leftSoldier.setNameVisible(false);
      }
      
      private function mouseComplete21(param1:Event) : *
      {
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete21);
         var _loc2_:Number = this._leftSoldier.x + 100;
         var _loc3_:Number = this._leftSoldier.y - 30;
         this._mouseMC.visible = false;
         this._miaozhunjing.visible = true;
         this._miaozhunjing.x = this._mouseMC.x;
         this._miaozhunjing.y = this._mouseMC.y;
         TweenLite.to(this._mouseMC,1,{
            "x":_loc2_,
            "y":_loc3_,
            "onComplete":this.move21
         });
         TweenLite.to(this._miaozhunjing,1,{
            "x":_loc2_,
            "y":_loc3_
         });
      }
      
      private function move21() : *
      {
         this._mouseMC.addEventListener(Event.COMPLETE,this.mouseComplete22);
         this._mouseMC.gotoAndPlay(2);
         this._leftSoldier.setNameVisible(true);
      }
      
      private function mouseComplete22(param1:Event) : *
      {
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete22);
         this.resetController();
         this._mouseMC.visible = true;
         this._miaozhunjing.visible = false;
         this._leftSoldier.stand();
         this._leftSoldier.addEventListener(SoldierEvent.MOVE_COMPLETE,this.shooterRightComplete);
         this._leftSoldier.goRight(100);
      }
      
      private function shooterRightComplete(param1:SoldierEvent) : *
      {
         this._leftSoldier.removeEventListener(SoldierEvent.MOVE_COMPLETE,this.shooterRightComplete);
         var _loc2_:Number = this._leftSoldier.x;
         var _loc3_:Number = this._leftSoldier.y - 30;
         TweenLite.to(this._mouseMC,1,{
            "x":_loc2_,
            "y":_loc3_,
            "onComplete":this.select22
         });
      }
      
      private function select22() : *
      {
         this._mouseMC.addEventListener(Event.COMPLETE,this.mouseComplete23);
         this._mouseMC.gotoAndPlay(2);
         this._leftSoldier.setNameVisible(false);
      }
      
      private function mouseComplete23(param1:Event) : *
      {
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete23);
         var _loc2_:Number = this._leftSoldier.x - 100;
         var _loc3_:Number = this._leftSoldier.y - 20;
         this._mouseMC.visible = false;
         this._miaozhunjing.visible = true;
         this._miaozhunjing.x = this._mouseMC.x;
         this._miaozhunjing.y = this._mouseMC.y;
         TweenLite.to(this._mouseMC,1,{
            "x":_loc2_,
            "y":_loc3_,
            "onComplete":this.move22
         });
         TweenLite.to(this._miaozhunjing,1,{
            "x":_loc2_,
            "y":_loc3_
         });
      }
      
      private function move22() : *
      {
         this._mouseMC.addEventListener(Event.COMPLETE,this.mouseComplete24);
         this._mouseMC.gotoAndPlay(2);
         this._leftSoldier.setNameVisible(true);
      }
      
      private function mouseComplete24(param1:Event) : *
      {
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete24);
         this.resetController();
         this._mouseMC.visible = true;
         this._miaozhunjing.visible = false;
         this._leftSoldier.stand();
         this._leftSoldier.addEventListener(SoldierEvent.MOVE_COMPLETE,this.shooterLeftComplete);
         this._leftSoldier.goLeft(100);
      }
      
      private function shooterLeftComplete(param1:SoldierEvent) : *
      {
         this._leftSoldier.removeEventListener(SoldierEvent.MOVE_COMPLETE,this.shooterLeftComplete);
         var _loc2_:Number = this._leftSoldier.x;
         var _loc3_:Number = this._leftSoldier.y - 30;
         TweenLite.to(this._mouseMC,1,{
            "x":_loc2_,
            "y":_loc3_,
            "onComplete":this.select23
         });
      }
      
      private function select23() : *
      {
         this._mouseMC.addEventListener(Event.COMPLETE,this.mouseComplete25);
         this._mouseMC.gotoAndPlay(2);
         this._leftSoldier.setNameVisible(false);
      }
      
      private function mouseComplete25(param1:Event) : *
      {
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete25);
         var _loc2_:Number = this._rightSoldier.x;
         var _loc3_:Number = this._rightSoldier.y - 30;
         this._mouseMC.visible = false;
         this._miaozhunjing.visible = true;
         this._miaozhunjing.x = this._mouseMC.x;
         this._miaozhunjing.y = this._mouseMC.y;
         TweenLite.to(this._mouseMC,1,{
            "x":_loc2_,
            "y":_loc3_,
            "onComplete":this.select24
         });
         TweenLite.to(this._miaozhunjing,1,{
            "x":_loc2_,
            "y":_loc3_
         });
      }
      
      private function select24() : *
      {
         this._mouseMC.addEventListener(Event.COMPLETE,this.mouseComplete26);
         this._mouseMC.gotoAndPlay(2);
         this._leftSoldier.setNameVisible(true);
      }
      
      private function mouseComplete26(param1:Event) : *
      {
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete26);
         this._mouseMC.visible = true;
         this._miaozhunjing.visible = false;
         this._leftSoldier.addEventListener(SoldierEvent.FIRE_COMPLETE,this.fireComplete21);
         this._leftSoldier.fire({"target":this._rightSoldier});
      }
      
      private function fireComplete21(param1:SoldierEvent) : *
      {
         this._leftSoldier.removeEventListener(SoldierEvent.FIRE_COMPLETE,this.fireComplete21);
         var _loc2_:Weapon = new Weapon(this._leftSoldier,param1.data.target as AbstractSoldier);
         var _loc3_:Point = this._leftSoldier.getHurPoint(this);
         _loc2_.x = _loc3_.x;
         _loc2_.y = _loc3_.y;
         _loc2_.addEventListener(WeaponEvent.WEAPON_END,this.onWeaponEndHandler);
         addChildAt(_loc2_,getChildIndex(this._leftSoldier));
         _loc2_.run();
         this.run2();
      }
      
      private function run3() : *
      {
         var _loc1_:Number = this._leftSoldier.x;
         var _loc2_:Number = this._leftSoldier.y - 30;
         TweenLite.to(this._mouseMC,3,{
            "x":_loc1_,
            "y":_loc2_,
            "onComplete":this.select31
         });
      }
      
      private function select31() : *
      {
         this._mouseMC.addEventListener(Event.COMPLETE,this.mouseComplete31);
         this._mouseMC.gotoAndPlay(2);
      }
      
      private function mouseComplete31(param1:Event) : *
      {
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete31);
         this._yuanchengCon.x = this._leftSoldier.x;
         this._yuanchengCon.y = this._leftSoldier.y - this._leftSoldier.long - 15;
         this._yuanchengCon.direct = this._leftSoldier.direct;
         this._yuanchengCon.visible = true;
         this._yuanchengCon.startBar(true);
         this._leftSoldier.setNameVisible(false);
         var _loc2_:Number = 275;
         var _loc3_:Number = 200;
         TweenLite.to(this._mouseMC,1,{
            "x":_loc2_,
            "y":_loc3_,
            "onComplete":this.fire31,
            "onUpdate":this.onUpdateHandler
         });
      }
      
      private function onUpdateHandler() : *
      {
         var _loc1_:Number = this._mouseMC.x - this._yuanchengCon.x;
         var _loc2_:Number = this._mouseMC.y - this._yuanchengCon.y;
         var _loc3_:Number = Math.atan2(_loc2_,_loc1_);
         this._yuanchengCon.setAngle(_loc3_ * 180 / Math.PI);
      }
      
      private function fire31() : *
      {
         var _loc1_:Number = 300;
         var _loc2_:Number = 300;
         TweenLite.to(this._mouseMC,2,{
            "x":_loc1_,
            "y":_loc2_,
            "onComplete":this.fire32,
            "onUpdate":this.onUpdateHandler
         });
      }
      
      private function fire32() : *
      {
         var _loc1_:Number = 300;
         var _loc2_:Number = 250;
         TweenLite.to(this._mouseMC,1,{
            "x":_loc1_,
            "y":_loc2_,
            "onComplete":this.fire33,
            "onUpdate":this.onUpdateHandler
         });
      }
      
      private function fire33() : *
      {
         this._mouseMC.addEventListener(Event.COMPLETE,this.mouseComplete32);
         this._mouseMC.gotoAndPlay(2);
      }
      
      private function mouseComplete32(param1:Event) : *
      {
         this._mouseMC.removeEventListener(Event.COMPLETE,this.mouseComplete32);
         this._yuanchengCon.stopBar();
         this._yuanchengCon.visible = false;
         this._leftSoldier.addEventListener(SoldierEvent.FIRE_COMPLETE,this.fireComplete31);
         this._leftSoldier.fire({
            "angle":this._yuanchengCon.getAngle(),
            "power":this._yuanchengCon.getPower()
         });
      }
      
      private function fireComplete31(param1:SoldierEvent) : *
      {
         var _loc2_:StoneWeapon = null;
         this._leftSoldier.removeEventListener(SoldierEvent.FIRE_COMPLETE,this.fireComplete31);
         _loc2_ = new StoneWeapon(this._leftSoldier,param1.data.angle,param1.data.power,"",400);
         var _loc3_:Point = this._leftSoldier.getHurPoint(this);
         _loc2_.x = _loc3_.x;
         _loc2_.y = _loc3_.y;
         addChild(_loc2_);
         _loc2_.addEventListener(WeaponEvent.WEAPON_END,this.onStoneWeaponEndHandler);
         _loc2_.run();
         this.run3();
      }
      
      public function getAutoMode() : Boolean
      {
         return false;
      }
   }
}
