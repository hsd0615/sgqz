package game
{
   import flash.display.Bitmap;
   public class LocalAssets
   {
      [Embed(source="../battle_bg.png")]
      private static var DefaultBackground:Class;
      public static function background():Bitmap
      {
         return new DefaultBackground() as Bitmap;
      }
      public static function url(path:String):String
      {
         return encodeURI((Config.OFFLINE_MODE ? "app:/" : "") + path);
      }
   }
}
