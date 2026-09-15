package com.hurlant.crypto.hash
{
   public class SHA256 extends SHABase implements IHash
   {
      
      protected static const k:Array = [1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298];
       
      
      protected var h:Array;
      
      public function SHA256()
      {
         this.h = [1779033703,3144134277,1013904242,2773480762,1359893119,2600822924,528734635,1541459225];
         super();
      }
      
      override public function getHashSize() : uint
      {
         return 32;
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
         var _loc10_:uint = 0;
         var _loc11_:uint = 0;
         var _loc12_:uint = 0;
         var _loc13_:uint = 0;
         var _loc14_:uint = 0;
         var _loc15_:uint = 0;
         param1[param2 >> 5] |= 128 << 24 - param2 % 32;
         param1[(param2 + 64 >> 9 << 4) + 15] = param2;
         var _loc16_:Array = [];
         var _loc17_:uint = uint(this.h[0]);
         var _loc18_:uint = uint(this.h[1]);
         var _loc19_:uint = uint(this.h[2]);
         var _loc20_:uint = uint(this.h[3]);
         var _loc21_:uint = uint(this.h[4]);
         var _loc22_:uint = uint(this.h[5]);
         var _loc23_:uint = uint(this.h[6]);
         var _loc24_:uint = uint(this.h[7]);
         var _loc25_:uint = 0;
         while(_loc25_ < param1.length)
         {
            _loc3_ = _loc17_;
            _loc4_ = _loc18_;
            _loc5_ = _loc19_;
            _loc6_ = _loc20_;
            _loc7_ = _loc21_;
            _loc8_ = _loc22_;
            _loc9_ = _loc23_;
            _loc10_ = _loc24_;
            _loc11_ = 0;
            while(_loc11_ < 64)
            {
               if(_loc11_ < 16)
               {
                  _loc16_[_loc11_] = param1[_loc25_ + _loc11_] || 0;
               }
               else
               {
                  _loc14_ = uint(this.rrol(_loc16_[_loc11_ - 15],7) ^ this.rrol(_loc16_[_loc11_ - 15],18) ^ _loc16_[_loc11_ - 15] >>> 3);
                  _loc15_ = uint(this.rrol(_loc16_[_loc11_ - 2],17) ^ this.rrol(_loc16_[_loc11_ - 2],19) ^ _loc16_[_loc11_ - 2] >>> 10);
                  _loc16_[_loc11_] = _loc16_[_loc11_ - 16] + _loc14_ + _loc16_[_loc11_ - 7] + _loc15_;
               }
               _loc12_ = uint((this.rrol(_loc17_,2) ^ this.rrol(_loc17_,13) ^ this.rrol(_loc17_,22)) + (_loc17_ & _loc18_ ^ _loc17_ & _loc19_ ^ _loc18_ & _loc19_));
               _loc13_ = _loc24_ + (this.rrol(_loc21_,6) ^ this.rrol(_loc21_,11) ^ this.rrol(_loc21_,25)) + (_loc21_ & _loc22_ ^ _loc23_ & ~_loc21_) + k[_loc11_] + _loc16_[_loc11_];
               _loc24_ = _loc23_;
               _loc23_ = _loc22_;
               _loc22_ = _loc21_;
               _loc21_ = _loc20_ + _loc13_;
               _loc20_ = _loc19_;
               _loc19_ = _loc18_;
               _loc18_ = _loc17_;
               _loc17_ = _loc13_ + _loc12_;
               _loc11_++;
            }
            _loc17_ += _loc3_;
            _loc18_ += _loc4_;
            _loc19_ += _loc5_;
            _loc20_ += _loc6_;
            _loc21_ += _loc7_;
            _loc22_ += _loc8_;
            _loc23_ += _loc9_;
            _loc24_ += _loc10_;
            _loc25_ += 16;
         }
         return [_loc17_,_loc18_,_loc19_,_loc20_,_loc21_,_loc22_,_loc23_,_loc24_];
      }
      
      protected function rrol(param1:uint, param2:uint) : uint
      {
         return param1 << 32 - param2 | param1 >>> param2;
      }
      
      override public function toString() : String
      {
         return "sha256";
      }
   }
}
