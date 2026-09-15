package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import game.events.UIEvent;
   
   public class Alert extends BaseUI
   {
       
      
      private var __textTF:TextField;
      
      private var __closeBtn:SimpleButton;
      
      private var __okBtn:SimpleButton;
      
      private var __cancelBtn:SimpleButton;
      
      private var _fun:Function;
      
      private var _cancelFun:Function;
      
      public function Alert(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__textTF = _skin.getChildByName("_textTF") as TextField;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this.__cancelBtn = _skin.getChildByName("_cancelBtn") as SimpleButton;
      }
      
      override protected function initEvent() : void
      {
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.onCloseClickHandler);
         this.__cancelBtn.addEventListener(MouseEvent.CLICK,this.onCancelClickHandler);
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.onOKClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         var _loc2_:TextFormat = null;
         this.__textTF.text = param1.text;
         if(this.__textTF.numLines > 1)
         {
            this.__textTF.height = this.__textTF.textHeight + 4;
            _loc2_ = new TextFormat();
            _loc2_.align = "left";
            this.__textTF.defaultTextFormat = _loc2_;
            this.__textTF.text = param1.text;
            this.__textTF.y = -this.__textTF.height / 2 - 20;
         }
         this._fun = param1.fun;
         this._cancelFun = param1.cancelFun;
         if(param1.type == 0)
         {
            this.__cancelBtn.visible = false;
            this.__okBtn.visible = false;
         }
         else if(param1.type == 1)
         {
            this.__closeBtn.visible = false;
         }
      }
      
      private function onCloseClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this.__okBtn.visible == false && this.__cancelBtn.visible == false)
         {
            if(this._fun != null)
            {
               this._fun();
               this._fun == null;
            }
         }
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
      
      private function onCancelClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
         if(this._cancelFun != null)
         {
            this._cancelFun();
            this._cancelFun == null;
         }
      }
      
      private function onOKClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
         if(this._fun != null)
         {
            this._fun();
            this._fun == null;
         }
      }
   }
}
