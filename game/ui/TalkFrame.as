package game.ui
{
   import com.greensock.TweenLite;
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.filters.DropShadowFilter;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class TalkFrame extends BaseUI
   {
       
      
      private var __hand:MovieClip;
      
      private var _tf:TextField;
      
      private var _maxWidth:Number = 170;
      
      private var _borderWidth:Number = 5;
      
      private var _sp:Sprite;
      
      private var _timer:Timer;
      
      private var _delay:int = 3000;
      
      public function TalkFrame(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
         mouseChildren = false;
         mouseEnabled = false;
      }
      
      override protected function initView() : void
      {
         this.__hand = _skin.getChildByName("_hand") as MovieClip;
         this._sp = new Sprite();
         addChildAt(this._sp,0);
         this._tf = new TextField();
         this._tf.width = this._maxWidth - this._borderWidth * 2;
         this._tf.selectable = false;
         this._tf.multiline = true;
         this._tf.wordWrap = true;
         this._tf.autoSize = "left";
         filters = [new DropShadowFilter(5,45,0,0.2,0,0)];
         this._tf.x = this._borderWidth;
         this._tf.y = this._borderWidth;
         this._sp.addChild(this._tf);
      }
      
      override protected function initEvent() : void
      {
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStageHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this._tf.text = param1.text;
         if(param1.delay != null)
         {
            this._delay = int(param1.delay);
         }
         this._tf.height = this._tf.textHeight + 4;
         this._sp.graphics.beginFill(16777215);
         this._sp.graphics.lineStyle(1.5,3355443,1);
         this._sp.graphics.drawRoundRect(0,0,this._maxWidth,this._tf.height + this._borderWidth * 2,5,5);
         this._sp.y = -this.__hand.height - this._sp.height + 3.5;
         this._sp.x = -(this._sp.width - this.__hand.width + 20);
         this.zoomFrom(1,1,0,0.7,this.startTime);
      }
      
      override public function zoomFrom(param1:Number, param2:Number, param3:Number = 1, param4:Number = 1, param5:Function = null) : *
      {
         if(param5 != null)
         {
            TweenLite.from(this,param4,{
               "scaleX":param1,
               "scaleY":param2,
               "alpha":param3,
               "onComplete":param5
            });
         }
         else
         {
            TweenLite.from(this,param4,{
               "scaleX":param1,
               "scaleY":param2,
               "alpha":param3
            });
         }
      }
      
      private function startTime() : *
      {
         this._timer = new Timer(this._delay,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timeCompleteHandler);
         this._timer.start();
      }
      
      private function onRemovedFromStageHandler(param1:Event) : *
      {
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStageHandler);
         this._timer.stop();
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.timeCompleteHandler);
      }
      
      private function timeCompleteHandler(param1:TimerEvent) : *
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
   }
}
