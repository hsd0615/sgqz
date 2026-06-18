package game.ui
{
   import com.iflashigame.controller.AESController;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
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

      // 购买前余额快照，用于检测服务端是否正确扣费
      private var _preMoney:int;
      private var _preDianka:int;
      private var _preExploit:int;
      private var _preReverence:int;

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
         try {
            var _iconClass:Class = ApplicationDomain.currentDomain.getDefinition(param1.icon) as Class;
            var _bmp:Bitmap = new Bitmap(new _iconClass() as BitmapData);
            this._img.addChild(_bmp);
         } catch(_e:Error) {
            // 图标类不存在, 绘制程序化占位图标(装备等新增物品)
            this._img.addChild(createPlaceholderIcon(param1.icon));
         }
      }

      private function createPlaceholderIcon(iconName:String) : DisplayObject
      {
         var _s:Sprite = new Sprite();
         var _g:Shape = new Shape();
         var _isWeapon:Boolean = (iconName.indexOf("proto_4_1") >= 0);
         var _isArmor:Boolean = (iconName.indexOf("proto_4_11") >= 0 || iconName.indexOf("proto_4_12") >= 0 || iconName.indexOf("proto_4_13") >= 0 || iconName.indexOf("proto_4_14") >= 0 || iconName.indexOf("proto_4_15") >= 0);
         // 绘制40x40图标
         if(_isWeapon)
         {
            // 剑形: 红色剑刃+金色剑柄
            _g.graphics.beginFill(0xCC3333);
            _g.graphics.moveTo(20,2); _g.graphics.lineTo(26,6); _g.graphics.lineTo(26,28);
            _g.graphics.lineTo(30,34); _g.graphics.lineTo(20,32); _g.graphics.lineTo(10,34);
            _g.graphics.lineTo(14,28); _g.graphics.lineTo(14,6); _g.graphics.lineTo(20,2);
            _g.graphics.endFill();
            _g.graphics.beginFill(0xC8A84E);
            _g.graphics.drawRoundRect(15,34,10,6,2,2);
            _g.graphics.endFill();
         }
         else if(_isArmor)
         {
            // 盾形: 蓝色盾牌
            _g.graphics.beginFill(0x3366AA);
            _g.graphics.moveTo(20,2); _g.graphics.lineTo(36,8); _g.graphics.lineTo(36,24);
            _g.graphics.lineTo(20,38); _g.graphics.lineTo(4,24); _g.graphics.lineTo(4,8);
            _g.graphics.lineTo(20,2);
            _g.graphics.endFill();
            _g.graphics.beginFill(0xFFD700);
            _g.graphics.drawCircle(20,18,5);
            _g.graphics.endFill();
         }
         else
         {
            // 宝石形: 绿色菱形
            _g.graphics.beginFill(0x33AA55);
            _g.graphics.moveTo(20,2); _g.graphics.lineTo(36,20);
            _g.graphics.lineTo(20,38); _g.graphics.lineTo(4,20);
            _g.graphics.lineTo(20,2);
            _g.graphics.endFill();
            _g.graphics.beginFill(0xFFFFFF,0.5);
            _g.graphics.drawCircle(16,14,4);
            _g.graphics.endFill();
         }
         _s.addChild(_g);
         return _s;
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
         // 保存购买前余额快照（用于检测服务端是否正确扣费）
         this._preMoney = RoleModel.getInstance().money;
         this._preDianka = RoleModel.getInstance().dianka;
         this._preExploit = RoleModel.getInstance().exploit;
         this._preReverence = RoleModel.getInstance().reverence;
         this._logPurchase("BEFORE_SEND");
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
         var _payType:int = int(this._data.payType);
         var _price:int = int(this._data.newPrice);
         _loc1_.head = Head.HTTP_NEW_BUYITEM;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         _loc1_.shopID = this._data.id;
         _loc1_.code = this._data.code;
         _loc1_.count = this._data.count;
         _loc1_.price = _price;
         _loc1_.payType = _payType;
         if(_payType == 1) _loc1_.money = _price;
         else if(_payType == 2) _loc1_.dianka = _price;
         else if(_payType == 3) _loc1_.exploit = _price;
         else if(_payType == 4) _loc1_.reverence = _price;
         _loc1_.mask = true;
         AESController.getInstance().sendJSON(_loc1_,this.buyItemResponse);
      }

      private function buyItemResponse(param1:Object) : *
      {
         var _payType:int = int(this._data.payType);
         var _price:int = int(this._data.newPrice);

         // 写入服务端原始响应到日志
         this._logResponse("SERVER_RESPONSE",param1);

         if(param1.success == true)
         {
            // 读取服务端返回的余额
            var svrMoney:int = param1.data.money != undefined ? int(param1.data.money) : -1;
            var svrDianka:int = param1.data.dianka != undefined ? int(param1.data.dianka) : -1;
            var svrExploit:int = param1.data.exploit != undefined ? int(param1.data.exploit) : -1;
            var svrReverence:int = param1.data.reverence != undefined ? int(param1.data.reverence) : -1;

            // 核心逻辑：检测服务端是否正确扣费
            // 如果服务端返回的余额 < 购买前余额，说明服务端已正确扣费，以服务端为准
            // 否则说明服务端未扣费（旧版服务端），客户端本地扣费

            // === 银子 ===
            if(svrMoney >= 0 && svrMoney < this._preMoney)
            {
               // 服务端已扣费，以服务端为准
               RoleModel.getInstance().money = svrMoney;
               this._logPurchase("MONEY_FROM_SERVER",svrMoney);
            }
            else if(_payType == 1)
            {
               // 服务端未扣费（或余额没变），本地扣费
               var localMoney:int = this._preMoney - _price;
               RoleModel.getInstance().money = localMoney;
               this._logPurchase("MONEY_LOCAL_FALLBACK",localMoney,this._preMoney,svrMoney);
            }
            else if(svrMoney >= 0)
            {
               // 非银子支付，同步服务端银子值
               RoleModel.getInstance().money = svrMoney;
            }

            // === 点卡 ===
            if(svrDianka >= 0 && svrDianka < this._preDianka)
            {
               RoleModel.getInstance().dianka = svrDianka;
               this._logPurchase("DIANKA_FROM_SERVER",svrDianka);
            }
            else if(_payType == 2)
            {
               var localDianka:int = this._preDianka - _price;
               RoleModel.getInstance().dianka = localDianka;
               this._logPurchase("DIANKA_LOCAL_FALLBACK",localDianka);
            }
            else if(svrDianka >= 0)
            {
               RoleModel.getInstance().dianka = svrDianka;
            }

            // === 功勋 ===
            if(svrExploit >= 0 && svrExploit < this._preExploit)
            {
               RoleModel.getInstance().exploit = svrExploit;
               this._logPurchase("EXPLOIT_FROM_SERVER",svrExploit);
            }
            else if(_payType == 3)
            {
               var localExploit:int = this._preExploit - _price;
               RoleModel.getInstance().exploit = localExploit;
               this._logPurchase("EXPLOIT_LOCAL_FALLBACK",localExploit);
            }
            else if(svrExploit >= 0)
            {
               RoleModel.getInstance().exploit = svrExploit;
            }

            // === 声望 ===
            if(svrReverence >= 0 && svrReverence < this._preReverence)
            {
               RoleModel.getInstance().reverence = svrReverence;
               this._logPurchase("REVERENCE_FROM_SERVER",svrReverence);
            }
            else if(_payType == 4)
            {
               var localReverence:int = this._preReverence - _price;
               RoleModel.getInstance().reverence = localReverence;
               this._logPurchase("REVERENCE_LOCAL_FALLBACK",localReverence);
            }
            else if(svrReverence >= 0)
            {
               RoleModel.getInstance().reverence = svrReverence;
            }

            // 添加道具到背包
            RoleModel.getInstance().modiBagItem(int(param1.data.item.id),param1.data.item.code,int(param1.data.item.count));

            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"物品购买成功，已进入你的背包。"
            }));
            RoleModel.getInstance().throttleSave();

            this._logPurchase("AFTER_PURCHASE");
         }
         else
         {
            this._logResponse("PURCHASE_FAILED",param1);
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }

      // ========== 调试日志 ==========

      private function _logPurchase(param1:String, param2:int = -1, param3:int = -1, param4:int = -1) : void
      {
         try
         {
            var _loc1_:File = File.applicationStorageDirectory.resolvePath("shop_debug.txt");
            var _loc2_:FileStream = new FileStream();
            _loc2_.open(_loc1_,FileMode.APPEND);
            var _loc3_:* = new Date().toString() + " [" + param1 + "] ";
            _loc3_ += "shopID=" + this._data.id + " code=" + this._data.code + " ";
            _loc3_ += "payType=" + int(this._data.payType) + " price=" + int(this._data.newPrice) + " count=" + int(this._data.count) + " ";
            _loc3_ += "preMoney=" + this._preMoney + " preDianka=" + this._preDianka + " ";
            _loc3_ += "nowMoney=" + RoleModel.getInstance().money + " nowDianka=" + RoleModel.getInstance().dianka + " ";
            _loc3_ += "nowExploit=" + RoleModel.getInstance().exploit + " nowReverence=" + RoleModel.getInstance().reverence;
            if(param2 >= 0) _loc3_ += " val=" + param2;
            if(param3 >= 0) _loc3_ += " pre=" + param3;
            if(param4 >= 0) _loc3_ += " svr=" + param4;
            _loc3_ += "\n";
            _loc2_.writeUTFBytes(_loc3_);
            _loc2_.close();
         }
         catch(_e:Error)
         {
            trace("ShopBlock debug log error: " + _e.message);
         }
      }

      private function _logResponse(param1:String, param2:Object) : void
      {
         try
         {
            var _loc1_:File = File.applicationStorageDirectory.resolvePath("shop_debug.txt");
            var _loc2_:FileStream = new FileStream();
            _loc2_.open(_loc1_,FileMode.APPEND);
            var _loc3_:* = new Date().toString() + " [" + param1 + "] ";
            _loc3_ += "success=" + param2.success + " ";
            if(param2.data)
            {
               _loc3_ += "svrMoney=" + param2.data.money + " svrDianka=" + param2.data.dianka + " ";
               _loc3_ += "svrExploit=" + param2.data.exploit + " svrReverence=" + param2.data.reverence + " ";
               if(param2.data.item) _loc3_ += "itemCode=" + param2.data.item.code + " itemCount=" + param2.data.item.count + " itemId=" + param2.data.item.id;
            }
            if(param2.message) _loc3_ += " msg=" + param2.message;
            _loc3_ += "\n";
            _loc2_.writeUTFBytes(_loc3_);
            _loc2_.close();
         }
         catch(_e:Error)
         {
            trace("ShopBlock debug log error: " + _e.message);
         }
      }
   }
}
