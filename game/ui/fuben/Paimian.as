package game.ui.fuben
{
   import com.iflashigame.ui.BaseUI;
   import com.greensock.loading.LoaderMax;
   import com.greensock.loading.SWFLoader;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import game.Data;
   import game.events.UIEvent;
   import game.model.EquipData;
   import game.ui.EquipIconsWuxia;

   public class Paimian extends BaseUI
   {


      private var __body:MovieClip;

      private var __nameTF:TextField;

      private var __countTF:TextField;

      private var _icon:Bitmap;

      private var _tmpX:Number = -16;

      private var _tmpY:Number = -33;

      private var _data:String = "";

      private var _isShow:Boolean;

      public var disable:Boolean;

      public var deferReveal:Boolean = false;

      public function Paimian(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }

      override protected function initView() : void
      {
         mouseChildren = false;
         this.__body = _skin.getChildByName("_body") as MovieClip;
         this.__nameTF = _skin.getChildByName("_nameTF") as TextField;
         this.__countTF = _skin.getChildByName("_countTF") as TextField;
      }

      override protected function initEvent() : void
      {
      }

      override public function initData(param1:Object) : void
      {
         this._data = param1 as String;
         this.disable = false;
         this._isShow = false;
         this.filters = [];
         if(this.__body != null) this.__body.filters = [];
         this.__nameTF.text = "";
         this.__countTF.text = "";
         if(this._icon != null && this._icon.parent == this) removeChild(this._icon);
         this._icon = null;
         addEventListener(MouseEvent.CLICK,this.onClickHandler);
      }

      public function show() : *
      {
         if(this._data == "")
         {
            return;
         }
         if(this._isShow == true)
         {
            return;
         }
         this._isShow = true;
         var _loc1_:Array = this._data.split("|");
         var _loc2_:int = int(_loc1_[0]);
         addChildAt(this.__body,0);
         if(_loc2_ == 1)
         {
            var _pname:String = Data.getInstance().getAttributes("proto",_loc1_[1],"name");
            if(!_pname) _pname = EquipData.get(_loc1_[1],"name");
            this.__nameTF.text = _pname || _loc1_[1];
            this.__countTF.text = "x " + _loc1_[2];
            this.createIcon(_loc1_[1]);
            this.addQualityBorder(int(EquipData.get(_loc1_[1],"quality")));
         }
         else if(_loc2_ == 2)
         {
            this.__nameTF.text = _loc1_[1];
            this.__countTF.text = "银子";
         }
         else if(_loc2_ == 3)
         {
            var _gname:String = Data.getInstance().getAttributes("general",_loc1_[1],"name");
            this.__nameTF.text = _gname || _loc1_[1];
            this.__countTF.text = "Lv." + _loc1_[3];
            this.createGeneralIcon(_loc1_[1]);
            this.addQualityBorder(int(_loc1_[2]));
         }
      }

      private function createGeneralIcon(param1:String) : *
      {
         // Render a bust from the same model the general uses in battle.
         var _bd:BitmapData = new BitmapData(64,64,false,0x1D1523);
         var _rendered:Boolean = false;
         var _skinName:String = Data.getInstance().getAttributes("general",param1,"skin");
         if(param1 == "general_6_15") _skinName = "generalSkin_18_0";
         var _skinClass:Class = null;
         var _loader:SWFLoader = LoaderMax.getLoader("game01.skin.general") as SWFLoader;
         var _names:Array = [_skinName + "_0",_skinName];
         for each(var _name:String in _names)
         {
            try {
               if(_loader != null) _skinClass = _loader.getClass(_name);
               if(_skinClass == null) _skinClass = ApplicationDomain.currentDomain.getDefinition(_name) as Class;
               if(_skinClass != null) break;
            } catch(_err:Error) {}
         }
         if(_skinClass != null)
         {
            try {
               var _general:MovieClip = new _skinClass() as MovieClip;
               if(_general != null)
               {
                  _general.gotoAndStop(1);
                  var _canvas:BitmapData = new BitmapData(320,320,true,0);
                  var _position:Matrix = new Matrix();
                  _position.translate(160,220);
                  _canvas.draw(_general,_position,null,null,null,true);
                  var _visible:Rectangle = _canvas.getColorBoundsRect(0xFF000000,0x00000000,false);
                  if(!_visible.isEmpty())
                  {
                     var _cropW:Number = Math.max(24,_visible.width * 0.6);
                     var _cropH:Number = Math.max(24,_visible.height * 0.65);
                     var _cropX:Number = _visible.x + (_visible.width - _cropW) / 2;
                     var _cropY:Number = _visible.y;
                     var _scale:Number = Math.min(56 / _cropW,56 / _cropH);
                     var _portrait:Matrix = new Matrix();
                     _portrait.scale(_scale,_scale);
                     _portrait.translate(4 + (56 - _cropW * _scale) / 2 - _cropX * _scale,
                                         4 + (56 - _cropH * _scale) / 2 - _cropY * _scale);
                     _bd.draw(_canvas,_portrait,null,null,new Rectangle(4,4,56,56),true);
                     _rendered = true;
                  }
                  _canvas.dispose();
               }
            } catch(_drawError:Error) {}
         }
         if(!_rendered)
         {
            var _fallback:TextField = new TextField();
            _fallback.defaultTextFormat = new TextFormat("SimHei",32,0xEED9A0,true);
            _fallback.text = this.__nameTF.text.substr(0,1);
            _fallback.width = 56;
            _fallback.height = 48;
            var _fallbackPosition:Matrix = new Matrix();
            _fallbackPosition.translate(8,9);
            _bd.draw(_fallback,_fallbackPosition);
         }
         this._icon = new Bitmap(_bd);
         this._icon.smoothing = true;
         this.fitIconToCard(true);
         addChild(this._icon);
      }

      private function addQualityBorder(param1:int) : *
      {
         var _colors:Array = [0xFF6600,0x33CCFF,0x99FF33,0xFFCC99];
         var _glowColor:uint = _colors[param1] || 0xFFCC99;
         var _size:int = param1 == 0 ? 6 : 3;
         var _alpha:Number = param1 == 0 ? 0.9 : 0.6;
         if(this.__body != null)
         {
            this.__body.filters = [new GlowFilter(_glowColor,_alpha,_size,_size,2)];
         }
      }

      private function createIcon(param1:String) : *
      {
         var _iconCreated:Boolean = false;
         // 先尝试 proto XML 中的图标(消耗品/道具)
         var _loc2_:String = Data.getInstance().getAttributes("proto",param1,"icon");
         if(_loc2_)
         {
            try {
               var _loc3_:Class = ApplicationDomain.currentDomain.getDefinition(_loc2_) as Class;
               this._icon = new Bitmap(new _loc3_() as BitmapData);
               _iconCreated = true;
            } catch(_e:Error) {
               // proto图标加载失败,继续尝试装备图标
            }
         }
         // 尝试装备图标 (EquipData + EquipIconsWuxia)
         if(!_iconCreated)
         {
            var _iconIdx:* = EquipData.get(param1,"iconIdx");
            if(_iconIdx != null)
            {
               var _bmp:Bitmap = EquipIconsWuxia.getIcon(int(_iconIdx));
               if(_bmp != null)
               {
                  this._icon = _bmp;
                  _iconCreated = true;
               }
            }
         }
         // 统一缩放和定位图标到卡槽内
         if(this._icon != null)
         {
            this._icon.smoothing = true;
            this.fitIconToCard();
            addChild(this._icon);
         }
      }

      private function fitIconToCard(param1:Boolean = false) : void
      {
         if(this.__body == null) return;
         var _bodyW:Number = this.__body.width;
         var _bodyH:Number = this.__body.height;
         if(_bodyW <= 0 || _bodyH <= 0) return;
         // 图标不超过卡面的60%宽、45%高
         var _maxW:Number = _bodyW * (param1 ? 0.68 : 0.6);
         var _maxH:Number = _bodyH * (param1 ? 0.52 : 0.45);
         var _baseW:Number = this._icon.bitmapData != null ? this._icon.bitmapData.width : this._icon.width;
         var _baseH:Number = this._icon.bitmapData != null ? this._icon.bitmapData.height : this._icon.height;
         var _scale:Number = Math.min(_maxW / Math.max(1,_baseW), _maxH / Math.max(1,_baseH));
         if(_scale > 1) _scale = 1;
         this._icon.scaleX = _scale;
         this._icon.scaleY = _scale;
         // 居中放置, y轴略靠上留出名称空间
         this._icon.x = int((_bodyW - _baseW * _scale) / 2) + this.__body.x;
         this._icon.y = this.__body.y + int(_bodyH * 0.08);
      }

      private function onClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this.disable == true)
         {
            return;
         }
         filters = [new GlowFilter(16763904,1,10,10)];
         if(!this.deferReveal) this.show();
         dispatchEvent(new UIEvent(UIEvent.CHOOSE_PAIMIAN,true));
      }

      public function get data() : String
      {
         return this._data;
      }
   }
}
