package game.ui
{
   import com.iflashigame.net.ChatManager;
   import com.iflashigame.talk.NetInfoType;
   import com.iflashigame.talk.TalkEvent;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;

   /** Root-level, non-interactive notice banner remains visible above battles and panels. */
   public class BroadcastUI extends Sprite
   {
      private var _field:TextField = new TextField();
      private var _queue:Array = [];
      private var _timer:Timer = new Timer(6000, 1);
      public function BroadcastUI()
      {
         mouseEnabled = false;
         mouseChildren = false;
         x = 120; y = 25;
         graphics.beginFill(0x101820, 0.9);
         graphics.drawRoundRect(0, 0, 530, 48, 8, 8);
         graphics.endFill();
         _field.defaultTextFormat = new TextFormat("Microsoft YaHei", 13, 0xFFE7A0);
         _field.x = 8; _field.y = 3; _field.width = 514; _field.height = 44;
         _field.multiline = true; _field.wordWrap = true; _field.selectable = false;
         addChild(_field);
         visible = false;
         addEventListener(Event.ENTER_FRAME, keepOnTop);
         _timer.addEventListener(TimerEvent.TIMER_COMPLETE, nextNotice);
         ChatManager.getInstance().addEventListener(TalkEvent.CHAT_PLAIN, onNotice);
      }
      private function keepOnTop(event:Event):void
      {
         if(visible && parent && parent.getChildIndex(this) != parent.numChildren - 1) parent.setChildIndex(this, parent.numChildren - 1);
      }
      private function onNotice(event:TalkEvent):void
      {
         if(event.data.type != NetInfoType.SYSTEM || !event.data.text) return;
         _queue.push(String(event.data.text));
         if(!_timer.running) nextNotice(null);
      }
      private function nextNotice(event:TimerEvent):void
      {
         if(_queue.length == 0) { visible = false; return; }
         _field.htmlText = _queue.shift();
         _field.height = _field.textHeight + 8;
         graphics.clear();
         graphics.beginFill(0x101820, 0.9);
         graphics.drawRoundRect(0, 0, 530, _field.height + 6, 8, 8);
         graphics.endFill();
         visible = true;
         if(parent) parent.setChildIndex(this, parent.numChildren - 1);
         _timer.reset();
         _timer.start();
      }
   }
}
