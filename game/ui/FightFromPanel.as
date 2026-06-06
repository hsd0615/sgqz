package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.utils.Timer;
   import game.events.UIEvent;
   
   public class FightFromPanel extends BaseUI
   {
       
      
      private var __contentTF:TextField;
      
      private var __fightBtn:SimpleButton;
      
      private var __defuseBtn:SimpleButton;
      
      private var __closeBtn:SimpleButton;
      
      private var __timeTF:TextField;
      
      private var _fromPID:String;
      
      private var _type:int;
      
      public var channel:String = "area";
      
      private var _timer:Timer;
      
      public function FightFromPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__contentTF = _skin.getChildByName("_contentTF") as TextField;
         this.__fightBtn = _skin.getChildByName("_fightBtn") as SimpleButton;
         this.__defuseBtn = _skin.getChildByName("_defuseBtn") as SimpleButton;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__timeTF = _skin.getChildByName("_timeTF") as TextField;
      }
      
      override protected function initEvent() : void
      {
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
      }
      
      private function onRemoveFromStageHandler(param1:Event) : *
      {
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
         this._timer.removeEventListener(TimerEvent.TIMER,this.onTimerHandler);
         this._timer.reset();
         this._timer = null;
      }
      
      override public function initData(param1:Object) : void
      {
         if(this._timer == null)
         {
            this._timer = new Timer(1000);
         }
         else
         {
            this._timer.reset();
         }
         this.__contentTF.text = "";
         this.__timeTF.text = "";
         this.__fightBtn.removeEventListener(MouseEvent.CLICK,this.fightBtnClickHandler);
         this.__defuseBtn.removeEventListener(MouseEvent.CLICK,this.defuseBtnClickHandler);
         this.__closeBtn.removeEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this.__closeBtn.removeEventListener(MouseEvent.CLICK,this.cancelFightHandler);
         this.__closeBtn.removeEventListener(MouseEvent.CLICK,this.defuseFightHandler);
         if(param1.channel != null)
         {
            this.channel = param1.channel;
         }
         if(param1.type == 1)
         {
            this._fromPID = param1.pID;
            if(param1.image % 2 == 1)
            {
               param1.name = "<font color=\'#6CDDF5\'>" + param1.name + "</font>";
            }
            else
            {
               param1.name = "<font color=\'#FC9595\'>" + param1.name + "</font>";
            }
            this.__contentTF.htmlText = "你已向" + param1.name + "（" + param1.level + "级）发起挑战，等待对方回应。";
            this.__closeBtn.visible = true;
            this.__fightBtn.visible = false;
            this.__defuseBtn.visible = false;
            Tools.setDisabled(this.__closeBtn,true);
            this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         }
         else if(param1.type == 2)
         {
            this._fromPID = param1.pID;
            if(param1.image % 2 == 1)
            {
               param1.name = "<font color=\'#6CDDF5\'>" + param1.name + "</font>";
            }
            else
            {
               param1.name = "<font color=\'#FC9595\'>" + param1.name + "</font>";
            }
            this.__contentTF.htmlText = param1.name + "（" + param1.level + "级）正在军前叫阵，是否上阵应战？";
            this.__closeBtn.visible = false;
            this.__fightBtn.visible = true;
            this.__defuseBtn.visible = true;
            this.__fightBtn.addEventListener(MouseEvent.CLICK,this.fightBtnClickHandler);
            this.__defuseBtn.addEventListener(MouseEvent.CLICK,this.defuseBtnClickHandler);
         }
         else if(param1.type == 3)
         {
            this._fromPID = null;
            this.__contentTF.htmlText = "对方闭守城门，拒绝了你的挑战。";
            this.__closeBtn.visible = true;
            this.__fightBtn.visible = false;
            this.__defuseBtn.visible = false;
            Tools.setDisabled(this.__closeBtn,false);
            this.__closeBtn.addEventListener(MouseEvent.CLICK,this.defuseFightHandler);
         }
         else if(param1.type == 4)
         {
            this._fromPID = null;
            this.__contentTF.htmlText = "对方已鸣金退兵，取消了对你的挑战。";
            this.__closeBtn.visible = true;
            this.__fightBtn.visible = false;
            this.__defuseBtn.visible = false;
            Tools.setDisabled(this.__closeBtn,false);
            this.__closeBtn.addEventListener(MouseEvent.CLICK,this.cancelFightHandler);
         }
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimerHandler);
         this._timer.start();
      }
      
      private function fightBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._timer.reset();
         dispatchEvent(new UIEvent(UIEvent.AGREE_FIGHT,true,{"pID":this._fromPID}));
      }
      
      private function defuseBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._timer.reset();
         dispatchEvent(new UIEvent(UIEvent.DEFUSE_FIGHT,true,{"pID":this._fromPID}));
      }
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._timer.reset();
         dispatchEvent(new UIEvent(UIEvent.CLOSE));
      }
      
      private function cancelFightHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._timer.reset();
         dispatchEvent(new UIEvent(UIEvent.BE_CANCEL_FIGHT));
      }
      
      private function defuseFightHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this._timer.reset();
         dispatchEvent(new UIEvent(UIEvent.BE_DEFUSE_FIGHT));
      }
      
      private function onTimerHandler(param1:TimerEvent) : *
      {
         var _loc2_:int = this._timer.currentCount;
         this.__timeTF.text = _loc2_.toString() + " 秒";
         if(_loc2_ == 15 && this.__closeBtn.visible == true)
         {
            Tools.setDisabled(this.__closeBtn,false);
         }
      }
      
      public function get fromPID() : String
      {
         return this._fromPID;
      }
   }
}
