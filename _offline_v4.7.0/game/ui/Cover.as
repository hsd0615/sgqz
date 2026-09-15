package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import game.events.UIEvent;
   
   public class Cover extends BaseUI
   {
       
      
      private var __newGameBtn:SimpleButton;
      
      private var __netGameBtn:SimpleButton;
      
      private var __infoBtn:SimpleButton;
      
      private var __bkMC:MovieClip;
      
      public function Cover(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__newGameBtn = _skin.getChildByName("_newGameBtn") as SimpleButton;
         this.__netGameBtn = _skin.getChildByName("_netGameBtn") as SimpleButton;
         this.__infoBtn = _skin.getChildByName("_infoBtn") as SimpleButton;
         this.__bkMC = _skin.getChildByName("_bkMC") as MovieClip;
      }
      
      override protected function initEvent() : void
      {
         this.__newGameBtn.addEventListener(MouseEvent.CLICK,this.newGameBtnClickHandler);
         this.__netGameBtn.addEventListener(MouseEvent.CLICK,this.netGameBtnClickHandler);
         this.__infoBtn.addEventListener(MouseEvent.CLICK,this.infoBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
      }
      
      private function newGameBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.NEW_GAME,true));
      }
      
      private function netGameBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CONNECT_SERVER,true));
      }
      
      private function infoBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.GAMEINFO,true));
      }
   }
}
