package com.iflashigame.ui
{
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   
   public class BaseUI extends Sprite
   {
       
      
      protected var _skin:MovieClip;
      
      public function BaseUI(param1:String, param2:ApplicationDomain = null)
      {
         super();
         if(param1 == null)
         {
            return;
         }
         this.init(param1,param2);
      }
      
      public function init(param1:String, param2:ApplicationDomain) : void
      {
         if(param2 == null)
         {
            param2 = ApplicationDomain.currentDomain;
         }
         this.initSkin(param1,param2);
         this.initView();
         this.initEvent();
      }
      
      protected function initSkin(param1:String, param2:ApplicationDomain = null) : void
      {
         var _loc3_:Class = param2.getDefinition(param1) as Class;
         this._skin = new _loc3_() as MovieClip;
         addChild(this._skin);
      }
      
      protected function initView() : void
      {
      }
      
      protected function initEvent() : void
      {
      }
      
      public function initData(param1:Object) : void
      {
      }
      
      public function createMask(param1:uint, param2:Number) : void
      {
         if(stage == null)
         {
            return;
         }
         graphics.clear();
         var _loc3_:Point = globalToLocal(new Point());
         graphics.beginFill(param1,param2);
         graphics.drawRect(_loc3_.x,_loc3_.y,stage.stageWidth,stage.stageHeight);
         graphics.endFill();
      }
      
      public function removeMask() : void
      {
         graphics.clear();
      }
      
      public function zoomTo(param1:Number, param2:Number, param3:Number = 1, param4:Number = 1, param5:Function = null) : *
      {
         if(param5 != null)
         {
            TweenLite.to(this._skin,param4,{
               "scaleX":param1,
               "scaleY":param2,
               "alpha":param3,
               "onComplete":param5
            });
         }
         else
         {
            TweenLite.to(this._skin,param4,{
               "scaleX":param1,
               "scaleY":param2,
               "alpha":param3
            });
         }
      }
      
      public function zoomFrom(param1:Number, param2:Number, param3:Number = 1, param4:Number = 1, param5:Function = null) : *
      {
         if(param5 != null)
         {
            TweenLite.from(this._skin,param4,{
               "scaleX":param1,
               "scaleY":param2,
               "alpha":param3,
               "onComplete":param5
            });
         }
         else
         {
            TweenLite.from(this._skin,param4,{
               "scaleX":param1,
               "scaleY":param2,
               "alpha":param3
            });
         }
      }
      
      public function rollTo(param1:Number, param2:Number, param3:Number = 1, param4:Number = 1, param5:Function = null) : *
      {
         if(param5 != null)
         {
            TweenLite.to(this._skin,param4,{
               "x":param1,
               "y":param2,
               "alpha":param3,
               "onComplete":param5
            });
         }
         else
         {
            TweenLite.to(this._skin,param4,{
               "x":param1,
               "y":param2,
               "alpha":param3
            });
         }
      }
      
      public function rollFrom(param1:Number, param2:Number, param3:Number = 1, param4:Number = 1, param5:Function = null) : *
      {
         if(param5 != null)
         {
            TweenLite.to(this._skin,param4,{
               "x":param1,
               "y":param2,
               "alpha":param3,
               "onComplete":param5
            });
         }
         else
         {
            TweenLite.to(this._skin,param4,{
               "x":param1,
               "y":param2,
               "alpha":param3
            });
         }
      }
      
      public function getSkin() : MovieClip
      {
         return this._skin;
      }
   }
}
