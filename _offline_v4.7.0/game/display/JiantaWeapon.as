package game.display
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import game.events.WeaponEvent;
   import game.model.Type;
   
   public class JiantaWeapon extends Sprite implements IWeapon
   {
       
      
      private var _direct:int;
      
      private var _skin:MovieClip;
      
      private var _code:String;
      
      private var _endPos:Point;
      
      private var _speed:Number = 20;
      
      private var _tempX:Number;
      
      private var _tempY:Number;
      
      private var _hurt:AbstractSoldier;
      
      private var _behurt:AbstractSoldier;
      
      public function JiantaWeapon(param1:AbstractSoldier, param2:AbstractSoldier)
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
         this._endPos = new Point(param2.x,param2.y - 30);
         this.initSkin();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddToStageHandler);
      }
      
      private function setAngle() : *
      {
         var _loc1_:Number = Math.atan2(this._behurt.y - y - 30,this._behurt.x - x);
         this._tempX = Math.cos(_loc1_) * this._speed;
         this._tempY = Math.sin(_loc1_) * this._speed;
         rotation = _loc1_ * 180 / Math.PI;
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
         this.setAngle();
         if(this._hurt.direct == 1)
         {
            addEventListener(Event.ENTER_FRAME,this.leftToRight);
         }
         else
         {
            addEventListener(Event.ENTER_FRAME,this.rightToLeft);
         }
      }
      
      private function leftToRight(param1:Event) : *
      {
         var _loc2_:Point = new Point(x + this._tempX,y + this._tempY);
         if(_loc2_.x > this._endPos.x)
         {
            _loc2_.x = this._endPos.x;
         }
         if(_loc2_.y > this._endPos.y)
         {
            _loc2_.y = this._endPos.y;
         }
         x = _loc2_.x;
         y = _loc2_.y;
         if(x == this._endPos.x && y == this._endPos.y)
         {
            removeEventListener(Event.ENTER_FRAME,this.leftToRight);
            dispatchEvent(new WeaponEvent(WeaponEvent.WEAPON_END,false,{
               "hurt":this._hurt,
               "behurt":this._behurt
            }));
         }
      }
      
      private function rightToLeft(param1:Event) : *
      {
         var _loc2_:Point = new Point(x + this._tempX,y + this._tempY);
         if(_loc2_.x < this._endPos.x)
         {
            _loc2_.x = this._endPos.x;
         }
         if(_loc2_.y > this._endPos.y)
         {
            _loc2_.y = this._endPos.y;
         }
         x = _loc2_.x;
         y = _loc2_.y;
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
