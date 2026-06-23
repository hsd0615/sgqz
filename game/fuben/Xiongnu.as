package game.fuben
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Elastic;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Mouse;
   import flash.utils.Timer;
   import game.Config;
   import game.Data;
   import game.ai.IAI;
   import game.ai.SmartAttack;
   import game.ai.XiongnuAI;
   import game.display.AbstractSoldier;
   import game.display.Boss;
   import game.display.Gunner;
   import game.display.IWorld;
   import game.display.JiantaSoldier;
   import game.display.JiantaWeapon;
   import game.display.Junzhu;
   import game.display.QianggongSoldier;
   import game.display.QianggongWeapon;
   import game.display.Saber;
   import game.display.Shooter;
   import game.display.StoneWeapon;
   import game.display.WandaoSoldier;
   import game.display.FrameSoldier;
   import game.display.Weapon;
   import game.events.ConEvent;
   import game.events.FightEvent;
   import game.events.SoldierEvent;
   import game.events.UIEvent;
   import game.events.WeaponEvent;
   import game.model.ArmyInfo;
   import game.model.RoleModel;
   import game.model.Type;
   import game.ui.AngleController;
   import game.ui.ConType;
   import game.ui.FightUI;
   import game.ui.NumTips;
   import game.ui.SkinCode;
   
   public class Xiongnu extends Sprite implements IWorld, IAI
   {
      
      private static const TS_POS:Point = new Point(50,360);
      
      private static const POS0:Point = new Point(140,335);
      
      private static const POS1:Point = new Point(180,360);
      
      private static const POS2:Point = new Point(220,385);
      
      private static const POS3:Point = new Point(180,410);
      
      private static const POS4:Point = new Point(140,435);

      private static const POS5:Point = new Point(100,460);

      private static const POS6:Point = new Point(60,485);
      
      private static const ATTACKPOS1:Point = new Point(35,-165);
      
      public static const MERIC:int = 30;
       
      
      private var _leftArmy:Vector.<ArmyInfo>;
      
      private var _rightArmy:Vector.<ArmyInfo>;
      
      private var _direct:int;
      
      private var _delay:Number = 0;
      
      private var _timer:Timer;
      
      private var _leftSoldiers:Array;
      
      private var _rightSoldiers:Array;
      
      private var _bk:DisplayObject;
      
      private var _yuanchengCon:AngleController;
      
      private var _miaozhunjing:MovieClip;
      
      private var _tipsLayer:NumTips;
      
      private var _isOver:Boolean;
      
      private var _currentSoldier:AbstractSoldier;
      
      private var _ammo:String = "";
      
      private var _title:Bitmap;
      
      private var _gridContainer:Sprite;
      
      private var _currentGrid:MovieClip;
      
      private var _auto:Boolean = false;
      
      private var _autoAI:XiongnuAI;
      
      private var _ai:XiongnuAI;
      
      private var _config:XiongnuConfig;
      
      private var _lockedEnemy:AbstractSoldier;
      
      private var _tf:TextField;
      
      private var _tfArr:Array;
      
      private var _soldierCount:int;
      
      private var _date:Number;
      
      private var _biansu:int = 0;
      
      private var _mask:MovieClip;
      
      private var _cover:MovieClip;
      
      private var _bossTalked:int;

      private var _equipNotifyText:String = "";

      private var _currentStageID:int;
      
      private var _pauseBtn:SimpleButton;
      
      private var _pause:Boolean;
      
      private var _pauseMC:BaseUI;
      
      private var _fightUI:FightUI;
      
      private var _ammoTips:MovieClip;
      
      private var _fubenID:int = 1;

      public function Xiongnu(param1:Vector.<ArmyInfo>, param2:int = 1, param3:int = 1, param4:int = 1)
      {
         super();
         this._leftArmy = param1.sort(this.compare);
         this._currentStageID = param2;
         this._direct = param3;
         this._fubenID = param4;
         this._config = new XiongnuConfig();
         if(stage != null)
         {
            this.addToStageHandler(null);
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,this.addToStageHandler);
         }
      }
      
      private function addToStageHandler(param1:Event) : *
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addToStageHandler);
         this.initView(this._currentStageID);
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
      
      private function initView(param1:int) : *
      {
         this.createBK();
         this.createMyArmy();
         this.creatGrid();
         switch(param1)
         {
            case 1:
               this.createEnemy1();
               break;
            case 2:
               this.createEnemy2();
               break;
            case 3:
               this.createEnemy3();
         }
         this.createGIcon();
         this.createController();
         this.createTipsLayer();
         this.createAmmoTips();
         this.createTF();
         this.createPauseBtn();
         this.setKilled(0);
         // 检查敌方是否携带高品质装备(橙色及以上)
         this.checkEquipNotify();
         // 倭寇副本第2关跳过过场动画，直接开战
         if(param1 == 2 && this._fubenID == StageID.DANG_PING_WO_KOU)
         {
            this.skipIntro();
         }
         else
         {
            this.showCover();
         }
      }
      
      private function showCover() : *
      {
         try {
            var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(SkinCode.XIONGNU_COVER + this._currentStageID) as Class;
            this._cover = new _loc1_() as MovieClip;
            this._cover.addEventListener(MouseEvent.CLICK,this.onCoverClickHandler);
            addChild(this._cover);
            TweenLite.from(this._cover,1,{"alpha":0});
         } catch(_e:Error) {
            // 封面类不存在时直接跳过
            this.showJuqing();
         }
      }
      
      private function onCoverClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:Class = null;
         this._cover.removeEventListener(MouseEvent.CLICK,this.onCoverClickHandler);
         _loc2_ = ApplicationDomain.currentDomain.getDefinition(SkinCode.FUBEN_MASK) as Class;
         this._mask = new _loc2_() as MovieClip;
         addChild(this._mask);
         TweenLite.to(this._cover,1,{
            "alpha":0,
            "onComplete":this.showJuqing
         });
      }
      
      private function showJuqing() : *
      {
         removeChild(this._cover);
         this._cover = null;
         switch(this._currentStageID)
         {
            case 1:
               this.showJuqing1();
               break;
            case 2:
               this.showJuqing2();
               break;
            case 3:
               this.showJuqing3();
         }
      }
      
      private function removeView() : *
      {
      }
      
      private function createBK() : *
      {
         if(this._currentStageID == 2 && this._fubenID == StageID.DANG_PING_WO_KOU)
         {
            // 倭寇海战背景 — 程序化绘制（仅倭寇副本第2关）
            this._bk = new Sprite();
            var _g:Graphics = (this._bk as Sprite).graphics;
            var _w:Number = stage.stageWidth;
            var _h:Number = stage.stageHeight;
            // 天空 — 黄昏血色（提亮）
            _g.beginFill(0x2a1a0a); _g.drawRect(0,0,_w,_h); _g.endFill();
            var _skyColors:Array = [0x6a2a10, 0x5a1a08, 0x4a1004, 0x3a0a02];
            for(var _si:int=0;_si<4;_si++){
               _g.beginFill(_skyColors[_si],0.4);
               _g.drawRect(0,_si*60,_w,60); _g.endFill();
            }
            // 海面
            _g.beginFill(0x1a3040,0.75);
            _g.drawRect(0,_h*0.55,_w,_h*0.45); _g.endFill();
            // 波浪纹理
            _g.lineStyle(1,0x2a4a6a,0.25);
            for(var _wi:int=0;_wi<15;_wi++){
               var _wy:Number=_h*0.55+20+_wi*18;
               _g.moveTo(0,_wy); _g.curveTo(_w*0.25,_wy-8,_w*0.5,_wy);
               _g.curveTo(_w*0.75,_wy+8,_w,_wy);
            }
            // 左侧倭船剪影
            _g.beginFill(0x0d0804,0.9);
            _g.moveTo(60,_h*0.45); _g.lineTo(120,_h*0.45);
            _g.lineTo(130,_h*0.38); _g.lineTo(50,_h*0.38); _g.lineTo(40,_h*0.42);
            // 船帆
            _g.beginFill(0x1a1008,0.7);
            _g.moveTo(80,_h*0.42); _g.lineTo(100,_h*0.42);
            _g.lineTo(95,_h*0.20); _g.lineTo(85,_h*0.20);
            // 右侧倭船剪影
            _g.beginFill(0x0d0804,0.9);
            _g.moveTo(_w-60,_h*0.48); _g.lineTo(_w-120,_h*0.48);
            _g.lineTo(_w-130,_h*0.41); _g.lineTo(_w-50,_h*0.41); _g.lineTo(_w-40,_h*0.45);
            _g.beginFill(0x1a1008,0.7);
            _g.moveTo(_w-80,_h*0.45); _g.lineTo(_w-100,_h*0.45);
            _g.lineTo(_w-95,_h*0.23); _g.lineTo(_w-85,_h*0.23);
            // 远处山峰/岛屿
            _g.beginFill(0x080604,0.6);
            _g.moveTo(0,_h*0.55); _g.lineTo(40,_h*0.42); _g.lineTo(90,_h*0.50);
            _g.lineTo(150,_h*0.44); _g.lineTo(200,_h*0.52); _g.lineTo(250,_h*0.48);
            _g.lineTo(310,_h*0.55); _g.lineTo(350,_h*0.50); _g.lineTo(380,_h*0.55);
            _g.lineTo(_w,_h*0.55); _g.lineTo(_w,_h*0.60); _g.lineTo(0,_h*0.60);
            // 战火烟雾
            _g.beginFill(0x3a2a1a,0.15);
            _g.drawCircle(_w*0.3,_h*0.3,40);
            _g.drawCircle(_w*0.35,_h*0.25,30);
            _g.drawCircle(_w*0.7,_h*0.35,35);
            _g.drawCircle(_w*0.65,_h*0.28,25);
            // 太阳 — 暗红日丸
            _g.beginFill(0x8b2000,0.4);
            _g.drawCircle(_w*0.5,_h*0.25,35);
            _g.beginFill(0x8b3000,0.2);
            _g.drawCircle(_w*0.5,_h*0.25,25);
            addChild(this._bk);
         }
         else
         {
            var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(SkinCode.FUBEN_STAGE1) as Class;
            this._bk = new _loc1_() as MovieClip;
            this._bk.x = stage.stageWidth / 2;
            this._bk.y = stage.stageHeight / 2;
            addChild(this._bk);
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
      
      private function creatGrid() : *
      {
         var _loc1_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc4_:Bitmap = null;
         _loc1_ = 0;
         _loc2_ = null;
         var _loc3_:Class = null;
         _loc4_ = null;
         var _loc5_:Boolean = false;
         this._gridContainer = new Sprite();
         this._gridContainer.graphics.beginFill(0,0.4);
         this._gridContainer.graphics.drawRoundRect(0,0,290,38,4,4);
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
            _loc2_.x = 2 + (_loc1_ - 1) * (_loc2_.width + 2);
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
         var _loc2_:String = null;
         param1.stopImmediatePropagation();
         trace(param1.target);
         if(!(param1.target is MovieClip))
         {
            return;
         }
         if(this._currentGrid == param1.target)
         {
            this._currentGrid.sanjiao.visible = false;
            this._currentGrid = null;
            this._ammo = "";
         }
         else
         {
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
            _loc2_ = String(param1.target.code);
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
      
      private function createTF() : *
      {
         if(this._currentStageID == 1)
         {
            this._tf = new TextField();
            this._tf.width = 127;
            this._tf.height = 38;
            this._tf.x = 640;
            this._tf.y = 5;
            this._tf.selectable = false;
            this._tf.multiline = true;
            this._tf.wordWrap = true;
            this._tf.textColor = 16777215;
            this._tf.filters = [new GlowFilter(0,1,2,2,50)];
            addChild(this._tf);
         }
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
      
      private function createPauseBtn() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(SkinCode.PAUSE_BTN) as Class;
         this._pauseBtn = new _loc1_() as SimpleButton;
         this._pauseBtn.x = 600;
         this._pauseBtn.y = 20;
         addChild(this._pauseBtn);
         this._pauseBtn.visible = false;
      }
      
      private function createTitle() : *
      {
         if(this._title != null)
         {
            removeChild(this._title);
            this._title = null;
         }
         if(this._currentStageID == 2 && this._fubenID == StageID.DANG_PING_WO_KOU)
         {
            // 倭寇标题：程序化绘制（仅倭寇副本）
            var _titleSp:Sprite = new Sprite();
            var _tf:TextField = new TextField();
            _tf.defaultTextFormat = new TextFormat("SimHei",26,0xFFD700,true);
            _tf.text = "荡 平 倭 寇";
            _tf.selectable = false; _tf.mouseEnabled = false;
            _tf.width = 300; _tf.height = 40;
            _tf.x = (stage.stageWidth - _tf.width) / 2;
            _tf.y = 30;
            _titleSp.addChild(_tf);
            // 副标题
            var _tf2:TextField = new TextField();
            _tf2.defaultTextFormat = new TextFormat("SimSun",12,0xC8A84E);
            _tf2.text = "— 犯我疆土者，虽远必诛 —";
            _tf2.selectable = false; _tf2.mouseEnabled = false;
            _tf2.width = 300; _tf2.height = 20;
            _tf2.x = (stage.stageWidth - _tf2.width) / 2;
            _tf2.y = 72;
            _titleSp.addChild(_tf2);
            this._title = new Bitmap(new BitmapData(1,1,false,0));
            addChild(_titleSp);
         }
         else
         {
            var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition("title_fuben_1" + this._currentStageID) as Class;
            this._title = new Bitmap(new _loc1_() as BitmapData);
            addChild(this._title);
            this._title.x = (stage.stageWidth - this._title.width) / 2;
            this._title.y = 50;
         }
      }
      
      private function createMyArmy() : *
      {
         var _loc1_:int = 0;
         var _loc2_:AbstractSoldier = null;
         this._leftSoldiers = [];
         var _loc3_:int = int(this._leftArmy.length);
         var _loc4_:int = 0;
         var _offset:int = (this._currentStageID == 2) ? 0 : 300;
         while(_loc4_ < _loc3_)
         {
            try {
               _loc2_ = this.armyFactory(this._leftArmy[_loc4_],1,this._direct == 1 ? true : false);
            } catch(_e:Error) {
               // 若特定兵种创建失败(如皮肤缺失),回退为Shooter
               _loc2_ = new Shooter(this._leftArmy[_loc4_].clone(),1,this._direct == 1 ? true : false,this);
            }
            if(_loc2_.type == Type.TOUSHICHE)
            {
               _loc2_.x = Xiongnu.TS_POS.x - _offset;
               _loc2_.y = Xiongnu.TS_POS.y;
            }
            else
            {
               _loc2_.x = Xiongnu["POS" + _loc1_].x - _offset;
               _loc2_.y = Xiongnu["POS" + _loc1_].y;
               _loc1_++;
            }
            addChild(_loc2_);
            this._leftSoldiers.push(_loc2_);
            _loc4_++;
         }
      }
      
      private function armyFactory(param1:ArmyInfo, param2:int, param3:Boolean) : AbstractSoldier
      {
         try {
            switch(param1.type)
            {
               case Type.TOUSHICHE:
                  return new Gunner(param1.clone(),param2,param3,this);
               case Type.QIBING:
                  return new Saber(param1.clone(),param2,param3,this);
               case Type.JIANTABING:
                  return new JiantaSoldier(param1.clone(),param2,param3);
               case Type.QIANGGONGBING:
                  return new QianggongSoldier(param1.clone(),param2,param3);
               case Type.WANDAOBING:
                  return new WandaoSoldier(param1.clone(),param2,param3);
               case Type.BOSS:
                  return new Boss(param1.clone(),param2,param3);
               case Type.JUNZHU:
                  return new Junzhu(param1.clone(),param2,param3,this);
               case 14:
               case 15:
               case 16:
               case 17:
                  return new Saber(param1.clone(),param2,param3,this);
               default:
                  return new Shooter(param1.clone(),param2,param3,this);
            }
         } catch(_e:Error) {
            param1.type = Type.GONGBING;
            return new Shooter(param1.clone(),param2,param3,this);
         }
         return new Shooter(param1.clone(),param2,param3,this);
      }
      
      private function createEnemy1() : *
      {
         var _loc4_:AbstractSoldier = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _loc4_ = null;
         var _loc5_:int = 0;
         this.createTitle();
         this._rightArmy = new Vector.<ArmyInfo>();
         this._rightArmy.push(this._config.getJiantaData());
         this._rightArmy.push(this._config.getJiantaData());
         _loc3_ = 0;
         while(_loc3_ < this._leftArmy.length)
         {
            _loc1_ += this._leftArmy[_loc3_].hp;
            _loc2_ += this._leftArmy[_loc3_].defense;
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < 20)
         {
            this._rightArmy.push(this._config.getWandaoData(_loc1_,_loc2_,this._leftArmy.length));
            _loc3_++;
         }
         this._rightSoldiers = [];
         (_loc4_ = this.armyFactory(this._rightArmy[0],-1,false)).x = 700;
         _loc4_.y = 335;
         _loc4_.armyInfo.hp = this._rightArmy[0].hp;
         addChildAt(_loc4_,getChildIndex(this._leftSoldiers[0]));
         this._rightSoldiers.push(_loc4_);
         (_loc4_ = this.armyFactory(this._rightArmy[1],-1,false)).x = 640;
         _loc4_.y = 440;
         _loc4_.armyInfo.hp = this._rightArmy[1].hp;
         addChildAt(_loc4_,getChildIndex(this._gridContainer));
         this._rightSoldiers.push(_loc4_);
         var _loc6_:AbstractSoldier;
         (_loc6_ = this.armyFactory(this._rightArmy[2],-1,false)).x = stage.stageWidth + 130;
         _loc6_.y = Xiongnu.POS1.y;
         _loc6_.armyInfo.hp = this._rightArmy[2].hp;
         addChildAt(_loc6_,getChildIndex(_loc4_));
         this._rightSoldiers.push(_loc6_);
         var _loc7_:AbstractSoldier;
         (_loc7_ = this.armyFactory(this._rightArmy[3],-1,false)).x = stage.stageWidth + 100;
         _loc7_.y = Xiongnu.POS2.y;
         _loc7_.armyInfo.hp = this._rightArmy[3].hp;
         addChildAt(_loc7_,getChildIndex(_loc4_));
         this._rightSoldiers.push(_loc7_);
         var _loc8_:AbstractSoldier;
         (_loc8_ = this.armyFactory(this._rightArmy[4],-1,false)).x = stage.stageWidth + 150;
         _loc8_.y = Xiongnu.POS3.y;
         _loc8_.armyInfo.hp = this._rightArmy[4].hp;
         addChildAt(_loc8_,getChildIndex(_loc4_));
         this._rightSoldiers.push(_loc8_);
         _loc3_ = 0;
         while(_loc3_ < this._rightArmy.length - 2 - 3)
         {
            _loc4_ = this.armyFactory(this._rightArmy[_loc3_ + 5],-1,false);
            _loc4_.armyInfo.hp = this._rightArmy[_loc3_ + 5].hp;
            if((_loc5_ = _loc3_ % 3 + 2) == 2)
            {
               _loc4_.x = _loc6_.x;
               _loc4_.y = _loc6_.y;
               addChildAt(_loc4_,getChildIndex(_loc6_));
            }
            else if(_loc5_ == 3)
            {
               _loc4_.x = _loc7_.x;
               _loc4_.y = _loc7_.y;
               addChildAt(_loc4_,getChildIndex(_loc7_));
            }
            else
            {
               _loc4_.x = _loc8_.x;
               _loc4_.y = _loc8_.y;
               addChildAt(_loc4_,getChildIndex(_loc8_));
            }
            this._rightSoldiers.push(_loc4_);
            _loc3_++;
         }
      }
      
      private function createEnemy2() : *
      {
         var _loc1_:int = 0;
         var _loc2_:AbstractSoldier = null;
         this.createTitle();
         this._rightArmy = new Vector.<ArmyInfo>();
         var _loc3_:int = 0;
         // 复制己方将领作为敌方镜像 (一对一复制)
         _loc3_ = 0;
         while(_loc3_ < this._leftArmy.length)
         {
            var _playerGen:ArmyInfo = this._leftArmy[_loc3_];
            var _enemyCode:String = _playerGen.code;
            var _enemyLevel:int = _playerGen.level;
            if(_enemyLevel < 1) _enemyLevel = 1;
            var _enemyAI:Object = Data.getInstance().getFubenAIDelay(this._fubenID, _enemyCode);
            var _enemy:ArmyInfo = Data.getInstance().getArmyInfo(_enemyCode, _enemyLevel, 0, 0, _playerGen.name, int(_enemyAI.delay), int(_enemyAI.ai));
            _enemy.isEnemy = true;
            _enemy.baseDefense = _playerGen.defense;
            _enemy.baseAttack = _playerGen.attack;
            _enemy.hp = _playerGen.hp;
            _enemy.forceHp = true;
            _enemy.attackDistance = _playerGen.attackDistance;
            this._rightArmy[_loc3_] = _enemy;
            _loc3_++;
         }
         this._rightSoldiers = [];
         var _loc4_:int = int(this._rightArmy.length);
         var _loc5_:int = int(this._leftArmy.length);
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc2_ = this.armyFactory(this._rightArmy[_loc3_],-1,this._direct == -1 ? true : false);
            _loc2_.armyInfo.hp = this._rightArmy[_loc3_].hp;
            if(_loc2_.type == Type.TOUSHICHE)
            {
               _loc2_.x = 770 - Xiongnu.TS_POS.x;
               _loc2_.y = Xiongnu.TS_POS.y;
            }
            else
            {
               _loc2_.x = 770 - Xiongnu["POS" + _loc1_].x;
               _loc2_.y = Xiongnu["POS" + _loc1_].y;
               _loc1_++;
            }
            if(_loc3_ < _loc5_)
            {
               addChildAt(_loc2_,getChildIndex(this._leftSoldiers[_loc3_] as AbstractSoldier));
            }
            else
            {
               addChild(_loc2_);
            }
            this._rightSoldiers.push(_loc2_);
            _loc3_++;
         }
      }
      
      private function createEnemy3() : *
      {
         this.createTitle();
         this._rightArmy = new Vector.<ArmyInfo>();
         this._rightSoldiers = [];
         this._rightArmy.push(this._config.getBossData(this._leftArmy));
         this._rightArmy[0].forceHp = true;
         var _loc1_:AbstractSoldier = this.armyFactory(this._rightArmy[0],-1,false);
         // Fix: AbstractSoldier构造函数会将hp重置为maxHp，boss需要恢复自定义HP
         var _totalPlayerHP:int = 0;
         var _pi:int = 0;
         while(_pi < this._leftArmy.length) {
            _totalPlayerHP += this._leftArmy[_pi].hp;
            _pi++;
         }
         this._rightArmy[0].hp = _totalPlayerHP * 12;
         _loc1_.armyInfo.hp = this._rightArmy[0].hp;
         this._rightSoldiers.push(_loc1_);
         _loc1_.x = 550;
         _loc1_.y = Xiongnu.POS2.y;
         addChild(_loc1_);
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
         this.initUnInteractiveEvent();
      }
      
      private function initUnInteractiveEvent() : *
      {
         this._pauseBtn.addEventListener(MouseEvent.CLICK,this.onPauseBtnClickHandler);
         addEventListener(SoldierEvent.ZHAOHUAN,this.onSoldierZhaohuanHandler);
         addEventListener(SoldierEvent.FILL_COMPLETE,this.onSoldierFillCompleteHandler);
         addEventListener(SoldierEvent.FIRE_COMPLETE,this.onSoldierFireCompleteHandler);
         addEventListener(SoldierEvent.BEHURT,this.onSoldierBehurtHandler);
         addEventListener(SoldierEvent.SHANBI,this.onSoldierShanbiHandler);
         addEventListener(SoldierEvent.HUIFU,this.onSoldierHuifuHandler);
         addEventListener(SoldierEvent.DEAD,this.onSoldierDeadHandler);
         addEventListener(SoldierEvent.DEAD_COMPLETE,this.onSoldierDeadCompleteHandler);
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
         this.setCurrentSoldier(this.selectSoldier(param1.data.id,param1.data.code));
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
      
      private function smartAttackHandler(param1:SoldierEvent) : *
      {
         this.onMouseClickHandler(null);
         SmartAttack.makeAI(param1.target as AbstractSoldier,this);
      }
      
      private function onMouseClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         trace("Fight 单击事件");
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
      
      private function createMiaozhunjingHandler(param1:ConEvent) : void
      {
         this._miaozhunjing.addEventListener(Event.ENTER_FRAME,this.onMiaozhunjingEnterFrameHandler);
         addEventListener(SoldierEvent.ENEMY_LOCKED,this.enemyLockHandler);
         addEventListener(SoldierEvent.ENEMY_UNLOCKED,this.enemyUnlockHandler);
         this._miaozhunjing.visible = true;
         Mouse.prototype.isHide = true;
         Mouse.hide();
      }
      
      private function enemyLockHandler(param1:SoldierEvent) : *
      {
         this._lockedEnemy = param1.target as AbstractSoldier;
      }
      
      private function enemyUnlockHandler(param1:SoldierEvent) : *
      {
         this._lockedEnemy = null;
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
      
      private function onSoldierZhaohuanHandler(param1:SoldierEvent) : *
      {
         (param1.target as AbstractSoldier).talk({
            "text":"小的们，给我上！",
            "delay":2000
         });
         this.zhaohuanQianggong(int(param1.data.count));
      }
      
      private function zhaohuanQianggong(param1:int) : *
      {
         var _loc3_:AbstractSoldier = null;
         var _loc2_:AbstractSoldier = null;
         _loc3_ = null;
         var _loc4_:AbstractSoldier = null;
         var _loc5_:AbstractSoldier = null;
         var _loc6_:ArmyInfo = this._config.getQianggongData(this._leftArmy);
         if(this._rightSoldiers.length != 0)
         {
            _loc2_ = this._rightSoldiers[0];
            _loc3_ = this.armyFactory(_loc6_,-1,false);
            _loc3_.x = 670 + 130;
            _loc3_.y = Xiongnu.POS1.y;
            addChildAt(_loc3_,getChildIndex(_loc2_));
            this._rightSoldiers.push(_loc3_);
            this._ai.qianggongArr.push(_loc3_);
            _loc3_.goLeft(130);
            (_loc4_ = this.armyFactory(_loc6_,-1,false)).x = 630 + 130;
            _loc4_.y = Xiongnu.POS2.y;
            addChildAt(_loc4_,getChildIndex(_loc3_) + 2);
            this._rightSoldiers.push(_loc4_);
            this._ai.qianggongArr.push(_loc4_);
            _loc4_.goLeft(130);
            (_loc5_ = this.armyFactory(_loc6_,-1,false)).x = 700 + 130;
            _loc5_.y = Xiongnu.POS3.y;
            addChildAt(_loc5_,getChildIndex(_loc4_) + 1);
            this._rightSoldiers.push(_loc5_);
            this._ai.qianggongArr.push(_loc5_);
            _loc5_.goLeft(130);
         }
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
         var _loc3_:AbstractSoldier = null;
         var _loc4_:StoneWeapon = null;
         var _loc5_:Point = null;
         var _loc6_:JiantaWeapon = null;
         var _loc7_:Point = null;
         var _loc8_:QianggongWeapon = null;
         var _loc9_:Point = null;
         var _loc10_:Weapon = null;
         var _loc11_:Point = null;
         var _loc12_:int = 0;
         var _loc13_:AbstractSoldier = null;
         var _loc14_:Class = null;
         var _loc15_:MovieClip = null;
         var _loc16_:Weapon = null;
         var _loc17_:Point = null;
         param1.stopPropagation();
         _loc2_ = param1.target as AbstractSoldier;
         switch(_loc2_.type)
         {
            case Type.TOUSHICHE:
               if(_loc2_.isPlayer == true)
               {
                  trace("攻击弹药",this._ammo);
                  _loc4_ = new StoneWeapon(_loc2_,param1.data.angle,param1.data.power,this._ammo,385);
               }
               else
               {
                  _loc4_ = new StoneWeapon(_loc2_,param1.data.angle,param1.data.power,_loc2_.feature > 0 ? "proto_2_" + (_loc2_.feature + 4) : "proto_2_3",385);
               }
               _loc5_ = _loc2_.getHurPoint(this);
               trace("起始坐标:",_loc5_);
               _loc4_.x = _loc5_.x;
               _loc4_.y = _loc5_.y;
               addChildAt(_loc4_,getChildIndex(_loc2_) + 1);
               _loc4_.addEventListener(WeaponEvent.WEAPON_END,this.onStoneWeaponEndHandler);
               _loc4_.run();
               break;
            case Type.QIBING:
               if(_loc2_.direct == 1)
               {
                  _loc3_ = this.findSoldier(-1);
               }
               else
               {
                  _loc3_ = this.findSoldier(1);
               }
               if(_loc3_ != null)
               {
                  if(Tools.getJilv(_loc3_.shanbi) == true)
                  {
                     _loc3_.dispatchEvent(new SoldierEvent(SoldierEvent.SHANBI,true));
                  }
                  else
                  {
                     _loc3_.hurt(this._config.getHurtVale(_loc2_,_loc3_),_loc2_);
                  }
               }
               break;
            case Type.JIANTABING:
               _loc6_ = new JiantaWeapon(_loc2_,param1.data.target as AbstractSoldier);
               _loc7_ = _loc2_.getHurPoint(this);
               trace(_loc7_);
               _loc6_.x = _loc7_.x;
               _loc6_.y = _loc7_.y;
               _loc6_.addEventListener(WeaponEvent.WEAPON_END,this.onJiantaWeaponEndHandler);
               addChildAt(_loc6_,getChildIndex(_loc2_));
               _loc6_.run();
               break;
            case Type.QIANGGONGBING:
               _loc8_ = new QianggongWeapon(_loc2_,param1.data.target as AbstractSoldier);
               _loc9_ = _loc2_.getHurPoint(this);
               _loc8_.x = _loc9_.x;
               _loc8_.y = _loc9_.y;
               _loc8_.addEventListener(WeaponEvent.WEAPON_END,this.onQianggongWeaponEndHandler);
               addChildAt(_loc8_,getChildIndex(_loc2_));
               _loc8_.run();
               break;
            case Type.BOSS:
               if(int(param1.data.attackType) == 2)
               {
                  this.shake();
                  _loc12_ = 0;
                  while(_loc12_ < this._leftSoldiers.length)
                  {
                     _loc3_ = this._leftSoldiers[_loc12_] as AbstractSoldier;
                     if(_loc3_ != null)
                     {
                        if(Tools.getJilv(_loc3_.shanbi) == true)
                        {
                           _loc3_.dispatchEvent(new SoldierEvent(SoldierEvent.SHANBI,true));
                        }
                        else
                        {
                           _loc3_.hurt(this._config.getHurtVale(_loc2_,_loc3_,null,1),_loc2_);
                        }
                     }
                     _loc12_++;
                  }
               }
               else
               {
                  int(param1.data.attackType) == 1;
               }
               if(_loc2_.direct == 1)
               {
                  _loc3_ = this.findSoldier(-1);
               }
               else
               {
                  _loc3_ = this.findSoldier(1);
               }
               if(_loc3_ != null)
               {
                  if(Tools.getJilv(_loc3_.shanbi) == true)
                  {
                     _loc3_.dispatchEvent(new SoldierEvent(SoldierEvent.SHANBI,true));
                  }
                  else
                  {
                     _loc3_.hurt(this._config.getHurtVale(_loc2_,_loc3_,null,2),_loc2_);
                  }
               }
               break;
            case Type.JUNZHU:
               if(param1.data.type == "baoji")
               {
                  if((_loc13_ = param1.data.target as AbstractSoldier) != null)
                  {
                     (_loc15_ = new (_loc14_ = ApplicationDomain.currentDomain.getDefinition("jineng_" + _loc2_.code) as Class)() as MovieClip).addEventListener(Event.ENTER_FRAME,this.jinengEnterFrameHandler);
                     _loc15_.scaleX = 0.9 * _loc2_.direct;
                     _loc15_.scaleY = 0.9;
                     _loc15_.x = _loc13_.x;
                     _loc15_.y = _loc2_.y;
                     _loc15_.direct = _loc2_.direct;
                     addChild(_loc15_);
                  }
               }
               else
               {
                  _loc16_ = new Weapon(_loc2_,param1.data.target as AbstractSoldier);
                  _loc17_ = _loc2_.getHurPoint(this);
                  _loc16_.x = _loc17_.x;
                  _loc16_.y = _loc17_.y;
                  _loc16_.addEventListener(WeaponEvent.WEAPON_END,this.onWeaponEndHandler);
                  addChildAt(_loc16_,getChildIndex(_loc2_));
                  _loc16_.run();
               }
               break;
            default:
               _loc10_ = new Weapon(_loc2_,param1.data.target as AbstractSoldier);
               _loc11_ = _loc2_.getHurPoint(this);
               _loc10_.x = _loc11_.x;
               _loc10_.y = _loc11_.y;
               _loc10_.addEventListener(WeaponEvent.WEAPON_END,this.onWeaponEndHandler);
               addChildAt(_loc10_,getChildIndex(_loc2_));
               _loc10_.run();
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
                  _loc6_.hurt(this._config.getHurtVale(param1,_loc6_,param5));
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
      
      private function onJiantaWeaponEndHandler(param1:WeaponEvent) : *
      {
         param1.currentTarget.removeEventListener(WeaponEvent.WEAPON_END,this.onJiantaWeaponEndHandler);
         removeChild(param1.currentTarget as JiantaWeapon);
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
               _loc2_.hurt(this._config.getHurtVale(_loc3_,_loc2_));
            }
         }
      }
      
      private function onQianggongWeaponEndHandler(param1:WeaponEvent) : *
      {
         param1.currentTarget.removeEventListener(WeaponEvent.WEAPON_END,this.onQianggongWeaponEndHandler);
         removeChild(param1.currentTarget as QianggongWeapon);
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
               _loc2_.hurt(this._config.getHurtVale(_loc3_,_loc2_));
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
               _loc2_.hurt(this._config.getHurtVale(_loc3_,_loc2_),_loc3_);
            }
         }
      }
      
      private function onSoldierBehurtHandler(param1:SoldierEvent) : *
      {
         var _loc2_:Boss = null;
         if(param1.target is Boss)
         {
            _loc2_ = param1.target as Boss;
            if(_loc2_.hp < _loc2_.maxHP * 0.2 && this._bossTalked < 4)
            {
               ++this._bossTalked;
               _loc2_.talk({
                  "text":"我才减完肥，又被你们打肿了……",
                  "delay":2000
               });
            }
            else if(_loc2_.hp < _loc2_.maxHP * 0.4 && this._bossTalked < 3)
            {
               ++this._bossTalked;
               _loc2_.talk({
                  "text":"哇呀呀！打疼我了，我要发飙了！",
                  "delay":2000
               });
            }
            else if(_loc2_.hp < _loc2_.maxHP * 0.6 && this._bossTalked < 2)
            {
               ++this._bossTalked;
               _loc2_.talk({
                  "text":"打归打，别往脸上招呼啊，等下我还要去相亲呢！",
                  "delay":2000
               });
            }
            else if(_loc2_.hp < _loc2_.maxHP * 0.8 && this._bossTalked < 1)
            {
               ++this._bossTalked;
               _loc2_.talk({
                  "text":"蝼蚁们，这么点实力就敢来攻击我？",
                  "delay":2000
               });
            }
         }
         var _loc3_:Point = new Point(param1.target.x,param1.target.y - 50);
         var _loc4_:Point = _loc3_.clone();
         _loc4_.y -= 50;
         var _d2:Object = param1.data;
         var _loc5_:int = _d2 is int ? int(_d2) : (_d2.value || 0);
         var _crit2:Boolean = _d2 is int ? false : (_d2.isCrit || false);
         this._tipsLayer.addTips(_loc5_,_loc3_,_crit2);
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
         if(_loc2_.direct == this._direct)
         {
            this._fightUI.checkDead(_loc2_.armyInfo.id,_loc2_.armyInfo.code);
         }
      }
      
      private function onSoldierDeadCompleteHandler(param1:SoldierEvent) : *
      {
         var _loc2_:int = 0;
         this.removeSoldier(param1.target as AbstractSoldier);
         if(this._tf != null && param1.target is WandaoSoldier)
         {
            ++this._soldierCount;
            this.setKilled(this._soldierCount);
         }
         if(this._isOver != true)
         {
            if(param1.target is Boss)
            {
               this.clear();
               this._isOver = true;
               _loc2_ = 1;
               dispatchEvent(new FightEvent(FightEvent.XIONGNU_FIGHT_COMPLETE,true,{
                  "result":_loc2_,
                  "stageID":this._fubenID,
                  "index":this._currentStageID,
                  "level":this.getGeneralLevel()
               }));
            }
            else if(this._leftSoldiers.length == 0)
            {
               this.clear();
               this._isOver = true;
               if(this._direct == 1)
               {
                  _loc2_ = 0;
               }
               else
               {
                  _loc2_ = 1;
               }
               dispatchEvent(new FightEvent(FightEvent.XIONGNU_FIGHT_COMPLETE,true,{
                  "result":_loc2_,
                  "stageID":this._fubenID,
                  "index":this._currentStageID,
                  "level":this.getGeneralLevel()
               }));
            }
            else if(this._rightSoldiers.length == 0)
            {
               this.clear();
               this._isOver = true;
               if(this._direct == 1)
               {
                  _loc2_ = 1;
               }
               else
               {
                  _loc2_ = 0;
               }
               dispatchEvent(new FightEvent(FightEvent.XIONGNU_FIGHT_COMPLETE,true,{
                  "result":_loc2_,
                  "stageID":this._fubenID,
                  "index":this._currentStageID,
                  "level":this.getGeneralLevel()
               }));
            }
         }
      }
      
      private function getGeneralLevel() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = int(this._leftArmy.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ += this._leftArmy[_loc3_].level;
            _loc3_++;
         }
         return int(_loc1_ / _loc2_);
      }
      
      private function removeSoldier(param1:AbstractSoldier) : *
      {
         var _loc2_:int = 0;
         if(this._ai != null && param1.isPlayer == false)
         {
            this._ai.killSoldier(param1);
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
      
      public function clear() : *
      {
         if(this._timer != null)
         {
            this._timer.reset();
            this._timer.removeEventListener(TimerEvent.TIMER,this.speedCheckHandler);
            this._timer = null;
         }
         this.removeAllEvent();
         Mouse.show();
         Mouse.prototype.isHide = false;
         Mouse.prototype.canFire = false;
         if(this._ai != null)
         {
            this._ai.stopAI();
         }
         this._yuanchengCon.stopBar();
         this._yuanchengCon.visible = false;
         this._miaozhunjing.visible = false;
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
               dispatchEvent(new UIEvent(UIEvent.SPEED_CHECKOUT,true,{"flag":"xiongnu"}));
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
      
      private function removeAllEvent() : *
      {
         removeEventListener(SoldierEvent.SELECTED,this.onSoldierSelectedHandler);
         removeEventListener(SoldierEvent.ENEMY_SELECTED,this.onEnemySelectedHandler);
         removeEventListener(SoldierEvent.SMART_ATTACK,this.smartAttackHandler);
         removeEventListener(MouseEvent.CLICK,this.onMouseClickHandler);
         removeEventListener(ConEvent.CREATE_MIAOZHUNJING,this.createMiaozhunjingHandler);
         removeEventListener(ConEvent.FIRE,this.conFireHandler);
         this._pauseBtn.removeEventListener(MouseEvent.CLICK,this.onPauseBtnClickHandler);
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
      
      public function get leftSoldiers() : Array
      {
         return this._leftSoldiers;
      }
      
      public function get rightSoldiers() : Array
      {
         return this._rightSoldiers;
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
         return false;
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
      
      private function setKilled(param1:int, param2:int = 20) : *
      {
         var _loc3_:* = null;
         if(this._tf != null)
         {
            _loc3_ = this._equipNotifyText;
            _loc3_ += "已消灭<font color=\'#ffe155\'>匈奴杂兵</font> ";
            _loc3_ += param1 + " 个\n";
            _loc3_ += "剩余<font color=\'#ffe155\'>匈奴杂兵</font> ";
            _loc3_ += param2 - param1 + " 个";
            this._tf.htmlText = _loc3_;
         }
      }
      
      // 检查敌方是否携带高品质装备(橙色Q7+)，在战斗界面提示玩家
      private function checkEquipNotify() : void
      {
         if(this._rightArmy == null) return;
         var _highEquips:Array = [];
         var _ri:int = 0;
         while(_ri < this._rightArmy.length)
         {
            var _army:ArmyInfo = this._rightArmy[_ri] as ArmyInfo;
            if(_army != null)
            {
               var _eqStr:String = _army.getEquipmentStr();
               if(_eqStr != null && _eqStr != "" && _eqStr != "0,0,0,0,0,0")
               {
                  var _parts:Array = _eqStr.split(",");
                  var _pi:int = 0;
                  while(_pi < _parts.length)
                  {
                     var _code:String = _parts[_pi];
                     if(_code != "0" && _code != "" && _code != null)
                     {
                        var _q:int = int(game.model.EquipData.get(_code, "quality"));
                        if(_q >= 5)
                        {
                           var _eqName:String = game.model.EquipData.get(_code, "name") as String;
                           _highEquips.push({eqName:_eqName, quality:_q, enemyName:_army.name});
                           break;
                        }
                     }
                     _pi++;
                  }
               }
            }
            _ri++;
         }
         if(_highEquips.length > 0)
         {
            this._equipNotifyText = "<font color='#ff6600' size='14'>⚠ 稀有掉落预警</font>\n";
            var _hi:int = 0;
            while(_hi < _highEquips.length)
            {
               this._equipNotifyText += "<font color='#ff9900'>[" + _highEquips[_hi].enemyName + "] 携带 </font>";
               this._equipNotifyText += "<font color='#ff4500'><b>" + _highEquips[_hi].eqName + "</b></font> ";
               this._equipNotifyText += "<font color='#ffcc00'>(Q" + _highEquips[_hi].quality + ")</font>\n";
               _hi++;
            }
            this._equipNotifyText += "<font color='#ffffff' size='12'>击败该武将并通关即可获得！</font>\n";
         }
      }

      private function showJuqing1() : *
      {
         var _loc1_:int = 0;
         if(this._leftSoldiers.length == 0) {
            if(this._timer != null) { this._timer.stop(); this._timer = null; }
            this._timer = new Timer(500,1);
            this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.juqing1TimerHandler);
            this._timer.start();
            return;
         }
         while(_loc1_ < this._leftSoldiers.length)
         {
            if(this._leftSoldiers[_loc1_].type == Type.QIBING)
            {
               this._leftSoldiers[_loc1_].speed = 3;
            }
            else
            {
               this._leftSoldiers[_loc1_].speed = 3;
            }
            this._leftSoldiers[_loc1_].goRight(300);
            _loc1_++;
         }
         this._leftSoldiers[_loc1_ - 1].addEventListener(SoldierEvent.MOVE_COMPLETE,this.onJuqing1MyArmyMoveCompleteHandler);
      }
      
      private function onJuqing1MyArmyMoveCompleteHandler(param1:SoldierEvent) : *
      {
         param1.currentTarget.removeEventListener(SoldierEvent.MOVE_COMPLETE,this.onJuqing1MyArmyMoveCompleteHandler);
         var _loc2_:int = 0;
         while(_loc2_ < this._leftSoldiers.length)
         {
            if(this._leftSoldiers[_loc2_].type == Type.QIBING)
            {
               this._leftSoldiers[_loc2_].speed = 3;
            }
            else
            {
               this._leftSoldiers[_loc2_].speed = 1.8;
            }
            _loc2_++;
         }
         this._rightSoldiers[1].talk({
            "text":"报……报告，\n有人偷袭营寨！！！",
            "delay":3000
         });
         if(this._timer != null)
         {
            this._timer.stop();
            this._timer = null;
         }
         this._timer = new Timer(1500,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.juqing1TimerHandler);
         this._timer.start();
      }
      
      private function juqing1TimerHandler(param1:TimerEvent) : *
      {
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.juqing1TimerHandler);
         this._rightSoldiers[2].speed = 2.8;
         this._rightSoldiers[3].speed = 2.8;
         this._rightSoldiers[4].speed = 2.8;
         this._rightSoldiers[2].goLeft(350);
         this._rightSoldiers[3].goLeft(350);
         this._rightSoldiers[4].goLeft(350);
         this._rightSoldiers[3].addEventListener(SoldierEvent.MOVE_COMPLETE,this.wandaoTalk);
      }
      
      private function wandaoTalk(param1:SoldierEvent) : *
      {
         param1.currentTarget.removeEventListener(SoldierEvent.MOVE_COMPLETE,this.wandaoTalk);
         this._rightSoldiers[2].speed = 1.8;
         this._rightSoldiers[3].speed = 1.8;
         this._rightSoldiers[4].speed = 1.8;
         this._rightSoldiers[3].talk({
            "text":"大胆鼠辈，竟敢在此撒野，看爷爷捅你一万个透明窟窿。",
            "delay":2000
         });
         this._timer.reset();
         this._timer.delay = 2000;
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.juqing1OverHandler);
         this._timer.start();
      }
      
      private function juqing1OverHandler(param1:TimerEvent) : *
      {
         this._timer.reset();
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.juqing1OverHandler);
         this._mask.addEventListener(Event.COMPLETE,this.onMaskFrameCompleteHandler);
         this._mask.gotoAndPlay("removeMask");
      }
      
      private function onMaskFrameCompleteHandler(param1:Event) : *
      {
         this._mask.removeEventListener(Event.COMPLETE,this.onMaskFrameCompleteHandler);
         removeChild(this._mask);
         this._mask = null;
         this.initEvent();
         this._ai = new XiongnuAI(this,5000,-1,this._config);
         this._ai.startAI();
         if(this._timer != null)
         {
            this._timer.reset();
            this._timer = null;
         }
         this._timer = new Timer(Config.NORMAL);
         this._date = new Date().getTime();
         this._timer.addEventListener(TimerEvent.TIMER,this.speedCheckHandler);
         this._timer.start();
      }
      
      private function skipIntro() : *
      {
         this.initEvent();
         this._ai = new XiongnuAI(this,5000,-1,this._config);
         this._ai.startAI();
         if(this._timer != null)
         {
            this._timer.reset();
            this._timer = null;
         }
         this._timer = new Timer(Config.NORMAL);
         this._date = new Date().getTime();
         this._timer.addEventListener(TimerEvent.TIMER,this.speedCheckHandler);
         this._timer.start();
      }

      private function createStartAni() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(SkinCode.XIONGNU_ANI) as Class;
         var _loc2_:MovieClip = new _loc1_() as MovieClip;
         _loc2_.x = stage.stageWidth / 2;
         _loc2_.y = height / 2 - 50;
         addChild(_loc2_);
         _loc2_.addEventListener(Event.COMPLETE,this.onStartAniCompleteHandler1);
      }
      
      private function onStartAniCompleteHandler1(param1:Event) : *
      {
         param1.currentTarget.removeEventListener(Event.COMPLETE,this.onStartAniCompleteHandler1);
         removeChild(param1.currentTarget as MovieClip);
      }
      
      private function showJuqing2() : *
      {
         var _loc1_:int = 0;
         if(this._leftSoldiers.length == 0) {
            if(this._timer != null) { this._timer.stop(); this._timer = null; }
            this._timer = new Timer(500,1);
            this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.juqing2OverHandler);
            this._timer.start();
            return;
         }
         while(_loc1_ < this._leftSoldiers.length)
         {
            if(this._leftSoldiers[_loc1_].type == Type.QIBING)
            {
               this._leftSoldiers[_loc1_].speed = 3;
            }
            else
            {
               this._leftSoldiers[_loc1_].speed = 3;
            }
            this._leftSoldiers[_loc1_].goRight(300);
            _loc1_++;
         }
         this._leftSoldiers[_loc1_ - 1].addEventListener(SoldierEvent.MOVE_COMPLETE,this.onJuqing2MyArmyMoveCompleteHandler);
      }
      
      private function onJuqing2MyArmyMoveCompleteHandler(param1:SoldierEvent) : *
      {
         param1.currentTarget.removeEventListener(SoldierEvent.MOVE_COMPLETE,this.onJuqing2MyArmyMoveCompleteHandler);
         var _loc2_:int = 0;
         while(_loc2_ < this._leftSoldiers.length)
         {
            if(this._leftSoldiers[_loc2_].type == Type.QIBING)
            {
               this._leftSoldiers[_loc2_].speed = 3;
            }
            else
            {
               this._leftSoldiers[_loc2_].speed = 1.8;
            }
            _loc2_++;
         }
         var _loc3_:AbstractSoldier = Tools.randomFromArr(this._rightSoldiers);
         _loc3_.talk({
            "text":"何人胆敢擅闯我营寨？",
            "delay":3000
         });
         if(this._timer != null)
         {
            this._timer.stop();
            this._timer = null;
         }
         this._timer = new Timer(1500,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.juqing2OverHandler);
         this._timer.start();
      }
      
      private function juqing2OverHandler(param1:TimerEvent) : *
      {
         this._timer.reset();
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.juqing2OverHandler);
         this._mask.addEventListener(Event.COMPLETE,this.onMaskFrameCompleteHandler);
         this._mask.gotoAndPlay("removeMask");
      }
      
      private function showJuqing3() : *
      {
         var _loc1_:int = 0;
         if(this._leftSoldiers.length == 0) {
            if(this._timer != null) { this._timer.stop(); this._timer = null; }
            this._timer = new Timer(500,1);
            this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.juqing3OverHandler);
            this._timer.start();
            return;
         }
         while(_loc1_ < this._leftSoldiers.length)
         {
            if(this._leftSoldiers[_loc1_].type == Type.QIBING)
            {
               this._leftSoldiers[_loc1_].speed = 3;
            }
            else
            {
               this._leftSoldiers[_loc1_].speed = 3;
            }
            this._leftSoldiers[_loc1_].goRight(300);
            _loc1_++;
         }
         this._leftSoldiers[_loc1_ - 1].addEventListener(SoldierEvent.MOVE_COMPLETE,this.onJuqing3MyArmyMoveCompleteHandler);
      }
      
      private function onJuqing3MyArmyMoveCompleteHandler(param1:SoldierEvent) : *
      {
         param1.currentTarget.removeEventListener(SoldierEvent.MOVE_COMPLETE,this.onJuqing3MyArmyMoveCompleteHandler);
         var _loc2_:int = 0;
         while(_loc2_ < this._leftSoldiers.length)
         {
            if(this._leftSoldiers[_loc2_].type == Type.QIBING)
            {
               this._leftSoldiers[_loc2_].speed = 3;
            }
            else
            {
               this._leftSoldiers[_loc2_].speed = 1.8;
            }
            _loc2_++;
         }
         this._rightSoldiers[0].talk({
            "text":"居然突破了两道防线，还挺有两下子的哈，也罢！让本将军取下你们项上人头…",
            "delay":2000
         });
         if(this._timer != null)
         {
            this._timer.stop();
            this._timer = null;
         }
         this._timer = new Timer(2500,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.juqing3OverHandler);
         this._timer.start();
      }
      
      private function juqing3OverHandler(param1:TimerEvent) : *
      {
         this._timer.reset();
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.juqing3OverHandler);
         this._mask.addEventListener(Event.COMPLETE,this.onMaskFrameCompleteHandler);
         this._mask.gotoAndPlay("removeMask");
      }
      
      private function onPauseBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.createPauseMask();
         this._ai.pause = true;
      }
      
      private function createPauseMask() : *
      {
         if(this._pauseMC == null)
         {
            this._pauseMC = new BaseUI(SkinCode.PAUSE_MASK_MC);
            this._pauseMC.x = stage.stageWidth / 2;
            this._pauseMC.y = stage.stageHeight / 2;
         }
         this._pauseMC.addEventListener(MouseEvent.CLICK,this.onPuseMCClickHandler);
         addChild(this._pauseMC);
         this._pauseMC.createMask(0,0.5);
         this.stopAllAction();
      }
      
      private function stopAllAction() : *
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._leftSoldiers.length)
         {
            if(this._leftSoldiers[_loc2_].isDead == false)
            {
               this._leftSoldiers[_loc2_].stand();
               this._leftSoldiers[_loc2_].cooling = false;
            }
            _loc2_++;
         }
         if(this._currentStageID == 2)
         {
            _loc1_ = 0;
            while(_loc1_ < this._rightSoldiers.length)
            {
               if(this._rightSoldiers[_loc1_].isDead == false)
               {
                  this._rightSoldiers[_loc1_].stand();
                  this._rightSoldiers[_loc1_].cooling = false;
               }
               _loc1_++;
            }
         }
      }
      
      private function onPuseMCClickHandler(param1:MouseEvent) : *
      {
         removeChild(this._pauseMC);
         this._ai.pause = false;
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
      
      private function hideAmmoTipsHandler(param1:MouseEvent) : *
      {
         stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.hideAmmoTipsHandler,true);
         this._ammoTips.visible = false;
      }
   }
}
