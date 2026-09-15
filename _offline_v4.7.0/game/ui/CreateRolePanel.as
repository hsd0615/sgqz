package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.TextFilter;
   import com.iflashigame.utils.Tools;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.events.UIEvent;
   
   public class CreateRolePanel extends BaseUI
   {
       
      
      private var __img1:MovieClip;
      
      private var __img2:MovieClip;
      
      private var __nameTF:TextField;
      
      private var __okBtn:SimpleButton;
      
      private var __closeBtn:SimpleButton;
      
      public var p2p:Boolean;
      
      private var _select:int = -1;
      
      public function CreateRolePanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__img1 = _skin.getChildByName("_img1") as MovieClip;
         this.__img2 = _skin.getChildByName("_img2") as MovieClip;
         this.__nameTF = _skin.getChildByName("_nameTF") as TextField;
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__img1.buttonMode = true;
         this.__img2.buttonMode = true;
         this._select = 1;
         this.__img1.gotoAndStop(2);
         this.__nameTF.restrict = "^[]<> /\'\"|#　";
      }
      
      override protected function initEvent() : void
      {
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.onOKBtnClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.onCloseBtnClickHandler);
         this.__img1.addEventListener(MouseEvent.CLICK,this.onImg1ClickHandler);
         this.__img2.addEventListener(MouseEvent.CLICK,this.onImg2ClickHandler);
         this.__img1.addEventListener(MouseEvent.MOUSE_OVER,this.onImgMouseOverHandler);
         this.__img2.addEventListener(MouseEvent.MOUSE_OVER,this.onImgMouseOverHandler);
         this.__img1.addEventListener(MouseEvent.MOUSE_OUT,this.onImgMouseOutHandler);
         this.__img2.addEventListener(MouseEvent.MOUSE_OUT,this.onImgMouseOutHandler);
      }
      
      private function onImgMouseOverHandler(param1:MouseEvent) : *
      {
         if(param1.currentTarget == this.__img1)
         {
            if(this._select == 1)
            {
               Tools.setBright(this.__img1,0.2);
            }
            else
            {
               Tools.setBright(this.__img1,0.2);
            }
         }
         else if(this._select == 1)
         {
            Tools.setBright(this.__img2,0.2);
         }
         else
         {
            Tools.setBright(this.__img2,0.2);
         }
      }
      
      private function onImgMouseOutHandler(param1:MouseEvent) : *
      {
         if(param1.currentTarget == this.__img1)
         {
            if(this._select == 1)
            {
               Tools.setBright(this.__img1,0);
            }
            else
            {
               Tools.setBright(this.__img1,0);
            }
         }
         else if(this._select == 1)
         {
            Tools.setBright(this.__img2,0);
         }
         else
         {
            Tools.setBright(this.__img2,0);
         }
      }
      
      private function onImg1ClickHandler(param1:MouseEvent) : *
      {
         this._select = 1;
         this.__img1.gotoAndStop(2);
         this.__img2.gotoAndStop(1);
      }
      
      private function onImg2ClickHandler(param1:MouseEvent) : *
      {
         this._select = 2;
         this.__img1.gotoAndStop(1);
         this.__img2.gotoAndStop(2);
      }
      
      private function onOKBtnClickHandler(param1:MouseEvent) : *
      {
         if(this._select != -1 && this.__nameTF.text != "")
         {
            if(TextFilter.getInstance().checkText(this.__nameTF.text) == false)
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"你的名号不够响亮，还是换个名字吧！"
               }));
            }
            else
            {
               dispatchEvent(new UIEvent(UIEvent.CREATE_ROLE,true,{
                  "image":this._select,
                  "nickName":this.__nameTF.text
               }));
            }
         }
      }
      
      private function onCloseBtnClickHandler(param1:MouseEvent) : *
      {
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
      
      override public function initData(param1:Object) : void
      {
      }
   }
}
