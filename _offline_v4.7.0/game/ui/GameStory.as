package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import game.events.UIEvent;
   
   public class GameStory extends BaseUI
   {
       
      
      private var __okBtn:SimpleButton;
      
      private var __bk:MovieClip;
      
      private var __preBtn:SimpleButton;
      
      private var __nextBtn:SimpleButton;
      
      private var __closeBtn:SimpleButton;
      
      private var __storyMC:MovieClip;
      
      private var __infoMC:MovieClip;
      
      public var type:int;
      
      public function GameStory(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this.__bk = _skin.getChildByName("_bk") as MovieClip;
         this.__preBtn = _skin.getChildByName("_preBtn") as SimpleButton;
         this.__nextBtn = _skin.getChildByName("_nextBtn") as SimpleButton;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__storyMC = _skin.getChildByName("_storyMC") as MovieClip;
         this.__infoMC = _skin.getChildByName("_infoMC") as MovieClip;
         this.__bk = _skin.getChildByName("_bk") as MovieClip;
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
      }
      
      private function onRemoveFromStageHandler(param1:Event) : *
      {
         this.__storyMC.stop();
      }
      
      override protected function initEvent() : void
      {
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.okBtnClickHandler);
         this.__preBtn.addEventListener(MouseEvent.CLICK,this.preBtnClickHandler);
         this.__nextBtn.addEventListener(MouseEvent.CLICK,this.nextBtnClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this.type = param1 as int;
         if(param1 == 1)
         {
            this.__preBtn.visible = false;
            this.__nextBtn.visible = false;
            this.__closeBtn.visible = false;
            this.__infoMC.visible = false;
            this.__storyMC.gotoAndPlay(2);
         }
         else
         {
            this.__storyMC.visible = false;
            this.__bk.visible = false;
            Tools.setDisabled(this.__preBtn,true);
         }
      }
      
      private function preBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.__infoMC.gotoAndStop(1);
         Tools.setDisabled(this.__nextBtn,false);
         Tools.setDisabled(this.__preBtn,true);
      }
      
      private function nextBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.__infoMC.gotoAndStop(2);
         Tools.setDisabled(this.__nextBtn,true);
         Tools.setDisabled(this.__preBtn,false);
      }
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
      
      private function okBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
   }
}
