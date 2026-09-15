package com.iflashigame.controller
{
   import flash.events.Event;
   
   public class ControllerEvent extends Event
   {
      
      public static const ERROR:String = "error";
       
      
      public var data:Object;
      
      public function ControllerEvent(param1:String, param2:Object, param3:Boolean = true, param4:Boolean = true)
      {
         this.data = param2;
         super(param1,param3,param4);
      }
   }
}
