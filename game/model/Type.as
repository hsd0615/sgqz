package game.model
{
   public class Type
   {
      
      public static const LONG:Array = [80,60,60,60,60,60,60,60,60,80,60,195,60,110];
      
      public static const TYPE_NAME:Array = ["投石车","弓兵","飞刀兵","朴刀兵","斧兵","锤兵","武斗兵","长枪兵","藤甲兵","骑兵"];
      
      public static const TOUSHICHE:int = 0;
      
      public static const GONGBING:int = 1;
      
      public static const FEIDAOBING:int = 2;
      
      public static const PUDAOBING:int = 3;
      
      public static const FUBING:int = 4;
      
      public static const CHUIBING:int = 5;
      
      public static const WUDOUBING:int = 6;
      
      public static const CHANGQIANGBING:int = 7;
      
      public static const TENGJIABING:int = 8;
      
      public static const QIBING:int = 9;
      
      public static const WANDAOBING:int = 10;
      
      public static const JIANTABING:int = 11;
      
      public static const QIANGGONGBING:int = 12;
      
      public static const BOSS:int = 13;
      
      public static const JUNZHU:int = 20;
       
      
      public function Type()
      {
         super();
      }
      
      public static function createType(param1:int) : String
      {
         var _loc2_:String = null;
         switch(param1)
         {
            case CHANGQIANGBING:
               _loc2_ = "长枪兵";
               break;
            case CHUIBING:
               _loc2_ = "锤兵";
               break;
            case FEIDAOBING:
               _loc2_ = "飞刀兵";
               break;
            case FUBING:
               _loc2_ = "斧兵";
               break;
            case GONGBING:
               _loc2_ = "弓兵";
               break;
            case PUDAOBING:
               _loc2_ = "朴刀兵";
               break;
            case QIBING:
               _loc2_ = "骑兵";
               break;
            case TENGJIABING:
               _loc2_ = "藤甲兵";
               break;
            case TOUSHICHE:
               _loc2_ = "投石车";
               break;
            case WUDOUBING:
               _loc2_ = "武斗兵";
               break;
            case JUNZHU:
               _loc2_ = "君主";
         }
         return _loc2_;
      }
      
      public static function createKezhiStr(param1:int) : String
      {
         var _loc2_:String = null;
         switch(param1)
         {
            case CHANGQIANGBING:
               _loc2_ = "克长枪兵";
               break;
            case CHUIBING:
               _loc2_ = "克锤兵";
               break;
            case FEIDAOBING:
               _loc2_ = "克飞刀";
               break;
            case FUBING:
               _loc2_ = "克斧兵";
               break;
            case GONGBING:
               _loc2_ = "克弓兵";
               break;
            case PUDAOBING:
               _loc2_ = "克朴刀兵";
               break;
            case QIBING:
               _loc2_ = "克骑兵";
               break;
            case TENGJIABING:
               _loc2_ = "克藤甲兵";
               break;
            case TOUSHICHE:
               _loc2_ = "投石车";
               break;
            case WUDOUBING:
               _loc2_ = "克武斗兵";
         }
         return _loc2_;
      }
      
      public static function createTitle(param1:int) : String
      {
         var _loc2_:String = null;
         switch(param1)
         {
            case 0:
               _loc2_ = "<font color=\'#ff6600\'>超级武将</font>";
               break;
            case 1:
               _loc2_ = "<font color=\'#33ccff\'>一流武将</font>";
               break;
            case 2:
               _loc2_ = "<font color=\'#99ff33\'>二流武将</font>";
               break;
            default:
               _loc2_ = "<font color=\'#ffcc99\'>三流武将</font>";
         }
         return _loc2_;
      }
   }
}
