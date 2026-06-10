package game
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.system.Security;
   import com.iflashigame.controller.AESController;
   import com.iflashigame.net.HttpPollConnection;

   public class Sanguo4399Web extends Sprite
   {
      public function Sanguo4399Web()
      {
         super();
         Security.loadPolicyFile("http://47.96.41.243:3000/crossdomain.xml");
         addEventListener(Event.ADDED_TO_STAGE, onAdded);
      }

      private function onAdded(e:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE, onAdded);
         Config.IS_WEB = true;
         // 网页版：使用SWF自己的域名作为服务器地址（避免跨域）
         var _swfUrl:String = this.loaderInfo.url;
         if(_swfUrl.indexOf("://") > 0) {
            var _parts:Array = _swfUrl.split("/");
            Config.SERVER_HOST = _parts[2].split(":")[0];
            AESController.getInstance().serverURL = _parts[0] + "//" + _parts[2];
         }
         HttpPollConnection.setDebugTextField(null);
         var main:Sanguo4399 = new Sanguo4399();
         addChild(main);
      }
   }
}
