package game.ui
{
   import com.iflashigame.controller.AESController;
   import com.iflashigame.net.ChatManager;
   import com.iflashigame.talk.FaceList;
   import com.iflashigame.talk.NetInfoType;
   import com.iflashigame.talk.TalkEvent;
   import com.iflashigame.talk.TalkField;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.ui.TipsFrame;
   import com.iflashigame.utils.TextFilter;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.events.TimerEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import game.Config;
   import game.events.UIEvent;
   import game.model.Head;
   import game.model.RoleModel;
   import game.ui.list.ScrollBar;
   
   public class TalkArea extends BaseUI
   {
      
      private static const WORLD_MAX_LINE:int = 30;
      
      private static const PRIVATE_MAX_LINE:int = 10;
       
      
      private var __talkInputTF:TextField;
      
      private var __faceBtn:SimpleButton;
      
      private var __sendBtn:SimpleButton;
      
      private var __labaBtn:SimpleButton;
      
      private var __worldChannelBtn:MovieClip;
      
      private var __privateChannelBtn:MovieClip;
      
      private var __switchBtn:MovieClip;
      
      private var _talkChannel:int = 2;
      
      private var _allArr:Array;
      
      private var _privateArr:Array;
      
      private var _labaArr:Array;
      
      private var _labaTimer:Timer;
      
      private var __minBtn:SimpleButton;
      
      private var __bk:MovieClip;
      
      private var _talkField:TalkField;
      
      private var _scrollBar:ScrollBar;
      
      private var _labaField:TalkField;
      
      private var _faceList:FaceList;
      
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
      
      private var _currentChannel:int;
      
      private var _oldTime:int;
      
      public function TalkArea(param1:String, param2:ApplicationDomain = null)
      {
         this._allArr = [];
         this._privateArr = [];
         this._labaArr = [];
         this._labaTimer = new Timer(10000);
         this._oldTime = getTimer();
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__talkInputTF = _skin.getChildByName("_talkInputTF") as TextField;
         this.__faceBtn = _skin.getChildByName("_faceBtn") as SimpleButton;
         this.__sendBtn = _skin.getChildByName("_sendBtn") as SimpleButton;
         this.__labaBtn = _skin.getChildByName("_labaBtn") as SimpleButton;
         this.__worldChannelBtn = _skin.getChildByName("_worldChannelBtn") as MovieClip;
         this.__privateChannelBtn = _skin.getChildByName("_privateChannelBtn") as MovieClip;
         this.__minBtn = _skin.getChildByName("_minBtn") as SimpleButton;
         this.__bk = _skin.getChildByName("_bk") as MovieClip;
         this.__switchBtn = _skin.getChildByName("_switchBtn") as MovieClip;
         this.__worldChannelBtn.buttonMode = true;
         this.__privateChannelBtn.buttonMode = true;
         this.__switchBtn.gotoAndStop(2);
         this.__switchBtn.buttonMode = false;
         this._talkField = new TalkField(this.__bk.width - 15,this.__bk.height - 8);
         this._talkField.x = this.__bk.x + 15;
         this._talkField.y = this.__bk.y + 4;
         addChild(this._talkField);
         this._labaField = new TalkField(this.__bk.width - 10,40,null,0,16777215,0.3);
         this._labaField.x = this.__bk.x + 5;
         this._labaField.y = this.__bk.y - 74;
         addChild(this._labaField);
         this._labaField.mouseChildren = false;
         this._labaField.mouseEnabled = false;
         this._labaField.visible = false;
         this._scrollBar = new ScrollBar(SkinCode.SCROLL_BAR);
         this._scrollBar.scaleY = 0.7;
         this._scrollBar.y = this.__bk.y;
         this._scrollBar.x = 8;
         addChild(this._scrollBar);
         this._scrollBar.target = this._talkField;
         this._faceList = new FaceList(53);
         this._faceList.x = this.__faceBtn.x - this._faceList.width / 2;
         this._faceList.y = this.__faceBtn.y - this._faceList.height - this.__faceBtn.height / 2;
         addChild(this._faceList);
         this._faceList.visible = false;
         this.__talkInputTF.restrict = "^[]<>\'\"|#　";
         this.__talkInputTF.text = "";
         this.__worldChannelBtn.gotoAndStop(1);
         this.__worldChannelBtn.visible = true;
         this.__privateChannelBtn.visible = false;
         this._currentChannel = 1;
         // 显示全服通告(装备掉落等实时消息)
         var _pa:Array = RoleModel.getInstance().pendingAnnouncements;
         if(_pa && _pa.length > 0) {
            for(var _pai:int = 0; _pai < _pa.length; _pai++) {
               var _pao:Object = _pa[_pai];
               var _pat:String = new Date(_pao.time).toLocaleTimeString();
               var _pam:String = _pao.msg as String;
               this._allArr.push("<font color='#00ff00'>【世界】</font><font color='#ff0000'>[通告][" + _pat + "]：" + _pam + "</font>\n");
            }
            this._talkField.setMultiText(this._allArr);
            RoleModel.getInstance().pendingAnnouncements = null;
         }
      }
      
      override protected function initEvent() : void
      {
         this.__faceBtn.addEventListener(MouseEvent.CLICK,this.faceBtnClickHandler);
         this.__faceBtn.addEventListener(MouseEvent.MOUSE_OVER,this.faceBtnMouseOverHandler);
         this.__faceBtn.addEventListener(MouseEvent.MOUSE_OUT,this.faceBtnMouseOutHandler);
         this.__sendBtn.addEventListener(MouseEvent.CLICK,this.sendBtnClickHandler);
         this.__sendBtn.addEventListener(MouseEvent.MOUSE_OVER,this.sendBtnMouseOverHandler);
         this.__sendBtn.addEventListener(MouseEvent.MOUSE_OUT,this.sendBtnMouseOutHandler);
         this.__labaBtn.addEventListener(MouseEvent.CLICK,this.labaBtnClickHandler);
         this.__labaBtn.addEventListener(MouseEvent.MOUSE_OVER,this.labaBtnMouseOverHandler);
         this.__labaBtn.addEventListener(MouseEvent.MOUSE_OUT,this.labaBtnMouseOutHandler);
         this.__worldChannelBtn.addEventListener(MouseEvent.CLICK,this.worldChannelBtnClickHandler);
         this.__privateChannelBtn.addEventListener(MouseEvent.CLICK,this.privateChannelBtnClickHandler);
         this.__minBtn.addEventListener(MouseEvent.CLICK,this.minBtnClickHandler);
         this.__minBtn.addEventListener(MouseEvent.MOUSE_OVER,this.minBtnMouseOverHandler);
         this.__minBtn.addEventListener(MouseEvent.MOUSE_OUT,this.minBtnMouseOutHandler);
         this.__talkInputTF.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeydownHandler);
         this._faceList.addEventListener(MouseEvent.CLICK,this.onFaceListClickHandler);
         this._talkField.addEventListener(TextEvent.LINK,this.onTalkFieldClickHandler);
         this._labaTimer.addEventListener(TimerEvent.TIMER,this.onLabaTimerHandler);
         addEventListener(Event.REMOVED_FROM_STAGE,this.removeFromStageHandler);
      }
      
      private function switchBtnMouseOverHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
            "htmlText":"切换频道",
            "width":60,
            "height":18,
            "type":1
         }));
      }
      
      private function switchBtnMouseOutHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
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
      
      private function removeFromStageHandler(param1:Event) : *
      {
         this._labaTimer.removeEventListener(TimerEvent.TIMER,this.onLabaTimerHandler);
      }
      
      override public function initData(param1:Object) : void
      {
      }
      
      private function faceBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._faceList.visible == true)
         {
            this._faceList.visible = false;
         }
         else
         {
            this._faceList.visible = true;
         }
      }
      
      private function faceBtnMouseOverHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
            "htmlText":"聊天表情",
            "width":60,
            "height":18,
            "type":1
         }));
      }
      
      private function faceBtnMouseOutHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
      }
      
      private function onKeydownHandler(param1:KeyboardEvent) : *
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.sendBtnClickHandler(null);
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
      
      private function sendBtnMouseOverHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
            "htmlText":"发送聊天",
            "width":60,
            "height":18,
            "type":1
         }));
      }
      
      private function sendBtnMouseOutHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
      }
      
      private function labaBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this.__talkInputTF.text == "")
         {
            return;
         }
         if(RoleModel.getInstance().getBagItemCount("proto_3_1") <= 0)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"背包中没有小喇叭，您可以在商城中购买。"
            }));
         }
         else
         {
            this.sendToHttpNew();
         }
      }
      
      private function sendToHttpNew() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_USE_AMMO;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         _loc1_.id = RoleModel.getInstance().findBagItemID("proto_3_1");
         _loc1_.mask = true;
         AESController.getInstance().sendJSON(_loc1_,this.useItemResponse);
      }
      
      private function useItemResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            RoleModel.getInstance().delBagItem("proto_3_1");
            this.sendLaba();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function labaBtnMouseOverHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
            "htmlText":"小喇叭",
            "width":60,
            "height":18,
            "type":1
         }));
      }
      
      private function labaBtnMouseOutHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
      }
      
      private function worldChannelBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.__worldChannelBtn.gotoAndStop(1);
         this.__privateChannelBtn.gotoAndStop(2);
         this._currentChannel = 1;
         this._talkField.setMultiText(this._allArr);
      }
      
      private function privateChannelBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.__worldChannelBtn.gotoAndStop(2);
         this.__privateChannelBtn.gotoAndStop(1);
         this._currentChannel = 2;
         this._talkField.setMultiText(this._privateArr);
      }
      
      private function minBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._talkField.visible == false)
         {
            this._talkField.visible = true;
            this.__bk.visible = true;
            this._scrollBar.visible = true;
            if(this._labaTimer.running == true)
            {
               this._labaField.visible = true;
            }
         }
         else
         {
            this._talkField.visible = false;
            this.__bk.visible = false;
            this._scrollBar.visible = false;
            this._labaField.visible = false;
         }
      }
      
      private function minBtnMouseOverHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
            "htmlText":"隐藏/显示",
            "width":60,
            "height":18,
            "type":1
         }));
      }
      
      private function minBtnMouseOutHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
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
         trace(_loc2_);
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
            if(this._currentChannel == 1)
            {
               this._allArr.push(_loc2_);
               this._talkField.setMultiText(this._allArr);
            }
            else
            {
               this._privateArr.push(_loc2_);
               this._talkField.setMultiText(this._privateArr);
            }
            this.checkLines();
            return;
         }
         this._oldTime = _loc8_;
         if(param1 == RoleModel.getInstance().roleName)
         {
            _loc2_ = "<font color=\'" + this._errorColor + "\'>错误，你不能跟自己私聊\n</font>";
            if(this._currentChannel == 1)
            {
               this._allArr.push(_loc2_);
               this._talkField.setMultiText(this._allArr);
            }
            else
            {
               this._privateArr.push(_loc2_);
               this._talkField.setMultiText(this._privateArr);
            }
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
            _loc2_ = _loc3_ + "【私聊】你对[" + param1 + "]" + _loc4_ + "说：" + _loc5_ + "\n";
            this._allArr.push(_loc2_);
            this._privateArr.push(_loc2_);
            if(this._currentChannel == 1)
            {
               this._talkField.setMultiText(this._allArr);
            }
            else
            {
               this._talkField.setMultiText(this._privateArr);
            }
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
      
      private function sendArea() : *
      {
         var _loc1_:* = null;
         var _loc2_:int = getTimer();
         if(_loc2_ - this._oldTime < Config.AREATALK_DELAY)
         {
            _loc1_ = "<font color=\'" + this._errorColor + "\'>你说话太快了，请稍后再发送。\n</font>";
            if(this._currentChannel == 1)
            {
               this._allArr.push(_loc1_);
               this._talkField.setMultiText(this._allArr);
            }
            else
            {
               this._privateArr.push(_loc1_);
               this._talkField.setMultiText(this._privateArr);
            }
            this.checkLines();
            return;
         }
         this._oldTime = _loc2_;
         var _loc3_:* = "<font color=\'" + this._mapColor + "\'>";
         var _loc4_:String = "</font>";
         var _loc5_:String = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = "0|") + (RoleModel.getInstance().roleName + "|")) + (RoleModel.getInstance().roleID + "|")) + (ChatManager.getInstance().peerID + "|")) + (RoleModel.getInstance().imageID + "|")) + (RoleModel.getInstance().level + "|")) + (RoleModel.getInstance().agent + "|")) + (RoleModel.getInstance().status + "|")) + RoleModel.getInstance().loginServer;
         _loc1_ = _loc3_ + "【当前】<a href=\'event:" + _loc5_ + "\'>[" + RoleModel.getInstance().roleName + "]</a>" + _loc4_ + "说：" + this.__talkInputTF.text + "\n";
         this._allArr.push(_loc1_);
         if(this._currentChannel == 1)
         {
            this._talkField.setMultiText(this._allArr);
         }
         else
         {
            this._talkField.setMultiText(this._privateArr);
         }
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
            if(this._currentChannel == 1)
            {
               this._allArr.push(_loc1_);
               this._talkField.setMultiText(this._allArr);
            }
            else
            {
               this._privateArr.push(_loc1_);
               this._talkField.setMultiText(this._privateArr);
            }
            this.checkLines();
            return;
         }
         this._oldTime = _loc2_;
         if(RoleModel.getInstance().money < Config.WORLDTALK_MONEY)
         {
            _loc1_ = "<font color=\'" + this._errorColor + "\'>银子余额不足，无法发言。\n</font>";
            if(this._currentChannel == 1)
            {
               this._allArr.push(_loc1_);
               this._talkField.setMultiText(this._allArr);
            }
            else
            {
               this._privateArr.push(_loc1_);
               this._talkField.setMultiText(this._privateArr);
            }
            this.checkLines();
            return;
         }
         RoleModel.getInstance().money = RoleModel.getInstance().money - Config.WORLDTALK_MONEY;
         dispatchEvent(new UIEvent(UIEvent.OPEN_BAOCUN,true));
         var _loc3_:* = "<font color=\'" + this._worldColor + "\'>";
         var _loc4_:String = "</font>";
         var _loc5_:String = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = (_loc5_ = "0|") + (RoleModel.getInstance().roleName + "|")) + (RoleModel.getInstance().roleID + "|")) + (ChatManager.getInstance().peerID + "|")) + (RoleModel.getInstance().imageID + "|")) + (RoleModel.getInstance().level + "|")) + (RoleModel.getInstance().agent + "|")) + (RoleModel.getInstance().status + "|")) + RoleModel.getInstance().loginServer;
         _loc1_ = _loc3_ + "【世界】<a href=\'event:" + _loc5_ + "\'>[" + RoleModel.getInstance().roleName + "]</a>" + _loc4_ + "说：" + this.__talkInputTF.text + "\n";
         this._allArr.push(_loc1_);
         if(this._currentChannel == 1)
         {
            this._talkField.setMultiText(this._allArr);
         }
         else
         {
            this._talkField.setMultiText(this._privateArr);
         }
         this.checkLines();
         dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
            "type":NetInfoType.WORLD,
            "text":_loc1_
         }));
      }
      
      private function checkLines() : *
      {
         if(this._allArr.length > WORLD_MAX_LINE)
         {
            this._allArr.shift();
         }
         if(this._privateArr.length > PRIVATE_MAX_LINE)
         {
            this._privateArr.shift();
         }
      }
      
      public function recieveNetInfo(param1:Object) : *
      {
         if(param1.type == NetInfoType.LABA)
         {
            this.pushLaba(param1.text);
         }
         if(param1.toName != null)
         {
            this._privateArr.push(param1.text);
         }
         this._allArr.push(param1.text);
         if(this._currentChannel == 1)
         {
            this._talkField.setMultiText(this._allArr);
         }
         else
         {
            this._talkField.setMultiText(this._privateArr);
         }
      }
      
      private function pushLaba(param1:String) : *
      {
         this._labaArr.push(param1);
         if(this._labaTimer.running == false)
         {
            if(this._labaArr.length > 0)
            {
               this._labaTimer.start();
               this._labaField.setText(this._labaArr.shift());
            }
         }
         this._labaField.visible = this._talkField.visible;
      }
      
      private function onLabaTimerHandler(param1:TimerEvent) : *
      {
         if(this._labaArr.length > 0)
         {
            this._labaField.setText(this._labaArr.shift());
         }
         else
         {
            this._labaTimer.reset();
            this._labaField.visible = false;
         }
      }
      
      public function sendLaba() : *
      {
         var _loc1_:* = null;
         var _loc2_:String = "0|";
         _loc2_ += RoleModel.getInstance().roleName + "|";
         _loc2_ += RoleModel.getInstance().roleID + "|";
         _loc2_ += ChatManager.getInstance().peerID + "|";
         _loc2_ += RoleModel.getInstance().imageID + "|";
         _loc2_ += RoleModel.getInstance().level + "|";
         _loc2_ += RoleModel.getInstance().agent + "|";
         _loc2_ += RoleModel.getInstance().status + "|";
         _loc2_ += RoleModel.getInstance().loginServer;
         _loc1_ = "<font color=\'" + this._labaColor + "\'>【小喇叭】<a href=\'event:" + _loc2_ + "\'>[" + RoleModel.getInstance().roleName + "]</a></font>说：" + this.__talkInputTF.text + "\n";
         this.pushLaba(_loc1_);
         this._allArr.push(_loc1_);
         this._privateArr.push(_loc1_);
         if(this._currentChannel == 1)
         {
            this._talkField.setMultiText(this._allArr);
         }
         else
         {
            this._talkField.setMultiText(this._privateArr);
         }
         this.checkLines();
         this.__talkInputTF.text = "";
         stage.focus = this.__talkInputTF;
         this._faceList.visible = false;
         dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
            "type":NetInfoType.LABA,
            "text":_loc1_
         }));
      }
   }
}
