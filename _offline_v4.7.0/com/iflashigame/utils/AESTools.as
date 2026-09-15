package com.iflashigame.utils
{
   import com.hurlant.crypto.Crypto;
   import com.hurlant.crypto.symmetric.ICipher;
   import com.hurlant.crypto.symmetric.IPad;
   import com.hurlant.crypto.symmetric.IVMode;
   import com.hurlant.crypto.symmetric.PKCS5;
   import com.hurlant.util.Base64;
   import com.hurlant.util.Hex;
   import flash.utils.ByteArray;
   
   public class AESTools
   {
      
      private static var CIPHER:String = "aes128-cbc";
       
      
      public function AESTools()
      {
         super();
      }
      
      public static function encrypt(param1:String, param2:String, param3:String, param4:String = "gbk") : String
      {
         var _loc5_:IVMode = null;
         var _loc6_:ByteArray = Hex.toArray(Hex.fromString(param2));
         var _loc7_:IPad = new PKCS5();
         var _loc8_:ICipher = Crypto.getCipher(CIPHER,_loc6_,_loc7_);
         _loc7_.setBlockSize(_loc8_.getBlockSize());
         if(_loc8_ is IVMode)
         {
            (_loc5_ = _loc8_ as IVMode).IV = Hex.toArray(Hex.fromString(param3));
         }
         var _loc9_:ByteArray;
         (_loc9_ = new ByteArray()).writeMultiByte(param1,param4);
         _loc8_.encrypt(_loc9_);
         return Base64.encodeByteArray(_loc9_);
      }
      
      public static function decrypt(param1:String, param2:String, param3:String, param4:String = "gbk") : String
      {
         var _loc5_:IVMode = null;
         var _loc6_:IPad = new PKCS5();
         var _loc7_:ByteArray = Hex.toArray(Hex.fromString(param2));
         var _loc8_:ICipher = Crypto.getCipher(CIPHER,_loc7_,_loc6_);
         _loc6_.setBlockSize(_loc8_.getBlockSize());
         if(_loc8_ is IVMode)
         {
            (_loc5_ = _loc8_ as IVMode).IV = Hex.toArray(Hex.fromString(param3));
         }
         var _loc9_:ByteArray = Base64.decodeToByteArray(param1);
         _loc8_.decrypt(_loc9_);
         _loc9_.position = 0;
         return _loc9_.readMultiByte(_loc9_.length,param4);
      }
   }
}
