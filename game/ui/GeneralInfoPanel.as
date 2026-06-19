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
            {x:-160, y:-208},  // 0:武器   (右,上)
            {x:-329, y:-146},  // 1:铠甲   (左,中)
            {x:-160, y:-146},  // 2:饰品Ⅰ (右,中)
            {x:-329, y:-208},  // 3:头盔   (左,上)
            {x:-329, y:-85},   // 4:战靴   (左,下)
            {x:-160, y:-85}    // 5:饰品Ⅱ (右,下)
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

            if(_eqCode != null && _eqCode != "" && _eqCode != "0")
            {
               var _q:int = int(EquipData.get(_eqCode,"quality"));
               var _qc:uint = getQualityBgColor(_q);

               // 品质纯色背景(不透明覆盖)
               var _bg:Shape = new Shape();
               _bg.graphics.beginFill(_qc, 0.95);
               _bg.graphics.drawRoundRect(0, 0, 34, 34, 4, 4);
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

               // 悬停显示装备属性
               var _eqC:String = _eqCode;
               _slot.addEventListener(MouseEvent.MOUSE_OVER, function(p:*):void {
                  var _n:* = EquipData.get(_eqC,"name"); var _a:int=int(EquipData.get(_eqC,"attack"))||0;
                  var _ap:int=int(EquipData.get(_eqC,"attackPct"))||0; var _d:int=int(EquipData.get(_eqC,"defense"))||0;
                  var _dp:int=int(EquipData.get(_eqC,"defensePct"))||0; var _h:int=int(EquipData.get(_eqC,"hp"))||0;
                  var _hp:int=int(EquipData.get(_eqC,"hpPct"))||0; var _ls:int=int(EquipData.get(_eqC,"lifesteal"))||0;
                  var _db:int=int(EquipData.get(_eqC,"dmgBonus"))||0; var _dr:int=int(EquipData.get(_eqC,"dmgReduce"))||0;
                  var _cr:int=int(EquipData.get(_eqC,"critRate"))||0; var _cd:int=int(EquipData.get(_eqC,"critDmg"))||0;
                  var _t:String = "<b>"+_n+"</b>\n";
                  if(_a||_ap) _t+="攻击:"+(_a>0?"+"+_a:_a)+(_ap>0?"+"+_ap+"%":"")+"\n";
                  if(_d||_dp) _t+="防御:"+(_d>0?"+"+_d:_d)+(_dp>0?"+"+_dp+"%":"")+"\n";
                  if(_h||_hp) _t+="气血:"+(_h>0?"+"+_h:_h)+(_hp>0?"+"+_hp+"%":"")+"\n";
                  if(_ls>0) _t+="吸血:"+_ls+"%\n"; if(_db>0) _t+="增伤:"+_db+"%\n";
                  if(_dr>0) _t+="减伤:"+_dr+"%\n"; if(_cr>0) _t+="暴击:"+_cr+"%\n";
                  if(_cd>0) _t+="暴伤:"+_cd+"%\n";
                  _self.dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{htmlText:_t,type:3,width:130,height:120}));
               });
               _slot.addEventListener(MouseEvent.MOUSE_OUT, function(p:*):void {
                  _self.dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
               });
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

      private var _qualityColors:Array = [0x999999,0xCCCCCC,0x4bea13,0x16d2fa,0xe720f9,0xFFD700,0xFF6600,0xFF4444,0xFF0000,0xFF6600,0xFFFFFF];
      private var _qualityBgColors:Array = [0x1a1a1a,0x2a2a2a,0x0d1d05,0x051525,0x150515,0x1d1800,0x1d0d00,0x1d0505,0x1d0000,0x150d00,0x0d0d0d];
      private var _qualityNames:Array = ["","普通","精良","稀有","史诗","传说","神话","远古","至尊","超凡","入圣"];
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

            // 品质背景
            var _cbg:Shape = new Shape();
            _cbg.graphics.beginFill(getQualityBgColor(_q),0.65);
            _cbg.graphics.lineStyle(1,getQualityColor(_q),0.5);
            _cbg.graphics.drawRoundRect(1,1,_cellW-2,_cellH-2,3,3);
            _cbg.graphics.endFill();
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
               var _t:String = "<b>"+_n+"</b> <font color='#888'>Lv"+_lv+"</font>\n";
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
            _sellBg.graphics.beginFill(0x660000,0.85);
            _sellBg.graphics.lineStyle(1,0xCC4444,0.7);
            _sellBg.graphics.drawRoundRect(0,0,16,14,3,3);
            _sellBg.graphics.endFill();
            _sellBtn.addChild(_sellBg);
            var _sellTF:TextField = new TextField();
            _sellTF.defaultTextFormat = new TextFormat("SimSun",9,0xFF6666,true);
            _sellTF.text = "售"; _sellTF.selectable = false;
            _sellTF.width = 16; _sellTF.height = 12; _sellTF.x = 1; _sellTF.y = 1;
            _sellBtn.addChild(_sellTF);
            _sellBtn.x = _cellW - 18; _sellBtn.y = _cellH - 16;
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
         if(_totalPages > 1) {
            var _fy:int = _listH - _footerH + 4;
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

      private static function getEquipSellPrice(code:String):Object {
         var q:int = int(EquipData.get(code,"quality"))||1;
         var lv:int = int(EquipData.get(code,"levelReq"))||1;
         return {silver: q * lv * 3, dianka: q >= 5 ? (q - 4) * 8 : 0};
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
            this.__specTF.width = 110; this.__specTF.height = 130;
            this.__specTF.multiline = true; this.__specTF.wordWrap = true;
            this.__specTF.selectable = false;
            addChild(this.__specTF);
         }
         this.__specTF.x = this.__xiaohaoTF.x + this.__xiaohaoTF.width + 15;
         this.__specTF.y = this.__xiaohaoTF.y - 40;
         var _s:String = "";
         if(_ls > 0 || _db > 0 || _dr > 0 || _cr > 0 || _cd > 0) {
            _s += "<font color='#FFD700' size='11'><b>特殊属性</b></font>\n";
            if(_ls > 0) _s += "<font color='#FF6600'>吸血 +" + _ls + "%</font>\n";
            if(_db > 0) _s += "<font color='#FF6600'>增伤 +" + _db + "%</font>\n";
            if(_dr > 0) _s += "<font color='#FF6600'>减伤 +" + _dr + "%</font>\n";
            if(_cr > 0) _s += "<font color='#FF6600'>暴击 +" + _cr + "%</font>\n";
            if(_cd > 0) _s += "<font color='#FF6600'>暴伤 +" + _cd + "%</font>\n";
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
