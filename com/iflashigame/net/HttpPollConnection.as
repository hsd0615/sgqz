package com.iflashigame.net
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.utils.Timer;
   import game.Config;

   public class HttpPollConnection extends EventDispatcher
   {
      private var _baseURL:String;
      private var _token:String;
      private var _pollTimer:Timer;
      private var _lastPollTime:Number = 0;
      private var _connected:Boolean = false;

      private static var _debugTF:* = null;
      public static function setDebugTextField(tf:*) : void { _debugTF = tf; }
      private function log(msg:String) : void {
         if (_debugTF != null) { try { _debugTF.appendText(msg+"\n"); } catch(e:Error) {} }
      }

      public function HttpPollConnection() { super(); }
      public function get connected() : Boolean { return _connected; }

      public function connect(host:String, port:int) : void
      {
         this._baseURL = "http://" + host + ":" + port;
         this._token = Config.token || "";
         this._connected = true;
         this._lastPollTime = new Date().getTime();

         this._pollTimer = new Timer(150);
         this._pollTimer.addEventListener(TimerEvent.TIMER, this.doPoll);
         this._pollTimer.start();

         this.log("web connected");
         dispatchEvent(new SocketEvent(SocketEvent.CONNECTED));
      }

      public function send(msg:Object) : void
      {
         if (!this._connected) return;
         // 包一层：服务端需要 {token, msg}
         var _wrap:Object = { token: this._token, msg: msg };
         var _json:String = this.toJson(_wrap);
         try {
            var _l:URLLoader = new URLLoader();
            var _r:URLRequest = new URLRequest(this._baseURL + "/api/poll/send");
            _r.method = URLRequestMethod.POST;
            _r.contentType = "application/json";
            _r.data = _json;
            _l.load(_r);
         } catch(_e:Error) {}
      }

      private function toJson(o:Object) : String {
         var p:Array = [];
         for (var k:String in o) {
            var v:* = o[k]; var vs:String;
            if (v is String) vs = '"' + String(v).replace(/\\/g,"\\\\").replace(/"/g,"\\\"") + '"';
            else if (v is Number || v is int) vs = v.toString();
            else if (v is Boolean) vs = v ? "true" : "false";
            else vs = "null";
            p.push('"' + k + '":' + vs);
         }
         return "{" + p.join(",") + "}";
      }

      private function doPoll(evt:TimerEvent) : void
      {
         if (!this._connected) return;
         var _self:HttpPollConnection = this;
         var _since:Number = this._lastPollTime;
         try {
            var _l:URLLoader = new URLLoader();
            var _r:URLRequest = new URLRequest(this._baseURL + "/api/poll/recv");
            _r.method = URLRequestMethod.POST;
            _r.contentType = "application/json";
            _r.data = this.toJson({ token: this._token, since: _since });
            _l.addEventListener(Event.COMPLETE, function(e:Event):void {
               try {
                  var _raw:String = _l.data as String;
                  var _b:int = _raw.indexOf("{");
                  if (_b < 0) return;
                  _raw = _raw.substring(_b);
                  var _msgs:Array = [];
                  var _svrTime:Number = 0;
                  var _ms:int = _raw.indexOf('"messages"');
                  if (_ms > 0) {
                     var _as:int = _raw.indexOf('[', _ms);
                     var _ae:int = _as >= 0 ? _raw.indexOf(']', _as) : -1;
                     if (_as >= 0 && _ae >= 0) {
                        try {
                           var _obj:* = (JSON.parse is Function) ? JSON.parse(_raw.substring(_as, _ae + 1)) : null;
                           if (_obj is Array) _msgs = _obj as Array;
                        } catch(_e:Error) {}
                     }
                  }
                  var _ts:int = _raw.indexOf('"serverTime"');
                  if (_ts > 0) {
                     var _tc:int = _raw.indexOf(':', _ts);
                     var _te:int = _raw.indexOf(',', _tc);
                     if (_te < 0) _te = _raw.indexOf('}', _tc);
                     if (_tc > 0 && _te > 0) _svrTime = Number(_raw.substring(_tc + 1, _te));
                  }
                  for each (var _m:Object in _msgs) {
                     if (_m && _m.msg) _self.dispatchEvent(new SocketEvent(SocketEvent.DATA, _m.msg));
                  }
                  _self._lastPollTime = _svrTime > 0 ? _svrTime : new Date().getTime();
               } catch(_e:Error) {}
            });
            _l.load(_r);
         } catch(_e:Error) {}
      }

      public function close() : void
      {
         this._connected = false;
         if (this._pollTimer != null) { this._pollTimer.stop(); this._pollTimer.removeEventListener(TimerEvent.TIMER, this.doPoll); this._pollTimer = null; }
         dispatchEvent(new SocketEvent(SocketEvent.CLOSED));
      }
   }
}
