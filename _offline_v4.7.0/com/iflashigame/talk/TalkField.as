package com.iflashigame.talk
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import game.ui.list.IScrollElement;
   
   public class TalkField extends Sprite implements IScrollElement
   {
       
      
      private var _tf:TextField;
      
      private var _tfMask:Sprite;
      
      private var _faceContainer:Sprite;
      
      private var _maskWidth:Number;
      
      private var _maskHeight:Number;
      
      private var _textFormat:TextFormat;
      
      private var _leading:Number;
      
      private var _textColor:uint;
      
      private var _alpha:Number;
      
      private var _appDomain:ApplicationDomain;
      
      public function TalkField(param1:Number, param2:Number, param3:ApplicationDomain = null, param4:Number = 2, param5:uint = 15658734, param6:Number = 0)
      {
         super();
         this._maskWidth = param1;
         this._maskHeight = param2;
         this._leading = param4;
         this._textColor = param5;
         this._alpha = param6;
         this._appDomain = param3 == null ? ApplicationDomain.currentDomain : param3;
         this.initView();
         this.initEvent();
      }
      
      private function initView() : *
      {
         this.createBK();
         this.createMask();
         this.createTF();
         this.createFaceContainer();
      }
      
      private function initEvent() : *
      {
         addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheelHandler);
      }
      
      private function onMouseWheelHandler(param1:MouseEvent) : void
      {
         this.maskY -= param1.delta * 4;
         dispatchEvent(new Event("scroll"));
      }
      
      private function createBK() : *
      {
         graphics.beginFill(0,this._alpha);
         graphics.drawRect(-5,-2,this._maskWidth + 10,this._maskHeight + 14);
         graphics.endFill();
      }
      
      private function createMask() : *
      {
         this._tfMask = new Sprite();
         this._tfMask.graphics.beginFill(0);
         this._tfMask.graphics.drawRect(0,0,this._maskWidth,this._maskHeight);
         this._tfMask.graphics.endFill();
         addChild(this._tfMask);
      }
      
      private function createTF() : *
      {
         this._textFormat = new TextFormat();
         this._textFormat.color = this._textColor;
         this._textFormat.size = 12;
         this._textFormat.letterSpacing = 0.75;
         this._textFormat.leading = this._leading;
         this._tf = new TextField();
         this._tf.textColor = 15658734;
         this._tf.width = this._maskWidth;
         this._tf.defaultTextFormat = this._textFormat;
         this._tf.selectable = false;
         this._tf.multiline = true;
         this._tf.wordWrap = true;
         this._tf.autoSize = "left";
         this._tf.filters = [new GlowFilter(0,0.95,2,2,10)];
         this._tf.mouseWheelEnabled = false;
         addChild(this._tf);
         this._tf.mask = this._tfMask;
      }
      
      private function createFaceContainer() : *
      {
         this._faceContainer = new Sprite();
         this._faceContainer.scrollRect = new Rectangle(0,0,this._maskWidth,this._maskHeight);
         addChild(this._faceContainer);
      }
      
      private function clearFaceContain() : *
      {
         while(this._faceContainer.numChildren > 0)
         {
            this._faceContainer.removeChildAt(0);
         }
      }
      
      public function setText(param1:String) : *
      {
         var _loc4_:MovieClip = null;
         var _loc2_:Rectangle = null;
         var _loc3_:Class = null;
         _loc4_ = null;
         this._tf.text = "";
         this._tf.defaultTextFormat = this._textFormat;
         var _loc5_:Array = [];
         this.clearFaceContain();
         var _loc6_:Array;
         if((_loc6_ = param1.match(/\*(0[1-9]|[1-4][0-9]|5[0-3])/g)) != null)
         {
            _loc5_ = _loc5_.concat(_loc6_);
         }
         param1 = param1.replace(/\*(0[1-9]|[1-4][0-9]|5[0-3])/g,"<font size=\'24\'>　</font>");
         this._tf.htmlText = param1;
         this._tf.height;
         var _loc7_:String = this._tf.text;
         var _loc8_:Array = [];
         var _loc9_:int = 0;
         while(_loc9_ < _loc7_.length)
         {
            if(_loc7_.charAt(_loc9_) == "　")
            {
               _loc8_.push(_loc9_);
            }
            _loc9_++;
         }
         this._tf.height;
         var _loc10_:* = 0;
         while(_loc10_ < _loc8_.length)
         {
            _loc2_ = this._tf.getCharBoundaries(_loc8_[_loc10_]);
            _loc3_ = this._appDomain.getDefinition("face" + _loc5_[_loc10_].substr(1,2)) as Class;
            if(_loc3_ != null && _loc2_ != null)
            {
               _loc4_ = new _loc3_() as MovieClip;
               this._faceContainer.addChild(_loc4_);
               _loc4_.x = _loc2_.x;
               _loc4_.y = _loc2_.y + 3;
            }
            _loc10_++;
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function setMultiText(param1:Array) : *
      {
         var _loc4_:Rectangle = null;
         var _loc6_:MovieClip = null;
         var _loc2_:String = null;
         var _loc3_:Array = null;
         _loc4_ = null;
         var _loc5_:Class = null;
         _loc6_ = null;
         if(param1 == null)
         {
            return;
         }
         this._tf.text = "";
         this._tf.defaultTextFormat = this._textFormat;
         var _loc7_:Array = [];
         this.clearFaceContain();
         var _loc8_:String = "";
         var _loc9_:* = 0;
         while(_loc9_ < param1.length)
         {
            _loc2_ = String(param1[_loc9_]);
            _loc3_ = _loc2_.match(/\*(0[1-9]|[1-4][0-9]|5[0-3])/g);
            if(_loc3_ != null)
            {
               _loc7_ = _loc7_.concat(_loc3_);
            }
            _loc2_ = _loc2_.replace(/\*(0[1-9]|[1-4][0-9]|5[0-3])/g,"<font size=\'24\'>　</font>");
            _loc8_ += _loc2_;
            _loc9_++;
         }
         this._tf.htmlText = _loc8_;
         this._tf.height;
         var _loc10_:String = this._tf.text;
         var _loc11_:Array = [];
         var _loc12_:int = 0;
         while(_loc12_ < _loc10_.length)
         {
            if(_loc10_.charAt(_loc12_) == "　")
            {
               _loc11_.push(_loc12_);
            }
            _loc12_++;
         }
         this._tf.height;
         var _loc13_:* = 0;
         while(_loc13_ < _loc11_.length)
         {
            _loc4_ = this._tf.getCharBoundaries(_loc11_[_loc13_]);
            if((_loc5_ = this._appDomain.getDefinition("face" + _loc7_[_loc13_].substr(1,2)) as Class) != null && _loc4_ != null)
            {
               _loc6_ = new _loc5_() as MovieClip;
               this._faceContainer.addChild(_loc6_);
               _loc6_.x = _loc4_.x;
               _loc6_.y = _loc4_.y + 3;
            }
            _loc13_++;
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get maskX() : Number
      {
         return this._faceContainer.scrollRect.x;
      }
      
      public function set maskX(param1:Number) : *
      {
         var _loc2_:Rectangle = null;
         _loc2_ = this._faceContainer.scrollRect;
         _loc2_.x = param1;
         this._tf.x = -param1;
         this._faceContainer.scrollRect = _loc2_;
      }
      
      public function get maskY() : Number
      {
         return this._faceContainer.scrollRect.y;
      }
      
      public function set maskY(param1:Number) : *
      {
         var _loc2_:Rectangle = this._faceContainer.scrollRect;
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > this.maxScroll)
         {
            param1 = this.maxScroll;
         }
         this._tf.y = -param1;
         _loc2_.y = param1;
         this._faceContainer.scrollRect = _loc2_;
      }
      
      public function get minScroll() : Number
      {
         return 0;
      }
      
      public function get maxScroll() : Number
      {
         if(this._tf.height <= this._tfMask.height)
         {
            return 0;
         }
         return this._tf.height - this._tfMask.height;
      }
   }
}
