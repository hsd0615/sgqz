package game.ui
{
   import com.iflashigame.controller.AESController;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import game.Config;
   import game.Data;
   import game.model.ArmyInfo;
   import game.model.EquipData;
   import game.model.Head;
   import game.model.RoleModel;
   import game.events.UIEvent;

   public class EquipPanel extends Sprite
   {
      // 6槽位: 0=武器 1=铠甲 2=饰品 3=头盔 4=战靴 5=饰品
      private var _slotLabels:Array = ["武器","铠甲","饰品","头盔","战靴","饰品"];
      private var _slotIcons:Array = ["weapon","armor","accessory","helmet","boots","accessory"];
      // 槽位布局坐标 (x,y)
      private static const SLOT_POS:Array = [
         new Point(90, 115),   // 0:武器  middle-left
         new Point(260, 115),  // 1:铠甲  middle-right
         new Point(175, 35),   // 2:头盔  top-center
         new Point(5, 195),    // 3:饰品Ⅰ bottom-left
         new Point(175, 115),  // 4:战靴  center (same as armor but different row - wait, let me redesign)
         new Point(345, 195)   // 5:饰品Ⅱ bottom-right
      ];

      private var _armyInfo:ArmyInfo;
      private var _slotSprites:Array = [];
      private var _bagList:Sprite;
      private var _selectingSlot:int = -1;

      public function EquipPanel(param1:ArmyInfo)
      {
         super();
         this._armyInfo = param1;
         this.buildUI();
      }

      private function buildUI() : void
      {
         var _w:int = 440;
         var _h:int = 320;

         // 背景
         var _bg:Shape = new Shape();
         _bg.graphics.beginFill(0x0d0804, 0.96);
         _bg.graphics.lineStyle(2, 0x8B6914, 0.9);
         _bg.graphics.drawRoundRect(0, 0, _w, _h, 10, 10);
         _bg.graphics.endFill();
         addChild(_bg);

         // 标题
         var _titleTF:TextField = new TextField();
         _titleTF.defaultTextFormat = new TextFormat("SimHei", 16, 0xFFD700, true);
         _titleTF.text = "装备管理 - " + this._armyInfo.name;
         _titleTF.selectable = false;
         _titleTF.autoSize = TextFieldAutoSize.CENTER;
         _titleTF.x = (_w - _titleTF.width) / 2;
         _titleTF.y = 6;
         addChild(_titleTF);

         // 6槽位 — RPG布局
         // Layout:
         //           [头盔]              y=35
         //   [武器]  [铠甲]  [饰品Ⅰ]     y=115
         //   [战靴]                     y=195
         //           [饰品Ⅱ]            y=195
         var _slotLayout:Array = [
            {label:"头盔", x:195, y:35},       // slot 3, top-center
            {label:"武器", x:5, y:115},        // slot 0, middle-left
            {label:"铠甲", x:195, y:115},      // slot 1, middle-center
            {label:"饰品Ⅰ", x:385, y:115},     // slot 2, middle-right
            {label:"战靴", x:100, y:195},      // slot 4, bottom-left
            {label:"饰品Ⅱ", x:290, y:195}      // slot 5, bottom-right
         ];
         var _slotIndices:Array = [3, 0, 1, 2, 4, 5];

         for(var _si:int = 0; _si < 6; _si++)
         {
            var _slotIdx:int = _slotIndices[_si];
            var _pos:Object = _slotLayout[_si];
            var _cell:Sprite = this.createSlotCell(_slotIdx, _pos.label);
            _cell.x = _pos.x;
            _cell.y = _pos.y;
            _cell.name = "slot" + _slotIdx;
            this._slotSprites[_slotIdx] = _cell;
            addChild(_cell);
         }

         // 关闭按钮
         var _closeBtn:Sprite = new Sprite();
         var _cs:Shape = new Shape();
         _cs.graphics.beginFill(0x5a2010, 0.9);
         _cs.graphics.lineStyle(1, 0xC8A84E, 0.8);
         _cs.graphics.drawRoundRect(0, 0, 80, 26, 5, 5);
         _cs.graphics.endFill();
         _closeBtn.addChild(_cs);
         var _cTF:TextField = new TextField();
         _cTF.defaultTextFormat = new TextFormat("SimHei", 12, 0xFFD700, true);
         _cTF.text = "关 闭";
         _cTF.selectable = false; _cTF.autoSize = TextFieldAutoSize.CENTER;
         _cTF.x = (80 - _cTF.width) / 2; _cTF.y = 5;
         _closeBtn.addChild(_cTF);
         _closeBtn.buttonMode = true;
         _closeBtn.x = (_w - 80) / 2; _closeBtn.y = _h - 38;
         var _self:EquipPanel = this;
         _closeBtn.addEventListener(MouseEvent.CLICK, function(p:*):void {
            _self.close();
         });
         addChild(_closeBtn);

         // 批量售卖按钮
         var _batchBtn:Sprite = new Sprite();
         var _bbs:Shape = new Shape();
         _bbs.graphics.beginFill(0x5a2010, 0.9);
         _bbs.graphics.lineStyle(1, 0xC8A84E, 0.8);
         _bbs.graphics.drawRoundRect(0, 0, 80, 26, 5, 5);
         _bbs.graphics.endFill();
         _batchBtn.addChild(_bbs);
         var _bTF:TextField = new TextField();
         _bTF.defaultTextFormat = new TextFormat("SimHei", 12, 0xFFD700, true);
         _bTF.text = "批量售卖";
         _bTF.selectable = false; _bTF.autoSize = TextFieldAutoSize.CENTER;
         _bTF.x = (80 - _bTF.width) / 2; _bTF.y = 5;
         _batchBtn.addChild(_bTF);
         _batchBtn.buttonMode = true;
         _batchBtn.x = (_w - 80) / 2 + 100; _batchBtn.y = _h - 38;
         _batchBtn.addEventListener(MouseEvent.CLICK, function(p:*):void {
            p.stopImmediatePropagation();
            _self.showBatchSell();
         });
         addChild(_batchBtn);

         // 背包选择列表(初始隐藏)
         this._bagList = new Sprite();
         this._bagList.visible = false;
         addChild(this._bagList);

         this.refresh();
      }

      private function createSlotCell(param1:int, param2:String) : Sprite
      {
         var _cell:Sprite = new Sprite();
         _cell.mouseChildren = false;

         // 图标框背景
         var _frame:Shape = new Shape();
         _frame.graphics.beginFill(0x1a1008, 0.9);
         _frame.graphics.lineStyle(1.5, 0x8B6914, 0.7);
         _frame.graphics.drawRoundRect(0, 0, 50, 50, 6, 6);
         _frame.graphics.endFill();
         _cell.addChild(_frame);

         // 槽位标签
         var _labelTF:TextField = new TextField();
         _labelTF.defaultTextFormat = new TextFormat("SimHei", 11, 0xC8A84E, true);
         _labelTF.text = param2;
         _labelTF.selectable = false;
         _labelTF.autoSize = TextFieldAutoSize.CENTER;
         _labelTF.x = (50 - _labelTF.width) / 2;
         _labelTF.y = 54;
         _cell.addChild(_labelTF);

         // 点击区域
         _cell.buttonMode = true;
         var _self:EquipPanel = this;
         var _slotIdx:int = param1;
         _cell.addEventListener(MouseEvent.CLICK, function(p:MouseEvent):void {
            _self.onSlotClick(_slotIdx);
         });

         return _cell;
      }

      private var _qualityColors:Array = [0x999999,0xCCCCCC,0xCCCCCC,0x4bea13,0x4bea13,0xe720f9,0xe720f9,0xFF8C00,0xFF8C00,0xFF0000,0xFF66FF];
      private var _qualityNames:Array = ["","白色","白色","绿色","绿色","紫色","紫色","橙色","橙色","红色","彩色"];

      private function getQualityColor(param1:int):uint { return _qualityColors[param1] || 0xCCCCCC; }

      private function formatEquipInfo(param1:String):String
      {
         if(param1 == "" || param1 == null || param1 == "0") return "空";
         var _n:* = EquipData.get(param1,"name");
         var _atk:* = EquipData.get(param1,"attack");
         var _atkp:* = EquipData.get(param1,"attackPct");
         var _def:* = EquipData.get(param1,"defense");
         var _defp:* = EquipData.get(param1,"defensePct");
         var _hp:* = EquipData.get(param1,"hp");
         var _hpp:* = EquipData.get(param1,"hpPct");
         var _q:int = int(EquipData.get(param1,"quality"));
         var _s:String = "[" + this._qualityNames[_q] + "] " + String(_n||"?");
         if(int(_atk) > 0) _s += " 攻+" + int(_atk);
         if(int(_atkp) > 0) _s += " 攻+" + int(_atkp) + "%";
         if(int(_def) > 0) _s += " 防+" + int(_def);
         if(int(_defp) > 0) _s += " 防+" + int(_defp) + "%";
         if(int(_hp) > 0) _s += " HP+" + int(_hp);
         if(int(_hpp) > 0) _s += " HP+" + int(_hpp) + "%";
         return _s;
      }

      private function refresh() : void
      {
         for(var _i:int = 0; _i < 6; _i++)
         {
            var _cell:Sprite = this._slotSprites[_i] as Sprite;
            if(_cell == null) continue;
            var _eqCode:String = this._armyInfo.getEquipSlot(_i);
            // 清除旧图标 (保留frame和label)
            while(_cell.numChildren > 2) _cell.removeChildAt(2);

            if(_eqCode != null && _eqCode != "" && _eqCode != "0")
            {
               // 显示装备图标
               var _bmp:Bitmap = this.getEquipIcon(_eqCode);
               if(_bmp != null)
               {
                  _bmp.scaleX = 0.35;
                  _bmp.scaleY = 0.35;
                  _bmp.smoothing = true;
                  _bmp.x = (50 - _bmp.width) / 2;
                  _bmp.y = (50 - _bmp.height) / 2;
                  _cell.addChild(_bmp);
               }
               // 添加品质光晕
               var _q:int = int(EquipData.get(_eqCode,"quality"));
               var _glow:GlowFilter = new GlowFilter(this.getQualityColor(_q), 0.6, 6, 6, 2);
               _cell.filters = [_glow];
            }
            else
            {
               // 空槽 - 灰色占位
               _cell.filters = [];
               var _empty:Shape = new Shape();
               _empty.graphics.beginFill(0x333333, 0.5);
               _empty.graphics.drawRoundRect(12, 12, 26, 26, 3, 3);
               _empty.graphics.endFill();
               _cell.addChild(_empty);
            }
         }
         this.hideBagList();
      }

      private function getEquipIcon(param1:String) : Bitmap
      {
         if(param1 == null || param1 == "") return null;
         var _idx:* = EquipData.get(param1,"iconIdx");
         if(_idx != null && int(_idx) > 0)
         {
            var _b:Bitmap = game.ui.EquipIconsWuxia.getIcon(int(_idx));
            if(_b != null) return _b;
         }
         var _slot:* = EquipData.get(param1,"slot");
         if(_slot == null) return EquipIconAssets.weapon();
         var _s:int = int(_slot);
         if(_s == 1) return EquipIconAssets.weapon();
         if(_s == 2) return EquipIconAssets.armor();
         if(_s == 3 || _s == 6) return EquipIconAssets.accessory();
         if(_s == 4) return EquipIconAssets.helmet();
         if(_s == 5) return EquipIconAssets.boots();
         return EquipIconAssets.weapon();
      }

      private function onSlotClick(param1:int) : void
      {
         var _eqCode:String = this._armyInfo.getEquipSlot(param1);
         if(_eqCode != null && _eqCode != "" && _eqCode != "0")
         {
            this.unequip(param1);
         }
         else
         {
            this.showBagList(param1);
         }
      }

      private function unequip(param1:int) : void
      {
         var _self:EquipPanel = this;
         var _obj:Object = {};
         _obj.head = Head.HTTP_NEW_UNEQUIP;
         _obj.agent = Config.AGENT;
         _obj.ver = Config.VER;
         _obj.token = Config.token;
         _obj.roleID = RoleModel.getInstance().roleID;
         _obj.userID = RoleModel.getInstance().userID;
         _obj.id = this._armyInfo.id;
         _obj.slot = param1;
         _obj.mask = true;
         AESController.getInstance().sendJSON(_obj, function(param2:Object):void {
            if(param2.success == true)
            {
               if(param2.data.general)
               {
                  _self._armyInfo.setEquipSlot(param1, "");
                  _self._armyInfo.hp = _self._armyInfo.maxHp;
               }
               if(param2.data.bagModel)
               {
                  RoleModel.getInstance().initBagModel(param2.data.bagModel);
               }
               if(param2.data.money != undefined) RoleModel.getInstance().money = int(param2.data.money);
               _self.refresh();
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"装备已卸下,已放回背包。"}));
            }
            else
            {
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:param2.message||"卸下失败"}));
            }
         });
      }

      private function showBagList(param1:int) : void
      {
         this.hideBagList();
         this._selectingSlot = param1;
         // slot 0→1, 1→2, 2→3, 3→4, 4→5, 5→6 (EquipData slot从1开始)
         var _items:Array = RoleModel.getInstance().getBagEquipItems(param1 + 1);
         if(_items.length == 0)
         {
            this.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"背包中没有可用的" + this._slotLabels[param1] + "类装备。"}));
            return;
         }

         // 弹出列表 - 放在面板中央偏右
         this._bagList.x = 100;
         this._bagList.y = 240;
         var _listW:int = 240;
         var _listH:int = Math.min(_items.length, 5) * 28 + 8;
         this._bagList.graphics.clear();
         this._bagList.graphics.beginFill(0x1a1008, 0.97);
         this._bagList.graphics.lineStyle(1, 0x8B6914, 0.9);
         this._bagList.graphics.drawRoundRect(0, 0, _listW, _listH, 5, 5);
         this._bagList.graphics.endFill();

         var _self:EquipPanel = this;
         for(var _i:int = 0; _i < _items.length; _i++)
         {
            var _item:Object = _items[_i];
            var _elr:* = EquipData.get(_item.code,"levelReq");
            var _row:Sprite = new Sprite();
            _row.y = 4 + _i * 28;
            var _rowTF:TextField = new TextField();
            _rowTF.defaultTextFormat = new TextFormat("SimSun", 11, 0xD4C8A0);
            _rowTF.selectable = false;
            _rowTF.width = _listW - 8; _rowTF.height = 20;
            _rowTF.x = 4; _rowTF.y = 0;
            var _txt:String = this.formatEquipInfo(_item.code);
            _txt += "  Lv." + (int(_elr)||1);
            if(this._armyInfo.level < (int(_elr)||1))
            {
               _txt += " (等级不足)";
               _rowTF.textColor = 0x666666;
            }
            else
            {
               var _q2:int = int(EquipData.get(_item.code,"quality"));
               _rowTF.textColor = this.getQualityColor(_q2);
            }
            _rowTF.text = _txt;
            _row.addChild(_rowTF);
            _row.buttonMode = (this._armyInfo.level >= (int(_elr)||1));
            _row.name = _item.code;
            _row.addEventListener(MouseEvent.CLICK, function(p:*):void {
               var _code:String = p.currentTarget.name;
               _self.equip(_self._selectingSlot, _code);
            });

            // 售卖按钮
            var _sellBtn2:Sprite = new Sprite();
            _sellBtn2.name = "sell_" + _item.code;
            _sellBtn2.buttonMode = true; _sellBtn2.mouseChildren = false;
            var _sb2:Shape = new Shape();
            _sb2.graphics.beginFill(0x660000,0.85);
            _sb2.graphics.lineStyle(1,0xCC4444,0.7);
            _sb2.graphics.drawRoundRect(0,0,18,16,3,3);
            _sb2.graphics.endFill();
            _sellBtn2.addChild(_sb2);
            var _stf2:TextField = new TextField();
            _stf2.defaultTextFormat = new TextFormat("SimSun",9,0xFF6666,true);
            _stf2.text = "售"; _stf2.selectable = false;
            _stf2.width = 18; _stf2.height = 14; _stf2.x = 1; _stf2.y = 1;
            _sellBtn2.addChild(_stf2);
            _sellBtn2.x = _listW - 24; _sellBtn2.y = 4;
            _sellBtn2.addEventListener(MouseEvent.CLICK, function(p:*):void {
               p.stopImmediatePropagation();
               var _sc:String = p.currentTarget.name.replace("sell_","");
               _self.onSellEquipClick(_sc);
            });
            _row.addChild(_sellBtn2);

            this._bagList.addChild(_row);
         }
         this._bagList.visible = true;
      }

      private function hideBagList() : void
      {
         this._bagList.visible = false;
         while(this._bagList.numChildren > 0) this._bagList.removeChildAt(0);
         this._selectingSlot = -1;
      }

      private function equip(param1:int, param2:String) : void
      {
         var _self:EquipPanel = this;
         var _obj:Object = {};
         _obj.head = Head.HTTP_NEW_EQUIP;
         _obj.agent = Config.AGENT;
         _obj.ver = Config.VER;
         _obj.token = Config.token;
         _obj.roleID = RoleModel.getInstance().roleID;
         _obj.userID = RoleModel.getInstance().userID;
         _obj.id = this._armyInfo.id;
         _obj.slot = param1;
         _obj.itemCode = param2;
         _obj.mask = true;
         AESController.getInstance().sendJSON(_obj, function(param3:Object):void {
            if(param3.success == true)
            {
               if(param3.data.general)
               {
                  var _eqArr:Array = param3.data.general.equipment.split(",");
                  if(_eqArr.length > param1 && _eqArr[param1] != "0")
                  {
                     _self._armyInfo.setEquipSlot(param1, _eqArr[param1]);
                  }
                  else
                  {
                     _self._armyInfo.setEquipSlot(param1, param2);
                  }
               }
               _self._armyInfo.hp = _self._armyInfo.maxHp; // 钳制到新maxHp
               if(param3.data.bagModel)
               {
                  RoleModel.getInstance().initBagModel(param3.data.bagModel);
               }
               if(param3.data.money != undefined) RoleModel.getInstance().money = int(param3.data.money);
               _self.refresh();
               var _en2:* = EquipData.get(param2,"name");
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"已装备 " + String(_en2||"")}));
            }
            else
            {
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:param3.message||"装备失败"}));
            }
         });
      }

      private static function getEquipSellPrice(code:String):Object {
         var q:int = int(EquipData.get(code,"quality"))||1;
         var lv:int = int(EquipData.get(code,"levelReq"))||1;
         var silver:int = q * lv * 50;
         return {silver: silver, dianka: q >= 6 ? (q - 5) * 10 : 0};
      }

      private function onSellEquipClick(code:String):void {
         var _self:EquipPanel = this;
         var price:Object = getEquipSellPrice(code);
         var nm:* = EquipData.get(code,"name");
         var msg:String = "确定要售卖 [" + nm + "] 吗？\n";
         msg += "可获得：银子+" + price.silver;
         if(price.dianka > 0) msg += "  点卡+" + price.dianka;
         _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
            "type":1,
            "text":msg,
            "fun":function():void { _self.sellEquip(code); }
         }));
      }

      private function sellEquip(code:String):void {
         var _self:EquipPanel = this;
         var _obj:Object = {};
         _obj.head = Head.HTTP_NEW_SELL_EQUIP;
         _obj.agent = Config.AGENT;
         _obj.ver = Config.VER;
         _obj.token = Config.token;
         _obj.roleID = RoleModel.getInstance().roleID;
         _obj.userID = RoleModel.getInstance().userID;
         _obj.itemCode = code;
         _obj.mask = true;
         AESController.getInstance().sendJSON(_obj, function(param1:Object):void {
            if(param1.success == true)
            {
               if(param1.data.bagModel) RoleModel.getInstance().initBagModel(param1.data.bagModel);
               if(param1.data.money != undefined) RoleModel.getInstance().money = int(param1.data.money);
               if(param1.data.dianka != undefined) RoleModel.getInstance().dianka = int(param1.data.dianka);
               _self.refresh();
               var price:Object = getEquipSellPrice(code);
               var nm:* = EquipData.get(code,"name");
               var doneMsg:String = "已售卖 " + nm + "，获得银子+" + price.silver;
               if(price.dianka > 0) doneMsg += " 点卡+" + price.dianka;
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:doneMsg}));
            }
            else
            {
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:param1.message||"售卖失败"}));
            }
         });
      }

      // ========== 批量售卖 ==========
      private var _batchSelected:Object = {};
      private var _batchFilterQ:int = 0;

      private function showBatchSell() : void {
         this.hideBagList();
         var _self:EquipPanel = this;
         var _allItems:Array = RoleModel.getInstance().getBagEquipItems(0);
         if(_allItems.length == 0) {
            this.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"背包中没有可售卖的装备。"}));
            return;
         }
         this._batchSelected = {};
         for(var _ai:int = 0; _ai < _allItems.length; _ai++) {
            this._batchSelected[_allItems[_ai].code] = true;
         }

         var _w:int = 400; var _h:int = 300;
         var _bx:int = 20; var _by:int = 60;
         this._bagList.x = _bx; this._bagList.y = _by;
         this._bagList.graphics.clear();
         this._bagList.graphics.beginFill(0x1a1008, 0.97);
         this._bagList.graphics.lineStyle(1.5, 0xC8A84E, 0.9);
         this._bagList.graphics.drawRoundRect(0, 0, _w, _h, 8, 8);
         this._bagList.graphics.endFill();

         var _tTF:TextField = new TextField();
         _tTF.defaultTextFormat = new TextFormat("SimHei", 13, 0xFFD700, true);
         _tTF.text = "批量售卖 (" + _allItems.length + "件)"; _tTF.selectable = false;
         _tTF.autoSize = TextFieldAutoSize.CENTER; _tTF.x = (_w - _tTF.width)/2; _tTF.y = 6;
         this._bagList.addChild(_tTF);

         // 品质筛选
         var _qRowY:int = 30;
         var _qlTF:TextField = new TextField();
         _qlTF.defaultTextFormat = new TextFormat("SimSun", 10, 0x998866);
         _qlTF.text = "品质:"; _qlTF.selectable = false;
         _qlTF.width = 35; _qlTF.height = 16; _qlTF.x = 6; _qlTF.y = _qRowY + 2;
         this._bagList.addChild(_qlTF);
         for(var _qi:int = 1; _qi <= 10; _qi++) {
            var _qb:Sprite = new Sprite();
            _qb.name = "qbtn" + _qi;
            _qb.buttonMode = true; _qb.mouseChildren = false;
            var _qx:int = 40 + (_qi-1) * 35;
            var _qs:Shape = new Shape();
            var _qc:uint = (_qi == this._batchFilterQ) ? 0x8B6914 : 0x221100;
            _qs.graphics.beginFill(_qc, 0.9);
            _qs.graphics.lineStyle(1, _qi == this._batchFilterQ ? 0xFFD700 : 0x554422, 0.7);
            _qs.graphics.drawRoundRect(0, 0, 32, 16, 3, 3);
            _qs.graphics.endFill();
            _qb.addChild(_qs);
            var _qtf:TextField = new TextField();
            _qtf.defaultTextFormat = new TextFormat("SimSun", 9, _qi == this._batchFilterQ ? 0xFFD700 : 0x776644);
            _qtf.text = "Q" + _qi; _qtf.selectable = false; _qtf.width = 32; _qtf.height = 14; _qtf.x = 0; _qtf.y = 1;
            _qb.addChild(_qtf);
            _qb.x = _qx; _qb.y = _qRowY;
            _qb.addEventListener(MouseEvent.CLICK, function(p:*):void {
               var _qn:int = int(p.currentTarget.name.replace("qbtn",""));
               _self._batchFilterQ = (_self._batchFilterQ == _qn) ? 0 : _qn;
               _self.showBatchSell();
            });
            this._bagList.addChild(_qb);
         }

         // 全选/取消
         var _allBtn:Sprite = new Sprite();
         _allBtn.buttonMode = true; _allBtn.mouseChildren = false;
         _allBtn.x = _w - 66; _allBtn.y = _qRowY;
         var _abg:Shape = new Shape();
         _abg.graphics.beginFill(0x332200, 0.9);
         _abg.graphics.lineStyle(1, 0x8B6914, 0.7);
         _abg.graphics.drawRoundRect(0, 0, 60, 16, 3, 3);
         _abg.graphics.endFill();
         _allBtn.addChild(_abg);
         var _atf:TextField = new TextField();
         _atf.defaultTextFormat = new TextFormat("SimSun", 10, 0xCCAA44);
         _atf.text = "全选/取消"; _atf.selectable = false;
         _atf.width = 60; _atf.height = 14; _atf.x = 0; _atf.y = 1;
         _allBtn.addChild(_atf);
         _allBtn.addEventListener(MouseEvent.CLICK, function(p:*):void {
            var _any:Boolean = false;
            for(var _k:String in _self._batchSelected) { if(_self._batchSelected[_k]) { _any = true; break; } }
            for(var _k2:String in _self._batchSelected) _self._batchSelected[_k2] = !_any;
            _self.showBatchSell();
         });
         this._bagList.addChild(_allBtn);

         // 物品列表
         var _listY:int = _qRowY + 22;
         var _vis:int = 0;
         for(var _vi:int = 0; _vi < _allItems.length; _vi++) {
            var _it2:Object = _allItems[_vi];
            var _q:int = int(EquipData.get(_it2.code,"quality"));
            if(this._batchFilterQ > 0 && _q != this._batchFilterQ) continue;
            if(_vis >= 9) break; _vis++;
            var _row2:Sprite = new Sprite();
            _row2.y = _listY + (_vis-1) * 24;
            _row2.name = "row_" + _it2.code;

            var _cb:Sprite = new Sprite();
            _cb.name = "cb_" + _it2.code;
            _cb.mouseChildren = false;
            var _cbs:Shape = new Shape();
            var _sel2:Boolean = this._batchSelected[_it2.code] == true;
            _cbs.graphics.beginFill(_sel2 ? 0x8B6914 : 0x1a1008, 0.9);
            _cbs.graphics.lineStyle(1, _sel2 ? 0xFFD700 : 0x554422, 0.8);
            _cbs.graphics.drawRoundRect(0, 0, 14, 14, 2, 2);
            _cbs.graphics.endFill();
            if(_sel2) {
               _cbs.graphics.lineStyle(2, 0xFFD700, 1);
               _cbs.graphics.moveTo(3, 7); _cbs.graphics.lineTo(6, 10); _cbs.graphics.lineTo(11, 4);
            }
            _cb.addChild(_cbs);
            _cb.x = 6; _cb.y = 3;
            _cb.addEventListener(MouseEvent.CLICK, function(p:*):void {
               p.stopImmediatePropagation();
               var _c2:String = p.currentTarget.name.replace("cb_","");
               _self._batchSelected[_c2] = !_self._batchSelected[_c2];
               _self.showBatchSell();
            });
            _row2.addChild(_cb);

            var _nTF2:TextField = new TextField();
            _nTF2.defaultTextFormat = new TextFormat("SimSun", 10, this.getQualityColor(_q));
            var _nm2:* = EquipData.get(_it2.code,"name");
            var _lv2:int = int(EquipData.get(_it2.code,"levelReq"))||1;
            var _pr2:Object = getEquipSellPrice(_it2.code);
            _nTF2.text = _nm2 + " Q" + _q + " Lv" + _lv2 + "  ¥" + _pr2.silver;
            _nTF2.selectable = false; _nTF2.width = 320; _nTF2.height = 20;
            _nTF2.x = 26; _nTF2.y = 1;
            _row2.addChild(_nTF2);
            this._bagList.addChild(_row2);
         }

         // 底部统计
         var _totalS:int = 0; var _totalD:int = 0; var _sellCount:int = 0;
         var _selectedCodes:Array = [];
         for(var _si2:int = 0; _si2 < _allItems.length; _si2++) {
            var _code3:String = _allItems[_si2].code;
            if(this._batchSelected[_code3] == true) {
               var _q3:int = int(EquipData.get(_code3,"quality"));
               if(this._batchFilterQ > 0 && _q3 != this._batchFilterQ) continue;
               var _p3:Object = getEquipSellPrice(_code3);
               _totalS += _p3.silver; _totalD += _p3.dianka; _sellCount++;
               _selectedCodes.push(_code3);
            }
         }

         var _btmY:int = _h - 34;
         var _sumTF:TextField = new TextField();
         _sumTF.defaultTextFormat = new TextFormat("SimHei", 11, 0xFFD700);
         _sumTF.text = "选中" + _sellCount + "件  银子+" + _totalS + (_totalD > 0 ? "  点卡+" + _totalD : "");
         _sumTF.selectable = false; _sumTF.autoSize = TextFieldAutoSize.CENTER;
         _sumTF.x = (_w - _sumTF.width)/2; _sumTF.y = _btmY;
         this._bagList.addChild(_sumTF);

         if(_sellCount > 0) {
            var _cnf:Sprite = new Sprite();
            _cnf.buttonMode = true; _cnf.mouseChildren = false;
            _cnf.x = (_w - 120)/2; _cnf.y = _btmY + 18;
            var _cbg2:Shape = new Shape();
            _cbg2.graphics.beginFill(0x8B0000, 0.9);
            _cbg2.graphics.lineStyle(1.5, 0xFF6600, 0.8);
            _cbg2.graphics.drawRoundRect(0, 0, 120, 22, 4, 4);
            _cbg2.graphics.endFill();
            _cnf.addChild(_cbg2);
            var _ct2:TextField = new TextField();
            _ct2.defaultTextFormat = new TextFormat("SimHei", 12, 0xFFD700, true);
            _ct2.text = "确认批量售卖"; _ct2.selectable = false;
            _ct2.autoSize = TextFieldAutoSize.CENTER; _ct2.x = (120 - _ct2.width)/2; _ct2.y = 3;
            _cnf.addChild(_ct2);
            var _finalCodes:Array = _selectedCodes;
            var _finalS:int = _totalS; var _finalD:int = _totalD;
            _cnf.addEventListener(MouseEvent.CLICK, function(p:*):void {
               var _msg:String = "确定要批量售卖" + _finalCodes.length + "件装备吗？\n可得银子+" + _finalS + (_finalD > 0 ? " 点卡+" + _finalD : "");
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":1, "text":_msg,
                  "fun":function():void { _self.batchSellEquip(_finalCodes); }
               }));
            });
            this._bagList.addChild(_cnf);
         }

         this._bagList.visible = true;
      }

      private function batchSellEquip(codes:Array):void {
         var _self:EquipPanel = this;
         var _obj:Object = {};
         _obj.head = Head.HTTP_NEW_SELL_EQUIP;
         _obj.agent = Config.AGENT;
         _obj.ver = Config.VER;
         _obj.token = Config.token;
         _obj.roleID = RoleModel.getInstance().roleID;
         _obj.userID = RoleModel.getInstance().userID;
         _obj.itemCodes = codes.join(",");
         _obj.mask = true;
         AESController.getInstance().sendJSON(_obj, function(param1:Object):void {
            if(param1.success == true)
            {
               if(param1.data.bagModel) RoleModel.getInstance().initBagModel(param1.data.bagModel);
               if(param1.data.money != undefined) RoleModel.getInstance().money = int(param1.data.money);
               if(param1.data.dianka != undefined) RoleModel.getInstance().dianka = int(param1.data.dianka);
               _self.refresh();
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  type:0, text:"批量售卖完成！售出" + (param1.data.soldCount||codes.length) + "件，银子+" + (param1.data.totalSilver||0) + (param1.data.totalDianka > 0 ? " 点卡+" + param1.data.totalDianka : "")
               }));
               _self.close();
            }
            else
            {
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:param1.message||"批量售卖失败"}));
            }
         });
      }

      public function close() : void
      {
         if(this.parent) this.parent.removeChild(this);
      }
   }
}
