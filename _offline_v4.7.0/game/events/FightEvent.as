package game.events
{
   import flash.events.Event;
   
   public class FightEvent extends Event
   {
      
      public static const FIGHT_COMPLETE:String = "fightComplete";
      
      public static const P2P_FIGHT_COMPLETE:String = "p2pFightComplete";
      
      public static const CLOSE_FIGHT:String = "closeFight";
      
      public static const CLOSE_P2P_FIGHT:String = "closeP2PFight";
      
      public static const USE_AMMO:String = "useAmmo";
      
      public static const LEITAI_FIGHT_COMPLETE:String = "leitaiFightComplete";
      
      public static const CLOSE_LEITAI_FIGHT:String = "closeLeitaiFight";
      
      public static const XIONGNU_FIGHT_COMPLETE:String = "xiongnuFightComplete";
       
      
      public var data:Object;
      
      public function FightEvent(param1:String, param2:Boolean = false, param3:Object = null, param4:Boolean = false)
      {
         super(param1,param2,param4);
         this.data = param3;
      }
      
      override public function clone() : Event
      {
         return new FightEvent(type,bubbles,this.data,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("FightEvent","type","bubbles","cancelable","eventPhase");
      }
   }
}
