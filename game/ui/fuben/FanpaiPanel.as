package game.ui.fuben
{
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.events.Event;
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
      private var _cards:Array;
      private var _deckId:String;
      private var _pendingIndex:int = -1;
      private var _requestTimer:Timer;

      private var _choosed:Boolean = false;

      // 多翻牌支持
      private var _maxFlips:int = 1;
      private var _flipsRemaining:int = 1;
      private var _flippedCards:Array;
      private var _flipCosts:Array;

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
         this._cards = [this._pai1,this._pai2,this._pai3,this._pai4,this._pai5,this._pai6];
      }

      override protected function initEvent() : void
      {
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.okBtnClickHandler);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoved);
      }

      override public function initData(param1:Object) : void
      {
         this._stageID = int(param1.stageID);
         this._deckId = param1.deckId == null ? "" : String(param1.deckId);
         this._pendingIndex = -1;
         for each(var card:Paimian in this._cards) card.deferReveal = this._stageID == 0 || int(param1.maxFlips) > 1;
         this._maxFlips = int(param1.maxFlips) || 1;
         this._flipCosts = param1.flipCosts as Array;
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
         Tools.setDisabled(this.__okBtn,true);

         // 匈奴通关翻牌也支持多次翻牌；只有旧单翻模式保留倒计时。
         if(this._stageID != 0 && this._maxFlips <= 1)
         {
            this.__tf.text = "翻牌倒计时：10";
            var _loc3_:Timer = new Timer(1000,10);
            _loc3_.addEventListener(TimerEvent.TIMER,this.onTimerHandler);
            _loc3_.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerCompleteHandler);
            _loc3_.start();
         }
         else this.updateFlipsText();
         addEventListener(UIEvent.CHOOSE_PAIMIAN,this.choosPaiHandler);
      }

      private function updateFlipsText() : void
      {
         if(this._maxFlips > 1 || this._stageID == 0)
         {
            var _left:int = this._flipsRemaining;
            if(_left > 0)
            {
               var _cost:int = this._stageID == 0 || this._flipCosts == null ? 0 : int(this._flipCosts[this._maxFlips - _left]);
               this.__tf.text = "剩余翻牌：" + _left + "/" + this._maxFlips + " 次" + (this._stageID == 0 ? "" : "；本次消耗 " + _cost + " 点卡");
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
         this.requestRecruitCard(_target);
      }

      private function requestRecruitCard(card:Paimian) : void
      {
         var index:int = this._cards.indexOf(card);
         if(index < 0 || this._flipsRemaining <= 0) return;
         if(this._pendingIndex >= 0 && this._pendingIndex != index) return;
         this._pendingIndex = index;
         for each(var other:Paimian in this._cards) other.disable = true;
         Tools.setDisabled(this.__okBtn,true);
         this.__tf.text = "正在翻牌，请稍候…";
         if(this._requestTimer != null) this._requestTimer.stop();
         this._requestTimer = new Timer(35000,1);
         this._requestTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onRequestTimeout);
         this._requestTimer.start();
         dispatchEvent(new UIEvent(UIEvent.SEND_PAIMIAN,true,{
            stageID:this._stageID, deckId:this._deckId, cardIndex:index,
            flipIndex:this._maxFlips - this._flipsRemaining, data:card.data
         }));
      }

      private function onRequestTimeout(event:TimerEvent) : void
      {
         if(this._pendingIndex < 0) return;
         Paimian(this._cards[this._pendingIndex]).disable = false;
         Tools.setDisabled(this.__okBtn,false);
         this.__tf.text = "请求未确认，点击原卡重试（不会重复扣令），或点击确定关闭";
      }

      public function resolveRecruit(success:Boolean, data:Object = null) : Boolean
      {
         if(this._pendingIndex < 0) return false;
         if(success && data != null && data.deckId != null && String(data.deckId) != String(this._deckId)) return false;
         if(success && data != null && data.cardIndex != null && int(data.cardIndex) != this._pendingIndex) return false;
         if(this._requestTimer != null) this._requestTimer.stop();
         if(success)
         {
            var card:Paimian = this._cards[this._pendingIndex] as Paimian;
            card.initData(String(data.result || (data.general != null ? "3|" + data.general.code + "|0|" + data.general.level : "1|" + data.item.code + "|" + data.item.count)));
            card.show();
            this._flippedCards.push({target:card});
            this._flipsRemaining--;
         }
         this._pendingIndex = -1;
         for each(var other:Paimian in this._cards)
         {
            other.disable = this._flipsRemaining <= 0;
            for each(var chosen:Object in this._flippedCards) if(chosen.target == other) other.disable = true;
         }
         this.updateFlipsText();
         Tools.setDisabled(this.__okBtn,false);
         return success;
      }

      public function hasMoreFlips() : Boolean
      {
         return this._maxFlips > 1 && this._flipsRemaining > 0;
      }

      private function onRemoved(event:Event) : void
      {
         if(this._requestTimer != null) this._requestTimer.stop();
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

            if(this._stageID == 0 || this._maxFlips > 1)
            {
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
