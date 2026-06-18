package game.ui
{
   import flash.display.Bitmap;

   // 装备图标 - Flaticon真实PNG素材(CC许可)
   public class EquipIconAssets
   {
      [Embed(source="../../assets/icons/weapon.png")]
      private static var _weapon:Class;
      [Embed(source="../../assets/icons/armor.png")]
      private static var _armor:Class;
      [Embed(source="../../assets/icons/ring.png")]
      private static var _ring:Class;

      public static function weapon() : Bitmap
      {
         var _b:Bitmap = new _weapon() as Bitmap;
         _b.smoothing = true;
         return _b;
      }

      public static function armor() : Bitmap
      {
         var _b:Bitmap = new _armor() as Bitmap;
         _b.smoothing = true;
         return _b;
      }

      public static function accessory() : Bitmap
      {
         var _b:Bitmap = new _ring() as Bitmap;
         _b.smoothing = true;
         return _b;
      }
   }
}
