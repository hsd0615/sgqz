package game.ui
{
   import com.iflashigame.net.ChatManager;
   import com.iflashigame.net.P2PEvent;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.TextFilter;
   import com.iflashigame.utils.Tools;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import game.Data;
   import game.events.UIEvent;
   import game.model.ArmyInfo;
   import game.model.Head;
   import game.model.RoleModel;
   import game.model.Type;
   
   public class FightWait extends BaseUI
   {
       
      
      private var __talkArea:TextField;
      
      private var __talkInputTF:TextField;
      
      private var __talkBtn:SimpleButton;
      
      private var __okBtn:SimpleButton;
      
      private var __cancelBtn:SimpleButton;
      
      private var __adjustBtn:SimpleButton;
      
      private var __closeBtn:SimpleButton;
      
      private var __leftNameTF:TextField;
      
      private var __leftLevelTF:TextField;
      
      private var __rightNameTF:TextField;
      
      private var __rightLevelTF:TextField;
      
      private var __leftStatus:MovieClip;
      
      private var __rightStatus:MovieClip;
      
      private var _leftImgPos:Point;
      
      private var _rightImgPos:Point;
      
      private var _leftPos0:Point;
      
      private var _leftPos1:Point;
      
      private var _leftPos2:Point;
      
      private var _leftPos3:Point;
      
      private var _leftPos4:Point;
      
      private var _rightPos0:Point;
      
      private var _rightPos1:Point;
      
      private var _rightPos2:Point;
      
      private var _rightPos3:Point;
      
      private var _rightPos4:Point;
      
      private var _leftBlock0:GeneralBlock;
      
      private var _leftBlock1:GeneralBlock;
      
      private var _leftBlock2:GeneralBlock;
      
      private var _leftBlock3:GeneralBlock;
      
      private var _leftBlock4:GeneralBlock;
      
      private var _rightBlock0:GeneralBlock;
      
      private var _rightBlock1:GeneralBlock;
      
      private var _rightBlock2:GeneralBlock;
      
      private var _rightBlock3:GeneralBlock;
      
      private var _rightBlock4:GeneralBlock;
      
      private var _leftArmy:Vector.<ArmyInfo>;
      
      private var _rightArmy:Vector.<ArmyInfo>;
      
      private var _leftInfo:Object;
      
      private var _rightInfo:Object;
      
      private var _leftStatus:int;
      
      private var _rightStatus:int;
      
      private var _leftImage:MovieClip;
      
      private var _rightImage:MovieClip;
      
      private var _direct:int;
      
      public function FightWait(param1:String, param2:ApplicationDomain = null)
      {
         this._leftImgPos = new Point(-352.5,-225.2);
         this._rightImgPos = new Point(246.45,-55.5);
         this._leftPos0 = new Point(-210.65,-223.65);
         this._leftPos1 = new Point(-95.2,-223.65);
         this._leftPos2 = new Point(20.25,-223.65);
         this._leftPos3 = new Point(135.7,-223.65);
         this._leftPos4 = new Point(251.3,-223.65);
         this._rightPos0 = new Point(-346.65,-54.65);
         this._rightPos1 = new Point(-231.2,-54.65);
         this._rightPos2 = new Point(-115.75,-54.65);
         this._rightPos3 = new Point(-0.3,-54.65);
         this._rightPos4 = new Point(115.3,-54.65);
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__talkArea = _skin.getChildByName("_talkArea") as TextField;
         this.__talkInputTF = _skin.getChildByName("_talkInputTF") as TextField;
         this.__talkBtn = _skin.getChildByName("_talkBtn") as SimpleButton;
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this.__cancelBtn = _skin.getChildByName("_cancelBtn") as SimpleButton;
         this.__adjustBtn = _skin.getChildByName("_adjustBtn") as SimpleButton;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__leftNameTF = _skin.getChildByName("_leftNameTF") as TextField;
         this.__leftLevelTF = _skin.getChildByName("_leftLevelTF") as TextField;
         this.__rightNameTF = _skin.getChildByName("_rightNameTF") as TextField;
         this.__rightLevelTF = _skin.getChildByName("_rightLevelTF") as TextField;
         this.__leftStatus = _skin.getChildByName("_leftStatus") as MovieClip;
         this.__rightStatus = _skin.getChildByName("_rightStatus") as MovieClip;
         this.__talkArea.text = "";
         this.__talkInputTF.text = "";
         this.__leftNameTF.text = "";
         this.__rightNameTF.text = "";
         this.__leftLevelTF.text = "";
         this.__rightLevelTF.text = "";
         this.createBlock();
         this.__cancelBtn.visible = false;
      }
      
      private function createBlock() : *
      {
         var _loc1_:int = 0;
         while(_loc1_ < 5)
         {
            this["_leftBlock" + _loc1_] = new GeneralBlock(SkinCode.GENERAL_BLOCK);
            addChild(this["_leftBlock" + _loc1_]);
            this["_leftBlock" + _loc1_].clear();
            this["_leftBlock" + _loc1_].x = this["_leftPos" + _loc1_].x;
            this["_leftBlock" + _loc1_].y = this["_leftPos" + _loc1_].y;
            this["_rightBlock" + _loc1_] = new GeneralBlock(SkinCode.GENERAL_BLOCK);
            addChild(this["_rightBlock" + _loc1_]);
            this["_rightBlock" + _loc1_].clear();
            this["_rightBlock" + _loc1_].x = this["_rightPos" + _loc1_].x;
            this["_rightBlock" + _loc1_].y = this["_rightPos" + _loc1_].y;
            _loc1_++;
         }
      }
      
      override protected function initEvent() : void
      {
         this.__talkBtn.addEventListener(MouseEvent.CLICK,this.talkBtnClickHandler);
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.okBtnClickHandler);
         this.__cancelBtn.addEventListener(MouseEvent.CLICK,this.cancelBtnClickHandler);
         this.__adjustBtn.addEventListener(MouseEvent.CLICK,this.adjustBtnClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this.__talkInputTF.addEventListener(KeyboardEvent.KEY_DOWN,this.onTalkInputKeyDownHandler);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHandler);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutHandler);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this._leftInfo = param1.leftInfo;
         this._rightInfo = param1.rightInfo;
         this.setLeftArmy(param1.leftArmy);
         this.setRightArmy(param1.rightArmy);
         this._direct = param1.direct;
         this.__leftNameTF.text = param1.leftInfo.name;
         this.__rightNameTF.text = param1.rightInfo.name;
         this.__leftLevelTF.text = "等级：" + param1.leftInfo.level;
         this.__rightLevelTF.text = "等级：" + param1.rightInfo.level;
         this.setImage(this._leftImage,1,param1.leftInfo.image);
         this.setImage(this._rightImage,-1,param1.rightInfo.image);
         this.setStatus(1,1);
         this.setStatus(-1,1);
      }
      
      public function setLeftArmy(param1:Vector.<ArmyInfo>) : *
      {
         this._leftArmy = param1;
         var _loc2_:int = 0;
         while(_loc2_ < 5)
         {
            if(_loc2_ < this._leftArmy.length)
            {
               this["_leftBlock" + _loc2_].initData(this._leftArmy[_loc2_]);
            }
            else
            {
               this["_leftBlock" + _loc2_].clear();
            }
            _loc2_++;
         }
      }
      
      public function setRightArmy(param1:Vector.<ArmyInfo>) : *
      {
         this._rightArmy = param1;
         var _loc2_:int = 0;
         while(_loc2_ < 5)
         {
            if(_loc2_ < this._rightArmy.length)
            {
               this["_rightBlock" + _loc2_].initData(this._rightArmy[_loc2_]);
            }
            else
            {
               this["_rightBlock" + _loc2_].clear();
            }
            _loc2_++;
         }
      }
      
      private function setImage(param1:MovieClip, param2:int, param3:int) : *
      {
         var _loc4_:Class;
         param1 = new (_loc4_ = ApplicationDomain.currentDomain.getDefinition("image" + param3) as Class)() as MovieClip;
         if(param2 == 1)
         {
            param1.x = this._leftImgPos.x;
            param1.y = this._leftImgPos.y;
         }
         else
         {
            param1.x = this._rightImgPos.x;
            param1.y = this._rightImgPos.y;
         }
         addChild(param1);
      }
      
      public function setStatus(param1:int, param2:int) : *
      {
         if(param1 == 1)
         {
            this._leftStatus = param2;
            this.__leftStatus.gotoAndStop(param2);
            addChild(this.__leftStatus);
         }
         else
         {
            this._rightStatus = param2;
            this.__rightStatus.gotoAndStop(param2);
            addChild(this.__rightStatus);
         }
         if(this._leftStatus == 2 && this._rightStatus == 2)
         {
            ChatManager.getInstance().p2pSend({"head":Head.FIGHT_START});
            ChatManager.getInstance().dispatchEvent(new P2PEvent(P2PEvent.P2P_DATA,false,{"head":Head.FIGHT_START}));
         }
      }
      
      public function setArea(param1:String) : *
      {
         param1 = TextFilter.getInstance().replaceText(param1);
         this.__talkArea.htmlText += param1;
         this.__talkArea.scrollV = this.__talkArea.maxScrollV;
      }
      
      public function getLeftInfo() : Object
      {
         return this._leftInfo;
      }
      
      public function getRightInfo() : Object
      {
         return this._rightInfo;
      }
      
      public function getDirect() : int
      {
         return this._direct;
      }
      
      public function getLeftArmy() : Vector.<ArmyInfo>
      {
         return this._leftArmy;
      }
      
      public function getRightArmy() : Vector.<ArmyInfo>
      {
         return this._rightArmy;
      }
      
      public function addSoldier(param1:Object) : *
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:ArmyInfo = Data.getInstance().getArmyInfo(param1.code,param1.level,param1.evolution,param1.feature,param1.name,param1.delay,param1.ai,param1.kezhi,param1.tianfu);
         if(param1.direct == 1)
         {
            this._leftArmy.push(_loc4_);
            _loc2_ = 0;
            while(_loc2_ < 5)
            {
               if(this["_leftBlock" + _loc2_].active == false)
               {
                  this["_leftBlock" + _loc2_].initData(_loc4_);
                  return;
               }
               _loc2_++;
            }
         }
         else
         {
            this._rightArmy.push(_loc4_);
            _loc3_ = 0;
            while(_loc3_ < 5)
            {
               if(this["_rightBlock" + _loc3_].active == false)
               {
                  this["_rightBlock" + _loc3_].initData(_loc4_);
                  return;
               }
               _loc3_++;
            }
         }
      }
      
      public function removeSoldier(param1:Object) : *
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1.direct == 1)
         {
            _loc2_ = 0;
            while(_loc2_ < 5)
            {
               if(this["_leftBlock" + _loc2_].active == true)
               {
                  if(this["_leftBlock" + _loc2_].armyInfo.code == param1.code)
                  {
                     this["_leftBlock" + _loc2_].clear();
                     break;
                  }
               }
               _loc2_++;
            }
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < 5)
            {
               if(this["_rightBlock" + _loc3_].active == true)
               {
                  if(this["_rightBlock" + _loc3_].armyInfo.code == param1.code)
                  {
                     this["_rightBlock" + _loc3_].clear();
                     break;
                  }
               }
               _loc3_++;
            }
         }
         this.removeSoldierFromArmy(param1.direct,param1.code);
      }
      
      private function removeSoldierFromArmy(param1:int, param2:String) : *
      {
         var _loc3_:Vector.<ArmyInfo> = null;
         if(param1 == 1)
         {
            _loc3_ = this._leftArmy;
         }
         else
         {
            _loc3_ = this._rightArmy;
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_].code == param2)
            {
               _loc3_.splice(_loc4_,1);
               return;
            }
            _loc4_++;
         }
      }
      
      private function talkBtnClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:* = null;
         var _loc5_:Object = null;
         if(param1 != null)
         {
            param1.stopImmediatePropagation();
         }
         if(this.__talkInputTF.text != "\r" && this.__talkInputTF.text != "")
         {
            _loc2_ = RoleModel.getInstance().roleName;
            _loc3_ = RoleModel.getInstance().imageID;
            if(_loc3_ % 2 == 1)
            {
               _loc4_ = "<font color=\'#6CDDF5\'>" + _loc2_ + "：</font>" + this.__talkInputTF.text + "\n";
            }
            else
            {
               _loc4_ = "<font color=\'#FC9595\'>" + _loc2_ + "：</font>" + this.__talkInputTF.text + "\n";
            }
            this.setArea(_loc4_);
            (_loc5_ = {}).head = Head.P2P_TALK;
            _loc5_.text = _loc4_;
            ChatManager.getInstance().p2pSend(_loc5_);
            this.__talkInputTF.text = "";
         }
      }
      
      private function okBtnClickHandler(param1:MouseEvent) : *
      {
         if(param1 != null)
         {
            param1.stopImmediatePropagation();
         }
         var _loc2_:Object = {};
         _loc2_.head = Head.FIGHT_STATUS_CHANGE;
         _loc2_.direct = this._direct;
         _loc2_.status = 2;
         ChatManager.getInstance().p2pSend(_loc2_);
         Tools.setDisabled(this.__adjustBtn,true);
         this.__okBtn.visible = false;
         this.__cancelBtn.visible = true;
         this.setStatus(this._direct,2);
      }
      
      private function cancelBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         var _loc2_:Object = {};
         _loc2_.head = Head.FIGHT_STATUS_CHANGE;
         _loc2_.direct = this._direct;
         _loc2_.status = 1;
         ChatManager.getInstance().p2pSend(_loc2_);
         Tools.setDisabled(this.__adjustBtn,false);
         this.__okBtn.visible = true;
         this.__cancelBtn.visible = false;
         this.setStatus(this._direct,1);
      }
      
      private function adjustBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_BUDUI,true));
      }
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         var _loc2_:Object = {};
         _loc2_.head = Head.CANCEL_FIGHT;
         ChatManager.getInstance().p2pSend(_loc2_);
         dispatchEvent(new UIEvent(UIEvent.CANCEL_FIGHTWAIT,true));
      }
      
      private function onTalkInputKeyDownHandler(param1:KeyboardEvent) : *
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.talkBtnClickHandler(null);
         }
      }
      
      private function onMouseOverHandler(param1:MouseEvent) : void
      {
         var _loc2_:GeneralBlock = null;
         var _loc3_:* = null;
         param1.stopImmediatePropagation();
         if(param1.target is GeneralBlock && param1.target.active == true)
         {
            _loc2_ = param1.target as GeneralBlock;
            _loc3_ = "";
            _loc3_ += "<font face=\'_sans\'>";
            _loc3_ += this.createTitle(_loc2_.armyInfo.title);
            _loc3_ += "<font color=\'#e5ce10\'>姓名：</font>" + _loc2_.armyInfo.name + "\n";
            _loc3_ += "<font color=\'#e5ce10\'>等级：</font>" + _loc2_.armyInfo.level + "\n";
            _loc3_ += "<font color=\'#e5ce10\'>类型：</font>" + this.createType(_loc2_.armyInfo.type);
            _loc3_ += "<font color=\'#e5ce10\'>攻击：</font>";
            _loc3_ += _loc2_.armyInfo.attack + "\n";
            _loc3_ += "<font color=\'#e5ce10\'>防御：</font>";
            _loc3_ += _loc2_.armyInfo.defense + "\n";
            _loc3_ += "<font color=\'#e5ce10\'>血量：</font>";
            _loc3_ += _loc2_.armyInfo.hp + "\n";
            _loc3_ += "<font color=\'#e5ce10\'>射程：</font>";
            _loc3_ += _loc2_.armyInfo.attackDistance + "\n";
            _loc3_ += "<font color=\'#e5ce10\'>进化等级：</font>";
            if(_loc2_.armyInfo.evolution == 0)
            {
               _loc3_ += "无\n";
            }
            else
            {
               _loc3_ += _loc2_.armyInfo.evolution + "级 <font color=\'#4bea13\'>全属性增加" + _loc2_.armyInfo.getAddtion() * 100 + "%</font>\n";
            }
            _loc3_ += "<font color=\'#e5ce10\'>攻击属相：</font>";
            if(_loc2_.armyInfo.feature == 0)
            {
               _loc3_ += "无\n";
            }
            else if(_loc2_.armyInfo.feature == 1)
            {
               _loc3_ += "<font color=\'#16d2fa\'>冰</font>";
               _loc3_ += " <font color=\'#f45415\'>克制火，被雷克制</font>\n";
            }
            else if(_loc2_.armyInfo.feature == 2)
            {
               _loc3_ += "<font color=\'#ff3333\'>火</font>";
               _loc3_ += " <font color=\'#f45415\'>克制风，被冰克制</font>\n";
            }
            else if(_loc2_.armyInfo.feature == 3)
            {
               _loc3_ += "<font color=\'#4bea13\'>风</font>";
               _loc3_ += " <font color=\'#f45415\'>克制雷，被火克制</font>\n";
            }
            else if(_loc2_.armyInfo.feature == 4)
            {
               _loc3_ += "<font color=\'#e720f9\'>雷</font>";
               _loc3_ += " <font color=\'#f45415\'>克制冰，被风克制</font>\n";
            }
            if(_loc2_.armyInfo.type != Type.TOUSHICHE)
            {
               if(_loc2_.armyInfo.tianfu != null)
               {
                  _loc3_ += "<font color=\'#e5ce10\'>天赋：</font>" + Data.getInstance().getAttributes("tianfu",_loc2_.armyInfo.tianfu,"name") + "\n";
               }
               else
               {
                  _loc3_ += "<font color=\'#e5ce10\'>天赋：</font>" + "无\n";
               }
               _loc3_ += "<font color=\'#e5ce10\'>克制" + Type.TYPE_NAME[_loc2_.armyInfo.kezhi1] + ":</font>" + _loc2_.armyInfo.kezhiLevel1 + "级\n";
               _loc3_ += "<font color=\'#e5ce10\'>克制" + Type.TYPE_NAME[_loc2_.armyInfo.kezhi2] + ":</font>" + _loc2_.armyInfo.kezhiLevel2 + "级\n";
               _loc3_ += "<font color=\'#e5ce10\'>克制" + Type.TYPE_NAME[_loc2_.armyInfo.kezhi3] + ":</font>" + _loc2_.armyInfo.kezhiLevel3 + "级\n";
               _loc3_ += "</font>";
               dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
                  "htmlText":_loc3_,
                  "type":3,
                  "width":150,
                  "height":220
               }));
            }
            else
            {
               _loc3_ += "</font>";
               dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
                  "htmlText":_loc3_,
                  "type":3,
                  "width":150,
                  "height":155
               }));
            }
         }
      }
      
      private function createType(param1:int) : String
      {
         var _loc2_:String = null;
         switch(param1)
         {
            case Type.CHANGQIANGBING:
               _loc2_ = "长枪兵\n";
               break;
            case Type.CHUIBING:
               _loc2_ = "锤兵\n";
               break;
            case Type.FEIDAOBING:
               _loc2_ = "飞刀兵\n";
               break;
            case Type.FUBING:
               _loc2_ = "斧兵\n";
               break;
            case Type.GONGBING:
               _loc2_ = "弓兵\n";
               break;
            case Type.PUDAOBING:
               _loc2_ = "朴刀兵\n";
               break;
            case Type.QIBING:
               _loc2_ = "骑兵\n";
               break;
            case Type.TENGJIABING:
               _loc2_ = "藤甲兵\n";
               break;
            case Type.TOUSHICHE:
               _loc2_ = "投石车\n";
               break;
            case Type.WUDOUBING:
               _loc2_ = "武斗兵\n";
         }
         return _loc2_;
      }
      
      private function createTitle(param1:int) : String
      {
         var _loc2_:String = null;
         switch(param1)
         {
            case 0:
               _loc2_ = "<font color=\'#ff6600\'>超级武将</font>\n";
               break;
            case 1:
               _loc2_ = "<font color=\'#33ccff\'>一流武将</font>\n";
               break;
            case 2:
               _loc2_ = "<font color=\'#99ff33\'>二流武将</font>\n";
               break;
            default:
               _loc2_ = "<font color=\'#ffcc99\'>三流武将</font>\n";
         }
         return _loc2_;
      }
      
      private function onMouseOutHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         if(param1.target is GeneralBlock && param1.target.active == true)
         {
            dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
         }
      }
      
      private function onRemoveFromStageHandler(param1:Event) : *
      {
         dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
      }
      
      public function fight() : *
      {
         this.okBtnClickHandler(null);
      }
   }
}
