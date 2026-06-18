package game.ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;

   // 装备图标素材 - 嵌入PNG图像到SWF中
   public class EquipIconAssets
   {
      [Embed(source="../../assets/icons/sword.png")]
      private static var _sword:Class;
      [Embed(source="../../assets/icons/shield.png")]
      private static var _shield:Class;
      [Embed(source="../../assets/icons/gem.png")]
      private static var _gem:Class;

      public static function weapon() : Bitmap
      {
         var _b:Bitmap = new _sword() as Bitmap;
         _b.smoothing = true;
         return _b;
      }

      public static function armor() : Bitmap
      {
         var _b:Bitmap = new _shield() as Bitmap;
         _b.smoothing = true;
         return _b;
      }

      public static function accessory() : Bitmap
      {
         var _b:Bitmap = new _gem() as Bitmap;
         _b.smoothing = true;
         return _b;
      }
   }
}
