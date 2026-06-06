package com.iflashigame.talk
{
   import flash.events.Event;
   
   public class TalkEvent extends Event
   {
      
      public static const NET_INFO:String = "netInfo";
       
      
      public var data:Object;
      
      public function TalkEvent(param1:String, param2:Boolean = false, param3:Object = null, param4:Boolean = false)
      {
         this.data = param3;
         super(param1,param2,param4);
      }
      
      override public function clone() : Event
      {
         return new TalkEvent(type,bubbles,this.data,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("TalkEvent","type","bubbles","cancelable","eventPhase");
      }
   }
}
