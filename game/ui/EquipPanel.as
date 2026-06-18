package game.ui
{
   import com.iflashigame.controller.AESController;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.filters.GlowFilter;
   import game.Config;
   import game.Data;
   import game.model.ArmyInfo;
   import game.model.Head;
   import game.model.RoleModel;
   import game.events.UIEvent;

   public class EquipPanel extends Sprite
   {
      private var _armyInfo:ArmyInfo;
      private var _slotLabels:Array = ["武器","防具","饰品"];
      private var _slotKeys:Array = ["equip1","equip2","equip3"];
      private var _slotIdx:Array = [0,1,2];
      private var _slotTFs:Array = [];
      private var _slotBtns:Array = [];
      private var _bagList:Sprite;
      private var _bagItems:Array = [];
      private var _selectingSlot:int = -1;

      public function EquipPanel(param1:ArmyInfo)
      {
         super();
         this._armyInfo = param1;
         this.buildUI();
      }

      private function buildUI() : void
      {
         var _w:int = 340;
         var _h:int = 260;

         // 背景
         var _bg:Shape = new Shape();
         _bg.graphics.beginFill(0x0d0804, 0.96);
         _bg.graphics.lineStyle(2, 0x8B6914, 0.9);
         _bg.graphics.drawRoundRect(0, 0, _w, _h, 10, 10);
         _bg.graphics.endFill();
         _bg.graphics.lineStyle(1, 0xC8A84E, 0.5);
         _bg.graphics.moveTo(10, 32); _bg.graphics.lineTo(_w - 10, 32);
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

         // 3个装备槽
         for(var _i:int = 0; _i < 3; _i++)
         {
            var _slotY:int = 40 + _i * 50;
            // 槽位标签
            var _labelTF:TextField = new TextField();
            _labelTF.defaultTextFormat = new TextFormat("SimSun", 12, 0xC8A84E, true);
            _labelTF.text = this._slotLabels[_i] + ":";
            _labelTF.selectable = false;
            _labelTF.width = 50; _labelTF.x = 14; _labelTF.y = _slotY;
            addChild(_labelTF);

            // 装备内容
            var _contentTF:TextField = new TextField();
            _contentTF.defaultTextFormat = new TextFormat("SimSun", 12, 0xD4C8A0);
            _contentTF.selectable = false;
            _contentTF.wordWrap = true;
            _contentTF.width = 160; _contentTF.height = 42;
            _contentTF.x = 64; _contentTF.y = _slotY;
            addChild(_contentTF);
            this._slotTFs.push(_contentTF);

            // 操作按钮
            var _btn:Sprite = new Sprite();
            var _bs:Shape = new Shape();
            _bs.graphics.beginFill(0x3a2010, 0.9);
            _bs.graphics.lineStyle(1, 0xC8A84E, 0.7);
            _bs.graphics.drawRoundRect(0, 0, 54, 22, 4, 4);
            _bs.graphics.endFill();
            _btn.addChild(_bs);
            var _bTF:TextField = new TextField();
            _bTF.defaultTextFormat = new TextFormat("SimSun", 11, 0xFFD700);
            _bTF.selectable = false;
            _bTF.width = 54; _bTF.height = 18;
            _bTF.x = 0; _bTF.y = 3;
            _bTF.text = "...";
            _btn.addChild(_bTF);
            _btn.buttonMode = true;
            _btn.x = 234; _btn.y = _slotY;
            this._slotBtns.push({btn:_btn, tf:_bTF, index:_i});
            var _self:EquipPanel = this;
            _btn.addEventListener(MouseEvent.CLICK, function(p:*):void {
               _self.onSlotClick(int(p.currentTarget.name));
            });
            _btn.name = String(_i);
            addChild(_btn);
         }

         // 关闭按钮
         var _closeBtn:Sprite = new Sprite();
         var _cs:Shape = new Shape();
         _cs.graphics.beginFill(0x5a2010, 0.9);
         _cs.graphics.lineStyle(1, 0xC8A84E, 0.8);
         _cs.graphics.drawRoundRect(0, 0, 70, 24, 5, 5);
         _cs.graphics.endFill();
         _closeBtn.addChild(_cs);
         var _cTF:TextField = new TextField();
         _cTF.defaultTextFormat = new TextFormat("SimHei", 12, 0xFFD700, true);
         _cTF.text = "关闭";
         _cTF.selectable = false; _cTF.autoSize = TextFieldAutoSize.CENTER;
         _cTF.x = (70 - _cTF.width) / 2; _cTF.y = 4;
         _closeBtn.addChild(_cTF);
         _closeBtn.buttonMode = true;
         _closeBtn.x = (_w - 70) / 2; _closeBtn.y = _h - 32;
         _closeBtn.addEventListener(MouseEvent.CLICK, function(p:*):void {
            _self.close();
         });
         addChild(_closeBtn);

         // 背包选择列表(初始隐藏)
         this._bagList = new Sprite();
         this._bagList.x = 64; this._bagList.y = 60;
         this._bagList.visible = false;
         addChild(this._bagList);

         this.refresh();
      }

      private var _qualityColors:Array = [0x999999,0xCCCCCC,0x4bea13,0x16d2fa,0xe720f9,0xFFD700];
      private var _qualityNames:Array = ["","普通","精良","稀有","史诗","传说"];

      private function getQualityColor(param1:int):uint { return _qualityColors[param1] || 0xCCCCCC; }
      private function getQualityName(param1:int):String { return _qualityNames[param1] || "?"; }

      private function formatEquipInfo(param1:String):String
      {
         if(param1 == "" || param1 == null || param1 == "0") return "空";
         var _n:* = Data.getInstance().getAttributes("equip",param1,"name");
         var _atk:* = Data.getInstance().getAttributes("equip",param1,"attack");
         var _atkp:* = Data.getInstance().getAttributes("equip",param1,"attackPct");
         var _def:* = Data.getInstance().getAttributes("equip",param1,"defense");
         var _defp:* = Data.getInstance().getAttributes("equip",param1,"defensePct");
         var _hp:* = Data.getInstance().getAttributes("equip",param1,"hp");
         var _hpp:* = Data.getInstance().getAttributes("equip",param1,"hpPct");
         var _q:int = int(Data.getInstance().getAttributes("equip",param1,"quality"));
         var _s:String = "[" + this.getQualityName(_q) + "] " + String(_n||"?");
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
         for(var _i:int = 0; _i < 3; _i++)
         {
            var _eqCode:String = this._armyInfo.getEquipSlot(_i);
            var _tf:TextField = this._slotTFs[_i];
            var _btnData:Object = this._slotBtns[_i];
            if(_eqCode != null && _eqCode != "" && _eqCode != "0")
            {
               _tf.text = this.formatEquipInfo(_eqCode);
               var _q:int = int(Data.getInstance().getAttributes("equip",_eqCode,"quality"));
               _tf.textColor = this.getQualityColor(_q);
               _btnData.tf.text = "卸下";
            }
            else
            {
               _tf.text = "空";
               _tf.textColor = 0x666666;
               _btnData.tf.text = "装备";
            }
         }
         this.hideBagList();
      }

      private function onSlotClick(param1:int) : void
      {
         var _eqCode:String = this._armyInfo.getEquipSlot(param1);
         if(_eqCode != null && _eqCode != "" && _eqCode != "0")
         {
            // 卸下操作
            this.unequip(param1);
         }
         else
         {
            // 显示背包中对应类型的装备
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
                  _self._armyInfo.hp = _self._armyInfo.hp;
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
         var _items:Array = RoleModel.getInstance().getBagEquipItems(param1 + 1);
         if(_items.length == 0)
         {
            this.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"背包中没有可用的" + this._slotLabels[param1] + "类装备。"}));
            return;
         }

         // 绘制背包列表背景
         this._bagList.graphics.clear();
         var _listH:int = Math.min(_items.length, 5) * 28 + 8;
         this._bagList.graphics.beginFill(0x1a1008, 0.95);
         this._bagList.graphics.lineStyle(1, 0x8B6914, 0.8);
         this._bagList.graphics.drawRoundRect(0, 0, 200, _listH, 5, 5);
         this._bagList.graphics.endFill();

         var _self:EquipPanel = this;
         for(var _i:int = 0; _i < _items.length; _i++)
         {
            var _item:Object = _items[_i];
            var _en:* = Data.getInstance().getAttributes("equip",_item.code,"name");
            var _ea:* = Data.getInstance().getAttributes("equip",_item.code,"attack");
            var _ed:* = Data.getInstance().getAttributes("equip",_item.code,"defense");
            var _eh:* = Data.getInstance().getAttributes("equip",_item.code,"hp");
            var _elr:* = Data.getInstance().getAttributes("equip",_item.code,"levelReq");

            var _row:Sprite = new Sprite();
            _row.y = 4 + _i * 28;

            var _rowTF:TextField = new TextField();
            _rowTF.defaultTextFormat = new TextFormat("SimSun", 11, 0xD4C8A0);
            _rowTF.selectable = false;
            _rowTF.width = 195; _rowTF.height = 20;
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
               var _q2:int = int(Data.getInstance().getAttributes("equip",_item.code,"quality"));
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
                  _self._armyInfo.setEquipSlot(param1, param3.data.general.equipment ?
                     param3.data.general.equipment.split(",")[param1] : param2);
               }
               if(param3.data.bagModel)
               {
                  RoleModel.getInstance().initBagModel(param3.data.bagModel);
               }
               if(param3.data.money != undefined) RoleModel.getInstance().money = int(param3.data.money);
               _self.refresh();
               var _en2:* = Data.getInstance().getAttributes("equip",param2,"name");
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"已装备 " + String(_en2||"")}));
            }
            else
            {
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:param3.message||"装备失败"}));
            }
         });
      }

      public function close() : void
      {
         if(this.parent) this.parent.removeChild(this);
      }
   }
}
