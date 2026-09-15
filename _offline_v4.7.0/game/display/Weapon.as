package game.display
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import game.events.WeaponEvent;
   import game.model.Type;
   
   public class Weapon extends Sprite implements IWeapon
   {
       
      
      private var _direct:int;
      
      private var _skin:MovieClip;
      
      private var _code:String;
      
      private var _endPos:Point;
      
      private var _speed:Number = 10;
      
      private var _hurt:AbstractSoldier;
      
      private var _behurt:AbstractSoldier;
      
      public function Weapon(param1:AbstractSoldier, param2:AbstractSoldier)
      {
         super();
         mouseChildren = false;
         mouseEnabled = false;
         this._hurt = param1;
         this._behurt = param2;
         this._direct = -param1.direct;
         if(param1.code == "general_5_19" || param1.type == Type.JUNZHU)
         {
            this._code = "effect_dongzhuo";
         }
         else if(param1.evolution > 1)
         {
            this._code = "effect_" + param1.type + "_1";
         }
         else
         {
            this._code = "effect_" + param1.type + "_0";
         }
         this._endPos = new Point(param2.x,param2.y);
         this.initSkin();
      }
      
      private function initSkin() : *
      {
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition(this._code) as Class;
         this._skin = new _loc1_() as MovieClip;
         this._skin.scaleX = this._hurt.direct * 0.7;
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
         x += this._speed;
         if(x >= this._endPos.x)
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
         x -= this._speed;
         if(x <= this._endPos.x)
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
