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
