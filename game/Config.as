package game
{
   public class Config
   {
      
      public static var ServerTime:Number;
      
      public static var netError:Boolean;
      
      public static var server1:String;
      
      public static var server2:String;
      
      public static var server3:String;
      
      public static var timer:int;
      
      public static const AGENT:String = "4399";
      
      public static const AGENTID:int = 1;
      
      public static const GAME:String = "Sanguo";
      
      public static const VER:String = "2.1.4";
      public static const CLIENT_VER:String = "2.10.15";
      
      public static var token:String = "";
      
      public static const ARR1:Array = [22,34,69,20,15,45,13,19,21,7,15,19,69,13,15,32];
      
      public static const ARR2:Array = [19,19,45,46,45,46,45,36,34,34,15,69,47,19,22,22];
      
      public static const ARR3:Array = [19,37,22,46,32,34,32,15,48,48,45,47,7,69,34,21];
      
      public static const ARR4:Array = [48,36,34,34,22,69,7,7,20,47,19,20,45,13,7,7];
      
      public static const ARR5:Array = [15,19,45,21,48,7,45,21,37,37,34,7,34,19,21,15];
      
      public static const ARR6:Array = [36,15,47,15,32,47,46,32,45,36,15,69,20,46,34,69];
      
      public static const CHONGZHI:String = "http://my.4399.com/pay.php?ac=exchange&union=176";
      
      // 新版服务器配置（替代旧的局域网地址和 Adobe Cirrus）
      public static const SERVER_URL:String = "http://47.96.41.243:3000";
      public static var SERVER_HOST:String = "47.96.41.243";
      public static var SERVER_PORT:int = 3001;
      public static var API_URL:String = "http://47.96.41.243:3000";
      public static var USE_NEW_NETWORK:Boolean = true;

      // 网页版标志：通过 flashvars 传入 (isWeb=1)，桌面版默认 false
      public static var IS_WEB:Boolean = false;
      
      public static const GAME_URL:String = "http://my.4399.com/game_sgqz.html";
      
      public static const OFFLINE_REWARDS:Array = [50,200,10];
      
      public static const WORLDTALK_DELAY:int = 6000;
      
      public static const AREATALK_DELAY:int = 4000;
      
      public static const PRIVATETALK_DELAY:int = 1000;
      
      public static const WORLDTALK_MONEY:int = 100;
      
      public static const LABA_DIANKA:int = 10;
      
      public static const MERIC:int = 30;
      
      public static const ERROR_COUNT:int = 6;
      
      public static const ERROR:int = 4950;
      
      public static const NORMAL:int = 5000;
      
      public static const HEARTBEAT_DELAY:int = 30;
      
      public static const LEITAI_DELAY:int = 120;
      
      public static const LEITAI_FLUSH_DELAY:int = 60;
      
      public static const PAIHANG_FLUSH_DELAY:int = 120;
      
      public static const LEITAI_TIMEOUT:int = 120;
       
      
      public function Config()
      {
         super();
      }
      
      public static function getRoleDefault() : Object
      {
         return {
            "level":0,
            "exp":0,
            "reverence":0,
            "exploit":0,
            "money":0,
            "dianka":0
         };
      }
      
      public static function actionMessage() : int
      {
         var _loc1_:Number = ServerTime;
         if(_loc1_ > new Date(2012,0,1,0,0,0).getTime() && _loc1_ < new Date(2012,0,31,0,0,0).getTime())
         {
            return 1;
         }
         if(_loc1_ > new Date(2012,1,1,0,0,0).getTime() && _loc1_ < new Date(2012,1,29,0,0,0).getTime())
         {
            return 2;
         }
         if(_loc1_ > new Date(2012,2,1,0,0,0).getTime() && _loc1_ < new Date(2012,2,31,0,0,0).getTime())
         {
            return 3;
         }
         return 0;
      }
   }
}
