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
      // 6槽位: 0=武器 1=铠甲 2=饰品Ⅰ 3=头盔 4=战靴 5=饰品Ⅱ
      private var _slotLabels:Array = ["武器","铠甲","饰品Ⅰ","头盔","战靴","饰品Ⅱ"];
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
         var base:int = q * lv;
         var silver:int = q >= 8 ? base * 5000 : base * 500;
         return {silver: silver, dianka: q >= 6 ? (q - 5) * 30 : 0};
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

      public function close() : void
      {
         if(this.parent) this.parent.removeChild(this);
      }
   }
}
