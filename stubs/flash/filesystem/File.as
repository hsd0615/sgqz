package flash.filesystem
{
   public class File
   {
      public static var applicationDirectory:File = new File();
      public static var applicationStorageDirectory:File = new File();
      public function get nativePath():String { return ""; }
      public function resolvePath(path:String):File { return new File(); }
      public function File(path:String = null) {}
   }
}
