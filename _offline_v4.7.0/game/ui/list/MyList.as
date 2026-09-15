package game.ui.list
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import game.model.RoleStatus;
   import game.ui.SkinCode;
   
   public class MyList extends Sprite implements IScrollElement
   {
       
      
      private var _mask:Rectangle;
      
      private var _itemContainer:Sprite;
      
      private var _lineSpace:int;
      
      private var _currentItem:ListItem;
      
      private var _arr:Vector.<ListItem>;
      
      public function MyList(param1:Number, param2:Number, param3:int = 1)
      {
         super();
         this._arr = new Vector.<ListItem>();
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
      
      public function initData(param1:Object, param2:Boolean) : *
      {
         var _loc3_:ListItem = null;
         var _loc4_:* = undefined;
         this.clear();
         for(_loc4_ in param1)
         {
            this.addItem(param1[_loc4_],param2);
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
      
      public function addItem(param1:Object, param2:Boolean) : *
      {
         var _loc3_:ListItem = null;
         _loc3_ = null;
         var _loc4_:int = 0;
         while(_loc4_ < this._arr.length)
         {
            _loc3_ = this._arr[_loc4_];
            if(_loc3_.pID == param1.pID)
            {
               return;
            }
            _loc4_++;
         }
         if(param2 == true && param1.status != RoleStatus.NOMAL)
         {
            return;
         }
         _loc3_ = new ListItem(SkinCode.LIST_ITEM);
         var _loc5_:int = int(this._arr.length);
         _loc3_.name = "item_" + _loc5_;
         if(_loc5_ % 2 == 0)
         {
            _loc3_.setBK(1);
         }
         else
         {
            _loc3_.setBK(2);
         }
         _loc3_.initData(param1);
         _loc3_.y = _loc5_ * (_loc3_.getRect(this._itemContainer).height + this._lineSpace);
         this._itemContainer.addChild(_loc3_);
         this._arr.push(_loc3_);
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function removeItem(param1:String) : *
      {
         var _loc2_:ListItem = null;
         var _loc3_:String = null;
         var _loc4_:int = int(this._arr.length);
         var _loc5_:int = -1;
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_)
         {
            _loc2_ = this._arr[_loc6_] as ListItem;
            if(param1 == _loc2_.pID)
            {
               _loc5_ = _loc6_;
               break;
            }
            _loc6_++;
         }
         if(_loc5_ != -1)
         {
            _loc2_ = this._itemContainer.getChildByName("item_" + _loc5_) as ListItem;
            if(_loc2_ != null)
            {
               if(_loc2_ == this._currentItem || this._currentItem == null)
               {
                  this._currentItem = null;
                  this._arr.splice(_loc5_,1);
                  this._itemContainer.removeChild(_loc2_);
                  this.reflush();
               }
               else
               {
                  _loc3_ = this._currentItem.pID;
                  this._arr.splice(_loc5_,1);
                  this._itemContainer.removeChild(_loc2_);
                  this.reflush(_loc3_);
               }
            }
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function changeStatus(param1:Object) : *
      {
         var _loc2_:ListItem = null;
         var _loc3_:int = int(this._arr.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = this._arr[_loc4_] as ListItem;
            if(param1.pID == _loc2_.pID)
            {
               _loc2_.setStatus(param1.status);
               break;
            }
            _loc4_++;
         }
      }
      
      private function reflush(param1:String = null) : *
      {
         var _loc2_:ListItem = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._arr.length)
         {
            _loc2_ = this._itemContainer.getChildAt(_loc3_) as ListItem;
            _loc2_.name = "item_" + _loc3_;
            if(_loc3_ % 2 == 0)
            {
               _loc2_.setBK(1);
            }
            else
            {
               _loc2_.setBK(2);
            }
            _loc2_.y = _loc3_ * (_loc2_.getRect(this._itemContainer).height + this._lineSpace);
            if(param1 == _loc2_.pID)
            {
               this._currentItem = _loc2_;
               this._currentItem.setActive(true);
            }
            _loc3_++;
         }
      }
      
      private function onItemContainerClickHandler(param1:MouseEvent) : *
      {
         if(this._currentItem != null)
         {
            this._currentItem.setActive(false);
         }
         this._currentItem = param1.target as ListItem;
         this._currentItem.setActive(true);
      }
      
      public function get item() : ListItem
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
      
      public function getItemByLevel(param1:int) : ListItem
      {
         if(this._arr == null || this._arr.length == 0)
         {
            return null;
         }
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < this._arr.length)
         {
            if(this._arr[_loc2_].getStatus() == RoleStatus.NOMAL && this._arr[_loc2_].getLevel() == param1)
            {
               return this._arr[_loc2_];
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this._arr.length)
         {
            if(this._arr[_loc2_].getStatus() == RoleStatus.NOMAL && this._arr[_loc2_].getLevel() > param1 - 4 && this._arr[_loc2_].getLevel() < param1 + 4)
            {
               return this._arr[_loc2_];
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this._arr.length)
         {
            if(this._arr[_loc2_].getStatus() == RoleStatus.NOMAL && this._arr[_loc2_].getLevel() > param1 - 6 && this._arr[_loc2_].getLevel() < param1 + 6)
            {
               return this._arr[_loc2_];
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this._arr.length)
         {
            if(this._arr[_loc2_].getStatus() == RoleStatus.NOMAL)
            {
               return this._arr[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
   }
}
