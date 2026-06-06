package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.Logic;
   import game.events.UIEvent;
   import game.model.ArmyInfo;
   import game.model.RoleModel;
   import game.model.Type;
   
   public class GeneralFullInfoBlock extends BaseUI
   {
       
      
      private var __shengjiBtn:SimpleButton;
      
      private var __jinhuaBtn:SimpleButton;
      
      private var __nameTF:TextField;
      
      private var __valueTF:TextField;
      
      private var _block:GeneralBlock;
      
      private var __titleTF:TextField;
      
      private var _posX:Number = 13;
      
      private var _posY:Number = 15;
      
      private var _armyInfo:ArmyInfo;
      
      private var _roleModel:RoleModel;
      
      public function GeneralFullInfoBlock(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__shengjiBtn = _skin.getChildByName("_shengjiBtn") as SimpleButton;
         this.__jinhuaBtn = _skin.getChildByName("_jinhuaBtn") as SimpleButton;
         this.__nameTF = _skin.getChildByName("_nameTF") as TextField;
         this.__valueTF = _skin.getChildByName("_valueTF") as TextField;
         this.__titleTF = _skin.getChildByName("_titleTF") as TextField;
         this.__nameTF.text = "";
         this.__valueTF.text = "";
      }
      
      override protected function initEvent() : void
      {
         this.__shengjiBtn.addEventListener(MouseEvent.CLICK,this.shengjiBtnClickHandler);
         this.__jinhuaBtn.addEventListener(MouseEvent.CLICK,this.jinhuaBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this._roleModel = param1.roleModel;
         this._armyInfo = param1.armyInfo;
         if(this._block == null)
         {
            this._block = new GeneralBlock(SkinCode.GENERAL_BLOCK);
            this._block.x = this._posX;
            this._block.y = this._posY;
            addChild(this._block);
         }
         this._block.initData(this._armyInfo);
         this.createTitle();
         this.createNameTF();
         this.createValueTF();
         this.checkBtn();
      }
      
      private function checkBtn() : *
      {
         if(this._armyInfo.evolution >= 10)
         {
            Tools.setDisabled(this.__jinhuaBtn,true);
         }
         else
         {
            Tools.setDisabled(this.__jinhuaBtn,false);
         }
      }
      
      private function createTitle() : *
      {
         switch(this._armyInfo.title)
         {
            case 0:
               this.__titleTF.htmlText = "<font color=\'#ff6600\'>超级武将</font>";
               break;
            case 1:
               this.__titleTF.htmlText = "<font color=\'#33ccff\'>一流武将</font>";
               break;
            case 2:
               this.__titleTF.htmlText = "<font color=\'#99ff33\'>二流武将</font>";
               break;
            default:
               this.__titleTF.htmlText = "<font color=\'#ffcc99\'>三流武将</font>";
         }
      }
      
      private function createNameTF() : *
      {
         var _loc1_:* = "";
         _loc1_ += "类型：\n";
         _loc1_ += "攻击：\n";
         _loc1_ += "防御：\n";
         _loc1_ += "血量：\n";
         _loc1_ += "射程：\n";
         _loc1_ += "进化等级：\n";
         _loc1_ += "攻击属相：\n";
         _loc1_ += "升级消耗：\n";
         this.__nameTF.text = _loc1_;
      }
      
      private function createValueTF() : *
      {
         var _loc1_:* = "";
         switch(this._armyInfo.type)
         {
            case Type.CHANGQIANGBING:
               _loc1_ += "长枪兵\n";
               break;
            case Type.CHUIBING:
               _loc1_ += "锤兵\n";
               break;
            case Type.FEIDAOBING:
               _loc1_ += "飞刀兵\n";
               break;
            case Type.FUBING:
               _loc1_ += "斧兵\n";
               break;
            case Type.GONGBING:
               _loc1_ += "弓兵\n";
               break;
            case Type.PUDAOBING:
               _loc1_ += "朴刀兵\n";
               break;
            case Type.QIBING:
               _loc1_ += "骑兵\n";
               break;
            case Type.TENGJIABING:
               _loc1_ += "藤甲兵\n";
               break;
            case Type.TOUSHICHE:
               _loc1_ += "投石车\n";
               break;
            case Type.WUDOUBING:
               _loc1_ += "武斗兵\n";
         }
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
         }
         else
         {
            _loc1_ += "    " + this._armyInfo.evolution + "级 <font color=\'#4bea13\'>全属性增加" + this._armyInfo.getAddtion() * 100 + "%</font>\n";
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
         _loc1_ += "    " + Logic.getExploitByLevel(this._armyInfo.level) + " 功勋  " + Logic.getMoneyByLevel(this._armyInfo.level) + " 银子";
         this.__valueTF.htmlText = _loc1_;
      }
      
      private function shengjiBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._armyInfo.level < 200)
         {
            dispatchEvent(new UIEvent(UIEvent.SHENGJI_CLICK,true,this._armyInfo));
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
         if(this._armyInfo.level >= 30)
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
   }
}
