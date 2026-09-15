package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class CFBMode extends IVMode implements IMode
   {
       
      
      public function CFBMode(param1:ISymmetricKey, param2:IPad = null)
      {
         super(param1,null);
      }
      
      public function encrypt(param1:ByteArray) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:uint = param1.length;
         var _loc5_:ByteArray = getIV4e();
         var _loc6_:uint = 0;
         while(_loc6_ < param1.length)
         {
            key.encrypt(_loc5_);
            _loc2_ = _loc6_ + blockSize < _loc4_ ? blockSize : uint(_loc4_ - _loc6_);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               param1[_loc6_ + _loc3_] ^= _loc5_[_loc3_];
               _loc3_++;
            }
            _loc5_.position = 0;
            _loc5_.writeBytes(param1,_loc6_,_loc2_);
            _loc6_ += blockSize;
         }
      }
      
      public function decrypt(param1:ByteArray) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:uint = param1.length;
         var _loc5_:ByteArray = getIV4d();
         var _loc6_:ByteArray = new ByteArray();
         var _loc7_:uint = 0;
         while(_loc7_ < param1.length)
         {
            key.encrypt(_loc5_);
            _loc2_ = _loc7_ + blockSize < _loc4_ ? blockSize : uint(_loc4_ - _loc7_);
            _loc6_.position = 0;
            _loc6_.writeBytes(param1,_loc7_,_loc2_);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               param1[_loc7_ + _loc3_] ^= _loc5_[_loc3_];
               _loc3_++;
            }
            _loc5_.position = 0;
            _loc5_.writeBytes(_loc6_);
            _loc7_ += blockSize;
         }
      }
      
      public function toString() : String
      {
         return key.toString() + "-cfb";
      }
   }
}
