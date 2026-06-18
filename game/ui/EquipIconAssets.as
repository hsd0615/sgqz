package game.ui
{
   import flash.display.Bitmap;

   // 装备图标 - OpenGameArt Fantasy RPG Icons 3 (手绘原创, 免费商用)
   public class EquipIconAssets
   {
      [Embed(source="../../assets/icons/sword_oga.png")]
      private static var _weapon:Class;
      [Embed(source="../../assets/icons/shield_oga.png")]
      private static var _armor:Class;
      [Embed(source="../../assets/icons/armor_oga.png")]
      private static var _accessory:Class;

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
         var _b:Bitmap = new _accessory() as Bitmap;
         _b.smoothing = true;
         return _b;
      }

      // 头盔图标 - 暂用盾牌(防具)图标, 后续替换为专属PNG
      public static function helmet() : Bitmap
      {
         var _b:Bitmap = new _armor() as Bitmap;
         _b.smoothing = true;
         return _b;
      }

      // 战靴图标 - 暂用宝石(饰品)图标, 后续替换为专属PNG
      public static function boots() : Bitmap
      {
         var _b:Bitmap = new _accessory() as Bitmap;
         _b.smoothing = true;
         return _b;
      }
   }
}
