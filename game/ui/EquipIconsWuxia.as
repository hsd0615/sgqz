package game.ui
{
   import flash.display.Bitmap;

   // 46个武侠装备图标 - 从爱给网下载的免费素材
   public class EquipIconsWuxia
   {
      [Embed(source="../../assets/icons/wuxia/equip_01.png")] private static var _e01:Class;
      [Embed(source="../../assets/icons/wuxia/equip_02.png")] private static var _e02:Class;
      [Embed(source="../../assets/icons/wuxia/equip_03.png")] private static var _e03:Class;
      [Embed(source="../../assets/icons/wuxia/equip_04.png")] private static var _e04:Class;
      [Embed(source="../../assets/icons/wuxia/equip_05.png")] private static var _e05:Class;
      [Embed(source="../../assets/icons/wuxia/equip_06.png")] private static var _e06:Class;
      [Embed(source="../../assets/icons/wuxia/equip_07.png")] private static var _e07:Class;
      [Embed(source="../../assets/icons/wuxia/equip_08.png")] private static var _e08:Class;
      [Embed(source="../../assets/icons/wuxia/equip_09.png")] private static var _e09:Class;
      [Embed(source="../../assets/icons/wuxia/equip_10.png")] private static var _e10:Class;
      [Embed(source="../../assets/icons/wuxia/equip_11.png")] private static var _e11:Class;
      [Embed(source="../../assets/icons/wuxia/equip_12.png")] private static var _e12:Class;
      [Embed(source="../../assets/icons/wuxia/equip_13.png")] private static var _e13:Class;
      [Embed(source="../../assets/icons/wuxia/equip_14.png")] private static var _e14:Class;
      [Embed(source="../../assets/icons/wuxia/equip_15.png")] private static var _e15:Class;
      [Embed(source="../../assets/icons/wuxia/equip_16.png")] private static var _e16:Class;
      [Embed(source="../../assets/icons/wuxia/equip_17.png")] private static var _e17:Class;
      [Embed(source="../../assets/icons/wuxia/equip_18.png")] private static var _e18:Class;
      [Embed(source="../../assets/icons/wuxia/equip_19.png")] private static var _e19:Class;
      [Embed(source="../../assets/icons/wuxia/equip_20.png")] private static var _e20:Class;
      [Embed(source="../../assets/icons/wuxia/equip_21.png")] private static var _e21:Class;
      [Embed(source="../../assets/icons/wuxia/equip_22.png")] private static var _e22:Class;
      [Embed(source="../../assets/icons/wuxia/equip_23.png")] private static var _e23:Class;
      [Embed(source="../../assets/icons/wuxia/equip_24.png")] private static var _e24:Class;
      [Embed(source="../../assets/icons/wuxia/equip_25.png")] private static var _e25:Class;
      [Embed(source="../../assets/icons/wuxia/equip_26.png")] private static var _e26:Class;
      [Embed(source="../../assets/icons/wuxia/equip_27.png")] private static var _e27:Class;
      [Embed(source="../../assets/icons/wuxia/equip_28.png")] private static var _e28:Class;
      [Embed(source="../../assets/icons/wuxia/equip_29.png")] private static var _e29:Class;
      [Embed(source="../../assets/icons/wuxia/equip_30.png")] private static var _e30:Class;
      [Embed(source="../../assets/icons/wuxia/equip_31.png")] private static var _e31:Class;
      [Embed(source="../../assets/icons/wuxia/equip_32.png")] private static var _e32:Class;
      [Embed(source="../../assets/icons/wuxia/equip_33.png")] private static var _e33:Class;
      [Embed(source="../../assets/icons/wuxia/equip_34.png")] private static var _e34:Class;
      [Embed(source="../../assets/icons/wuxia/equip_35.png")] private static var _e35:Class;
      [Embed(source="../../assets/icons/wuxia/equip_36.png")] private static var _e36:Class;
      [Embed(source="../../assets/icons/wuxia/equip_37.png")] private static var _e37:Class;
      [Embed(source="../../assets/icons/wuxia/equip_38.png")] private static var _e38:Class;
      [Embed(source="../../assets/icons/wuxia/equip_39.png")] private static var _e39:Class;
      [Embed(source="../../assets/icons/wuxia/equip_40.png")] private static var _e40:Class;
      [Embed(source="../../assets/icons/wuxia/equip_41.png")] private static var _e41:Class;
      [Embed(source="../../assets/icons/wuxia/equip_42.png")] private static var _e42:Class;
      [Embed(source="../../assets/icons/wuxia/equip_43.png")] private static var _e43:Class;
      [Embed(source="../../assets/icons/wuxia/equip_44.png")] private static var _e44:Class;
      [Embed(source="../../assets/icons/wuxia/equip_45.png")] private static var _e45:Class;
      [Embed(source="../../assets/icons/wuxia/equip_46.png")] private static var _e46:Class;

      private static var _classes:Array = [
         _e01,_e02,_e03,_e04,_e05,_e06,_e07,_e08,
         _e09,_e10,_e11,_e12,_e13,_e14,_e15,_e16,
         _e17,_e18,_e19,_e20,_e21,_e22,_e23,_e24,
         _e25,_e26,_e27,_e28,_e29,_e30,_e31,_e32,
         _e33,_e34,_e35,_e36,_e37,_e38,_e39,_e40,
         _e41,_e42,_e43,_e44,_e45,_e46
      ];

      public static function getIcon(param1:int) : Bitmap
      {
         if(param1 < 1 || param1 > 46) return null;
         var _b:Bitmap = new _classes[param1 - 1]() as Bitmap;
         _b.smoothing = true;
         return _b;
      }
   }
}
