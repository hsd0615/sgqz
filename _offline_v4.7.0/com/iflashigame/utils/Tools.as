package com.iflashigame.utils
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.SimpleButton;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class Tools
   {
       
      
      public function Tools()
      {
         super();
      }
      
      public static function setGray(param1:InteractiveObject, param2:Boolean) : *
      {
         var _loc3_:Array = null;
         var _loc4_:ColorMatrixFilter = null;
         var _loc5_:Array = null;
         if(param2)
         {
            _loc3_ = new Array();
            _loc3_ = _loc3_.concat([0.3086,0.6094,0.082,0,0]);
            _loc3_ = _loc3_.concat([0.3086,0.6094,0.082,0,0]);
            _loc3_ = _loc3_.concat([0.3086,0.6094,0.082,0,0]);
            _loc3_ = _loc3_.concat([0,0,0,1,0]);
            _loc4_ = new ColorMatrixFilter(_loc3_);
            (_loc5_ = new Array()).push(_loc4_);
            param1.filters = _loc5_;
         }
         else
         {
            param1.filters = [];
         }
      }
      
      public static function setDisabled(param1:InteractiveObject, param2:Boolean, param3:Boolean = true) : *
      {
         if(param3)
         {
            setGray(param1,param2);
         }
         if(param2)
         {
            if(param1 is SimpleButton)
            {
               (param1 as SimpleButton).enabled = false;
               param1.mouseEnabled = false;
            }
            else
            {
               param1.mouseEnabled = false;
               if(param1 is DisplayObjectContainer)
               {
                  (param1 as DisplayObjectContainer).mouseChildren = false;
               }
            }
         }
         else if(param1 is SimpleButton)
         {
            (param1 as SimpleButton).enabled = true;
            param1.mouseEnabled = true;
         }
         else
         {
            param1.mouseEnabled = true;
            if(param1 is DisplayObjectContainer)
            {
               (param1 as DisplayObjectContainer).mouseChildren = true;
            }
         }
      }
      
      public static function randomFromArr(param1:Array, param2:int = -1) : *
      {
         var _loc3_:int = 0;
         if(param2 == -1)
         {
            _loc3_ = int(param1.length);
         }
         else
         {
            _loc3_ = param1.length > param2 ? param2 : int(param1.length);
         }
         var _loc4_:int = Math.floor(_loc3_ * Math.random());
         return param1[_loc4_];
      }
      
      public static function clearContainer(param1:DisplayObjectContainer) : *
      {
         while(param1.numChildren > 0)
         {
            param1.removeChildAt(0);
         }
      }
      
      public static function setBright(param1:DisplayObject, param2:Number) : *
      {
         if(param1 == null)
         {
            return;
         }
         if(param2 < 0)
         {
            param2 = 0;
         }
         else if(param2 > 1)
         {
            param2 = 1;
         }
         var _loc3_:ColorTransform = param1.transform.colorTransform;
         var _loc4_:int = Math.round(255 * param2);
         _loc3_.redMultiplier = 1 - param2;
         _loc3_.greenMultiplier = 1 - param2;
         _loc3_.blueMultiplier = 1 - param2;
         _loc3_.redOffset = _loc4_;
         _loc3_.greenOffset = _loc4_;
         _loc3_.blueOffset = _loc4_;
         param1.transform.colorTransform = _loc3_;
      }
      
      public static function ChangeColor(param1:DisplayObject, param2:Number, param3:Number, param4:Number) : *
      {
         var _loc5_:ColorTransform;
         (_loc5_ = new ColorTransform()).redOffset = param2;
         _loc5_.blueOffset = param3;
         _loc5_.greenOffset = param4;
         param1.transform.colorTransform = _loc5_;
      }
      
      public static function selectObject(param1:DisplayObjectContainer, param2:Point, param3:Class) : *
      {
         var _loc4_:BitmapData = null;
         var _loc5_:Point = null;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         if(param1 == null)
         {
            return null;
         }
         var _loc8_:*;
         if((_loc8_ = param1.stage.getObjectsUnderPoint(param2)).length == 0)
         {
            return null;
         }
         var _loc9_:Rectangle = new Rectangle(0,0,1,1);
         var _loc10_:Matrix = new Matrix();
         var _loc11_:* = _loc8_.length - 1;
         while(_loc11_ >= 0)
         {
            _loc4_ = new BitmapData(1,1,true,0);
            _loc5_ = (_loc8_[_loc11_] as DisplayObject).globalToLocal(param2);
            _loc10_.tx = -int(_loc5_.x);
            _loc10_.ty = -int(_loc5_.y);
            if(!param1.contains(_loc8_[_loc11_] as DisplayObject))
            {
               return null;
            }
            _loc4_.draw(_loc8_[_loc11_],_loc10_,null,null,_loc9_);
            _loc6_ = _loc4_.getPixel32(0,0);
            if((_loc7_ = uint(_loc6_ >> 24 & 255)) != 129 && _loc6_ != 0)
            {
               _loc4_.dispose();
               if(_loc8_[_loc11_] is param3)
               {
                  return _loc8_[_loc11_] as param3;
               }
               while(_loc8_[_loc11_] != param1)
               {
                  _loc8_[_loc11_] = _loc8_[_loc11_].parent;
                  if(_loc8_[_loc11_] is param3)
                  {
                     return _loc8_[_loc11_] as param3;
                  }
               }
            }
            _loc11_--;
         }
         return null;
      }
      
      public static function getJilv(param1:Number, param2:int = 100) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(param1 == 1)
         {
            return true;
         }
         if(param1 == 0)
         {
            return false;
         }
         var _loc11_:Vector.<Boolean> = new Vector.<Boolean>(param2,true);
         if(param1 > 0.5)
         {
            param1 = 1 - param1;
            _loc3_ = 0;
            while(_loc3_ < param2)
            {
               _loc11_[_loc3_] = true;
               _loc3_++;
            }
            _loc4_ = int(param1 * param2);
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc6_ = int(Math.random() * param2);
               if(_loc11_[_loc6_] == true)
               {
                  _loc11_[_loc6_] = false;
                  _loc5_++;
               }
            }
         }
         else
         {
            _loc7_ = 0;
            while(_loc7_ < param2)
            {
               _loc11_[_loc7_] = false;
               _loc7_++;
            }
            _loc8_ = int(param1 * param2);
            _loc9_ = 0;
            while(_loc9_ < _loc8_)
            {
               _loc10_ = int(Math.random() * param2);
               if(_loc11_[_loc10_] == false)
               {
                  _loc11_[_loc10_] = true;
                  _loc9_++;
               }
            }
         }
         return _loc11_[int(Math.random() * param2)];
      }
      
      public static function removeArrFromArr(param1:Vector.<String>, param2:Vector.<String>) : Array
      {
         var _loc3_:* = undefined;
         var _loc4_:Object = {};
         var _loc5_:int = 0;
         while(_loc5_ < param1.length)
         {
            _loc4_[param1[_loc5_]] = param1[_loc5_];
            _loc5_++;
         }
         var _loc6_:int = 0;
         while(_loc6_ < param2.length)
         {
            delete _loc4_[param2[_loc6_]];
            _loc6_++;
         }
         var _loc7_:Array = [];
         for(_loc3_ in _loc4_)
         {
            _loc7_.push(_loc4_[_loc3_]);
         }
         return _loc7_;
      }
   }
}
