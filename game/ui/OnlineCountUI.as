package game.ui
{
   import com.iflashigame.controller.AESController;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import game.Config;

   public class OnlineCountUI extends Sprite
   {
      private var _bg:Sprite;
      private var _titleTF:TextField;
      private var _countTF:TextField;
      private var _dot:Sprite;
      private var _timer:Timer;
      private var _versionChecked:Boolean;

      // 悬停弹出面板
      private var _popup:Sprite;
      private var _popupTF:TextField;
      private var _players:Array = [];
      private var _hoverTimer:Timer;
      private var _isOver:Boolean;

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
         // 背景面板
         this._bg = new Sprite();
         this.drawBackground();
         addChild(this._bg);

         // 标题
         this._titleTF = new TextField();
         this._titleTF.defaultTextFormat = new TextFormat("SimSun", 10, TITLE_COLOR);
         this._titleTF.text = "在线人数";
         this._titleTF.autoSize = TextFieldAutoSize.CENTER;
         this._titleTF.selectable = false; this._titleTF.mouseEnabled = false;
         this._titleTF.x = 36; this._titleTF.y = 4;
         addChild(this._titleTF);

         // 数字
         this._countTF = new TextField();
         var _fmt:TextFormat = new TextFormat("SimHei", 16, COUNT_COLOR, true);
         _fmt.align = TextFormatAlign.CENTER;
         this._countTF.defaultTextFormat = _fmt;
         this._countTF.text = "--";
         this._countTF.autoSize = TextFieldAutoSize.CENTER;
         this._countTF.selectable = false; this._countTF.mouseEnabled = false;
         this._countTF.x = 36; this._countTF.y = 18;
         addChild(this._countTF);

         // 状态灯
         this._dot = new Sprite();
         this._dot.graphics.beginFill(DOT_GREEN);
         this._dot.graphics.drawCircle(0, 0, 4);
         this._dot.graphics.endFill();
         this._dot.x = 14; this._dot.y = 22;
         addChild(this._dot);

         // 悬停事件
         this.buttonMode = true;
         this.addEventListener(MouseEvent.MOUSE_OVER, this.onOver);
         this.addEventListener(MouseEvent.MOUSE_OUT, this.onOut);
      }

      private function drawBackground() : void
      {
         var _w:Number = 78; var _h:Number = 42;
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

      // ========== 悬停弹出面板 ==========

      private function onOver(param1:MouseEvent) : void
      {
         this._isOver = true;
         this._bg.filters = [new GlowFilter(GLOW_COLOR, 0.6, 6, 6, 2)];
         this.showPopup();
      }

      private function onOut(param1:MouseEvent) : void
      {
         this._isOver = false;
         this._bg.filters = [];
         this.hidePopup();
      }

      private function showPopup() : void
      {
         if(this._players.length == 0) return;
         if(this._popup != null) { this.hidePopup(); }

         this._popup = new Sprite();
         var _pw:Number = 120;
         var _lineH:int = 16;
         var _ph:Number = Math.min(this._players.length, 20) * _lineH + 28;

         // 背景
         this._popup.graphics.lineStyle(1.5, BORDER_COLOR, 0.9);
         this._popup.graphics.beginFill(0x0d0804, 0.95);
         this._popup.graphics.drawRoundRect(0, 0, _pw, _ph, 6, 6);
         this._popup.graphics.endFill();

         // 标题栏
         this._popup.graphics.beginFill(0x1a1008, 0.9);
         this._popup.graphics.drawRoundRect(3, 3, _pw - 6, 20, 4, 4);
         this._popup.graphics.endFill();

         var _title:TextField = new TextField();
         _title.defaultTextFormat = new TextFormat("SimSun", 10, 0xFFD700, true);
         _title.text = "在线玩家 (" + this._players.length + ")";
         _title.autoSize = TextFieldAutoSize.CENTER;
         _title.selectable = false; _title.mouseEnabled = false;
         _title.x = _pw / 2 - _title.width / 2; _title.y = 5;
         this._popup.addChild(_title);

         // 玩家列表
         var _html:String = "";
         var _max:int = Math.min(this._players.length, 20);
         for(var i:int = 0; i < _max; i++)
         {
            var _p:Object = this._players[i];
            var _color:String = (_p.level >= 200) ? "#FF6B6B" : (_p.level >= 100) ? "#FFD700" : "#C8C8C8";
            _html += "<font color='" + _color + "'>Lv." + _p.level + " " + _p.name + "</font>\n";
         }
         if(this._players.length > 20) {
            _html += "<font color='#888888'>...及其他 " + (this._players.length - 20) + " 人</font>";
         }

         this._popupTF = new TextField();
         this._popupTF.defaultTextFormat = new TextFormat("SimSun", 10, 0xCCCCCC);
         this._popupTF.htmlText = _html;
         this._popupTF.selectable = false; this._popupTF.mouseEnabled = false;
         this._popupTF.x = 8; this._popupTF.y = 24;
         this._popupTF.width = _pw - 12; this._popupTF.height = _ph - 28;
         this._popup.addChild(this._popupTF);

         // 定位在面板下方
         this._popup.x = 0;
         this._popup.y = 44;
         addChild(this._popup);
      }

      private function hidePopup() : void
      {
         if(this._popup != null) {
            if(this._popup.parent) this._popup.parent.removeChild(this._popup);
            this._popup = null; this._popupTF = null;
         }
      }

      // ========== 轮询 ==========

      private function startPolling() : void
      {
         this.fetchData();
         this._timer = new Timer(30000);
         this._timer.addEventListener(TimerEvent.TIMER, this.onTimerHandler);
         this._timer.start();
      }

      private function onTimerHandler(param1:TimerEvent) : void { this.fetchData(); }

      private function fetchData() : void
      {
         // 获取在线人数
         this.fetchCount();
         // 获取在线玩家列表
         this.fetchPlayers();
         // 首次检查版本
         if(!this._versionChecked) { this._versionChecked = true; this.checkVersion(); }
      }

      private function fetchCount() : void
      {
         try {
            var _loader:URLLoader = new URLLoader();
            var _req:URLRequest = new URLRequest(AESController.getInstance().serverURL + "/api/online-count");
            _req.method = URLRequestMethod.POST;
            _req.contentType = "application/json"; _req.data = "{}";
            var _self:OnlineCountUI = this;
            _loader.addEventListener(Event.COMPLETE, function(p:*):void {
               try {
                  var _json:Object = JSON.parse(_loader.data as String);
                  if(_json.success == true) _self._countTF.text = String(_json.count);
               } catch(_e:Error) {}
            });
            _loader.load(_req);
         } catch(_e:Error) {}
      }

      private function fetchPlayers() : void
      {
         try {
            var _loader:URLLoader = new URLLoader();
            var _req:URLRequest = new URLRequest(AESController.getInstance().serverURL + "/api/online-players");
            _req.method = URLRequestMethod.POST;
            _req.contentType = "application/json"; _req.data = "{}";
            var _self:OnlineCountUI = this;
            _loader.addEventListener(Event.COMPLETE, function(p:*):void {
               try {
                  var _json:Object = JSON.parse(_loader.data as String);
                  if(_json.success == true && _json.players) {
                     _self._players = _json.players as Array;
                     if(_self._isOver) _self.showPopup();
                  }
               } catch(_e:Error) {}
            });
            _loader.load(_req);
         } catch(_e:Error) {}
      }

      private function checkVersion() : void
      {
         try {
            var _loader:URLLoader = new URLLoader();
            var _req:URLRequest = new URLRequest(AESController.getInstance().serverURL + "/api/version");
            _req.method = URLRequestMethod.POST;
            _req.contentType = "application/json"; _req.data = "{}";
            var _self:OnlineCountUI = this;
            _loader.addEventListener(Event.COMPLETE, function(p:*):void {
               try {
                  var _json:Object = JSON.parse(_loader.data as String);
                  if(_json.success && _json.version && _json.version != Config.CLIENT_VER) {
                     _self._dot.graphics.clear();
                     _self._dot.graphics.beginFill(DOT_ORANGE);
                     _self._dot.graphics.drawCircle(0, 0, 4);
                     _self._dot.graphics.endFill();
                  }
               } catch(_e:Error) {}
            });
            _loader.load(_req);
         } catch(_e:Error) {}
      }

      public function stopPolling() : void
      {
         if(this._timer != null) { this._timer.stop(); this._timer.removeEventListener(TimerEvent.TIMER, this.onTimerHandler); this._timer = null; }
         this.hidePopup();
      }
   }
}
