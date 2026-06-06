package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class OFBMode extends IVMode implements IMode
   {
       
      
      public function OFBMode(param1:ISymmetricKey, param2:IPad = null)
      {
         super(param1,null);
      }
      
      public function encrypt(param1:ByteArray) : void
      {
         var _loc2_:ByteArray = getIV4e();
         this.core(param1,_loc2_);
      }
      
      public function decrypt(param1:ByteArray) : void
      {
         var _loc2_:ByteArray = getIV4d();
         this.core(param1,_loc2_);
      }
      
      private function core(param1:ByteArray, param2:ByteArray) : void
      {
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:uint = param1.length;
         var _loc6_:ByteArray = new ByteArray();
         var _loc7_:uint = 0;
         while(_loc7_ < param1.length)
         {
            key.encrypt(param2);
            _loc6_.position = 0;
            _loc6_.writeBytes(param2);
            _loc3_ = _loc7_ + blockSize < _loc5_ ? blockSize : uint(_loc5_ - _loc7_);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               param1[_loc7_ + _loc4_] ^= param2[_loc4_];
               _loc4_++;
            }
            param2.position = 0;
            param2.writeBytes(_loc6_);
            _loc7_ += blockSize;
         }
      }
      
      public function toString() : String
      {
         return key.toString() + "-ofb";
      }
   }
}
