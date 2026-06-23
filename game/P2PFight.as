package game
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Elastic;
   import com.iflashigame.net.ChatManager;
   import com.iflashigame.talk.TalkField;
   import com.iflashigame.utils.GlobalTimer;
   import com.iflashigame.utils.Tools;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
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
   import game.model.Head;
   import game.model.RoleModel;
   import game.model.Type;
   import game.ui.AngleController;
   import game.ui.ConType;
   import game.ui.EquipDropFX;
   import game.ui.FightUI;
   import game.ui.NumTips;
   import game.ui.P2PFightTalk;
   import game.ui.SkinCode;
   
   public class P2PFight extends Sprite implements IWorld, IAI
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
      
      private var _leftInfo:Object;
      
      private var _rightInfo:Object;
      
      private var _direct:int;
      
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
      
      private var _ammo:String = "";
      
      private var _title:Bitmap;
      
      private var _gridContainer:Sprite;
      
      private var _talkInputTF:TextField;
      
      private var _talkTF:TextField;
      
      private var _currentGrid:MovieClip;
      
      private var _auto:Boolean = false;
      
      private var _autoAI:AI;
      
      private var _lockedEnemy:AbstractSoldier;
      
      private var _talkArea:TextField;
      
      private var _talkInput:P2PFightTalk;
      
      public var _date:Number;
      
      private var _biansu:int = 0;
      
      public var _talkField:TalkField;
      
      private var _fightUI:FightUI;
      
      private var _ammoTips:MovieClip;
      
      public function P2PFight(param1:Vector.<ArmyInfo>, param2:Vector.<ArmyInfo>, param3:Object, param4:Object, param5:int = 1)
      {
         super();
         this._leftArmy = param1.sort(this.compare);
         this._rightArmy = param2.sort(this.compare);
         this._direct = param5;
         this._leftInfo = param3;
         this._rightInfo = param4;
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
            this._auto = true;
            (param1.currentTarget as MovieClip).frame.visible = false;
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
         // Web键盘轮询: Flash通过ExternalInterface.call获取JS按键
         addEventListener(Event.ENTER_FRAME,this.pollWebKeys);

            this._autoAI = new AI(this,5000,this._direct,true);
            this._autoAI.startAI();
         }
         else
         {
            this.initEvent();
         }
         this._date = new Date().getTime();
         this._timer = new Timer(Config.NORMAL);
         this._timer.addEventListener(TimerEvent.TIMER,this.speedCheckHandler);
         this._timer.start();
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
         this.createTitle();
         this.creatImage();
         this.createTalk();
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
         addEventListener(SoldierEvent.P2P_ACTION,this.onP2PActionHandler);
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
            this._fightUI.initData(this._rightArmy,-1);
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
         var _loc1_:int = 0;
         var _loc4_:Bitmap = null;
         _loc1_ = 0;
         var _loc2_:MovieClip = null;
         var _loc3_:Class = null;
         _loc4_ = null;
         var _loc5_:Boolean = false;
         this._gridContainer = new Sprite();
         this._gridContainer.graphics.beginFill(0,0.4);
         this._gridContainer.graphics.drawRoundRect(0,0,314,38,4,4);
         this._gridContainer.graphics.endFill();
         addChild(this._gridContainer);
         var _loc6_:Class = ApplicationDomain.currentDomain.getDefinition(SkinCode.ICON_GRID) as Class;
         _loc1_ = 1;
         while(_loc1_ <= 8)
         {
            _loc2_ = new _loc6_() as MovieClip;
            _loc2_.buttonMode = true;
            _loc2_.name = "grid" + _loc1_;
            _loc3_ = ApplicationDomain.currentDomain.getDefinition("proto_2_" + _loc1_) as Class;
            (_loc4_ = new Bitmap(new _loc3_() as BitmapData)).x = 2;
            _loc4_.y = 2;
            _loc2_.addChildAt(_loc4_,0);
            _loc2_.x = 6 + (_loc1_ - 1) * (_loc2_.width + 4);
            _loc2_.y = 2;
            _loc2_.code = "proto_2_" + _loc1_;
            this._gridContainer.addChild(_loc2_);
            _loc5_ = RoleModel.getInstance().findBagItem("proto_2_" + _loc1_);
            _loc2_.countTF.text = RoleModel.getInstance().getBagItemCount("proto_2_" + _loc1_);
            _loc2_.sanjiao.visible = false;
            if(_loc5_ == true)
            {
               Tools.setDisabled(_loc2_,false);
            }
            else
            {
               Tools.setDisabled(_loc2_,true);
            }
            _loc2_.countTF.mouseEnabled = false;
            _loc2_.addEventListener(MouseEvent.MOUSE_OVER,this.onGridOverHandler);
            _loc2_.addEventListener(MouseEvent.MOUSE_OUT,this.onGridOutHandler);
            _loc1_++;
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
         if(this._direct == 1)
         {
            if(RoleModel.getInstance().findBagItem(_loc2_) == true)
            {
               this._ammo = _loc2_;
            }
            else
            {
               this._ammo = "";
            }
         }
         else if(this._direct == -1)
         {
            if(RoleModel.getInstance().findBagItem(_loc2_) == true)
            {
               this._ammo = _loc2_;
            }
            else
            {
               this._ammo = "";
            }
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
               _loc2_.x = P2PFight.TS_POS.x;
               _loc2_.y = P2PFight.TS_POS.y;
            }
            else
            {
               _loc2_.x = P2PFight["POS" + _loc1_].x;
               _loc2_.y = P2PFight["POS" + _loc1_].y;
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
               _loc2_.x = 770 - P2PFight.TS_POS.x;
               _loc2_.y = P2PFight.TS_POS.y;
            }
            else
            {
               _loc2_.x = 770 - P2PFight["POS" + _loc1_].x;
               _loc2_.y = P2PFight["POS" + _loc1_].y;
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
      
      private function createTitle() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition("title_vs") as Class;
         this._title = new Bitmap(new _loc1_() as BitmapData);
         addChild(this._title);
         this._title.x = (stage.stageWidth - this._title.width) / 2;
         this._title.y = 20;
      }
      
      private function creatImage() : *
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.mouseChildren = false;
         _loc1_.mouseEnabled = true;
         addChild(_loc1_);
         _loc1_.graphics.beginFill(0,0.3);
         _loc1_.graphics.drawRoundRect(4,4,170,74,15,15);
         _loc1_.graphics.drawRoundRect(770 - 170 - 4,4,170,74,15,15);
         _loc1_.graphics.endFill();
         var _loc2_:Class = ApplicationDomain.currentDomain.getDefinition("image" + this._leftInfo.image) as Class;
         var _loc3_:Class = ApplicationDomain.currentDomain.getDefinition("image" + this._rightInfo.image) as Class;
         var _loc4_:MovieClip;
         (_loc4_ = new _loc2_() as MovieClip).scaleX = 0.58;
         _loc4_.scaleY = 0.58;
         var _loc5_:MovieClip;
         (_loc5_ = new _loc3_() as MovieClip).scaleX = 0.58;
         _loc5_.scaleY = 0.58;
         _loc4_.gotoAndStop(2);
         _loc5_.gotoAndStop(2);
         _loc4_.x = 8;
         _loc4_.y = 8;
         _loc5_.x = 770 - _loc5_.width - 8;
         _loc5_.y = 8;
         _loc1_.addChild(_loc4_);
         _loc1_.addChild(_loc5_);
         var _loc6_:TextField = new TextField();
         var _loc7_:TextField = new TextField();
         _loc6_.selectable = false;
         _loc7_.selectable = false;
         _loc6_.multiline = true;
         _loc7_.multiline = true;
         _loc1_.addChild(_loc6_);
         _loc1_.addChild(_loc7_);
         var _loc8_:TextFormat;
         (_loc8_ = new TextFormat()).color = 16777215;
         _loc8_.leading = 4;
         _loc6_.defaultTextFormat = _loc8_;
         var _loc9_:TextFormat;
         (_loc9_ = new TextFormat()).color = 16777215;
         _loc9_.leading = 4;
         _loc9_.align = "right";
         _loc7_.defaultTextFormat = _loc9_;
         _loc6_.filters = [new GlowFilter(0,1,2,2,100)];
         _loc7_.filters = [new GlowFilter(0,1,2,2,100)];
         _loc6_.text = this._leftInfo.name + "\nLv：" + this._leftInfo.level + "\n" + this._leftInfo.delay + "ms";
         _loc7_.text = this._rightInfo.name + "\nLv：" + this._rightInfo.level + "\n" + this._rightInfo.delay + "ms";
         _loc6_.width = _loc6_.textWidth + 5;
         _loc7_.width = _loc7_.textWidth + 5;
         _loc6_.x = _loc4_.x + _loc4_.width + 3;
         _loc6_.y = 10;
         _loc7_.x = _loc5_.x - 3 - _loc7_.width;
         _loc7_.y = 10;
      }
      
      private function createTalk() : *
      {
         this._talkInput = new P2PFightTalk(SkinCode.P2PFight_Talk);
         this._talkInput.y = 430;
         this._talkInput.x = (770 - this._talkInput.width) / 2;
         this._talkInput.addEventListener(UIEvent.SEND_TALK,this.sendTalkHandler);
         addChild(this._talkInput);
         this._talkArea = new TextField();
         this._talkArea.width = 320;
         this._talkArea.height = 64;
         this._talkArea.multiline = true;
         this._talkArea.wordWrap = true;
         this._talkArea.textColor = 15724527;
         this._talkArea.selectable = false;
         this._talkArea.mouseEnabled = false;
         this._talkArea.y = 90;
         this._talkArea.x = 5;
         this._talkArea.filters = [new GlowFilter(0,1,2,2,50)];
         addChild(this._talkArea);
      }
      
      private function sendTalkHandler(param1:UIEvent) : *
      {
         var _loc2_:* = null;
         var _loc3_:String = RoleModel.getInstance().roleName;
         var _loc4_:int;
         if((_loc4_ = RoleModel.getInstance().imageID) % 2 == 1)
         {
            _loc2_ = "<font color=\'#6CDDF5\'>" + _loc3_ + "：</font>" + this._talkInput.getText() + "\n";
         }
         else
         {
            _loc2_ = "<font color=\'#FC9595\'>" + _loc3_ + "：</font>" + this._talkInput.getText() + "\n";
         }
         this.setArea(_loc2_);
         var _loc5_:Object;
         (_loc5_ = {}).head = Head.P2P_TALK;
         _loc5_.text = _loc2_;
         ChatManager.getInstance().p2pSend(_loc5_);
      }
      
      public function setArea(param1:String) : *
      {
         this._talkArea.htmlText += param1;
         this._talkArea.scrollV = this._talkArea.maxScrollV;
      }
      
      private function removeSoldier(param1:AbstractSoldier) : *
      {
         var _loc2_:int = 0;
         if(this._autoAI != null && param1.isPlayer == true)
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
         if(param1.type == Type.TOUSHICHE && param1.isPlayer == true)
         {
            this.hideAmmoTipsHandler(null);
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
         var _loc7_:Object = null;
         var _loc8_:Rectangle = new Rectangle(param2.x - param4,0,param4 * 2,stage.stageHeight);
         var _loc9_:int = 0;
         while(_loc9_ < param3.length)
         {
            _loc6_ = param3[_loc9_] as AbstractSoldier;
            if(_loc8_.intersects(_loc6_.getRect(this)))
            {
               if(param1.isPlayer == true)
               {
                  _loc7_ = {};
                  if(Tools.getJilv(_loc6_.shanbi) == true)
                  {
                     _loc7_.head = ChatManager.getInstance().server == true ? Head.SHANBI_FROM_SERVER : Head.SHANBI_FROM_CLIENT;
                     _loc7_.direct = _loc6_.direct;
                     _loc7_.code = _loc6_.code;
                     ChatManager.getInstance().p2pSend(_loc7_);
                     _loc6_.dispatchEvent(new SoldierEvent(SoldierEvent.SHANBI,true));
                  }
                  else
                  {
                     _loc7_.head = ChatManager.getInstance().server == true ? Head.HURT_FROM_SERVER : Head.HURT_FROM_CLIENT;
                     _loc7_.direct = _loc6_.direct;
                     _loc7_.code = _loc6_.code;
                     _loc7_.hurt = Logic.getHurtVale(param1,_loc6_,param5);
                     ChatManager.getInstance().p2pSend(_loc7_);
                     _loc6_.hurt(_loc7_.hurt);
                  }
               }
               return;
            }
            _loc9_++;
         }
      }
      
      public function hurtByJineng(param1:AbstractSoldier, param2:Point, param3:Array, param4:Number) : *
      {
         var _loc5_:AbstractSoldier = null;
         var _loc6_:Object = null;
         var _loc7_:Rectangle = new Rectangle(param2.x - param4,0,param4 * 2,stage.stageHeight);
         var _loc8_:int = 0;
         while(_loc8_ < param3.length)
         {
            _loc5_ = param3[_loc8_] as AbstractSoldier;
            if(_loc7_.intersects(_loc5_.getRect(this)))
            {
               if(param1.isPlayer == true)
               {
                  (_loc6_ = {}).head = ChatManager.getInstance().server == true ? Head.HURT_FROM_SERVER : Head.HURT_FROM_CLIENT;
                  _loc6_.direct = _loc5_.direct;
                  _loc6_.code = _loc5_.code;
                  _loc6_.hurt = _loc5_.maxHP / 10;
                  ChatManager.getInstance().p2pSend(_loc6_);
                  _loc5_.hurt(_loc6_.hurt);
               }
            }
            _loc8_++;
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
         SmartAttack.makeAI(param1.target as AbstractSoldier,this,true);
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
                  "power":param1.data.power,
                  "ammo":this._ammo
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
         var _loc5_:Weapon = null;
         var _loc6_:Point = null;
         var _loc7_:Boolean = false;
         var _loc8_:AbstractSoldier = null;
         var _loc9_:Object = null;
         var _loc10_:AbstractSoldier = null;
         var _loc11_:Class = null;
         var _loc12_:MovieClip = null;
         var _loc13_:Weapon = null;
         var _loc14_:Point = null;
         param1.stopPropagation();
         _loc2_ = param1.target as AbstractSoldier;
         switch(_loc2_.type)
         {
            case Type.TOUSHICHE:
               trace("发射角度:",param1.data.angle,"发射力度:",param1.data.power);
               if(_loc2_.isPlayer == true)
               {
                  _loc3_ = new StoneWeapon(_loc2_,param1.data.angle,param1.data.power,this._ammo);
               }
               else
               {
                  _loc3_ = new StoneWeapon(_loc2_,param1.data.angle,param1.data.power,param1.data.ammo);
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
                  _loc7_ = RoleModel.getInstance().findBagItem(this._ammo);
                  this._currentGrid.countTF.text = RoleModel.getInstance().getBagItemCount(this._ammo);
                  if(_loc7_ == true)
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
               if(_loc2_.isPlayer == true)
               {
                  if(_loc2_.direct == 1)
                  {
                     _loc8_ = this.findSoldier(-1);
                  }
                  else
                  {
                     _loc8_ = this.findSoldier(1);
                  }
                  if(_loc8_ != null)
                  {
                     _loc9_ = {};
                     if(Tools.getJilv(_loc8_.shanbi) == true)
                     {
                        _loc9_.head = ChatManager.getInstance().server == true ? Head.SHANBI_FROM_SERVER : Head.SHANBI_FROM_CLIENT;
                        _loc9_.direct = _loc8_.direct;
                        _loc9_.code = _loc8_.code;
                        ChatManager.getInstance().p2pSend(_loc9_);
                        _loc8_.dispatchEvent(new SoldierEvent(SoldierEvent.SHANBI,true));
                     }
                     else
                     {
                        _loc9_.head = ChatManager.getInstance().server == true ? Head.HURT_FROM_SERVER : Head.HURT_FROM_CLIENT;
                        _loc9_.direct = _loc8_.direct;
                        _loc9_.code = _loc8_.code;
                        _loc9_.hurt = Logic.getHurtVale(_loc2_,_loc8_);
                        _loc9_.soldierCode = _loc2_.code;
                        ChatManager.getInstance().p2pSend(_loc9_);
                        _loc8_.hurt(_loc9_.hurt,_loc2_);
                     }
                  }
               }
               break;
            case Type.JUNZHU:
               if(param1.data.type == "baoji")
               {
                  if((_loc10_ = param1.data.target as AbstractSoldier) != null)
                  {
                     (_loc12_ = new (_loc11_ = ApplicationDomain.currentDomain.getDefinition("jineng_" + _loc2_.code) as Class)() as MovieClip).mouseEnabled = false;
                     _loc12_.mouseChildren = false;
                     _loc12_.addEventListener(Event.ENTER_FRAME,this.jinengEnterFrameHandler);
                     _loc12_.scaleX = 0.9 * _loc2_.direct;
                     _loc12_.scaleY = 0.9;
                     _loc12_.x = _loc10_.x;
                     _loc12_.y = _loc2_.y;
                     _loc12_.direct = _loc2_.direct;
                     _loc12_.owner = _loc2_;
                     addChild(_loc12_);
                  }
               }
               else
               {
                  _loc13_ = new Weapon(_loc2_,param1.data.target as AbstractSoldier);
                  _loc14_ = _loc2_.getHurPoint(this);
                  _loc13_.x = _loc14_.x;
                  _loc13_.y = _loc14_.y;
                  _loc13_.addEventListener(WeaponEvent.WEAPON_END,this.onWeaponEndHandler);
                  addChildAt(_loc13_,getChildIndex(_loc2_));
                  _loc13_.run();
               }
               break;
            default:
               _loc5_ = new Weapon(_loc2_,param1.data.target as AbstractSoldier);
               _loc6_ = _loc2_.getHurPoint(this);
               _loc5_.x = _loc6_.x;
               _loc5_.y = _loc6_.y;
               _loc5_.addEventListener(WeaponEvent.WEAPON_END,this.onWeaponEndHandler);
               addChildAt(_loc5_,getChildIndex(_loc2_));
               _loc5_.run();
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
               this.hurtByJineng(param1.currentTarget.owner as AbstractSoldier,new Point(param1.currentTarget.x,param1.currentTarget.y),this._rightSoldiers,75);
            }
            else
            {
               this.hurtByJineng(param1.currentTarget.owner as AbstractSoldier,new Point(param1.currentTarget.x,param1.currentTarget.y),this._leftSoldiers,75);
            }
         }
      }
      
      private function onWeaponEndHandler(param1:WeaponEvent) : *
      {
         var _loc2_:Object = null;
         param1.currentTarget.removeEventListener(WeaponEvent.WEAPON_END,this.onWeaponEndHandler);
         removeChild(param1.currentTarget as Weapon);
         var _loc3_:AbstractSoldier = param1.data.behurt;
         var _loc4_:AbstractSoldier = param1.data.hurt;
         if(_loc3_ != null && _loc4_ != null && _loc4_.isPlayer == true)
         {
            _loc2_ = {};
            if(Tools.getJilv(_loc3_.shanbi) == true)
            {
               _loc2_.head = ChatManager.getInstance().server == true ? Head.SHANBI_FROM_SERVER : Head.SHANBI_FROM_CLIENT;
               _loc2_.direct = _loc3_.direct;
               _loc2_.code = _loc3_.code;
               ChatManager.getInstance().p2pSend(_loc2_);
               _loc3_.dispatchEvent(new SoldierEvent(SoldierEvent.SHANBI,true));
            }
            else
            {
               _loc2_.head = ChatManager.getInstance().server == true ? Head.HURT_FROM_SERVER : Head.HURT_FROM_CLIENT;
               _loc2_.direct = _loc3_.direct;
               _loc2_.code = _loc3_.code;
               _loc2_.hurt = Logic.getHurtVale(_loc4_,_loc3_);
               _loc2_.soldierCode = _loc4_.code;
               ChatManager.getInstance().p2pSend(_loc2_);
               _loc3_.hurt(_loc2_.hurt,_loc4_);
            }
         }
      }
      
      private function onStoneWeaponEndHandler(param1:WeaponEvent) : *
      {
         param1.currentTarget.removeEventListener(WeaponEvent.WEAPON_END,this.onStoneWeaponEndHandler);
         var _loc2_:AbstractSoldier = param1.data.hurt;
         this.shake();
         if(_loc2_ != null && _loc2_.isPlayer == true)
         {
            if(_loc2_.direct == 1)
            {
               this.hurtByRec(_loc2_,new Point(param1.currentTarget.x,param1.currentTarget.y),this._rightSoldiers,param1.data.radiu,param1.data.ammo);
            }
            else
            {
               this.hurtByRec(_loc2_,new Point(param1.currentTarget.x,param1.currentTarget.y),this._leftSoldiers,param1.data.radiu,param1.data.ammo);
            }
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
         var _d:Object = param1.data;
         var _val:int = _d is int ? int(_d) : (_d.value || 0);
         var _crit:Boolean = _d is int ? false : (_d.isCrit || false);
         this._tipsLayer.addTips(_val,_loc2_,_crit);
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
         var _loc3_:Boolean = false;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:String = null;
         var _loc11_:Object = null;
         var _deadSoldier:AbstractSoldier = param1.target as AbstractSoldier;
         // 装备掉落地面特效
         if(_deadSoldier != null && _deadSoldier.armyInfo != null)
         {
            var _dropCode2:String = _deadSoldier.armyInfo.dropEquipCode;
            if(_dropCode2 != null && _dropCode2 != "" && _dropCode2 != "0")
            {
               EquipDropFX.show(this, _deadSoldier.x, _deadSoldier.y, _dropCode2);
            }
         }
         this.removeSoldier(_deadSoldier);
         if(this._isOver != true)
         {
            if(ChatManager.getInstance().leitaiMode == true)
            {
               _loc3_ = ChatManager.getInstance().leizhu;
               _loc4_ = {};
               if(this._leftSoldiers.length == 0)
               {
                  this.clear();
                  this._isOver = true;
                  if(this._direct == 1)
                  {
                     _loc2_ = "lost";
                     _loc5_ = String(this._rightInfo.name);
                  }
                  else
                  {
                     _loc2_ = "win";
                     _loc5_ = String(this._leftInfo.name);
                  }
               }
               else if(this._rightSoldiers.length == 0)
               {
                  this.clear();
                  this._isOver = true;
                  if(this._direct == 1)
                  {
                     _loc2_ = "win";
                     _loc5_ = String(this._rightInfo.name);
                  }
                  else
                  {
                     _loc2_ = "lost";
                     _loc5_ = String(this._leftInfo.name);
                  }
               }
               if(this._isOver == true && _loc3_ == false)
               {
                  _loc4_.head = Head.LEITAI_RESULT_FROM_SERVER;
                  _loc4_.leizhu = !_loc3_;
                  _loc4_.flag = _loc2_ == "win" ? "lost" : "win";
                  _loc4_.relativeName = RoleModel.getInstance().roleName;
                  ChatManager.getInstance().p2pSend(_loc4_);
                  _loc6_ = {
                     "leizhu":_loc3_,
                     "flag":_loc2_,
                     "relativeName":_loc5_
                  };
                  GlobalTimer.getInstance().addListener("leitaiFightResult",3,this.leitaiFightResult,1,_loc6_);
               }
               else if(this._isOver == true)
               {
                  // 守方也派发本地结果，但不发送 p2pSend（避免重复消息）
                  _loc6_ = {
                     "leizhu":_loc3_,
                     "flag":_loc2_,
                     "relativeName":_loc5_
                  };
                  GlobalTimer.getInstance().addListener("leitaiFightResult",3,this.leitaiFightResult,1,_loc6_);
               }
            }
            else
            {
               _loc11_ = {};
               if(this._leftSoldiers.length == 0)
               {
                  this.clear();
                  this._isOver = true;
                  if(this._direct == 1)
                  {
                     _loc7_ = "lost";
                     _loc8_ = this.getRightLevelAverage();
                     _loc9_ = this.getLeftLevelAverage();
                     _loc10_ = String(this._rightInfo.name);
                  }
                  else
                  {
                     _loc7_ = "win";
                     _loc8_ = this.getLeftLevelAverage();
                     _loc9_ = this.getRightLevelAverage();
                     _loc10_ = String(this._leftInfo.name);
                  }
                  if(ChatManager.getInstance().server == true)
                  {
                     _loc11_.head = Head.RESULT_FROM_SERVER;
                     _loc11_.flag = _loc7_ == "win" ? "lost" : "win";
                     _loc11_.m = _loc9_;
                     _loc11_.n = _loc8_;
                     _loc11_.relativeName = RoleModel.getInstance().roleName;
                     ChatManager.getInstance().p2pSend(_loc11_);
                     dispatchEvent(new FightEvent(FightEvent.P2P_FIGHT_COMPLETE,true,{
                        "flag":_loc7_,
                        "m":_loc8_,
                        "n":_loc9_,
                        "relativeName":_loc10_
                     }));
                  }
               }
               else if(this._rightSoldiers.length == 0)
               {
                  this.clear();
                  this._isOver = true;
                  if(this._direct == 1)
                  {
                     _loc7_ = "win";
                     _loc8_ = this.getRightLevelAverage();
                     _loc9_ = this.getLeftLevelAverage();
                     _loc10_ = String(this._rightInfo.name);
                  }
                  else
                  {
                     _loc7_ = "lost";
                     _loc8_ = this.getLeftLevelAverage();
                     _loc9_ = this.getRightLevelAverage();
                     _loc10_ = String(this._leftInfo.name);
                  }
                  if(ChatManager.getInstance().server == true)
                  {
                     _loc11_.head = Head.RESULT_FROM_SERVER;
                     _loc11_.flag = _loc7_ == "win" ? "lost" : "win";
                     _loc11_.m = _loc9_;
                     _loc11_.n = _loc8_;
                     _loc11_.relativeName = RoleModel.getInstance().roleName;
                     ChatManager.getInstance().p2pSend(_loc11_);
                     dispatchEvent(new FightEvent(FightEvent.P2P_FIGHT_COMPLETE,true,{
                        "flag":_loc7_,
                        "m":_loc8_,
                        "n":_loc9_,
                        "relativeName":_loc10_
                     }));
                  }
               }
            }
         }
      }
      
      private function leitaiFightResult(param1:Object) : *
      {
         trace("计时器触发战斗结果");
         dispatchEvent(new FightEvent(FightEvent.LEITAI_FIGHT_COMPLETE,true,param1));
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
         var _loc1_:int = 0;
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
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._rightArmy.length)
         {
            _loc1_ += this._rightArmy[_loc2_].level;
            _loc2_++;
         }
         return _loc1_;
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
               if(ChatManager.getInstance().leitaiMode == true)
               {
                  dispatchEvent(new UIEvent(UIEvent.SPEED_CHECKOUT,true,{"flag":"leitai"}));
               }
               else
               {
                  dispatchEvent(new UIEvent(UIEvent.SPEED_CHECKOUT,true,{"flag":"p2pfight"}));
               }
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
         if(this._autoAI != null)
         {
            this._autoAI.stopAI();
            this._autoAI = null;
         }
         this._yuanchengCon.stopBar();
         this._yuanchengCon.visible = false;
         this._miaozhunjing.visible = false;
      }
      
      private function getSoldier(param1:String, param2:int) : AbstractSoldier
      {
         var _loc3_:Array = null;
         if(param2 == 1)
         {
            _loc3_ = this._leftSoldiers;
         }
         else
         {
            _loc3_ = this._rightSoldiers;
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_].code == param1)
            {
               return _loc3_[_loc4_] as AbstractSoldier;
            }
            _loc4_++;
         }
         return null;
      }
      
      private function onP2PActionHandler(param1:SoldierEvent) : *
      {
         param1.stopImmediatePropagation();
         var _loc2_:int = ChatManager.getInstance().server == true ? Head.ACTION_FROM_SERVER : Head.ACTION_FROM_CLIENT;
         var _loc3_:Object = param1.data;
         _loc3_.head = _loc2_;
         ChatManager.getInstance().p2pSend(_loc3_);
      }
      
      public function p2pAction(param1:Object) : *
      {
         switch(param1.act)
         {
            case "stand":
               this.p2pStand(param1);
               break;
            case "fire":
               this.p2pFire(param1);
               break;
            case "goLeft":
               this.p2pGoLeft(param1);
               break;
            case "goRight":
               this.p2pGoRight(param1);
               break;
            case "baoji":
               this.p2pBaoji(param1);
         }
      }
      
      private function p2pStand(param1:Object) : void
      {
         var _loc2_:AbstractSoldier = this.getSoldier(param1.code,param1.direct);
         if(_loc2_ != null && _loc2_.isDead == false)
         {
            _loc2_.stand();
            _loc2_.x = Number(param1.posX);
            _loc2_.y = Number(param1.posY);
         }
      }
      
      private function p2pBaoji(param1:Object) : void
      {
         var _loc2_:AbstractSoldier = null;
         var _loc3_:AbstractSoldier = this.getSoldier(param1.code,param1.direct);
         if(_loc3_ != null && _loc3_.isDead == false)
         {
            if(param1.obj is String)
            {
               _loc2_ = this.getSoldier(param1.obj,-param1.direct);
               _loc3_.stand();
               _loc3_.x = Number(param1.posX);
               _loc3_.y = Number(param1.posY);
               _loc3_.baojiAttack({"target":_loc2_});
            }
         }
      }
      
      private function p2pFire(param1:Object) : void
      {
         var _loc2_:AbstractSoldier = null;
         var _loc3_:AbstractSoldier = this.getSoldier(param1.code,param1.direct);
         if(_loc3_ != null && _loc3_.isDead == false)
         {
            if(param1.obj == null)
            {
               _loc3_.stand();
               _loc3_.x = Number(param1.posX);
               _loc3_.y = Number(param1.posY);
               _loc3_.fire();
            }
            else if(param1.obj is String)
            {
               _loc2_ = this.getSoldier(param1.obj,-param1.direct);
               _loc3_.stand();
               _loc3_.x = Number(param1.posX);
               _loc3_.y = Number(param1.posY);
               _loc3_.fire({
                  "target":_loc2_,
                  "p2p":true
               });
            }
            else
            {
               _loc3_.fire(param1.obj);
            }
         }
      }
      
      private function p2pGoLeft(param1:Object) : void
      {
         var _loc2_:AbstractSoldier = this.getSoldier(param1.code,param1.direct);
         if(_loc2_ != null && _loc2_.isDead == false)
         {
            _loc2_.stand();
            _loc2_.x = Number(param1.posX);
            _loc2_.y = Number(param1.posY);
            _loc2_.goLeft(param1.obj);
         }
      }
      
      private function p2pGoRight(param1:Object) : void
      {
         var _loc2_:AbstractSoldier = this.getSoldier(param1.code,param1.direct);
         if(_loc2_ != null && _loc2_.isDead == false)
         {
            _loc2_.stand();
            _loc2_.x = Number(param1.posX);
            _loc2_.y = Number(param1.posY);
            _loc2_.goRight(param1.obj);
         }
      }
      
      public function p2pHurt(param1:Object) : *
      {
         var _loc2_:AbstractSoldier = null;
         var _loc3_:AbstractSoldier = this.getSoldier(param1.code,param1.direct);
         if(param1.soldierCode != null)
         {
            _loc2_ = this.getSoldier(param1.soldierCode,-param1.direct);
         }
         if(_loc3_ != null)
         {
            _loc3_.hurt(param1.hurt,_loc2_);
         }
      }
      
      public function p2pShanbi(param1:Object) : *
      {
         var _loc2_:AbstractSoldier = this.getSoldier(param1.code,param1.direct);
         if(_loc2_ != null && _loc2_.isDead == false)
         {
            _loc2_.dispatchEvent(new SoldierEvent(SoldierEvent.SHANBI,true));
         }
      }
      
      public function get ammo() : String
      {
         return this._ammo;
      }
      
      public function setAmmoTips(param1:AbstractSoldier) : *
      {
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
      
      public function get relativeName() : String
      {
         if(this._direct == 1)
         {
            return this._rightInfo.name;
         }
         return this._leftInfo.name;
      }
      
      public function get isOver() : Boolean
      {
         return this._isOver;
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
      // 边缘检测防止持续触发setSelect
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
