package game.ui
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import com.iflashigame.controller.AESController;
   import game.Config;

   public class OnlineCountUI extends Sprite
   {

      private var _bg:Sprite;
      private var _titleTF:TextField;
      private var _countTF:TextField;
      private var _timer:Timer;
      private var _dot:Sprite;
      private var _versionChecked:Boolean = false;

      // 配色
      private static const BG_COLOR:uint = 0x1a1008;
      private static const BORDER_COLOR:uint = 0x8B6914;
      private static const TITLE_COLOR:uint = 0xC8A84E;
      private static const COUNT_COLOR:uint = 0xFFD700;
      private static const GLOW_COLOR:uint = 0xFFAA00;
      private static const DOT_GREEN:uint = 0x00FF66;
      private static const DOT_ORANGE:uint = 0xFF8800;

      public function OnlineCountUI()
      {
         super();
         this.createView();
         this.startPolling();
      }

      private function createView() : void
      {
         this._bg = new Sprite();
         this.drawBackground();
         addChild(this._bg);

         this._titleTF = new TextField();
         var _titleFmt:TextFormat = new TextFormat("SimSun", 10, TITLE_COLOR);
         this._titleTF.defaultTextFormat = _titleFmt;
         this._titleTF.text = "在线人数";
         this._titleTF.autoSize = TextFieldAutoSize.CENTER;
         this._titleTF.selectable = false;
         this._titleTF.mouseEnabled = false;
         this._titleTF.x = 36;
         this._titleTF.y = 4;
         addChild(this._titleTF);

         this._countTF = new TextField();
         var _countFmt:TextFormat = new TextFormat("SimHei", 16, COUNT_COLOR, true);
         _countFmt.align = TextFormatAlign.CENTER;
         this._countTF.defaultTextFormat = _countFmt;
         this._countTF.text = "--";
         this._countTF.autoSize = TextFieldAutoSize.CENTER;
         this._countTF.selectable = false;
         this._countTF.mouseEnabled = false;
         this._countTF.x = 36;
         this._countTF.y = 18;
         addChild(this._countTF);

         this._dot = new Sprite();
         this._dot.graphics.beginFill(DOT_GREEN);
         this._dot.graphics.drawCircle(0, 0, 4);
         this._dot.graphics.endFill();
         this._dot.x = 14;
         this._dot.y = 22;
         addChild(this._dot);
      }

      private function drawBackground() : void
      {
         var _w:Number = 78;
         var _h:Number = 42;

         this._bg.graphics.clear();
         this._bg.graphics.lineStyle(2, GLOW_COLOR, 0.25);
         this._bg.graphics.drawRoundRect(-1, -1, _w + 2, _h + 2, 8, 8);
         this._bg.graphics.lineStyle(1.5, BORDER_COLOR, 0.8);
         this._bg.graphics.beginFill(BG_COLOR, 0.85);
         this._bg.graphics.drawRoundRect(0, 0, _w, _h, 6, 6);
         this._bg.graphics.endFill();
         this._bg.graphics.lineStyle(0.5, BORDER_COLOR, 0.4);
         this._bg.graphics.drawRoundRect(3, 3, _w - 6, _h - 6, 4, 4);
         this._bg.graphics.lineStyle(1, BORDER_COLOR, 0.6);
         this._bg.graphics.moveTo(10, 14);
         this._bg.graphics.lineTo(_w - 10, 14);
      }

      private function startPolling() : void
      {
         this.fetchOnlineCount();
         this._timer = new Timer(30000);
         this._timer.addEventListener(TimerEvent.TIMER, this.onTimerHandler);
         this._timer.start();
      }

      private function onTimerHandler(param1:TimerEvent) : void
      {
         this.fetchOnlineCount();
      }

      private function fetchOnlineCount() : void
      {
         try
         {
            var _loader:URLLoader = new URLLoader();
            var _req:URLRequest = new URLRequest(AESController.getInstance().serverURL + "/api/online-count");
            _req.method = URLRequestMethod.POST;
            _req.contentType = "application/json";
            _req.data = "{}";
            var _self:OnlineCountUI = this;
            _loader.addEventListener(Event.COMPLETE, function(param1:Event):void {
               try
               {
                  var _raw:String = _loader.data as String;
                  var _json:Object = JSON.parse(_raw);
                  if(_json.success == true)
                  {
                     _self.setCount(int(_json.count));
                  }
               }
               catch(_e:Error)
               {
                  trace("OnlineCountUI parse error: " + _e.message);
               }
            });
            _loader.load(_req);
         }
         catch(_e:Error)
         {
            trace("OnlineCountUI fetch error: " + _e.message);
         }

         // 首次轮询时检查版本
         if(!this._versionChecked)
         {
            this._versionChecked = true;
            this.checkVersion();
         }
      }

      private function checkVersion() : void
      {
         try
         {
            var _loader:URLLoader = new URLLoader();
            var _req:URLRequest = new URLRequest(AESController.getInstance().serverURL + "/api/version");
            _req.method = URLRequestMethod.POST;
            _req.contentType = "application/json";
            _req.data = "{}";
            var _self:OnlineCountUI = this;
            _loader.addEventListener(Event.COMPLETE, function(param1:Event):void {
               try
               {
                  var _raw:String = _loader.data as String;
                  var _json:Object = JSON.parse(_raw);
                  if(_json.success == true && _json.version)
                  {
                     var _svrVer:String = String(_json.version);
                     if(_svrVer != Config.CLIENT_VER)
                     {
                        // 版本过期，指示灯变橙色
                        _self._dot.graphics.clear();
                        _self._dot.graphics.beginFill(DOT_ORANGE);
                        _self._dot.graphics.drawCircle(0, 0, 4);
                        _self._dot.graphics.endFill();
                     }
                  }
               }
               catch(_e:Error) {}
            });
            _loader.load(_req);
         }
         catch(_e:Error) {}
      }

      public function setCount(param1:int) : void
      {
         this._countTF.text = param1.toString();
      }

      public function stopPolling() : void
      {
         if(this._timer != null)
         {
            this._timer.stop();
            this._timer.removeEventListener(TimerEvent.TIMER, this.onTimerHandler);
            this._timer = null;
         }
      }
   }
}
