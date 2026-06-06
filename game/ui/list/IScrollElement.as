package game.ui.list
{
   public interface IScrollElement
   {
       
      
      function get maskX() : Number;
      
      function set maskX(param1:Number) : *;
      
      function get maskY() : Number;
      
      function set maskY(param1:Number) : *;
      
      function get minScroll() : Number;
      
      function get maxScroll() : Number;
      
      function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void;
      
      function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void;
   }
}
