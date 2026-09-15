package game.ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.GradientType;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;

   // 装备图标生成器 - 高精度程序化绘制, 无需外部素材
   public class EquipIcons
   {
      private static var _cache:Object = {};

      // 武器图标(红色调)
      public static function weapon() : Bitmap
      {
         if(_cache["weapon"]) return new Bitmap(_cache["weapon"] as BitmapData);
         var _bd:BitmapData = new BitmapData(44, 44, true, 0);
         var _s:Sprite = new Sprite();
         // 剑刃
         var _blade:Shape = new Shape();
         var _m:Matrix = new Matrix();
         _m.createGradientBox(10, 30, 0, 17, 4);
         _blade.graphics.beginGradientFill(GradientType.LINEAR, [0xEE4444,0xCC2222,0xAA1111], [1,1,1], [0,128,255], _m);
         _blade.graphics.moveTo(22,3); _blade.graphics.lineTo(28,6); _blade.graphics.lineTo(28,28);
         _blade.graphics.lineTo(32,34); _blade.graphics.lineTo(22,30); _blade.graphics.lineTo(12,34);
         _blade.graphics.lineTo(16,28); _blade.graphics.lineTo(16,6); _blade.graphics.lineTo(22,3);
         _blade.graphics.endFill();
         _blade.filters = [new DropShadowFilter(1,45,0,0.5,2,2)];
         _s.addChild(_blade);
         // 护手
         var _guard:Shape = new Shape();
         _guard.graphics.beginFill(0xB8860B);
         _guard.graphics.drawRoundRect(10,28,24,5,3,3);
         _guard.graphics.endFill();
         _guard.graphics.beginFill(0xFFD700);
         _guard.graphics.drawRoundRect(18,29,8,3,1,1);
         _guard.graphics.endFill();
         _s.addChild(_guard);
         // 剑柄
         var _handle:Shape = new Shape();
         _handle.graphics.beginGradientFill(GradientType.LINEAR, [0x8B6914,0x654321], [1,1], [0,255], _m);
         _handle.graphics.drawRoundRect(18,33,8,9,2,2);
         _handle.graphics.endFill();
         _s.addChild(_handle);
         _bd.draw(_s);
         _cache["weapon"] = _bd;
         return new Bitmap(_bd);
      }

      // 防具图标(蓝色调)
      public static function armor() : Bitmap
      {
         if(_cache["armor"]) return new Bitmap(_cache["armor"] as BitmapData);
         var _bd:BitmapData = new BitmapData(44, 44, true, 0);
         var _s:Sprite = new Sprite();
         var _m:Matrix = new Matrix();
         // 盾牌主体
         _m.createGradientBox(36, 40, 0, 4, 2);
         var _shield:Shape = new Shape();
         _shield.graphics.beginGradientFill(GradientType.LINEAR, [0x5588CC,0x3366AA,0x224488], [1,1,1], [0,128,255], _m);
         _shield.graphics.moveTo(22,2); _shield.graphics.lineTo(40,10); _shield.graphics.lineTo(40,26);
         _shield.graphics.lineTo(22,42); _shield.graphics.lineTo(4,26); _shield.graphics.lineTo(4,10);
         _shield.graphics.lineTo(22,2);
         _shield.graphics.endFill();
         _shield.graphics.lineStyle(1.5, 0xAACCDD, 0.6);
         _shield.graphics.moveTo(22,2); _shield.graphics.lineTo(40,10); _shield.graphics.lineTo(40,26);
         _shield.graphics.lineTo(22,42); _shield.graphics.lineTo(4,26); _shield.graphics.lineTo(4,10);
         _shield.graphics.lineTo(22,2);
         _shield.filters = [new DropShadowFilter(1,45,0,0.5,2,2)];
         _s.addChild(_shield);
         // 中心装饰
         _m.createGradientBox(12,12,0,16,14);
         var _center:Shape = new Shape();
         _center.graphics.beginGradientFill(GradientType.RADIAL, [0xFFD700,0xB8860B], [1,1], [0,255], _m);
         _center.graphics.drawCircle(22,20,7);
         _center.graphics.endFill();
         _center.graphics.lineStyle(1,0xFFFFFF,0.5);
         _center.graphics.drawCircle(22,20,5);
         _s.addChild(_center);
         _bd.draw(_s);
         _cache["armor"] = _bd;
         return new Bitmap(_bd);
      }

      // 饰品图标(绿色调)
      public static function accessory() : Bitmap
      {
         if(_cache["accessory"]) return new Bitmap(_cache["accessory"] as BitmapData);
         var _bd:BitmapData = new BitmapData(44, 44, true, 0);
         var _s:Sprite = new Sprite();
         var _m:Matrix = new Matrix();
         // 宝石主体
         _m.createGradientBox(28,34,Math.PI/4,8,4);
         var _gem:Shape = new Shape();
         _gem.graphics.beginGradientFill(GradientType.LINEAR, [0x66DD88,0x33AA55,0x228844], [1,1,1], [0,128,255], _m);
         _gem.graphics.moveTo(22,2); _gem.graphics.lineTo(40,18); _gem.graphics.lineTo(22,42);
         _gem.graphics.lineTo(4,18); _gem.graphics.lineTo(22,2);
         _gem.graphics.endFill();
         _gem.graphics.lineStyle(1,0x88EEAA,0.5);
         _gem.graphics.moveTo(22,2); _gem.graphics.lineTo(40,18); _gem.graphics.lineTo(22,42);
         _gem.graphics.lineTo(4,18); _gem.graphics.lineTo(22,2);
         _gem.filters = [new DropShadowFilter(1,45,0,0.5,2,2)];
         _s.addChild(_gem);
         // 高光
         _m.createGradientBox(8,8,0,16,10);
         var _highlight:Shape = new Shape();
         _highlight.graphics.beginGradientFill(GradientType.RADIAL, [0xFFFFFF,0xFFFFFF], [0.7,0], [0,255], _m);
         _highlight.graphics.drawCircle(18,14,6);
         _highlight.graphics.endFill();
         _s.addChild(_highlight);
         _bd.draw(_s);
         _cache["accessory"] = _bd;
         return new Bitmap(_bd);
      }
   }
}
