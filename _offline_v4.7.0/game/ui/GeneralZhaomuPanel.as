package game.ui
{
   import com.iflashigame.controller.AESController;
   import com.iflashigame.sound.MySound;
   import com.iflashigame.talk.NetInfoType;
   import com.iflashigame.talk.TalkEvent;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.Config;
   import game.Data;
   import game.SoundCode;
   import game.TextFactory;
   import game.events.UIEvent;
   import game.model.ArmyInfo;
   import game.model.Head;
   import game.model.RoleModel;
   import game.model.Type;
   
   public class GeneralZhaomuPanel extends BaseUI
   {
      
      private static const QIUXIANLING:int = 20;
       
      
      private var __diankaBtn:SimpleButton;
      
      private var __diankaTF:TextField;
      
      private var __diankaTipsTF:TextField;
      
      private var __putongBtn:SimpleButton;
      
      private var __putongTF:TextField;
      
      private var __putongTipsTF:TextField;
      
      private var __jixuBtn:SimpleButton;
      
      private var __cancelBtn:SimpleButton;
      
      private var __infoTF:TextField;
      
      private var __lostTF:TextField;
      
      private var __countTF:TextField;
      
      private var __titleTF:TextField;
      
      private var _block:GeneralBlock;
      
      private var _pos1:Point;
      
      private var _armyInfo:ArmyInfo;
      
      private var _count:int;
      
      public function GeneralZhaomuPanel(param1:String, param2:ApplicationDomain = null)
      {
         this._pos1 = new Point(-206.65,-109.65);
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__diankaBtn = _skin.getChildByName("_diankaBtn") as SimpleButton;
         this.__diankaTF = _skin.getChildByName("_diankaTF") as TextField;
         this.__diankaTipsTF = _skin.getChildByName("_diankaTipsTF") as TextField;
         this.__putongBtn = _skin.getChildByName("_putongBtn") as SimpleButton;
         this.__putongTF = _skin.getChildByName("_putongTF") as TextField;
         this.__putongTipsTF = _skin.getChildByName("_putongTipsTF") as TextField;
         this.__infoTF = _skin.getChildByName("_infoTF") as TextField;
         this.__lostTF = _skin.getChildByName("_lostTF") as TextField;
         this.__countTF = _skin.getChildByName("_countTF") as TextField;
         this.__titleTF = _skin.getChildByName("_titleTF") as TextField;
         this.__jixuBtn = _skin.getChildByName("_jixuBtn") as SimpleButton;
         this.__cancelBtn = _skin.getChildByName("_cancelBtn") as SimpleButton;
         this.__diankaTF.text = "";
         this.__diankaTipsTF.text = "";
         this.__putongTF.text = "";
         this.__putongTipsTF.text = "";
         this.__infoTF.text = "";
         this.__countTF.text = "";
         this.__lostTF.visible = false;
      }
      
      override protected function initEvent() : void
      {
         this.__diankaBtn.addEventListener(MouseEvent.CLICK,this.diankaBtnClickHandler);
         this.__putongBtn.addEventListener(MouseEvent.CLICK,this.putongBtnClickHandler);
         this.__jixuBtn.addEventListener(MouseEvent.CLICK,this.jixuBtnClickHandler);
         this.__cancelBtn.addEventListener(MouseEvent.CLICK,this.cancelBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this._count = ~3;
         this._armyInfo = param1 as ArmyInfo;
         if(this._block == null)
         {
            this._block = new GeneralBlock(SkinCode.GENERAL_BLOCK);
            this._block.x = this._pos1.x;
            this._block.y = this._pos1.y;
            addChild(this._block);
         }
         this._block.initData(this._armyInfo);
         this.createInfo();
         this.createDiankaInfo();
         this.createPutongInfo();
         this.createTitle();
         this.check();
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
      
      private function createInfo() : void
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
         _loc1_ += this._armyInfo.attackDistance;
         this.__infoTF.text = _loc1_;
      }
      
      private function createDiankaInfo() : void
      {
         var _loc1_:String = "";
         _loc1_ += "招募几率:" + Data.getInstance().getAttributes("general",this._armyInfo.code,"dianka") + "%\n";
         _loc1_ += "需要：声望 1000  点卡 " + QIUXIANLING + "\n";
         this.__diankaTF.text = _loc1_;
      }
      
      private function createPutongInfo() : void
      {
         var _loc1_:* = "";
         _loc1_ += "招募几率:" + Data.getInstance().getAttributes("general",this._armyInfo.code,"money") + "%\n";
         _loc1_ += "需要：声望 1000  银子 1000\n";
         this.__putongTF.text = _loc1_;
      }
      
      private function check() : void
      {
         if(RoleModel.getInstance().reverence < 1000)
         {
            this.__diankaTipsTF.text = "没有足够的声望";
            Tools.setDisabled(this.__diankaBtn,true);
         }
         else if(RoleModel.getInstance().getBagItemCount("proto_3_3") > 0)
         {
            this.__diankaTipsTF.text = "";
            Tools.setDisabled(this.__diankaBtn,false);
         }
         else if(RoleModel.getInstance().dianka < QIUXIANLING)
         {
            this.__diankaTipsTF.text = "没有足够的点卡，请先充值。";
            Tools.setDisabled(this.__diankaBtn,true);
         }
         else
         {
            this.__diankaTipsTF.text = "";
            Tools.setDisabled(this.__diankaBtn,false);
         }
         if(RoleModel.getInstance().reverence < 1000)
         {
            this.__putongTipsTF.text = "没有足够的声望";
            Tools.setDisabled(this.__putongBtn,true);
         }
         else if(RoleModel.getInstance().money < 1000)
         {
            this.__putongTipsTF.text = "没有足够的银子";
            Tools.setDisabled(this.__putongBtn,true);
         }
         else
         {
            this.__putongTipsTF.text = "";
            Tools.setDisabled(this.__putongBtn,false);
         }
         if(~this._count <= 0)
         {
            this.__countTF.text = "武将招募次数耗尽，请重新搜索。";
            Tools.setDisabled(this.__diankaBtn,true);
            Tools.setDisabled(this.__putongBtn,true);
         }
         else
         {
            this.__countTF.text = "武将剩余可招募次数" + ~this._count + "/3";
         }
      }
      
      private function zhaomuSuccessOK() : *
      {
         dispatchEvent(new UIEvent(UIEvent.OPEN_ZHAOMU,true));
      }
      
      private function zhaomuSuccessCancel() : *
      {
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
      
      private function jixuBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_ZHAOMU,true));
      }
      
      private function cancelBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
      
      private function diankaBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(RoleModel.getInstance().getBagItemCount("proto_3_3") > 0)
         {
            this.sendToHttpNew(Head.HTTP_NEW_QIUXIAN_ZHAOMU);
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":1,
               "text":"点卡招募需要花费20点卡，将会大大提升招募几率，且不消耗招募次数，是否确认使用？",
               "fun":this.realyDianka
            }));
         }
      }
      
      private function realyDianka() : *
      {
         this.sendToHttpNew(Head.HTTP_NEW_DIANKA_ZHAOMU);
      }
      
      private function putongBtnClickHandler(param1:MouseEvent) : *
      {
         this.sendToHttpNew(Head.HTTP_NEW_PUTONG_ZHAOMU);
      }
      
      private function sendToHttpNew(param1:int) : *
      {
         var _loc2_:Object = {};
         _loc2_.head = param1;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         _loc2_.code = this._armyInfo.code;
         _loc2_.mask = true;
         switch(param1)
         {
            case Head.HTTP_NEW_PUTONG_ZHAOMU:
               AESController.getInstance().sendJSON(_loc2_,this.putongResponse);
               break;
            case Head.HTTP_NEW_QIUXIAN_ZHAOMU:
               AESController.getInstance().sendJSON(_loc2_,this.diankaResponse);
               break;
            case Head.HTTP_NEW_DIANKA_ZHAOMU:
               AESController.getInstance().sendJSON(_loc2_,this.diankaResponse);
         }
      }
      
      private function putongResponse(param1:Object) : *
      {
         var _loc2_:Object = null;
         var _loc3_:ArmyInfo = null;
         var _loc4_:String = null;
         if(param1.success == true)
         {
            _loc2_ = param1.data;
            RoleModel.getInstance().reverence = int(_loc2_.reverence);
            RoleModel.getInstance().money = int(_loc2_.money);
            if(_loc2_.general == null)
            {
               this._count = ~(~this._count - 1);
               this.check();
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"招募失败，武将 " + this._armyInfo.name + " 不愿跟随你征战沙场。"
               }));
            }
            else
            {
               this._count = ~3;
               _loc3_ = Data.getInstance().getArmyInfo(_loc2_.general.code,_loc2_.general.level,_loc2_.general.evolution,_loc2_.general.feature,null,3000,100,_loc2_.general.kezhi,_loc2_.general.genius);
               _loc3_.id = Number(_loc2_.general.id);
               RoleModel.getInstance().addSoldier(_loc3_);
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":1,
                  "text":"招募成功！武将 " + this._armyInfo.name + " 正式投效于你，共谋天下霸业。",
                  "fun":this.zhaomuSuccessOK,
                  "cancelFun":this.zhaomuSuccessCancel,
                  "skin":SkinCode.ALERT_FOR_ZHAOMU
               }));
               MySound.getInstance().startEventSoundByName(SoundCode.SUCCESS);
               if(this._armyInfo.title <= 1)
               {
                  _loc4_ = TextFactory.makeZhaomu(RoleModel.getInstance().roleName,this._armyInfo);
                  dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                     "type":NetInfoType.SYSTEM,
                     "text":_loc4_
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
      
      private function diankaResponse(param1:Object) : *
      {
         var _loc2_:Object = null;
         var _loc3_:ArmyInfo = null;
         var _loc4_:String = null;
         if(param1.success == true)
         {
            _loc2_ = param1.data;
            RoleModel.getInstance().reverence = int(_loc2_.reverence);
            RoleModel.getInstance().dianka = int(_loc2_.dianka);
            if(_loc2_.general == null)
            {
               this.check();
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"招募失败，武将 " + this._armyInfo.name + " 不愿跟随你征战沙场。"
               }));
            }
            else
            {
               _loc3_ = Data.getInstance().getArmyInfo(_loc2_.general.code,_loc2_.general.level,_loc2_.general.evolution,_loc2_.general.feature,null,3000,100,_loc2_.general.kezhi,_loc2_.general.genius);
               _loc3_.id = Number(_loc2_.general.id);
               RoleModel.getInstance().addSoldier(_loc3_);
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":1,
                  "text":"招募成功！武将 " + this._armyInfo.name + " 正式投效于你，共谋天下霸业。",
                  "fun":this.zhaomuSuccessOK,
                  "cancelFun":this.zhaomuSuccessCancel,
                  "skin":SkinCode.ALERT_FOR_ZHAOMU
               }));
               MySound.getInstance().startEventSoundByName(SoundCode.SUCCESS);
               if(this._armyInfo.title <= 1)
               {
                  _loc4_ = TextFactory.makeZhaomu(RoleModel.getInstance().roleName,this._armyInfo);
                  dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                     "type":NetInfoType.SYSTEM,
                     "text":_loc4_
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
   }
}
