package com.hurlant.crypto.hash
{
   public class SHA1 extends SHABase implements IHash
   {
      
      public static const HASH_SIZE:int = 20;
       
      
      public function SHA1()
      {
         super();
      }
      
      override public function getHashSize() : uint
      {
         return HASH_SIZE;
      }
      
      override protected function core(param1:Array, param2:uint) : Array
      {
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         param1[param2 >> 5] |= 128 << 24 - param2 % 32;
         param1[(param2 + 64 >> 9 << 4) + 15] = param2;
         var _loc10_:Array = [];
         var _loc11_:uint = 1732584193;
         var _loc12_:uint = 4023233417;
         var _loc13_:uint = 2562383102;
         var _loc14_:uint = 271733878;
         var _loc15_:uint = 3285377520;
         var _loc16_:uint = 0;
         while(_loc16_ < param1.length)
         {
            _loc3_ = _loc11_;
            _loc4_ = _loc12_;
            _loc5_ = _loc13_;
            _loc6_ = _loc14_;
            _loc7_ = _loc15_;
            _loc8_ = 0;
            while(_loc8_ < 80)
            {
               if(_loc8_ < 16)
               {
                  _loc10_[_loc8_] = param1[_loc16_ + _loc8_] || 0;
               }
               else
               {
                  _loc10_[_loc8_] = this.rol(_loc10_[_loc8_ - 3] ^ _loc10_[_loc8_ - 8] ^ _loc10_[_loc8_ - 14] ^ _loc10_[_loc8_ - 16],1);
               }
               _loc9_ = this.rol(_loc11_,5) + this.ft(_loc8_,_loc12_,_loc13_,_loc14_) + _loc15_ + _loc10_[_loc8_] + this.kt(_loc8_);
               _loc15_ = _loc14_;
               _loc14_ = _loc13_;
               _loc13_ = this.rol(_loc12_,30);
               _loc12_ = _loc11_;
               _loc11_ = _loc9_;
               _loc8_++;
            }
            _loc11_ += _loc3_;
            _loc12_ += _loc4_;
            _loc13_ += _loc5_;
            _loc14_ += _loc6_;
            _loc15_ += _loc7_;
            _loc16_ += 16;
         }
         return [_loc11_,_loc12_,_loc13_,_loc14_,_loc15_];
      }
      
      private function rol(param1:uint, param2:uint) : uint
      {
         return param1 << param2 | param1 >>> 32 - param2;
      }
      
      private function ft(param1:uint, param2:uint, param3:uint, param4:uint) : uint
      {
         if(param1 < 20)
         {
            return param2 & param3 | ~param2 & param4;
         }
         if(param1 < 40)
         {
            return param2 ^ param3 ^ param4;
         }
         if(param1 < 60)
         {
            return param2 & param3 | param2 & param4 | param3 & param4;
         }
         return param2 ^ param3 ^ param4;
      }
      
      private function kt(param1:uint) : uint
      {
         return param1 < 20 ? 1518500249 : (param1 < 40 ? 1859775393 : (param1 < 60 ? uint(2400959708) : uint(3395469782)));
      }
      
      override public function toString() : String
      {
         return "sha1";
      }
   }
}
