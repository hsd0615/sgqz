package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.events.UIEvent;
   import game.model.RoleModel;
   
   public class Guoqing2 extends BaseUI
   {
       
      
      private var __txt:TextField;
      
      private var __select1:MovieClip;
      
      private var __select2:MovieClip;
      
      private var __select3:MovieClip;
      
      private var __select4:MovieClip;
      
      private var __okBtn:SimpleButton;
      
      private var _select:int;
      
      public function Guoqing2(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__txt = _skin.getChildByName("_txt") as TextField;
         this.__select1 = _skin.getChildByName("_select1") as MovieClip;
         this.__select2 = _skin.getChildByName("_select2") as MovieClip;
         this.__select3 = _skin.getChildByName("_select3") as MovieClip;
         this.__select4 = _skin.getChildByName("_select4") as MovieClip;
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this.__select1.buttonMode = true;
         this.__select2.buttonMode = true;
         this.__select3.buttonMode = true;
         this.__select4.buttonMode = true;
      }
      
      override protected function initEvent() : void
      {
         this.__select1.addEventListener(MouseEvent.CLICK,this.select1ClickHandler);
         this.__select2.addEventListener(MouseEvent.CLICK,this.select2ClickHandler);
         this.__select3.addEventListener(MouseEvent.CLICK,this.select3ClickHandler);
         this.__select4.addEventListener(MouseEvent.CLICK,this.select4ClickHandler);
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.okBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         var _loc2_:* = "您在国庆献礼活动中充值累计超过" + param1.rmb + "元\n奖励：";
         if(int(param1.money) != 0)
         {
            _loc2_ += param1.money + "银子 ";
         }
         if(int(param1.exploit) != 0)
         {
            _loc2_ += param1.exploit + "功勋 ";
         }
         if(int(param1.dianka) != 0)
         {
            _loc2_ += param1.dianka + "点卡 ";
         }
         this.__txt.text = _loc2_;
         if(param1.general1 != "" && param1.general2 != "")
         {
            if(RoleModel.getInstance().getSoldierByCode(param1.general1) != null)
            {
               this.__select1.gotoAndStop(1);
               Tools.setDisabled(this.__select1,true,false);
               this.__select2.gotoAndStop(2);
            }
            else
            {
               this.__select1.gotoAndStop(2);
            }
            if(RoleModel.getInstance().getSoldierByCode(param1.general2) != null)
            {
               this.__select3.gotoAndStop(1);
               Tools.setDisabled(this.__select3,true,false);
               this.__select4.gotoAndStop(2);
            }
            else
            {
               this.__select3.gotoAndStop(3);
            }
         }
         else if(param1.general1 != "" && param1.general2 == "")
         {
            this.__select1.gotoAndStop(2);
            this.__select3.gotoAndStop(1);
            Tools.setDisabled(this.__select3,true,false);
         }
         else if(param1.general1 == "" && param1.general2 != "")
         {
            this.__select3.gotoAndStop(2);
            this.__select1.gotoAndStop(1);
            Tools.setDisabled(this.__select1,true,false);
         }
         else if(param1.general1 == "" && param1.general2 == "")
         {
            this.__select1.gotoAndStop(1);
            this.__select3.gotoAndStop(1);
            Tools.setDisabled(this.__select1,true,false);
            Tools.setDisabled(this.__select3,true,false);
         }
      }
      
      private function select1ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this.__select1.currentFrame == 2)
         {
            return;
         }
         this.__select1.gotoAndStop(2);
         this.__select2.gotoAndStop(1);
      }
      
      private function select2ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this.__select2.currentFrame == 2)
         {
            return;
         }
         this.__select1.gotoAndStop(1);
         this.__select2.gotoAndStop(2);
      }
      
      private function select3ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this.__select3.currentFrame == 2)
         {
            return;
         }
         this.__select3.gotoAndStop(2);
         this.__select4.gotoAndStop(1);
      }
      
      private function select4ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this.__select4.currentFrame == 2)
         {
            return;
         }
         this.__select3.gotoAndStop(1);
         this.__select4.gotoAndStop(2);
      }
      
      private function okBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this.__select1.currentFrame == 2 && this.__select3.currentFrame == 2)
         {
            this._select = 3;
         }
         else if(this.__select1.currentFrame == 2)
         {
            this._select = 1;
         }
         else if(this.__select3.currentFrame == 2)
         {
            this._select = 2;
         }
         else
         {
            this._select = 0;
         }
         dispatchEvent(new UIEvent(UIEvent.LING_GUOQING,true,{"select":this._select}));
      }
   }
}
