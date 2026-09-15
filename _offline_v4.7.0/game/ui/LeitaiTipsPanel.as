package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.utils.Timer;
   import game.Config;
   import game.events.UIEvent;
   
   public class LeitaiTipsPanel extends BaseUI
   {
       
      
      private var __contentTF:TextField;
      
      private var __timeTF:TextField;
      
      private var __closeBtn:SimpleButton;
      
      private var __continueBtn:SimpleButton;
      
      private var __exitBtn:SimpleButton;
      
      private var _type:int;
      
      private var _rID:int;
      
      private var _timer:Timer;
      
      public function LeitaiTipsPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__contentTF = _skin.getChildByName("_contentTF") as TextField;
         this.__timeTF = _skin.getChildByName("_timeTF") as TextField;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__continueBtn = _skin.getChildByName("_continueBtn") as SimpleButton;
         this.__exitBtn = _skin.getChildByName("_exitBtn") as SimpleButton;
      }
      
      override protected function initEvent() : void
      {
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStageHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this.__continueBtn.addEventListener(MouseEvent.CLICK,this.continueBtnClickHandler);
         this.__exitBtn.addEventListener(MouseEvent.CLICK,this.exitBtnClickHandler);
      }
      
      private function onRemovedFromStageHandler(param1:Event) : void
      {
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStageHandler);
         if(this._timer != null)
         {
            this._timer.reset();
            this._timer.removeEventListener(TimerEvent.TIMER,this.onType1TimerHandler);
            this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onType1TimerCompleteHandler);
            this._timer = null;
         }
      }
      
      override public function initData(param1:Object) : void
      {
         this._type = int(param1.type);
         this._rID = int(param1.rID);
         switch(param1.type)
         {
            case 1:
               this.showType1();
               break;
            case 2:
               this.showType2();
         }
      }
      
      private function showType1() : *
      {
         if(this._timer == null)
         {
            this._timer = new Timer(1000,Config.LEITAI_DELAY);
         }
         this._timer.reset();
         this._timer.addEventListener(TimerEvent.TIMER,this.onType1TimerHandler);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onType1TimerCompleteHandler);
         this.__contentTF.text = "　　　　　恭喜您成为擂主，请等待其他玩家攻擂。\n　　　　　若守擂成功，您将获得擂台收益及积分。";
         this.__timeTF.text = "等待攻擂倒计时：180秒";
         this.__continueBtn.visible = false;
         this.__exitBtn.visible = false;
         this.__closeBtn.visible = false;
         this._timer.start();
      }
      
      private function onType1TimerHandler(param1:TimerEvent) : *
      {
         this.__timeTF.text = "等待攻擂倒计时：" + (Config.LEITAI_DELAY - this._timer.currentCount).toString() + "秒";
      }
      
      private function onType1TimerCompleteHandler(param1:TimerEvent) : *
      {
         this._timer.reset();
         this._timer.removeEventListener(TimerEvent.TIMER,this.onType1TimerHandler);
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onType1TimerCompleteHandler);
         this.__timeTF.text = "";
         this.__continueBtn.visible = true;
         this.__exitBtn.visible = true;
         this.__contentTF.text = "您创建擂台期间暂时无人攻擂，请选择是否继续当擂主或退出本擂台，若选择退出本擂台，你的报名费将全额返还。";
      }
      
      private function showType2() : *
      {
      }
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
      
      private function continueBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CONTINUE_LEIZHU,true,{"roomID":this._rID}));
      }
      
      private function exitBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.EXIT_LEIZHU,true,{
            "roomID":this._rID,
            "flag":0
         }));
      }
   }
}
