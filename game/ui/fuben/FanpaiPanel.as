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

      private var _stageID:int;

      private var _choosed:Boolean = false;

      // 多翻牌支持
      private var _maxFlips:int = 1;
      private var _flipsRemaining:int = 1;
      private var _flippedCards:Array;

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
         this._pai1.x = -238.45; this._pai1.y = -22;
         this._pai2.x = -144.3;  this._pai2.y = -22;
         this._pai3.x = -50.15;  this._pai3.y = -22;
         this._pai4.x = 44;      this._pai4.y = -22;
         this._pai5.x = 138.15;  this._pai5.y = -22;
         this._pai6.x = 232.5;   this._pai6.y = -22;
         addChild(this._pai1); addChild(this._pai2); addChild(this._pai3);
         addChild(this._pai4); addChild(this._pai5); addChild(this._pai6);
         this._pai1.buttonMode = true; this._pai2.buttonMode = true;
         this._pai3.buttonMode = true; this._pai4.buttonMode = true;
         this._pai5.buttonMode = true; this._pai6.buttonMode = true;
         Tools.setDisabled(this.__okBtn,true);
         this._flippedCards = [];
      }

      override protected function initEvent() : void
      {
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.okBtnClickHandler);
      }

      override public function initData(param1:Object) : void
      {
         this._stageID = int(param1.stageID);
         this._maxFlips = int(param1.maxFlips) || 1;
         this._flipsRemaining = this._maxFlips;
         this._choosed = false;
         this._flippedCards = [];

         var _loc2_:Array = param1.pai as Array;
         this._pai1.initData(_loc2_[0]);
         this._pai2.initData(_loc2_[1]);
         this._pai3.initData(_loc2_[2]);
         this._pai4.initData(_loc2_[3]);
         this._pai5.initData(_loc2_[4]);
         this._pai6.initData(_loc2_[5]);

         this.updateFlipsText();

         // 非求贤令模式(stageID!=0)保持原有10秒倒计时逻辑
         if(this._stageID != 0)
         {
            this.__tf.text = "翻牌倒计时：10";
            var _loc3_:Timer = new Timer(1000,10);
            _loc3_.addEventListener(TimerEvent.TIMER,this.onTimerHandler);
            _loc3_.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerCompleteHandler);
            _loc3_.start();
         }
         else if(this._maxFlips > 1)
         {
            // 求贤令多翻模式：无倒计时，显示翻牌次数
            this.__tf.text = "剩余翻牌：" + this._maxFlips + " 次（可使用多个求贤令）";
         }
         addEventListener(UIEvent.CHOOSE_PAIMIAN,this.choosPaiHandler);
      }

      private function updateFlipsText() : void
      {
         if(this._stageID == 0 && this._maxFlips > 1)
         {
            var _left:int = this._flipsRemaining;
            if(_left > 0)
            {
               this.__tf.text = "剩余翻牌：" + _left + "/" + this._maxFlips + " 次";
            }
            else
            {
               this.__tf.text = "翻牌完成，点击确定";
            }
         }
      }

      private function choosPaiHandler(param1:UIEvent) : *
      {
         param1.stopImmediatePropagation();
         var _target:Paimian = param1.target as Paimian;
         var _cardData:String = _target.data;

         if(this._stageID == 0 && this._maxFlips > 1)
         {
            // ===== 求贤令多翻模式 =====
            // 检查是否已翻过这张牌
            for(var _fi:int = 0; _fi < this._flippedCards.length; _fi++)
            {
               if(this._flippedCards[_fi].data == _cardData) return;
            }

            // 记录翻牌
            this._flippedCards.push({data: _cardData, target: _target});
            this._flipsRemaining--;

            // 翻转卡牌
            _target.show();
            _target.filters = [new GlowFilter(16763904,1,10,10)];
            _target.disable = true;

            this.updateFlipsText();

            // 发送翻牌请求到服务端
            dispatchEvent(new UIEvent(UIEvent.SEND_PAIMIAN,true,{
               "data":_cardData,
               "stageID":this._stageID
            }));

            // 翻牌次数用完，启用确定按钮并自动翻面剩余卡牌
            if(this._flipsRemaining <= 0)
            {
               this._pai1.disable = true;
               this._pai2.disable = true;
               this._pai3.disable = true;
               this._pai4.disable = true;
               this._pai5.disable = true;
               this._pai6.disable = true;
               this.showAllCards();
               Tools.setDisabled(this.__okBtn,false);
               this.__tf.text = "翻牌完成，点击确定";
            }
         }
         else
         {
            // ===== 原版单翻模式（副本翻牌 / 1个求贤令） =====
            removeEventListener(UIEvent.CHOOSE_PAIMIAN,this.choosPaiHandler);
            this._flippedCards.push({data: _cardData, target: _target});
            this._pai1.disable = true;
            this._pai2.disable = true;
            this._pai3.disable = true;
            this._pai4.disable = true;
            this._pai5.disable = true;
            this._pai6.disable = true;
            Tools.setDisabled(this.__okBtn,false);
         }
      }

      private function showAllCards() : void
      {
         this._pai1.show();
         this._pai2.show();
         this._pai3.show();
         this._pai4.show();
         this._pai5.show();
         this._pai6.show();
      }

      private function onTimerHandler(param1:TimerEvent) : *
      {
         var _loc2_:Timer = param1.currentTarget as Timer;
         this.__tf.text = "翻牌倒计时：" + (10 - _loc2_.currentCount);
      }

      private function onTimerCompleteHandler(param1:TimerEvent) : *
      {
         removeEventListener(UIEvent.CHOOSE_PAIMIAN,this.choosPaiHandler);
         this._pai1.disable = true; this._pai2.disable = true;
         this._pai3.disable = true; this._pai4.disable = true;
         this._pai5.disable = true; this._pai6.disable = true;
         this.showAllCards();
         // 原版：未手动选则自动选第一张
         if(this._flippedCards.length == 0)
         {
            this._pai1.filters = [new GlowFilter(16763904,1,10,10)];
            this._flippedCards.push({data: this._pai1.data, target: this._pai1});
            this.__tf.text = "时间到，自动选择";
         }
         Tools.setDisabled(this.__okBtn,false);
      }

      private function okBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._choosed == false)
         {
            this._choosed = true;

            if(this._stageID == 0 && this._maxFlips > 1)
            {
               // 多翻模式：所有翻牌已通过choosPaiHandler逐个发送
               // 只需关闭面板
               dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
            }
            else
            {
               // 原版单翻模式
               dispatchEvent(new UIEvent(UIEvent.SEND_PAIMIAN,true,{
                  "data":this._flippedCards.length > 0 ? this._flippedCards[0].data : this._pai1.data,
                  "stageID":this._stageID
               }));
            }
         }
      }
   }
}
