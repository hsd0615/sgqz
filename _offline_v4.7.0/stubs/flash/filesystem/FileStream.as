package flash.filesystem
{
   import flash.utils.ByteArray;
   public class FileStream
   {
      public function open(file:File, mode:String):void {}
      public function close():void {}
      public function writeUTFBytes(str:String):void {}
      public function writeBytes(bytes:ByteArray, offset:uint, length:uint):void {}
      public function readUTFBytes(length:uint):String { return ""; }
      public function get bytesAvailable():uint { return 0; }
      public function FileStream() {}
   }
}
