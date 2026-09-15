package game.ui.list
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import game.ui.SkinCode;
   
   public class StageList extends Sprite implements IScrollElement
   {
       
      
      private var _mask:Rectangle;
      
      private var _itemContainer:Sprite;
      
      private var _lineSpace:int;
      
      private var _currentItem:StageListItem;
      
      private var _arr:Vector.<StageListItem>;
      
      public function StageList(param1:Number, param2:Number, param3:int = 1)
      {
         super();
         this._arr = new Vector.<StageListItem>();
         this._mask = new Rectangle(0,0,param1,param2);
         this.scrollRect = this._mask;
         this._itemContainer = new Sprite();
         addChild(this._itemContainer);
         this._lineSpace = param3;
         this._itemContainer.addEventListener(MouseEvent.CLICK,this.onItemContainerClickHandler);
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
      
      public function get maskWidth() : Number
      {
         return scrollRect.width;
      }
      
      public function set maskWidth(param1:Number) : *
      {
         this._mask = this.scrollRect;
         this._mask.width = param1;
         this.scrollRect = this._mask;
      }
      
      public function get maskHeight() : Number
      {
         return scrollRect.height;
      }
      
      public function set maskHeight(param1:Number) : *
      {
         this._mask = this.scrollRect;
         this._mask.height = param1;
         this.scrollRect = this._mask;
      }
      
      public function initData(param1:Object) : *
      {
         var _loc2_:StageListItem = null;
         var _loc3_:* = undefined;
         this.clear();
         for(_loc3_ in param1)
         {
            this.addItem(param1[_loc3_]);
         }
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHandler);
      }
      
      private function onMouseOverHandler(param1:MouseEvent) : void
      {
         addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheelHandler);
      }
      
      private function onMouseWheelHandler(param1:MouseEvent) : void
      {
         this.maskY -= param1.delta * 4;
         dispatchEvent(new Event("scroll"));
      }
      
      public function clear() : *
      {
         while(this._arr.length > 0)
         {
            this._arr.pop();
         }
         while(this._itemContainer.numChildren > 0)
         {
            this._itemContainer.removeChildAt(0);
         }
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHandler);
      }
      
      public function addItem(param1:Object) : *
      {
         var _loc2_:StageListItem = null;
         _loc2_ = new StageListItem(SkinCode.STAGE_LIST_ITEM);
         var _loc3_:int = int(this._arr.length);
         _loc2_.name = "item_" + _loc3_;
         if(_loc3_ % 2 == 0)
         {
            _loc2_.setBK(1);
         }
         else
         {
            _loc2_.setBK(2);
         }
         _loc2_.initData(param1);
         _loc2_.y = _loc3_ * (_loc2_.getRect(this._itemContainer).height + this._lineSpace);
         this._itemContainer.addChild(_loc2_);
         this._arr.push(_loc2_);
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function onItemContainerClickHandler(param1:MouseEvent) : *
      {
         if(this._currentItem != null)
         {
            this._currentItem.setActive(false);
         }
         this._currentItem = param1.target as StageListItem;
         this._currentItem.setActive(true);
      }
      
      public function get item() : StageListItem
      {
         return this._currentItem;
      }
      
      public function get itemIndex() : int
      {
         if(this._currentItem == null)
         {
            return -1;
         }
         return int(this._currentItem.name.split("_")[1]);
      }
      
      public function get minScroll() : Number
      {
         return 0;
      }
      
      public function get maxScroll() : Number
      {
         if(this._itemContainer.height <= this._mask.height)
         {
            return 0;
         }
         return this._itemContainer.height - this._mask.height;
      }
   }
}
