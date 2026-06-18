package game.ui
{
   import com.iflashigame.controller.AESController;
   import com.iflashigame.talk.NetInfoType;
   import com.iflashigame.talk.TalkEvent;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.BlurFilter;
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
   import game.model.Head;
   import game.model.RoleModel;
   import game.model.Type;
   
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
      }
      
      override public function initData(param1:Object) : void
      {
         this._armyInfo = param1 as ArmyInfo;
         this.flush();
      }
      
      private var _equipBtn:Sprite;

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
         this.showEquipBtn();
      }

      private function showEquipBtn() : void
      {
         if(this._equipBtn != null) { removeChild(this._equipBtn); this._equipBtn = null; }
         this._equipBtn = new Sprite();
         var _bg:Shape = new Shape();
         _bg.graphics.beginFill(0x4a2010, 0.94);
         _bg.graphics.lineStyle(2, 0xFFD700, 0.9);
         _bg.graphics.drawRoundRect(0, 0, 80, 28, 6, 6);
         _bg.graphics.endFill();
         this._equipBtn.addChild(_bg);
         var _tf:TextField = new TextField();
         _tf.defaultTextFormat = new TextFormat("SimHei", 13, 0xFFD700, true);
         _tf.text = "装 备";
         _tf.selectable = false;
         _tf.autoSize = TextFieldAutoSize.CENTER;
         _tf.x = (80 - _tf.width) / 2; _tf.y = 4;
         this._equipBtn.addChild(_tf);
         this._equipBtn.buttonMode = true;
         // 放在升级按钮下方, 位置醒目
         this._equipBtn.x = this.__shengjiBtn.x;
         this._equipBtn.y = this.__shengjiBtn.y + this.__shengjiBtn.height + 6;
         var _self:GeneralInfoPanel = this;
         this._equipBtn.addEventListener(MouseEvent.CLICK, function(p:MouseEvent):void {
            p.stopImmediatePropagation();
            _self.dispatchEvent(new UIEvent(UIEvent.OPEN_EQUIP, true, _self._armyInfo));
         });
         addChild(this._equipBtn);
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
         _loc1_ += this._armyInfo.attack + "\n";
         _loc1_ += this._armyInfo.defense + "\n";
         _loc1_ += this._armyInfo.hp + "\n";
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
         if(this._armyInfo.equipAttackBonus > 0 || this._armyInfo.equipDefenseBonus > 0 || this._armyInfo.equipHPBonus > 0)
         {
            _loc1_ += "<font color='#FFD700'>--装备加成--</font>\n";
            if(this._armyInfo.equipAttackFlat > 0) _loc1_ += "攻击 <font color='#4bea13'>+" + this._armyInfo.equipAttackFlat + "</font>";
            if(this._armyInfo.equipAttackPct > 0) _loc1_ += " <font color='#4bea13'>+" + this._armyInfo.equipAttackPct + "%</font>";
            if(this._armyInfo.equipAttackFlat > 0 || this._armyInfo.equipAttackPct > 0) _loc1_ += " ";
            if(this._armyInfo.equipDefenseFlat > 0) _loc1_ += "防御 <font color='#16d2fa'>+" + this._armyInfo.equipDefenseFlat + "</font>";
            if(this._armyInfo.equipDefensePct > 0) _loc1_ += " <font color='#16d2fa'>+" + this._armyInfo.equipDefensePct + "%</font>";
            if(this._armyInfo.equipDefenseFlat > 0 || this._armyInfo.equipDefensePct > 0) _loc1_ += " ";
            if(this._armyInfo.equipHPFlat > 0) _loc1_ += "生命 <font color='#ff3333'>+" + this._armyInfo.equipHPFlat + "</font>";
            if(this._armyInfo.equipHPPct > 0) _loc1_ += " <font color='#ff3333'>+" + this._armyInfo.equipHPPct + "%</font>";
            _loc1_ += "\n";
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
