package game.ui
{
   import com.iflashigame.controller.AESController;
   import com.iflashigame.net.ChatManager;
   import com.iflashigame.net.P2PEvent;
   import com.iflashigame.talk.NetInfoType;
   import com.iflashigame.talk.TalkEvent;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.GlobalTimer;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import game.Config;
   import game.TextFactory;
   import game.events.TimerStr;
   import game.events.UIEvent;
   import game.model.Head;
   import game.model.RoleModel;
   import game.model.RoleStatus;
   import game.ui.list.ScrollBar;
   
   public class LeitaiPanel extends BaseUI
   {
       
      
      private var __exploitTF:TextField;
      
      private var __moneyTF:TextField;
      
      private var __diankaTF:TextField;
      
      private var __rongyuTF:TextField;
      
      private var __paimingTF:TextField;
      
      private var __chongzhiBtn:SimpleButton;
      
      private var __guizeBtn:SimpleButton;
      
      private var __tiaozhengBtn:SimpleButton;
      
      private var __closeBtn:SimpleButton;
      
      private var _container:LeitaiContainer;
      
      private var _scrollBar:ScrollBar;
      
      private var _leitaiArr:Vector.<Leitai>;
      
      private var _paiHangArr:Array;
      
      private var _tipsPanel:LeitaiTipsPanel;
      
      private var _rID:int = -1;
      
      public function LeitaiPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      public function get rID() : int
      {
         return this._rID;
      }
      
      public function resetRID() : *
      {
         this._rID = -1;
      }
      
      override protected function initView() : void
      {
         this.__exploitTF = _skin.getChildByName("_exploitTF") as TextField;
         this.__moneyTF = _skin.getChildByName("_moneyTF") as TextField;
         this.__diankaTF = _skin.getChildByName("_diankaTF") as TextField;
         this.__rongyuTF = _skin.getChildByName("_rongyuTF") as TextField;
         this.__paimingTF = _skin.getChildByName("_paimingTF") as TextField;
         this.__chongzhiBtn = _skin.getChildByName("_chongzhiBtn") as SimpleButton;
         this.__guizeBtn = _skin.getChildByName("_guizeBtn") as SimpleButton;
         this.__tiaozhengBtn = _skin.getChildByName("_tiaozhengBtn") as SimpleButton;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this._container = new LeitaiContainer();
         this._container.x = -365;
         this._container.y = -210;
         addChild(this._container);
         this._scrollBar = new ScrollBar(SkinCode.PAIHANG_SCROLL_BAR);
         this._scrollBar.x = 119;
         this._scrollBar.y = -208.8;
         addChild(this._scrollBar);
         this._scrollBar.target = this._container;
         this.createPaiHang();
      }
      
      override protected function initEvent() : void
      {
         addEventListener(Event.ADDED_TO_STAGE,this.addToStageHandler);
         addEventListener(Event.REMOVED_FROM_STAGE,this.removeFromStageHandler);
         this.__chongzhiBtn.addEventListener(MouseEvent.CLICK,this.chongzhiBtnClickHandler);
         this.__guizeBtn.addEventListener(MouseEvent.CLICK,this.guizeBtnClickHandler);
         this.__tiaozhengBtn.addEventListener(MouseEvent.CLICK,this.tiaozhengBtnClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         addEventListener(UIEvent.BECOME_LEIZHU,this.becomeLeizhuHandler);
         addEventListener(UIEvent.GONGLEI,this.gongleiHandler);
      }
      
      private function addToStageHandler(param1:Event) : *
      {
         RoleModel.getInstance().status = RoleStatus.LEITAI_DATING;
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDownHandler);
      }
      
      private function onKeyDownHandler(param1:KeyboardEvent) : *
      {
         switch(param1.keyCode)
         {
            case Keyboard.CONTROL:
               this.leitaiFlushFun();
         }
      }
      
      private function removeFromStageHandler(param1:Event) : *
      {
         GlobalTimer.getInstance().removeListener(TimerStr.LEITAI_FLUSH);
         GlobalTimer.getInstance().removeListener(TimerStr.PAIHANG_FLUSH);
         RoleModel.getInstance().status = RoleStatus.DANJI;
         ChatManager.getInstance().leitaiMode = false;
         ChatManager.getInstance().leizhu = true;
      }
      
      override public function initData(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.flushLeitai(param1.leitai);
         this.flushPaihang(param1.paihang);
         this.flushOther(param1);
         GlobalTimer.getInstance().addListener(TimerStr.LEITAI_FLUSH,Config.LEITAI_FLUSH_DELAY,this.leitaiFlushFun);
         GlobalTimer.getInstance().addListener(TimerStr.PAIHANG_FLUSH,Config.PAIHANG_FLUSH_DELAY,this.paihangFlushFun);
      }
      
      public function flushLeitai(param1:Array) : *
      {
         param1.sortOn("rID",Array.NUMERIC | Array.DESCENDING);
         this._container.initData(param1);
      }
      
      public function flushPaihang(param1:Array) : *
      {
         this.initPaihang(param1);
      }
      
      public function flushOther(param1:Object) : *
      {
         this.__exploitTF.text = RoleModel.getInstance().exploit.toString();
         this.__moneyTF.text = RoleModel.getInstance().money.toString();
         this.__diankaTF.text = RoleModel.getInstance().dianka.toString();
         if(param1.rongyu != null)
         {
            this.__rongyuTF.text = param1.rongyu;
         }
         if(param1.ranking != null)
         {
            this.__paimingTF.text = param1.ranking;
         }
      }
      
      private function createPaiHang() : *
      {
         var _loc1_:int = 0;
         var _loc3_:MovieClip = null;
         _loc1_ = 0;
         var _loc2_:Class = null;
         _loc3_ = null;
         this._paiHangArr = [];
         _loc1_ = 0;
         while(_loc1_ < 10)
         {
            _loc2_ = ApplicationDomain.currentDomain.getDefinition(SkinCode.LEITAI_LIST_ITEM) as Class;
            _loc3_ = new _loc2_() as MovieClip;
            _loc3_.mouseEnabled = false;
            _loc3_.mouseChildren = false;
            _loc3_.x = 174;
            _loc3_.y = -180 + _loc1_ * 25;
            addChild(_loc3_);
            this._paiHangArr.push(_loc3_);
            _loc1_++;
         }
      }
      
      private function initPaihang(param1:Array) : *
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            this._paiHangArr[_loc2_]._mingciTF.text = (_loc2_ + 1).toString();
            this._paiHangArr[_loc2_]._nameTF.text = param1[_loc2_].roleName;
            this._paiHangArr[_loc2_]._rongyuTF.text = param1[_loc2_].score;
            _loc2_++;
         }
      }
      
      public function becomeLeizhu(param1:int) : *
      {
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_LEITAI_BEMASTER;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         _loc2_.rID = param1;
         _loc2_.pID = ChatManager.getInstance().peerID;
         _loc2_.mask = true;
         AESController.getInstance().sendJSON(_loc2_,this.becomeLeizhuResponse);
      }
      
      private function becomeLeizhuHandler(param1:UIEvent) : void
      {
         param1.stopImmediatePropagation();
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_LEITAI_BEMASTER;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         _loc2_.rID = int(param1.data.roomID);
         _loc2_.pID = ChatManager.getInstance().peerID;
         _loc2_.mask = true;
         AESController.getInstance().sendJSON(_loc2_,this.becomeLeizhuResponse);
      }
      
      private function becomeLeizhuResponse(param1:Object) : *
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(param1.success == true)
         {
            try {
            RoleModel.getInstance().status = RoleStatus.LEITAI;
            ChatManager.getInstance().leitaiMode = true;
            ChatManager.getInstance().leizhu = true;
            RoleModel.getInstance().money = int(param1.data.money);
            RoleModel.getInstance().exploit = int(param1.data.exploit);
            RoleModel.getInstance().dianka = int(param1.data.dianka);
            RoleModel.getInstance().rongyu = int(param1.data.rongyu);
            this.flushLeitai(param1.data.leitai);
            this.flushOther(param1.data);
            GlobalTimer.getInstance().pauseListener(TimerStr.LEITAI_FLUSH);
            GlobalTimer.getInstance().pauseListener(TimerStr.PAIHANG_FLUSH);
            this.openTipsPanel({
               "type":1,
               "rID":param1.data.rID
            });
            this._rID = param1.data.rID;
            _loc2_ = this.findCountByrID(param1.data.rID,param1.data.leitai);
            if(_loc2_ != null) {
               _loc3_ = TextFactory.makeLeitai(_loc2_.rLevel,_loc2_.mInfo.roleName);
               dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                  "type":NetInfoType.SYSTEM,
                  "text":_loc3_
               }));
            }
            } catch(e:Error) {
               // 静默处理，防止回调崩溃导致监听器泄漏
            }
         }
         else
         {
            RoleModel.getInstance().status = RoleStatus.LEITAI_DATING;
            ChatManager.getInstance().leitaiMode = false;
            ChatManager.getInstance().leizhu = true;
            GlobalTimer.getInstance().playListener(TimerStr.LEITAI_FLUSH);
            GlobalTimer.getInstance().playListener(TimerStr.PAIHANG_FLUSH);
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
            this.leitaiFlushFun();
         }
      }
      
      private function gongleiHandler(param1:UIEvent) : void
      {
         param1.stopImmediatePropagation();
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_LEITAI_BESLAVE;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         _loc2_.rID = int(param1.data.roomID);
         _loc2_.pID = ChatManager.getInstance().peerID;
         _loc2_.mask = true;
         AESController.getInstance().sendJSON(_loc2_,this.gongleiResponse);
      }
      
      private function gongleiResponse(param1:Object) : *
      {
         var _loc2_:Object = null;
         if(param1.success == true)
         {
            try {
            RoleModel.getInstance().status = RoleStatus.LEITAI;
            ChatManager.getInstance().leitaiMode = true;
            ChatManager.getInstance().leizhu = false;
            RoleModel.getInstance().money = int(param1.data.money);
            RoleModel.getInstance().exploit = int(param1.data.exploit);
            RoleModel.getInstance().dianka = int(param1.data.dianka);
            RoleModel.getInstance().rongyu = int(param1.data.rongyu);
            this.flushLeitai(param1.data.leitai);
            this.flushOther(param1.data);
            this._rID = param1.data.rID;
            GlobalTimer.getInstance().pauseListener(TimerStr.LEITAI_FLUSH);
            GlobalTimer.getInstance().pauseListener(TimerStr.PAIHANG_FLUSH);
            _loc2_ = this.findCountByrID(param1.data.rID,param1.data.leitai);
            if(_loc2_ != null && _loc2_.mInfo != null && _loc2_.mInfo.pID) {
               ChatManager.getInstance().p2pConnect(_loc2_.mInfo.pID,false,Config.LEITAI_TIMEOUT);
               ChatManager.getInstance().dispatchEvent(new P2PEvent(P2PEvent.LEITAI_CONNECT_WAIT));
            }
            } catch(e:Error) {}
         }
         else
         {
            RoleModel.getInstance().status = RoleStatus.LEITAI_DATING;
            ChatManager.getInstance().leitaiMode = false;
            ChatManager.getInstance().leizhu = true;
            GlobalTimer.getInstance().playListener(TimerStr.LEITAI_FLUSH);
            GlobalTimer.getInstance().playListener(TimerStr.PAIHANG_FLUSH);
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
            this.leitaiFlushFun();
         }
      }
      
      private function chongzhiBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CHONGZHI_CLICK,true));
      }
      
      private function guizeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_LEITAI_GUIZE,true));
      }
      
      private function tiaozhengBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_BUDUI,true));
      }
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
      
      public function leitaiFlushFun() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_LEITAI_FLUSH;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         AESController.getInstance().sendJSON(_loc1_,this.leitaiFlushResponse);
      }
      
      private function leitaiFlushResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            this.flushLeitai(param1.data.leitai);
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function paihangFlushFun() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_LEITAI_PAIHANG;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         AESController.getInstance().sendJSON(_loc1_,this.paihangFlushResponse);
      }
      
      private function paihangFlushResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            this.flushPaihang(param1.data.paihang);
            this.flushOther(param1.data);
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      public function openTipsPanel(param1:Object) : *
      {
         if(this._tipsPanel == null)
         {
            this._tipsPanel = new LeitaiTipsPanel(SkinCode.LEITAI_TIPS_PANEL);
            addChild(this._tipsPanel);
            this._tipsPanel.createMask(0,0.4);
         }
         this._tipsPanel.initData(param1);
      }
      
      public function closeTipsPanel() : *
      {
         if(this._tipsPanel != null)
         {
            removeChild(this._tipsPanel);
            this._tipsPanel = null;
         }
      }
      
      public function findCountByrID(param1:int, param2:Array) : Object
      {
         var _loc3_:int = 0;
         while(_loc3_ < param2.length)
         {
            if(param2[_loc3_].rID == param1)
            {
               return param2[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
   }
}
