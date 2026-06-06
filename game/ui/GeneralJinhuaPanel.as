package game.ui
{
   import com.iflashigame.controller.AESController;
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
   import game.Logic;
   import game.TextFactory;
   import game.events.UIEvent;
   import game.model.ArmyInfo;
   import game.model.Head;
   import game.model.RoleModel;
   
   public class GeneralJinhuaPanel extends BaseUI
   {
       
      
      private var __valueTF1:TextField;
      
      private var __valueTF2:TextField;
      
      private var __infoTF1:TextField;
      
      private var __infoTF2:TextField;
      
      private var __jinhuaBtn:SimpleButton;
      
      private var __cancelBtn:SimpleButton;
      
      private var _block1:GeneralBlock;
      
      private var _block2:GeneralBlock;
      
      private var _armyInfo:ArmyInfo;
      
      private var pos1:Point;
      
      private var pos2:Point;
      
      public function GeneralJinhuaPanel(param1:String, param2:ApplicationDomain = null)
      {
         this.pos1 = new Point(-260.6,-133.65);
         this.pos2 = new Point(55.35,-133.65);
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__valueTF1 = _skin.getChildByName("_valueTF1") as TextField;
         this.__valueTF2 = _skin.getChildByName("_valueTF2") as TextField;
         this.__infoTF1 = _skin.getChildByName("_infoTF1") as TextField;
         this.__infoTF2 = _skin.getChildByName("_infoTF2") as TextField;
         this.__jinhuaBtn = _skin.getChildByName("_jinhuaBtn") as SimpleButton;
         this.__cancelBtn = _skin.getChildByName("_cancelBtn") as SimpleButton;
         this.__valueTF1.text = "";
         this.__valueTF2.text = "";
         this.__infoTF1.text = "";
         this.__infoTF2.text = "";
      }
      
      override protected function initEvent() : void
      {
         this.__jinhuaBtn.addEventListener(MouseEvent.CLICK,this.jinhuaBtnClickHandler);
         this.__cancelBtn.addEventListener(MouseEvent.CLICK,this.cancelBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this._armyInfo = param1 as ArmyInfo;
         if(this._block1 == null)
         {
            this._block1 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
            this._block1.x = this.pos1.x;
            this._block1.y = this.pos1.y;
            addChild(this._block1);
         }
         if(this._block2 == null)
         {
            this._block2 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
            this._block2.x = this.pos2.x;
            this._block2.y = this.pos2.y;
            addChild(this._block2);
         }
         this._block1.initData(this._armyInfo);
         var _loc2_:ArmyInfo = Data.getInstance().getArmyInfo(this._armyInfo.code,this._armyInfo.level,this._armyInfo.evolution + 1,this._armyInfo.feature);
         _loc2_.tianfu = this._armyInfo.tianfu;
         this._block2.initData(_loc2_);
         this.createValue1(this._armyInfo);
         this.createValue2(_loc2_);
         this.createInfo1(this._armyInfo,_loc2_);
         this.createInfo2(this._armyInfo,_loc2_);
         this.checkBtn();
      }
      
      private function createValue1(param1:ArmyInfo) : void
      {
         var _loc2_:String = "";
         _loc2_ += param1.attack + "\n";
         _loc2_ += param1.defense + "\n";
         _loc2_ += param1.hp + "\n";
         _loc2_ += param1.attackDistance + "\n";
         this.__valueTF1.htmlText = _loc2_;
      }
      
      private function createValue2(param1:ArmyInfo) : void
      {
         var _loc2_:String = "";
         _loc2_ += param1.attack + "\n";
         _loc2_ += param1.defense + "\n";
         _loc2_ += param1.hp + "\n";
         _loc2_ += param1.attackDistance + "\n";
         this.__valueTF2.htmlText = _loc2_;
      }
      
      private function createInfo1(param1:ArmyInfo, param2:ArmyInfo) : void
      {
         var _loc3_:* = "";
         _loc3_ += "当前进化等级：" + param1.evolution + "级\n";
         _loc3_ += "需要进化道具：" + Data.getInstance().getAttributes("proto",param1.proto,"name");
         if(RoleModel.getInstance().findBagItem(param1.proto) == true)
         {
            _loc3_ += "<font color=\'#4bea13\'>（已满足）</font>\n";
         }
         else
         {
            _loc3_ += "<font color=\'#FF544C\'>（不满足）</font>\n";
         }
         _loc3_ += "进化成功率：" + Logic.getJinhuaJilv(param1.evolution) * 100 + "%";
         this.__infoTF1.htmlText = _loc3_;
      }
      
      private function createInfo2(param1:ArmyInfo, param2:ArmyInfo) : void
      {
         var _loc3_:* = "";
         _loc3_ += "目标进化等级：" + param2.evolution + "级\n";
         if(RoleModel.getInstance().money < 1000)
         {
            _loc3_ += "需要消耗银子：1000<font color=\'#FF544C\'>（不满足）</font>\n";
         }
         else
         {
            _loc3_ += "需要消耗银子：1000<font color=\'#4bea13\'>（已满足）</font>\n";
         }
         _loc3_ += "进化后全属性增加：" + param2.getAddtion() * 100 + "%";
         this.__infoTF2.htmlText = _loc3_;
      }
      
      private function checkBtn() : *
      {
         if(RoleModel.getInstance().findBagItem(this._armyInfo.proto) == false || RoleModel.getInstance().money < 1000)
         {
            Tools.setDisabled(this.__jinhuaBtn,true);
         }
         else if(this._armyInfo.evolution >= 10)
         {
            Tools.setDisabled(this.__jinhuaBtn,true);
         }
      }
      
      private function jinhuaBtnClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:Object = null;
         if(RoleModel.getInstance().money < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"所需银子不足，无法进化武将。"
            }));
         }
         else if(RoleModel.getInstance().findBagItem(this._armyInfo.proto) == false)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有武将进化道具，无法进化武将。"
            }));
         }
         else
         {
            param1.stopImmediatePropagation();
            _loc2_ = {};
            _loc2_.head = Head.HTTP_NEW_GENERAL_JINHUA;
            _loc2_.agent = Config.AGENT;
            _loc2_.ver = Config.VER;
            _loc2_.token = Config.token;
            _loc2_.roleID = RoleModel.getInstance().roleID;
            _loc2_.userID = RoleModel.getInstance().userID;
            _loc2_.mask = true;
            _loc2_.id = this._armyInfo.id;
            AESController.getInstance().sendJSON(_loc2_,this.jinhuaResponse);
         }
      }
      
      private function jinhuaResponse(param1:Object) : *
      {
         var _loc2_:String = null;
         if(param1.success == true)
         {
            RoleModel.getInstance().money = int(param1.data.money);
            RoleModel.getInstance().delBagItemByID(param1.data.itemID);
            if(param1.data.general != null)
            {
               this._armyInfo.evolution = param1.data.general.evolution;
               this._armyInfo.hp = this._armyInfo.baseHp + this._armyInfo.hpAddtion + this._armyInfo.tianfuHP;
               this._armyInfo.feature = param1.data.general.feature;
               this._armyInfo.skin = Data.getInstance().getAttributes("general",this._armyInfo.code,"skin") + "_" + (this._armyInfo.evolution > 1 ? 1 : 0).toString();
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"武将进化成功!"
               }));
               dispatchEvent(new UIEvent(UIEvent.JINHUA,true));
               if(this._armyInfo.evolution >= 2)
               {
                  _loc2_ = TextFactory.makeJinhua(RoleModel.getInstance().roleName,this._armyInfo);
                  dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                     "type":NetInfoType.SYSTEM,
                     "text":_loc2_
                  }));
               }
            }
            else
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"武将进化失败!"
               }));
            }
            if(this._armyInfo.evolution >= 10)
            {
               dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
            }
            else
            {
               this.initData(this._armyInfo);
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
      
      private function cancelBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
   }
}
