package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.system.ApplicationDomain;
   import game.events.UIEvent;
   
   public class SelectServerPanel extends BaseUI
   {
       
      
      private var __btn1:MovieClip;
      
      private var __btn2:MovieClip;
      
      private var __btn3:MovieClip;
      
      private var __btn4:MovieClip;
      
      private var __btn5:MovieClip;
      
      private var __btn6:MovieClip;
      
      private var __btn7:MovieClip;
      
      private var __btn8:MovieClip;
      
      private var __okBtn:SimpleButton;
      
      private var _currentServer:int;
      
      public var newPlayer:Boolean;
      
      public function SelectServerPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__btn1 = _skin.getChildByName("_btn1") as MovieClip;
         this.__btn2 = _skin.getChildByName("_btn2") as MovieClip;
         this.__btn3 = _skin.getChildByName("_btn3") as MovieClip;
         this.__btn4 = _skin.getChildByName("_btn4") as MovieClip;
         this.__btn5 = _skin.getChildByName("_btn5") as MovieClip;
         this.__btn6 = _skin.getChildByName("_btn6") as MovieClip;
         this.__btn7 = _skin.getChildByName("_btn7") as MovieClip;
         this.__btn8 = _skin.getChildByName("_btn8") as MovieClip;
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this.__btn1.buttonMode = true;
         this.__btn2.buttonMode = true;
         this.__btn3.buttonMode = true;
         this.__btn4.buttonMode = true;
         this.__btn5.buttonMode = true;
         this.__btn6.buttonMode = true;
         this.__btn7.buttonMode = true;
         this.__btn8.buttonMode = true;
      }
      
      override protected function initEvent() : void
      {
         this.__btn1.addEventListener(MouseEvent.CLICK,this.btn1ClickHandler);
         this.__btn2.addEventListener(MouseEvent.CLICK,this.btn2ClickHandler);
         this.__btn3.addEventListener(MouseEvent.CLICK,this.btn3ClickHandler);
         this.__btn4.addEventListener(MouseEvent.CLICK,this.btn4ClickHandler);
         this.__btn5.addEventListener(MouseEvent.CLICK,this.btn5ClickHandler);
         this.__btn6.addEventListener(MouseEvent.CLICK,this.btn6ClickHandler);
         this.__btn7.addEventListener(MouseEvent.CLICK,this.btn7ClickHandler);
         this.__btn8.addEventListener(MouseEvent.CLICK,this.btn8ClickHandler);
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.okBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
      }
      
      private function clearFilter() : *
      {
         this.__btn1.filters = [];
         this.__btn2.filters = [];
         this.__btn3.filters = [];
         this.__btn4.filters = [];
         this.__btn5.filters = [];
         this.__btn6.filters = [];
         this.__btn7.filters = [];
         this.__btn8.filters = [];
      }
      
      private function btn1ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.clearFilter();
         this.__btn1.filters = [new GlowFilter(16763904,1,5,5,50)];
         this._currentServer = 1;
      }
      
      private function btn2ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.clearFilter();
         this.__btn2.filters = [new GlowFilter(16763904,1,5,5,50)];
         this._currentServer = 2;
      }
      
      private function btn3ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.clearFilter();
         this.__btn3.filters = [new GlowFilter(16763904,1,5,5,50)];
         this._currentServer = 3;
      }
      
      private function btn4ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.clearFilter();
         this.__btn4.filters = [new GlowFilter(16763904,1,5,5,50)];
         this._currentServer = 4;
      }
      
      private function btn5ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.clearFilter();
         this.__btn5.filters = [new GlowFilter(16763904,1,5,5,50)];
         this._currentServer = 5;
      }
      
      private function btn6ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.clearFilter();
         this.__btn6.filters = [new GlowFilter(16763904,1,5,5,50)];
         this._currentServer = 6;
      }
      
      private function btn7ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.clearFilter();
         this.__btn7.filters = [new GlowFilter(16763904,1,5,5,50)];
         this._currentServer = 7;
      }
      
      private function btn8ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.clearFilter();
         this.__btn8.filters = [new GlowFilter(16763904,1,5,5,50)];
         this._currentServer = 8;
      }
      
      private function okBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._currentServer < 1)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"请选择需要登录的服务器。"
            }));
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.SERVER_SELECTED,true,{
               "serverID":this._currentServer,
               "newPlayer":this.newPlayer
            }));
         }
      }
   }
}
