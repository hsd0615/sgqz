package game.ui
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import game.ui.list.IScrollElement;
   
   public class LeitaiContainer extends Sprite implements IScrollElement
   {
       
      
      private var _leitaiArr:Vector.<Leitai>;
      
      private var _mask:Rectangle;
      
      private var _sp:Sprite;
      
      public function LeitaiContainer()
      {
         super();
         this.initView();
      }
      
      private function initView() : *
      {
         this._sp = new Sprite();
         addChild(this._sp);
         this._sp.x = 35;
         this._sp.y = 17;
         this.createLeitai();
      }
      
      private function createLeitai() : *
      {
         var _loc1_:Leitai = null;
         this._leitaiArr = new Vector.<Leitai>();
         var _loc2_:int = 0;
         while(_loc2_ < 48)
         {
            _loc1_ = new Leitai(SkinCode.LEITAI);
            _loc1_.x = _loc2_ % 3 * 145;
            _loc1_.y = int(_loc2_ / 3) * 348;
            this._sp.addChild(_loc1_);
            this._leitaiArr.push(_loc1_);
            _loc2_++;
         }
         this._mask = new Rectangle(0,0,466,396);
         this.scrollRect = this._mask;
      }
      
      public function initData(param1:Array) : *
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._leitaiArr.length)
         {
            if(_loc2_ < param1.length)
            {
               this._leitaiArr[_loc2_].initData(param1[_loc2_]);
            }
            _loc2_++;
         }
         addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheelHandler);
      }
      
      private function onMouseWheelHandler(param1:MouseEvent) : void
      {
         if(this.maskY == 0)
         {
            return;
         }
         this.maskY -= param1.delta * 4;
         dispatchEvent(new Event("scroll"));
      }
      
      public function get maskX() : Number
      {
         return scrollRect.x;
      }
      
      public function set maskX(param1:Number) : *
      {
         this._mask = this.scrollRect;
         this._mask.x = param1;
         this.scrollRect = this._mask;
      }
      
      public function get maskY() : Number
      {
         return scrollRect.y;
      }
      
      public function set maskY(param1:Number) : *
      {
         this._mask = this.scrollRect;
         if(param1 < this.minScroll)
         {
            param1 = this.minScroll;
         }
         else if(param1 > this.maxScroll)
         {
            param1 = this.maxScroll;
         }
         this._mask.y = param1;
         this.scrollRect = this._mask;
      }
      
      public function get minScroll() : Number
      {
         return 0;
      }
      
      public function get maxScroll() : Number
      {
         if(this._sp.height <= this._mask.height)
         {
            return 0;
         }
         return this._sp.height - this._mask.height + 34;
      }
   }
}
