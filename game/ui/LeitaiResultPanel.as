package game.ui
{
   import com.iflashigame.talk.NetInfoType;
   import com.iflashigame.talk.TalkEvent;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.utils.Timer;
   import game.Config;
   import game.TextFactory;
   import game.events.FightEvent;
   import game.events.UIEvent;
   import game.model.LeitaiType;
   
   public class LeitaiResultPanel extends BaseUI
   {
       
      
      private var __titleMC:MovieClip;
      
      private var __resultTF:TextField;
      
      private var __infoTF:TextField;
      
      private var __timeTF:TextField;
      
      private var __continueBtn:SimpleButton;
      
      private var __closeBtn:SimpleButton;
      
      private var __exitBtn:SimpleButton;
      
      private var _timer:Timer;
      
      private var _leizhu:Boolean;
      
      private var _flag:int;
      
      private var _leitai:Object;
      
      private var _createNew:Boolean = false;
      
      public function LeitaiResultPanel(param1:String, param2:ApplicationDomain = null)
      {
         this._timer = new Timer(1000);
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__titleMC = _skin.getChildByName("_titleMC") as MovieClip;
         this.__resultTF = _skin.getChildByName("_resultTF") as TextField;
         this.__infoTF = _skin.getChildByName("_infoTF") as TextField;
         this.__timeTF = _skin.getChildByName("_timeTF") as TextField;
         this.__continueBtn = _skin.getChildByName("_continueBtn") as SimpleButton;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__exitBtn = _skin.getChildByName("_exitBtn") as SimpleButton;
         this.__resultTF.text = "";
         this.__infoTF.text = "";
         this.__timeTF.text = "";
      }
      
      override protected function initEvent() : void
      {
         addEventListener(Event.REMOVED_FROM_STAGE,this.removeFromStageHandler);
         this.__continueBtn.addEventListener(MouseEvent.CLICK,this.continueBtnClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this.__exitBtn.addEventListener(MouseEvent.CLICK,this.exitBtnClickHandler);
      }
      
      private function removeFromStageHandler(param1:Event) : *
      {
         if(this._timer != null)
         {
            this._timer.reset();
            this._timer.removeEventListener(TimerEvent.TIMER,this.onTimerHandler);
            this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerCompleteHandler);
            this._timer = null;
         }
      }
      
      override public function initData(param1:Object) : void
      {
         this._leizhu = param1.leizhu;
         this._flag = param1.flag;
         this._leitai = param1.leitai;
         switch(this._flag)
         {
            case 0:
               this.showResult1(param1);
               break;
            case 1:
               this.showResult2(param1);
               break;
            case 2:
               this.showResult3(param1);
         }
      }
      
      private function showResult1(param1:Object) : *
      {
         if(param1.leizhu == true)
         {
            this.__titleMC.gotoAndStop(2);
            this.__resultTF.text = "您守擂失败。";
            this.__infoTF.text = "请再接再厉！重整兵马！";
            this.__timeTF.visible = false;
            this.__continueBtn.visible = false;
            this.__exitBtn.visible = false;
            this.__closeBtn.visible = true;
         }
         else
         {
            this.__titleMC.gotoAndStop(4);
            this.__resultTF.text = "您攻擂失败。";
            this.__infoTF.text = "请再接再厉！重整兵马！";
            this.__timeTF.visible = false;
            this.__continueBtn.visible = false;
            this.__exitBtn.visible = false;
            this.__closeBtn.visible = true;
         }
      }
      
      private function showResult2(param1:Object) : *
      {
         var _loc2_:String = null;
         var _loc3_:* = null;
         if(param1.leizhu == true)
         {
            this.__titleMC.gotoAndStop(1);
            this.__resultTF.visible = true;
            if(param1.leitai.rCount == 10)
            {
               this.__resultTF.text = "恭喜您连续守擂成功10场，获得奖励：";
            }
            else if(param1.leitai.rCount == 20)
            {
               this._createNew = true;
               this.__resultTF.text = "恭喜您连续守擂成功20场，获得全部奖池基金：";
            }
            else
            {
               this.__resultTF.text = "恭喜您守擂成功，获得奖励:";
            }
            if(param1.leitai.rType == LeitaiType.YINZI)
            {
               _loc2_ = "银子";
            }
            else if(param1.leitai.rType == LeitaiType.GONGXUN)
            {
               _loc2_ = "功勋";
            }
            else
            {
               _loc2_ = "点卡";
            }
            _loc3_ = _loc2_ + " +" + param1.value + " 荣誉+" + param1.rongyu;
            if(param1.leitai.rCount < 20)
            {
               _loc3_ += "\n\n奖池基金累计至：" + param1.leitai.rValue;
               _loc3_ += "\n再继续成功守擂" + (20 - param1.leitai.rCount) + "次，您可以获得全部奖池奖励。";
            }
            this.__infoTF.text = _loc3_;
            this.showShouleiWin(param1);
         }
         else
         {
            this.__titleMC.gotoAndStop(3);
            this.__resultTF.visible = true;
            this.__resultTF.text = "恭喜您攻擂成功！获得全部奖池奖励：";
            if(param1.leitai.rType == LeitaiType.YINZI)
            {
               _loc2_ = "银子";
            }
            else if(param1.leitai.rType == LeitaiType.GONGXUN)
            {
               _loc2_ = "功勋";
            }
            else
            {
               _loc2_ = "点卡";
            }
            _loc3_ = _loc2_ + " +" + param1.value + " 荣誉+" + param1.rongyu;
            _loc3_ += "\n\n您成为新擂主，请等待其他玩家攻擂。\n若守擂成功，您将获得擂台收益及荣誉。";
            this.__infoTF.text = _loc3_;
            this.showGongleiWin(param1);
         }
         this.__closeBtn.visible = false;
         this.__continueBtn.visible = true;
         this.__exitBtn.visible = true;
         if(param1.leitai.rCount < 20)
         {
            this.startTimer();
         }
      }
      
      private function showResult3(param1:Object) : *
      {
         var _loc2_:String = null;
         var _loc3_:* = null;
         if(param1.leizhu == true)
         {
            this.__titleMC.gotoAndStop(1);
            this.__resultTF.visible = true;
            if(param1.leitai.rCount == 10)
            {
               this.__resultTF.text = "恭喜您连续守擂成功10场，获得奖励：";
            }
            else if(param1.leitai.rCount == 20)
            {
               this._createNew = true;
               this.__resultTF.text = "恭喜您连续守擂成功20场，获得全部奖池基金：";
            }
            else
            {
               this.__resultTF.text = "恭喜您守擂成功，获得奖励:";
            }
            if(param1.leitai.rType == LeitaiType.YINZI)
            {
               _loc2_ = "银子";
            }
            else if(param1.leitai.rType == LeitaiType.GONGXUN)
            {
               _loc2_ = "功勋";
            }
            else
            {
               _loc2_ = "点卡";
            }
            _loc3_ = "攻擂者因非正常原因退出擂台。\n" + _loc2_ + " +" + param1.value + " 荣誉+" + param1.rongyu;
            if(param1.leitai.rCount < 20)
            {
               _loc3_ += "\n\n奖池基金累计至：" + param1.leitai.rValue;
               _loc3_ += "\n再继续成功守擂" + (20 - param1.leitai.rCount) + "次，您可以获得全部奖池奖励。";
            }
            this.__infoTF.text = _loc3_;
            this.showShouleiWin(param1);
         }
         else
         {
            this.__titleMC.gotoAndStop(3);
            this.__resultTF.visible = true;
            this.__resultTF.text = "恭喜您攻擂成功！获得全部奖池奖励：";
            _loc2_ = "擂主因非正常原因退出擂台。\n";
            if(param1.leitai.rType == LeitaiType.YINZI)
            {
               _loc2_ = "银子";
            }
            else if(param1.leitai.rType == LeitaiType.GONGXUN)
            {
               _loc2_ = "功勋";
            }
            else
            {
               _loc2_ = "点卡";
            }
            _loc3_ = _loc2_ + " +" + param1.value + " 荣誉+" + param1.rongyu;
            _loc3_ += "\n\n您成为新擂主，请等待其他玩家攻擂。\n若守擂成功，您将获得擂台收益及荣誉。";
            this.__infoTF.text = _loc3_;
            this.showGongleiWin(param1);
         }
         this.__closeBtn.visible = false;
         this.__continueBtn.visible = true;
         this.__exitBtn.visible = true;
         if(param1.leitai.rCount < 20)
         {
            this.startTimer();
         }
      }
      
      private function showGongleiWin(param1:Object) : *
      {
         var _loc2_:String = TextFactory.makeGonglei(param1.relativeName,param1.leitai.mInfo.roleName);
         dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
            "type":NetInfoType.SYSTEM,
            "text":_loc2_
         }));
      }
      
      private function showShouleiWin(param1:Object) : *
      {
         var _loc2_:String = null;
         if(param1.leitai.rCount == 1)
         {
            _loc2_ = TextFactory.makeShouleiFirst(param1.leitai.mInfo.roleName,param1.relativeName);
         }
         else if(param1.leitai.rCount == 20)
         {
            _loc2_ = TextFactory.makeShouleiSuccess(param1.leitai.mInfo.roleName,param1.leitai.rValue);
         }
         else
         {
            _loc2_ = TextFactory.makeShoulei(param1.leitai.mInfo.roleName,param1.leitai.rLevel,param1.leitai.rValue);
         }
         dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
            "type":NetInfoType.SYSTEM,
            "text":_loc2_
         }));
      }
      
      public function startTimer() : *
      {
         Tools.setDisabled(this.__continueBtn,true);
         Tools.setDisabled(this.__exitBtn,true);
         if(this._timer == null)
         {
            this._timer = new Timer(1000);
         }
         this._timer.reset();
         this._timer.repeatCount = Config.LEITAI_DELAY;
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimerHandler);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerCompleteHandler);
         this._timer.start();
      }
      
      private function onTimerHandler(param1:TimerEvent) : void
      {
         this.__timeTF.text = "等待攻擂倒计时：" + (Config.LEITAI_DELAY - this._timer.currentCount) + "秒";
      }
      
      private function onTimerCompleteHandler(param1:TimerEvent) : void
      {
         this.__timeTF.text = "无人攻擂，请选择继续或者退出。";
         this._timer.reset();
         this._timer.removeEventListener(TimerEvent.TIMER,this.onTimerHandler);
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerCompleteHandler);
         Tools.setDisabled(this.__continueBtn,false);
         Tools.setDisabled(this.__exitBtn,false);
      }
      
      private function continueBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._createNew == true)
         {
            dispatchEvent(new UIEvent(UIEvent.BECOME_LEIZHU,true,{"roomID":this._leitai.rID}));
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.CONTINUE_LEIZHU,true,{"roomID":this._leitai.rID}));
         }
      }
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new FightEvent(FightEvent.CLOSE_LEITAI_FIGHT,true,{
            "leizhu":this._leizhu,
            "flag":this._flag
         }));
      }
      
      private function exitBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.EXIT_LEIZHU,true,{
            "roomID":this._leitai.rID,
            "flag":1
         }));
      }
   }
}
