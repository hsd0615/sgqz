package com.iflashigame.net
{
   import flash.events.EventDispatcher;
   public class SocketConnection extends EventDispatcher
   {
      public function get connected():Boolean { return true; }
      public function connect(host:String, port:int):void {
         dispatchEvent(new SocketEvent(SocketEvent.CONNECTED));
      }
      public function send(msg:Object):void {}
      public function close():void {}
   }
}
