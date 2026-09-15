package game.ai
{
   import game.display.AbstractSoldier;
   
   public interface IAI
   {
       
      
      function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void;
      
      function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void;
      
      function get leftSoldiers() : Array;
      
      function get rightSoldiers() : Array;
      
      function get ammo() : String;
      
      function setAmmoTips(param1:AbstractSoldier) : *;
      
      function getAllDistance(param1:AbstractSoldier, param2:AbstractSoldier) : Number;
      
      function getDistance(param1:AbstractSoldier, param2:AbstractSoldier) : Number;
      
      function findSoldier(param1:int) : AbstractSoldier;
   }
}
