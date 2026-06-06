package game.ai
{
   import com.iflashigame.net.ChatManager;
   import game.Fight;
   import game.display.AbstractSoldier;
   import game.display.Saber;
   import game.display.Shooter;
   import game.model.Head;
   
   public class SmartAttack
   {
       
      
      public function SmartAttack()
      {
         super();
      }
      
      public static function makeAI(param1:AbstractSoldier, param2:IAI, param3:Boolean = false) : *
      {
         if(param1.canAI == true)
         {
            if(param1 is Saber)
            {
               saberAttack(param1 as Saber,param2,param3);
            }
            else if(param1 is Shooter)
            {
               soldierForward(param1 as Shooter,param2,param3);
            }
         }
      }
      
      private static function soldierForward(param1:AbstractSoldier, param2:IAI, param3:Boolean) : *
      {
         var _loc4_:Object = {};
         var _loc5_:int = ChatManager.getInstance().server == true ? Head.ACTION_FROM_SERVER : Head.ACTION_FROM_CLIENT;
         _loc4_.head = _loc5_;
         _loc4_.direct = param1.direct;
         _loc4_.code = param1.code;
         if(param1.direct == -1)
         {
            if(param3 == true)
            {
               _loc4_.act = "goLeft";
               _loc4_.obj = param2.getDistance(param1,param2.findSoldier(1));
               ChatManager.getInstance().p2pSend(_loc4_);
            }
            param1.goLeft(param2.getDistance(param1,param2.findSoldier(1)));
         }
         else if(param1.direct == 1)
         {
            if(param3 == true)
            {
               _loc4_.act = "goRight";
               _loc4_.obj = param2.getDistance(param1,param2.findSoldier(-1));
               ChatManager.getInstance().p2pSend(_loc4_);
            }
            param1.goRight(param2.getDistance(param1,param2.findSoldier(-1)));
         }
      }
      
      private static function soldierMove(param1:AbstractSoldier, param2:IAI, param3:Boolean) : *
      {
         var _loc4_:Object = {};
         var _loc5_:int = ChatManager.getInstance().server == true ? Head.ACTION_FROM_SERVER : Head.ACTION_FROM_CLIENT;
         _loc4_.head = _loc5_;
         _loc4_.direct = param1.direct;
         _loc4_.code = param1.code;
         if(param1.direct == 1)
         {
            if(param3 == true)
            {
               _loc4_.act = "goLeft";
               _loc4_.obj = param1.moveDistance * Fight.MERIC / 2;
               ChatManager.getInstance().p2pSend(_loc4_);
            }
            param1.goLeft(param1.moveDistance * Fight.MERIC / 2);
         }
         else if(param1.direct == -1)
         {
            if(param3 == true)
            {
               _loc4_.act = "goRight";
               _loc4_.obj = param1.moveDistance * Fight.MERIC / 2;
               ChatManager.getInstance().p2pSend(_loc4_);
            }
            param1.goRight(param1.moveDistance * Fight.MERIC / 2);
         }
      }
      
      private static function saberAttack(param1:Saber, param2:IAI, param3:Boolean) : *
      {
         var _loc4_:Object = {};
         var _loc5_:int = ChatManager.getInstance().server == true ? Head.ACTION_FROM_SERVER : Head.ACTION_FROM_CLIENT;
         _loc4_.head = _loc5_;
         _loc4_.direct = param1.direct;
         _loc4_.code = param1.code;
         _loc4_.act = "fire";
         if(param1.direct == 1)
         {
            if(param3 == true)
            {
               _loc4_.obj = {"distance":param2.getAllDistance(param1,param2.findSoldier(-1))};
               ChatManager.getInstance().p2pSend(_loc4_);
            }
            param1.fire({"distance":param2.getAllDistance(param1,param2.findSoldier(-1))});
         }
         else
         {
            if(param3 == true)
            {
               _loc4_.obj = {"distance":param2.getAllDistance(param1,param2.findSoldier(1))};
               ChatManager.getInstance().p2pSend(_loc4_);
            }
            param1.fire({"distance":param2.getAllDistance(param1,param2.findSoldier(1))});
         }
      }
      
      private static function shooterAttack(param1:Shooter, param2:IAI, param3:Boolean) : *
      {
         var _loc4_:AbstractSoldier = param1.direct == 1 ? param2.findSoldier(-1) : param2.findSoldier(1);
         var _loc5_:Number = param2.getAllDistance(param1,_loc4_);
         var _loc6_:Object = {};
         var _loc7_:int = ChatManager.getInstance().server == true ? Head.ACTION_FROM_SERVER : Head.ACTION_FROM_CLIENT;
         _loc6_.head = _loc7_;
         _loc6_.direct = param1.direct;
         _loc6_.code = param1.code;
         if(_loc5_ <= param1.attckDistance * Fight.MERIC)
         {
            if(param3 == true)
            {
               _loc6_.act = "fire";
               _loc6_.obj = _loc4_.code;
               ChatManager.getInstance().p2pSend(_loc6_);
            }
            param1.fire({"target":_loc4_});
         }
         else if(param1.direct == 1)
         {
            if(param3 == true)
            {
               _loc6_.act = "goRight";
               _loc6_.obj = param2.getDistance(param1,param2.findSoldier(-1));
               ChatManager.getInstance().p2pSend(_loc6_);
            }
            param1.goRight(param2.getDistance(param1,param2.findSoldier(-1)));
         }
         else
         {
            if(param3 == true)
            {
               _loc6_.act = "goLeft";
               _loc6_.obj = param2.getDistance(param1,param2.findSoldier(1));
               ChatManager.getInstance().p2pSend(_loc6_);
            }
            param1.goLeft(param2.getDistance(param1,param2.findSoldier(1)));
         }
      }
   }
}
