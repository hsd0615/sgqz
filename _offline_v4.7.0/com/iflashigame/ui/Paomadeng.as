package com.iflashigame.ui
{
   import com.iflashigame.utils.Tools;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class Paomadeng extends Sprite
   {
       
      
      private var _tf1:TextField;
      
      private var _tf2:TextField;
      
      private var _arr:Array;
      
      private var _recWidth:Number;
      
      private var _recHeight:Number;
      
      private var _speed:Number;
      
      public function Paomadeng(param1:Array, param2:Number = 200, param3:Number = 16, param4:Number = 1, param5:uint = 15658734)
      {
         super();
         this._arr = param1;
         this._recWidth = param2;
         this._recHeight = param3;
         this._speed = param4;
         this._tf1 = new TextField();
         this._tf1.textColor = param5;
         this._tf1.width = this._recWidth;
         this._tf1.height = this._recHeight;
         this._tf1.filters = [new GlowFilter(0,1,2,2,100)];
         this._tf2 = new TextField();
         this._tf2.width = this._recWidth;
         this._tf2.height = this._recHeight;
         this._tf2.x = this._tf1.width;
         addChild(this._tf1);
         addChild(this._tf2);
         scrollRect = new Rectangle(0,0,this._recWidth,this._recHeight);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemoveFromStageHandler);
      }
      
      public function start() : *
      {
         this._tf1.removeEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler1);
         this._tf2.removeEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler2);
         this._tf1.x = this._recWidth + 10;
         this._tf2.x = this._recWidth + 10;
         this.setText(1);
         this._tf1.addEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler1);
      }
      
      private function setText(param1:int) : *
      {
         if(param1 == 1)
         {
            this._tf1.text = Tools.randomFromArr(this._arr);
            this._tf1.width = this._tf1.textWidth + 5;
            this._tf1.height = this._recHeight;
         }
         else if(param1 == 2)
         {
            this._tf2.text = Tools.randomFromArr(this._arr);
            this._tf2.width = this._tf2.textWidth + 5;
         }
      }
      
      private function onEnterFrameHandler1(param1:Event) : *
      {
         this._tf1.x -= this._speed;
         if(this._tf1.x < -this._tf1.width)
         {
            this._tf1.x = this._recWidth + 10;
            this.setText(1);
         }
      }
      
      private function onRemoveFromStageHandler(param1:Event) : *
      {
         this.stop();
      }
      
      private function stop() : *
      {
         this._tf1.removeEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler1);
         this._tf2.removeEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler2);
      }
      
      private function onEnterFrameHandler2(param1:Event) : *
      {
      }
   }
}
