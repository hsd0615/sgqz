package game.ui
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Elastic;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import game.model.EquipData;

   /**
    * 装备掉落地面特效 — 敌方死亡时播放装备掉落动画
    * 图标和品质边框与BagPanel一致
    */
   public class EquipDropFX extends Sprite
   {
      // 品质背景色 (与BagPanel._qualityBgColors一致)
      private static const BG_COLORS:Array = [
         0x333333, 0x555555, 0x555555, 0x1a3a0a, 0x1a3a0a,
         0x2a0a2a, 0x2a0a2a, 0x3a1a00, 0x3a1a00, 0x3a0000, 0x3a0a0a
      ];
      // 品质外发光颜色
      private static const GLOW_COLORS:Array = [
         0x666666, 0x999999, 0x999999, 0x33CC33, 0x33CC33,
         0xCC33CC, 0xCC33CC, 0xFF8800, 0xFF8800, 0xFF3333, 0xFF66FF, 0xFF0040
      ];
      // 品质名
      private static const Q_NAMES:Array = [
         "", "普通", "精良", "稀有", "史诗", "传说", "神话", "远古", "至尊", "超凡", "入圣", "魔器"
      ];

      private var _container:Sprite;
      private var _bg:Shape;
      private var _icon:Bitmap;
      private var _nameTF:TextField;
      private var _groundY:Number;

      /**
       * 在指定父容器中显示装备掉落特效
       * @param parent  父容器 (Fight/P2PFight)
       * @param px      掉落X位置 (死亡士兵x)
       * @param py      掉落Y位置 (死亡士兵y)
       * @param equipCode 装备code (proto_4_xx)
       */
      public static function show(parent:Sprite, px:Number, py:Number, equipCode:String):void
      {
         var fx:EquipDropFX = new EquipDropFX();
         fx.init(equipCode, py);
         fx.x = px;
         fx.y = py;
         parent.addChild(fx);
      }

      public function EquipDropFX()
      {
         super();
         this.mouseChildren = false;
         this.mouseEnabled = false;
      }

      private function init(equipCode:String, startY:Number):void
      {
         _groundY = startY + 30;
         _container = new Sprite();
         addChild(_container);

         // 获取装备数据
         var quality:int = int(EquipData.get(equipCode, "quality"));
         if(quality < 1) quality = 1;
         if(quality > 10) quality = 10;
         var eqName:String = String(EquipData.get(equipCode, "name") || "??");
         var iconIdx:int = int(EquipData.get(equipCode, "iconIdx"));
         if(iconIdx < 1) iconIdx = 11; // 默认武器图标

         // 品质背景
         _bg = new Shape();
         _bg.graphics.beginFill(BG_COLORS[quality], 0.85);
         _bg.graphics.drawRoundRect(0, 0, 44, 44, 5, 5);
         _bg.graphics.endFill();
         // 边框
         _bg.graphics.lineStyle(1.5, GLOW_COLORS[quality], 0.9);
         _bg.graphics.drawRoundRect(0, 0, 44, 44, 5, 5);
         _container.addChild(_bg);

         // 装备图标
         if(iconIdx > 0)
         {
            _icon = EquipIconsWuxia.getIcon(iconIdx);
            if(_icon != null)
            {
               var scale:Number = 36 / Math.max(_icon.width, _icon.height);
               _icon.scaleX = scale;
               _icon.scaleY = scale;
               _icon.smoothing = true;
               _icon.x = int((44 - _icon.width) / 2);
               _icon.y = int((44 - _icon.height) / 2);
               _container.addChild(_icon);
            }
         }

         // 品质光晕
         _container.filters = [new GlowFilter(GLOW_COLORS[quality], 0.7, 10, 10, 2, 3)];

         // 名称文字
         _nameTF = new TextField();
         _nameTF.defaultTextFormat = new TextFormat("SimSun", 10, GLOW_COLORS[quality], true);
         _nameTF.autoSize = TextFieldAutoSize.CENTER;
         _nameTF.selectable = false;
         _nameTF.text = eqName + " " + Q_NAMES[quality];
         _nameTF.x = int((44 - _nameTF.width) / 2);
         _nameTF.y = 46;
         _nameTF.alpha = 0;
         _container.addChild(_nameTF);

         // 动画序列: 从上方掉落 → 弹跳 → 光晕闪烁 → 文字浮现 → 淡出
         _container.y = -80; // 从上方开始
         _container.alpha = 1;

         // 帧1: 快速下坠 (0.3s)
         TweenLite.to(_container, 0.3, {
            y: 0,
            ease: Elastic.easeIn,
            onComplete: function():void {
               // 帧2: 文字浮现
               TweenLite.to(_nameTF, 0.3, { alpha: 1, y: 46 });
               // 帧3: 渐隐 (2s后淡出)
               TweenLite.to(_container, 0.5, {
                  alpha: 0,
                  delay: 2.0,
                  onComplete: function():void {
                     if(parent) parent.removeChild(this as EquipDropFX);
                  }
               });
            }
         });
      }
   }
}
