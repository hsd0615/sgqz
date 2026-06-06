package game.ui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import game.events.UIEvent;
   
   public class Zhuanpan extends Sprite
   {
       
      
      private var _applicationDomain:ApplicationDomain;
      
      private var _buttonArr:Array;
      
      private var _buttonCode:String;
      
      private var _r:Number = 90;
      
      private var _speed:Number = 1;
      
      private var _direct:int = -1;
      
      public function Zhuanpan(param1:String, param2:ApplicationDomain = null)
      {
         super();
         this._buttonCode = param1;
         if(param2 == null)
         {
            this._applicationDomain = ApplicationDomain.currentDomain;
         }
         else
         {
            this._applicationDomain = param2;
         }
         this.createButton();
         addEventListener(Event.REMOVED_FROM_STAGE,this.removeFromStageHandler);
         addEventListener(MouseEvent.CLICK,this.onMouseClickHandler);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHandler);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutHandler);
      }
      
      public function createButton() : *
      {
         var _loc3_:Point = null;
         var _loc1_:Class = null;
         var _loc2_:MovieClip = null;
         _loc3_ = null;
         this._buttonArr = [];
         var _loc4_:int = 0;
         while(_loc4_ < 10)
         {
            _loc1_ = this._applicationDomain.getDefinition(this._buttonCode + _loc4_) as Class;
            _loc2_ = new _loc1_() as MovieClip;
            _loc2_.buttonMode = true;
            _loc3_ = this.getPosByAngle(_loc4_ * 36);
            _loc2_.x = _loc3_.x;
            _loc2_.y = _loc3_.y;
            _loc2_.name = "button|" + _loc4_ + "|" + _loc4_ * 36;
            addChild(_loc2_);
            this._buttonArr.push(_loc2_);
            _loc4_++;
         }
      }
      
      private function getPosByAngle(param1:Number) : Point
      {
         var _loc2_:Number = param1 * Math.PI / 180;
         var _loc3_:Number = this._r * Math.cos(_loc2_);
         var _loc4_:Number = this._r * Math.sin(_loc2_);
         return new Point(_loc3_,_loc4_);
      }
      
      public function run() : *
      {
         addEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
      }
      
      public function get speed() : Number
      {
         return this._speed;
      }
      
      public function set speed(param1:Number) : *
      {
         this._speed = param1;
      }
      
      public function get direct() : int
      {
         return this._direct;
      }
      
      public function set direct(param1:int) : *
      {
         this._direct = param1;
      }
      
      private function enterFrameHandler(param1:Event) : *
      {
         var _loc2_:Number = NaN;
         var _loc3_:Point = null;
         this._speed = (mouseX * mouseX + mouseY * mouseY - 15000) / 2500;
         if(this._speed > 10)
         {
            this._speed = 10;
         }
         else if(this._speed < 1)
         {
            this._speed = 1;
         }
         var _loc4_:int = 0;
         while(_loc4_ < 10)
         {
            _loc2_ = Number(this._buttonArr[_loc4_].name.split("|")[2]);
            _loc2_ += this._direct * this._speed;
            _loc3_ = this.getPosByAngle(_loc2_);
            this._buttonArr[_loc4_].x = _loc3_.x;
            this._buttonArr[_loc4_].y = _loc3_.y;
            this._buttonArr[_loc4_].name = "button|" + _loc4_ + "|" + _loc2_;
            _loc4_++;
         }
      }
      
      private function onMouseClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(param1.target is MovieClip)
         {
            dispatchEvent(new UIEvent(UIEvent.ZHUANPAN_CLICK,true,{"value":int(param1.target.name.split("|")[1])}));
         }
      }
      
      private function onMouseOverHandler(param1:MouseEvent) : *
      {
         var _loc2_:int = 0;
         while(_loc2_ < 10)
         {
            this._buttonArr[_loc2_].gotoAndStop(2);
            _loc2_++;
         }
      }
      
      private function onMouseOutHandler(param1:MouseEvent) : *
      {
         var _loc2_:int = 0;
         while(_loc2_ < 10)
         {
            this._buttonArr[_loc2_].gotoAndStop(1);
            _loc2_++;
         }
      }
      
      public function stop() : *
      {
         removeEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
      }
      
      private function removeFromStageHandler(param1:Event) : *
      {
         this.stop();
      }
   }
}
