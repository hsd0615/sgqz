package utils
{
   public class JsonFormatter
   {
       
      
      public function JsonFormatter()
      {
         super();
      }
      
      public static function formatJson(param1:Object, param2:String = "  ") : String
      {
         return formatValue(param1,param2,"");
      }
      
      private static function formatValue(param1:*, param2:String, param3:String) : String
      {
         var _loc4_:Array = null;
         var _loc5_:* = null;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         if(param1 is String)
         {
            return "\"" + escapeString(param1) + "\"";
         }
         if(param1 is Number || param1 is Boolean || param1 === null)
         {
            return String(param1);
         }
         if(param1 is Array)
         {
            if((_loc4_ = param1 as Array).length == 0)
            {
               return "[]";
            }
            _loc5_ = "[\n";
            _loc6_ = 0;
            while(_loc6_ < _loc4_.length)
            {
               _loc5_ += param3 + param2 + formatValue(_loc4_[_loc6_],param2,param3 + param2);
               if(_loc6_ < _loc4_.length - 1)
               {
                  _loc5_ += ",";
               }
               _loc5_ += "\n";
               _loc6_++;
            }
            return _loc5_ + (param3 + "]");
         }
         if(param1 is Object)
         {
            _loc7_ = [];
            for(_loc8_ in param1)
            {
               _loc7_.push(_loc8_);
            }
            if(_loc7_.length == 0)
            {
               return "{}";
            }
            _loc5_ = "{\n";
            _loc6_ = 0;
            while(_loc6_ < _loc7_.length)
            {
               _loc9_ = String(_loc7_[_loc6_]);
               _loc5_ += param3 + param2 + "\"" + _loc9_ + "\": " + formatValue(param1[_loc9_],param2,param3 + param2);
               if(_loc6_ < _loc7_.length - 1)
               {
                  _loc5_ += ",";
               }
               _loc5_ += "\n";
               _loc6_++;
            }
            return _loc5_ + (param3 + "}");
         }
         return "\"\"";
      }
      
      private static function escapeString(param1:String) : String
      {
         return param1.replace(/\\/g,"\\\\").replace(/"/g,"\\\"").replace(/\r/g,"\\r").replace(/\n/g,"\\n").replace(/\t/g,"\\t");
      }
   }
}
