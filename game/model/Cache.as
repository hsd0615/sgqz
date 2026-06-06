package game.model
{
   import flash.events.EventDispatcher;
   
   public class Cache extends EventDispatcher
   {
      
      private static var _instance:Cache;
      
      public static const MAX_FIGHT_COUNT:int = 15;
       
      
      public var fightCount:int = 0;
      
      public var xiongnuStageID:int;
      
      public function Cache(param1:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : Cache
      {
         if(Cache._instance == null)
         {
            Cache._instance = new Cache(new SingletonEnforcer());
         }
         return Cache._instance;
      }
   }
}

class SingletonEnforcer
{
    
   
   public function SingletonEnforcer()
   {
      super();
   }
}
