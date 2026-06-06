package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.SimpleButton;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import game.events.UIEvent;
   
   public class P2PFightTalk extends BaseUI
   {
       
      
      private var __inputTF:TextField;
      
      private var __btn:SimpleButton;
      
      private var _text:String = "";
      
      public function P2PFightTalk(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__inputTF = _skin.getChildByName("_inputTF") as TextField;
         this.__btn = _skin.getChildByName("_btn") as SimpleButton;
         this.__inputTF.text = "";
      }
      
      override protected function initEvent() : void
      {
         this.__btn.addEventListener(MouseEvent.CLICK,this.btnClickHandler);
         this.__inputTF.addEventListener(KeyboardEvent.KEY_DOWN,this.onTalkInputKeyDownHandler);
      }
      
      override public function initData(param1:Object) : void
      {
      }
      
      private function btnClickHandler(param1:MouseEvent) : *
      {
         if(param1 != null)
         {
            param1.stopImmediatePropagation();
         }
         if(this.__inputTF.text != "输入聊天信息" && this.__inputTF.text != "")
         {
            this._text = this.__inputTF.text;
            dispatchEvent(new UIEvent(UIEvent.SEND_TALK));
            this.__inputTF.text = "";
         }
      }
      
      private function onTalkInputKeyDownHandler(param1:KeyboardEvent) : *
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.btnClickHandler(null);
         }
      }
      
      public function getText() : String
      {
         return this._text;
      }
   }
}
