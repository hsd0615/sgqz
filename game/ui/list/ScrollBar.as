package game.ui.list
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   
   public class ScrollBar extends BaseUI
   {
      
      private static const BLOCK_HEIGHT:int = 20;
       
      
      private var __upArrow:MovieClip;
      
      private var __block:MovieClip;
      
      private var __downArrow:MovieClip;
      
      private var __bk:MovieClip;
      
      private var _target:IScrollElement;
      
      public var scroll:Number = 30;
      
      public function ScrollBar(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__upArrow = _skin.getChildByName("_upArrow") as MovieClip;
         this.__block = _skin.getChildByName("_block") as MovieClip;
         this.__downArrow = _skin.getChildByName("_downArrow") as MovieClip;
         this.__bk = _skin.getChildByName("_bk") as MovieClip;
      }
      
      override protected function initEvent() : void
      {
         this.__upArrow.addEventListener(MouseEvent.MOUSE_DOWN,this.upArrowMouseDownHandler);
         this.__upArrow.addEventListener(MouseEvent.MOUSE_UP,this.upArrowMouseUpHandler);
         this.__block.addEventListener(MouseEvent.MOUSE_DOWN,this.blockMouseDownHandler);
         this.__block.addEventListener(MouseEvent.MOUSE_UP,this.blockMouseUpHandler);
         this.__downArrow.addEventListener(MouseEvent.MOUSE_DOWN,this.downArrowMouseDownHandler);
         this.__downArrow.addEventListener(MouseEvent.MOUSE_UP,this.downArrowMouseUpHandler);
         this.__bk.addEventListener(MouseEvent.MOUSE_DOWN,this.bkMouseDownHandler);
         this.__bk.addEventListener(MouseEvent.MOUSE_UP,this.bkMouseUpHandler);
         addEventListener(Event.REMOVED_FROM_STAGE,this.removeFromStageHandler);
      }
      
      public function get target() : IScrollElement
      {
         return this._target;
      }
      
      public function set target(param1:IScrollElement) : *
      {
         if(this._target != null)
         {
            this._target.removeEventListener(Event.CHANGE,this.onTargetChangeHandler);
         }
         if(param1 == null)
         {
            if(this._target != null)
            {
               this._target.removeEventListener(Event.CHANGE,this.onTargetChangeHandler);
               this._target.removeEventListener("scroll",this.onTargetScrollHandler);
               stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onBlockDownAndMoveHandler);
               stage.removeEventListener(MouseEvent.MOUSE_UP,this.blockMouseUpHandler);
               this._target = null;
            }
         }
         else
         {
            this._target = param1;
            this._target.addEventListener(Event.CHANGE,this.onTargetChangeHandler);
            this._target.addEventListener("scroll",this.onTargetScrollHandler);
            this.resetBlock();
         }
      }
      
      public function setScrollToTop() : *
      {
         if(this._target != null)
         {
            this._target.maskY = this._target.minScroll;
            this.resetBlock();
         }
      }
      
      private function resetBlock() : *
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this._target.maxScroll == 0)
         {
            this.__block.scaleY = this.__bk.height / (this.__block.height / this.__block.scaleY);
            this.__block.y = this.__bk.y;
         }
         else
         {
            _loc1_ = this.__block.height / this.__block.scaleY;
            _loc2_ = BLOCK_HEIGHT / _loc1_;
            _loc3_ = this.__bk.height * this.scroll / (this._target.maxScroll + this.scroll) / _loc1_;
            if(_loc3_ < _loc2_)
            {
               this.__block.scaleY = _loc2_;
            }
            else
            {
               this.__block.scaleY = _loc3_;
            }
            this.__block.y = this.__bk.y + this._target.maskY * (this.__bk.height - this.__block.height) / this._target.maxScroll;
            if(this.__block.y + this.__block.height > this.__bk.y + this.__bk.height)
            {
               this.__block.y = this.__bk.y + this.__bk.height - this.__block.height;
               this._target.maskY = this._target.maxScroll;
            }
         }
      }
      
      private function onTargetChangeHandler(param1:Event) : *
      {
         this._target.maskY = this._target.maxScroll;
         this.resetBlock();
      }
      
      private function onTargetScrollHandler(param1:Event) : *
      {
         this.resetBlock();
      }
      
      private function upArrowMouseDownHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._target != null)
         {
            if(this._target.maskY - this.scroll < 0)
            {
               this._target.maskY = 0;
            }
            else
            {
               this._target.maskY -= this.scroll;
            }
            this.resetBlock();
         }
      }
      
      private function upArrowMouseUpHandler(param1:MouseEvent) : *
      {
      }
      
      private function blockMouseDownHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._target.maxScroll == 0)
         {
            return;
         }
         if(this._target != null)
         {
            this.__block.startDrag(false,new Rectangle(this.__bk.x,this.__bk.y,0,this.__bk.height - this.__block.height));
            stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onBlockDownAndMoveHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP,this.blockMouseUpHandler);
         }
      }
      
      private function onBlockDownAndMoveHandler(param1:MouseEvent) : *
      {
         var _loc2_:Number = NaN;
         if(this._target != null)
         {
            _loc2_ = (this.__block.y - this.__bk.y) / (this.__bk.height - this.__block.height) * this._target.maxScroll;
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            else if(_loc2_ > this._target.maxScroll)
            {
               _loc2_ = this._target.maxScroll;
            }
            this._target.maskY = _loc2_;
         }
      }
      
      private function blockMouseUpHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onBlockDownAndMoveHandler);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.blockMouseUpHandler);
         this.__block.stopDrag();
      }
      
      private function downArrowMouseDownHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._target != null)
         {
            if(this._target.maskY + this.scroll > this._target.maxScroll)
            {
               this._target.maskY = this._target.maxScroll;
            }
            else
            {
               this._target.maskY += this.scroll;
            }
            this.resetBlock();
         }
      }
      
      private function downArrowMouseUpHandler(param1:MouseEvent) : *
      {
      }
      
      private function bkMouseDownHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._target != null)
         {
            if(mouseY < this.__block.y)
            {
               this._target.maskY -= this.scroll;
            }
            else
            {
               this._target.maskY += this.scroll;
            }
            this.resetBlock();
         }
      }
      
      private function bkMouseUpHandler(param1:MouseEvent) : *
      {
      }
      
      private function removeFromStageHandler(param1:Event) : *
      {
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onBlockDownAndMoveHandler);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.blockMouseUpHandler);
      }
   }
}
