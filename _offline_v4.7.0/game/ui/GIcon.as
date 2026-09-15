package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.events.ConEvent;
   import game.model.ArmyInfo;
   
   public class GIcon extends BaseUI
   {
       
      
      private var __tf:TextField;
      
      private var __icon:MovieClip;
      
      private var _id:Number = -1;
      
      private var _code:String = "";
      
      public var index:int = -1;
      
      private var _dead:Boolean = false;
      
      public function GIcon(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__tf = _skin.getChildByName("_tf") as TextField;
         this.__icon = _skin.getChildByName("_icon") as MovieClip;
         this.__icon.visible = false;
         this.__tf.visible = false;
         this.__icon.buttonMode = true;
      }
      
      override protected function initEvent() : void
      {
         this.__icon.addEventListener(MouseEvent.MOUSE_OVER,this.iconMouseOverHandler);
         this.__icon.addEventListener(MouseEvent.MOUSE_OUT,this.iconMouseOutHandler);
         this.__icon.addEventListener(MouseEvent.CLICK,this.iconClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         if(param1 == null || !(param1 is ArmyInfo))
         {
            this._id = -1;
            this._code = "";
            this.__icon.visible = false;
            this.__tf.visible = false;
         }
         else
         {
            this.__icon.visible = true;
            this.__tf.visible = true;
            this._id = param1.id;
            this._code = param1.code;
            this.__icon.gotoAndStop(param1.type);
            this.__tf.text = param1.name;
         }
      }
      
      public function get id() : Number
      {
         return this._id;
      }
      
      public function get code() : String
      {
         return this._code;
      }
      
      private function iconMouseOverHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.__icon.scaleX = 1.2;
         this.__icon.scaleY = 1.2;
      }
      
      private function iconMouseOutHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.__icon.scaleX = 1;
         this.__icon.scaleY = 1;
      }
      
      private function iconClickHandler(param1:MouseEvent) : *
      {
         if(param1 != null)
         {
            param1.stopImmediatePropagation();
         }
         dispatchEvent(new ConEvent(ConEvent.SELECT_SOLDIER,true,{
            "id":this._id,
            "code":this._code,
            "index":this.index
         }));
      }
      
      public function dead() : *
      {
         this._dead = true;
         Tools.setDisabled(this.__icon,true);
      }
      
      public function setSelect() : *
      {
         if(!this._dead)
         {
            this.iconClickHandler(null);
         }
      }
   }
}
