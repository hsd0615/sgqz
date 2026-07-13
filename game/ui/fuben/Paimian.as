package game.ui.fuben
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
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
         var _title:int = 3;
         try { _title = int(Data.getInstance().getAttributes("general",param1,"title")); } catch(_e:Error) {}
         // 品质颜色: 超级=橙金, 一流=蓝, 二流=绿, 三流=灰白
         var _qualityColors:Array = [0xFF6600,0x3399FF,0x66CC33,0xCCCCCC];
         var _qualityNames:Array = ["超级","一流","二流","三流"];
         var _color:uint = _qualityColors[_title] || 0xCCCCCC;
         // 画品质色块+边框
         var _bd:BitmapData = new BitmapData(50,50,false,_color);
         this._icon = new Bitmap(_bd);
         this._icon.smoothing = true;
         this.fitIconToCard();
         addChild(this._icon);
         // 品质标签
         var _qTf:TextField = new TextField();
         _qTf.defaultTextFormat = new TextFormat("SimHei",10,0xFFFFFF,true);
         _qTf.text = _qualityNames[_title] || "";
         _qTf.selectable = false;
         _qTf.mouseEnabled = false;
         _qTf.width = 36;
         _qTf.height = 16;
         _qTf.x = 7;
         _qTf.y = 17;
         addChild(_qTf);
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

      private function fitIconToCard() : void
      {
         if(this.__body == null) return;
         var _bodyW:Number = this.__body.width;
         var _bodyH:Number = this.__body.height;
         if(_bodyW <= 0 || _bodyH <= 0) return;
         // 图标不超过卡面的60%宽、45%高
         var _maxW:Number = _bodyW * 0.6;
         var _maxH:Number = _bodyH * 0.45;
         var _scale:Number = Math.min(_maxW / this._icon.width, _maxH / this._icon.height);
         if(_scale > 1) _scale = 1;
         this._icon.scaleX = _scale;
         this._icon.scaleY = _scale;
         // 居中放置, y轴略靠上留出名称空间
         this._icon.x = int((_bodyW - this._icon.width * _scale) / 2) + this.__body.x;
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
         this.show();
         dispatchEvent(new UIEvent(UIEvent.CHOOSE_PAIMIAN,true));
      }

      public function get data() : String
      {
         return this._data;
      }
   }
}
