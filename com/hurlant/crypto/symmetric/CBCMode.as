package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class CBCMode extends IVMode implements IMode
   {
       
      
      public function CBCMode(param1:ISymmetricKey, param2:IPad = null)
      {
         super(param1,param2);
      }
      
      public function encrypt(param1:ByteArray) : void
      {
         var _loc2_:uint = 0;
         padding.pad(param1);
         var _loc3_:ByteArray = getIV4e();
         var _loc4_:uint = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = 0;
            while(_loc2_ < blockSize)
            {
               param1[_loc4_ + _loc2_] ^= _loc3_[_loc2_];
               _loc2_++;
            }
            key.encrypt(param1,_loc4_);
            _loc3_.position = 0;
            _loc3_.writeBytes(param1,_loc4_,blockSize);
            _loc4_ += blockSize;
         }
      }
      
      public function decrypt(param1:ByteArray) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:ByteArray = getIV4d();
         var _loc4_:ByteArray = new ByteArray();
         var _loc5_:uint = 0;
         while(_loc5_ < param1.length)
         {
            _loc4_.position = 0;
            _loc4_.writeBytes(param1,_loc5_,blockSize);
            key.decrypt(param1,_loc5_);
            _loc2_ = 0;
            while(_loc2_ < blockSize)
            {
               param1[_loc5_ + _loc2_] ^= _loc3_[_loc2_];
               _loc2_++;
            }
            _loc3_.position = 0;
            _loc3_.writeBytes(_loc4_,0,blockSize);
            _loc5_ += blockSize;
         }
         padding.unpad(param1);
      }
      
      public function toString() : String
      {
         return key.toString() + "-cbc";
      }
   }
}
