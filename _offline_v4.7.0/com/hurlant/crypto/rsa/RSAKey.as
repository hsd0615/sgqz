package com.hurlant.crypto.rsa
{
   import com.hurlant.crypto.prng.Random;
   import com.hurlant.math.BigInteger;
   import com.hurlant.util.Memory;
   import flash.utils.ByteArray;
   
   public class RSAKey
   {
       
      
      public var e:int;
      
      public var n:BigInteger;
      
      public var d:BigInteger;
      
      public var p:BigInteger;
      
      public var q:BigInteger;
      
      public var dmp1:BigInteger;
      
      public var dmq1:BigInteger;
      
      public var coeff:BigInteger;
      
      protected var canDecrypt:Boolean;
      
      protected var canEncrypt:Boolean;
      
      public function RSAKey(param1:BigInteger, param2:int, param3:BigInteger = null, param4:BigInteger = null, param5:BigInteger = null, param6:BigInteger = null, param7:BigInteger = null, param8:BigInteger = null)
      {
         super();
         this.n = param1;
         this.e = param2;
         this.d = param3;
         this.p = param4;
         this.q = param5;
         this.dmp1 = param6;
         this.dmq1 = param7;
         this.coeff = param8;
         this.canEncrypt = this.n != null && this.e != 0;
         this.canDecrypt = this.canEncrypt && this.d != null;
      }
      
      public static function parsePublicKey(param1:String, param2:String) : RSAKey
      {
         return new RSAKey(new BigInteger(param1,16),parseInt(param2,16));
      }
      
      public static function parsePrivateKey(param1:String, param2:String, param3:String, param4:String = null, param5:String = null, param6:String = null, param7:String = null, param8:String = null) : RSAKey
      {
         if(param4 == null)
         {
            return new RSAKey(new BigInteger(param1,16),parseInt(param2,16),new BigInteger(param3,16));
         }
         return new RSAKey(new BigInteger(param1,16),parseInt(param2,16),new BigInteger(param3,16),new BigInteger(param4,16),new BigInteger(param5,16),new BigInteger(param6,16),new BigInteger(param7),new BigInteger(param8));
      }
      
      public static function generate(param1:uint, param2:String) : RSAKey
      {
         var _loc3_:BigInteger = null;
         var _loc4_:BigInteger = null;
         var _loc5_:BigInteger = null;
         var _loc6_:BigInteger = null;
         var _loc7_:Random = new Random();
         var _loc8_:uint = uint(param1 >> 1);
         var _loc9_:RSAKey;
         (_loc9_ = new RSAKey(null,0,null)).e = parseInt(param2,16);
         var _loc10_:BigInteger = new BigInteger(param2,16);
         do
         {
            do
            {
               _loc9_.p = bigRandom(param1 - _loc8_,_loc7_);
            }
            while(!(_loc9_.p.subtract(BigInteger.ONE).gcd(_loc10_).compareTo(BigInteger.ONE) == 0 && _loc9_.p.isProbablePrime(10)));
            
            do
            {
               _loc9_.q = bigRandom(_loc8_,_loc7_);
            }
            while(!(_loc9_.q.subtract(BigInteger.ONE).gcd(_loc10_).compareTo(BigInteger.ONE) == 0 && _loc9_.q.isProbablePrime(10)));
            
            if(_loc9_.p.compareTo(_loc9_.q) <= 0)
            {
               _loc6_ = _loc9_.p;
               _loc9_.p = _loc9_.q;
               _loc9_.q = _loc6_;
            }
            _loc3_ = _loc9_.p.subtract(BigInteger.ONE);
            _loc4_ = _loc9_.q.subtract(BigInteger.ONE);
         }
         while(_loc5_.gcd(_loc10_).compareTo(BigInteger.ONE) != 0);
         
         _loc9_.n = _loc9_.p.multiply(_loc9_.q);
         _loc9_.d = _loc10_.modInverse(_loc5_);
         _loc9_.dmp1 = _loc9_.d.mod(_loc3_);
         _loc9_.dmq1 = _loc9_.d.mod(_loc4_);
         _loc9_.coeff = _loc9_.q.modInverse(_loc9_.p);
         return _loc9_;
      }
      
      protected static function bigRandom(param1:int, param2:Random) : BigInteger
      {
         if(param1 < 2)
         {
            return BigInteger.nbv(1);
         }
         var _loc3_:ByteArray = new ByteArray();
         param2.nextBytes(_loc3_,param1 >> 3);
         _loc3_.position = 0;
         var _loc4_:BigInteger;
         (_loc4_ = new BigInteger(_loc3_)).primify(param1,1);
         return _loc4_;
      }
      
      public function getBlockSize() : uint
      {
         return (this.n.bitLength() + 7) / 8;
      }
      
      public function dispose() : void
      {
         this.e = 0;
         this.n.dispose();
         this.n = null;
         Memory.gc();
      }
      
      public function encrypt(param1:ByteArray, param2:ByteArray, param3:uint, param4:Function = null) : void
      {
         this._encrypt(this.doPublic,param1,param2,param3,param4,2);
      }
      
      public function decrypt(param1:ByteArray, param2:ByteArray, param3:uint, param4:Function = null) : void
      {
         this._decrypt(this.doPrivate2,param1,param2,param3,param4,2);
      }
      
      public function sign(param1:ByteArray, param2:ByteArray, param3:uint, param4:Function = null) : void
      {
         this._encrypt(this.doPrivate2,param1,param2,param3,param4,1);
      }
      
      public function verify(param1:ByteArray, param2:ByteArray, param3:uint, param4:Function = null) : void
      {
         this._decrypt(this.doPublic,param1,param2,param3,param4,1);
      }
      
      private function _encrypt(param1:Function, param2:ByteArray, param3:ByteArray, param4:uint, param5:Function, param6:int) : void
      {
         var _loc7_:BigInteger = null;
         var _loc8_:BigInteger = null;
         if(param5 == null)
         {
            param5 = this.pkcs1pad;
         }
         if(param2.position >= param2.length)
         {
            param2.position = 0;
         }
         var _loc9_:uint = this.getBlockSize();
         var _loc10_:int = int(param2.position + param4);
         while(param2.position < _loc10_)
         {
            _loc7_ = new BigInteger(param5(param2,_loc10_,_loc9_,param6),_loc9_);
            (_loc8_ = param1(_loc7_)).toArray(param3);
         }
      }
      
      private function _decrypt(param1:Function, param2:ByteArray, param3:ByteArray, param4:uint, param5:Function, param6:int) : void
      {
         var _loc7_:BigInteger = null;
         var _loc8_:BigInteger = null;
         var _loc9_:ByteArray = null;
         if(param5 == null)
         {
            param5 = this.pkcs1unpad;
         }
         if(param2.position >= param2.length)
         {
            param2.position = 0;
         }
         var _loc10_:uint = this.getBlockSize();
         var _loc11_:int = int(param2.position + param4);
         while(param2.position < _loc11_)
         {
            _loc7_ = new BigInteger(param2,param4);
            _loc8_ = param1(_loc7_);
            _loc9_ = param5(_loc8_,_loc10_);
            param3.writeBytes(_loc9_);
         }
      }
      
      private function pkcs1pad(param1:ByteArray, param2:int, param3:uint, param4:uint = 2) : ByteArray
      {
         var _loc10_:* = undefined;
         var _loc11_:* = undefined;
         var _loc12_:* = undefined;
         var _loc5_:int = 0;
         var _loc6_:ByteArray = new ByteArray();
         var _loc7_:uint = param1.position;
         param2 = Math.min(param2,param1.length,_loc7_ + param3 - 11);
         param1.position = param2;
         var _loc8_:int = param2 - 1;
         while(_loc8_ >= _loc7_ && param3 > 11)
         {
            var _loc13_:*;
            _loc6_[_loc13_ = _loc11_ = --param3] = param1[_loc8_--];
         }
         _loc6_[_loc13_ = _loc11_ = --param3] = 0;
         var _loc9_:Random = new Random();
         while(param3 > 2)
         {
            _loc5_ = 0;
            while(_loc5_ == 0)
            {
               _loc5_ = param4 == 2 ? _loc9_.nextByte() : 255;
            }
            var _loc14_:*;
            _loc6_[_loc14_ = _loc12_ = --param3] = _loc5_;
         }
         _loc6_[_loc14_ = _loc12_ = --param3] = param4;
         var _loc15_:*;
         _loc6_[_loc15_ = _loc10_ = --param3] = 0;
         return _loc6_;
      }
      
      private function pkcs1unpad(param1:BigInteger, param2:uint, param3:uint = 2) : ByteArray
      {
         var _loc4_:ByteArray = param1.toByteArray();
         var _loc5_:ByteArray = new ByteArray();
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_.length && _loc4_[_loc6_] == 0)
         {
            _loc6_++;
         }
         if(_loc4_.length - _loc6_ != param2 - 1 || _loc4_[_loc6_] > 2)
         {
            trace("PKCS#1 unpad: i=" + _loc6_ + ", expected b[i]==[0,1,2], got b[i]=" + _loc4_[_loc6_].toString(16));
            return null;
         }
         _loc6_++;
         while(_loc4_[_loc6_] != 0)
         {
            if(++_loc6_ >= _loc4_.length)
            {
               trace("PKCS#1 unpad: i=" + _loc6_ + ", b[i-1]!=0 (=" + _loc4_[_loc6_ - 1].toString(16) + ")");
               return null;
            }
         }
         while(++_loc6_ < _loc4_.length)
         {
            _loc5_.writeByte(_loc4_[_loc6_]);
         }
         _loc5_.position = 0;
         return _loc5_;
      }
      
      private function rawpad(param1:ByteArray, param2:int, param3:uint) : ByteArray
      {
         return param1;
      }
      
      public function toString() : String
      {
         return "rsa";
      }
      
      public function dump() : String
      {
         var _loc1_:* = "N=" + this.n.toString(16) + "\n" + "E=" + this.e.toString(16) + "\n";
         if(this.canDecrypt)
         {
            _loc1_ += "D=" + this.d.toString(16) + "\n";
            if(this.p != null && this.q != null)
            {
               _loc1_ += "P=" + this.p.toString(16) + "\n";
               _loc1_ += "Q=" + this.q.toString(16) + "\n";
               _loc1_ += "DMP1=" + this.dmp1.toString(16) + "\n";
               _loc1_ += "DMQ1=" + this.dmq1.toString(16) + "\n";
               _loc1_ += "IQMP=" + this.coeff.toString(16) + "\n";
            }
         }
         return _loc1_;
      }
      
      protected function doPublic(param1:BigInteger) : BigInteger
      {
         return param1.modPowInt(this.e,this.n);
      }
      
      protected function doPrivate2(param1:BigInteger) : BigInteger
      {
         if(this.p == null && this.q == null)
         {
            return param1.modPow(this.d,this.n);
         }
         var _loc2_:BigInteger = param1.mod(this.p).modPow(this.dmp1,this.p);
         var _loc3_:BigInteger = param1.mod(this.q).modPow(this.dmq1,this.q);
         while(_loc2_.compareTo(_loc3_) < 0)
         {
            _loc2_ = _loc2_.add(this.p);
         }
         return _loc2_.subtract(_loc3_).multiply(this.coeff).mod(this.p).multiply(this.q).add(_loc3_);
      }
      
      protected function doPrivate(param1:BigInteger) : BigInteger
      {
         if(this.p == null || this.q == null)
         {
            return param1.modPow(this.d,this.n);
         }
         var _loc2_:BigInteger = param1.mod(this.p).modPow(this.dmp1,this.p);
         var _loc3_:BigInteger = param1.mod(this.q).modPow(this.dmq1,this.q);
         while(_loc2_.compareTo(_loc3_) < 0)
         {
            _loc2_ = _loc2_.add(this.p);
         }
         return _loc2_.subtract(_loc3_).multiply(this.coeff).mod(this.p).multiply(this.q).add(_loc3_);
      }
   }
}
