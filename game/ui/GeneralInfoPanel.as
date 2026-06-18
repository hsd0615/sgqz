package game.ui
{
   import com.iflashigame.controller.AESController;
   import com.iflashigame.talk.NetInfoType;
   import com.iflashigame.talk.TalkEvent;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.BlurFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFieldAutoSize;
   import game.Config;
   import game.Data;
   import game.Logic;
   import game.TextFactory;
   import game.events.UIEvent;
   import game.model.ArmyInfo;
   import game.model.EquipData;
   import game.model.Head;
   import game.model.RoleModel;
   import game.model.Type;
   import game.ui.EquipIconAssets;
   import game.ui.EquipIconsWuxia;

   public class GeneralInfoPanel extends BaseUI
   {


      private var __nameTF:TextField;

      private var __titleTF:TextField;

      private var __valueTF:TextField;

      private var __xiaohaoTF:TextField;

      private var __shengjiBtn:SimpleButton;

      private var __jinhuaBtn:SimpleButton;

      private var __sxcxBtn:MovieClip;

      private var __kezhi1TF:TextField;

      private var __kezhi2TF:TextField;

      private var __kezhi3TF:TextField;

      private var __kezhi1Btn:MovieClip;

      private var __kezhi2Btn:MovieClip;

      private var __kezhi3Btn:MovieClip;

      private var __tianfuNameTF:TextField;

      private var __tianfuDescTF:TextField;

      private var __chongxiBtn:MovieClip;

      private var __jihuoBtn:MovieClip;

      private var __moneyTF:TextField;

      private var __exploitTF:TextField;

      private var __closeBtn:SimpleButton;

      private var __shopBtn:SimpleButton;

      private var _pos1:Point;

      private var _pos2:Point;

      private var _pos3:Point;

      private var _point:Point;

      private var _armyInfo:ArmyInfo;

      private var _general:MovieClip;

      private var _icon1:Sprite;

      private var _icon2:Sprite;

      private var _icon3:Sprite;

      // 6个装备槽
      private var _equipSlots:Array = [];
      // 槽位标签: 0=武器 1=铠甲 2=饰品Ⅰ 3=头盔 4=战靴 5=饰品Ⅱ
      private static const SLOT_LABELS:Array = ["武器","铠甲","饰品","头盔","战靴","饰品"];
      private var _bagList:Sprite;
      private var _selectingSlot:int = -1;

      public function GeneralInfoPanel(param1:String, param2:ApplicationDomain = null)
      {
         this._pos1 = new Point(-300,69);
         this._pos2 = new Point(-231,69);
         this._pos3 = new Point(-163,69);
         this._point = new Point(-235,-65);
         super(param1,param2);
      }

      override protected function initView() : void
      {
         this.__nameTF = _skin.getChildByName("_nameTF") as TextField;
         this.__titleTF = _skin.getChildByName("_titleTF") as TextField;
         this.__valueTF = _skin.getChildByName("_valueTF") as TextField;
         this.__xiaohaoTF = _skin.getChildByName("_xiaohaoTF") as TextField;
         this.__shengjiBtn = _skin.getChildByName("_shengjiBtn") as SimpleButton;
         this.__jinhuaBtn = _skin.getChildByName("_jinhuaBtn") as SimpleButton;
         this.__sxcxBtn = _skin.getChildByName("_sxcxBtn") as MovieClip;
         this.__kezhi1TF = _skin.getChildByName("_kezhi1TF") as TextField;
         this.__kezhi2TF = _skin.getChildByName("_kezhi2TF") as TextField;
         this.__kezhi3TF = _skin.getChildByName("_kezhi3TF") as TextField;
         this.__kezhi1Btn = _skin.getChildByName("_kezhi1Btn") as MovieClip;
         this.__kezhi2Btn = _skin.getChildByName("_kezhi2Btn") as MovieClip;
         this.__kezhi3Btn = _skin.getChildByName("_kezhi3Btn") as MovieClip;
         this.__tianfuNameTF = _skin.getChildByName("_tianfuNameTF") as TextField;
         this.__tianfuDescTF = _skin.getChildByName("_tianfuDescTF") as TextField;
         this.__chongxiBtn = _skin.getChildByName("_chongxiBtn") as MovieClip;
         this.__jihuoBtn = _skin.getChildByName("_jihuoBtn") as MovieClip;
         this.__moneyTF = _skin.getChildByName("_moneyTF") as TextField;
         this.__exploitTF = _skin.getChildByName("_exploitTF") as TextField;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__shopBtn = _skin.getChildByName("_shopBtn") as SimpleButton;
         this.__kezhi1Btn.buttonMode = true;
         this.__kezhi2Btn.buttonMode = true;
         this.__kezhi3Btn.buttonMode = true;
         this.__jihuoBtn.buttonMode = true;
         this.__chongxiBtn.buttonMode = true;
         this.__sxcxBtn.buttonMode = true;
         this.__jihuoBtn.visible = false;
         this.__chongxiBtn.visible = false;
         this.__sxcxBtn.visible = true;

         this.findEquipSlots();
         var _ai:int = 0;
         while(_ai < 6)
         {
            if(this._equipSlots[_ai] != null) addChild(this._equipSlots[_ai] as DisplayObject);
            _ai++;
         }

         this._bagList = new Sprite();
         this._bagList.visible = false;
         addChild(this._bagList);
      }

      /**
       * 创建6个装备槽交互覆盖层。
       * 每个槽位坐标在 _slotPositions 数组中定义。
       *
       * 如何提供坐标给我:
       *   打开武将详情面板截图, 对每个槽位标注你想要的 x,y 像素位置。
       *   例如: "武器槽应该在 (-300, -120), 铠甲槽应该在 (-240, -120)..."
       *   我修改下方数组即可, 无需重新部署整个游戏逻辑。
       *
       * 坐标系说明:
       *   - 原点 (0,0) 是 _skin 的注册点
       *   - 武将中心约在 (-235, -65)
       *   - x 负值向左, y 负值向上
       *   - 每格 48×48 像素
       */
      private function findEquipSlots() : void
      {
         var _sW:int = 34;
         var _sH:int = 34;

         // 布局: 左列=头盔/铠甲/战靴, 右列=武器/饰品Ⅰ/饰品Ⅱ
         var _slotPositions:Array = [
            {x:-165, y:-208},  // 0:武器   (右,上)
            {x:-329, y:-146},  // 1:铠甲   (左,中)
            {x:-165, y:-146},  // 2:饰品Ⅰ (右,中)
            {x:-329, y:-208},  // 3:头盔   (左,上)
            {x:-329, y:-85},   // 4:战靴   (左,下)
            {x:-165, y:-85}    // 5:饰品Ⅱ (右,下)
         ];

         var _j:int = 0;
         while(_j < 6)
         {
            var _s:Sprite = new Sprite();
            _s.name = "equipSlot" + _j;
            _s.buttonMode = true;
            _s.mouseChildren = false;
            _s.x = _slotPositions[_j].x;
            _s.y = _slotPositions[_j].y;

            // 纯透明覆盖层(仅用于点击区域, 无任何可见元素)
            var _bb:Shape = new Shape();
            _bb.graphics.beginFill(0x000000, 0);
            _bb.graphics.drawRoundRect(0, 0, _sW, _sH, 5, 5);
            _bb.graphics.endFill();
            _s.addChild(_bb);

            this._equipSlots[_j] = _s;
            _j++;
         }
      }

      override protected function initEvent() : void
      {
         RoleModel.getInstance().addEventListener(Event.CHANGE,this.onRoleModelChange);
         this.__shengjiBtn.addEventListener(MouseEvent.CLICK,this.shengjiBtnClickHandler);
         this.__jinhuaBtn.addEventListener(MouseEvent.CLICK,this.jinhuaBtnClickHandler);
         this.__kezhi1Btn.addEventListener(MouseEvent.CLICK,this.kezhi1BtnClickHandler);
         this.__kezhi2Btn.addEventListener(MouseEvent.CLICK,this.kezhi2BtnClickHandler);
         this.__kezhi3Btn.addEventListener(MouseEvent.CLICK,this.kezhi3BtnClickHandler);
         this.__chongxiBtn.addEventListener(MouseEvent.CLICK,this.chongxiBtnClickHandler);
         this.__jihuoBtn.addEventListener(MouseEvent.CLICK,this.jihuoBtnClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this.__shopBtn.addEventListener(MouseEvent.CLICK,this.onShopBtnClickHandler);
         this.__sxcxBtn.addEventListener(MouseEvent.CLICK,this.onSxcxBtnClickHandler);

         var _si:int = 0;
         while(_si < 6)
         {
            var _slot:DisplayObject = this._equipSlots[_si] as DisplayObject;
            if(_slot != null)
            {
               if(_slot is Sprite) (_slot as Sprite).mouseEnabled = true;
               if(_slot is MovieClip) (_slot as MovieClip).mouseEnabled = true;
               if(_slot is Sprite) (_slot as Sprite).buttonMode = true;
               _slot.addEventListener(MouseEvent.CLICK, this.onEquipSlotClick);
            }
            _si++;
         }
      }

      override public function initData(param1:Object) : void
      {
         this._armyInfo = param1 as ArmyInfo;
         this.flush();
      }

      public function flush() : *
      {
         this.__nameTF.text = this._armyInfo.name + "\nLv:" + this._armyInfo.level;
         this.createGeneral(this._armyInfo.skin);
         this.__titleTF.htmlText = Type.createTitle(this._armyInfo.title);
         this.createValueTF();
         this.createXiaohaoTF();
         this.createKezhi();
         this.createTianfu();
         this.__moneyTF.text = RoleModel.getInstance().money.toString();
         this.__exploitTF.text = RoleModel.getInstance().exploit.toString();
         this.showEquipSlots();
      }

      private function showEquipSlots() : void
      {
         var _si:int = 0;
         while(_si < 6)
         {
            var _slot:DisplayObject = this._equipSlots[_si] as DisplayObject;
            if(_slot == null) { _si++; continue; }
            var _eqCode:String = this._armyInfo.getEquipSlot(_si);

            if(_slot is Sprite)
            {
               var _spr:Sprite = _slot as Sprite;
               var _ci:int = _spr.numChildren - 1;
               while(_ci >= 0)
               {
                  var _child:* = _spr.getChildAt(_ci);
                  if(_child is Bitmap) _spr.removeChildAt(_ci);
                  _ci--;
               }
            }
            if(_slot is MovieClip)
            {
               var _mc:MovieClip = _slot as MovieClip;
               var _cim:int = _mc.numChildren - 1;
               while(_cim >= 0)
               {
                  if(_mc.getChildAt(_cim) is Bitmap) _mc.removeChildAt(_cim);
                  _cim--;
               }
            }

            _slot.name = "equipSlot" + _si;

            // 清除旧的图标和背景(保留index0的透明点击区域)
            if(_slot is Sprite) {
               var _sp:Sprite = _slot as Sprite;
               while(_sp.numChildren > 1) _sp.removeChildAt(1);
            } else if(_slot is MovieClip) {
               var _mp:MovieClip = _slot as MovieClip;
               while(_mp.numChildren > 1) _mp.removeChildAt(1);
            }
            _slot.filters = [];

            if(_eqCode != null && _eqCode != "" && _eqCode != "0")
            {
               var _q:int = int(EquipData.get(_eqCode,"quality"));
               var _qc:uint = getQualityBgColor(_q);

               // 品质纯色背景
               var _bg:Shape = new Shape();
               _bg.graphics.beginFill(_qc, 0.7);
               _bg.graphics.drawRoundRect(1, 1, 32, 32, 4, 4);
               _bg.graphics.endFill();
               if(_slot is Sprite) (_slot as Sprite).addChild(_bg);
               else (_slot as MovieClip).addChild(_bg);

               // 装备图标
               var _bmp:Bitmap = this.getEquipBmp(_eqCode);
               if(_bmp != null)
               {
                  var _esz:Number = 30 / Math.max(_bmp.width, _bmp.height);
                  _bmp.scaleX = _esz; _bmp.scaleY = _esz;
                  _bmp.smoothing = true;
                  _bmp.x = int((34 - _bmp.width) / 2);
                  _bmp.y = int((34 - _bmp.height) / 2);
                  if(_slot is Sprite) (_slot as Sprite).addChild(_bmp);
                  else (_slot as MovieClip).addChild(_bmp);
               }
            }
            _si++;
         }
      }

      private function getEquipBmp(param1:String) : Bitmap
      {
         if(param1 == null || param1 == "") return null;
         var _idx:* = EquipData.get(param1, "iconIdx");
         if(_idx != null && _idx != "" && int(_idx) > 0)
         {
            return EquipIconsWuxia.getIcon(int(_idx));
         }
         return null;
      }

      private var _qualityColors:Array = [0x999999,0xCCCCCC,0x4bea13,0x16d2fa,0xe720f9,0xFFD700,0xFF6600,0xFF4444,0xFF0000];
      private var _qualityBgColors:Array = [0x333333,0x555555,0x1a3a0a,0x0a2a3a,0x2a0a2a,0x3a3000,0x3a1a00,0x3a0a0a,0x3a0000];
      private var _qualityNames:Array = ["","普通","精良","稀有","史诗","传说","神话","远古","至尊"];
      private function getQualityColor(param1:int):uint { return _qualityColors[param1] || 0xCCCCCC; }
      private function getQualityBgColor(param1:int):uint { return _qualityBgColors[param1] || 0x333333; }

      private function onEquipSlotClick(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         var _slotName:String = (param1.currentTarget as DisplayObject).name;
         var _slotIdx:int = int(_slotName.replace("equipSlot",""));
         if(_slotIdx < 0 || _slotIdx > 5) return;

         var _eqCode:String = this._armyInfo.getEquipSlot(_slotIdx);
         if(_eqCode != null && _eqCode != "" && _eqCode != "0")
         {
            this.unequipItem(_slotIdx);
         }
         else
         {
            this.showEquipBagList(_slotIdx);
         }
      }

      private function unequipItem(param1:int) : void
      {
         var _self:GeneralInfoPanel = this;
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
               _self._armyInfo.setEquipSlot(param1, "");
               _self._armyInfo.hp = _self._armyInfo.hp;
               if(param2.data.bagModel)
               {
                  RoleModel.getInstance().initBagModel(param2.data.bagModel);
               }
               if(param2.data.money != undefined) RoleModel.getInstance().money = int(param2.data.money);
               _self.flush();
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"装备已卸下,已放回背包。"}));
            }
            else
            {
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:param2.message||"卸下失败"}));
            }
         });
      }

      private function showEquipBagList(param1:int) : void
      {
         this.hideEquipBagList();
         this._selectingSlot = param1;
         var _items:Array = RoleModel.getInstance().getBagEquipItems(param1 + 1);
         if(_items.length == 0)
         {
            this.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"背包中没有可用的" + SLOT_LABELS[param1] + "类装备。"}));
            return;
         }

         // 装备选择面板 - 暗黑RPG风格
         var _cols:int = 3;
         var _cellW:int = 74, _cellH:int = 82;
         var _pad:int = 6;
         var _rows:int = int(Math.ceil(_items.length / _cols));
         var _listW:int = _cols * _cellW + _pad * 2;
         var _listH:int = Math.min(_rows, 3) * _cellH + _pad * 2 + 28;
         this._bagList.x = int((400 - _listW) / 2) - 20;
         this._bagList.y = 130;

         this._bagList.graphics.clear();
         // 外框阴影
         this._bagList.graphics.beginFill(0x000000, 0.5);
         this._bagList.graphics.drawRoundRect(2, 2, _listW, _listH, 8, 8);
         this._bagList.graphics.endFill();
         // 主背景
         this._bagList.graphics.beginFill(0x0d0804, 0.98);
         this._bagList.graphics.lineStyle(2, 0x8B6914, 0.85);
         this._bagList.graphics.drawRoundRect(0, 0, _listW, _listH, 8, 8);
         this._bagList.graphics.endFill();

         // 标题栏
         var _titleTF:TextField = new TextField();
         _titleTF.defaultTextFormat = new TextFormat("SimHei", 13, 0xFFD700, true);
         _titleTF.text = "选择" + SLOT_LABELS[param1];
         _titleTF.selectable = false;
         _titleTF.width = _listW; _titleTF.height = 20;
         _titleTF.x = 0; _titleTF.y = 5;
         this._bagList.addChild(_titleTF);

         var _self:GeneralInfoPanel = this;
         var _ii:int = 0;
         while(_ii < _items.length)
         {
            var _item:Object = _items[_ii];
            var _elr:int = int(EquipData.get(_item.code,"levelReq")) || 1;
            var _q:int = int(EquipData.get(_item.code,"quality"));
            var _col:int = _ii % _cols;
            var _row:int = int(_ii / _cols);

            var _cell:Sprite = new Sprite();
            _cell.x = _pad + _col * _cellW;
            _cell.y = _pad + 24 + _row * _cellH;
            _cell.buttonMode = (this._armyInfo.level >= _elr);
            _cell.name = _item.code;

            // 品质边框
            var _cbg:Shape = new Shape();
            _cbg.graphics.beginFill(getQualityBgColor(_q), 0.6);
            _cbg.graphics.lineStyle(1.5, getQualityColor(_q), 0.7);
            _cbg.graphics.drawRoundRect(0, 0, _cellW - 4, _cellH - 20, 4, 4);
            _cbg.graphics.endFill();
            _cell.addChild(_cbg);

            // 装备图标
            var _bmp2:Bitmap = this.getEquipBmp(_item.code);
            if(_bmp2 != null)
            {
               var _sc:Number = 42 / Math.max(_bmp2.width, _bmp2.height);
               _bmp2.scaleX = _sc; _bmp2.scaleY = _sc;
               _bmp2.smoothing = true;
               _bmp2.x = int((_cellW - 4 - _bmp2.width) / 2);
               _bmp2.y = 4;
               _cell.addChild(_bmp2);
            }

            // 装备名
            var _ntf:TextField = new TextField();
            _ntf.defaultTextFormat = new TextFormat("SimHei", 10, getQualityColor(_q));
            var _en:* = EquipData.get(_item.code,"name");
            _ntf.text = String(_en||"?");
            _ntf.selectable = false; _ntf.width = _cellW; _ntf.height = 16;
            _ntf.x = 0; _ntf.y = _cellH - 18;
            _cell.addChild(_ntf);

            if(this._armyInfo.level < _elr)
            {
               _cell.alpha = 0.35;
               _ntf.text += " Lv" + _elr;
            }

            _cell.addEventListener(MouseEvent.CLICK, function(p:*):void {
               if(_self._armyInfo.level < _elr) return;
               _self.equipItem(_self._selectingSlot, p.currentTarget.name);
            });
            this._bagList.addChild(_cell);
            _ii++;
         }
         this._bagList.visible = true;
      }

      private function hideEquipBagList() : void
      {
         this._bagList.visible = false;
         while(this._bagList.numChildren > 0) this._bagList.removeChildAt(0);
         this._selectingSlot = -1;
      }

      private function equipItem(param1:int, param2:String) : void
      {
         var _self:GeneralInfoPanel = this;
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
                  var _eqArr:Array = (param3.data.general.equipment || "").split(",");
                  var _eqCode:String = (_eqArr.length > param1 && _eqArr[param1] && _eqArr[param1] != "0") ? _eqArr[param1] : param2;
                  _self._armyInfo.setEquipSlot(param1, _eqCode);
               }
               else
               {
                  _self._armyInfo.setEquipSlot(param1, param2);
               }
               // 强制属性重算
               _self._armyInfo.hp = _self._armyInfo.hp;
               if(param3.data.bagModel)
               {
                  RoleModel.getInstance().initBagModel(param3.data.bagModel);
               }
               if(param3.data.money != undefined) RoleModel.getInstance().money = int(param3.data.money);
               _self.flush();
               var _en2:* = EquipData.get(param2,"name");
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"已装备 " + String(_en2||"")}));
            }
            else
            {
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:param3.message||"装备失败"}));
            }
         });
      }

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

      private function createGeneral(param1:String) : *
      {
         if(this._general != null)
         {
            removeChild(this._general);
            this._general = null;
         }
         var _loc2_:Class = ApplicationDomain.currentDomain.getDefinition(param1) as Class;
         this._general = new _loc2_() as MovieClip;
         this._general.mouseChildren = false;
         if(this._armyInfo.code == "general_5_19" || this._armyInfo.type == Type.JUNZHU)
         {
            this._general.scaleX = 0.52;
            this._general.scaleY = 0.52;
         }
         else if(this._general.evolution > 1)
         {
            this._general.scaleX = 0.65;
            this._general.scaleY = 0.65;
         }
         else
         {
            this._general.scaleX = 0.65;
            this._general.scaleY = 0.65;
         }
         this._general.x = this._point.x;
         this._general.y = this._point.y;
         addChild(this._general);
         var _loc3_:Shape = new Shape();
         _loc3_.graphics.beginFill(16764006);
         _loc3_.graphics.drawEllipse(-40,-12,80,24);
         _loc3_.filters = [new BlurFilter(20,12)];
         this._general.addChildAt(_loc3_,0);
      }

      private function createKezhi() : void
      {
         if(this._icon1 != null)
         {
            this._icon1.removeEventListener(MouseEvent.MOUSE_OVER,this.iconOverHandler);
            this._icon1.removeEventListener(MouseEvent.MOUSE_OUT,this.iconOutHandler);
            removeChild(this._icon1);
            this._icon1 = null;
         }
         if(this._icon2 != null)
         {
            this._icon2.removeEventListener(MouseEvent.MOUSE_OVER,this.iconOverHandler);
            this._icon2.removeEventListener(MouseEvent.MOUSE_OUT,this.iconOutHandler);
            removeChild(this._icon2);
            this._icon2 = null;
         }
         if(this._icon3 != null)
         {
            this._icon3.removeEventListener(MouseEvent.MOUSE_OVER,this.iconOverHandler);
            this._icon3.removeEventListener(MouseEvent.MOUSE_OUT,this.iconOutHandler);
            removeChild(this._icon3);
            this._icon3 = null;
         }
         if(this._armyInfo.type == Type.TOUSHICHE)
         {
            this.__kezhi1TF.text = "无克制";
            this.__kezhi2TF.text = "无克制";
            this.__kezhi3TF.text = "无克制";
            Tools.setDisabled(this.__kezhi1Btn,true);
            Tools.setDisabled(this.__kezhi2Btn,true);
            Tools.setDisabled(this.__kezhi3Btn,true);
            return;
         }
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition("kezhiIcon" + this._armyInfo.kezhi1) as Class;
         this._icon1 = new Sprite();
         this._icon1.addChild(new Bitmap(new _loc1_() as BitmapData));
         _loc1_ = ApplicationDomain.currentDomain.getDefinition("kezhiIcon" + this._armyInfo.kezhi2) as Class;
         this._icon2 = new Sprite();
         this._icon2.addChild(new Bitmap(new _loc1_() as BitmapData));
         _loc1_ = ApplicationDomain.currentDomain.getDefinition("kezhiIcon" + this._armyInfo.kezhi3) as Class;
         this._icon3 = new Sprite();
         this._icon3.addChild(new Bitmap(new _loc1_() as BitmapData));
         this._icon1.x = this._pos1.x;
         this._icon1.y = this._pos1.y;
         this._icon2.x = this._pos2.x;
         this._icon2.y = this._pos2.y;
         this._icon3.x = this._pos3.x;
         this._icon3.y = this._pos3.y;
         addChild(this._icon1);
         addChild(this._icon2);
         addChild(this._icon3);
         this._icon1.addEventListener(MouseEvent.MOUSE_OVER,this.iconOverHandler);
         this._icon2.addEventListener(MouseEvent.MOUSE_OVER,this.iconOverHandler);
         this._icon3.addEventListener(MouseEvent.MOUSE_OVER,this.iconOverHandler);
         this._icon1.addEventListener(MouseEvent.MOUSE_OUT,this.iconOutHandler);
         this._icon2.addEventListener(MouseEvent.MOUSE_OUT,this.iconOutHandler);
         this._icon3.addEventListener(MouseEvent.MOUSE_OUT,this.iconOutHandler);
         this.__kezhi1TF.text = Type.createKezhiStr(this._armyInfo.kezhi1) + this._armyInfo.kezhiLevel1.toString() + "级";
         this.__kezhi2TF.text = Type.createKezhiStr(this._armyInfo.kezhi2) + this._armyInfo.kezhiLevel2.toString() + "级";
         this.__kezhi3TF.text = Type.createKezhiStr(this._armyInfo.kezhi3) + this._armyInfo.kezhiLevel3.toString() + "级";
         if(this._armyInfo.kezhiLevel1 > 9)
         {
            Tools.setDisabled(this.__kezhi1Btn,true);
         }
         else
         {
            Tools.setDisabled(this.__kezhi1Btn,false);
         }
         if(this._armyInfo.kezhiLevel2 > 9)
         {
            Tools.setDisabled(this.__kezhi2Btn,true);
         }
         else
         {
            Tools.setDisabled(this.__kezhi2Btn,false);
         }
         if(this._armyInfo.kezhiLevel3 > 9)
         {
            Tools.setDisabled(this.__kezhi3Btn,true);
         }
         else
         {
            Tools.setDisabled(this.__kezhi3Btn,false);
         }
      }

      private function iconOverHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         var _loc2_:String = "";
         if(param1.currentTarget == this._icon1)
         {
            _loc2_ += Type.createKezhiStr(this._armyInfo.kezhi1) + "\n";
            _loc2_ += "攻击与防御额外提升" + Logic.kezhiBilv[this._armyInfo.kezhiLevel1] + "%";
         }
         else if(param1.currentTarget == this._icon2)
         {
            _loc2_ += Type.createKezhiStr(this._armyInfo.kezhi2) + "\n";
            _loc2_ += "攻击与防御额外提升" + Logic.kezhiBilv[this._armyInfo.kezhiLevel2] + "%";
         }
         else if(param1.currentTarget == this._icon3)
         {
            _loc2_ += Type.createKezhiStr(this._armyInfo.kezhi3) + "\n";
            _loc2_ += "攻击与防御额外提升" + Logic.kezhiBilv[this._armyInfo.kezhiLevel3] + "%";
         }
         dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
            "htmlText":_loc2_,
            "type":3,
            "width":150,
            "height":45
         }));
      }

      private function iconOutHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
      }

      private function createTianfu() : void
      {
         if(this._armyInfo.type == Type.TOUSHICHE)
         {
            this.__tianfuNameTF.text = "无";
            this.__tianfuDescTF.text = "投石车无天赋属性，其他类型武将可以免费激活武将天赋。";
            this.__chongxiBtn.visible = false;
            this.__jihuoBtn.visible = false;
         }
         else if(this._armyInfo.tianfu == null)
         {
            this.__tianfuNameTF.text = "点击激活按钮，免费激活武将天赋";
            this.__tianfuDescTF.text = "天赋激活后，如果对武将天赋属性不满意可以使用点卡重洗天赋。";
            this.__chongxiBtn.visible = false;
            this.__jihuoBtn.visible = true;
         }
         else
         {
            this.__tianfuNameTF.text = Data.getInstance().getAttributes("tianfu",this._armyInfo.tianfu,"name");
            this.__tianfuDescTF.text = Data.getInstance().getAttributes("tianfu",this._armyInfo.tianfu,"desc");
            this.__chongxiBtn.visible = true;
            this.__jihuoBtn.visible = false;
         }
      }

      private function createValueTF() : void
      {
         var _loc1_:* = "";
         _loc1_ += Type.createType(this._armyInfo.type) + "\n";
         _loc1_ += this._armyInfo.attack;
         if(this._armyInfo.equipAttackBonus > 0) _loc1_ += "<font color='#FFD700'>(+" + this._armyInfo.equipAttackFlat + (this._armyInfo.equipAttackPct>0?"+"+this._armyInfo.equipAttackPct+"%":"") + ")</font>";
         _loc1_ += "\n";
         _loc1_ += this._armyInfo.defense;
         if(this._armyInfo.equipDefenseBonus > 0) _loc1_ += "<font color='#FFD700'>(+" + this._armyInfo.equipDefenseFlat + (this._armyInfo.equipDefensePct>0?"+"+this._armyInfo.equipDefensePct+"%":"") + ")</font>";
         _loc1_ += "\n";
         _loc1_ += this._armyInfo.hp;
         if(this._armyInfo.equipHPBonus > 0) _loc1_ += "<font color='#FFD700'>(+" + this._armyInfo.equipHPFlat + (this._armyInfo.equipHPPct>0?"+"+this._armyInfo.equipHPPct+"%":"") + ")</font>";
         _loc1_ += "\n";
         _loc1_ += this._armyInfo.attackDistance + "\n";
         if(this._armyInfo.evolution == 0)
         {
            if(this._armyInfo.level < 30)
            {
               _loc1_ += "    无 <font color=\'#4bea13\'>(30级后可以进化)</font>\n";
            }
            else
            {
               _loc1_ += "    无 <font color=\'#4bea13\'>(进化后获得加成)</font>\n";
            }
            Tools.setDisabled(this.__sxcxBtn,true);
         }
         else
         {
            _loc1_ += "    " + this._armyInfo.evolution + "级 <font color=\'#4bea13\'>全属性增加" + this._armyInfo.getAddtion() * 100 + "%</font>\n";
            Tools.setDisabled(this.__sxcxBtn,false);
         }
         if(this._armyInfo.feature == 0)
         {
            if(this._armyInfo.type == Type.TOUSHICHE)
            {
               _loc1_ += "    无\n";
            }
            else
            {
               _loc1_ += "    无 <font color=\'#4bea13\'>(进化后获得属相)</font>\n";
            }
         }
         else if(this._armyInfo.feature == 1)
         {
            if(this._armyInfo.type == Type.TOUSHICHE)
            {
               _loc1_ += "    无\n";
            }
            else
            {
               _loc1_ += "    <font color=\'#16d2fa\'>冰</font>";
               _loc1_ += " <font color=\'#f45415\'>克制火，被雷克制</font>\n";
            }
         }
         else if(this._armyInfo.feature == 2)
         {
            _loc1_ += "    <font color=\'#ff3333\'>火</font>";
            _loc1_ += " <font color=\'#f45415\'>克制风，被冰克制</font>\n";
         }
         else if(this._armyInfo.feature == 3)
         {
            _loc1_ += "    <font color=\'#4bea13\'>风</font>";
            _loc1_ += " <font color=\'#f45415\'>克制雷，被火克制</font>\n";
         }
         else if(this._armyInfo.feature == 4)
         {
            _loc1_ += "    <font color=\'#e720f9\'>雷</font>";
            _loc1_ += " <font color=\'#f45415\'>克制冰，被风克制</font>\n";
         }
         // 装备特殊属性
         if(this._armyInfo.equipLifesteal > 0 || this._armyInfo.equipDmgBonus > 0 || this._armyInfo.equipDmgReduce > 0 || this._armyInfo.equipCritRate > 0)
         {
            _loc1_ += "<font color='#FF6600'>";
            if(this._armyInfo.equipLifesteal > 0) _loc1_ += " 吸血+" + this._armyInfo.equipLifesteal + "%";
            if(this._armyInfo.equipDmgBonus > 0) _loc1_ += " 增伤+" + this._armyInfo.equipDmgBonus + "%";
            if(this._armyInfo.equipDmgReduce > 0) _loc1_ += " 减伤+" + this._armyInfo.equipDmgReduce + "%";
            if(this._armyInfo.equipCritRate > 0) _loc1_ += " 暴击+" + this._armyInfo.equipCritRate + "%";
            if(this._armyInfo.equipCritDmg > 0) _loc1_ += " 暴伤+" + this._armyInfo.equipCritDmg + "%";
            _loc1_ += "</font>\n";
         }
         this.__valueTF.htmlText = _loc1_;
      }

      private function createXiaohaoTF() : void
      {
         this.__xiaohaoTF.text = "需要功勋 " + Logic.getExploitByLevel(this._armyInfo.level) + "\n需要银子 " + Logic.getMoneyByLevel(this._armyInfo.level);
      }

      private function onRoleModelChange(param1:Event) : void
      {
         if(this.__moneyTF) this.__moneyTF.text = RoleModel.getInstance().money.toString();
         if(this.__exploitTF) this.__exploitTF.text = RoleModel.getInstance().exploit.toString();
      }

      private function shengjiBtnClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         param1.stopImmediatePropagation();
         if(this._armyInfo.level < 200)
         {
            _loc2_ = Logic.getMoneyByLevel(this._armyInfo.level);
            _loc3_ = Logic.getExploitByLevel(this._armyInfo.level);
            if(RoleModel.getInstance().money >= _loc2_ && RoleModel.getInstance().exploit >= _loc3_)
            {
               this.sendToHttpNew(Head.HTTP_NEW_GENERAL_SHENGJI);
            }
            else
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"所需功勋或银子不足，无法提升等级。"
               }));
            }
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"武将更高等级尚未开放，请关注官方最新消息。"
            }));
         }
      }

      private function jinhuaBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._armyInfo.evolution >= 10)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"武将更高进化等级尚未开放，请关注官方消息"
            }));
         }
         else if(this._armyInfo.level >= 30)
         {
            dispatchEvent(new UIEvent(UIEvent.JINHUA_CLICK,true,this._armyInfo));
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"武将等级不满足进化要求，30级以后才能进化。\n提示：武将进化后可获得全属性加成，并随机获得攻击属相。"
            }));
         }
      }

      private function kezhi1BtnClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:* = null;
         param1.stopImmediatePropagation();
         if(RoleModel.getInstance().getBagItemCount("proto_3_4") < 1)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"您没有克制进阶符，无法升级。克制进阶符在副本中抽取，也可以在商城中购买。"
            }));
         }
         else if(RoleModel.getInstance().money < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有足够的银子，进阶克制属性需要消耗1000银子。"
            }));
         }
         else if(RoleModel.getInstance().exploit < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有足够的功勋，进阶克制属性需要消耗1000功勋。"
            }));
         }
         else if(this._armyInfo.kezhiLevel1 > 9)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"克制等级最高为10级。"
            }));
         }
         else
         {
            _loc2_ = Type.createKezhiStr(this._armyInfo.kezhi1) + "进阶至" + (this._armyInfo.kezhiLevel1 + 1) + "级，对战";
            _loc2_ += Type.createType(this._armyInfo.kezhi1);
            _loc2_ += "时攻击和防御提升" + Logic.kezhiBilv[this._armyInfo.kezhiLevel1 + 1];
            _loc2_ += "%\n";
            _loc2_ += "进阶成功率：" + Logic.getKezhiJilv(this._armyInfo.kezhiLevel1) * 100 + "%\n";
            _loc2_ += "进阶消耗：克制进阶符1个、 功勋1000、银子1000";
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":1,
               "text":_loc2_,
               "fun":this.jinjie1
            }));
         }
      }

      private function jinjie1() : *
      {
         this.sendToHttpNew(Head.HTTP_NEW_GENERAL_KEZHI_SHENGJI,0);
      }

      private function kezhi2BtnClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:* = null;
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.SHUANGKAI_POST,true));
         if(RoleModel.getInstance().getBagItemCount("proto_3_4") < 1)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"您没有克制进阶符，无法升级。克制进阶符在副本中抽取，也可以在商城中购买。"
            }));
         }
         else if(RoleModel.getInstance().money < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有足够的银子，进阶克制属性需要消耗1000银子。"
            }));
         }
         else if(RoleModel.getInstance().exploit < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有足够的功勋，进阶克制属性需要消耗1000功勋。"
            }));
         }
         else if(this._armyInfo.kezhiLevel2 > 9)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"克制等级最高为10级。"
            }));
         }
         else
         {
            _loc2_ = Type.createKezhiStr(this._armyInfo.kezhi2) + "进阶至" + (this._armyInfo.kezhiLevel2 + 1) + "级，对战";
            _loc2_ += Type.createType(this._armyInfo.kezhi2);
            _loc2_ += "时攻击和防御提升" + Logic.kezhiBilv[this._armyInfo.kezhiLevel2 + 1];
            _loc2_ += "%\n";
            _loc2_ += "进阶成功率：" + Logic.getKezhiJilv(this._armyInfo.kezhiLevel2) * 100 + "%\n";
            _loc2_ += "进阶消耗：克制进阶符1个、 功勋1000、银子1000";
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":1,
               "text":_loc2_,
               "fun":this.jinjie2
            }));
         }
      }

      private function jinjie2() : *
      {
         this.sendToHttpNew(Head.HTTP_NEW_GENERAL_KEZHI_SHENGJI,1);
      }

      private function kezhi3BtnClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:* = null;
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.SHUANGKAI_POST,true));
         if(RoleModel.getInstance().getBagItemCount("proto_3_4") < 1)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"您没有克制进阶符，无法升级。克制进阶符在副本中抽取，也可以在商城中购买。"
            }));
         }
         else if(RoleModel.getInstance().money < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有足够的银子，进阶克制属性需要消耗1000银子。"
            }));
         }
         else if(RoleModel.getInstance().exploit < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有足够的功勋，进阶克制属性需要消耗1000功勋。"
            }));
         }
         else if(this._armyInfo.kezhiLevel3 > 9)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"克制等级最高为10级。"
            }));
         }
         else
         {
            _loc2_ = Type.createKezhiStr(this._armyInfo.kezhi3) + "进阶至" + (this._armyInfo.kezhiLevel3 + 1) + "级，对战";
            _loc2_ += Type.createType(this._armyInfo.kezhi3);
            _loc2_ += "时攻击和防御提升" + Logic.kezhiBilv[this._armyInfo.kezhiLevel3 + 1];
            _loc2_ += "%\n";
            _loc2_ += "进阶成功率：" + Logic.getKezhiJilv(this._armyInfo.kezhiLevel3) * 100 + "%\n";
            _loc2_ += "进阶消耗：克制进阶符1个、 功勋1000、银子1000";
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":1,
               "text":_loc2_,
               "fun":this.jinjie3
            }));
         }
      }

      private function jinjie3() : *
      {
         this.sendToHttpNew(Head.HTTP_NEW_GENERAL_KEZHI_SHENGJI,2);
      }

      private function chongxiBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
            "type":1,
            "text":"重洗武将天赋需要花费100点卡，是否确认使用？",
            "fun":this.realyChongxi
         }));
      }

      private function realyChongxi() : *
      {
         if(RoleModel.getInstance().dianka < 100)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"点卡不足，无法重洗武将天赋。"
            }));
         }
         else
         {
            this.sendToHttpNew(Head.HTTP_NEW_GENERAL_TIANFU);
         }
      }

      private function jihuoBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.sendToHttpNew(Head.HTTP_NEW_GENERAL_TIANFU);
      }

      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }

      private function onShopBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_SHOP,true));
      }

      private function sendToHttpNew(param1:int, param2:int = 1) : *
      {
         var _loc3_:Object = {};
         _loc3_.head = param1;
         _loc3_.agent = Config.AGENT;
         _loc3_.ver = Config.VER;
         _loc3_.token = Config.token;
         _loc3_.roleID = RoleModel.getInstance().roleID;
         _loc3_.userID = RoleModel.getInstance().userID;
         _loc3_.id = this._armyInfo.id;
         _loc3_.mask = true;
         switch(param1)
         {
            case Head.HTTP_NEW_GENERAL_SHENGJI:
               AESController.getInstance().sendJSON(_loc3_,this.shengjiResponse);
               break;
            case Head.HTTP_NEW_GENERAL_KEZHI_SHENGJI:
               _loc3_.index = param2;
               AESController.getInstance().sendJSON(_loc3_,this.kezhiResponse);
               break;
            case Head.HTTP_NEW_GENERAL_TIANFU:
               AESController.getInstance().sendJSON(_loc3_,this.tianfuResponse);
               break;
            case Head.HTTP_NEW_SHUXINGCHONGXI:
               AESController.getInstance().sendJSON(_loc3_,this.sxcxResponse);
         }
      }

      private function shengjiResponse(param1:Object) : *
      {
         var _loc2_:String = null;
         if(param1.success == true)
         {
            RoleModel.getInstance().money = param1.data.money;
            RoleModel.getInstance().exploit = param1.data.exploit;
            this._armyInfo.setLevel(param1.data.level);
            RoleModel.getInstance().throttleSave();
            this.flush();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }

      private function kezhiResponse(param1:Object) : *
      {
         var _loc2_:String = null;
         if(param1.success == true)
         {
            RoleModel.getInstance().money = param1.data.money + 100;
            RoleModel.getInstance().exploit = param1.data.exploit + 100;
            RoleModel.getInstance().delBagItemByID(param1.data.itemID);
            if(param1.data.general != null)
            {
               this._armyInfo.setKezhiStr(param1.data.general.kezhi);
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"克制属性进阶成功。"
               }));
               if(param1.data.index == 0)
               {
                  _loc2_ = TextFactory.makeKezhiJinjie(RoleModel.getInstance().roleName,this._armyInfo.name,Type.createType(this._armyInfo.kezhi1),this._armyInfo.kezhiLevel1.toString());
                  dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                     "type":NetInfoType.SYSTEM,
                     "text":_loc2_
                  }));
               }
               else if(param1.data.index == 1)
               {
                  _loc2_ = TextFactory.makeKezhiJinjie(RoleModel.getInstance().roleName,this._armyInfo.name,Type.createType(this._armyInfo.kezhi2),this._armyInfo.kezhiLevel2.toString());
                  dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                     "type":NetInfoType.SYSTEM,
                     "text":_loc2_
                  }));
               }
               else if(param1.data.index == 2)
               {
                  _loc2_ = TextFactory.makeKezhiJinjie(RoleModel.getInstance().roleName,this._armyInfo.name,Type.createType(this._armyInfo.kezhi3),this._armyInfo.kezhiLevel3.toString());
                  dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                     "type":NetInfoType.SYSTEM,
                     "text":_loc2_
                  }));
               }
               RoleModel.getInstance().throttleSave();
            }
            else
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"克制属性进阶失败。"
               }));
            }
            this.flush();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }

      private function tianfuResponse(param1:Object) : *
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         if(param1.success == true)
         {
            if(RoleModel.getInstance().dianka == int(param1.data.dianka))
            {
               this._armyInfo.tianfu = param1.data.general.genius;
               this.flush();
               this.__jihuoBtn.visible = false;
               this.__chongxiBtn.visible = true;
            }
            else
            {
               RoleModel.getInstance().dianka = param1.data.dianka;
               this._armyInfo.tianfu = param1.data.general.genius;
               this.flush();
               _loc2_ = int(Data.getInstance().getAttributes("tianfu",this._armyInfo.tianfu,"level"));
               if(_loc2_ == 3)
               {
                  _loc3_ = TextFactory.makeTianfu(RoleModel.getInstance().roleName,this._armyInfo);
                  dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                     "type":NetInfoType.SYSTEM,
                     "text":_loc3_
                  }));
               }
            }
            RoleModel.getInstance().throttleSave();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }

      private function onSxcxBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._armyInfo.feature > 0)
         {
            if(RoleModel.getInstance().dianka < 100)
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"点卡不足，无法重洗武将属相。"
               }));
            }
            else
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":1,
                  "text":"重洗武将属相需要花费100点卡，是否确认使用？",
                  "fun":this.realSxcxFun
               }));
            }
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"此武将尚未进化，无法重洗属性。"
            }));
         }
      }

      private function realSxcxFun() : *
      {
         this.sendToHttpNew(Head.HTTP_NEW_SHUXINGCHONGXI);
      }

      private function sxcxResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            RoleModel.getInstance().dianka = param1.data.dianka;
            this._armyInfo.feature = param1.data.feature;
            this.flush();
            RoleModel.getInstance().throttleSave();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
   }
}
