package game.ui
{
   import com.iflashigame.net.ChatManager;
   import com.iflashigame.talk.FaceList;
   import com.iflashigame.talk.NetInfoType;
   import com.iflashigame.talk.TalkEvent;
   import com.iflashigame.talk.TalkField;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.ui.Paomadeng;
   import com.iflashigame.ui.TipsFrame;
   import com.iflashigame.utils.TextFilter;
   import fl.controls.CheckBox;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.utils.getTimer;
   import game.Config;
   import game.events.UIEvent;
   import game.model.RoleModel;
   import game.model.RoleStatus;
   import game.ui.list.ListItem;
   import game.ui.list.MyList;
   import game.ui.list.ScrollBar;
   import game.ui.OnlineCountUI;
   
   public class GameCenterUI extends BaseUI
   {
      
      private static const MAX_LINE:int = 30;
       
      
      private var __roleImage:MovieClip;
      
      private var __nickNameTF:TextField;
      
      private var __roleInfoTF:TextField;
      
      private var __paihangBtn:SimpleButton;
      
      private var __shopBtn:SimpleButton;
      
      private var __exitBtn:SimpleButton;
      
      private var __showAllBtn:MovieClip;
      
      private var __showFreeBtn:MovieClip;
      
      private var __defuseCheckBox:CheckBox;
      
      private var _userList:MyList;
      
      private var _scrollBar:ScrollBar;
      
      private var __requestBtn:SimpleButton;
      
      private var __autoRequestBtn:SimpleButton;
      
      private var __talkInputTF:TextField;
      
      private var __sendBtn:SimpleButton;
      
      private var __faceBtn:SimpleButton;
      
      private var _talkField:TalkField;
      
      private var _talkScrollBar:ScrollBar;
      
      private var _faceList:FaceList;
      
      private var _talkArr:Array;
      
      private var __switchBtn:MovieClip;
      
      private var _talkChannel:int = 1;
      
      private var _sysNotesColor:String = "#ff0000";
      
      private var _sysTipsColor:String = "#66ffcc";
      
      private var _personalTipsColor:String = "#9999FF";
      
      private var _screenColor:String = "#ffff66";
      
      private var _worldColor:String = "#00ff00";
      
      private var _mapColor:String = "#33ccff";
      
      private var _personalColor:String = "#ff9999";
      
      private var _labaColor:String = "#ffff00";
      
      private var _zhuangbeiColor:String = "#FF6633";
      
      private var _petsColor:String = "#A34ED6";
      
      private var _errorColor:String = "#99cccc";
      
      private var _roleModel:RoleModel;
      
      private var _arr:Array;
      
      private var _showFree:Boolean;
      
      private var _paomadeng:Paomadeng;
      
      private var _oldTime:int;
      private var _onlineCountUI:OnlineCountUI;
      
      public function GameCenterUI(param1:String, param2:ApplicationDomain = null)
      {
         this._talkArr = [];
         this._oldTime = getTimer();
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__roleImage = _skin.getChildByName("_roleImage") as MovieClip;
         this.__nickNameTF = _skin.getChildByName("_nickNameTF") as TextField;
         this.__roleInfoTF = _skin.getChildByName("_roleInfoTF") as TextField;
         this.__paihangBtn = _skin.getChildByName("_paihangBtn") as SimpleButton;
         this.__shopBtn = _skin.getChildByName("_shopBtn") as SimpleButton;
         this.__exitBtn = _skin.getChildByName("_exitBtn") as SimpleButton;
         this.__showAllBtn = _skin.getChildByName("_showAllBtn") as MovieClip;
         this.__showFreeBtn = _skin.getChildByName("_showFreeBtn") as MovieClip;
         this.__showAllBtn.buttonMode = true;
         this.__showFreeBtn.buttonMode = true;
         this.__switchBtn = _skin.getChildByName("_switchBtn") as MovieClip;
         this.__switchBtn.buttonMode = true;
         this.__defuseCheckBox = _skin.getChildByName("_defuseCheckBox") as CheckBox;
         this.__defuseCheckBox.buttonMode = true;
         this.__requestBtn = _skin.getChildByName("_requestBtn") as SimpleButton;
         this.__autoRequestBtn = _skin.getChildByName("_autoRequestBtn") as SimpleButton;
         this.__talkInputTF = _skin.getChildByName("_talkInputTF") as TextField;
         this.__talkInputTF.restrict = "^[]<>\'\"|#　";
         this.__talkInputTF.text = "";
         this.__sendBtn = _skin.getChildByName("_sendBtn") as SimpleButton;
         this.__faceBtn = _skin.getChildByName("_faceBtn") as SimpleButton;
         this.__defuseCheckBox.selected = false;
         this._userList = new MyList(542,168);
         this._userList.x = -211;
         this._userList.y = -169;
         addChild(this._userList);
         this._scrollBar = new ScrollBar(SkinCode.SCROLL_BAR);
         this._scrollBar.x = 351;
         this._scrollBar.y = -173;
         addChild(this._scrollBar);
         this._scrollBar.target = this._userList;
         this.showAll(true);
         this._talkField = new TalkField(580,118);
         this._talkField.x = -225;
         this._talkField.y = 79;
         addChild(this._talkField);
         this._talkScrollBar = new ScrollBar(SkinCode.SCROLL_BAR);
         this._talkScrollBar.x = this._talkField.x + this._talkField.width - 8;
         this._talkScrollBar.y = this._talkField.y;
         this._talkScrollBar.scaleY = 0.7;
         addChild(this._talkScrollBar);
         this._talkScrollBar.target = this._talkField;
         this._faceList = new FaceList(53);
         this._faceList.x = this.__faceBtn.x + this.__faceBtn.width / 2 - this._faceList.width;
         this._faceList.y = this.__faceBtn.y - this._faceList.height - this.__faceBtn.height / 2;
         addChild(this._faceList);
         this._faceList.visible = false;
         this._onlineCountUI = new OnlineCountUI();
         this._onlineCountUI.x = -211;
         this._onlineCountUI.y = -200;
         addChild(this._onlineCountUI);
      }
      
      private function showAll(param1:Boolean) : *
      {
         if(param1 == true)
         {
            this._showFree = false;
            this.__showAllBtn.gotoAndStop(1);
            this.__showFreeBtn.gotoAndStop(2);
         }
         else
         {
            this._showFree = true;
            this.__showAllBtn.gotoAndStop(2);
            this.__showFreeBtn.gotoAndStop(1);
         }
      }
      
      override protected function initEvent() : void
      {
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
         this.__paihangBtn.addEventListener(MouseEvent.CLICK,this.paihangBtnClickHandler);
         this.__shopBtn.addEventListener(MouseEvent.CLICK,this.shopBtnClickHandler);
         this.__exitBtn.addEventListener(MouseEvent.CLICK,this.exitBtnClickHandler);
         this.__showAllBtn.addEventListener(MouseEvent.CLICK,this.showAllBtnClickHandler);
         this.__showFreeBtn.addEventListener(MouseEvent.CLICK,this.showFreeBtnClickHandler);
         this.__defuseCheckBox.addEventListener(MouseEvent.CLICK,this.defuseCheckBoxClickHandler);
         this.__requestBtn.addEventListener(MouseEvent.CLICK,this.requestBtnClickHandler);
         this.__autoRequestBtn.addEventListener(MouseEvent.CLICK,this.autoRequestBtnClickHandler);
         this.__sendBtn.addEventListener(MouseEvent.CLICK,this.sendBtnClickHandler);
         this.__faceBtn.addEventListener(MouseEvent.CLICK,this.faceBtnClickHandler);
         this.__talkInputTF.addEventListener(KeyboardEvent.KEY_DOWN,this.onTalkInputKeyDownHandler);
         this._faceList.addEventListener(MouseEvent.CLICK,this.onFaceListClickHandler);
         this._talkField.addEventListener(TextEvent.LINK,this.onTalkFieldClickHandler);
         this.__switchBtn.addEventListener(MouseEvent.CLICK,this.switchBtnMouseClickHandler);
      }
      
      private function switchBtnMouseClickHandler(param1:MouseEvent) : void
      {
         if(this.__switchBtn.currentFrame == 1)
         {
            this.__switchBtn.gotoAndStop(2);
            this._talkChannel = 2;
         }
         else
         {
            this.__switchBtn.gotoAndStop(1);
            this._talkChannel = 1;
         }
      }
      
      public function setRole(param1:RoleModel) : *
      {
         this._roleModel = param1;
         this.__nickNameTF.text = this._roleModel.roleName;
         var _loc2_:* = "编号:" + this._roleModel.roleID + "\n";
         _loc2_ += "等级:" + this._roleModel.level + "\n";
         _loc2_ += "战斗场次:" + this._roleModel.fightCount + "\n";
         _loc2_ += "获胜场次:" + this._roleModel.winCount + "\n";
         _loc2_ += "积分:" + this._roleModel.score;
         this.__roleInfoTF.text = _loc2_;
         this.setImage(this._roleModel.imageID);
      }
      
      private function setImage(param1:int) : *
      {
         var _loc2_:Class = ApplicationDomain.currentDomain.getDefinition("image" + param1) as Class;
         var _loc3_:MovieClip = new _loc2_() as MovieClip;
         _loc3_.x = (this.__roleImage.width - _loc3_.width) / 2;
         _loc3_.y = (this.__roleImage.height - _loc3_.height) / 2;
         this.__roleImage.addChild(_loc3_);
      }
      
      public function setList(param1:Array) : *
      {
         this._arr = param1;
         this._userList.initData(this._arr,this._showFree);
      }
      
      public function addListItem(param1:Object) : *
      {
         this._userList.addItem(param1,this._showFree);
      }
      
      public function removeListItem(param1:String) : *
      {
         this._userList.removeItem(param1);
      }
      
      public function setArea(param1:String) : *
      {
         this._talkArr.push(param1);
         this._talkField.setMultiText(this._talkArr);
      }
      
      public function changeStatus(param1:Object) : *
      {
         this._userList.changeStatus(param1);
      }
      
      private function paihangBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.PAIHANG_CLICK,true));
      }
      
      private function shopBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_SHOP,true));
      }
      
      private function exitBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.EXIT_GAMECENTER,true));
      }
      
      private function showAllBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.showAll(true);
         this._userList.initData(this._arr,this._showFree);
      }
      
      private function showFreeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.showAll(false);
         this._userList.initData(this._arr,this._showFree);
      }
      
      private function defuseCheckBoxClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this.__defuseCheckBox.selected == true)
         {
            this._roleModel.status = RoleStatus.XIUZHAN;
         }
         else
         {
            this._roleModel.status = RoleStatus.NOMAL;
         }
         dispatchEvent(new UIEvent(UIEvent.CHANGE_STATUS));
      }
      
      private function requestBtnClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:ListItem = null;
         param1.stopImmediatePropagation();
         if(RoleModel.getInstance().status != RoleStatus.XIUZHAN)
         {
            _loc2_ = this._userList.item;
            if(_loc2_ == null)
            {
               return;
            }
            if(_loc2_.getStatus() == RoleStatus.NOMAL)
            {
               dispatchEvent(new UIEvent(UIEvent.FIGHT_REQUEST,true,{
                  "pID":_loc2_.pID,
                  "area":_loc2_.getArea(),
                  "name":_loc2_.getName(),
                  "level":_loc2_.getLevel(),
                  "image":_loc2_.getImage(),
                  "channel":"area"
               }));
            }
         }
      }
      
      private function autoRequestBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(RoleModel.getInstance().status != RoleStatus.NOMAL)
         {
            return;
         }
         var _loc2_:ListItem = this._userList.getItemByLevel(RoleModel.getInstance().level);
         if(_loc2_ != null)
         {
            dispatchEvent(new UIEvent(UIEvent.FIGHT_REQUEST,true,{
               "pID":_loc2_.pID,
               "area":_loc2_.getArea(),
               "name":_loc2_.getName(),
               "level":_loc2_.getLevel(),
               "image":_loc2_.getImage(),
               "channel":"area"
            }));
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有找到匹配的玩家。"
            }));
         }
      }
      
      private function sendBtnClickHandler(param1:MouseEvent) : *
      {
         var _loc6_:* = undefined;
         var _loc2_:String = null;
         if(param1 != null)
         {
            param1.stopImmediatePropagation();
         }
         if(this.__talkInputTF.text == "")
         {
            return;
         }
         this.__talkInputTF.text = this.__talkInputTF.text.replace("\r","");
         var _loc3_:RegExp = /^\/(\S)+\s/;
         this.__talkInputTF.text = TextFilter.getInstance().replaceText(this.__talkInputTF.text);
         var _loc4_:String = this.__talkInputTF.text;
         var _loc5_:Array;
         if((_loc5_ = _loc3_.exec(_loc4_)) != null)
         {
            _loc2_ = String(_loc5_[0].substring(1,_loc5_[0].length - 1));
            _loc6_ = _loc2_;
            var _loc7_:int = 0;
            switch(0)
            {
            }
            this.sendPrivate(_loc2_);
            this.__talkInputTF.text = _loc5_[0];
            this.__talkInputTF.setSelection(this.__talkInputTF.length,this.__talkInputTF.length);
         }
         else
         {
            if(this._talkChannel == 1)
            {
               this.sendArea();
            }
            else
            {
               this.sendWorld();
            }
            this.__talkInputTF.text = "";
         }
         this._faceList.visible = false;
      }
      
      private function faceBtnClickHandler(param1:MouseEvent) : *
      {
         if(this._faceList.visible == true)
         {
            this._faceList.visible = false;
         }
         else
         {
            this._faceList.visible = true;
         }
      }
      
      private function onTalkInputKeyDownHandler(param1:KeyboardEvent) : *
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.sendBtnClickHandler(null);
         }
      }
      
      private function onRemoveFromStageHandler(param1:Event) : *
      {
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
         if(this._onlineCountUI != null)
         {
            this._onlineCountUI.stopPolling();
            this._onlineCountUI = null;
         }
         this._arr = null;
         this._roleModel = null;
      }
      
      private function talk(param1:String) : *
      {
      }
      
      public function setPaomadeng(param1:Array) : *
      {
         if(this._paomadeng != null)
         {
            removeChild(this._paomadeng);
            this._paomadeng = null;
         }
         this._paomadeng = new Paomadeng(param1,245,18,1,16750848);
         this._paomadeng.x = -3;
         this._paomadeng.y = -230;
         addChild(this._paomadeng);
         this._paomadeng.start();
      }
      
      private function checkLines() : *
      {
         if(this._talkArr.length > MAX_LINE)
         {
            this._talkArr.shift();
         }
      }
      
      private function sendArea() : *
      {
         var _loc1_:* = null;
         var _loc2_:int = getTimer();
         if(_loc2_ - this._oldTime < Config.AREATALK_DELAY)
         {
            _loc1_ = "<font color=\'" + this._errorColor + "\'>你说话太快了，请稍后再发送。\n</font>";
            this._talkArr.push(_loc1_);
            this._talkField.setMultiText(this._talkArr);
            this.checkLines();
            return;
         }
         this._oldTime = _loc2_;
         var _loc3_:* = "<font color=\'" + this._mapColor + "\'>";
         var _loc4_:String = "</font>";
         var _loc5_:String = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = "0|") + (RoleModel.getInstance().roleName + "|")) + (RoleModel.getInstance().roleID + "|")) + (ChatManager.getInstance().peerID + "|")) + (RoleModel.getInstance().imageID + "|")) + (RoleModel.getInstance().level + "|")) + (RoleModel.getInstance().agent + "|")) + (RoleModel.getInstance().status + "|")) + RoleModel.getInstance().loginServer;
         _loc1_ = _loc3_ + "【当前】<a href=\'event:" + _loc5_ + "\'>[" + RoleModel.getInstance().roleName + "]</a>" + _loc4_ + "说：" + this.__talkInputTF.text + "\n";
         this._talkArr.push(_loc1_);
         this._talkField.setMultiText(this._talkArr);
         this.checkLines();
         dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
            "type":NetInfoType.PUBLIC,
            "text":_loc1_
         }));
      }
      
      private function sendWorld() : *
      {
         var _loc1_:* = null;
         var _loc2_:int = getTimer();
         if(_loc2_ - this._oldTime < Config.WORLDTALK_DELAY)
         {
            _loc1_ = "<font color=\'" + this._errorColor + "\'>你说话太快了，请稍后再发送。\n</font>";
            this._talkArr.push(_loc1_);
            this._talkField.setMultiText(this._talkArr);
            this.checkLines();
            return;
         }
         this._oldTime = _loc2_;
         if(RoleModel.getInstance().money < Config.WORLDTALK_MONEY)
         {
            _loc1_ = "<font color=\'" + this._errorColor + "\'>银子余额不足，无法发言。\n</font>";
            this._talkArr.push(_loc1_);
            this._talkField.setMultiText(this._talkArr);
            this.checkLines();
            return;
         }
         RoleModel.getInstance().money = RoleModel.getInstance().money - Config.WORLDTALK_MONEY;
         dispatchEvent(new UIEvent(UIEvent.OPEN_BAOCUN,true));
         var _loc3_:* = "<font color=\'" + this._worldColor + "\'>";
         var _loc4_:String = "</font>";
         var _loc5_:String = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = "0|") + (RoleModel.getInstance().roleName + "|")) + (RoleModel.getInstance().roleID + "|")) + (ChatManager.getInstance().peerID + "|")) + (RoleModel.getInstance().imageID + "|")) + (RoleModel.getInstance().level + "|")) + (RoleModel.getInstance().agent + "|")) + (RoleModel.getInstance().status + "|")) + RoleModel.getInstance().loginServer;
         _loc1_ = _loc3_ + "【世界】<a href=\'event:" + _loc5_ + "\'>[" + RoleModel.getInstance().roleName + "]</a>" + _loc4_ + "说：" + this.__talkInputTF.text + "\n";
         this._talkArr.push(_loc1_);
         this._talkField.setMultiText(this._talkArr);
         this.checkLines();
         dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
            "type":NetInfoType.WORLD,
            "text":_loc1_
         }));
      }
      
      private function sendPrivate(param1:String) : *
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:* = undefined;
         var _loc8_:int;
         if((_loc8_ = getTimer()) - this._oldTime < Config.PRIVATETALK_DELAY)
         {
            _loc2_ = "<font color=\'" + this._errorColor + "\'>你发言的频率太快了\n</font>";
            this._talkArr.push(_loc2_);
            this._talkField.setMultiText(this._talkArr);
            this.checkLines();
            return;
         }
         this._oldTime = _loc8_;
         if(param1 == RoleModel.getInstance().roleName)
         {
            _loc2_ = "<font color=\'" + this._errorColor + "\'>错误，你不能跟自己私聊\n</font>";
            this._talkArr.push(_loc2_);
            this._talkField.setMultiText(this._talkArr);
            this.checkLines();
         }
         else
         {
            _loc3_ = "<font color=\'" + this._personalColor + "\'>";
            _loc4_ = "</font>";
            if((_loc5_ = this.__talkInputTF.text.substring(2 + param1.length)) == "")
            {
               return;
            }
            _loc2_ = _loc3_ + "【私聊】" + _loc4_ + "你对" + _loc3_ + "[" + param1 + "]" + _loc4_ + "说：" + _loc5_ + "\n";
            this._talkArr.push(_loc2_);
            this._talkField.setMultiText(this._talkArr);
            this.checkLines();
            _loc6_ = (_loc6_ = (_loc6_ = (_loc6_ = (_loc6_ = (_loc6_ = (_loc6_ = (_loc6_ = (_loc6_ = "0|") + (RoleModel.getInstance().roleName + "|")) + (RoleModel.getInstance().roleID + "|")) + (ChatManager.getInstance().peerID + "|")) + (RoleModel.getInstance().imageID + "|")) + (RoleModel.getInstance().level + "|")) + (RoleModel.getInstance().agent + "|")) + (RoleModel.getInstance().status + "|")) + RoleModel.getInstance().loginServer;
            _loc7_ = _loc3_ + "【私聊】<a href=\'event:" + _loc6_ + "\'>[" + RoleModel.getInstance().roleName + "]</a>" + _loc4_ + "对你说：" + _loc5_ + "\n";
            dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
               "type":NetInfoType.PRIVATE,
               "text":_loc7_,
               "toName":param1
            }));
         }
      }
      
      private function onFaceListClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this.__talkInputTF.length >= this.__talkInputTF.maxChars - 1)
         {
            return;
         }
         if(param1.target.name.indexOf("face") == -1)
         {
            return;
         }
         var _loc2_:String = "*" + param1.target.name.substring(4);
         this.__talkInputTF.replaceText(this.__talkInputTF.caretIndex,this.__talkInputTF.caretIndex,_loc2_);
         var _loc3_:int = this.__talkInputTF.caretIndex + _loc2_.length;
         this.__talkInputTF.setSelection(_loc3_,_loc3_);
         this._faceList.visible = false;
         stage.focus = this.__talkInputTF;
      }
      
      private function onTalkFieldClickHandler(param1:TextEvent) : *
      {
         var _loc2_:String = null;
         var _loc3_:* = null;
         param1.stopImmediatePropagation();
         var _loc4_:Array;
         var _loc5_:String = String((_loc4_ = param1.text.split("|"))[0]);
         _loc2_ = String(_loc4_[1]);
         var _loc6_:Number = Number(_loc4_[2]);
         var _loc7_:String = String(_loc4_[3]);
         var _loc8_:int = int(_loc4_[4]);
         var _loc9_:int = int(_loc4_[5]);
         var _loc10_:String = String(_loc4_[6]);
         var _loc11_:int = int(_loc4_[7]);
         var _loc12_:int = int(_loc4_[8]);
         switch(_loc5_)
         {
            case "0":
               _loc3_ = "<a href=\'event:talk|" + _loc2_ + "\'>私聊</a>\n<a href=\'event:fight|";
               _loc3_ += _loc2_ + "|";
               _loc3_ += _loc6_ + "|";
               _loc3_ += _loc7_ + "|";
               _loc3_ += _loc8_ + "|";
               _loc3_ += _loc9_ + "|";
               _loc3_ += _loc10_ + "|";
               _loc3_ += _loc11_ + "|";
               _loc3_ += _loc12_;
               _loc3_ += "\'>挑战</a>\n";
               _loc3_ += "<a href=\'event:friend\'>好友</a>";
               this.showMenu(_loc3_);
               break;
            case "1":
            case "2":
         }
      }
      
      private function showMenu(param1:String) : *
      {
         var _loc2_:TipsFrame = new TipsFrame();
         _loc2_.initData({
            "htmlText":param1,
            "width":60,
            "height":50,
            "focus":true
         });
         _loc2_.x = mouseX;
         _loc2_.y = mouseY;
         addChild(_loc2_);
         stage.focus = _loc2_;
         _loc2_.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,this.onMenuFocusChangeHandler);
         _loc2_.addEventListener(TextEvent.LINK,this.onMenuClickHandler);
      }
      
      private function onMenuClickHandler(param1:TextEvent) : *
      {
         param1.stopImmediatePropagation();
         param1.currentTarget.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,this.onMenuFocusChangeHandler);
         param1.currentTarget.removeEventListener(TextEvent.LINK,this.onMenuClickHandler);
         removeChild(param1.currentTarget as TipsFrame);
         var _loc2_:Array = param1.text.split("|");
         if(_loc2_ != null)
         {
            switch(_loc2_[0])
            {
               case "talk":
                  this.setNickName(_loc2_[1]);
                  break;
               case "fight":
                  if(_loc2_[3] == ChatManager.getInstance().peerID || Number(_loc2_[2]) == RoleModel.getInstance().roleID)
                  {
                     dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                        "type":0,
                        "text":"你不能向自己发起挑战！"
                     }));
                  }
                  else if(int(_loc2_[8]) == RoleModel.getInstance().loginServer)
                  {
                     trace("同区挑战");
                     dispatchEvent(new UIEvent(UIEvent.FIGHT_REQUEST,true,{
                        "pID":_loc2_[3],
                        "area":_loc2_[6],
                        "name":_loc2_[1],
                        "level":int(_loc2_[5]),
                        "image":int(_loc2_[4]),
                        "channel":"area"
                     }));
                  }
                  else
                  {
                     trace("跨区挑战");
                     dispatchEvent(new UIEvent(UIEvent.FIGHT_REQUEST,true,{
                        "pID":_loc2_[3],
                        "area":_loc2_[6],
                        "name":_loc2_[1],
                        "level":int(_loc2_[5]),
                        "image":int(_loc2_[4]),
                        "channel":"world"
                     }));
                  }
                  break;
               case "friend":
                  dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                     "type":0,
                     "text":"好友功能暂未开启,请关注官方信息。"
                  }));
            }
         }
      }
      
      private function onMenuFocusChangeHandler(param1:FocusEvent) : *
      {
         var _loc2_:TipsFrame = param1.currentTarget as TipsFrame;
         if(!_loc2_.contains(param1.relatedObject as DisplayObject))
         {
            param1.currentTarget.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,this.onMenuFocusChangeHandler);
            param1.currentTarget.removeEventListener(TextEvent.LINK,this.onMenuClickHandler);
            removeChild(param1.currentTarget as TipsFrame);
         }
      }
      
      private function setNickName(param1:String) : *
      {
         var _loc2_:RegExp = /^\/(\S)+\s/;
         this.__talkInputTF.text = this.__talkInputTF.text.replace(_loc2_,"");
         this.__talkInputTF.text = "/" + param1 + " " + this.__talkInputTF.text;
         this.__talkInputTF.setSelection(this.__talkInputTF.length,this.__talkInputTF.length);
         stage.focus = this.__talkInputTF;
      }
   }
}
