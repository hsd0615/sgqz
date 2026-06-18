package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
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
   import game.ui.EquipIconAssets;

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
         var _fmt:TextFormat = new TextFormat("SimSun",12,0xFFD700);

         // 上一页按钮
         this._prevBtn = new Sprite();
         var _ps:Shape = new Shape();
         _ps.graphics.beginFill(0x3a2010,0.9);
         _ps.graphics.lineStyle(1,0xC8A84E,0.7);
         _ps.graphics.drawRoundRect(0,0,55,22,4,4);
         _ps.graphics.endFill();
         this._prevBtn.addChild(_ps);
         var _prevTF:TextField = new TextField();
         _prevTF.defaultTextFormat = _fmt;
         _prevTF.text = "上一页";
         _prevTF.selectable = false;
         _prevTF.width = 55;
         _prevTF.height = 18;
         _prevTF.x = 0;
         _prevTF.y = 3;
         this._prevBtn.addChild(_prevTF);
         this._prevBtn.buttonMode = true;
         this._prevBtn.mouseChildren = false;
         addChild(this._prevBtn);

         // 页码文本
         this._pageTF = new TextField();
         this._pageTF.defaultTextFormat = new TextFormat("SimHei",13,0xD4C8A0,true);
         this._pageTF.text = "1/1";
         this._pageTF.selectable = false;
         this._pageTF.autoSize = TextFieldAutoSize.CENTER;
         this._pageTF.width = 60;
         this._pageTF.height = 20;
         addChild(this._pageTF);

         // 下一页按钮
         this._nextBtn = new Sprite();
         var _ns:Shape = new Shape();
         _ns.graphics.beginFill(0x3a2010,0.9);
         _ns.graphics.lineStyle(1,0xC8A84E,0.7);
         _ns.graphics.drawRoundRect(0,0,55,22,4,4);
         _ns.graphics.endFill();
         this._nextBtn.addChild(_ns);
         var _nextTF:TextField = new TextField();
         _nextTF.defaultTextFormat = _fmt;
         _nextTF.text = "下一页";
         _nextTF.selectable = false;
         _nextTF.width = 55;
         _nextTF.height = 18;
         _nextTF.x = 0;
         _nextTF.y = 3;
         this._nextBtn.addChild(_nextTF);
         this._nextBtn.buttonMode = true;
         this._nextBtn.mouseChildren = false;
         addChild(this._nextBtn);

         // 计算分页按钮位置(放在最后一排格子下方)
         var _bottomY:Number = 0;
         var _k:int = ITEMS_PER_PAGE - 4;
         while(_k <= ITEMS_PER_PAGE)
         {
            var _g:MovieClip = this._gridContainer.getChildByName("_grid" + _k) as MovieClip;
            if(_g != null)
            {
               var _gy:Number = _g.y + _g.height;
               if(_gy > _bottomY)
               {
                  _bottomY = _gy;
               }
            }
            _k++;
         }
         var _btnY:Number = _bottomY + 12;

         // 居中排列: [上一页] [页码] [下一页]
         var _totalW:Number = 55 + 10 + 60 + 10 + 55;
         var _startX:Number = (340 - _totalW) / 2;
         if(_startX < 10)
         {
            _startX = 10;
         }
         this._prevBtn.x = _startX;
         this._prevBtn.y = _btnY;
         this._pageTF.x = _startX + 55 + 10;
         this._pageTF.y = _btnY + 2;
         this._nextBtn.x = _startX + 55 + 10 + 60 + 10;
         this._nextBtn.y = _btnY;
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
                  if(_loc5_.getChildAt(_ci) is Bitmap)
                  {
                     _loc5_.removeChildAt(_ci);
                  }
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
               _loc6_.x = 2;
               _loc6_.y = 2;
               _loc5_.addChildAt(_loc6_,0);
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
      private function createEquipIcon(param1:String) : Bitmap
      {
         var _bmp:Bitmap = null;
         // 提取proto_4_X中的数字部分
         var _num:int = 0;
         var _parts:Array = param1.split("_");
         if(_parts.length >= 3)
         {
            _num = int(_parts[_parts.length - 1]);
         }

         // proto_4_1~5: 武器, proto_4_11~15: 防具, proto_4_21~25: 饰品
         if(_num >= 21)
         {
            _bmp = EquipIconAssets.accessory();
         }
         else if(_num >= 11)
         {
            _bmp = EquipIconAssets.armor();
         }
         else
         {
            _bmp = EquipIconAssets.weapon();
         }

         if(_bmp == null)
         {
            return null;
         }

         // 128x128 PNG缩放到~36px, 与其他道具图标大小一致
         _bmp.scaleX = 0.28;
         _bmp.scaleY = 0.28;
         _bmp.smoothing = true;
         return _bmp;
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
