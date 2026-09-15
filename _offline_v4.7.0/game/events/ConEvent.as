package game.events
{
   import flash.events.Event;
   
   public class ConEvent extends Event
   {
      
      public static const LEFT:String = "left";
      
      public static const RIGHT:String = "right";
      
      public static const FIRE:String = "fire";
      
      public static const CREATE_MIAOZHUNJING:String = "createMiaozhunjing";
      
      public static const SELECT_SOLDIER:String = "selectSoldier";
       
      
      public var data:Object;
      
      public function ConEvent(param1:String, param2:Boolean = false, param3:Object = null, param4:Boolean = false)
      {
         this.data = param3;
         super(param1,param2,param4);
      }
      
      override public function clone() : Event
      {
         return new ConEvent(type,bubbles,this.data,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("ConEvent","type","bubbles","cancelable","eventPhase");
      }
   }
}
