package com.iflashigame.ui
{
   import flash.display.Shape;
   import flash.display.Sprite;
   
   public class ProgressBar extends Sprite
   {
       
      
      private var _width:int;
      
      private var _height:int;
      
      private var _fillType:int;
      
      private var _barColor:uint;
      
      private var _barAlpha:Number;
      
      private var _lineColor:uint;
      
      private var _lineAlpha:Number;
      
      private var _lineWidth:Number;
      
      private var _fillColor:uint;
      
      private var _fillAlpha:Number;
      
      private var _bk:Shape;
      
      private var _bar:Shape;
      
      private var _max:Number = 100;
      
      private var _current:Number = 100;
      
      public function ProgressBar(param1:int, param2:int, param3:int = 1, param4:uint = 16711680, param5:Number = 1, param6:uint = 14540253, param7:Number = 1, param8:Number = 1, param9:uint = 10027008, param10:Number = 1)
      {
         super();
         this._width = param1;
         this._height = param2;
         this._fillType = param3;
         this._barColor = param4;
         this._barAlpha = param5;
         this._lineColor = param6;
         this._lineAlpha = param7;
         this._lineWidth = param8;
         this._fillColor = param9;
         this._fillAlpha = param10;
         this.drawBK();
         this.drawBar();
      }
      
      private function drawBK() : *
      {
         this._bk = new Shape();
         this._bk.graphics.beginFill(this._fillColor,this._fillAlpha);
         this._bk.graphics.lineStyle(this._lineWidth,this._lineColor,this._lineAlpha,true,"none");
         this._bk.graphics.drawRect(0,0,this._width,this._height);
         this._bk.graphics.endFill();
         addChild(this._bk);
      }
      
      private function drawBar() : *
      {
         this._bar = new Shape();
         this._bar.graphics.beginFill(this._barColor,this._barAlpha);
         this._bar.graphics.lineStyle(this._lineWidth,this._lineColor,this._lineAlpha,true,"none");
         this._bar.graphics.drawRect(0,0,this._width,this._height);
         this._bar.graphics.endFill();
         addChild(this._bar);
      }
      
      public function setScale(param1:Number, param2:Number) : *
      {
         this._current = param1;
         this._max = param2;
         if(this._current < 0)
         {
            this._current = 0;
         }
         if(this._current > this._max)
         {
            this._current = this._max;
         }
         var _loc3_:Number = this._current / this._max;
         this._bar.scaleX = _loc3_;
      }
      
      public function setMax(param1:Number, param2:Boolean = false) : *
      {
         if(param2)
         {
            this.setScale(param1,param1);
         }
         else
         {
            this.setScale(this._current,param1);
         }
      }
      
      public function setCurrent(param1:Number, param2:Boolean = false) : *
      {
         if(param2)
         {
            this.setScale(param1,param1);
         }
         else
         {
            this.setScale(param1,this._max);
         }
      }
      
      public function getMax() : Number
      {
         return this._max;
      }
      
      public function getCurrent() : Number
      {
         return this._current;
      }
   }
}
