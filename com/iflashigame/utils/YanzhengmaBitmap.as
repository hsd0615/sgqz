package com.iflashigame.utils
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class YanzhengmaBitmap extends Sprite
   {
       
      
      private var num:int;
      
      private var arr:Array;
      
      private var color:Array;
      
      private var font:Array;
      
      private var vColor:Array;
      
      private var w:int;
      
      private var h:int;
      
      private var r:int = 15;
      
      private var fontLayer:Sprite;
      
      private var bkLayer:Bitmap;
      
      private var tempStr:String;
      
      public function YanzhengmaBitmap(param1:Number, param2:Number)
      {
         this.arr = ["0","1","2","3","4","5","6","7","8","9"];
         super();
         this.init();
         this.num = 4;
         this.w = param1;
         this.h = param2;
      }
      
      private function init() : void
      {
         this.color = new Array();
         this.color.push(0);
         this.color.push(102);
         this.color.push(3342336);
         this.color.push(47);
         this.font = new Array();
         this.font.push("黑体");
         this.font.push("Comic Sans MS");
         this.font.push("Arial");
         this.font.push("Symbol");
         this.vColor = new Array();
         this.vColor.push(16751103);
         this.vColor.push(16764159);
         this.vColor.push(16764057);
         this.vColor.push(10066431);
      }
      
      public function create() : *
      {
         if(this.bkLayer != null)
         {
            removeChild(this.bkLayer);
            this.bkLayer = null;
         }
         this.bkLayer = this.makeV(this.w,this.h);
         this.bkLayer.alpha = 0.8;
         addChild(this.bkLayer);
         if(this.fontLayer != null)
         {
            removeChild(this.fontLayer);
            this.fontLayer = null;
         }
         this.fontLayer = this.makeFont();
         this.fontLayer.alpha = 0.6;
         addChild(this.fontLayer);
      }
      
      public function getValue() : String
      {
         return this.tempStr;
      }
      
      private function makeV(param1:int, param2:int) : Bitmap
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:uint = 0;
         var _loc6_:BitmapData = new BitmapData(param1,param2);
         var _loc7_:int = 0;
         while(_loc7_ < 10000)
         {
            _loc4_ = Math.random() * param2;
            _loc3_ = Math.random() * param1;
            _loc5_ = Tools.randomFromArr(this.vColor);
            _loc6_.setPixel(_loc3_,_loc4_,_loc5_);
            _loc7_++;
         }
         return new Bitmap(_loc6_);
      }
      
      private function makeFont() : Sprite
      {
         var _loc1_:Sprite = null;
         var _loc2_:TextField = null;
         _loc1_ = null;
         _loc2_ = null;
         var _loc3_:TextFormat = null;
         this.tempStr = Tools.randomFromArr(this.arr) + Tools.randomFromArr(this.arr) + Tools.randomFromArr(this.arr) + Tools.randomFromArr(this.arr);
         trace(this.tempStr);
         _loc1_ = new Sprite();
         var _loc4_:int = 0;
         while(_loc4_ < this.num)
         {
            _loc2_ = new TextField();
            _loc2_.text = this.tempStr.charAt(_loc4_);
            _loc2_.textColor = uint(Tools.randomFromArr(this.color));
            _loc3_ = new TextFormat();
            _loc3_.color = uint(Tools.randomFromArr(this.color));
            _loc3_.font = Tools.randomFromArr(this.font);
            _loc3_.size = 60;
            _loc2_.setTextFormat(_loc3_);
            _loc2_.x = 10 + _loc4_ * 40;
            _loc2_.y = this.setRandom(-5,5) + 7;
            _loc2_.selectable = false;
            _loc1_.addChild(_loc2_);
            _loc4_++;
         }
         return _loc1_;
      }
      
      private function setRandom(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = NaN;
         _loc3_ = Math.random() * (param2 - param1);
         return _loc3_ + param1;
      }
   }
}
