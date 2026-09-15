package game.ui
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import game.ui.list.IScrollElement;

   /**
    * 可滚动排行列表容器 — 实现 IScrollElement 以支持 ScrollBar
    */
   public class RankingContainer extends Sprite implements IScrollElement
   {
      private var _sp:Sprite;
      private var _maskRect:Rectangle;

      public function RankingContainer(w:int, h:int)
      {
         super();
         this._sp = new Sprite();
         addChild(this._sp);
         this._maskRect = new Rectangle(0, 0, w, h);
         this.scrollRect = this._maskRect;
      }

      public function get content() : Sprite { return this._sp; }

      /**
       * 启用鼠标滚轮滚动
       */
      public function enableMouseWheel() : void
      {
         addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelHandler);
      }

      private function onMouseWheelHandler(e:MouseEvent) : void
      {
         if(maxScroll <= 0) return;
         this.maskY -= e.delta * 4;
         dispatchEvent(new Event("scroll"));
      }

      // ==== IScrollElement ====
      public function get maskX() : Number { return scrollRect.x; }
      public function set maskX(v:Number) : *
      {
         this._maskRect = scrollRect;
         this._maskRect.x = v;
         this.scrollRect = this._maskRect;
      }
      public function get maskY() : Number { return scrollRect.y; }
      public function set maskY(v:Number) : *
      {
         this._maskRect = scrollRect;
         if(v < minScroll) v = minScroll;
         if(v > maxScroll) v = maxScroll;
         this._maskRect.y = v;
         this.scrollRect = this._maskRect;
      }
      public function get minScroll() : Number { return 0; }
      public function get maxScroll() : Number
      {
         var _ch:Number = this._sp.height;
         var _mh:Number = this._maskRect.height;
         if(_ch <= _mh) return 0;
         return _ch - _mh + 4;
      }
   }
}
