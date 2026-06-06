package game.ui
{
   import com.iflashigame.controller.AESController;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.Bitmap;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.Config;
   import game.events.UIEvent;
   import game.model.Head;
   import game.model.RoleModel;
   
   public class ShopBlock extends BaseUI
   {
       
      
      private var __nameTF:TextField;
      
      private var __oldTF:TextField;
      
      private var __newTF:TextField;
      
      private var __infoTF:TextField;
      
      private var __buyBtn:SimpleButton;
      
      private var _img:Sprite;
      
      private var _money:int;
      
      private var _dianka:int;
      
      private var _exploit:int;
      
      private var _reverence:int;
      
      private var _data:Object;
      
      public function ShopBlock(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__nameTF = _skin.getChildByName("_nameTF") as TextField;
         this.__oldTF = _skin.getChildByName("_oldTF") as TextField;
         this.__newTF = _skin.getChildByName("_newTF") as TextField;
         this.__infoTF = _skin.getChildByName("_infoTF") as TextField;
         this.__buyBtn = _skin.getChildByName("_buyBtn") as SimpleButton;
         this._img = new Sprite();
         this._img.x = 20;
         this._img.y = 23;
         addChild(this._img);
      }
      
      override protected function initEvent() : void
      {
         this.__buyBtn.addEventListener(MouseEvent.CLICK,this.buyBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._data = param1;
         if(param1.count > 1)
         {
            this.__nameTF.htmlText = "<font color=\'#ff3300\'>" + param1.name + "x" + param1.count + "</font>";
         }
         else
         {
            this.__nameTF.htmlText = "<font color=\'#ff3300\'>" + param1.name + "x1</font>";
         }
         if(param1.id == "shop043")
         {
            param1.icon = "proto_libao";
            this.__infoTF.text = "礼包内包含10个克制进阶符、50万银子";
         }
         else
         {
            this.__infoTF.text = param1.desc;
         }
         if(int(param1.payType) == 1)
         {
            this.__oldTF.text = param1.oldPrice + "银子";
            this.__newTF.text = param1.newPrice + "银子";
         }
         else if(int(param1.payType) == 2)
         {
            this.__oldTF.text = param1.oldPrice + "点卡";
            this.__newTF.text = param1.newPrice + "点卡";
         }
         else if(int(param1.payType) == 3)
         {
            this.__oldTF.text = param1.oldPrice + "功勋";
            this.__newTF.text = param1.newPrice + "功勋";
         }
         else if(int(param1.payType) == 4)
         {
            this.__oldTF.text = param1.oldPrice + "声望";
            this.__newTF.text = param1.newPrice + "声望";
         }
         if(this._img.numChildren > 0)
         {
            this._img.removeChildAt(0);
         }
         var _loc2_:Class = ApplicationDomain.currentDomain.getDefinition(param1.icon) as Class;
         var _loc3_:Bitmap = new Bitmap(new _loc2_());
         this._img.addChild(_loc3_);
      }
      
      private function buyBtnClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc4_:* = null;
         var _loc5_:* = null;
         param1.stopImmediatePropagation();
         switch(int(this._data.payType))
         {
            case 1:
               if(this._money < int(this._data.newPrice))
               {
                  dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                     "type":0,
                     "text":"银子不足，无法购买此商品。"
                  }));
               }
               else
               {
                  _loc2_ = "购买" + this._data.name + "*" + this._data.count + "需要花费" + this._data.newPrice + "银子，是否确认购买？";
                  dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                     "type":1,
                     "text":_loc2_,
                     "fun":this.pay
                  }));
               }
               break;
            case 2:
               if(this._dianka < int(this._data.newPrice))
               {
                  dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                     "type":0,
                     "text":"点卡不足，无法购买此商品。"
                  }));
               }
               else
               {
                  _loc3_ = "购买" + this._data.name + "*" + this._data.count + "需要花费" + this._data.newPrice + "点卡，是否确认购买？";
                  dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                     "type":1,
                     "text":_loc3_,
                     "fun":this.pay
                  }));
               }
               break;
            case 3:
               if(this._exploit < int(this._data.newPrice))
               {
                  dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                     "type":0,
                     "text":"功勋不足，无法购买此商品。"
                  }));
               }
               else
               {
                  _loc4_ = "购买" + this._data.name + "*" + this._data.count + "需要花费" + this._data.newPrice + "功勋，是否确认购买？";
                  dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                     "type":1,
                     "text":_loc4_,
                     "fun":this.pay
                  }));
               }
               break;
            case 4:
               if(this._reverence < int(this._data.newPrice))
               {
                  dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                     "type":0,
                     "text":"声望不足，无法购买此商品。"
                  }));
               }
               else
               {
                  _loc5_ = "购买" + this._data.name + "*" + this._data.count + "需要花费" + this._data.newPrice + "声望，是否确认购买？";
                  dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                     "type":1,
                     "text":_loc5_,
                     "fun":this.pay
                  }));
               }
         }
      }
      
      private function pay() : *
      {
         var _loc1_:int = RoleModel.getInstance().getBagItemCount(this._data.code);
         if(_loc1_ + int(this._data.count) > 99)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"物品叠加数量超过上限，无法购买！"
            }));
            return;
         }
         this.sendToHttpNew();
      }
      
      public function checkBtn(param1:int, param2:int, param3:int, param4:int) : *
      {
         this._money = param1;
         this._dianka = param2;
         this._exploit = param3;
         this._reverence = param4;
         switch(int(this._data.payType))
         {
            case 1:
               if(param1 < int(this._data.newPrice))
               {
                  Tools.setDisabled(this.__buyBtn,true);
               }
               else
               {
                  Tools.setDisabled(this.__buyBtn,false);
               }
               break;
            case 2:
               if(param2 < int(this._data.newPrice))
               {
                  Tools.setDisabled(this.__buyBtn,true);
               }
               else
               {
                  Tools.setDisabled(this.__buyBtn,false);
               }
               break;
            case 3:
               if(param3 < int(this._data.newPrice))
               {
                  Tools.setDisabled(this.__buyBtn,true);
               }
               else
               {
                  Tools.setDisabled(this.__buyBtn,false);
               }
               break;
            case 4:
               if(param4 < int(this._data.newPrice))
               {
                  Tools.setDisabled(this.__buyBtn,true);
               }
               else
               {
                  Tools.setDisabled(this.__buyBtn,false);
               }
         }
      }
      
      private function sendToHttpNew() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_BUYITEM;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         _loc1_.shopID = this._data.id;
         _loc1_.mask = true;
         AESController.getInstance().sendJSON(_loc1_,this.buyItemResponse);
      }
      
      private function buyItemResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            RoleModel.getInstance().money = param1.data.money;
            RoleModel.getInstance().dianka = param1.data.dianka;
            RoleModel.getInstance().exploit = param1.data.exploit;
            RoleModel.getInstance().reverence = param1.data.reverence;
            RoleModel.getInstance().modiBagItem(param1.data.item.id,param1.data.item.code,param1.data.item.count);
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"物品购买成功，已进入你的背包。"
            }));
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
