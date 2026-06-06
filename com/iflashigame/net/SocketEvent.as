package com.iflashigame.net
{
   import flash.events.Event;

   public class SocketEvent extends Event
   {
      public static const CONNECTED:String = "socketConnected";
      public static const CONNECT_FAIL:String = "socketConnectFail";
      public static const CLOSED:String = "socketClosed";
      public static const DATA:String = "socketData";
      public static const ERROR:String = "socketError";

      public var data:Object;
      public var message:String;

      public function SocketEvent(type:String, dataOrMsg:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type, bubbles, cancelable);
         if (dataOrMsg is String)
         {
            this.message = dataOrMsg as String;
         }
         else
         {
            this.data = dataOrMsg;
         }
      }

      override public function clone():Event
      {
         return new SocketEvent(type, data != null ? data : message, bubbles, cancelable);
      }
   }
}
