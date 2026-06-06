package game.display
{
   public interface IWorld
   {
       
      
      function checkLeft(param1:AbstractSoldier) : Boolean;
      
      function checkRight(param1:AbstractSoldier) : Boolean;
      
      function findSoldier(param1:int) : AbstractSoldier;
      
      function getDistance(param1:AbstractSoldier, param2:AbstractSoldier) : Number;
      
      function getAllDistance(param1:AbstractSoldier, param2:AbstractSoldier) : Number;
      
      function getAutoMode() : Boolean;
   }
}
