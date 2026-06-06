package game.ui
{
   import com.iflashigame.controller.AESController;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.YanzhengmaBitmap;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.Config;
   import game.events.UIEvent;
   import game.model.Head;
   import game.model.RoleModel;
   
   public class YanzhengPanel extends BaseUI
   {
       
      
      private var __okBtn:SimpleButton;
      
      private var __tf1:TextField;
      
      private var __tf2:TextField;
      
      private var __tf3:TextField;
      
      private var __tf4:TextField;
      
      private var _zhuanpan:Zhuanpan;
      
      private var _value:int;
      
      private var _currentTF:TextField;
      
      private var _maBitmap:YanzhengmaBitmap;
      
      private var _color:uint = 16737843;
      
      public function YanzhengPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this.__tf1 = _skin.getChildByName("_tf1") as TextField;
         this.__tf2 = _skin.getChildByName("_tf2") as TextField;
         this.__tf3 = _skin.getChildByName("_tf3") as TextField;
         this.__tf4 = _skin.getChildByName("_tf4") as TextField;
      }
      
      override protected function initEvent() : void
      {
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.okBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this.createZhuanpan();
         this.flush();
      }
      
      private function createZhuanpan() : *
      {
         this._zhuanpan = new Zhuanpan(SkinCode.YANZHENGMA_BTN);
         this._zhuanpan.x = 135;
         this._zhuanpan.y = -15;
         addChild(this._zhuanpan);
         this._zhuanpan.run();
         this._zhuanpan.addEventListener(UIEvent.ZHUANPAN_CLICK,this.inputHandler);
      }
      
      private function inputHandler(param1:UIEvent) : *
      {
         if(this._currentTF != null)
         {
            this._currentTF.text = param1.data.value;
            if(this._currentTF == this.__tf1)
            {
               this.__tf1.backgroundColor = 16777215;
               this.__tf2.backgroundColor = this._color;
               this._currentTF = this.__tf2;
            }
            else if(this._currentTF == this.__tf2)
            {
               this.__tf2.backgroundColor = 16777215;
               this.__tf3.backgroundColor = this._color;
               this._currentTF = this.__tf3;
            }
            else if(this._currentTF == this.__tf3)
            {
               this.__tf3.backgroundColor = 16777215;
               this.__tf4.backgroundColor = this._color;
               this._currentTF = this.__tf4;
            }
            else if(this._currentTF == this.__tf4)
            {
               this.__tf4.backgroundColor = 16777215;
               this.__tf1.backgroundColor = this._color;
               this._currentTF = this.__tf1;
            }
         }
      }
      
      public function flush() : *
      {
         this.__tf1.text = "";
         this.__tf2.text = "";
         this.__tf3.text = "";
         this.__tf4.text = "";
         this._currentTF = this.__tf1;
         this._currentTF.backgroundColor = this._color;
         this.createBitMap();
      }
      
      private function createBitMap() : *
      {
         if(this._maBitmap != null)
         {
            removeChild(this._maBitmap);
            this._maBitmap = null;
         }
         this._maBitmap = new YanzhengmaBitmap(180,70);
         this._maBitmap.create();
         this._maBitmap.x = -230;
         this._maBitmap.y = -90;
         addChild(this._maBitmap);
      }
      
      private function okBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         var _loc2_:String = this.__tf1.text + this.__tf2.text + this.__tf3.text + this.__tf4.text;
         if(_loc2_ == this._maBitmap.getValue())
         {
            this.sendToHttpNew();
         }
         else
         {
            this.flush();
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"验证码输入错误，请重新输入！"
            }));
         }
      }
      
      private function sendToHttpNew() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_YANZHENG;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         _loc1_.mask = true;
         AESController.getInstance().sendJSON(_loc1_,this.yanzhengResponse);
      }
      
      private function yanzhengResponse(param1:Object) : *
      {
         var _loc2_:int = 0;
         if(param1.success == true)
         {
            _loc2_ = param1.data.money - RoleModel.getInstance().money;
            RoleModel.getInstance().money = param1.data.money;
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"验证码输入正确，获得奖励" + _loc2_ + "银子！"
            }));
            dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
   }
}
