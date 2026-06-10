package game.display
{
   import flash.display.Bitmap; import flash.display.BitmapData; import flash.display.Loader;
   import flash.display.Sprite; import flash.events.Event; import flash.net.URLRequest;
   public class WokouAssets
   {
      private static var _s:BitmapData; private static var _b:BitmapData; private static var _c:int;
      public static function load():void { if(_c>0)return;
         var l1:Loader=new Loader();l1.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{_s=Bitmap(l1.content).bitmapData;_c++;});l1.load(new URLRequest('/client/wokou_soldier.png'));
         var l2:Loader=new Loader();l2.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{_b=Bitmap(l2.content).bitmapData;_c++;});l2.load(new URLRequest('/client/wokou_boss.png'));
      }
      public static function get count():int{return _c}
      public static function make(boss:Boolean):Sprite{var sp:Sprite=new Sprite();var bd:BitmapData=boss?_b:_s;if(bd){var bm:Bitmap=new Bitmap(bd);bm.smoothing=true;bm.x=-bd.width/2;bm.y=-bd.height;sp.addChild(bm)}return sp}
   }
}
