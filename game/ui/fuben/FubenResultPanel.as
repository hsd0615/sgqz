package game.ui.fuben
{
   import com.iflashigame.sound.MySound;
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.SoundCode;
   import game.events.UIEvent;
   
   public class FubenResultPanel extends BaseUI
   {
       
      
      private var __title0:MovieClip;
      
      private var __title1:MovieClip;
      
      private var __tf:TextField;
      
      private var __restartBtn:SimpleButton;
      
      private var __nextBtn:SimpleButton;
      
      private var __exitBtn:SimpleButton;
      
      private var __okBtn:SimpleButton;
      
      private var _stageID:int;
      
      private var _index:int;
      
      private var _paiArr:Array;
      
      public function FubenResultPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__title0 = _skin.getChildByName("_title0") as MovieClip;
         this.__title1 = _skin.getChildByName("_title1") as MovieClip;
         this.__tf = _skin.getChildByName("_tf") as TextField;
         this.__restartBtn = _skin.getChildByName("_restartBtn") as SimpleButton;
         this.__nextBtn = _skin.getChildByName("_nextBtn") as SimpleButton;
         this.__exitBtn = _skin.getChildByName("_exitBtn") as SimpleButton;
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this.hideAll();
      }
      
      private function hideAll() : *
      {
         this.__title0.visible = false;
         this.__title1.visible = false;
         this.__restartBtn.visible = false;
         this.__nextBtn.visible = false;
         this.__exitBtn.visible = false;
         this.__okBtn.visible = false;
      }
      
      override protected function initEvent() : void
      {
         this.__restartBtn.addEventListener(MouseEvent.CLICK,this.restartBtnClickHandler);
         this.__nextBtn.addEventListener(MouseEvent.CLICK,this.nextBtnClickHandler);
         this.__exitBtn.addEventListener(MouseEvent.CLICK,this.exitBtnClickHandler);
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.okBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this._stageID = int(param1.stageID);
         this._index = int(param1.index);
         if(param1.pai != null)
         {
            this._paiArr = param1.pai;
         }
         if(int(param1.result) == 0)
         {
            this.showLost();
            MySound.getInstance().startEventSoundByName(SoundCode.LOST);
            return;
         }
         switch(this._index)
         {
            case 1:
               this.showResult1(param1.forward);
               break;
            case 2:
               this.showResult2(param1.forward);
               break;
            case 3:
               this.showResult3(param1.forward);
         }
         MySound.getInstance().startEventSoundByName(SoundCode.WIN);
      }
      
      private function showLost() : *
      {
         this.hideAll();
         this.__title0.visible = true;
         this.__tf.text = "\n胜败乃兵家常事，请秣兵历马择时再战。";
         this.__restartBtn.visible = true;
         this.__exitBtn.visible = true;
      }
      
      private function showResult1(param1:Array) : *
      {
         this.hideAll();
         this.__title1.visible = true;
         var _loc2_:* = "已成功清除匈奴营寨前哨，请继续深入敌营。\n";
         _loc2_ += "过关奖励：银子+" + param1[0] + " 功勋+" + param1[1] + " 声望+" + param1[2] + "\n";
         _loc2_ += "下一关奖励更丰厚，加油吧！";
         this.__tf.text = _loc2_;
         this.__nextBtn.visible = true;
      }
      
      private function showResult2(param1:Array) : *
      {
         this.hideAll();
         this.__title1.visible = true;
         var _loc2_:* = "已剿灭匈奴营寨内围，请继续深入敌营，擒拿头目。\n";
         _loc2_ += "过关奖励：银子+" + param1[0] + " 功勋+" + param1[1] + " 声望+" + param1[2] + "\n";
         _loc2_ += "过全部关卡可获得特殊奖励，继续加油！";
         this.__tf.text = _loc2_;
         this.__nextBtn.visible = true;
      }
      
      private function showResult3(param1:Array) : *
      {
         this.hideAll();
         this.__title1.visible = true;
         var _loc2_:* = "匈奴头目已被成功擒获，任务完成。\n";
         _loc2_ += "过关奖励：银子+" + param1[0] + " 功勋+" + param1[1] + " 声望+" + param1[2] + "\n";
         _loc2_ += "请进入翻牌界面抽取特殊奖励！";
         this.__tf.text = _loc2_;
         this.__okBtn.visible = true;
      }
      
      private function restartBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.XIONGNU_CLICK,true));
      }
      
      private function nextBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.START_FUBEN,true,{
            "stageID":this._stageID,
            "index":this._index + 1
         }));
      }
      
      private function exitBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE_FUBEN,true));
      }
      
      private function okBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_FANPAI,true,{
            "pai":this._paiArr,
            "stageID":this._stageID
         }));
      }
   }
}
