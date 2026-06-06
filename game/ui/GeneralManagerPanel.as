package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.events.UIEvent;
   import game.model.ArmyInfo;
   import game.model.RoleModel;
   
   public class GeneralManagerPanel extends BaseUI
   {
       
      
      private var __moneyTF:TextField;
      
      private var __exploitTF:TextField;
      
      private var __preBtn:SimpleButton;
      
      private var __nextBtn:SimpleButton;
      
      private var __pageTF:TextField;
      
      private var __closeBtn:SimpleButton;
      
      private var _pos1:Point;
      
      private var _pos2:Point;
      
      private var _pos3:Point;
      
      private var _pos4:Point;
      
      private var _block1:GeneralFullInfoBlock;
      
      private var _block2:GeneralFullInfoBlock;
      
      private var _block3:GeneralFullInfoBlock;
      
      private var _block4:GeneralFullInfoBlock;
      
      private var _currentPage:int;
      
      private var _maxPage:int;
      
      private var _roleModel:RoleModel;
      
      private var _army:Vector.<ArmyInfo>;
      
      public function GeneralManagerPanel(param1:String, param2:ApplicationDomain = null)
      {
         this._pos1 = new Point(-338.55,-204.65);
         this._pos2 = new Point(5.4,-204.65);
         this._pos3 = new Point(-338.55,-29.65);
         this._pos4 = new Point(5.4,-29.65);
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__moneyTF = _skin.getChildByName("_moneyTF") as TextField;
         this.__exploitTF = _skin.getChildByName("_exploitTF") as TextField;
         this.__preBtn = _skin.getChildByName("_preBtn") as SimpleButton;
         this.__nextBtn = _skin.getChildByName("_nextBtn") as SimpleButton;
         this.__pageTF = _skin.getChildByName("_pageTF") as TextField;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
      }
      
      override protected function initEvent() : void
      {
         this.__preBtn.addEventListener(MouseEvent.CLICK,this.preBtnClickHandler);
         this.__nextBtn.addEventListener(MouseEvent.CLICK,this.nextBtnClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this._roleModel = param1.roleModel;
         this._army = param1.army;
         if(this._block1 == null)
         {
            this._block1 = new GeneralFullInfoBlock(SkinCode.GENERAL_FULLINFO_BLOCK);
            addChild(this._block1);
         }
         if(this._block2 == null)
         {
            this._block2 = new GeneralFullInfoBlock(SkinCode.GENERAL_FULLINFO_BLOCK);
            addChild(this._block2);
         }
         if(this._block3 == null)
         {
            this._block3 = new GeneralFullInfoBlock(SkinCode.GENERAL_FULLINFO_BLOCK);
            addChild(this._block3);
         }
         if(this._block4 == null)
         {
            this._block4 = new GeneralFullInfoBlock(SkinCode.GENERAL_FULLINFO_BLOCK);
            addChild(this._block4);
         }
         this._block1.x = this._pos1.x;
         this._block1.y = this._pos1.y;
         this._block2.x = this._pos2.x;
         this._block2.y = this._pos2.y;
         this._block3.x = this._pos1.x;
         this._block3.y = this._pos3.y;
         this._block4.x = this._pos4.x;
         this._block4.y = this._pos4.y;
         this._currentPage = 1;
         this._maxPage = param1.army.length % 4 == 0 ? int(param1.army.length / 4) : int(param1.army.length / 4) + 1;
         this.flush();
      }
      
      public function flush() : *
      {
         this._block1.visible = false;
         this._block2.visible = false;
         this._block3.visible = false;
         this._block4.visible = false;
         this.__pageTF.text = this._currentPage + "/" + this._maxPage;
         this.__moneyTF.text = this._roleModel.money.toString();
         this.__exploitTF.text = this._roleModel.exploit.toString();
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
         var _loc1_:int = (this._currentPage - 1) * 4;
         this._block1.initData({
            "roleModel":this._roleModel,
            "armyInfo":this._army[_loc1_]
         });
         this._block1.visible = true;
         _loc1_++;
         if(_loc1_ >= this._army.length)
         {
            return;
         }
         this._block2.initData({
            "roleModel":this._roleModel,
            "armyInfo":this._army[_loc1_]
         });
         this._block2.visible = true;
         _loc1_++;
         if(_loc1_ >= this._army.length)
         {
            return;
         }
         this._block3.initData({
            "roleModel":this._roleModel,
            "armyInfo":this._army[_loc1_]
         });
         this._block3.visible = true;
         _loc1_++;
         if(_loc1_ >= this._army.length)
         {
            return;
         }
         this._block4.initData({
            "roleModel":this._roleModel,
            "armyInfo":this._army[_loc1_]
         });
         this._block4.visible = true;
         _loc1_++;
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
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
   }
}
