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
   
   public class Guoqing1 extends BaseUI
   {
       
      
      private var __txt:TextField;
      
      private var __select1:MovieClip;
      
      private var __select2:MovieClip;
      
      private var __okBtn:SimpleButton;
      
      private var _select:int = 0;
      
      private var _current:int = 0;
      
      public function Guoqing1(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__txt = _skin.getChildByName("_txt") as TextField;
         this.__select1 = _skin.getChildByName("_select1") as MovieClip;
         this.__select2 = _skin.getChildByName("_select2") as MovieClip;
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this.__select1.buttonMode = true;
         this.__select2.buttonMode = true;
      }
      
      override protected function initEvent() : void
      {
         this.__select1.addEventListener(MouseEvent.CLICK,this.select1ClickHandler);
         this.__select2.addEventListener(MouseEvent.CLICK,this.select2ClickHandler);
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
         trace("Guoqing1",param1.general1,param1.general2);
         if(param1.general1 == null)
         {
            param1.general1 = "";
         }
         if(param1.general2 == null)
         {
            param1.general2 = "";
         }
         if(param1.general1 != "" && param1.general2 == "")
         {
            trace("可以选貂蝉");
            if(RoleModel.getInstance().getSoldierByCode(param1.general1) != null)
            {
               this._current = 0;
               this._select = this._current;
               this.__select2.gotoAndStop(2);
               Tools.setDisabled(this.__select1,true,false);
            }
            else
            {
               this._current = 1;
               this._select = this._current;
               this.__select1.gotoAndStop(2);
            }
         }
         else if(param1.general1 == "" && param1.general2 != "")
         {
            if(RoleModel.getInstance().getSoldierByCode(param1.general2) != null)
            {
               this._current = 0;
               this._select = this._current;
               this.__select2.gotoAndStop(2);
               Tools.setDisabled(this.__select1,true,false);
            }
            else
            {
               this._current = 2;
               this._select = this._current;
               this.__select1.gotoAndStop(2);
            }
         }
         else if(param1.general1 == "" && param1.general2 == "")
         {
            this._current = 0;
            this._select = this._current;
            this.__select2.gotoAndStop(2);
            Tools.setDisabled(this.__select1,true,false);
         }
      }
      
      private function select1ClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this.__select1.currentFrame == 2)
         {
            return;
         }
         this.__select2.gotoAndStop(1);
         this.__select1.gotoAndStop(2);
         this._select = this._current;
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
         this._select = 0;
      }
      
      private function okBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.LING_GUOQING,true,{"select":this._select}));
      }
   }
}
