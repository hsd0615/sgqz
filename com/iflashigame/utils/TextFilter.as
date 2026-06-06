package com.iflashigame.utils
{
   public class TextFilter
   {
      
      private static var _instance:TextFilter;
       
      
      private var _filterArr:Array;
      
      public var keyFlag:String = "*";
      
      public function TextFilter(param1:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : TextFilter
      {
         if(TextFilter._instance == null)
         {
            TextFilter._instance = new TextFilter(new SingletonEnforcer());
         }
         return TextFilter._instance;
      }
      
      public function setStr(param1:String) : *
      {
         param1 = param1.replace(/\s+/g,"#");
         this._filterArr = param1.split("#");
      }
      
      public function checkText(param1:String) : Boolean
      {
         var _loc2_:* = undefined;
         if(this._filterArr == null)
         {
            return true;
         }
         for(_loc2_ in this._filterArr)
         {
            if(param1.indexOf(this._filterArr[_loc2_]) != -1)
            {
               return false;
            }
         }
         return true;
      }
      
      public function replaceText(param1:String) : String
      {
         var _loc2_:* = undefined;
         var _loc3_:RegExp = null;
         if(this._filterArr == null)
         {
            return param1;
         }
         for(_loc2_ in this._filterArr)
         {
            _loc3_ = new RegExp(this._filterArr[_loc2_],"g");
            param1 = param1.replace(_loc3_,this.getFlag(this._filterArr[_loc2_].length));
         }
         return param1;
      }
      
      private function getFlag(param1:int) : String
      {
         var _loc2_:String = "";
         while(param1 > 0)
         {
            _loc2_ += this.keyFlag;
            param1--;
         }
         return _loc2_;
      }
      
      private function getStar() : String
      {
         var _loc2_:* = arguments[0].length;
         var _loc3_:String = "";
         var _loc4_:* = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_ += this.keyFlag;
            _loc4_++;
         }
         return _loc3_;
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
