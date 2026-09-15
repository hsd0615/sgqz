package game.events
{
   import flash.events.Event;
   
   public class SoldierEvent extends Event
   {
      
      public static const DEAD:String = "dead";
      
      public static const DEAD_COMPLETE:String = "deadComplete";
      
      public static const MOVE_COMPLETE:String = "moveComplete";
      
      public static const FIRE_COMPLETE:String = "fireComplete";
      
      public static const FILL_COMPLETE:String = "fillComplete";
      
      public static const BEHURT:String = "beHurt";
      
      public static const HUIFU:String = "huifu";
      
      public static const SHANBI:String = "shanbi";
      
      public static const P2P_ACTION:String = "p2pAction";
      
      public static const SELECTED:String = "selected";
      
      public static const ENEMY_SELECTED:String = "enemySelected";
      
      public static const SMART_ATTACK:String = "smartAttack";
      
      public static const ENEMY_LOCKED:String = "enemyLocked";
      
      public static const ENEMY_UNLOCKED:String = "enemyUnlocked";
      
      public static const TALK:String = "talk";
      
      public static const ZHAOHUAN:String = "zhaohuan";
       
      
      public var data:Object;
      
      public function SoldierEvent(param1:String, param2:Boolean = false, param3:Object = null, param4:Boolean = false)
      {
         this.data = param3;
         super(param1,param2,param4);
      }
      
      override public function clone() : Event
      {
         return new SoldierEvent(type,bubbles,this.data,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("SoldierEvent","type","bubbles","cancelable","eventPhase");
      }
   }
}
