package game.ui.fuben
{
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.utils.Timer;
   import game.events.UIEvent;
   import game.ui.SkinCode;
   
   public class FanpaiPanel extends BaseUI
   {
       
      
      private var __tf:TextField;
      
      private var __okBtn:SimpleButton;
      
      private var _pai1:Paimian;
      
      private var _pai2:Paimian;
      
      private var _pai3:Paimian;
      
      private var _pai4:Paimian;
      
      private var _pai5:Paimian;
      
      private var _pai6:Paimian;
      
      private var _data:String = "";
      
      private var _stageID:int;
      
      private var _choosed:Boolean = false;
      
      public function FanpaiPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__tf = _skin.getChildByName("_tf") as TextField;
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this._pai1 = new Paimian(SkinCode.FUBEN_PAIMIAN);
         this._pai2 = new Paimian(SkinCode.FUBEN_PAIMIAN);
         this._pai3 = new Paimian(SkinCode.FUBEN_PAIMIAN);
         this._pai4 = new Paimian(SkinCode.FUBEN_PAIMIAN);
         this._pai5 = new Paimian(SkinCode.FUBEN_PAIMIAN);
         this._pai6 = new Paimian(SkinCode.FUBEN_PAIMIAN);
         this._pai1.x = -238.45;
         this._pai1.y = -22;
         this._pai2.x = -144.3;
         this._pai2.y = -22;
         this._pai3.x = -50.15;
         this._pai3.y = -22;
         this._pai4.x = 44;
         this._pai4.y = -22;
         this._pai5.x = 138.15;
         this._pai5.y = -22;
         this._pai6.x = 232.5;
         this._pai6.y = -22;
         addChild(this._pai1);
         addChild(this._pai2);
         addChild(this._pai3);
         addChild(this._pai4);
         addChild(this._pai5);
         addChild(this._pai6);
         this._pai1.buttonMode = true;
         this._pai2.buttonMode = true;
         this._pai3.buttonMode = true;
         this._pai4.buttonMode = true;
         this._pai5.buttonMode = true;
         this._pai6.buttonMode = true;
         Tools.setDisabled(this.__okBtn,true);
      }
      
      override protected function initEvent() : void
      {
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.okBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this._stageID = int(param1.stageID);
         var _loc2_:Array = param1.pai as Array;
         this._pai1.initData(_loc2_[0]);
         this._pai2.initData(_loc2_[1]);
         this._pai3.initData(_loc2_[2]);
         this._pai4.initData(_loc2_[3]);
         this._pai5.initData(_loc2_[4]);
         this._pai6.initData(_loc2_[5]);
         this.__tf.text = "翻牌倒计时：10";
         var _loc3_:Timer = new Timer(1000,10);
         _loc3_.addEventListener(TimerEvent.TIMER,this.onTimerHandler);
         _loc3_.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerCompleteHandler);
         _loc3_.start();
         addEventListener(UIEvent.CHOOSE_PAIMIAN,this.choosPaiHandler);
      }
      
      private function choosPaiHandler(param1:UIEvent) : *
      {
         param1.stopImmediatePropagation();
         removeEventListener(UIEvent.CHOOSE_PAIMIAN,this.choosPaiHandler);
         this._data = (param1.target as Paimian).data;
         this._pai1.disable = true;
         this._pai2.disable = true;
         this._pai3.disable = true;
         this._pai4.disable = true;
         this._pai5.disable = true;
         this._pai6.disable = true;
         Tools.setDisabled(this.__okBtn,false);
      }
      
      private function onTimerHandler(param1:TimerEvent) : *
      {
         var _loc2_:Timer = param1.currentTarget as Timer;
         this.__tf.text = "翻牌倒计时：" + (10 - _loc2_.currentCount);
      }
      
      private function onTimerCompleteHandler(param1:TimerEvent) : *
      {
         removeEventListener(UIEvent.CHOOSE_PAIMIAN,this.choosPaiHandler);
         this._pai1.disable = true;
         this._pai2.disable = true;
         this._pai3.disable = true;
         this._pai4.disable = true;
         this._pai5.disable = true;
         this._pai6.disable = true;
         this._pai1.show();
         this._pai2.show();
         this._pai3.show();
         this._pai4.show();
         this._pai5.show();
         this._pai6.show();
         if(this._data == "")
         {
            this._pai1.filters = [new GlowFilter(16763904,1,10,10)];
            this._data = this._pai1.data;
         }
         Tools.setDisabled(this.__okBtn,false);
      }
      
      private function okBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._choosed == false)
         {
            this._choosed = true;
            dispatchEvent(new UIEvent(UIEvent.SEND_PAIMIAN,true,{
               "data":this._data,
               "stageID":this._stageID
            }));
         }
      }
   }
}
