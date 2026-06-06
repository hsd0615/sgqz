package com.iflashigame.talk
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.system.ApplicationDomain;
   
   public class FaceList extends Sprite
   {
       
      
      private var _tileWidth:int = 24;
      
      private var _tileHeight:int = 24;
      
      private var _columnCount:int = 10;
      
      private var _border:int = 2;
      
      private var _appDomain:ApplicationDomain;
      
      public function FaceList(param1:int, param2:ApplicationDomain = null)
      {
         super();
         this._appDomain = param2 == null ? ApplicationDomain.currentDomain : param2;
         this.initFaceList(param1);
      }
      
      private function initFaceList(param1:int) : *
      {
         var _loc2_:Class = null;
         var _loc3_:MovieClip = null;
         var _loc4_:* = undefined;
         var _loc5_:Array = [];
         var _loc6_:* = 1;
         while(_loc6_ <= param1)
         {
            if(_loc6_ < 10)
            {
               _loc5_.push("face0" + _loc6_);
            }
            else
            {
               _loc5_.push("face" + _loc6_);
            }
            _loc6_++;
         }
         var _loc7_:Array = new Array();
         var _loc8_:* = 0;
         while(_loc8_ < _loc5_.length)
         {
            _loc2_ = this._appDomain.getDefinition(_loc5_[_loc8_].toString()) as Class;
            _loc3_ = new _loc2_() as MovieClip;
            (_loc4_ = new Object()).name = _loc5_[_loc8_];
            _loc4_.source = _loc3_;
            _loc7_.push(_loc4_);
            _loc8_++;
         }
         this.setDP(_loc7_);
      }
      
      private function setDP(param1:Array) : *
      {
         var _loc4_:int = 0;
         var _loc2_:* = undefined;
         var _loc3_:MovieClip = null;
         _loc4_ = 0;
         var _loc5_:int = 0;
         var _loc6_:int;
         if((_loc6_ = int(param1.length)) > 0)
         {
            _loc2_ = 1;
            while(_loc2_ <= _loc6_)
            {
               _loc3_ = new MovieClip();
               _loc3_.mouseChildren = false;
               _loc3_.graphics.beginFill(0,0.6);
               _loc3_.graphics.lineStyle(1,0);
               _loc3_.graphics.drawRect(0,0,this._tileWidth + this._border * 2,this._tileHeight + this._border * 2);
               _loc3_.graphics.endFill();
               _loc3_.source = param1[_loc2_ - 1].source;
               _loc3_.source.x = _loc3_.source.y = this._border;
               _loc3_.addChild(_loc3_.source);
               _loc3_.index = _loc2_;
               _loc3_.name = param1[_loc2_ - 1].name;
               _loc4_ = Math.ceil(_loc3_.index / this._columnCount);
               _loc5_ = _loc2_ - this._columnCount * (_loc4_ - 1);
               _loc3_.x = (_loc5_ - 1) * (this._tileWidth + this._border * 2);
               _loc3_.y = (_loc4_ - 1) * (this._tileHeight + this._border * 2);
               addChild(_loc3_);
               _loc3_.buttonMode = true;
               _loc2_++;
            }
            graphics.beginFill(16777215,0.6);
            graphics.drawRect(0,0,width,height);
            graphics.endFill();
         }
      }
   }
}
