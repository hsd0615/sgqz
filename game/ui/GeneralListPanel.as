package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.Data;
   import game.events.UIEvent;
   import game.model.ArmyInfo;
   import game.model.RoleModel;
   import game.model.Type;
   
   public class GeneralListPanel extends BaseUI
   {
       
      
      private var __btn1:MovieClip;
      
      private var __btn2:MovieClip;
      
      private var __btn3:MovieClip;
      
      private var __btn4:MovieClip;
      
      private var __btn5:MovieClip;
      
      private var __btn6:MovieClip;
      
      private var __btn7:MovieClip;
      
      private var __btn8:MovieClip;
      
      private var __btn9:MovieClip;
      
      private var __btn10:MovieClip;
      
      private var __btn0:MovieClip;
      
      private var __moneyTF:TextField;
      
      private var __exploitTF:TextField;
      
      private var __preBtn:SimpleButton;
      
      private var __pageTF:TextField;
      
      private var __nextBtn:SimpleButton;
      
      private var __closeBtn:SimpleButton;
      
      private var _currentPage:int;
      
      private var _maxPage:int;
      
      private var _roleModel:RoleModel;
      
      private var _army:Vector.<ArmyInfo>;
      
      private var _iconArr:Array;
      
      private var _iconContainer:Sprite;
      
      private var _currentIcon:GeneralBlock;
      
      private var _currentLabel:int = 1;
      
      public function GeneralListPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__btn1 = _skin.getChildByName("_btn1") as MovieClip;
         this.__btn2 = _skin.getChildByName("_btn2") as MovieClip;
         this.__btn3 = _skin.getChildByName("_btn3") as MovieClip;
         this.__btn4 = _skin.getChildByName("_btn4") as MovieClip;
         this.__btn5 = _skin.getChildByName("_btn5") as MovieClip;
         this.__btn6 = _skin.getChildByName("_btn6") as MovieClip;
         this.__btn7 = _skin.getChildByName("_btn7") as MovieClip;
         this.__btn8 = _skin.getChildByName("_btn8") as MovieClip;
         this.__btn9 = _skin.getChildByName("_btn9") as MovieClip;
         this.__btn10 = _skin.getChildByName("_btn10") as MovieClip;
         this.__btn0 = _skin.getChildByName("_btn0") as MovieClip;
         this.__moneyTF = _skin.getChildByName("_moneyTF") as TextField;
         this.__exploitTF = _skin.getChildByName("_exploitTF") as TextField;
         this.__preBtn = _skin.getChildByName("_preBtn") as SimpleButton;
         this.__pageTF = _skin.getChildByName("_pageTF") as TextField;
         this.__nextBtn = _skin.getChildByName("_nextBtn") as SimpleButton;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__btn1.buttonMode = true;
         this.__btn2.buttonMode = true;
         this.__btn3.buttonMode = true;
         this.__btn4.buttonMode = true;
         this.__btn5.buttonMode = true;
         this.__btn6.buttonMode = true;
         this.__btn7.buttonMode = true;
         this.__btn8.buttonMode = true;
         this.__btn9.buttonMode = true;
         this.__btn10.buttonMode = true;
         this.__btn0.buttonMode = true;
         this.createIcon();
      }
      
      private function createIcon() : *
      {
         var _loc1_:int = 0;
         var _loc2_:GeneralBlock = null;
         _loc1_ = 0;
         _loc2_ = null;
         this._iconContainer = new Sprite();
         this._iconContainer.x = -315;
         this._iconContainer.y = -145;
         addChild(this._iconContainer);
         this._iconContainer.doubleClickEnabled = true;
         this._iconArr = [];
         _loc1_ = 0;
         while(_loc1_ < 10)
         {
            _loc2_ = new GeneralBlock(SkinCode.GENERAL_BLOCK);
            this._iconArr.push(_loc2_);
            _loc2_.x = _loc1_ % 5 * 132;
            _loc2_.y = int(_loc1_ / 5) * 150;
            this._iconContainer.addChild(_loc2_);
            _loc2_.buttonMode = true;
            _loc1_++;
         }
      }
      
      override protected function initEvent() : void
      {
         this.__btn1.addEventListener(MouseEvent.CLICK,this.btn1ClickHandler);
         this.__btn2.addEventListener(MouseEvent.CLICK,this.btn2ClickHandler);
         this.__btn3.addEventListener(MouseEvent.CLICK,this.btn3ClickHandler);
         this.__btn4.addEventListener(MouseEvent.CLICK,this.btn4ClickHandler);
         this.__btn5.addEventListener(MouseEvent.CLICK,this.btn5ClickHandler);
         this.__btn6.addEventListener(MouseEvent.CLICK,this.btn6ClickHandler);
         this.__btn7.addEventListener(MouseEvent.CLICK,this.btn7ClickHandler);
         this.__btn8.addEventListener(MouseEvent.CLICK,this.btn8ClickHandler);
         this.__btn9.addEventListener(MouseEvent.CLICK,this.btn9ClickHandler);
         this.__btn10.addEventListener(MouseEvent.CLICK,this.btn10ClickHandler);
         this.__btn0.addEventListener(MouseEvent.CLICK,this.btn0ClickHandler);
         this._iconContainer.addEventListener(MouseEvent.MOUSE_OVER,this.onContainerOverHandler);
         this._iconContainer.addEventListener(MouseEvent.MOUSE_OUT,this.onContainerOutHandler);
         this._iconContainer.addEventListener(MouseEvent.CLICK,this.onContainerClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.onCloseBtnClickHandler);
         this.__preBtn.addEventListener(MouseEvent.CLICK,this.onPreBtnClickHandler);
         this.__nextBtn.addEventListener(MouseEvent.CLICK,this.onNextBtnClickHandler);
      }
      
      private function onPreBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         --this._currentPage;
         this.flush();
      }
      
      private function onNextBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         ++this._currentPage;
         this.flush();
      }
      
      private function onContainerOverHandler(param1:MouseEvent) : *
      {
         var _loc2_:GeneralBlock = null;
         var _loc3_:* = null;
         param1.stopImmediatePropagation();
         if((param1.target as GeneralBlock).armyInfo != null)
         {
            _loc2_ = param1.target as GeneralBlock;
            _loc3_ = "";
            _loc3_ += "<font face=\'_sans\'>";
            _loc3_ += Type.createTitle(_loc2_.armyInfo.title) + "\n";
            _loc3_ += "<font color=\'#e5ce10\'>姓名：</font>" + _loc2_.armyInfo.name + "\n";
            _loc3_ += "<font color=\'#e5ce10\'>等级：</font>" + _loc2_.armyInfo.level + "\n";
            _loc3_ += "<font color=\'#e5ce10\'>类型：</font>" + Type.createType(_loc2_.armyInfo.type) + "\n";
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
      
      private function onContainerOutHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
      }
      
      private function onContainerClickHandler(param1:MouseEvent) : *
      {
         this._currentIcon = param1.target as GeneralBlock;
         if(this._currentIcon.armyInfo != null)
         {
            dispatchEvent(new UIEvent(UIEvent.SHOW_GENERAL_INFO,true,{"armyInfo":this._currentIcon.armyInfo}));
         }
      }
      
      private function onCloseBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
      
      override public function initData(param1:Object) : void
      {
         this._currentLabel = 1;
         this._roleModel = param1.roleModel;
         this._army = param1.army;
         this.setLabel();
         this._currentPage = 1;
         this.flush();
      }
      
      public function flush() : *
      {
         var _loc1_:* = undefined;
         var _loc2_:* = undefined;
         this.__moneyTF.text = this._roleModel.money.toString();
         this.__exploitTF.text = this._roleModel.exploit.toString();
         var _loc3_:Array = [];
         for(_loc1_ in this._army)
         {
            if(this._currentLabel != 0)
            {
               if(this._army[_loc1_].type == this._currentLabel)
               {
                  _loc3_.push(this._army[_loc1_]);
               }
            }
            else if(this._army[_loc1_].type == this._currentLabel || this._army[_loc1_].type == Type.JUNZHU)
            {
               _loc3_.push(this._army[_loc1_]);
            }
         }
         if(_loc3_.length == 0)
         {
            this._maxPage = 1;
         }
         else
         {
            this._maxPage = _loc3_.length % 10 == 0 ? int(_loc3_.length / 10) : int(_loc3_.length / 10) + 1;
         }
         this.__pageTF.text = this._currentPage + "/" + this._maxPage;
         if(this._currentPage == 1)
         {
            Tools.setDisabled(this.__preBtn,true);
         }
         else
         {
            Tools.setDisabled(this.__preBtn,false);
         }
         if(this._currentPage == this._maxPage)
         {
            Tools.setDisabled(this.__nextBtn,true);
         }
         else
         {
            Tools.setDisabled(this.__nextBtn,false);
         }
         for(_loc2_ in this._iconArr)
         {
            this._iconArr[_loc2_].clear();
         }
         if(_loc3_.length == 0)
         {
            return;
         }
         _loc3_.sort(this.sortRule);
         var _loc5_:int;
         var _loc4_:int;
         if((_loc5_ = (_loc4_ = (this._currentPage - 1) * 10) + 10) > _loc3_.length)
         {
            _loc5_ = int(_loc3_.length);
         }
         var _loc6_:int = 0;
         var _loc7_:int = _loc4_;
         while(_loc7_ < _loc5_)
         {
            this._iconArr[_loc6_].initData(_loc3_[_loc7_]);
            _loc6_++;
            _loc7_++;
         }
      }
      
      private function sortRule(param1:ArmyInfo, param2:ArmyInfo) : *
      {
         if(param1.title < param2.title)
         {
            return -1;
         }
         if(param1.title > param2.title)
         {
            return 1;
         }
         if(param1.level > param2.level)
         {
            return -1;
         }
         if(param1.level < param2.level)
         {
            return 1;
         }
         return 0;
      }
      
      private function setLabel() : *
      {
         this.__btn1.gotoAndStop(1);
         this.__btn2.gotoAndStop(1);
         this.__btn3.gotoAndStop(1);
         this.__btn4.gotoAndStop(1);
         this.__btn5.gotoAndStop(1);
         this.__btn6.gotoAndStop(1);
         this.__btn7.gotoAndStop(1);
         this.__btn8.gotoAndStop(1);
         this.__btn9.gotoAndStop(1);
         this.__btn10.gotoAndStop(1);
         this.__btn0.gotoAndStop(1);
         this._currentPage = 1;
         this["__btn" + this._currentLabel].gotoAndStop(2);
      }
      
      private function btn1ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._currentLabel = 1;
         this.setLabel();
         this.flush();
      }
      
      private function btn2ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._currentLabel = 2;
         this.setLabel();
         this.flush();
      }
      
      private function btn3ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._currentLabel = 3;
         this.setLabel();
         this.flush();
      }
      
      private function btn4ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._currentLabel = 4;
         this.setLabel();
         this.flush();
      }
      
      private function btn5ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._currentLabel = 5;
         this.setLabel();
         this.flush();
      }
      
      private function btn6ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._currentLabel = 6;
         this.setLabel();
         this.flush();
      }
      
      private function btn7ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._currentLabel = 7;
         this.setLabel();
         this.flush();
      }
      
      private function btn8ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._currentLabel = 8;
         this.setLabel();
         this.flush();
      }
      
      private function btn9ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._currentLabel = 9;
         this.setLabel();
         this.flush();
      }
      
      private function btn10ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._currentLabel = 10;
         this.setLabel();
         this.flush();
      }
      
      private function btn0ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._currentLabel = 0;
         this.setLabel();
         this.flush();
      }
   }
}
