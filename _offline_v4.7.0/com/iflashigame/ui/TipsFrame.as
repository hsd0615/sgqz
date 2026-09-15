package com.iflashigame.ui
{
   import flash.display.Sprite;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   
   public class TipsFrame extends Sprite
   {
       
      
      protected var _tf:TextField;
      
      protected var _width:int = 200;
      
      protected var _height:int = 50;
      
      protected var _bordColor:uint = 51;
      
      protected var _bodyColor:uint = 51;
      
      protected var _bordAlpha:Number = 1;
      
      protected var _bodyAlpha:Number = 0.5;
      
      protected var _bordSize:Number = 2;
      
      protected var _focus:Boolean;
      
      public var type:int = 1;
      
      public function TipsFrame()
      {
         super();
         this.initView();
      }
      
      private function initView() : *
      {
         mouseEnabled = false;
         this._tf = new TextField();
         this._tf.textColor = 16777215;
         addChild(this._tf);
         this._tf.multiline = true;
         this._tf.wordWrap = true;
         this._tf.width = this._width;
         this._tf.selectable = false;
      }
      
      public function initData(param1:Object) : *
      {
         if(param1.hasOwnProperty("width"))
         {
            this._width = param1.width;
         }
         if(param1.hasOwnProperty("height"))
         {
            this._height = param1.height;
         }
         if(param1.hasOwnProperty("bordColor"))
         {
            this._bordColor = param1.bordColor;
         }
         if(param1.hasOwnProperty("bodyColor"))
         {
            this._bodyColor = param1.bodyColor;
         }
         if(param1.hasOwnProperty("bordAlpha"))
         {
            this._bordAlpha = param1.bordAlpha;
         }
         if(param1.hasOwnProperty("bodyAlpha"))
         {
            this._bodyAlpha = param1.bodyAlpha;
         }
         if(param1.hasOwnProperty("bordSize"))
         {
            this._bordSize = param1.bordSize;
         }
         if(param1.hasOwnProperty("type"))
         {
            this.type = param1.type;
         }
         if(param1.hasOwnProperty("focus"))
         {
            this._focus = Boolean(param1.focus);
         }
         this._tf.htmlText = param1.htmlText;
         this._tf.width = 500;
         this._tf.width = this._tf.textWidth + 5;
         this._width = this._tf.width;
         this._tf.height = this._tf.textHeight + 5;
         this._tf.filters = [new GlowFilter(0,1,2,2,1000)];
         this._tf.x = 6;
         this._tf.y = 6;
         graphics.clear();
         graphics.beginFill(this._bodyColor,this._bodyAlpha);
         graphics.lineStyle(this._bordSize,this._bordColor,this._bordAlpha);
         graphics.drawRoundRect(0,0,this._width + 12,this._height + 12,5,5);
         filters = [new DropShadowFilter(4,45,0,0.5)];
      }
   }
}
