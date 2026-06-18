package game.ui {
   import flash.display.Bitmap;
   public class EquipIconsWuxia {
      [Embed(source="../../assets/icons/wuxia/头盔_九龙冠.png")] private static var _i01:Class;
      [Embed(source="../../assets/icons/wuxia/头盔_天尊冠.png")] private static var _i02:Class;
      [Embed(source="../../assets/icons/wuxia/头盔_混沌盔.png")] private static var _i03:Class;
      [Embed(source="../../assets/icons/wuxia/头盔_灵蛇盔.png")] private static var _i04:Class;
      [Embed(source="../../assets/icons/wuxia/战靴_凌波靴.png")] private static var _i05:Class;
      [Embed(source="../../assets/icons/wuxia/战靴_虚空靴.png")] private static var _i06:Class;
      [Embed(source="../../assets/icons/wuxia/战靴_风云靴.png")] private static var _i07:Class;
      [Embed(source="../../assets/icons/wuxia/护甲_玄武战甲.png")] private static var _i08:Class;
      [Embed(source="../../assets/icons/wuxia/护甲_皮甲.png")] private static var _i09:Class;
      [Embed(source="../../assets/icons/wuxia/护甲_麒麟铠.png")] private static var _i10:Class;
      [Embed(source="../../assets/icons/wuxia/武器_丈八蛇矛.png")] private static var _i11:Class;
      [Embed(source="../../assets/icons/wuxia/武器_倚天剑.png")] private static var _i12:Class;
      [Embed(source="../../assets/icons/wuxia/武器_寒月刀.png")] private static var _i13:Class;
      [Embed(source="../../assets/icons/wuxia/武器_方天画戟.png")] private static var _i14:Class;
      [Embed(source="../../assets/icons/wuxia/武器_灭世.png")] private static var _i15:Class;
      [Embed(source="../../assets/icons/wuxia/武器_神罚.png")] private static var _i16:Class;
      [Embed(source="../../assets/icons/wuxia/武器_精钢剑.png")] private static var _i17:Class;
      [Embed(source="../../assets/icons/wuxia/武器_铁剑.png")] private static var _i18:Class;
      [Embed(source="../../assets/icons/wuxia/武器_青釭剑.png")] private static var _i19:Class;
      [Embed(source="../../assets/icons/wuxia/武器_青龙偃月.png")] private static var _i20:Class;
      [Embed(source="../../assets/icons/wuxia/饰品_七杀戒.png")] private static var _i21:Class;
      [Embed(source="../../assets/icons/wuxia/饰品_和氏璧.png")] private static var _i22:Class;
      [Embed(source="../../assets/icons/wuxia/饰品_嗜血魔符.png")] private static var _i23:Class;
      [Embed(source="../../assets/icons/wuxia/饰品_天地令.png")] private static var _i24:Class;
      [Embed(source="../../assets/icons/wuxia/饰品_混沌珠.png")] private static var _i25:Class;
      [Embed(source="../../assets/icons/wuxia/饰品_紫微星.png")] private static var _i26:Class;
      [Embed(source="../../assets/icons/wuxia/饰品_翡翠环.png")] private static var _i27:Class;
      [Embed(source="../../assets/icons/wuxia/饰品_贪狼令.png")] private static var _i28:Class;
      [Embed(source="../../assets/icons/wuxia/饰品_轮回印.png")] private static var _i29:Class;
      [Embed(source="../../assets/icons/wuxia/饰品_铜戒指.png")] private static var _i30:Class;

      private static var _c:Array=[_i01,_i02,_i03,_i04,_i05,_i06,_i07,_i08,_i09,_i10,_i11,_i12,_i13,_i14,_i15,_i16,_i17,_i18,_i19,_i20,_i21,_i22,_i23,_i24,_i25,_i26,_i27,_i28,_i29,_i30];

      public static function getIcon(idx:int):Bitmap {
         if(idx<1||idx>30) return null;
         var b:Bitmap=new _c[idx-1]() as Bitmap;
         b.smoothing=true; return b;
      }
   }
}
