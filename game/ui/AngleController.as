package game.ui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import game.display.AbstractSoldier;
   import game.events.ConEvent;
   
   public class AngleController extends Sprite
   {
      
      private static const MAX_ANGLE:Number = 0;
      
      private static const MIN_ANGLE:Number = -50;
      
      private static const MAX_POWER:Number = 100;
      
      private static const MIN_POWER:Number = 1;
       
      
      private var _skin:MovieClip;
      
      private var __hand:MovieClip;
      
      private var __bar:MovieClip;
      
      private var __flag:MovieClip;
      
      private var _angle:Number;
      
      private var _power:Number;
      
      private var _powerDirect:int;
      
      private var _direct:int = 1;
      
      public var target:AbstractSoldier;
      
      public function AngleController(param1:String)
      {
         super();
         mouseChildren = false;
         mouseEnabled = false;
         this.initSkin(param1);
         this.initView();
         this.initEvent();
      }
      
      private function initSkin(param1:String) : *
      {
         var _loc2_:Class = ApplicationDomain.currentDomain.getDefinition(param1) as Class;
         this._skin = new _loc2_() as MovieClip;
         addChild(this._skin);
      }
      
      private function initView() : void
      {
         this.__hand = this._skin.getChildByName("_hand") as MovieClip;
         this.__bar = this.__hand.getChildByName("_bar") as MovieClip;
         this.__flag = this._skin.getChildByName("_flag") as MovieClip;
         this.__flag.visible = false;
         this.__bar.scaleX = MIN_POWER;
      }
      
      private function initEvent() : *
      {
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStageHandler);
      }
      
      public function startBar(param1:Boolean = false) : *
      {
         this._power = MIN_POWER;
         this._powerDirect = 1;
         this._angle = 0;
         if(param1 == true)
         {
            addEventListener(Event.ENTER_FRAME,this.onDemoBarProgressHandler);
         }
         else
         {
            addEventListener(Event.ENTER_FRAME,this.onBarProgressHandler);
            stage.addEventListener(MouseEvent.CLICK,this.onFireHandler,true);
         }
      }
      
      private function onFireHandler(param1:MouseEvent) : *
      {
         stage.removeEventListener(MouseEvent.CLICK,this.onFireHandler,true);
         this.stopBar();
         dispatchEvent(new ConEvent(ConEvent.FIRE,true,{
            "type":ConType.YUANCHENG,
            "angle":this.getAngle(),
            "power":this._power
         }));
      }
      
      private function onDemoBarProgressHandler(param1:Event) : *
      {
         this._power += 3 * this._powerDirect;
         if(this._power <= MIN_POWER || this._power >= MAX_POWER)
         {
            this._powerDirect = -this._powerDirect;
         }
         this.__bar.scaleX = this._power / 100;
      }
      
      private function onBarProgressHandler(param1:Event) : *
      {
         this._power += 3 * this._powerDirect;
         if(this._power <= MIN_POWER || this._power >= MAX_POWER)
         {
            this._powerDirect = -this._powerDirect;
         }
         this.__bar.scaleX = this._power / 100;
         var _loc2_:Number = Math.atan2(mouseY,mouseX);
         this.setAngle(_loc2_ * 180 / Math.PI);
      }
      
      public function stopBar() : *
      {
         removeEventListener(Event.ENTER_FRAME,this.onDemoBarProgressHandler);
         removeEventListener(Event.ENTER_FRAME,this.onBarProgressHandler);
         stage.removeEventListener(MouseEvent.CLICK,this.onFireHandler,true);
      }
      
      private function onRemovedFromStageHandler(param1:Event) : *
      {
         this.stopBar();
      }
      
      public function getPower() : Number
      {
         return this._power;
      }
      
      public function setAngle(param1:Number) : *
      {
         if(this._direct == -1)
         {
            this._angle = 180 - param1;
            if(this._angle > 0 && this._angle <= 180)
            {
               this._angle = 360 + MAX_ANGLE;
            }
            else if(this._angle > 180 && this._angle <= 360 + MIN_ANGLE)
            {
               this._angle = 360 + MIN_ANGLE;
            }
            this.__hand.rotation = this._angle;
         }
         else
         {
            this._angle = param1;
            if(this._angle > MAX_ANGLE)
            {
               this._angle = MAX_ANGLE;
            }
            else if(this._angle < MIN_ANGLE)
            {
               this._angle = MIN_ANGLE;
            }
            this.__hand.rotation = this._angle;
         }
      }
      
      public function getAngle() : Number
      {
         if(this._direct == 1)
         {
            return this._angle;
         }
         return 360 - this._angle;
      }
      
      public function setEnabled(param1:Boolean) : *
      {
         if(param1)
         {
            this.__flag.visible = false;
         }
         else
         {
            this.__flag.visible = true;
         }
      }
      
      public function getEnabled() : Boolean
      {
         return this.__flag.visible == false;
      }
      
      public function set direct(param1:int) : *
      {
         this._direct = param1;
         if(this._direct == -1)
         {
            this._skin.scaleX = -1;
         }
         else
         {
            this._skin.scaleX = 1;
         }
      }
   }
}
