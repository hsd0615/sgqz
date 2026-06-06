package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.events.UIEvent;
   
   public class GameInfo extends BaseUI
   {
       
      
      private var __tf:TextField;
      
      private var __closeBtn:SimpleButton;
      
      public function GameInfo(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__tf = _skin.getChildByName("_tf") as TextField;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
      }
      
      override protected function initEvent() : void
      {
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
      }
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
   }
}
