package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFieldAutoSize;
   import game.Data;
   import game.events.UIEvent;
   import game.model.RoleModel;
   
   public class ShopPanel extends BaseUI
   {
       
      
      private var __danyaoLabel:MovieClip;
      
      private var __jinhuaLabel:MovieClip;
      
      private var __junshijiLabel:MovieClip;
      
      private var __wujiangjiLabel:MovieClip;
      
      private var __qitaLabel:MovieClip;

      private var __diankaTF:TextField;
      
      private var __moneyTF:TextField;
      
      private var __preBtn:SimpleButton;
      
      private var __nextBtn:SimpleButton;
      
      private var __pageTF:TextField;
      
      private var __chongzhiBtn:SimpleButton;
      
      private var __closeBtn:SimpleButton;
      
      private var _block1:ShopBlock;
      
      private var _block2:ShopBlock;
      
      private var _block3:ShopBlock;
      
      private var _block4:ShopBlock;
      
      private var _block5:ShopBlock;
      
      private var _block6:ShopBlock;
      
      private var _block7:ShopBlock;
      
      private var _block8:ShopBlock;
      
      private var _currentPage:int;
      
      private var _maxPage:int;
      
      private var _currentLabel:int;
      
      private var _arr:Array;
      
      public function ShopPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__danyaoLabel = _skin.getChildByName("_danyaoLabel") as MovieClip;
         this.__jinhuaLabel = _skin.getChildByName("_jinhuaLabel") as MovieClip;
         this.__junshijiLabel = _skin.getChildByName("_junshijiLabel") as MovieClip;
         this.__wujiangjiLabel = _skin.getChildByName("_wujiangjiLabel") as MovieClip;
         this.__qitaLabel = _skin.getChildByName("_qitaLabel") as MovieClip;
         this.__diankaTF = _skin.getChildByName("_diankaTF") as TextField;
         this.__moneyTF = _skin.getChildByName("_moneyTF") as TextField;
         this.__preBtn = _skin.getChildByName("_preBtn") as SimpleButton;
         this.__nextBtn = _skin.getChildByName("_nextBtn") as SimpleButton;
         this.__pageTF = _skin.getChildByName("_pageTF") as TextField;
         this.__chongzhiBtn = _skin.getChildByName("_chongzhiBtn") as SimpleButton;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__danyaoLabel.buttonMode = true;
         this.__jinhuaLabel.buttonMode = true;
         this.__junshijiLabel.buttonMode = true;
         this.__wujiangjiLabel.buttonMode = true;
         this.__qitaLabel.buttonMode = true;
         this.createBlock();
      }
      
      private function setLabel(param1:int) : *
      {
         this.__danyaoLabel.gotoAndStop(2);
         this.__jinhuaLabel.gotoAndStop(2);
         this.__junshijiLabel.gotoAndStop(2);
         this.__wujiangjiLabel.gotoAndStop(2);
         this.__qitaLabel.gotoAndStop(2);
         switch(param1)
         {
            case 1:
               this.__danyaoLabel.gotoAndStop(1);
               break;
            case 2:
               this.__jinhuaLabel.gotoAndStop(1);
               break;
            case 3:
               this.__junshijiLabel.gotoAndStop(1);
               break;
            case 4:
               this.__wujiangjiLabel.gotoAndStop(1);
               break;
            case 5:
               this.__qitaLabel.gotoAndStop(1);
               break;
         }
         this._currentLabel = param1;
         this._arr = Data.getInstance().getShopData(this._currentLabel);
      }
      
      private function createBlock() : *
      {
         if(this._block1 == null)
         {
            this._block1 = new ShopBlock(SkinCode.SHOP_BLOCK);
            addChild(this._block1);
         }
         if(this._block2 == null)
         {
            this._block2 = new ShopBlock(SkinCode.SHOP_BLOCK);
            addChild(this._block2);
         }
         if(this._block3 == null)
         {
            this._block3 = new ShopBlock(SkinCode.SHOP_BLOCK);
            addChild(this._block3);
         }
         if(this._block4 == null)
         {
            this._block4 = new ShopBlock(SkinCode.SHOP_BLOCK);
            addChild(this._block4);
         }
         if(this._block5 == null)
         {
            this._block5 = new ShopBlock(SkinCode.SHOP_BLOCK);
            addChild(this._block5);
         }
         if(this._block6 == null)
         {
            this._block6 = new ShopBlock(SkinCode.SHOP_BLOCK);
            addChild(this._block6);
         }
         if(this._block7 == null)
         {
            this._block7 = new ShopBlock(SkinCode.SHOP_BLOCK);
            addChild(this._block7);
         }
         if(this._block8 == null)
         {
            this._block8 = new ShopBlock(SkinCode.SHOP_BLOCK);
            addChild(this._block8);
         }
         this._block1.x = this._block5.x = -340.95;
         this._block2.x = this._block6.x = -167.65;
         this._block3.x = this._block7.x = 5.65;
         this._block4.x = this._block8.x = 178.95;
         this._block1.y = this._block2.y = this._block3.y = this._block4.y = -175.55;
         this._block5.y = this._block6.y = this._block7.y = this._block8.y = -12.55;
      }
      
      override protected function initEvent() : void
      {
         this.__danyaoLabel.addEventListener(MouseEvent.CLICK,this.danyaoLabelClickHandler);
         this.__jinhuaLabel.addEventListener(MouseEvent.CLICK,this.jinhuaLabelClickHandler);
         this.__junshijiLabel.addEventListener(MouseEvent.CLICK,this.junshijiLabelClickHandler);
         this.__wujiangjiLabel.addEventListener(MouseEvent.CLICK,this.wujiangjiLabelClickHandler);
         this.__qitaLabel.addEventListener(MouseEvent.CLICK,this.qitaLabelClickHandler);
         this.__chongzhiBtn.addEventListener(MouseEvent.CLICK,this.chongzhiBtnClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this.__preBtn.addEventListener(MouseEvent.CLICK,this.preBtnClickHandler);
         this.__nextBtn.addEventListener(MouseEvent.CLICK,this.nextBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this.setLabel(param1.label);
         this._currentPage = 1;
         if(this._arr == null)
         {
            this._maxPage = 1;
         }
         else
         {
            this._maxPage = this._arr.length % 8 == 0 ? int(this._arr.length / 8) : int(this._arr.length / 8) + 1;
         }
         this.flush();
      }
      
      public function flush() : *
      {
         this._block1.visible = false;
         this._block2.visible = false;
         this._block3.visible = false;
         this._block4.visible = false;
         this._block5.visible = false;
         this._block6.visible = false;
         this._block7.visible = false;
         this._block8.visible = false;
         this.__pageTF.text = this._currentPage + "/" + this._maxPage;
         this.__moneyTF.text = RoleModel.getInstance().money.toString();
         this.__diankaTF.text = RoleModel.getInstance().dianka.toString();
         if(this._currentPage == 1)
         {
            Tools.setDisabled(this.__preBtn,true);
         }
         else
         {
            Tools.setDisabled(this.__preBtn,false);
         }
         if(this._currentPage == this._maxPage)
         {
            Tools.setDisabled(this.__nextBtn,true);
         }
         else
         {
            Tools.setDisabled(this.__nextBtn,false);
         }
         if(this._arr == null)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"该物品即将开放，敬请期待!"
            }));
            return;
         }
         var _loc1_:int = (this._currentPage - 1) * 8;
         this._block1.initData(this._arr[_loc1_]);
         this._block1.visible = true;
         this._block1.checkBtn(RoleModel.getInstance().money,RoleModel.getInstance().dianka,RoleModel.getInstance().exploit,RoleModel.getInstance().reverence);
         _loc1_++;
         if(_loc1_ >= this._arr.length)
         {
            return;
         }
         this._block2.initData(this._arr[_loc1_]);
         this._block2.visible = true;
         this._block2.checkBtn(RoleModel.getInstance().money,RoleModel.getInstance().dianka,RoleModel.getInstance().exploit,RoleModel.getInstance().reverence);
         _loc1_++;
         if(_loc1_ >= this._arr.length)
         {
            return;
         }
         this._block3.initData(this._arr[_loc1_]);
         this._block3.visible = true;
         this._block3.checkBtn(RoleModel.getInstance().money,RoleModel.getInstance().dianka,RoleModel.getInstance().exploit,RoleModel.getInstance().reverence);
         _loc1_++;
         if(_loc1_ >= this._arr.length)
         {
            return;
         }
         this._block4.initData(this._arr[_loc1_]);
         this._block4.visible = true;
         this._block4.checkBtn(RoleModel.getInstance().money,RoleModel.getInstance().dianka,RoleModel.getInstance().exploit,RoleModel.getInstance().reverence);
         _loc1_++;
         if(_loc1_ >= this._arr.length)
         {
            return;
         }
         this._block5.initData(this._arr[_loc1_]);
         this._block5.visible = true;
         this._block5.checkBtn(RoleModel.getInstance().money,RoleModel.getInstance().dianka,RoleModel.getInstance().exploit,RoleModel.getInstance().reverence);
         _loc1_++;
         if(_loc1_ >= this._arr.length)
         {
            return;
         }
         this._block6.initData(this._arr[_loc1_]);
         this._block6.visible = true;
         this._block6.checkBtn(RoleModel.getInstance().money,RoleModel.getInstance().dianka,RoleModel.getInstance().exploit,RoleModel.getInstance().reverence);
         _loc1_++;
         if(_loc1_ >= this._arr.length)
         {
            return;
         }
         this._block7.initData(this._arr[_loc1_]);
         this._block7.visible = true;
         this._block7.checkBtn(RoleModel.getInstance().money,RoleModel.getInstance().dianka,RoleModel.getInstance().exploit,RoleModel.getInstance().reverence);
         _loc1_++;
         if(_loc1_ >= this._arr.length)
         {
            return;
         }
         this._block8.initData(this._arr[_loc1_]);
         this._block8.visible = true;
         this._block8.checkBtn(RoleModel.getInstance().money,RoleModel.getInstance().dianka,RoleModel.getInstance().exploit,RoleModel.getInstance().reverence);
         _loc1_++;
      }
      
      private function danyaoLabelClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.initData({"label":1});
      }
      
      private function jinhuaLabelClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.initData({"label":2});
      }
      
      private function junshijiLabelClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.initData({"label":3});
      }
      
      private function wujiangjiLabelClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.initData({"label":4});
      }
      
      private function qitaLabelClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.initData({"label":5});
      }

      private function chongzhiBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CHONGZHI_CLICK,true));
      }
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
      
      private function preBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         --this._currentPage;
         this.flush();
      }
      
      private function nextBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         ++this._currentPage;
         this.flush();
      }
   }
}
