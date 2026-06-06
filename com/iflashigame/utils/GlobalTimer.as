package com.iflashigame.utils
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class GlobalTimer
   {
      
      private static var _instance:GlobalTimer;
       
      
      private var _timer:Timer;
      
      private var _lsManager:Object;
      
      private var _count:int;
      
      private var _maxCount:int = 30;
      
      public function GlobalTimer(param1:SingletonEnforcer)
      {
         super();
         this.init();
      }
      
      public static function getInstance() : GlobalTimer
      {
         if(GlobalTimer._instance == null)
         {
            GlobalTimer._instance = new GlobalTimer(new SingletonEnforcer());
         }
         return GlobalTimer._instance;
      }
      
      private function init() : *
      {
         this._timer = new Timer(1000);
         this._lsManager = {};
      }
      
      public function start() : *
      {
         this._timer.start();
         if(this._timer.hasEventListener(TimerEvent.TIMER) == false)
         {
            this._timer.addEventListener(TimerEvent.TIMER,this.onTimerEventHandler);
         }
      }
      
      private function onTimerEventHandler(param1:TimerEvent) : *
      {
         var _loc2_:* = undefined;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Array = [];
         for(_loc2_ in this._lsManager)
         {
            _loc4_ = this._timer.currentCount;
            if(this._lsManager[_loc2_].nextCount <= _loc4_)
            {
               this._lsManager[_loc2_].nextCount = _loc4_ + this._lsManager[_loc2_].delay;
               if(this._lsManager[_loc2_].pause == false)
               {
                  if(this._lsManager[_loc2_].funObj == null)
                  {
                     this._lsManager[_loc2_].fun();
                  }
                  else
                  {
                     this._lsManager[_loc2_].fun(this._lsManager[_loc2_].funObj);
                  }
                  ++this._lsManager[_loc2_].currentRepeat;
                  if(this._lsManager[_loc2_].repeat != 0)
                  {
                     if(this._lsManager[_loc2_].currentRepeat >= this._lsManager[_loc2_].repeat)
                     {
                        _loc5_.push(_loc2_);
                     }
                  }
               }
            }
         }
         _loc3_ = 0;
         while(_loc3_ < _loc5_.length)
         {
            this.removeListener(_loc5_[_loc3_]);
            _loc3_++;
         }
      }
      
      public function stop() : *
      {
         this._timer.stop();
      }
      
      public function reset() : *
      {
         this._timer.reset();
      }
      
      public function addListener(param1:String, param2:int, param3:Function, param4:int = 0, param5:Object = null) : *
      {
         if(this._count >= this._maxCount)
         {
            throw new Error("触发器数量已达到上限!");
         }
         if(this._lsManager[param1] == null)
         {
            this._lsManager[param1] = {
               "delay":param2,
               "nextCount":this._timer.currentCount + param2,
               "repeat":param4,
               "currentRepeat":0,
               "pause":false,
               "fun":param3,
               "funObj":param5
            };
            ++this._count;
            return;
         }
         throw new Error(param1 + "触发器已经添加，请先删除此触发器再添加!");
      }
      
      public function pauseListener(param1:String) : *
      {
         if(this._lsManager[param1] == null)
         {
            return;
         }
         this._lsManager[param1].pause = true;
      }
      
      public function playListener(param1:String) : *
      {
         if(this._lsManager[param1] == null)
         {
            return;
         }
         this._lsManager[param1].pause = false;
      }
      
      public function removeListener(param1:String) : *
      {
         if(this._lsManager[param1] == null)
         {
            return;
         }
         this.pauseListener(param1);
         this._lsManager[param1].fun = null;
         this._lsManager[param1].funObj = null;
         delete this._lsManager[param1];
         --this._count;
      }
      
      public function get count() : int
      {
         return this._count;
      }
      
      public function get maxCount() : int
      {
         return this._maxCount;
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
