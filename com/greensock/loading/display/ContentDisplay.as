package com.greensock.loading.display
{
   import com.greensock.loading.core.LoaderItem;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   
   public class ContentDisplay extends Sprite
   {
      
      protected static var _transformProps:Object = {
         "x":1,
         "y":1,
         "scaleX":1,
         "scaleY":1,
         "rotation":1,
         "alpha":1,
         "visible":true,
         "blendMode":"normal",
         "centerRegistration":false,
         "crop":false,
         "scaleMode":"stretch",
         "hAlign":"center",
         "vAlign":"center"
      };
       
      
      protected var _loader:LoaderItem;
      
      protected var _rawContent:DisplayObject;
      
      protected var _centerRegistration:Boolean;
      
      protected var _crop:Boolean;
      
      protected var _scaleMode:String = "stretch";
      
      protected var _hAlign:String = "center";
      
      protected var _vAlign:String = "center";
      
      protected var _bgColor:uint;
      
      protected var _bgAlpha:Number = 0;
      
      protected var _fitWidth:Number;
      
      protected var _fitHeight:Number;
      
      public var gcProtect:*;
      
      public function ContentDisplay(param1:LoaderItem)
      {
         super();
         this.loader = param1;
      }
      
      public function dispose(param1:Boolean = true, param2:Boolean = true) : void
      {
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
         this.rawContent = null;
         this.gcProtect = null;
         if(this._loader != null)
         {
            if(param1)
            {
               this._loader.unload();
            }
            if(param2)
            {
               this._loader.dispose(false);
               this._loader = null;
            }
         }
      }
      
      protected function _update() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = this._centerRegistration && this._fitWidth > 0 ? this._fitWidth / -2 : 0;
         var _loc8_:Number = this._centerRegistration && this._fitHeight > 0 ? this._fitHeight / -2 : 0;
         graphics.clear();
         if(this._fitWidth > 0 && this._fitHeight > 0)
         {
            graphics.beginFill(this._bgColor,this._bgAlpha);
            graphics.drawRect(_loc7_,_loc8_,this._fitWidth,this._fitHeight);
            graphics.endFill();
         }
         if(this._rawContent == null)
         {
            return;
         }
         var _loc9_:DisplayObject;
         var _loc10_:Number = (_loc9_ = this._rawContent).width;
         var _loc11_:Number = _loc9_.height;
         if(Boolean(this._loader.hasOwnProperty("getClass")) && !this._loader.scriptAccessDenied)
         {
            _loc10_ = _loc9_.loaderInfo.width;
            _loc11_ = _loc9_.loaderInfo.height;
         }
         if(this._fitWidth > 0 && this._fitHeight > 0)
         {
            _loc1_ = this._fitWidth;
            _loc2_ = this._fitHeight;
            _loc3_ = _loc1_ - _loc10_;
            _loc4_ = _loc2_ - _loc11_;
            if(this._scaleMode != "none")
            {
               _loc5_ = _loc1_ / _loc2_;
               if((_loc6_ = _loc10_ / _loc11_) < _loc5_ && this._scaleMode == "proportionalInside" || _loc6_ > _loc5_ && this._scaleMode == "proportionalOutside")
               {
                  _loc1_ = _loc2_ * _loc6_;
               }
               if(_loc6_ > _loc5_ && this._scaleMode == "proportionalInside" || _loc6_ < _loc5_ && this._scaleMode == "proportionalOutside")
               {
                  _loc2_ = _loc1_ / _loc6_;
               }
               if(this._scaleMode != "heightOnly")
               {
                  _loc9_.width *= _loc1_ / _loc10_;
                  _loc3_ = this._fitWidth - _loc1_;
               }
               if(this._scaleMode != "widthOnly")
               {
                  _loc9_.height *= _loc2_ / _loc11_;
                  _loc4_ = this._fitHeight - _loc2_;
               }
            }
            if(this._hAlign == "left")
            {
               _loc3_ = 0;
            }
            else if(this._hAlign != "right")
            {
               _loc3_ *= 0.5;
            }
            if(this._vAlign == "top")
            {
               _loc4_ = 0;
            }
            else if(this._vAlign != "bottom")
            {
               _loc4_ *= 0.5;
            }
            _loc9_.x = _loc7_;
            _loc9_.y = _loc8_;
            if(this._crop)
            {
               _loc9_.scrollRect = new Rectangle(-_loc3_ / _loc9_.scaleX,-_loc4_ / _loc9_.scaleY,this._fitWidth / _loc9_.scaleX,this._fitHeight / _loc9_.scaleY);
            }
            else
            {
               _loc9_.x += _loc3_;
               _loc9_.y += _loc4_;
            }
         }
         else
         {
            _loc9_.x = this._centerRegistration ? -_loc10_ / 2 : 0;
            _loc9_.y = this._centerRegistration ? -_loc11_ / 2 : 0;
         }
      }
      
      public function get fitWidth() : Number
      {
         return this._fitWidth;
      }
      
      public function set fitWidth(param1:Number) : void
      {
         this._fitWidth = param1;
         this._update();
      }
      
      public function get fitHeight() : Number
      {
         return this._fitHeight;
      }
      
      public function set fitHeight(param1:Number) : void
      {
         this._fitHeight = param1;
         this._update();
      }
      
      public function get scaleMode() : String
      {
         return this._scaleMode;
      }
      
      public function set scaleMode(param1:String) : void
      {
         if(param1 == "none" && this._rawContent != null)
         {
            this._rawContent.scaleX = this._rawContent.scaleY = 1;
         }
         this._scaleMode = param1;
         this._update();
      }
      
      public function get centerRegistration() : Boolean
      {
         return this._centerRegistration;
      }
      
      public function set centerRegistration(param1:Boolean) : void
      {
         this._centerRegistration = param1;
         this._update();
      }
      
      public function get crop() : Boolean
      {
         return this._crop;
      }
      
      public function set crop(param1:Boolean) : void
      {
         this._crop = param1;
         this._update();
      }
      
      public function get hAlign() : String
      {
         return this._hAlign;
      }
      
      public function set hAlign(param1:String) : void
      {
         this._hAlign = param1;
         this._update();
      }
      
      public function get vAlign() : String
      {
         return this._vAlign;
      }
      
      public function set vAlign(param1:String) : void
      {
         this._vAlign = param1;
         this._update();
      }
      
      public function get bgColor() : uint
      {
         return this._bgColor;
      }
      
      public function set bgColor(param1:uint) : void
      {
         this._bgColor = param1;
         this._update();
      }
      
      public function get bgAlpha() : Number
      {
         return this._bgAlpha;
      }
      
      public function set bgAlpha(param1:Number) : void
      {
         this._bgAlpha = param1;
         this._update();
      }
      
      public function get rawContent() : *
      {
         return this._rawContent;
      }
      
      public function set rawContent(param1:*) : void
      {
         if(this._rawContent != null && this._rawContent != param1 && this._rawContent.parent == this)
         {
            removeChild(this._rawContent);
         }
         this._rawContent = param1 as DisplayObject;
         if(this._rawContent == null)
         {
            return;
         }
         addChildAt(this._rawContent as DisplayObject,0);
         this._update();
      }
      
      public function get loader() : LoaderItem
      {
         return this._loader;
      }
      
      public function set loader(param1:LoaderItem) : void
      {
         var _loc2_:* = null;
         var _loc3_:String = null;
         this._loader = param1;
         if(this._loader == null)
         {
            return;
         }
         if(!this._loader.hasOwnProperty("setContentDisplay"))
         {
            throw new Error("Incompatible loader used for a ContentDisplay");
         }
         this.name = this._loader.name;
         for(_loc3_ in _transformProps)
         {
            if(_loc3_ in this._loader.vars)
            {
               _loc2_ = typeof _transformProps[_loc3_];
               this[_loc3_] = _loc2_ == "number" ? Number(this._loader.vars[_loc3_]) : (_loc2_ == "string" ? String(this._loader.vars[_loc3_]) : Boolean(this._loader.vars[_loc3_]));
            }
         }
         this._bgColor = uint(this._loader.vars.bgColor);
         this._bgAlpha = "bgAlpha" in this._loader.vars ? Number(this._loader.vars.bgAlpha) : ("bgColor" in this._loader.vars ? 1 : 0);
         this._fitWidth = "fitWidth" in this._loader.vars ? Number(this._loader.vars.fitWidth) : Number(this._loader.vars.width);
         this._fitHeight = "fitHeight" in this._loader.vars ? Number(this._loader.vars.fitHeight) : Number(this._loader.vars.height);
         this._update();
         if(this._loader.vars.container is DisplayObjectContainer)
         {
            (this._loader.vars.container as DisplayObjectContainer).addChild(this);
         }
         if(this._loader.content != this)
         {
            (this._loader as Object).setContentDisplay(this);
         }
         this.rawContent = (this._loader as Object).rawContent;
      }
   }
}
