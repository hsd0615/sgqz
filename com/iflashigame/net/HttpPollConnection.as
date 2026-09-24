package com.iflashigame.net
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.utils.getTimer;
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
      private var _cursor:Number = 0;
      private var _pollLoader:URLLoader;
      private var _pollStarted:int = 0;
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
         this._lastPollTime = 0;
         this._cursor = 0;

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
         // 使用原生JSON.stringify — 手动序列化不支持嵌套对象导致msg字段变成null
         try {
            if (JSON is Object && JSON.stringify is Function) {
               return JSON.stringify(o);
            }
         } catch(_e:Error) {}
         var p:Array = [];
         for (var k:String in o) {
            var v:* = o[k]; var vs:String;
            if (v is String) vs = '"' + String(v).replace(/\\/g,"\\\\").replace(/"/g,"\\\"") + '"';
            else if (v is Number || v is int) vs = v.toString();
            else if (v is Boolean) vs = v ? "true" : "false";
            else if (v is Array) { var arr:Array = []; for each(var av:* in v) { arr.push(this.toJson(av)); } vs = '[' + arr.join(',') + ']'; }
            else if (v is Object) vs = this.toJson(v);
            else vs = 'null';
            p.push('"' + k + '":' + vs);
         }
         return '{' + p.join(',') + '}';
      }

      private function acceptPollResponse(raw:String):Boolean
      {
         var response:Object = JSON.parse(raw);
         if(response == null || response.success !== true || !(response.messages is Array)) return false;
         if(response.cursor == null || isNaN(Number(response.cursor)) || Number(response.cursor) < this._cursor) return false;
         for each(var message:Object in response.messages)
         {
            if(message && message.msg) dispatchEvent(new SocketEvent(SocketEvent.DATA, message.msg));
         }
         this._cursor = Number(response.cursor);
         return true;
      }

      private function doPoll(evt:TimerEvent) : void
      {
         if(!this._connected) return;
         if(this._pollLoader != null)
         {
            if(getTimer() - this._pollStarted < 10000) return;
            try { this._pollLoader.close(); } catch(closeError:Error) {}
            this._pollLoader = null;
         }
         var self:HttpPollConnection = this;
         var loader:URLLoader = new URLLoader();
         this._pollLoader = loader;
         this._pollStarted = getTimer();
         var fail:Function = function(event:Event):void {
            if(self._pollLoader == loader) self._pollLoader = null;
         };
         loader.addEventListener(IOErrorEvent.IO_ERROR, fail);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fail);
         loader.addEventListener(Event.COMPLETE, function(event:Event):void {
            if(self._pollLoader != loader || !self._connected) return;
            try { self.acceptPollResponse(String(loader.data)); }
            catch(parseError:Error) { self.log("poll response invalid; retrying same cursor"); }
            self._pollLoader = null;
         });
         try {
            var request:URLRequest = new URLRequest(this._baseURL + "/api/poll/recv");
            request.method = URLRequestMethod.POST;
            request.contentType = "application/json";
            request.data = this.toJson({token:this._token, cursor:this._cursor});
            loader.load(request);
         } catch(loadError:Error) { this._pollLoader = null; }
      }

      public function close() : void
      {
         this._connected = false;
         if(this._pollLoader != null) { try { this._pollLoader.close(); } catch(e:Error) {} this._pollLoader = null; }
         if (this._pollTimer != null) { this._pollTimer.stop(); this._pollTimer.removeEventListener(TimerEvent.TIMER, this.doPoll); this._pollTimer = null; }
         dispatchEvent(new SocketEvent(SocketEvent.CLOSED));
      }
   }
}
