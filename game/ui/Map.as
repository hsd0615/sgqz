package game.ui
{
   import com.iflashigame.sound.MySound;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.ui.Paomadeng;
   import com.iflashigame.utils.Tools;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.Config;
   import game.Data;
   import game.SoundCode;
   import game.events.UIEvent;
   
   public class Map extends BaseUI
   {
       
      
      private var __luntanBtn:MovieClip;
      
      private var __shopBtn:MovieClip;
      
      private var __stage1Btn:MovieClip;
      
      private var __stage2Btn:MovieClip;
      
      private var __stage3Btn:MovieClip;
      
      private var __stage4Btn:MovieClip;
      
      private var __stage5Btn:MovieClip;
      
      private var __stage6Btn:MovieClip;
      
      private var __stage7Btn:MovieClip;
      
      private var __stage8Btn:MovieClip;
      
      private var __stage9Btn:MovieClip;
      
      private var __stage10Btn:MovieClip;
      
      private var __wujiangBtn:MovieClip;
      
      private var __buduiBtn:MovieClip;
      
      private var __zhaomuBtn:MovieClip;
      
      private var __duizhanBtn:MovieClip;
      
      private var __beibaoBtn:MovieClip;
      
      private var __buchangBtn:MovieClip;
      
      private var _buchangStr:String = "";
      
      private var __lingdiankaBtn:MovieClip;
      
      private var __leitaiBtn:MovieClip;
      
      private var __xiongnuBtn:MovieClip;
      
      private var __wokouBtn:MovieClip;
      
      private var __chongzhiBtn:SimpleButton;
      
      private var __soundMC:MovieClip;
      
      private var __waveMC:MovieClip;
      
      private var __nameTF:TextField;
      
      private var __infoTF:TextField;
      
      private var _posX:Number = -378;
      
      private var _posY:Number = -245;
      
      private var _paomadeng:Paomadeng;
      
      private var _talkArea:TalkArea;
      
      public function Map(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__luntanBtn = _skin.getChildByName("_luntanBtn") as MovieClip;
         this.__shopBtn = _skin.getChildByName("_shopBtn") as MovieClip;
         this.__stage1Btn = _skin.getChildByName("_stage1Btn") as MovieClip;
         this.__stage2Btn = _skin.getChildByName("_stage2Btn") as MovieClip;
         this.__stage3Btn = _skin.getChildByName("_stage3Btn") as MovieClip;
         this.__stage4Btn = _skin.getChildByName("_stage4Btn") as MovieClip;
         this.__stage5Btn = _skin.getChildByName("_stage5Btn") as MovieClip;
         this.__stage6Btn = _skin.getChildByName("_stage6Btn") as MovieClip;
         this.__stage7Btn = _skin.getChildByName("_stage7Btn") as MovieClip;
         this.__stage8Btn = _skin.getChildByName("_stage8Btn") as MovieClip;
         this.__stage9Btn = _skin.getChildByName("_stage9Btn") as MovieClip;
         this.__stage10Btn = _skin.getChildByName("_stage10Btn") as MovieClip;
         this.__wujiangBtn = _skin.getChildByName("_wujiangBtn") as MovieClip;
         this.__buduiBtn = _skin.getChildByName("_buduiBtn") as MovieClip;
         this.__zhaomuBtn = _skin.getChildByName("_zhaomuBtn") as MovieClip;
         this.__duizhanBtn = _skin.getChildByName("_duizhanBtn") as MovieClip;
         this.__beibaoBtn = _skin.getChildByName("_beibaoBtn") as MovieClip;
         this.__buchangBtn = _skin.getChildByName("_buchangBtn") as MovieClip;
         this.__lingdiankaBtn = _skin.getChildByName("_lingdiankaBtn") as MovieClip;
         this.__leitaiBtn = _skin.getChildByName("_leitaiBtn") as MovieClip;
         this.__xiongnuBtn = _skin.getChildByName("_xiongnuBtn") as MovieClip;
         this.__wokouBtn = _skin.getChildByName("_wokouBtn") as MovieClip;
         this.__chongzhiBtn = _skin.getChildByName("_chongzhiBtn") as SimpleButton;
         this.__soundMC = _skin.getChildByName("_soundMC") as MovieClip;
         this.__waveMC = _skin.getChildByName("_waveMC") as MovieClip;
         this.__luntanBtn.buttonMode = true;
         this.__shopBtn.buttonMode = true;
         this.__stage1Btn.buttonMode = true;
         this.__stage2Btn.buttonMode = true;
         this.__stage3Btn.buttonMode = true;
         this.__stage4Btn.buttonMode = true;
         this.__stage5Btn.buttonMode = true;
         this.__stage6Btn.buttonMode = true;
         this.__stage7Btn.buttonMode = true;
         this.__stage8Btn.buttonMode = true;
         this.__stage9Btn.buttonMode = true;
         this.__stage10Btn.buttonMode = true;
         this.__wujiangBtn.buttonMode = true;
         this.__buduiBtn.buttonMode = true;
         this.__zhaomuBtn.buttonMode = true;
         this.__duizhanBtn.buttonMode = true;
         this.__beibaoBtn.buttonMode = true;
         this.__buchangBtn.buttonMode = true;
         this.__leitaiBtn.buttonMode = true;
         this.__lingdiankaBtn.visible = false;
         this.__xiongnuBtn.buttonMode = true;
         this.__wokouBtn.buttonMode = true;
         this.__soundMC.mouseChildren = false;
         this.__waveMC.mouseChildren = false;
         this.__soundMC.buttonMode = true;
         this.__waveMC.buttonMode = true;
         this.__nameTF = _skin.getChildByName("_nameTF") as TextField;
         this.__infoTF = _skin.getChildByName("_infoTF") as TextField;
         this._talkArea = new TalkArea(SkinCode.TALK_INPUT);
         this._talkArea.x = -width / 2;
         this._talkArea.y = height / 2;
         addChild(this._talkArea);
         this.__buchangBtn.visible = false;
         var _loc1_:* = Config.actionMessage();
         switch(_loc1_)
         {
            case 1:
               this._buchangStr = "孙权降世奖励发放";
               this.__buchangBtn.visible = true;
               break;
            case 2:
               this._buchangStr = "刘备降世奖励发放";
               this.__buchangBtn.visible = true;
               break;
            case 3:
               this._buchangStr = "曹操降世奖励发放";
               this.__buchangBtn.visible = true;
         }
      }
      
      override protected function initEvent() : void
      {
         this.__stage1Btn.addEventListener(MouseEvent.CLICK,this.stage1BtnClickHandler);
         this.__stage1Btn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__stage1Btn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__stage2Btn.addEventListener(MouseEvent.CLICK,this.stage2BtnClickHandler);
         this.__stage2Btn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__stage2Btn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__stage3Btn.addEventListener(MouseEvent.CLICK,this.stage3BtnClickHandler);
         this.__stage3Btn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__stage3Btn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__stage4Btn.addEventListener(MouseEvent.CLICK,this.stage4BtnClickHandler);
         this.__stage4Btn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__stage4Btn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__stage5Btn.addEventListener(MouseEvent.CLICK,this.stage5BtnClickHandler);
         this.__stage5Btn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__stage5Btn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__stage6Btn.addEventListener(MouseEvent.CLICK,this.stage6BtnClickHandler);
         this.__stage6Btn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__stage6Btn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__stage7Btn.addEventListener(MouseEvent.CLICK,this.stage7BtnClickHandler);
         this.__stage7Btn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__stage7Btn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__stage8Btn.addEventListener(MouseEvent.CLICK,this.stage8BtnClickHandler);
         this.__stage8Btn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__stage8Btn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__stage9Btn.addEventListener(MouseEvent.CLICK,this.stage9BtnClickHandler);
         this.__stage9Btn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__stage9Btn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__stage10Btn.addEventListener(MouseEvent.CLICK,this.stage10BtnClickHandler);
         this.__stage10Btn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__stage10Btn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__luntanBtn.addEventListener(MouseEvent.CLICK,this.luntanBtnClickHandler);
         this.__luntanBtn.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         this.__luntanBtn.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         this.__shopBtn.addEventListener(MouseEvent.CLICK,this.shopBtnClickHandler);
         this.__shopBtn.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         this.__shopBtn.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         this.__wujiangBtn.addEventListener(MouseEvent.CLICK,this.wujiangBtnClickHandler);
         this.__wujiangBtn.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         this.__wujiangBtn.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         this.__buduiBtn.addEventListener(MouseEvent.CLICK,this.buduiBtnClickHandler);
         this.__buduiBtn.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         this.__buduiBtn.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         this.__zhaomuBtn.addEventListener(MouseEvent.CLICK,this.zhaomuBtnClickHandler);
         this.__zhaomuBtn.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         this.__zhaomuBtn.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         this.__duizhanBtn.addEventListener(MouseEvent.CLICK,this.duizhanBtnClickHandler);
         this.__duizhanBtn.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         this.__duizhanBtn.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         this.__beibaoBtn.addEventListener(MouseEvent.CLICK,this.beibaoBtnClickHandler);
         this.__beibaoBtn.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         this.__beibaoBtn.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         this.__leitaiBtn.addEventListener(MouseEvent.CLICK,this.leitaiBtnClickHandler);
         this.__leitaiBtn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__leitaiBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__buchangBtn.addEventListener(MouseEvent.CLICK,this.buchangBtnClickHandler);
         this.__buchangBtn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__buchangBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__chongzhiBtn.addEventListener(MouseEvent.CLICK,this.chongzhiBtnClickHandler);
         this.__soundMC.addEventListener(MouseEvent.CLICK,this.soundMCClickHandler);
         this.__soundMC.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         this.__soundMC.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         this.__waveMC.addEventListener(MouseEvent.CLICK,this.waveMCClickHandler);
         this.__waveMC.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         this.__waveMC.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         this.__xiongnuBtn.addEventListener(MouseEvent.CLICK,this.xiongnuBtnClickHandler);
         this.__xiongnuBtn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__xiongnuBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.__wokouBtn.addEventListener(MouseEvent.CLICK,this.wokouBtnClickHandler);
         this.__wokouBtn.addEventListener(MouseEvent.MOUSE_OVER,this.btnOverHandler);
         this.__wokouBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this.setInfo(param1);
         this.setImage(param1.image);
         this.setPaomadeng();
      }
      
      private function setPaomadeng() : *
      {
         this._paomadeng = new Paomadeng(Data.getInstance().getPaomadeng(),330,18,1);
         this._paomadeng.x = -116;
         this._paomadeng.y = -222;
         addChild(this._paomadeng);
         this._paomadeng.start();
      }
      
      public function setInfo(param1:Object) : *
      {
         this.__nameTF.text = param1.name;
         var _loc2_:String = "";
         _loc2_ += param1.level + "\n";
         _loc2_ += param1.reverence + "\n";
         _loc2_ += param1.money + "\n";
         _loc2_ += param1.exploit + "\n";
         _loc2_ += param1.dianka;
         this.__infoTF.text = _loc2_;
         this.checkPart(param1.history);
      }
      
      private function setImage(param1:int) : *
      {
         var _loc2_:Class = ApplicationDomain.currentDomain.getDefinition("image" + param1) as Class;
         var _loc3_:MovieClip = new _loc2_() as MovieClip;
         _loc3_.x = this._posX;
         _loc3_.y = this._posY;
         addChild(_loc3_);
      }
      
      private function checkPart(param1:Vector.<int>) : *
      {
         var _loc2_:MovieClip = null;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = this["__stage" + (_loc3_ + 1) + "Btn"] as MovieClip;
            _loc2_.gotoAndStop(param1[_loc3_]);
            if(param1[_loc3_] == 1)
            {
               Tools.setDisabled(_loc2_,true,false);
            }
            else
            {
               Tools.setDisabled(_loc2_,false,false);
            }
            _loc3_++;
         }
      }
      
      private function shopBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_SHOP,true));
      }
      
      private function luntanBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         // 禁用4399论坛跳转 — 本地测试版
         trace("forum blocked");
      }
      
      private function stage1BtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_STAGE,true,{"part":1}));
      }
      
      private function stage2BtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_STAGE,true,{"part":2}));
      }
      
      private function stage3BtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_STAGE,true,{"part":3}));
      }
      
      private function stage4BtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_STAGE,true,{"part":4}));
      }
      
      private function stage5BtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_STAGE,true,{"part":5}));
      }
      
      private function stage6BtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_STAGE,true,{"part":6}));
      }
      
      private function stage7BtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_STAGE,true,{"part":7}));
      }
      
      private function stage8BtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_STAGE,true,{"part":8}));
      }
      
      private function stage9BtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_STAGE,true,{"part":9}));
      }
      
      private function stage10BtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_STAGE,true,{"part":10}));
      }
      
      private function wujiangBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_WUJIANG,true));
      }
      
      private function buduiBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_BUDUI,true));
      }
      
      private function zhaomuBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_ZHAOMU,true));
      }
      
      private function duizhanBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_DUIZHAN,true));
      }
      
      private function beibaoBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_BEIBAO,true));
      }
      
      private function buchangBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_BUCHANG,true));
      }
      
      private function lingdiankaBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.LING_DIANKA,true));
      }
      
      private function leitaiBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_LEITAI,true));
      }
      
      private function soundMCClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(MySound.getInstance().bkDisabled == true)
         {
            this.__soundMC.gotoAndStop(1);
            MySound.getInstance().bkDisabled = false;
            MySound.getInstance().startByName(SoundCode.MAP);
         }
         else
         {
            this.__soundMC.gotoAndStop(2);
            MySound.getInstance().bkDisabled = true;
            MySound.getInstance().stop();
         }
      }
      
      private function waveMCClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(MySound.getInstance().eventDisabled == true)
         {
            this.__waveMC.gotoAndStop(1);
            MySound.getInstance().eventDisabled = false;
         }
         else
         {
            this.__waveMC.gotoAndStop(2);
            MySound.getInstance().eventDisabled = true;
         }
      }
      
      private function xiongnuBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.XIONGNU_CLICK,true,{"stageID":1}));
      }
      
      private function wokouBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
            "type":0,
            "text":"荡平倭寇副本暂未开放，请关注官方通知。"
         }));
      }
      
      private function mouseOverHandler(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.filters = [new GlowFilter(16776960,1,2,2,1000),new GlowFilter(16777113,0.8,4,4)];
         if(param1.target == this.__wujiangBtn)
         {
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":"武将升级、进化",
               "width":90,
               "height":18,
               "type":1
            }));
         }
         else if(param1.target == this.__buduiBtn)
         {
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":"选择上阵武将",
               "width":80,
               "height":18,
               "type":1
            }));
         }
         else if(param1.target == this.__zhaomuBtn)
         {
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":"招募在野武将",
               "width":80,
               "height":18,
               "type":1
            }));
         }
         else if(param1.target == this.__duizhanBtn)
         {
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":"挑战其他玩家",
               "width":80,
               "height":18,
               "type":1
            }));
         }
         else if(param1.target == this.__beibaoBtn)
         {
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":"查看背包物品",
               "width":80,
               "height":18,
               "type":1
            }));
         }
         else if(param1.target == this.__shopBtn)
         {
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":"道具商店",
               "width":57,
               "height":18,
               "type":2
            }));
         }
         else if(param1.target == this.__soundMC)
         {
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":"游戏音乐",
               "width":157,
               "height":18,
               "type":2
            }));
         }
         else if(param1.target == this.__waveMC)
         {
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":"游戏音效",
               "width":157,
               "height":18,
               "type":2
            }));
         }
         else if(param1.target == this.__luntanBtn)
         {
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":"玩家讨论组",
               "width":170,
               "height":18,
               "type":2
            }));
         }
      }
      
      private function mouseOutHandler(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.filters = [];
         dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
      }
      
      private function btnOverHandler(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.scaleX = 1.2;
         _loc2_.scaleY = 1.2;
         if(param1.target == this.__buchangBtn)
         {
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":this._buchangStr,
               "width":190,
               "height":18,
               "type":2
            }));
         }
         else if(param1.target == this.__lingdiankaBtn)
         {
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":"领取游戏维护补偿",
               "width":190,
               "height":18,
               "type":2
            }));
         }
      }
      
      private function btnOutHandler(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.scaleX = 1;
         _loc2_.scaleY = 1;
         if(param1.target == this.__buchangBtn)
         {
            dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
         }
         else if(param1.target == this.__lingdiankaBtn)
         {
            dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
         }
      }
      
      private function chongzhiBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CHONGZHI_CLICK,true));
      }
      
      public function recieveNetInfo(param1:Object) : *
      {
         this._talkArea.recieveNetInfo(param1);
      }
      
      public function sendLaba() : *
      {
         this._talkArea.sendLaba();
      }
   }
}
