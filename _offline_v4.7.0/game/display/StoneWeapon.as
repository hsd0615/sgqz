package game.display
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import game.Data;
   import game.events.WeaponEvent;
   
   public class StoneWeapon extends Sprite implements IWeapon
   {
      
      private static const G:Number = 0.0098 / 200;
      
      private static const MAX_POWER:Number = 0.145;
      
      private static const MIN_POWER:Number = 0.025;
      
      private static const MAX_STEP:Number = 10000;
      
      private static const SPEED:Number = 150;
      
      public static const R:int = 10;
       
      
      private var _hurt:AbstractSoldier;
      
      private var _skin:MovieClip;
      
      private var _direct:int;
      
      private var _angle:Number;
      
      private var _power:Number;
      
      private var _x0:*;
      
      private var _y0:*;
      
      private var _radians:Number;
      
      private var _t:Number;
      
      private var _ammo:String = "";
      
      private var _horizon:int = 0;
      
      public function StoneWeapon(param1:AbstractSoldier, param2:Number, param3:Number, param4:String, param5:int = 350)
      {
         this._x0 = Number;
         this._y0 = Number;
         super();
         mouseChildren = false;
         mouseEnabled = false;
         this._horizon = param5;
         this._hurt = param1;
         this._angle = param2;
         this._power = param3 / 100 * MAX_POWER + MIN_POWER;
         this._direct = this._hurt.direct;
         this._ammo = param4;
         this.initSkin();
      }
      
      private function initSkin() : *
      {
         var _loc1_:String = null;
         var _loc2_:Class = null;
         if(this._ammo == "")
         {
            _loc2_ = ApplicationDomain.currentDomain.getDefinition("effect_0_0") as Class;
         }
         else
         {
            _loc1_ = Data.getInstance().getAttributes("proto",this._ammo,"skin");
            _loc2_ = ApplicationDomain.currentDomain.getDefinition(_loc1_) as Class;
         }
         this._skin = new _loc2_() as MovieClip;
         this._skin.scaleX = this._direct * 0.65;
         this._skin.scaleY = 0.65;
         addChild(this._skin);
      }
      
      public function run() : *
      {
         this._x0 = x;
         this._y0 = y;
         if(this._direct == 1)
         {
            this._radians = this._angle * Math.PI / 180;
         }
         else if(this._direct == -1)
         {
            this._radians = (this._angle + 180) * Math.PI / 180;
         }
         this._t = 0;
         addEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
      }
      
      private function onEnterFrameHandler(param1:Event) : *
      {
         var _loc2_:Number = NaN;
         _loc2_ = NaN;
         rotation += 10 * this._direct;
         this._t += SPEED;
         var _loc3_:Number = this._x0 + this._power * Math.cos(this._radians) * this._t;
         _loc2_ = this._y0 + this._power * Math.sin(this._radians) * this._t + 0.5 * G * this._t * this._t;
         x = _loc3_;
         if(_loc2_ >= this._horizon)
         {
            y = this._horizon;
            rotation = 0;
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrameHandler);
            addEventListener(Event.ENTER_FRAME,this.checkEndHandler);
            this._skin.gotoAndPlay("_breakBegin");
            dispatchEvent(new WeaponEvent(WeaponEvent.WEAPON_END,false,{
               "hurt":this._hurt,
               "radiu":R,
               "ammo":this._ammo
            }));
         }
         else
         {
            y = _loc2_;
         }
      }
      
      private function checkEndHandler(param1:Event) : *
      {
         if(this._skin.currentFrameLabel == "_breakEnd")
         {
            removeEventListener(Event.ENTER_FRAME,this.checkEndHandler);
            parent.removeChild(this);
         }
      }
      
      public function run2(param1:Point) : *
      {
         this._x0 = param1.x;
         this._y0 = param1.y;
         if(this._direct == 1)
         {
            this._radians = -this._angle * Math.PI / 180;
         }
         else if(this._direct == -1)
         {
            this._radians = (this._angle + 180) * Math.PI / 180;
         }
         this._t = 1;
         graphics.lineStyle(1,16711680,13);
         graphics.drawCircle(this._x0,this._y0,3);
         addEventListener(Event.ENTER_FRAME,this.onDrawLineHandler);
      }
      
      private function onDrawLineHandler(param1:Event) : *
      {
         this._t += SPEED;
         var _loc2_:Number = this._x0 + this._power * Math.cos(this._radians) * this._t;
         var _loc3_:Number = this._y0 + this._power * Math.sin(this._radians) * this._t + 0.5 * G * this._t * this._t;
         if(_loc3_ >= this._horizon)
         {
            removeEventListener(Event.ENTER_FRAME,this.onDrawLineHandler);
         }
         else
         {
            graphics.drawCircle(_loc2_,_loc3_,3);
         }
      }
   }
}
