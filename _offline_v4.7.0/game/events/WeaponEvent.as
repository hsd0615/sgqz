package game.events
{
   import flash.events.Event;
   
   public class WeaponEvent extends Event
   {
      
      public static const WEAPON_END:String = "weaponEnd";
       
      
      public var data:Object;
      
      public function WeaponEvent(param1:String, param2:Boolean = false, param3:Object = null, param4:Boolean = false)
      {
         this.data = param3;
         super(param1,param2,param4);
      }
      
      override public function clone() : Event
      {
         return new WeaponEvent(type,bubbles,this.data,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("WeaponEvent","type","bubbles","cancelable","eventPhase");
      }
   }
}
