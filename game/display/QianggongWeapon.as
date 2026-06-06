package game.display
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import game.events.WeaponEvent;
   import game.model.Type;
   
   public class QianggongWeapon extends Sprite implements IWeapon
   {
       
      
      private var _direct:int;
      
      private var _skin:MovieClip;
      
      private var _code:String;
      
      private var _endPos:Point;
      
      private var _step:Number = 20;
      
      private var _a:Number;
      
      private var _b:Number;
      
      private var _c:Number;
      
      private var _tempX:Number;
      
      private var _tempY:Number;
      
      private var _oldX:Number;
      
      private var _oldY:Number;
      
      private var _startPos:Point;
      
      private var _centerPos:Point;
      
      private var _hurt:AbstractSoldier;
      
      private var _behurt:AbstractSoldier;
      
      public function QianggongWeapon(param1:AbstractSoldier, param2:AbstractSoldier)
      {
         super();
         mouseChildren = false;
         mouseEnabled = false;
         this._hurt = param1;
         this._behurt = param2;
         this._direct = -param1.direct;
         if(param1.evolution > 1)
         {
            this._code = "effect_" + Type.GONGBING + "_1";
         }
         else
         {
            this._code = "effect_" + Type.GONGBING + "_0";
         }
         this.initSkin();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddToStageHandler);
      }
      
      private function setABC() : *
      {
         this._startPos = new Point(x,y);
         this._endPos = new Point(this._behurt.x,y);
         this._centerPos = new Point(this._behurt.x + (x - this._behurt.x) / 2,y - 50);
         var _loc1_:Number = this._endPos.x;
         var _loc2_:Number = this._endPos.y;
         var _loc3_:Number = this._startPos.x;
         var _loc4_:Number = this._startPos.y;
         var _loc5_:Number = this._centerPos.x;
         var _loc6_:Number = this._centerPos.y;
         this._tempX = this._startPos.x;
         this._tempY = this._startPos.y;
         this._oldX = this._tempX;
         this._oldY = this._tempY;
         this._b = ((_loc4_ - _loc6_) * (_loc3_ * _loc3_ - _loc1_ * _loc1_) - (_loc4_ - _loc2_) * (_loc3_ * _loc3_ - _loc5_ * _loc5_)) / ((_loc3_ - _loc5_) * (_loc3_ * _loc3_ - _loc1_ * _loc1_) - (_loc3_ - _loc1_) * (_loc3_ * _loc3_ - _loc5_ * _loc5_));
         this._a = (_loc4_ - _loc2_ - this._b * (_loc3_ - _loc1_)) / (_loc3_ * _loc3_ - _loc1_ * _loc1_);
         this._c = _loc2_ - this._a * _loc1_ * _loc1_ - this._b * _loc1_;
      }
      
      private function initSkin() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(this._code) as Class;
         this._skin = new _loc1_() as MovieClip;
         this._skin.scaleX = 0.7;
         this._skin.scaleY = 0.7;
         addChild(this._skin);
      }
      
      public function run() : *
      {
         this.onAddToStageHandler(null);
      }
      
      private function onAddToStageHandler(param1:Event) : *
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddToStageHandler);
         this.setABC();
         if(this._hurt.direct != 1)
         {
            addEventListener(Event.ENTER_FRAME,this.rightToLeft);
         }
      }
      
      private function leftToRight(param1:Event) : *
      {
      }
      
      private function rightToLeft(param1:Event) : *
      {
         this._tempX -= this._step;
         this._tempY = this._a * this._tempX * this._tempX + this._b * this._tempX + this._c;
         if(this._tempX < this._endPos.x)
         {
            this._tempX = this._endPos.x;
            this._tempY = this._endPos.y;
         }
         var _loc2_:Number = Math.atan2(this._tempY - this._oldY,this._tempX - this._oldX);
         rotation = _loc2_ * 180 / Math.PI;
         x = this._tempX;
         y = this._tempY;
         this._oldX = this._tempX;
         this._oldY = this._tempY;
         if(x == this._endPos.x && y == this._endPos.y)
         {
            removeEventListener(Event.ENTER_FRAME,this.rightToLeft);
            dispatchEvent(new WeaponEvent(WeaponEvent.WEAPON_END,false,{
               "hurt":this._hurt,
               "behurt":this._behurt
            }));
         }
      }
   }
}
