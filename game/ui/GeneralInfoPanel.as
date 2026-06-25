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
   import flash.display.GradientType;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
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

      private var __specTF:TextField;

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
      private var _slotHoverFns:Dictionary = new Dictionary();

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
         this.__valueTF.multiline = true;
         this.__valueTF.wordWrap = true;
         this.__valueTF.height = 260;
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
            {x:-160, y:-206},  // 0:武器   (右,上)
            {x:-329, y:-146},  // 1:铠甲   (左,中)
            {x:-160, y:-146},  // 2:饰品Ⅰ (右,中)
            {x:-329, y:-206},  // 3:头盔   (左,上)
            {x:-329, y:-87},   // 4:战靴   (左,下)
            {x:-160, y:-87}    // 5:饰品Ⅱ (右,下)
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
         // 修复升级按钮点击区域：SWF的hitTestState仅左下角有效。
         // 延迟到ADDED_TO_STAGE后创建覆盖层，确保_skin布局完成、getBounds准确。
         var _self4:GeneralInfoPanel = this;
         this.addEventListener(Event.ADDED_TO_STAGE, function _onStage(p:Event):void {
            _self4.removeEventListener(Event.ADDED_TO_STAGE, _onStage);
            var _ov:Sprite = new Sprite();
            _ov.name = "_shengjiOverlay";
            // getBounds(_skin)=按钮在_skin坐标系中的真实位置(不能用btn.x/y,那是相对直接父节点的)
            var _br2:Rectangle = _self4.__shengjiBtn.getBounds(_self4._skin);
            _ov.x = _br2.x;
            _ov.y = _br2.y;
            _ov.graphics.beginFill(0xFF0000, 0.01);
            _ov.graphics.drawRect(-4, -4, _br2.width + 8, _br2.height + 8);
            _ov.graphics.endFill();
            _ov.buttonMode = true;
            _ov.addEventListener(MouseEvent.CLICK, function(pe:MouseEvent):void {
               pe.stopImmediatePropagation();
               _self4.shengjiBtnClickHandler(pe);
            });
            _self4._skin.addChild(_ov);
         });
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
         var _self:GeneralInfoPanel = this;
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

            // 先移除旧的悬停监听+隐藏可能粘住的tooltip(必须在if之前,空槽也要清)
            if(_self._slotHoverFns[_slot] != null) {
               var _oldFns:Array = _self._slotHoverFns[_slot] as Array;
               _slot.removeEventListener(MouseEvent.MOUSE_OVER, _oldFns[0] as Function);
               _slot.removeEventListener(MouseEvent.MOUSE_OUT, _oldFns[1] as Function);
               delete _self._slotHoverFns[_slot];
            }
            _self.dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));

            if(_eqCode != null && _eqCode != "" && _eqCode != "0")
            {
               var _q:int = int(EquipData.get(_eqCode,"quality"));
               var _qc:uint = getQualityBgColor(_q);

               // 品质边框(彩色Q10用彩虹渐变)
               var _bg:Shape = new Shape();
               if(_q == 10) {
                  drawRainbowBorder(_bg, 34, 34, 0.95);
                  _bg.filters = [new GlowFilter(0xFFFFCC, 0.7, 8, 8, 2, 1)];
               } else {
                  // 高级感边框: 品质色细边+暗底+微光
                  var _qc2:uint = getQualityColor(_q);
                  _bg.graphics.beginFill(0x0d0804, 0.90);
                  _bg.graphics.lineStyle(0.8, _qc2, 0.6);
                  _bg.graphics.drawRoundRect(0, 0, 34, 34, 4, 4);
                  _bg.graphics.endFill();
                  _bg.filters = [new GlowFilter(_qc2, 0.15, 3, 3, 1, 1)];
               }
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

               // 悬停显示装备属性+品质
               var _qName:String = getQualityName(_q);
               (function(_ec:String, _qn:String, _qcStr:String):void {
                  var _hoverFn:Function = function(p:*):void {
                     var _n:* = EquipData.get(_ec,"name"); var _a:int=int(EquipData.get(_ec,"attack"))||0;
                     var _ap:int=int(EquipData.get(_ec,"attackPct"))||0; var _d:int=int(EquipData.get(_ec,"defense"))||0;
                     var _dp:int=int(EquipData.get(_ec,"defensePct"))||0; var _h:int=int(EquipData.get(_ec,"hp"))||0;
                     var _hp:int=int(EquipData.get(_ec,"hpPct"))||0; var _ls:int=int(EquipData.get(_ec,"lifesteal"))||0;
                     var _db:int=int(EquipData.get(_ec,"dmgBonus"))||0; var _dr:int=int(EquipData.get(_ec,"dmgReduce"))||0;
                     var _cr:int=int(EquipData.get(_ec,"critRate"))||0; var _cd:int=int(EquipData.get(_ec,"critDmg"))||0;
                     var _t:String = "<font color='"+_qcStr+"'><b>"+_n+"</b> ["+_qn+"]</font>\n";
                     if(_a||_ap) _t+="攻击:"+(_a>0?"+"+_a:_a)+(_ap>0?"+"+_ap+"%":"")+"\n";
                     if(_d||_dp) _t+="防御:"+(_d>0?"+"+_d:_d)+(_dp>0?"+"+_dp+"%":"")+"\n";
                     if(_h||_hp) _t+="气血:"+(_h>0?"+"+_h:_h)+(_hp>0?"+"+_hp+"%":"")+"\n";
                     if(_ls>0) _t+="吸血:"+_ls+"%\n"; if(_db>0) _t+="增伤:"+_db+"%\n";
                     if(_dr>0) _t+="减伤:"+_dr+"%\n"; if(_cr>0) _t+="暴击:"+_cr+"%\n";
                     if(_cd>0) _t+="暴伤:"+_cd+"%\n";
                     _self.dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{htmlText:_t,type:3,width:140,height:130}));
                  };
                  var _outFn:Function = function(p:*):void { _self.dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true)); };
                  _self._slotHoverFns[_slot] = [_hoverFn, _outFn];
                  _slot.addEventListener(MouseEvent.MOUSE_OVER, _hoverFn);
                  _slot.addEventListener(MouseEvent.MOUSE_OUT, _outFn);
               })(_eqCode, _qName, "#" + getQualityColor(_q).toString(16));
            }
            _si++;
         }

         // 确保装备槽始终在最顶层，不被后续flush()添加的元素遮挡点击
         var _ti:int = 0;
         while(_ti < 6)
         {
            var _ts:DisplayObject = this._equipSlots[_ti] as DisplayObject;
            if(_ts != null && contains(_ts))
            {
               setChildIndex(_ts, numChildren - 1);
            }
            _ti++;
         }
         if(this._bagList != null && contains(this._bagList))
         {
            setChildIndex(this._bagList, numChildren - 1);
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

      // 品质6档: 白(Q1-2) 绿(Q3-4) 紫(Q5-6) 橙(Q7-8) 红(Q9) 彩(Q10)
      private var _qualityColors:Array = [0x999999,0xCCCCCC,0xCCCCCC,0x4bea13,0x4bea13,0xe720f9,0xe720f9,0xFF8C00,0xFF8C00,0xFF0000,0xFF66FF];
      private var _qualityBgColors:Array = [0x1a1a1a,0x2a2a2a,0x2a2a2a,0x0d1d05,0x0d1d05,0x150515,0x150515,0x1d0d00,0x1d0d00,0x1d0000,0x0d0d0d];
      private var _qualityNames:Array = ["","白色","白色","绿色","绿色","紫色","紫色","橙色","橙色","红色","彩色"];
      private function getQualityColor(param1:int):uint { return _qualityColors[param1] || 0xCCCCCC; }
      private function getQualityBgColor(param1:int):uint { return _qualityBgColors[param1] || 0x333333; }
      private function getQualityName(param1:int):String { return _qualityNames[param1] || "普通"; }

      // 彩色(Q10)高级炫彩边框 — 白金色系+微光
      private static const RAINBOW_COLORS:Array = [0xFFD700,0xFFAA44,0xFFFFFF,0x44FFAA,0x44AAFF,0xFF88CC,0xFFD700];
      private static function drawRainbowBorder(shape:Shape, w:Number, h:Number, borderW:Number=2.5):void {
         var _m:Matrix = new Matrix();
         _m.createGradientBox(w, h, Math.PI/4, 0, 0);
         shape.graphics.beginGradientFill(GradientType.LINEAR, RAINBOW_COLORS, [0.7,0.5,0.95,0.5,0.5,0.5,0.7], [0,43,85,128,170,213,255], _m);
         shape.graphics.drawRoundRect(0, 0, w, h, 4, 4);
         shape.graphics.endFill();
         shape.graphics.beginFill(0x0d0804, 1);
         shape.graphics.drawRoundRect(borderW, borderW, w-borderW*2, h-borderW*2, 3, 3);
         shape.graphics.endFill();
      }

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
               _self._armyInfo.hp = _self._armyInfo.maxHp;
               if(param2.data.bagModel)
               {
                  RoleModel.getInstance().initBagModel(param2.data.bagModel);
               }
               if(param2.data.money != undefined) RoleModel.getInstance().money = int(param2.data.money);
               _self.flush();
               if(_self._bagList.visible) _self.showEquipBagList(_self._selectingSlot);
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"装备已卸下,已放回背包。"}));
            }
            else
            {
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:param2.message||"卸下失败"}));
            }
         });
      }

      private var _equipListPage:int = 0;
      private var _equipListItems:Array = null;

      private function showEquipBagList(param1:int) : void
      {
         this.hideEquipBagList();
         this._selectingSlot = param1;
         var _allItems:Array = RoleModel.getInstance().getBagEquipItems(param1 + 1);
         if(_allItems.length == 0)
         {
            this.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"背包中没有可用的" + SLOT_LABELS[param1] + "类装备。"}));
            return;
         }
         this._equipListItems = _allItems;
         this._equipListPage = 0;
         this.renderEquipList();
      }

      private function renderEquipList() : void
      {
         var _items:Array = this._equipListItems; if(!_items) return;
         while(this._bagList.numChildren > 0) this._bagList.removeChildAt(0);
         this._bagList.graphics.clear();
         var _pageSize:int = 15; var _cols:int = 5;
         var _totalPages:int = int(Math.ceil(_items.length / _pageSize));
         if(_totalPages<1) _totalPages=1;
         if(this._equipListPage>=_totalPages) this._equipListPage=_totalPages-1;
         if(this._equipListPage<0) this._equipListPage=0;

         var _start:int = this._equipListPage * _pageSize;
         var _end:int = Math.min(_start + _pageSize, _items.length);
         var _pageItems:Array = _items.slice(_start, _end);
         var _rows:int = int(Math.ceil(_pageItems.length / _cols));

         var _cellW:int = 56, _cellH:int = 56, _pad:int = 5;
         var _listW:int = _cols * _cellW + _pad * 2;
         var _headerH:int = 26, _footerH:int = 28;
         var _listH:int = _rows * _cellH + _pad * 2 + _headerH + _footerH;

         // 居中
         this._bagList.x = int((400 - _listW) / 2) - 20;
         this._bagList.y = int((300 - _listH) / 2) - 30;

         this._bagList.graphics.clear();
         this._bagList.graphics.beginFill(0x000000, 0.5);
         this._bagList.graphics.drawRoundRect(2,2,_listW,_listH,8,8);
         this._bagList.graphics.endFill();
         this._bagList.graphics.beginFill(0x0d0804,0.98);
         this._bagList.graphics.lineStyle(2,0x8B6914,0.85);
         this._bagList.graphics.drawRoundRect(0,0,_listW,_listH,8,8);
         this._bagList.graphics.endFill();

         // 标题
         var _ttf:TextField = new TextField();
         _ttf.defaultTextFormat = new TextFormat("SimHei",12,0xFFD700,true);
         _ttf.text = "选择" + SLOT_LABELS[this._selectingSlot] + " (" + _items.length + "件)";
         _ttf.selectable = false; _ttf.width = _listW - 40; _ttf.height = 18;
         _ttf.x = 8; _ttf.y = 5;
         this._bagList.addChild(_ttf);

         // 关闭按钮
         var _close:TextField = new TextField();
         _close.defaultTextFormat = new TextFormat("SimHei",14,0xCC4444,true);
         _close.text = "✕"; _close.selectable = false;
         _close.width = 22; _close.height = 20; _close.x = _listW - 26; _close.y = 3;
         var _self:GeneralInfoPanel = this;
         _close.addEventListener(MouseEvent.CLICK, function(p:*):void { _self.hideEquipBagList(); });
         this._bagList.addChild(_close);

         var _contentY:int = _headerH;

         var _ci:int = 0;
         while(_ci < _pageItems.length)
         {
            var _item:Object = _pageItems[_ci];
            var _elr:int = int(EquipData.get(_item.code,"levelReq"))||1;
            var _q:int = int(EquipData.get(_item.code,"quality"));
            var _col:int = _ci % _cols; var _row:int = int(_ci / _cols);

            var _cell:Sprite = new Sprite();
            _cell.x = _pad + _col * _cellW; _cell.y = _contentY + _row * _cellH;
            _cell.buttonMode = true;
            _cell.name = _item.code;

            // 品质边框(Q10彩色用彩虹渐变)
            var _cbg:Shape = new Shape();
            if(_q == 10) {
               drawRainbowBorder(_cbg, _cellW-1, _cellH-1, 0.65);
               _cbg.x = 1; _cbg.y = 1;
               _cbg.filters = [new GlowFilter(0xFFFFCC, 0.5, 6, 6, 2, 1)];
            } else {
               var _qc3:uint = getQualityColor(_q);
               _cbg.graphics.beginFill(0x0d0804, 0.85);
               _cbg.graphics.lineStyle(1, _qc3, 0.55);
               _cbg.graphics.drawRoundRect(1,1,_cellW-2,_cellH-2,3,3);
               _cbg.graphics.endFill();
            }
            _cell.addChild(_cbg);

            // 图标(缩小)
            var _bmp:Bitmap = this.getEquipBmp(_item.code);
            if(_bmp != null)
            {
               var _sc:Number = 32 / Math.max(_bmp.width,_bmp.height);
               _bmp.scaleX = _sc; _bmp.scaleY = _sc;
               _bmp.smoothing = true;
               _bmp.x = int((_cellW - _bmp.width)/2);
               _bmp.y = int((_cellH - _bmp.height)/2);
               _cell.addChild(_bmp);
            }

            // 悬停提示
            _cell.addEventListener(MouseEvent.MOUSE_OVER, function(p:*):void {
               var _c:String = p.currentTarget.name;
               var _n:* = EquipData.get(_c,"name");
               var _a:* = EquipData.get(_c,"attack")||0;
               var _ap:* = EquipData.get(_c,"attackPct")||0;
               var _d:* = EquipData.get(_c,"defense")||0;
               var _dp:* = EquipData.get(_c,"defensePct")||0;
               var _h:* = EquipData.get(_c,"hp")||0;
               var _hp:* = EquipData.get(_c,"hpPct")||0;
               var _ls:* = EquipData.get(_c,"lifesteal")||0;
               var _db:* = EquipData.get(_c,"dmgBonus")||0;
               var _dr:* = EquipData.get(_c,"dmgReduce")||0;
               var _cr:* = EquipData.get(_c,"critRate")||0;
               var _cd:* = EquipData.get(_c,"critDmg")||0;
               var _ql:int = int(EquipData.get(_c,"quality"))||1;
               var _lv:int = int(EquipData.get(_c,"levelReq"))||1;
               var _qlColor:uint = _self.getQualityColor(_ql);
               var _qlHex:String = "#" + _qlColor.toString(16);
               var _t:String = "<font color='" + _qlHex + "'><b>" + _n + "</b> [" + _self.getQualityName(_ql) + "]</font> <font color='#888'>Lv" + _lv + "</font>\n";
               if(int(_a)!=0||int(_ap)!=0) _t+="攻击:"+_a+(int(_ap)>0?"+"+_ap+"%":"")+"\n";
               if(int(_d)!=0||int(_dp)!=0) _t+="防御:"+_d+(int(_dp)>0?"+"+_dp+"%":"")+"\n";
               if(int(_h)!=0||int(_hp)!=0) _t+="气血:"+_h+(int(_hp)>0?"+"+_hp+"%":"")+"\n";
               if(int(_ls)>0) _t+="吸血:"+_ls+"%\n";
               if(int(_db)>0) _t+="增伤:"+_db+"%\n";
               if(int(_dr)>0) _t+="减伤:"+_dr+"%\n";
               if(int(_cr)>0) _t+="暴击:"+_cr+"%\n";
               if(int(_cd)>0) _t+="暴伤:"+_cd+"%\n";
               _self.dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{htmlText:_t,type:3,width:140,height:Math.min(160,60+(_t.split('\n').length-1)*16)}));
            });
            _cell.addEventListener(MouseEvent.MOUSE_OUT, function(p:*):void {
               _self.dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
            });

            _cell.addEventListener(MouseEvent.CLICK, function(p:*):void {
               _self.equipItem(_self._selectingSlot, p.currentTarget.name);
            });

            // 售卖按钮(右下角)
            var _sellBtn:Sprite = new Sprite();
            _sellBtn.name = "sell_" + _item.code;
            _sellBtn.buttonMode = true; _sellBtn.mouseChildren = false;
            var _sellBg:Shape = new Shape();
            _sellBg.graphics.beginFill(0x1a1a1a,0.7);
            _sellBg.graphics.lineStyle(0.5,0x999999,0.6);
            _sellBg.graphics.drawRoundRect(0,0,12,10,2,2);
            _sellBg.graphics.endFill();
            _sellBtn.addChild(_sellBg);
            var _sellTF:TextField = new TextField();
            _sellTF.defaultTextFormat = new TextFormat("SimSun",6,0xCCCCCC,false);
            _sellTF.text = "售"; _sellTF.selectable = false;
            _sellTF.width = 12; _sellTF.height = 10; _sellTF.x = 0; _sellTF.y = -1;
            _sellBtn.addChild(_sellTF);
            _sellBtn.x = _cellW - 14; _sellBtn.y = _cellH - 12;
            _sellBtn.addEventListener(MouseEvent.CLICK, function(p:*):void {
               p.stopImmediatePropagation();
               var _sellCode:String = p.currentTarget.name.replace("sell_","");
               _self.onSellEquipClick(_sellCode);
            });
            _cell.addChild(_sellBtn);

            this._bagList.addChild(_cell);
            _ci++;
         }

         // 翻页栏
         var _fy:int = _listH - _footerH + 4;
         if(_totalPages > 1) {
            var _btnW:int = 22;
            function mkPgBtn(label:String, enabled:Boolean, handler:Function):Sprite {
               var s:Sprite = new Sprite();
               var bg:Shape = new Shape();
               bg.graphics.beginFill(enabled?0x3a2010:0x1a1008,0.9);
               bg.graphics.lineStyle(1,enabled?0xC8A84E:0x444444,0.6);
               bg.graphics.drawRoundRect(0,0,_btnW,18,3,3); bg.graphics.endFill();
               s.addChild(bg);
               var t:TextField = new TextField();
               t.defaultTextFormat = new TextFormat("SimSun",10,enabled?0xC8A84E:0x555555);
               t.text=label; t.selectable=false; t.width=_btnW; t.height=14; t.x=0; t.y=2;
               s.addChild(t); s.buttonMode=enabled; s.mouseChildren=false;
               if(enabled) s.addEventListener(MouseEvent.CLICK,function(p:*):void{handler();});
               return s;
            }
            var _btns:Array = [
               mkPgBtn("◀◀",this._equipListPage>0,function(){_self._equipListPage=0;_self.renderEquipList();}),
               mkPgBtn("◀",this._equipListPage>0,function(){_self._equipListPage--;_self.renderEquipList();}),
               null, // 页码
               mkPgBtn("▶",this._equipListPage<_totalPages-1,function(){_self._equipListPage++;_self.renderEquipList();}),
               mkPgBtn("▶▶",this._equipListPage<_totalPages-1,function(){_self._equipListPage=_totalPages-1;_self.renderEquipList();})
            ];
            var _pgTF:TextField = new TextField();
            _pgTF.defaultTextFormat = new TextFormat("SimHei",10,0xD4C8A0,true);
            _pgTF.text = (this._equipListPage+1)+"/"+_totalPages;
            _pgTF.selectable = false; _pgTF.autoSize = TextFieldAutoSize.CENTER;
            _pgTF.width = 40; _pgTF.height = 16;
            _btns[2] = _pgTF;
            var _tw:int = 22*4+40+12; var _sx:int = int((_listW-_tw)/2);
            var _bx:int = _sx;
            for(var _bi:int=0;_bi<_btns.length;_bi++){
               if(_btns[_bi] is TextField){ (_btns[_bi] as TextField).x=_bx; (_btns[_bi] as TextField).y=_fy; _bx+=40+4; }
               else { (_btns[_bi] as Sprite).x=_bx; (_btns[_bi] as Sprite).y=_fy; _bx+=_btnW+4; }
               this._bagList.addChild(_btns[_bi] as DisplayObject);
            }
         }

         // 批量售卖按钮(页脚右侧)
         var _batchBtn2:Sprite = new Sprite();
         _batchBtn2.buttonMode = true; _batchBtn2.mouseChildren = false;
         var _bbg2:Shape = new Shape();
         _bbg2.graphics.beginFill(0x442200, 0.9);
         _bbg2.graphics.lineStyle(1, 0xFF9900, 0.7);
         _bbg2.graphics.drawRoundRect(0, 0, 70, 18, 3, 3);
         _bbg2.graphics.endFill();
         _batchBtn2.addChild(_bbg2);
         var _btf2:TextField = new TextField();
         _btf2.defaultTextFormat = new TextFormat("SimSun", 10, 0xFF9900, true);
         _btf2.text = "📦 批量售卖"; _btf2.selectable = false;
         _btf2.width = 68; _btf2.height = 14; _btf2.x = 2; _btf2.y = 2;
         _batchBtn2.addChild(_btf2);
         _batchBtn2.x = _listW - 78; _batchBtn2.y = _listH - _footerH - 4;
         _batchBtn2.addEventListener(MouseEvent.CLICK, function(p:*):void {
            p.stopImmediatePropagation();
            _self.showBatchSellView();
         });
         this._bagList.addChild(_batchBtn2);

         this._bagList.visible = true;
      }

      // ========== 批量售卖 ==========
      private var _batchSelected2:Object = {};
      private var _batchFilterQ2:int = 0;
      private var _batchPage2:int = 0;

      private function showBatchSellView() : void {
         var _self:GeneralInfoPanel = this;
         var _allItems:Array = RoleModel.getInstance().getBagEquipItems(0);
         if(_allItems.length == 0) {
            this.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"背包中没有可售卖的装备。"}));
            return;
         }
         // 显示所有背包装备(服务端处理售出)
         if(this._batchPage2 == 0 && this._batchFilterQ2 == 0) {
            this._batchSelected2 = {};
            for(var _i:int=0;_i<_allItems.length;_i++) this._batchSelected2[_allItems[_i].id]=true;
         }

         while(this._bagList.numChildren>0) this._bagList.removeChildAt(0);
         var _w:int=370; var _h:int=270; var _pageSize:int=7;
         this._bagList.x = int((400-_w)/2) - 40;
         this._bagList.y = int((300-_h)/2) - 30;
         this._bagList.graphics.clear();
         this._bagList.graphics.beginFill(0x0d0804,0.98);
         this._bagList.graphics.lineStyle(2,0x8B6914,0.9);
         this._bagList.graphics.drawRoundRect(0,0,_w,_h,8,8);
         this._bagList.graphics.endFill();

         var _ttf2:TextField = new TextField();
         _ttf2.defaultTextFormat = new TextFormat("SimHei",12,0xFFD700,true);
         _ttf2.text = "批量售卖 ("+_allItems.length+"件)"; _ttf2.selectable=false;
         _ttf2.autoSize = TextFieldAutoSize.CENTER; _ttf2.x=(_w-_ttf2.width)/2; _ttf2.y=5;
         this._bagList.addChild(_ttf2);

         var _close2:TextField = new TextField();
         _close2.defaultTextFormat = new TextFormat("SimHei",14,0xCC4444,true);
         _close2.text="✕"; _close2.selectable=false; _close2.width=22; _close2.height=20;
         _close2.x=_w-26; _close2.y=2;
         _close2.addEventListener(MouseEvent.CLICK,function(p:*):void{_self._batchPage2=0;_self.hideEquipBagList();});
         this._bagList.addChild(_close2);

         // 品质筛选
         var _qy:int=26;
         var _qt2:TextField = new TextField();
         _qt2.defaultTextFormat = new TextFormat("SimSun",9,0x998866);
         _qt2.text="品质:"; _qt2.selectable=false; _qt2.width=30; _qt2.height=14;
         _qt2.x=4; _qt2.y=_qy+1; this._bagList.addChild(_qt2);
         for(var _qi2:int=1;_qi2<=10;_qi2++){
            var _qb2:Sprite=new Sprite(); _qb2.name="q2btn"+_qi2;
            _qb2.buttonMode=true; _qb2.mouseChildren=false;
            var _qx2:int=34+(_qi2-1)*33;
            _qb2.graphics.beginFill(_qi2==_self._batchFilterQ2?0x8B6914:0x221100,0.9);
            _qb2.graphics.lineStyle(1,_qi2==_self._batchFilterQ2?0xFFD700:0x554422);
            _qb2.graphics.drawRoundRect(0,0,29,14,3,3); _qb2.graphics.endFill();
            var _qtf3:TextField=new TextField();
            _qtf3.defaultTextFormat=new TextFormat("SimSun",8,_qi2==_self._batchFilterQ2?0xFFD700:0x776644);
            _qtf3.text="Q"+_qi2; _qtf3.selectable=false; _qtf3.width=29; _qtf3.height=12; _qtf3.x=0; _qtf3.y=1;
            _qb2.addChild(_qtf3); _qb2.x=_qx2; _qb2.y=_qy;
            _qb2.addEventListener(MouseEvent.CLICK,function(p:*):void{
               var _qn2:int=int(p.currentTarget.name.replace("q2btn",""));
               _self._batchFilterQ2=(_self._batchFilterQ2==_qn2)?0:_qn2;
               _self._batchPage2=0;
               _self.showBatchSellView();
            });
            this._bagList.addChild(_qb2);
         }


         // 筛选可见物品
         var _filtered:Array = [];
         for(var _fi:int=0;_fi<_allItems.length;_fi++){
            var _fq:int=int(EquipData.get(_allItems[_fi].code,"quality"));
            if(_self._batchFilterQ2>0 && _fq!=_self._batchFilterQ2) continue;
            _filtered.push(_allItems[_fi]);
         }
         var _totalPages:int = Math.max(1, Math.ceil(_filtered.length / _pageSize));
         if(_self._batchPage2 >= _totalPages) _self._batchPage2 = _totalPages-1;
         var _start:int = _self._batchPage2 * _pageSize;
         var _end:int = Math.min(_start + _pageSize, _filtered.length);

         // 物品列表
         var _ly:int=_qy+20;
         for(var _vi2:int=_start;_vi2<_end;_vi2++){
            var _it:Object=_filtered[_vi2];
            var _q2:int=int(EquipData.get(_it.code,"quality"));
            var _rn:int=_vi2-_start;
            var _rw2:Sprite=new Sprite(); _rw2.y=_ly+_rn*24;
            _rw2.mouseEnabled = false;

            var _sel3:Boolean=_self._batchSelected2[_it.id]==true;
            var _cb2:Sprite=new Sprite(); _cb2.name="bcb_"+_it.id;
            _cb2.mouseChildren=false; _cb2.buttonMode=true;
            _cb2.graphics.beginFill(_sel3?0x8B6914:0x1a1008,0.9);
            _cb2.graphics.lineStyle(1,_sel3?0xFFD700:0x554422,0.8);
            _cb2.graphics.drawRoundRect(0,0,14,14,2,2); _cb2.graphics.endFill();
            if(_sel3){_cb2.graphics.lineStyle(2,0xFFD700,1); _cb2.graphics.moveTo(3,7); _cb2.graphics.lineTo(6,10); _cb2.graphics.lineTo(11,4);}
            _cb2.x=6; _cb2.y=3;
            _cb2.addEventListener(MouseEvent.CLICK,function(p:*):void{
               p.stopImmediatePropagation();
               var _bid:Number = Number(p.currentTarget.name.replace("bcb_",""));
               _self._batchSelected2[_bid]=!_self._batchSelected2[_bid];
               _self.showBatchSellView();
            });
            _rw2.addChild(_cb2);

            var _ntf:TextField=new TextField();
            _ntf.defaultTextFormat=new TextFormat("SimSun",10,getQualityColor(_q2));
            _ntf.text=EquipData.get(_it.code,"name")+" Q"+_q2+" Lv"+(int(EquipData.get(_it.code,"levelReq"))||1)+" ¥"+getEquipSellPrice(_it.code).silver;
            _ntf.selectable=false; _ntf.width=300; _ntf.height=18;
            _ntf.x=26; _ntf.y=1;
            _rw2.addChild(_ntf);
            this._bagList.addChild(_rw2);
         }

         // 翻页
         if(_totalPages > 1) {
            var _pgy:int = _ly + _pageSize * 24 + 4;
            var _mkPg2:Function = function(label:String, enabled:Boolean, handler:Function):Sprite {
               var s:Sprite=new Sprite(); s.buttonMode=enabled; s.mouseChildren=false;
               var bg:Shape=new Shape();
               bg.graphics.beginFill(enabled?0x332200:0x111111,0.9);
               bg.graphics.lineStyle(1,enabled?0x8B6914:0x333333);
               bg.graphics.drawRoundRect(0,0,28,16,3,3); bg.graphics.endFill();
               s.addChild(bg);
               var t:TextField=new TextField();
               t.defaultTextFormat=new TextFormat("SimSun",9,enabled?0xC8A84E:0x555555);
               t.text=label; t.selectable=false; t.width=28; t.height=12; t.x=0; t.y=2;
               s.addChild(t);
               if(enabled) s.addEventListener(MouseEvent.CLICK,function(p:*):void{handler();});
               return s;
            };
            var _pgs:Array = [
               _mkPg2("◀◀",_self._batchPage2>0,function(){_self._batchPage2=0;_self.showBatchSellView();}),
               _mkPg2("◀",_self._batchPage2>0,function(){_self._batchPage2--;_self.showBatchSellView();})
            ];
            var _pgTF2:TextField = new TextField();
            _pgTF2.defaultTextFormat = new TextFormat("SimHei",10,0xD4C8A0,true);
            _pgTF2.text = (_self._batchPage2+1)+"/"+_totalPages;
            _pgTF2.selectable = false; _pgTF2.autoSize = TextFieldAutoSize.CENTER;
            _pgTF2.width = 40; _pgTF2.height = 14;
            _pgs.push(_pgTF2);
            _pgs.push(_mkPg2("▶",_self._batchPage2<_totalPages-1,function(){_self._batchPage2++;_self.showBatchSellView();}));
            _pgs.push(_mkPg2("▶▶",_self._batchPage2<_totalPages-1,function(){_self._batchPage2=_totalPages-1;_self.showBatchSellView();}));
            var _ptw:int = 28*4+40+16;
            var _psx:int = int((_w-_ptw)/2);
            var _px:int = _psx;
            for(var _pbi:int=0;_pbi<_pgs.length;_pbi++){
               if(_pgs[_pbi] is TextField) { (_pgs[_pbi] as TextField).x=_px; (_pgs[_pbi] as TextField).y=_pgy; _px+=40+4; }
               else { (_pgs[_pbi] as Sprite).x=_px; (_pgs[_pbi] as Sprite).y=_pgy; _px+=28+4; }
               this._bagList.addChild(_pgs[_pbi] as DisplayObject);
            }
         }

         // 底部统计
         var _totS:int=0,_totD:int=0,_scnt:int=0; var _scodes:Array=[];
         for(var _si:int=0;_si<_allItems.length;_si++){
            var _it4:Object=_allItems[_si];
            if(_self._batchSelected2[_it4.id]!=true) continue;
            var _q4:int=int(EquipData.get(_it4.code,"quality"));
            if(_self._batchFilterQ2>0&&_q4!=_self._batchFilterQ2) continue;
            var _p4:Object=getEquipSellPrice(_it4.code);
            _totS+=_p4.silver; _totD+=_p4.dianka; _scnt++;
            _scodes.push(_it4.code);
         }
         var _bmy:int=_h-40;
         var _stf4:TextField=new TextField();
         _stf4.defaultTextFormat=new TextFormat("SimHei",11,0xFFD700);
         _stf4.text="选中"+_scnt+"件  银子+"+_totS+(_totD>0?"  点卡+"+_totD:"");
         _stf4.selectable=false; _stf4.autoSize=TextFieldAutoSize.CENTER;
         _stf4.x=(_w-_stf4.width)/2; _stf4.y=_bmy; this._bagList.addChild(_stf4);

         if(_scnt>0){
            var _cb3:Sprite=new Sprite(); _cb3.buttonMode=true; _cb3.mouseChildren=false;
            _cb3.x=(_w-120)/2; _cb3.y=_bmy+16;
            var _cs3:Shape=new Shape();
            _cs3.graphics.beginFill(0x8B0000,0.9);
            _cs3.graphics.lineStyle(1.5,0xFF6600,0.8);
            _cs3.graphics.drawRoundRect(0,0,120,22,4,4); _cs3.graphics.endFill();
            _cb3.addChild(_cs3);
            var _ct3:TextField=new TextField();
            _ct3.defaultTextFormat=new TextFormat("SimHei",12,0xFFD700,true);
            _ct3.text="确认批量售卖"; _ct3.selectable=false;
            _ct3.autoSize=TextFieldAutoSize.CENTER; _ct3.x=(120-_ct3.width)/2; _ct3.y=3;
            _cb3.addChild(_ct3);
            var _fc:Array=_scodes; var _fs:int=_totS; var _fd:int=_totD;
            _cb3.addEventListener(MouseEvent.CLICK,function(p:*):void{
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":1,"text":"确定要批量售卖"+_fc.length+"件装备吗？\n可得银子+"+_fs+(_fd>0?" 点卡+"+_fd:""),
                  "fun":function():void{_self.batchSellEquip2(_fc);}
               }));
            });
            this._bagList.addChild(_cb3);
         }
         // 全选/取消(标题栏右侧,最后添加置顶)
         var _ab2:Sprite=new Sprite(); _ab2.buttonMode=true; _ab2.mouseChildren=false;
         _ab2.graphics.beginFill(0x332200,0.9);
         _ab2.graphics.lineStyle(1,0x8B6914); _ab2.graphics.drawRoundRect(0,0,54,14,3,3);
         _ab2.graphics.endFill();
         var _atf3:TextField=new TextField();
         _atf3.defaultTextFormat=new TextFormat("SimSun",9,0xCCAA44);
         _atf3.text="全选/取消"; _atf3.selectable=false; _atf3.width=54; _atf3.height=12; _atf3.x=0; _atf3.y=1;
         _ab2.addChild(_atf3);
         _ab2.x=_w-85; _ab2.y=5;
         _ab2.addEventListener(MouseEvent.CLICK,function(p:*):void{
            var _any2:Boolean=false;
            for(var _fi3:int=0;_fi3<_allItems.length;_fi3++) {
               if(_self._batchSelected2[_allItems[_fi3].id]) { _any2=true; break; }
            }
            for(var _fi4:int=0;_fi4<_allItems.length;_fi4++) {
               _self._batchSelected2[_allItems[_fi4].id] = !_any2;
            }
            _self.showBatchSellView();
         });
         this._bagList.addChild(_ab2);
         this._bagList.visible=true;
      }

      private function batchSellEquip2(codes:Array):void{
         var _self:GeneralInfoPanel=this;
         var _obj:Object={};
         _obj.head=Head.HTTP_NEW_SELL_EQUIP;
         _obj.agent=Config.AGENT; _obj.ver=Config.VER;
         _obj.token=Config.token;
         _obj.roleID=RoleModel.getInstance().roleID;
         _obj.userID=RoleModel.getInstance().userID;
         _obj.itemCodes=codes.join(",");
         _obj.mask=true;
         AESController.getInstance().sendJSON(_obj,function(param1:Object):void{
            if(param1.success==true){
               if(param1.data.bagModel) RoleModel.getInstance().initBagModel(param1.data.bagModel);
               if(param1.data.money!=undefined) RoleModel.getInstance().money=int(param1.data.money);
               if(param1.data.dianka!=undefined) RoleModel.getInstance().dianka=int(param1.data.dianka);
               _self.hideEquipBagList();
               _self.flush();
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  type:0,text:"批量售卖完成！售出"+(param1.data.soldCount||codes.length)+"件，银子+"+(param1.data.totalSilver||0)+(param1.data.totalDianka>0?" 点卡+"+param1.data.totalDianka:"")
               }));
            }else{
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:param1.message||"批量售卖失败"}));
            }
         });
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
               _self._armyInfo.hp = _self._armyInfo.maxHp;
               if(param3.data.bagModel)
               {
                  RoleModel.getInstance().initBagModel(param3.data.bagModel);
               }
               if(param3.data.money != undefined) RoleModel.getInstance().money = int(param3.data.money);
               _self.flush();
               if(_self._bagList.visible) _self.showEquipBagList(_self._selectingSlot);
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
         var _self:GeneralInfoPanel = this;
         var price:Object = getEquipSellPrice(code);
         var nm:* = EquipData.get(code,"name");
         var msg:String = "确定要售卖 [" + nm + "] 吗？\n";
         msg += "可获得：银子+" + price.silver;
         if(price.dianka > 0) msg += "  点卡+" + price.dianka;
         dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
            "type":1,
            "text":msg,
            "fun":function():void { _self.sellEquip(code); }
         }));
      }

      private function sellEquip(code:String):void {
         var _self:GeneralInfoPanel = this;
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
               _self.flush();
               if(_self._bagList.visible) _self.showEquipBagList(_self._selectingSlot);
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
         this._general.mouseEnabled = false;
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
         this.__valueTF.htmlText = _loc1_;

         // 装备特殊属性 — 右侧独立显示
         var _ls:int = this._armyInfo.equipLifesteal;
         var _db:int = this._armyInfo.equipDmgBonus;
         var _dr:int = this._armyInfo.equipDmgReduce;
         var _cr:int = this._armyInfo.equipCritRate;
         var _cd:int = this._armyInfo.equipCritDmg;
         if(this.__specTF == null) {
            this.__specTF = new TextField();
            this.__specTF.width = 200; this.__specTF.height = 60;
            this.__specTF.multiline = true; this.__specTF.wordWrap = true;
            this.__specTF.selectable = false;
            this.__specTF.mouseEnabled = false;
            this.__specTF.defaultTextFormat = new TextFormat("SimSun", 10, 0xFFFFFF);
            addChild(this.__specTF);
         }
         this.__specTF.x = this.__xiaohaoTF.x + this.__xiaohaoTF.width + 10;
         this.__specTF.y = this.__xiaohaoTF.y - 20;
         var _s:String = "";
         if(_ls > 0 || _db > 0 || _dr > 0 || _cr > 0 || _cd > 0) {
            _s += "<font color='#FFD700' size='11'><b>特殊属性</b></font><br/>";
            var _arr:Array = [];
            if(_ls > 0) _arr.push("<font color='#FF6600'>吸血+" + _ls + "%</font>");
            if(_db > 0) _arr.push("<font color='#FF6600'>增伤+" + _db + "%</font>");
            if(_dr > 0) _arr.push("<font color='#FF6600'>减伤+" + _dr + "%</font>");
            if(_cr > 0) _arr.push("<font color='#FF6600'>暴击+" + _cr + "%</font>");
            if(_cd > 0) _arr.push("<font color='#FF6600'>暴伤+" + _cd + "%</font>");
            // 竖排3列：先填满每纵3条，再换下一纵
            var COLS:int = 3;
            var _total:int = _arr.length;
            var _rows:int = Math.ceil(_total / COLS);
            var _r:int = 0;
            while(_r < _rows) {
               var _c:int = 0;
               while(_c < COLS) {
                  var _idx:int = _r + _c * _rows;
                  if(_idx < _total) {
                     _s += _arr[_idx];
                     if(_c < COLS - 1 && _idx + _rows < _total) {
                        _s += "    ";
                     }
                  }
                  _c++;
               }
               if(_r < _rows - 1) _s += "<br/>";
               _r++;
            }
         }
         this.__specTF.htmlText = _s;
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
         var _plyLv:int = RoleModel.getInstance().level;
         if(this._armyInfo.level < _plyLv)
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
               "text":"武将等级已达君主等级上限，请先提升君主等级。"
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
            RoleModel.getInstance().money = param1.data.money;
            RoleModel.getInstance().exploit = param1.data.exploit;
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
