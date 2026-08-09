package game.display
{
   import com.iflashigame.ui.ProgressBar;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.BlurFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.utils.Timer;
   import game.Logic;
   import game.events.SoldierEvent;
   import game.model.ArmyInfo;
   import game.model.Type;
   import game.ui.SkinCode;
   
   public class AbstractSoldier extends Sprite
   {
       
      
      protected var _skin:MovieClip;
      
      protected var _nameTF:TextField;
      
      protected var _icon:MovieClip;
      
      protected var _bloodBar:ProgressBar;
      
      protected var _coolingBar:ProgressBar;
      
      protected var _shadow:Shape;
      
      protected var _armyInfo:ArmyInfo;
      
      protected var _direct:int;
      
      protected var _isPlayer:Boolean;
      
      protected var _isDead:Boolean;
      
      protected var _world:IWorld;
      
      protected var _walking:Boolean;
      
      protected var _cooling:Boolean;
      
      protected var _fireing:Boolean;
      
      protected var _timer:Timer;
      
      protected var _maxHP:int;
      
      protected var _speed:Number = 1.8;
      
      protected var _locked:AbstractSoldier;
      
      protected var _selected:Boolean;
      
      public function AbstractSoldier(param1:ArmyInfo, param2:int = 1, param3:Boolean = false, param4:IWorld = null)
      {
         super();
         mouseEnabled = false;
         this._armyInfo = param1;
         this._maxHP = this._armyInfo.maxHp;
         if(!this._armyInfo.forceHp) {
            this._armyInfo.hp = this._armyInfo.maxHp;
         } else {
            this._maxHP = this._armyInfo.hp;
         }
         this._direct = param2;
         this._isPlayer = param3;
         this._world = param4;
         this.initView();
         this.initEvent();
      }
      
      protected function initView() : *
      {
         this.drawShadow();
         this.initSkin();
         this.showBar();
         this.createName();
      }
      
      protected function initEvent() : *
      {
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHandler,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutHandler,false,0,true);
         this._skin.addEventListener(MouseEvent.CLICK,this.onMouseClickHandler,false,0,true);
      }
      
      protected function onMouseOverHandler(param1:MouseEvent) : *
      {
         if(this._world != null && this._world.getAutoMode() == true)
         {
            return;
         }
         if(this._isPlayer)
         {
            if(!this._selected)
            {
               this.setGlow(true);
            }
         }
         else
         {
            dispatchEvent(new SoldierEvent(SoldierEvent.ENEMY_LOCKED,true));
         }
      }
      
      protected function onMouseOutHandler(param1:MouseEvent) : *
      {
         if(this._world != null && this._world.getAutoMode() == true)
         {
            return;
         }
         if(this._isPlayer)
         {
            if(!this._selected)
            {
               this.setGlow(false);
            }
         }
         else
         {
            dispatchEvent(new SoldierEvent(SoldierEvent.ENEMY_UNLOCKED,true));
         }
      }
      
      protected function onMouseClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._world != null && this._world.getAutoMode() == true)
         {
            return;
         }
         if(this._isPlayer)
         {
            this.setSelected();
            dispatchEvent(new SoldierEvent(SoldierEvent.SELECTED,true));
         }
         else
         {
            dispatchEvent(new SoldierEvent(SoldierEvent.ENEMY_SELECTED,true));
         }
      }
      
      public function setSelected() : *
      {
         this._selected = true;
         this.setGlow(true);
      }
      
      public function setUnSelected() : *
      {
         this._selected = false;
         this.setGlow(false);
      }
      
      protected function onMouseDoubleClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new SoldierEvent(SoldierEvent.SMART_ATTACK,true));
      }
      
      public function setGlow(param1:Boolean, param2:uint = 16777215) : *
      {
         switch(param1)
         {
            case true:
               this._skin.filters = [new GlowFilter(param2,1,10,10,3)];
               break;
            case false:
               this._skin.filters = [];
         }
      }
      
      protected function initSkin() : *
      {
         var _skinName:String = this._armyInfo.skin;
         // The six new generals use the exported custom timelines in general.swf.
         // staticgeneral.xml keeps their original general codes, so redirect them
         // here before resolving the skin class.
         switch(this._armyInfo.code)
         {
            case "general_6_15": _skinName = "generalSkin_18_0"; break; // Wei Yan
            case "general_1_13": _skinName = "generalSkin_23_0"; break; // Lu Meng
            case "general_9_14": _skinName = "generalSkin_21_0"; break; // Jiang Wei
            case "general_1_14": _skinName = "generalSkin_22_0"; break; // Lu Xun
            case "general_6_13": _skinName = "generalSkin_24_0"; break; // Cao Zhang
            case "general_9_7": _skinName = "generalSkin_19_0"; break; // Xiahou Yuan
         }
         var _loc1_:Class;
         try {
            _loc1_ = ApplicationDomain.currentDomain.getDefinition(_skinName) as Class;
         } catch(_e:Error) {
            try {
               // 进化皮肤_1不存在,回退到_0
               var _li:int = _skinName.lastIndexOf("_");
               if(_li > 0) _skinName = _skinName.substr(0, _li) + "_0";
               _loc1_ = ApplicationDomain.currentDomain.getDefinition(_skinName) as Class;
            } catch(_e2:Error) {
               try {
                  // 连_0也不存在,用去掉后缀的原始皮肤名
                  var _li2:int = this._armyInfo.skin.lastIndexOf("_");
                  if(_li2 > 0) _skinName = this._armyInfo.skin.substr(0, _li2);
                  _loc1_ = ApplicationDomain.currentDomain.getDefinition(_skinName) as Class;
               } catch(_e3:Error) {
                  // 终极回退: 所有皮肤都不存在,用透明占位
                  this._skin = new MovieClip();
                  return;
               }
            }
         }
         this._skin = new _loc1_() as MovieClip;
         if(this._armyInfo.code == "general_5_19" || this._armyInfo.type == Type.JUNZHU)
         {
            this._skin.scaleX = 0.52 * this._direct;
            this._skin.scaleY = 0.52;
         }
         else if(this._armyInfo.evolution > 1)
         {
            this._skin.scaleX = this._direct * 0.6;
            this._skin.scaleY = 0.6;
         }
         else
         {
            this._skin.scaleX = this._direct * 0.65;
            this._skin.scaleY = 0.65;
         }
         this._skin.mouseChildren = false;
         this._skin.buttonMode = true;
         addChild(this._skin);
         // 魔化/神化视觉效果
         if(this._armyInfo.name != null)
         {
            var _isMo3:Boolean = this._armyInfo.name.indexOf("魔化") == 0;
            var _isShen3:Boolean = this._armyInfo.name.indexOf("神化") == 0;
            if(_isMo3 || _isShen3)
            {
               var _glowColor3:uint = _isMo3 ? 0x000000 : 0xFF00FF;
               this._skin.filters = [new GlowFilter(_glowColor3, 1, 6, 6, 2)];
            }
         }
      }
      
      protected function drawShadow() : *
      {
         this._shadow = new Shape();
         this._shadow.graphics.beginFill(0);
         this._shadow.graphics.drawEllipse(-20,-5,40,10);
         this._shadow.filters = [new BlurFilter(10,6)];
         addChild(this._shadow);
      }
      
      protected function showBar() : *
      {
         var _loc1_:int = 0;
         this._bloodBar = new ProgressBar(40,5,1,16711680,1,0,0.8,1,3342336,1);
         this._coolingBar = new ProgressBar(40,3,1,52224,1,0,0.8,1,26112,1);
         if(this._armyInfo.code == "general_5_19" || this._armyInfo.type == Type.JUNZHU)
         {
            _loc1_ = 75;
         }
         else if(this._armyInfo.evolution > 1)
         {
            _loc1_ = Type.LONG[this._armyInfo.type] + 15;
         }
         else
         {
            _loc1_ = int(Type.LONG[this._armyInfo.type]);
         }
         this._coolingBar.y = -_loc1_;
         this._coolingBar.x = -this._coolingBar.width / 2;
         this._bloodBar.y = this._coolingBar.y - this._bloodBar.height + 1;
         this._bloodBar.x = -this._bloodBar.width / 2;
         this._coolingBar.mouseChildren = false;
         this._coolingBar.mouseEnabled = false;
         this._bloodBar.mouseChildren = false;
         this._bloodBar.mouseEnabled = false;
         this._coolingBar.setMax(this._armyInfo.cd * 1000,true);
         this._bloodBar.setMax(this.maxHP,true);
         addChild(this._bloodBar);
         if(this._isPlayer)
         {
            addChild(this._coolingBar);
         }
      }
      
      protected function createName() : *
      {
         var _loc1_:Class = null;
         this._nameTF = new TextField();
         this._nameTF.selectable = false;
         this._nameTF.text = "Lv" + this._armyInfo.level + ":" + this._armyInfo.name;
         this._nameTF.mouseEnabled = false;
         this._nameTF.width = this._nameTF.textWidth + 4;
         this._nameTF.height = this._nameTF.textHeight + 4;
         this._nameTF.y = this._bloodBar.y - 20;
         this._nameTF.x = -this._nameTF.width / 2;
         this._nameTF.mouseEnabled = false;
         this.setFilterColor(this._nameTF,14540253);
         addChild(this._nameTF);
         if(this._armyInfo.feature > 0)
         {
            _loc1_ = ApplicationDomain.currentDomain.getDefinition(SkinCode.ATTACK_ICON) as Class;
            this._icon = new _loc1_() as MovieClip;
            this._icon.mouseChildren = false;
            this._icon.mouseEnabled = false;
            this._nameTF.x += this._icon.width / 2;
            this._icon.x = this._nameTF.x - this._icon.width;
            this._icon.y = this._nameTF.y;
            addChild(this._icon);
            this._icon.gotoAndStop(this._armyInfo.feature);
         }
      }
      
      public function setNameVisible(param1:Boolean) : *
      {
         if(param1 == true)
         {
            this.setFilterColor(this._nameTF,13421772);
         }
         else
         {
            this.setFilterColor(this._nameTF,16772608);
         }
      }
      
      private function setFilterColor(param1:DisplayObject, param2:uint) : *
      {
         param1.filters = [new GlowFilter(param2,1,2,2,50)];
      }
      
      public function stand() : void
      {
         this._skin.gotoAndStop("_stand");
      }
      
      public function talk(param1:Object) : *
      {
         if(this._armyInfo.type == Type.JUNZHU)
         {
            param1.point = new Point(x - 20,y - 75);
         }
         else
         {
            param1.point = new Point(x - 20,y - Type.LONG[this._armyInfo.type]);
         }
         trace(param1.point);
         dispatchEvent(new SoldierEvent(SoldierEvent.TALK,true,param1));
      }
      
      public function goLeft(param1:Number = 0) : void
      {
         this._skin.gotoAndPlay("_moveBegin");
      }
      
      public function goRight(param1:Number = 0) : void
      {
         this._skin.gotoAndPlay("_moveBegin");
      }
      
      public function fire(param1:Object = null) : void
      {
         this._skin.gotoAndPlay("_attackBegin");
      }
      
      public function fire2(param1:Object = null) : void
      {
         this._skin.gotoAndPlay("_attckBegin");
      }
      
      public function baojiAttack(param1:Object = null) : void
      {
         this._skin.gotoAndPlay("_baojiBegin");
      }
      
      public function dead() : void
      {
         this.mouseChildren = false;
         this.mouseEnabled = false;
         this._isDead = true;
         this._skin.gotoAndPlay("_deadBegin");
      }
      
      public function hurt(param1:int, param2:AbstractSoldier = null) : void
      {
         if(this._isDead)
         {
            return;
         }
         this._armyInfo.hp -= param1;
         if(this._armyInfo.hp < 0)
         {
            this._armyInfo.hp = 0;
         }
         this._bloodBar.setCurrent(this._armyInfo.hp);
         dispatchEvent(new SoldierEvent(SoldierEvent.BEHURT,true,{value:param1,isCrit:Logic.lastCrit}));

         // 吸血: 攻击者回复伤害值的百分比
         if(param2 != null && param2._armyInfo != null && param2._armyInfo.equipLifesteal > 0 && !param2._isDead)
         {
            var _heal:int = int(param1 * param2._armyInfo.equipLifesteal / 100);
            if(_heal > 0)
            {
               param2.armyInfo.hp += _heal;
               if(param2.armyInfo.hp > param2.maxHP) param2.armyInfo.hp = param2.maxHP;
               param2.bloodBar.setCurrent(param2.armyInfo.hp);
            }
         }

         if(this._armyInfo.hp == 0)
         {
            addEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
            this.dead();
            dispatchEvent(new SoldierEvent(SoldierEvent.DEAD,true));
         }
      }
      
      protected function onEnterFrameHandler(param1:Event) : *
      {
         if(this._skin.currentFrameLabel == "_deadEnd")
         {
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
            dispatchEvent(new SoldierEvent(SoldierEvent.DEAD_COMPLETE,true));
         }
      }
      
      public function showHudun() : *
      {
         var _loc2_:MovieClip = null;
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition("texiao_hudun") as Class;
         _loc2_ = new _loc1_() as MovieClip;
         _loc2_.scaleX = this._skin.scaleX;
         _loc2_.scaleY = this._skin.scaleY;
         _loc2_.x = this._skin.x;
         _loc2_.y = this._skin.y;
         _loc2_.mouseChildren = false;
         _loc2_.mouseEnabled = false;
         addChild(_loc2_);
         _loc2_.gotoAndPlay(2);
         _loc2_.addEventListener("texiaoOver",this.texiaoOverHandler);
      }
      
      public function showFanshang() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition("texiao_fanshang") as Class;
         var _loc2_:MovieClip = new _loc1_() as MovieClip;
         _loc2_.scaleX = this._skin.scaleX;
         _loc2_.scaleY = this._skin.scaleY;
         _loc2_.x = this._skin.x;
         _loc2_.y = this._skin.y;
         _loc2_.mouseChildren = false;
         _loc2_.mouseEnabled = false;
         addChild(_loc2_);
         _loc2_.gotoAndPlay(2);
         _loc2_.addEventListener("texiaoOver",this.texiaoOverHandler);
      }
      
      private function texiaoOverHandler(param1:Event) : *
      {
         removeChild(param1.currentTarget as MovieClip);
      }
      
      public function getHurPoint(param1:DisplayObject) : Point
      {
         var _loc2_:MovieClip = this._skin.getChildByName("_hurtPoint") as MovieClip;
         var _loc3_:Point = _loc2_.localToGlobal(new Point(0,0));
         return param1.globalToLocal(_loc3_);
      }
      
      public function get isPlayer() : Boolean
      {
         return this._isPlayer;
      }
      
      public function get isDead() : Boolean
      {
         return this._isDead;
      }
      
      public function get code() : String
      {
         return this._armyInfo.code;
      }
      
      public function get nickName() : String
      {
         return this._armyInfo.name;
      }
      
      public function get type() : int
      {
         return this._armyInfo.type;
      }
      
      public function get level() : int
      {
         return this._armyInfo.level;
      }
      
      public function get hp() : int
      {
         return this._armyInfo.hp;
      }
      
      public function get maxHP() : int
      {
         return this._maxHP;
      }

      public function get bloodBar() : ProgressBar
      {
         return this._bloodBar;
      }
      
      public function get attack() : int
      {
         return this._armyInfo.attack;
      }
      
      public function get defense() : int
      {
         return this._armyInfo.defense;
      }
      
      public function get cd() : int
      {
         return this._armyInfo.cd;
      }
      
      public function get baoji() : int
      {
         return this._armyInfo.baoji;
      }
      
      public function get shanbi() : Number
      {
         return this._armyInfo.shanbi;
      }
      
      public function get attckDistance() : Number
      {
         return this._armyInfo.attackDistance;
      }
      
      public function get moveDistance() : Number
      {
         return this._armyInfo.moveDistance;
      }
      
      public function get feature() : int
      {
         return this._armyInfo.feature;
      }
      
      public function get evolution() : int
      {
         return this._armyInfo.evolution;
      }
      
      public function get long() : int
      {
         if(this._armyInfo.type == Type.JUNZHU)
         {
            return 75;
         }
         return Type.LONG[this._armyInfo.type];
      }
      
      public function get direct() : int
      {
         return this._direct;
      }
      
      public function get walking() : Boolean
      {
         return this._walking;
      }
      
      public function get cooling() : Boolean
      {
         return this._cooling;
      }
      
      public function set cooling(param1:Boolean) : *
      {
         this._cooling = param1;
      }
      
      public function get fireing() : Boolean
      {
         return this._fireing;
      }
      
      public function get canLeft() : Boolean
      {
         return false;
      }
      
      public function get canRight() : Boolean
      {
         return false;
      }
      
      public function getRectangle(param1:DisplayObject) : Rectangle
      {
         return this._skin.getRect(param1);
      }
      
      public function get canAI() : Boolean
      {
         if(this._walking)
         {
            return false;
         }
         if(this._isDead)
         {
            return false;
         }
         if(this._cooling)
         {
            return false;
         }
         if(this._fireing)
         {
            return false;
         }
         return true;
      }
      
      public function get delay() : int
      {
         return this._armyInfo.delay;
      }
      
      public function get ai() : int
      {
         return this._armyInfo.ai;
      }
      
      public function get speed() : Number
      {
         return this._speed;
      }
      
      public function set speed(param1:Number) : *
      {
         this._speed = param1;
      }
      
      public function get armyInfo() : ArmyInfo
      {
         return this._armyInfo;
      }
      
      public function dispatchP2PActionEvent(param1:Object) : *
      {
         if(this._isPlayer == true)
         {
            dispatchEvent(new SoldierEvent(SoldierEvent.P2P_ACTION,true,param1));
         }
      }
   }
}
