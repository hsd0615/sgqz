package com.iflashigame.sound
{
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.system.ApplicationDomain;
   
   public class MySound
   {
      
      private static var _instance:MySound;
       
      
      private var _sound:Sound;
      
      private var _soundName:String;
      
      private var _soundChanel:SoundChannel;
      
      public var bkDisabled:Boolean;
      
      public var eventDisabled:Boolean;
      
      public function MySound(param1:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : MySound
      {
         if(MySound._instance == null)
         {
            MySound._instance = new MySound(new SingletonEnforcer());
         }
         return MySound._instance;
      }
      
      public function start(param1:String, param2:Sound, param3:int = 999) : *
      {
         if(this._soundChanel != null)
         {
            this._soundChanel.stop();
         }
         this._sound = param2;
         if(!this.bkDisabled)
         {
            this._soundName = param1;
            this._soundChanel = this._sound.play(0,param3);
         }
      }
      
      public function startByName(param1:String, param2:int = 999) : *
      {
         if(this._soundName == param1)
         {
            return;
         }
         var _loc3_:Class = ApplicationDomain.currentDomain.getDefinition(param1) as Class;
         this.start(param1,new _loc3_() as Sound,param2);
      }
      
      public function startEventSound(param1:Sound) : *
      {
         if(!this.eventDisabled)
         {
            param1.play();
         }
      }
      
      public function startEventSoundByName(param1:String) : *
      {
         var _loc2_:Class = ApplicationDomain.currentDomain.getDefinition(param1) as Class;
         this.startEventSound(new _loc2_() as Sound);
      }
      
      public function stop(param1:String = "") : *
      {
         if(this._soundChanel != null)
         {
            if(param1 == "")
            {
               this._soundChanel.stop();
            }
            else if(param1 == this._soundName)
            {
               this._soundChanel.stop();
            }
            this._soundName = "";
         }
      }
      
      public function getLength() : Number
      {
         if(this._sound == null)
         {
            return 0;
         }
         return this._sound.length;
      }
      
      public function getPosition() : Number
      {
         if(this._soundChanel == null || this._sound == null)
         {
            return 0;
         }
         return this._soundChanel.position;
      }
   }
}

class SingletonEnforcer
{
    
   
   public function SingletonEnforcer()
   {
      super();
   }
}
