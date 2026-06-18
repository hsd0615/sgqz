package game.ui
{
   import flash.display.Bitmap;

   // 46个武侠装备图标 — 按类型分类
   public class EquipIconsWuxia
   {
      // 武器 01-08
      [Embed(source="../../assets/icons/wuxia/weapon_01.png")] private static var _w01:Class;
      [Embed(source="../../assets/icons/wuxia/weapon_02.png")] private static var _w02:Class;
      [Embed(source="../../assets/icons/wuxia/weapon_03.png")] private static var _w03:Class;
      [Embed(source="../../assets/icons/wuxia/weapon_04.png")] private static var _w04:Class;
      [Embed(source="../../assets/icons/wuxia/weapon_05.png")] private static var _w05:Class;
      [Embed(source="../../assets/icons/wuxia/weapon_06.png")] private static var _w06:Class;
      [Embed(source="../../assets/icons/wuxia/weapon_07.png")] private static var _w07:Class;
      [Embed(source="../../assets/icons/wuxia/weapon_08.png")] private static var _w08:Class;
      // 护甲 01-08
      [Embed(source="../../assets/icons/wuxia/armor_01.png")] private static var _a01:Class;
      [Embed(source="../../assets/icons/wuxia/armor_02.png")] private static var _a02:Class;
      [Embed(source="../../assets/icons/wuxia/armor_03.png")] private static var _a03:Class;
      [Embed(source="../../assets/icons/wuxia/armor_04.png")] private static var _a04:Class;
      [Embed(source="../../assets/icons/wuxia/armor_05.png")] private static var _a05:Class;
      [Embed(source="../../assets/icons/wuxia/armor_06.png")] private static var _a06:Class;
      [Embed(source="../../assets/icons/wuxia/armor_07.png")] private static var _a07:Class;
      [Embed(source="../../assets/icons/wuxia/armor_08.png")] private static var _a08:Class;
      // 头盔 01-08
      [Embed(source="../../assets/icons/wuxia/helmet_01.png")] private static var _h01:Class;
      [Embed(source="../../assets/icons/wuxia/helmet_02.png")] private static var _h02:Class;
      [Embed(source="../../assets/icons/wuxia/helmet_03.png")] private static var _h03:Class;
      [Embed(source="../../assets/icons/wuxia/helmet_04.png")] private static var _h04:Class;
      [Embed(source="../../assets/icons/wuxia/helmet_05.png")] private static var _h05:Class;
      [Embed(source="../../assets/icons/wuxia/helmet_06.png")] private static var _h06:Class;
      [Embed(source="../../assets/icons/wuxia/helmet_07.png")] private static var _h07:Class;
      [Embed(source="../../assets/icons/wuxia/helmet_08.png")] private static var _h08:Class;
      // 战靴 01-08
      [Embed(source="../../assets/icons/wuxia/boots_01.png")] private static var _b01:Class;
      [Embed(source="../../assets/icons/wuxia/boots_02.png")] private static var _b02:Class;
      [Embed(source="../../assets/icons/wuxia/boots_03.png")] private static var _b03:Class;
      [Embed(source="../../assets/icons/wuxia/boots_04.png")] private static var _b04:Class;
      [Embed(source="../../assets/icons/wuxia/boots_05.png")] private static var _b05:Class;
      [Embed(source="../../assets/icons/wuxia/boots_06.png")] private static var _b06:Class;
      [Embed(source="../../assets/icons/wuxia/boots_07.png")] private static var _b07:Class;
      [Embed(source="../../assets/icons/wuxia/boots_08.png")] private static var _b08:Class;
      // 饰品 01-14
      [Embed(source="../../assets/icons/wuxia/acc_01.png")] private static var _s01:Class;
      [Embed(source="../../assets/icons/wuxia/acc_02.png")] private static var _s02:Class;
      [Embed(source="../../assets/icons/wuxia/acc_03.png")] private static var _s03:Class;
      [Embed(source="../../assets/icons/wuxia/acc_04.png")] private static var _s04:Class;
      [Embed(source="../../assets/icons/wuxia/acc_05.png")] private static var _s05:Class;
      [Embed(source="../../assets/icons/wuxia/acc_06.png")] private static var _s06:Class;
      [Embed(source="../../assets/icons/wuxia/acc_07.png")] private static var _s07:Class;
      [Embed(source="../../assets/icons/wuxia/acc_08.png")] private static var _s08:Class;
      [Embed(source="../../assets/icons/wuxia/acc_09.png")] private static var _s09:Class;
      [Embed(source="../../assets/icons/wuxia/acc_10.png")] private static var _s10:Class;
      [Embed(source="../../assets/icons/wuxia/acc_11.png")] private static var _s11:Class;
      [Embed(source="../../assets/icons/wuxia/acc_12.png")] private static var _s12:Class;
      [Embed(source="../../assets/icons/wuxia/acc_13.png")] private static var _s13:Class;
      [Embed(source="../../assets/icons/wuxia/acc_14.png")] private static var _s14:Class;

      // iconIdx → Class 映射: 1-8武器, 9-16护甲, 17-24头盔, 25-32战靴, 33-46饰品
      private static var _classes:Array = [
         _w01,_w02,_w03,_w04,_w05,_w06,_w07,_w08,       // 1-8
         _a01,_a02,_a03,_a04,_a05,_a06,_a07,_a08,       // 9-16
         _h01,_h02,_h03,_h04,_h05,_h06,_h07,_h08,       // 17-24
         _b01,_b02,_b03,_b04,_b05,_b06,_b07,_b08,       // 25-32
         _s01,_s02,_s03,_s04,_s05,_s06,_s07,_s08,       // 33-40
         _s09,_s10,_s11,_s12,_s13,_s14                   // 41-46
      ];

      public static function getIcon(param1:int) : Bitmap
      {
         if(param1 < 1 || param1 > 46) return null;
         var _b:Bitmap = new _classes[param1 - 1]() as Bitmap;
         _b.smoothing = true;
         return _b;
      }

      /** 根据slot返回合适的图标列表, 供随机或默认选择 */
      public static function getIconBySlot(slot:int, quality:int) : Bitmap
      {
         var _base:int;
         if(slot == 1) _base = 0;       // 武器 1-8
         else if(slot == 2) _base = 8;  // 护甲 9-16
         else if(slot == 3 || slot == 6) _base = 32; // 饰品 33-46
         else if(slot == 4) _base = 16; // 头盔 17-24
         else if(slot == 5) _base = 24; // 战靴 25-32
         else _base = 0;

         var _idx:int = _base + Math.min(quality, slot==6?6:8);
         return getIcon(_idx);
      }
   }
}
