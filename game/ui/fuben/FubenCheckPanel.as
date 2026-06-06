package game.ui.fuben
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.events.UIEvent;
   import game.fuben.XiongnuConfig;
   import game.model.RoleModel;
   
   public class FubenCheckPanel extends BaseUI
   {
      
      private static const COUNT:int = 6;
       
      
      private var __tf:TextField;
      
      private var __adjustBtn:SimpleButton;
      
      private var __okBtn:SimpleButton;
      
      private var __returnBtn:SimpleButton;
      
      public function FubenCheckPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__tf = _skin.getChildByName("_tf") as TextField;
         this.__adjustBtn = _skin.getChildByName("_adjustBtn") as SimpleButton;
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this.__returnBtn = _skin.getChildByName("_returnBtn") as SimpleButton;
      }
      
      override protected function initEvent() : void
      {
         this.__adjustBtn.addEventListener(MouseEvent.CLICK,this.adjustBtnClickHandler);
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.okBtnClickHandler);
         this.__returnBtn.addEventListener(MouseEvent.CLICK,this.returnBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this.__tf.text = "袭杀匈奴（副本）每天可挑战次数为" + COUNT + "次， 你当前已挑战次数为 " + (COUNT - int(param1.count)) + " 次，剩余可挑战次数为 " + param1.count + " 次。";
      }
      
      private function adjustBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_BUDUI,true));
      }
      
      private function okBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(XiongnuConfig.checkGeneralLevel(RoleModel.getInstance().getChooseSoldiers()) == true)
         {
            dispatchEvent(new UIEvent(UIEvent.INJOY_FUBEN,true,{
               "stageID":1,
               "index":1
            }));
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"上阵的武将等级差不能超过10级不符，请重新调整上阵武将。"
            }));
         }
      }
      
      private function returnBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
   }
}
