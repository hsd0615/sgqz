package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFieldAutoSize;
   import game.Data;
   import game.events.UIEvent;
   import game.model.RoleModel;
   import game.ui.EquipIconsWuxia;
   import game.model.EquipData;

   public class BagPanel extends BaseUI
   {

      // 每页显示25个格子(5x5布局,复用SWF皮肤中的_grid1~_grid25)
      private static const ITEMS_PER_PAGE:int = 25;

      private var __closeBtn:SimpleButton;

      private var _gridArr:Array;

      private var _gridContainer:Sprite;

      // 分页相关
      private var _allData:Array;
      private var _currentPage:int = 1;
      private var _totalPages:int = 1;
      private var _prevBtn:Sprite;
      private var _nextBtn:Sprite;
      private var _pageTF:TextField;

      public function BagPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }

      override protected function initView() : void
      {
         var _loc1_:MovieClip = null;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this._gridContainer = new Sprite();
         addChild(this._gridContainer);
         this._gridArr = [];
         var _loc2_:int = 1;
         while(_loc2_ <= ITEMS_PER_PAGE)
         {
            _loc1_ = _skin.getChildByName("_grid" + _loc2_) as MovieClip;
            _loc1_.sanjiao.visible = false;
            _loc1_.mouseChildren = false;
            this._gridContainer.addChild(_loc1_);
            this._gridArr.push(_loc1_);
            _loc2_++;
         }

         // 程序化创建翻页按钮(SWF皮肤中没有)
         this.createPaginationUI();
      }

      private function createPaginationUI() : void
      {
         // 翻页栏样式: 首页 ◀ 第X/Y页 ▶ 末页
         var _btnW:int = 26, _btnH:int = 22, _gap:int = 4;

         function makeBtn(label:String, w:int):Sprite {
            var s:Sprite = new Sprite();
            var bg:Shape = new Shape();
            bg.graphics.beginFill(0x1a1008,0.92);
            bg.graphics.lineStyle(1,0x8B6914,0.5);
            bg.graphics.drawRoundRect(0,0,w,_btnH,3,3);
            bg.graphics.endFill();
            s.addChild(bg);
            var t:TextField = new TextField();
            t.defaultTextFormat = new TextFormat("SimSun",11,0x8B6914);
            t.text = label; t.selectable = false;
            t.width = w; t.height = 16; t.x = 0; t.y = 3;
            s.addChild(t);
            s.buttonMode = true; s.mouseChildren = false;
            return s;
         }

         this._prevBtn = makeBtn("◀◀", 32);
         var _prev1Btn:Sprite = makeBtn("◀", 22);
         this._pageTF = new TextField();
         this._pageTF.defaultTextFormat = new TextFormat("SimHei",12,0xFFD700,true);
         this._pageTF.text = "1/1";
         this._pageTF.selectable = false;
         this._pageTF.autoSize = TextFieldAutoSize.CENTER;
         this._pageTF.width = 55; this._pageTF.height = 18;
         var _next1Btn:Sprite = makeBtn("▶", 22);
         this._nextBtn = makeBtn("▶▶", 32);

         addChild(this._prevBtn);
         addChild(_prev1Btn);
         addChild(this._pageTF);
         addChild(_next1Btn);
         addChild(this._nextBtn);

         // 定位在格子区域下方
         var _btm:Number = 0;
         var _gc:int = this._gridContainer.numChildren;
         var _gi:int = 0;
         while(_gi < _gc)
         {
            var _g:DisplayObject = this._gridContainer.getChildAt(_gi);
            var _gy:Number = _g.y + _g.height;
            if(_gy > _btm) _btm = _gy;
            _gi++;
         }
         _btm += 14;

         var _buttons:Array = [this._prevBtn, _prev1Btn, this._pageTF, _next1Btn, this._nextBtn];
         var _tw:int = 32+_gap+22+_gap+55+_gap+22+_gap+32;
         var _sx:int = (340 - _tw) / 2;
         var _cx:int = _sx;
         this._prevBtn.x = _cx; this._prevBtn.y = _btm; _cx += 32 + _gap;
         _prev1Btn.x = _cx; _prev1Btn.y = _btm; _cx += 22 + _gap;
         this._pageTF.x = _cx; this._pageTF.y = _btm + 2; _cx += 55 + _gap;
         _next1Btn.x = _cx; _next1Btn.y = _btm; _cx += 22 + _gap;
         this._nextBtn.x = _cx; this._nextBtn.y = _btm;

         // 事件绑定
         var _self:BagPanel = this;
         this._prevBtn.addEventListener(MouseEvent.CLICK, function(p:*):void { if(_self._currentPage>1){_self._currentPage=1;_self.showPage();} });
         _prev1Btn.addEventListener(MouseEvent.CLICK, this.onPrevPageHandler);
         _next1Btn.addEventListener(MouseEvent.CLICK, this.onNextPageHandler);
         this._nextBtn.addEventListener(MouseEvent.CLICK, function(p:*):void { if(_self._currentPage<_self._totalPages){_self._currentPage=_self._totalPages;_self.showPage();} });
      }

      override protected function initEvent() : void
      {
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this._gridContainer.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHandler);
         this._gridContainer.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutHandler);
         this._prevBtn.addEventListener(MouseEvent.CLICK,this.onPrevPageHandler);
         this._nextBtn.addEventListener(MouseEvent.CLICK,this.onNextPageHandler);
      }

      override public function initData(param1:Object) : void
      {
         this._allData = param1 as Array;
         if(this._allData == null)
         {
            this._allData = [];
         }
         // 计算总页数: 向上取整
         this._totalPages = int(this._allData.length / ITEMS_PER_PAGE);
         if(this._allData.length % ITEMS_PER_PAGE != 0)
         {
            this._totalPages = this._totalPages + 1;
         }
         if(this._totalPages < 1)
         {
            this._totalPages = 1;
         }
         // 保持当前页码不越界
         if(this._currentPage > this._totalPages)
         {
            this._currentPage = this._totalPages;
         }
         if(this._currentPage < 1)
         {
            this._currentPage = 1;
         }
         this.showPage();
      }

      private function showPage() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:MovieClip = null;
         var _loc6_:Bitmap = null;
         var _loc7_:int = 0;

         _loc1_ = (this._currentPage - 1) * ITEMS_PER_PAGE;
         _loc2_ = _loc1_ + ITEMS_PER_PAGE;
         if(_loc2_ > this._allData.length)
         {
            _loc2_ = this._allData.length;
         }

         // 先清空所有格子中之前添加的图标Bitmap
         _loc7_ = 1;
         while(_loc7_ <= ITEMS_PER_PAGE)
         {
            _loc5_ = this._gridContainer.getChildByName("_grid" + _loc7_) as MovieClip;
            if(_loc5_ != null)
            {
               var _ci:int = _loc5_.numChildren - 1;
               while(_ci >= 0)
               {
                  var _ch:* = _loc5_.getChildAt(_ci);
                  if(_ch is Bitmap || _ch is Shape) _loc5_.removeChildAt(_ci);
                  _ci--;
               }
               _loc5_.code = null;
               _loc5_.flag = false;
               if(_loc5_.countTF != null)
               {
                  _loc5_.countTF.text = "";
               }
            }
            _loc7_++;
         }

         // 填充当前页数据
         _loc4_ = _loc1_;
         var _gridIndex:int = 1;
         while(_loc4_ < _loc2_)
         {
            var _item:Object = this._allData[_loc4_];
            _loc5_ = this._gridContainer.getChildByName("_grid" + _gridIndex) as MovieClip;
            _loc5_.code = _item.code;
            _loc5_.countTF.text = RoleModel.getInstance().getBagItemCount(_item.code);
            _loc5_.flag = true;

            _loc6_ = this.createItemIcon(_item);
            if(_loc6_ != null)
            {
               // 装备品质背景色
               if(_item.type == 4)
               {
                  var _eqQ:int = int(EquipData.get(_item.code, "quality"));
                  if(_eqQ > 0)
                  {
                     var _qBg:Shape = new Shape();
                     _qBg.graphics.beginFill(getEquipBgColor(_eqQ), 0.75);
                     _qBg.graphics.drawRoundRect(2, 2, _loc5_.width - 4, _loc5_.height - 4, 4, 4);
                     _qBg.graphics.endFill();
                     _loc5_.addChildAt(_qBg, 0);
                  }
               }
               _loc6_.x = int((_loc5_.width - _loc6_.width) / 2);
               _loc6_.y = int((_loc5_.height - _loc6_.height) / 2);
               if(_loc6_.x < 0) _loc6_.x = 2;
               if(_loc6_.y < 0) _loc6_.y = 2;
               _loc5_.addChildAt(_loc6_, 1);
            }

            _loc4_++;
            _gridIndex++;
         }

         // 更新页码显示
         this._pageTF.text = this._currentPage + "/" + this._totalPages;

         // 更新翻页按钮状态
         if(this._currentPage <= 1)
         {
            this._prevBtn.alpha = 0.35;
            this._prevBtn.mouseEnabled = false;
         }
         else
         {
            this._prevBtn.alpha = 1;
            this._prevBtn.mouseEnabled = true;
         }
         if(this._currentPage >= this._totalPages)
         {
            this._nextBtn.alpha = 0.35;
            this._nextBtn.mouseEnabled = false;
         }
         else
         {
            this._nextBtn.alpha = 1;
            this._nextBtn.mouseEnabled = true;
         }
      }

      /**
       * 根据物品类型创建图标
       * - 装备(type=4): 使用EquipIconAssets真实PNG图标,缩放到合适大小
       * - 其他道具: 使用proto数据中定义的SWF图标
       */
      private function createItemIcon(param1:Object) : Bitmap
      {
         var _code:String = param1.code as String;
         var _type:int = 0;
         var _iconName:String = null;
         var _iconClass:Class = null;
         var _bd:BitmapData = null;
         var _bmp:Bitmap = null;

         if(_code == null || _code == "")
         {
            return null;
         }

         _type = Data.getInstance().getAttributes("proto",_code,"type");

         // 装备类型: 使用真实装备图标,缩放到与普通道具一致
         if(_type == 4)
         {
            return this.createEquipIcon(_code);
         }

         // 普通道具: 使用proto中定义的icon
         _iconName = Data.getInstance().getAttributes("proto",_code,"icon");
         if(_iconName == null || _iconName == "")
         {
            return null;
         }
         try
         {
            _iconClass = ApplicationDomain.currentDomain.getDefinition(_iconName) as Class;
            _bd = new _iconClass() as BitmapData;
            _bmp = new Bitmap(_bd);
         }
         catch(_er:Error)
         {
            _bmp = null;
         }
         return _bmp;
      }

      /**
       * 创建装备图标 - 根据code判断武器/防具/饰品类型
       * 128x128 PNG缩放到约36x36以适配背包格子
       */
      private static const _qualityBgColors:Array = [0x333333,0x555555,0x1a3a0a,0x0a2a3a,0x2a0a2a,0x3a3000,0x3a1a00,0x3a0a0a,0x3a0000];
      private function getEquipBgColor(param1:int):uint { return _qualityBgColors[param1] || 0x333333; }

      private function createEquipIcon(param1:String) : Bitmap
      {
         var _idx:* = EquipData.get(param1, "iconIdx");
         if(_idx != null && int(_idx) > 0)
         {
            var _b:Bitmap = EquipIconsWuxia.getIcon(int(_idx));
            if(_b != null) { _b.smoothing = true; return _b; }
         }
         return null;
      }

      private function onPrevPageHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._currentPage > 1)
         {
            this._currentPage--;
            this.showPage();
         }
      }

      private function onNextPageHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._currentPage < this._totalPages)
         {
            this._currentPage++;
            this.showPage();
         }
      }

      private function onMouseOverHandler(param1:MouseEvent) : *
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         param1.stopImmediatePropagation();
         if(param1.target.flag == true)
         {
            _loc2_ = String(param1.target.code);
            _loc3_ = Data.getInstance().getAttributes("proto",_loc2_,"name");
            _loc4_ = Data.getInstance().getAttributes("proto",_loc2_,"type");
            _loc5_ = Data.getInstance().getAttributes("proto",_loc2_,"desc");
            _loc6_ = (_loc6_ = "") + ("<font color=\'#e5ce10\'>名称：</font>" + _loc3_ + "\n");
            if(_loc4_ == 1)
            {
               _loc6_ += "<font color=\'#e5ce10\'>类别：</font>" + "进化道具" + "\n";
            }
            else if(_loc4_ == 2)
            {
               _loc6_ += "<font color=\'#e5ce10\'>类别：</font>" + "战车弹药" + "\n";
            }
            else if(_loc4_ == 4)
            {
               _loc6_ += "<font color=\'#e5ce10\'>类别：</font>" + "装备" + "\n";
            }
            else
            {
               _loc6_ += "<font color=\'#e5ce10\'>类别：</font>" + "其他" + "\n";
            }
            _loc6_ += "<font color=\'#e5ce10\'>说明：</font>" + _loc5_ + "\n";
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":_loc6_,
               "type":3,
               "width":150,
               "height":70
            }));
         }
      }

      private function onMouseOutHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(param1.target.flag == true)
         {
            dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
         }
      }

      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
   }
}
