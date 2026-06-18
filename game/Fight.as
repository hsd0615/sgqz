package game
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Elastic;
   import com.iflashigame.utils.Tools;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.external.ExternalInterface;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.ui.Mouse;
   import flash.utils.Timer;
   import game.ai.AI;
   import game.ai.IAI;
   import game.ai.SmartAttack;
   import game.display.AbstractSoldier;
   import game.display.Gunner;
   import game.display.IWorld;
   import game.display.Junzhu;
   import game.display.Saber;
   import game.display.Shooter;
   import game.display.StoneWeapon;
   import game.display.Weapon;
   import game.events.ConEvent;
   import game.events.FightEvent;
   import game.events.SoldierEvent;
   import game.events.UIEvent;
   import game.events.WeaponEvent;
   import game.model.ArmyInfo;
   import game.model.MyPoint;
   import game.model.RoleModel;
   import game.model.Type;
   import game.ui.AngleController;
   import game.ui.ConType;
   import game.ui.FightUI;
   import game.ui.NumTips;
   import game.ui.SkinCode;
   
   public class Fight extends Sprite implements IWorld, IAI
   {
      
      private static const TS_POS:Point = new Point(50,340);
      
      private static const POS0:Point = new Point(140,315);
      
      private static const POS1:Point = new Point(180,340);
      
      private static const POS2:Point = new Point(220,365);
      
      private static const POS3:Point = new Point(180,390);
      
      private static const POS4:Point = new Point(140,415);
      
      private static const ATTACKPOS1:Point = new Point(35,-165);
      
      public static const MERIC:int = 30;
       
      
      private var _leftArmy:Vector.<ArmyInfo>;
      
      private var _rightArmy:Vector.<ArmyInfo>;
      
      private var _p2p:Boolean;
      
      private var _direct:int;
      
      private var _level:int;
      
      private var _part:int;
      
      private var _delay:Number = 0;

      
      private var _timer:Timer;
      
      private var _leftSoldiers:Array;
      
      private var _rightSoldiers:Array;
      
      private var _bk:MovieClip;
      
      private var _yuanchengCon:AngleController;
      
      private var _miaozhunjing:MovieClip;
      
      private var _tipsLayer:NumTips;
      
      private var _isOver:Boolean;
      
      private var _currentSoldier:AbstractSoldier;
      
      private var _ai:AI;
      
      private var _ammo:String = "";
      
      private var _title:Bitmap;
      
      private var _gridContainer:Sprite;
      
      private var _currentGrid:MovieClip;
      
      private var _auto:Boolean = false;
      
      private var _autoAI:AI;
      
      private var _lockedEnemy:AbstractSoldier;
      
      private var _tf:TextField;
      
      private var _tfArr:Array;
      
      public var _date:Number;
      
      private var _biansu:int = 0;

      private var _retreatBtn:Sprite;

      private var _fightUI:FightUI;
      
      private var _ammoTips:MovieClip;
      
      public function Fight(param1:Vector.<ArmyInfo>, param2:Vector.<ArmyInfo>, param3:int = 1, param4:Boolean = false)
      {
         super();
         this._leftArmy = param1.sort(this.compare);
         this._rightArmy = param2.sort(this.compare);
         this._direct = param3;
         this._p2p = param4;
         if(stage != null)
         {
            this.addToStageHandler(null);
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,this.addToStageHandler);
         }
      }
      
      private function compare(param1:ArmyInfo, param2:ArmyInfo) : Number
      {
         if(param1.sortFlag < param2.sortFlag)
         {
            return -1;
         }
         if(param1.sortFlag > param2.sortFlag)
         {
            return 1;
         }
         return 0;
      }
      
      private function addToStageHandler(param1:Event) : *
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addToStageHandler);
         this.initView();
         }
      
      private function initView() : *
      {
         this.createBK();
         this.createLeftArmy();
         this.createRightArmy();
         this.createGIcon();
         this.createController();
         this.createTipsLayer();
         this.createAmmoTips();
         this.creatGrid();
         this.createTF();
      }
      
      private function initEvent() : *
      {
         addEventListener(SoldierEvent.SELECTED,this.onSoldierSelectedHandler);
         addEventListener(SoldierEvent.ENEMY_SELECTED,this.onEnemySelectedHandler);
         addEventListener(SoldierEvent.SMART_ATTACK,this.smartAttackHandler);
         addEventListener(MouseEvent.CLICK,this.onMouseClickHandler);
         addEventListener(ConEvent.SELECT_SOLDIER,this.onSelectSoldierHandler);
         addEventListener(ConEvent.CREATE_MIAOZHUNJING,this.createMiaozhunjingHandler);
         addEventListener(ConEvent.FIRE,this.conFireHandler);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeydownHandler);
         this.initUnInteractiveEvent();
         // Web键盘轮询: Flash通过ExternalInterface.call获取JS按键
         addEventListener(Event.ENTER_FRAME,this.pollWebKeys);

      }
      
      private function initUnInteractiveEvent() : *
      {
         addEventListener(SoldierEvent.FILL_COMPLETE,this.onSoldierFillCompleteHandler);
         addEventListener(SoldierEvent.FIRE_COMPLETE,this.onSoldierFireCompleteHandler);
         addEventListener(SoldierEvent.BEHURT,this.onSoldierBehurtHandler);
         addEventListener(SoldierEvent.SHANBI,this.onSoldierShanbiHandler);
         addEventListener(SoldierEvent.HUIFU,this.onSoldierHuifuHandler);
         addEventListener(SoldierEvent.DEAD,this.onSoldierDeadHandler);
         addEventListener(SoldierEvent.DEAD_COMPLETE,this.onSoldierDeadCompleteHandler);
      }
      
      private function createTF() : *
      {
         // 撤退按钮 — 古铜风格匹配游戏UI
         this._retreatBtn = new Sprite();
         var _bg:Shape = new Shape();
         _bg.graphics.lineStyle(1.5, 0x8B6914, 0.9);
         _bg.graphics.beginFill(0x1a1008, 0.88);
         _bg.graphics.drawRoundRect(0, 0, 56, 22, 4, 4);
         _bg.graphics.endFill();
         _bg.graphics.lineStyle(0.5, 0x5a4010, 0.5);
         _bg.graphics.drawRoundRect(2, 2, 52, 18, 3, 3);
         this._retreatBtn.addChild(_bg);
         var _rtTF:TextField = new TextField();
         _rtTF.defaultTextFormat = new TextFormat("SimSun", 11, 0xC8A84E, true);
         _rtTF.text = "撤退";
         _rtTF.selectable = false; _rtTF.mouseEnabled = false;
         _rtTF.autoSize = TextFieldAutoSize.CENTER;
         _rtTF.x = 8; _rtTF.y = 3;
         this._retreatBtn.addChild(_rtTF);
         this._retreatBtn.buttonMode = true;
         this._retreatBtn.x = 710; this._retreatBtn.y = 2;
         this._retreatBtn.addEventListener(MouseEvent.CLICK, this.retreatClickHandler);
         addChild(this._retreatBtn);
      }

      private function retreatClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.doRetreat();
      }

      public function doRetreat() : *
      {
         if(this._isOver == true) return;
         this.clear();
         this._isOver = true;
         var _flag:String = "lost";
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         if(this._direct == 1)
         {
            _loc3_ = this.getRightLevelAverage();
            _loc4_ = this.getLeftLevelAverage();
         }
         else
         {
            _loc3_ = this.getLeftLevelAverage();
            _loc4_ = this.getRightLevelAverage();
         }
         dispatchEvent(new FightEvent(FightEvent.FIGHT_COMPLETE, true, {
            "flag": _flag,
            "m": _loc3_,
            "n": _loc4_
         }));
      }
      
      private function createGIcon() : *
      {
         this._fightUI = new FightUI();
         this._fightUI.y = 447;
         addChild(this._fightUI);
         if(this._direct == 1)
         {
            this._fightUI.initData(this._leftArmy);
         }
         else
         {
            this._fightUI.initData(this._rightArmy);
         }
      }
      
      private function createBK() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(SkinCode.FIGHT_STAGE) as Class;
         this._bk = new _loc1_() as MovieClip;
         this._bk.x = stage.stageWidth / 2;
         this._bk.y = stage.stageHeight / 2;
         addChild(this._bk);
      }
      
      private function creatGrid() : *
      {
         var _loc3_:Bitmap = null;
         var _loc6_:int = 0;
         var _loc1_:MovieClip = null;
         var _loc2_:Class = null;
         _loc3_ = null;
         var _loc4_:Boolean = false;
         this._gridContainer = new Sprite();
         this._gridContainer.graphics.beginFill(0,0.4);
         this._gridContainer.graphics.drawRoundRect(0,0,290,38,4,4);
         this._gridContainer.graphics.endFill();
         addChild(this._gridContainer);
         var _loc5_:Class = ApplicationDomain.currentDomain.getDefinition(SkinCode.ICON_GRID) as Class;
         _loc6_ = 1;
         while(_loc6_ <= 8)
         {
            _loc1_ = new _loc5_() as MovieClip;
            _loc1_.buttonMode = true;
            _loc1_.name = "grid" + _loc6_;
            _loc2_ = ApplicationDomain.currentDomain.getDefinition("proto_2_" + _loc6_) as Class;
            _loc3_ = new Bitmap(new _loc2_() as BitmapData);
            _loc3_.x = 2;
            _loc3_.y = 2;
            _loc1_.addChildAt(_loc3_,0);
            _loc1_.x = 2 + (_loc6_ - 1) * (_loc1_.width + 2);
            _loc1_.y = 2;
            _loc1_.code = "proto_2_" + _loc6_;
            this._gridContainer.addChild(_loc1_);
            _loc4_ = RoleModel.getInstance().findBagItem("proto_2_" + _loc6_);
            _loc1_.countTF.text = RoleModel.getInstance().getBagItemCount("proto_2_" + _loc6_);
            _loc1_.sanjiao.visible = false;
            if(_loc4_ == true)
            {
               Tools.setDisabled(_loc1_,false);
            }
            else
            {
               Tools.setDisabled(_loc1_,true);
            }
            _loc1_.countTF.mouseEnabled = false;
            _loc1_.addEventListener(MouseEvent.MOUSE_OVER,this.onGridOverHandler);
            _loc1_.addEventListener(MouseEvent.MOUSE_OUT,this.onGridOutHandler);
            _loc6_++;
         }
         this._gridContainer.y = 460;
         this._gridContainer.x = (770 - this._gridContainer.width) / 2;
         this._gridContainer.addEventListener(MouseEvent.CLICK,this.onGridClickHandler);
      }
      
      private function onGridOverHandler(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         var _loc3_:Array = _loc2_.filters;
         if(_loc3_ == null)
         {
            _loc3_ = [new GlowFilter(16763955,1,2,2,100)];
         }
         else
         {
            _loc3_.push(new GlowFilter(16763955,1,2,2,100));
         }
         _loc2_.filters = _loc3_;
         var _loc4_:String = String(_loc2_.code);
         var _loc5_:String = Data.getInstance().getAttributes("proto",_loc4_,"name");
         var _loc6_:int = Data.getInstance().getAttributes("proto",_loc4_,"type");
         var _loc7_:String = Data.getInstance().getAttributes("proto",_loc4_,"desc");
         var _loc8_:String = (_loc8_ = (_loc8_ = (_loc8_ = "") + ("<font color=\'#e5ce10\'>名称：</font>" + _loc5_ + "\n")) + ("<font color=\'#e5ce10\'>类别：</font>" + (_loc6_ == 1 ? "进化道具" : "战车弹药") + "\n")) + ("<font color=\'#e5ce10\'>说明：</font>" + _loc7_ + "\n");
         dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
            "htmlText":_loc8_,
            "type":3,
            "width":150,
            "height":70
         }));
      }
      
      private function onGridOutHandler(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         var _loc3_:Array = _loc2_.filters;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_] is GlowFilter)
            {
               _loc3_.splice(_loc4_,1);
               break;
            }
            _loc4_++;
         }
         _loc2_.filters = _loc3_;
         dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
      }
      
      private function onGridClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         trace(param1.target);
         if(!(param1.target is MovieClip))
         {
            return;
         }
         if(this._currentGrid != null)
         {
            this._currentGrid.sanjiao.visible = false;
            this._currentGrid = param1.target as MovieClip;
            this._currentGrid.sanjiao.visible = true;
         }
         else
         {
            this._currentGrid = param1.target as MovieClip;
            this._currentGrid.sanjiao.visible = true;
         }
         var _loc2_:String = String(param1.target.code);
         if(RoleModel.getInstance().findBagItem(_loc2_) == true)
         {
            this._ammo = _loc2_;
         }
         else
         {
            this._ammo = "";
         }
      }
      
      private function createLeftArmy() : *
      {
         var _loc1_:int = 0;
         var _loc2_:AbstractSoldier = null;
         this._leftSoldiers = [];
         var _loc3_:int = int(this._leftArmy.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = this.armyFactory(this._leftArmy[_loc4_],1,this._direct == 1 ? true : false);
            if(_loc2_.type == Type.TOUSHICHE)
            {
               _loc2_.x = Fight.TS_POS.x;
               _loc2_.y = Fight.TS_POS.y;
            }
            else
            {
               _loc2_.x = Fight["POS" + _loc1_].x;
               _loc2_.y = Fight["POS" + _loc1_].y;
               _loc1_++;
            }
            addChild(_loc2_);
            this._leftSoldiers.push(_loc2_);
            _loc4_++;
         }
      }
      
      private function createRightArmy() : *
      {
         var _loc1_:int = 0;
         var _loc2_:AbstractSoldier = null;
         this._rightSoldiers = [];
         var _loc3_:int = int(this._rightArmy.length);
         var _loc4_:int = int(this._leftArmy.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc2_ = this.armyFactory(this._rightArmy[_loc5_],-1,this._direct == -1 ? true : false);
            if(_loc2_.type == Type.TOUSHICHE)
            {
               _loc2_.x = 770 - Fight.TS_POS.x;
               _loc2_.y = Fight.TS_POS.y;
            }
            else
            {
               _loc2_.x = 770 - Fight["POS" + _loc1_].x;
               _loc2_.y = Fight["POS" + _loc1_].y;
               _loc1_++;
            }
            if(_loc5_ < _loc4_)
            {
               addChildAt(_loc2_,getChildIndex(this._leftSoldiers[_loc5_] as AbstractSoldier));
            }
            else
            {
               addChild(_loc2_);
            }
            this._rightSoldiers.push(_loc2_);
            _loc5_++;
         }
      }
      
      private function removeSoldier(param1:AbstractSoldier) : *
      {
         var _loc2_:int = 0;
         if(this._ai != null && this._p2p == false && param1.isPlayer == false)
         {
            this._ai.killSoldier(param1);
         }
         if(this._autoAI != null && this._p2p == false && param1.isPlayer == true)
         {
            this._autoAI.killSoldier(param1);
         }
         if(param1.direct == 1)
         {
            _loc2_ = int(this._leftSoldiers.indexOf(param1));
            this._leftSoldiers.splice(_loc2_,1);
         }
         else
         {
            _loc2_ = int(this._rightSoldiers.indexOf(param1));
            this._rightSoldiers.splice(_loc2_,1);
         }
         removeChild(param1);
      }
      
      private function armyFactory(param1:ArmyInfo, param2:int, param3:Boolean) : AbstractSoldier
      {
         switch(param1.type)
         {
            case Type.TOUSHICHE:
               return new Gunner(param1,param2,param3,this);
            case Type.QIBING:
               return new Saber(param1,param2,param3,this);
            case Type.JUNZHU:
               return new Junzhu(param1,param2,param3,this);
            default:
               return new Shooter(param1,param2,param3,this);
         }
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
      
      private function createTipsLayer() : *
      {
         this._tipsLayer = new NumTips();
         addChild(this._tipsLayer);
      }
      
      private function createAmmoTips() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(SkinCode.AMMO_TIPS) as Class;
         this._ammoTips = new _loc1_() as MovieClip;
         this._ammoTips.visible = false;
         this._tipsLayer.addChild(this._ammoTips);
      }
      
      public function findSoldier(param1:int) : AbstractSoldier
      {
         var _loc2_:AbstractSoldier = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(param1 == 1)
         {
            if(this._leftSoldiers.length == 0)
            {
               return null;
            }
            if(this._leftSoldiers.length == 1)
            {
               return this._leftSoldiers[0] as AbstractSoldier;
            }
            _loc2_ = this._leftSoldiers[0] as AbstractSoldier;
            _loc3_ = 1;
            while(_loc3_ < this._leftSoldiers.length)
            {
               if(_loc2_.x < this._leftSoldiers[_loc3_].x)
               {
                  _loc2_ = this._leftSoldiers[_loc3_] as AbstractSoldier;
               }
               _loc3_++;
            }
            return _loc2_;
         }
         if(this._rightSoldiers.length == 0)
         {
            return null;
         }
         if(this._rightSoldiers.length == 1)
         {
            return this._rightSoldiers[0] as AbstractSoldier;
         }
         _loc2_ = this._rightSoldiers[0] as AbstractSoldier;
         _loc4_ = 1;
         while(_loc4_ < this._rightSoldiers.length)
         {
            if(_loc2_.x > this._rightSoldiers[_loc4_].x)
            {
               _loc2_ = this._rightSoldiers[_loc4_] as AbstractSoldier;
            }
            _loc4_++;
         }
         return _loc2_;
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
      
      public function getDistance(param1:AbstractSoldier, param2:AbstractSoldier) : Number
      {
         if(param1 == null || param2 == null)
         {
            return 0;
         }
         var _loc3_:Number = param1.moveDistance * Config.MERIC;
         var _loc4_:Number = param1.attckDistance * Config.MERIC;
         var _loc5_:Number;
         if((_loc5_ = this.getAllDistance(param1,param2)) >= _loc3_)
         {
            return _loc3_;
         }
         return _loc5_;
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
      
      public function hurtByRec(param1:AbstractSoldier, param2:Point, param3:Array, param4:int, param5:String) : *
      {
         var _loc6_:AbstractSoldier = null;
         var _loc7_:Rectangle = new Rectangle(param2.x - param4,0,param4 * 2,stage.stageHeight);
         var _loc8_:int = 0;
         while(_loc8_ < param3.length)
         {
            _loc6_ = param3[_loc8_] as AbstractSoldier;
            if(_loc7_.intersects(_loc6_.getRect(this)))
            {
               if(Tools.getJilv(_loc6_.shanbi) == true)
               {
                  _loc6_.dispatchEvent(new SoldierEvent(SoldierEvent.SHANBI,true));
               }
               else
               {
                  _loc6_.hurt(Logic.getHurtVale(param1,_loc6_,param5));
               }
               return;
            }
            _loc8_++;
         }
      }
      
      public function hurtByJineng(param1:Point, param2:Array, param3:Number) : *
      {
         var _loc4_:AbstractSoldier = null;
         var _loc5_:Rectangle = new Rectangle(param1.x - param3,0,param3 * 2,stage.stageHeight);
         var _loc6_:int = 0;
         while(_loc6_ < param2.length)
         {
            _loc4_ = param2[_loc6_] as AbstractSoldier;
            if(_loc5_.intersects(_loc4_.getRect(this)))
            {
               _loc4_.hurt(_loc4_.maxHP / 10);
            }
            _loc6_++;
         }
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
         this._currentSoldier = param1;
         this._currentSoldier.setSelected();
         param1.setNameVisible(false);
         switch(param1.type)
         {
            case Type.TOUSHICHE:
               if(param1.isPlayer && this._ammo == "")
               {
                  this.setAmmoTips(param1);
                  return;
               }
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
            case Type.QIBING:
               dispatchEvent(new ConEvent(ConEvent.CREATE_MIAOZHUNJING,true));
               break;
            default:
               dispatchEvent(new ConEvent(ConEvent.CREATE_MIAOZHUNJING,true));
         }
      }
      
      private function onMouseClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
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
         var _newSoldier:AbstractSoldier = param1.target as AbstractSoldier;
         // 禁止在武将攻击动画中或已死亡时切换，防止UI卡住（瞄准镜被清但未重建）
         if(_newSoldier != null && (_newSoldier.fireing || _newSoldier.isDead))
         {
            return;
         }
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
         this.setCurrentSoldier(_newSoldier);
      }
      
      private function onSelectSoldierHandler(param1:ConEvent) : *
      {
         // 输入锁定: 瞄准中或力度条调整中禁止键盘切换武将，防止打断攻击
         if(Mouse.prototype.canFire == true)
         {
            return;
         }
         if(this._yuanchengCon.visible == true && this._yuanchengCon.getEnabled() == true)
         {
            return;
         }
         var _newSoldier:AbstractSoldier = this.selectSoldier(param1.data.id,param1.data.code);
         // 禁止在武将攻击动画中或已死亡时切换，防止UI卡住（瞄准镜被清但未重建）
         if(_newSoldier != null && (_newSoldier.fireing || _newSoldier.isDead))
         {
            return;
         }
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
         this.setCurrentSoldier(_newSoldier);
      }
      
      private function onEnemySelectedHandler(param1:SoldierEvent) : *
      {
         trace("敌人被点击了");
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
         trace("瞄准镜显示：",this._miaozhunjing.visible);
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
      
      private function smartAttackHandler(param1:SoldierEvent) : *
      {
         this.onMouseClickHandler(null);
         SmartAttack.makeAI(param1.target as AbstractSoldier,this);
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
         var _loc8_:Boolean = false;
         var _loc9_:AbstractSoldier = null;
         var _loc10_:Class = null;
         var _loc11_:MovieClip = null;
         var _loc12_:Weapon = null;
         var _loc13_:Point = null;
         param1.stopPropagation();
         _loc2_ = param1.target as AbstractSoldier;
         switch(_loc2_.type)
         {
            case Type.TOUSHICHE:
               trace("发射角度:",param1.data.angle,"发射力度:",param1.data.power);
               if(_loc2_.isPlayer == true)
               {
                  trace("攻击弹药",this._ammo);
                  _loc3_ = new StoneWeapon(_loc2_,param1.data.angle,param1.data.power,this._ammo);
               }
               else
               {
                  _loc3_ = new StoneWeapon(_loc2_,param1.data.angle,param1.data.power,_loc2_.feature > 0 ? "proto_2_" + (_loc2_.feature + 4) : "proto_2_3");
               }
               _loc4_ = _loc2_.getHurPoint(this);
               trace("起始坐标:",_loc4_);
               _loc3_.x = _loc4_.x;
               _loc3_.y = _loc4_.y;
               addChild(_loc3_);
               _loc3_.addEventListener(WeaponEvent.WEAPON_END,this.onStoneWeaponEndHandler);
               _loc3_.run();
               if(_loc2_.isPlayer && this._ammo != "")
               {
                  dispatchEvent(new FightEvent(FightEvent.USE_AMMO,true,{"id":RoleModel.getInstance().findBagItemID(this._ammo)}));
                  RoleModel.getInstance().delBagItem(this._ammo);
                  _loc8_ = RoleModel.getInstance().findBagItem(this._ammo);
                  this._currentGrid.countTF.text = RoleModel.getInstance().getBagItemCount(this._ammo);
                  if(_loc8_ == true)
                  {
                     Tools.setDisabled(this._currentGrid,false);
                  }
                  else
                  {
                     Tools.setDisabled(this._currentGrid,true);
                     if(this._currentGrid != null && this._currentGrid.code == this._ammo)
                     {
                        this._currentGrid.sanjiao.visible = false;
                        this._currentGrid = null;
                     }
                     this._ammo = "";
                  }
               }
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
                  if(Tools.getJilv(_loc5_.shanbi) == true)
                  {
                     _loc5_.dispatchEvent(new SoldierEvent(SoldierEvent.SHANBI,true));
                  }
                  else
                  {
                     _loc5_.hurt(Logic.getHurtVale(_loc2_,_loc5_),_loc2_);
                  }
               }
               break;
            case Type.JUNZHU:
               if(param1.data.type == "baoji")
               {
                  if((_loc9_ = param1.data.target as AbstractSoldier) != null)
                  {
                     (_loc11_ = new (_loc10_ = ApplicationDomain.currentDomain.getDefinition("jineng_" + _loc2_.code) as Class)() as MovieClip).mouseEnabled = false;
                     _loc11_.mouseChildren = false;
                     _loc11_.addEventListener(Event.ENTER_FRAME,this.jinengEnterFrameHandler);
                     _loc11_.scaleX = 0.9 * _loc2_.direct;
                     _loc11_.scaleY = 0.9;
                     _loc11_.x = _loc9_.x;
                     _loc11_.y = _loc2_.y;
                     _loc11_.direct = _loc2_.direct;
                     addChild(_loc11_);
                  }
               }
               else
               {
                  _loc12_ = new Weapon(_loc2_,param1.data.target as AbstractSoldier);
                  _loc13_ = _loc2_.getHurPoint(this);
                  _loc12_.x = _loc13_.x;
                  _loc12_.y = _loc13_.y;
                  _loc12_.addEventListener(WeaponEvent.WEAPON_END,this.onWeaponEndHandler);
                  addChildAt(_loc12_,getChildIndex(_loc2_));
                  _loc12_.run();
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
      
      private function jinengEnterFrameHandler(param1:Event) : void
      {
         if(param1.currentTarget.currentFrameLabel == "_jinengOver")
         {
            param1.currentTarget.removeEventListener(Event.ENTER_FRAME,this.jinengEnterFrameHandler);
            removeChild(param1.currentTarget as MovieClip);
         }
         else if(param1.currentTarget.currentFrameLabel == "_hurt")
         {
            if(param1.currentTarget.direct == 1)
            {
               this.hurtByJineng(new Point(param1.currentTarget.x,param1.currentTarget.y),this._rightSoldiers,75);
            }
            else
            {
               this.hurtByJineng(new Point(param1.currentTarget.x,param1.currentTarget.y),this._leftSoldiers,75);
            }
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
            if(Tools.getJilv(_loc2_.shanbi) == true)
            {
               _loc2_.dispatchEvent(new SoldierEvent(SoldierEvent.SHANBI,true));
            }
            else
            {
               _loc2_.hurt(Logic.getHurtVale(_loc3_,_loc2_),_loc3_);
            }
         }
      }
      
      private function onStoneWeaponEndHandler(param1:WeaponEvent) : *
      {
         param1.currentTarget.removeEventListener(WeaponEvent.WEAPON_END,this.onStoneWeaponEndHandler);
         var _loc2_:AbstractSoldier = param1.data.hurt;
         this.shake();
         if(_loc2_.direct == 1)
         {
            this.hurtByRec(_loc2_,new Point(param1.currentTarget.x,param1.currentTarget.y),this._rightSoldiers,param1.data.radiu,param1.data.ammo);
         }
         else
         {
            this.hurtByRec(_loc2_,new Point(param1.currentTarget.x,param1.currentTarget.y),this._leftSoldiers,param1.data.radiu,param1.data.ammo);
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
      
      private function onSoldierShanbiHandler(param1:SoldierEvent) : *
      {
         var _loc2_:Point = new Point(param1.target.x,param1.target.y - 50);
         var _loc3_:Point = _loc2_.clone();
         _loc3_.y -= 50;
         this._tipsLayer.addShanbi(_loc2_);
      }
      
      private function onSoldierHuifuHandler(param1:SoldierEvent) : *
      {
         var _loc2_:Point = new Point(param1.target.x,param1.target.y - 50);
         var _loc3_:Point = _loc2_.clone();
         _loc3_.y -= 50;
         var _loc4_:int = param1.data as int;
         this._tipsLayer.addTips2(_loc4_,_loc2_);
      }
      
      private function onSoldierDeadHandler(param1:SoldierEvent) : *
      {
         var _loc2_:AbstractSoldier = param1.target as AbstractSoldier;
         if(this._currentSoldier != null && this._currentSoldier == _loc2_)
         {
            this.resetController();
            this._currentSoldier = null;
         }
         this._fightUI.checkDead(_loc2_.armyInfo.id,_loc2_.armyInfo.code);
      }
      
      private function onSoldierDeadCompleteHandler(param1:SoldierEvent) : *
      {
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         this.removeSoldier(param1.target as AbstractSoldier);
         if(this._isOver != true)
         {
            if(this._leftSoldiers.length == 0)
            {
               this.clear();
               this._isOver = true;
               if(this._direct == 1)
               {
                  _loc2_ = "lost";
                  _loc3_ = this.getRightLevelAverage();
                  _loc4_ = this.getLeftLevelAverage();
               }
               else
               {
                  _loc2_ = "win";
                  _loc3_ = this.getLeftLevelAverage();
                  _loc4_ = this.getRightLevelAverage();
               }
               dispatchEvent(new FightEvent(FightEvent.FIGHT_COMPLETE,true,{
                  "flag":_loc2_,
                  "m":_loc3_,
                  "n":_loc4_
               }));
            }
            else if(this._rightSoldiers.length == 0)
            {
               this.clear();
               this._isOver = true;
               if(this._direct == 1)
               {
                  _loc2_ = "win";
                  _loc3_ = this.getRightLevelAverage();
                  _loc4_ = this.getLeftLevelAverage();
               }
               else
               {
                  _loc2_ = "lost";
                  _loc3_ = this.getRightLevelAverage();
                  _loc4_ = this.getLeftLevelAverage();
               }
               dispatchEvent(new FightEvent(FightEvent.FIGHT_COMPLETE,true,{
                  "flag":_loc2_,
                  "m":_loc3_,
                  "n":_loc4_
               }));
            }
         }
      }
      
      private function removeAllEvent() : *
      {
         removeEventListener(SoldierEvent.SELECTED,this.onSoldierSelectedHandler);
         removeEventListener(SoldierEvent.ENEMY_SELECTED,this.onEnemySelectedHandler);
         removeEventListener(SoldierEvent.SMART_ATTACK,this.smartAttackHandler);
         removeEventListener(MouseEvent.CLICK,this.onMouseClickHandler);
         removeEventListener(ConEvent.CREATE_MIAOZHUNJING,this.createMiaozhunjingHandler);
         removeEventListener(ConEvent.FIRE,this.conFireHandler);
         removeEventListener(SoldierEvent.FILL_COMPLETE,this.onSoldierFillCompleteHandler);
         removeEventListener(SoldierEvent.FIRE_COMPLETE,this.onSoldierFireCompleteHandler);
         removeEventListener(SoldierEvent.BEHURT,this.onSoldierBehurtHandler);
         removeEventListener(SoldierEvent.SHANBI,this.onSoldierShanbiHandler);
         removeEventListener(SoldierEvent.HUIFU,this.onSoldierHuifuHandler);
         removeEventListener(SoldierEvent.DEAD,this.onSoldierDeadHandler);
         removeEventListener(SoldierEvent.DEAD_COMPLETE,this.onSoldierDeadCompleteHandler);
         this._miaozhunjing.removeEventListener(Event.ENTER_FRAME,this.onMiaozhunjingEnterFrameHandler);
         removeEventListener(SoldierEvent.ENEMY_LOCKED,this.enemyLockHandler);
         removeEventListener(SoldierEvent.ENEMY_UNLOCKED,this.enemyUnlockHandler);
         this._gridContainer.removeEventListener(MouseEvent.CLICK,this.onGridClickHandler);
         this.hideAmmoTipsHandler(null);
      }
      
      private function getLeftLevelAverage() : Number
      {
         var _loc1_:Number = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._leftArmy.length)
         {
            _loc1_ += this._leftArmy[_loc2_].level;
            _loc2_++;
         }
         return _loc1_;
      }
      
      private function getRightLevelAverage() : Number
      {
         var _loc1_:Number = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._rightArmy.length)
         {
            _loc1_ += this._rightArmy[_loc2_].level;
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function get ammo() : String
      {
         return this._ammo;
      }
      
      public function setAmmoTips(param1:AbstractSoldier) : *
      {
         if(this._ammoTips.visible == true)
         {
            return;
         }
         this._ammoTips.x = param1.x;
         this._ammoTips.y = param1.y - 70;
         this._ammoTips.visible = true;
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.hideAmmoTipsHandler,true);
      }
      
      public function getAutoMode() : Boolean
      {
         return this._auto;
      }
      
      public function get leftSoldiers() : Array
      {
         return this._leftSoldiers;
      }
      
      public function get rightSoldiers() : Array
      {
         return this._rightSoldiers;
      }
      
      public function startAI(param1:Number, param2:int) : void
      {
         this._ai = new AI(this,this._delay,param2);
         this.createStartAni();
      }
      
      private function createStartAni() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(SkinCode.START_ANI) as Class;
         var _loc2_:MovieClip = new _loc1_() as MovieClip;
         _loc2_.x = width / 2;
         _loc2_.y = height / 2 - 50;
         addChild(_loc2_);
         _loc2_.addEventListener(Event.COMPLETE,this.onStartAniCompleteHandler);
         _loc2_.addEventListener(MouseEvent.CLICK,this.AniClickHandler);
      }
      
      private function AniClickHandler(param1:MouseEvent) : *
      {
         if(param1.target is SimpleButton)
         {
            if(MyPoint.autoFightPoint_old == null)
            {
               MyPoint.autoFightPoint_old = new Point(param1.localX,param1.localY);
            }
            else
            {
               MyPoint.autoFightPoint_new = new Point(param1.localX,param1.localY);
            }
            if(MyPoint.autoFightPoint_new != null && MyPoint.autoFightPoint_new.equals(MyPoint.autoFightPoint_old) && MyPoint.stagePoint_new != null && MyPoint.stagePoint_new.equals(MyPoint.stagePoint_old))
            {
               this._auto = false;
               (param1.currentTarget as MovieClip).frame.visible = false;
            }
            else
            {
               this._auto = true;
               (param1.currentTarget as MovieClip).frame.visible = false;
            }
         }
      }
      
      private function onStartAniCompleteHandler(param1:Event) : *
      {
         param1.currentTarget.removeEventListener(Event.COMPLETE,this.onStartAniCompleteHandler);
         removeChild(param1.currentTarget as MovieClip);
         if(this._auto == true)
         {
            this.onMouseClickHandler(null);
            this.initUnInteractiveEvent();
            this._autoAI = new AI(this,5000,this._direct);
            this._autoAI.startAI();
         }
         else
         {
            this.initEvent();
         }
         this._ai.startAI();
         this._date = new Date().getTime();
         this._timer = new Timer(Config.NORMAL);
         this._timer.addEventListener(TimerEvent.TIMER,this.speedCheckHandler);
         this._timer.start();
         if(MyPoint.stagePoint_new != null)
         {
            MyPoint.stagePoint_old = MyPoint.stagePoint_new;
            MyPoint.stagePoint_new = null;
         }
         if(MyPoint.autoFightPoint_new != null)
         {
            MyPoint.autoFightPoint_old = MyPoint.autoFightPoint_new;
            MyPoint.autoFightPoint_new = null;
         }
      }
      
      private function speedCheckHandler(param1:TimerEvent) : *
      {
         var _loc2_:Number = new Date().getTime() - this._date;
         if(_loc2_ < Config.ERROR)
         {
            ++this._biansu;
            if(this._biansu >= Config.ERROR_COUNT)
            {
               this._timer.reset();
               this._timer.removeEventListener(TimerEvent.TIMER,this.speedCheckHandler);
               this._timer = null;
               this.clear();
               dispatchEvent(new UIEvent(UIEvent.SPEED_CHECKOUT,true,{"flag":"fight"}));
            }
         }
         else if(_loc2_ == Config.NORMAL)
         {
            this._biansu = 0;
            this._date = new Date().getTime();
         }
         else
         {
            this._date = new Date().getTime();
         }
      }
      
      public function clear() : *
      {
         if(this._timer != null)
         {
            this._timer.reset();
            this._timer.removeEventListener(TimerEvent.TIMER,this.speedCheckHandler);
         }
         this.removeAllEvent();
         Mouse.show();
         Mouse.prototype.isHide = false;
         Mouse.prototype.canFire = false;
         if(this._ai != null)
         {
            this._ai.stopAI();
         }
         if(this._autoAI != null)
         {
            this._autoAI.stopAI();
         }
         this._yuanchengCon.stopBar();
         this._yuanchengCon.visible = false;
         this._miaozhunjing.visible = false;
         // 清理撤退按钮
         if(this._retreatBtn != null)
         {
            this._retreatBtn.removeEventListener(MouseEvent.CLICK, this.retreatClickHandler);
            if(this._retreatBtn.parent) this._retreatBtn.parent.removeChild(this._retreatBtn);
            this._retreatBtn = null;
         }
      }
      
      public function setPartAndLevel(param1:int, param2:int) : *
      {
         this._part = param1;
         this._level = param2;
         var _loc3_:int = Data.getInstance().getStageID(this._part,this._level);
         var _loc4_:Class = ApplicationDomain.currentDomain.getDefinition("title_" + _loc3_) as Class;
         this._title = new Bitmap(new _loc4_() as BitmapData);
         addChild(this._title);
         this._title.x = (stage.stageWidth - this._title.width) / 2;
         this._title.y = 30;
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function get part() : int
      {
         return this._part;
      }
      
      public function get p2p() : Boolean
      {
         return this._p2p;
      }
      
      private function selectSoldier(param1:Number, param2:String) : AbstractSoldier
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this._direct == 1)
         {
            _loc3_ = 0;
            while(_loc3_ < this._leftSoldiers.length)
            {
               if(this._leftSoldiers[_loc3_].armyInfo.id == param1 && this._leftSoldiers[_loc3_].armyInfo.code == param2)
               {
                  return this._leftSoldiers[_loc3_] as AbstractSoldier;
               }
               _loc3_++;
            }
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < this._rightSoldiers.length)
            {
               if(this._rightSoldiers[_loc4_].armyInfo.id == param1 && this._rightSoldiers[_loc4_].armyInfo.code == param2)
               {
                  return this._rightSoldiers[_loc4_] as AbstractSoldier;
               }
               _loc4_++;
            }
         }
         return null;
      }
      
            

      private function onKeydownHandler(param1:KeyboardEvent) : *
      {
         switch(param1.keyCode)
         {
            case 49:
               this._fightUI.setSelect(1);
               break;
            case 50:
               this._fightUI.setSelect(2);
               break;
            case 51:
               this._fightUI.setSelect(3);
               break;
            case 52:
               this._fightUI.setSelect(4);
               break;
            case 53:
               this._fightUI.setSelect(5);
         }
      }

      // Web键盘轮询: 每帧通过ExternalInterface向JS查询当前按键
      // 浏览器Flash插件中stage KEY_DOWN不可靠(PPAPI沙箱),
      // 改用主动轮询JS侧的按键队列。边缘检测防止持续触发setSelect
      private var _webKeyLastPoll:int = 0;
      private var _webKeyPrev:int = 0;
      private function pollWebKeys(param1:Event) : void
      {
         if(!Config.IS_WEB || !ExternalInterface.available) return;
         try {
            var _key:* = ExternalInterface.call("_sgqzPollKey");
            var _keyInt:int = (_key is Number) ? int(_key) : 0;
            if(_keyInt >= 1 && _keyInt <= 5 && _keyInt != this._webKeyPrev) {
               this._fightUI.setSelect(_keyInt);
            }
            this._webKeyPrev = _keyInt;
         } catch(_e:Error) {}
      }

      private function hideAmmoTipsHandler(param1:MouseEvent) : *
      {
         stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.hideAmmoTipsHandler,true);
         this._ammoTips.visible = false;
      }
   }
}
