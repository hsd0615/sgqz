package com.iflashigame.controller
{
   import com.iflashigame.utils.AESTools;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.net.sendToURL;
   import flash.system.ApplicationDomain;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import game.Config;

   public class AESController extends EventDispatcher implements IController
   {
      private static var _instance:AESController;

      private static const KEY:String = "f5b7e8b70048457f";
      private static const IV:String = "9fdf3dc3b9f26c42";

      // ===== 配置 =====
      private var _debug:Boolean = true;
      private var _test:Boolean = false;  // false = 使用真实服务器

      private var _root:DisplayObjectContainer;
      private var _maskDomain:ApplicationDomain;
      private var _maskCode:String;
      private var _mask:MovieClip;
      private var _maskRelative:String = "";

      // 服务器 URL（可通过 game.xml 覆盖）
      private var _serverURL:String = "http://127.0.0.1:3000";

      // ===== 请求管理 =====
      private var _listeners:Object;
      private var _fun:Object;
      private var _funParamer:Object;
      private var _listenerCount:int = 0;
      private var _timeOut:int = 60;  // 超时秒数（60秒，给Flash充足处理时间）
      private var _timer:Timer;

      private var _disable:Boolean;
      private var _testInstance:IControllerTest;
      private var _requestCode:String = "gbk";
      private var _responseCode:String = "utf-8";
      private var _codeStrack:Dictionary;

      // 重试配置
      private var _retryCount:int = 0;
      private var _retryMap:Dictionary;

      public function AESController(param1:SingletonEnforcer)
      {
         _listeners = {};
         _fun = {};
         _funParamer = {};
         _codeStrack = new Dictionary();
         _retryMap = new Dictionary();
         super();

         // 每秒检查超时
         _timer = new Timer(1000);
         _timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
         _testInstance = Test.getInstance();
      }

      public static function getInstance() : IController
      {
         if(AESController._instance == null)
         {
            AESController._instance = new AESController(new SingletonEnforcer());
         }
         return AESController._instance;
      }

      public function setRoot(param1:DisplayObjectContainer, param2:String, param3:ApplicationDomain = null) : *
      {
         _root = param1;
         _maskCode = param2;
         _maskDomain = param3 == null ? ApplicationDomain.currentDomain : param3;
      }

      public function get serverURL() : String { return _serverURL; }
      public function set serverURL(param1:String) : * { _serverURL = param1; }

      public function get debug() : Boolean { return _debug; }
      public function set debug(param1:Boolean) : void { _debug = param1; }

      public function get test() : Boolean { return _test; }
      public function set test(param1:Boolean) : void { _test = param1; }

      public function get testInstance() : IControllerTest { return _testInstance; }
      public function set testInstance(param1:IControllerTest) : void { _testInstance = param1; }

      public function get disable() : Boolean { return _disable; }
      public function set disable(param1:Boolean) : void { _disable = param1; }

      public function get requestCode() : String { return _requestCode; }
      public function set requestCode(param1:String) : * { _requestCode = param1; }

      public function get responseCode() : String { return _responseCode; }
      public function set responseCode(param1:String) : * { _responseCode = param1; }

      // ======================== 发送请求（保持公开 API 不变） ========================

      /**
       * 发送 JSON 请求并等待响应
       */
      public function sendJSON(param1:Object, param2:Function, param3:String = "") : String
      {
         if(_disable) return null;

         var stamp:String = getTimer().toString() + Math.random().toFixed(5);
         param1.stamp = stamp;

         var callbackFun:Function = param1.fun;
         var callbackParams:Array = param1.funParamer;
         delete param1.fun;
         delete param1.funParamer;

         if(_test)
         {
            // 测试模式：使用本地模拟数据
            loadTestData(param1, param2, callbackFun, callbackParams);
         }
         else if(param3 == "")
         {
            send(param1, param2, _serverURL, callbackFun, callbackParams);
         }
         else
         {
            send(param1, param2, param3, callbackFun, callbackParams);
         }
         return stamp;
      }

      /**
       * 发送 JSON 请求（无需响应，发后即忘）
       */
      public function sendJSONToURL(param1:Object, param2:String = "") : String
      {
         if(_disable) return null;

         var stamp:String = getTimer().toString() + Math.random().toFixed(5);
         param1.stamp = stamp;

         if(_test)
         {
            trace("测试模式 sendJSONToURL:", JSON.stringify(param1));
            return stamp;
         }

         var url:String = param2 == "" ? _serverURL : param2;

         // 根据 head 映射到正确的 API 端点
         url = mapHeadToURL(param1.head, url);

         var jsonData:String = JSON.stringify(param1);

         if(_debug)
         {
            trace("==========客户端发送数据(无需服务器反馈)===================");
            trace("发送到:", url);
            trace(jsonData);
            trace("==========客户端数据发送完毕===================");
         }

         var request:URLRequest = new URLRequest();
         request.url = url;
         request.method = URLRequestMethod.POST;
         request.contentType = "application/json";
         request.data = jsonData;
         sendToURL(request);

         return stamp;
      }

      public function close(param1:String) : *
      {
         if(_listeners.hasOwnProperty(param1))
         {
            try
            {
               _listeners[param1].instance.close();
            }
            catch(e:Error) {}
            delete _codeStrack[_listeners[param1].instance];
            delete _listeners[param1];
            --_listenerCount;
         }
      }

      // ======================== 私有方法 ========================

      private function createMask() : *
      {
         // 遮罩已禁用 - 避免每次请求显示转圈动画
      }

      /**
       * 发送 HTTP 请求
       */
      private function send(param1:Object, param2:Function, param3:String, param4:Function, param5:Array) : *
      {
         // 记录监听器
         _listeners[param1.stamp] = {
            fun: param2,
            count: _timeOut,
            event: param1.event
         };
         _fun[param1.stamp] = param4;
         _funParamer[param1.stamp] = param5;

         // 遮罩层
         if(param1.mask == true)
         {
            createMask();
            if(_mask != null && _root != null)
            {
               _root.addChild(_mask);
            }
            _maskRelative = param1.stamp;
            delete param1.mask;
         }

         ++_listenerCount;
         if(!_timer.running) _timer.start();

         // 映射 URL
         var url:String = mapHeadToURL(param1.head, param3);

         // 构造请求体 - 新版直接发送 JSON
         var jsonData:String = JSON.stringify(param1);

         if(_debug)
         {
            trace("==========客户端发送数据===================");
            trace("发送到:", url);
            trace(jsonData);
            trace("==========客户端数据发送完毕===================");
         }

         var request:URLRequest = new URLRequest();
         request.url = url;
         request.method = URLRequestMethod.POST;
         request.contentType = "application/json";
         request.data = jsonData;

         var loader:URLLoader = new URLLoader();
         _listeners[param1.stamp].instance = loader;
         _codeStrack[loader] = {
            stamp: param1.stamp,
            head: param1.head,
            roleID: param1.roleID,
            requestObj: param1,
            callback: param2,
            fun: param4,
            funParamer: param5,
            url: url,
            retries: 0
         };

         loader.addEventListener(Event.COMPLETE, onURLLoaderCompleteHandler);
         loader.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityErrorHandler);
         loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusHandler);

         try
         {
            loader.load(request);
         }
         catch(e:Error)
         {
            trace("URLLoader 加载错误:", e.message);
            dispatchEvent(new ControllerEvent(ControllerEvent.ERROR, {text: "网络请求失败: " + e.message}));
         }
      }

      /**
       * 将旧的 head 代码映射到新的 REST API 路径
       */
      private function mapHeadToURL(head:*, baseURL:String):String
      {
         // 默认使用新 API 路径
         var headCode:int = int(head);
         var path:String = "";

         switch(headCode)
         {
            // Auth
            case 9999: path = "/api/auth/login"; break;
            case 10000: path = "/api/auth/register"; break;
            case 9998: path = "/api/auth/active"; break;

            // Game
            case 10011: path = "/api/game/fight-result"; break;
            case 10023: path = "/api/game/fight-prepare"; break;
            case 10012: path = "/api/game/p2p-result"; break;
            case 18: path = "/api/game/save"; break;
            case 10014: path = "/api/game/history"; break;
            case 10013: path = "/api/game/use-ammo"; break;
            case 10015: path = "/api/game/verify"; break;

            // Shop
            case 10010: path = "/api/shop/buy"; break;
            case 10009: path = "/api/shop/dianka"; break;

            // General
            case 10001: case 10002: case 10003: path = "/api/general/recruit"; break;
            case 10004: path = "/api/general/upgrade"; break;
            case 10005: path = "/api/general/evolve"; break;
            case 10006: path = "/api/general/kezhi"; break;
            case 10007: path = "/api/general/talent"; break;
            case 10008: path = "/api/general/deploy"; break;
            case 10020: path = "/api/general/reforge"; break;
            case 10050: path = "/api/general/equip"; break;
            case 10051: path = "/api/general/unequip"; break;
            case 10052: path = "/api/general/sell"; break;
            case 10053: path = "/api/recruit/cards"; break;
            case 10054: path = "/api/recruit/flip"; break;

            // Fuben
            case 10016: path = "/api/fuben/count"; break;
            case 10017: path = "/api/fuben/enter"; break;
            case 10024: path = "/api/fuben/prepare"; break;
            case 10018: path = "/api/fuben/award"; break;
            case 10019: path = "/api/fuben/flip"; break;

            // Leitai
            case 10030: path = "/api/leitai/list"; break;
            case 10031: path = "/api/leitai/flush"; break;
            case 10032: path = "/api/leitai/be-master"; break;
            case 10034: path = "/api/leitai/be-slave"; break;
            case 10035: path = "/api/leitai/continue"; break;
            case 10033: path = "/api/leitai/exit"; break;
            case 10036: path = "/api/leitai/fight-over"; break;
            case 10037: path = "/api/leitai/heartbeat"; break;
            case 10038: path = "/api/leitai/rank"; break;

            // Misc
            case 10021: path = "/api/misc/award"; break;
            case 10022: path = "/api/misc/compensate"; break;
            case 10040: path = "/api/misc/claim-dianka"; break;
            case 10041: path = "/api/misc/guoqing"; break;

            default:
               // 未知的 head，使用通用端点
               path = "/api/game";
               break;
         }

         // 从 baseURL 中提取 host:port
         var apiBase:String = "http://127.0.0.1:3000";
         if(baseURL && baseURL.indexOf("http") == 0)
         {
            // 提取 host:port 部分
            var colonSlashSlash:int = baseURL.indexOf("://");
            var nextSlash:int = baseURL.indexOf("/", colonSlashSlash + 3);
            if(nextSlash != -1)
            {
               apiBase = baseURL.substring(0, nextSlash);
            }
            else
            {
               apiBase = baseURL;
            }
         }

         return apiBase + path;
      }

      // ======================== 事件处理 ========================

      private function onHttpStatusHandler(param1:HTTPStatusEvent) : *
      {
         if(_codeStrack[param1.currentTarget] != null)
         {
            _codeStrack[param1.currentTarget].code = param1.status;
            return;
         }
         throw new Error("没有指定的dispatcher对象");
      }

      private function onTimerHandler(param1:TimerEvent) : *
      {
         if(_listenerCount <= 0)
         {
            trace("控制器的计时器已经停止");
            _timer.stop();
            _timer.reset();
            return;
         }

         for(var stamp:* in _listeners)
         {
            --_listeners[stamp].count;
            if(_listeners[stamp].count <= 0)
            {
               trace(_listeners[stamp].event + "事件请求超时 (30秒)");
               dispatchEvent(new ControllerEvent(ControllerEvent.ERROR, {text: "服务器请求超时"}));

               if(_maskRelative == stamp)
               {
                  _maskRelative = "";
                  if(_root != null && _mask != null)
                  {
                     try { _root.removeChild(_mask); } catch(e:Error) {}
                  }
               }

               // 清理
               if(_listeners[stamp] && _listeners[stamp].instance)
               {
                  delete _codeStrack[_listeners[stamp].instance];
               }
               delete _listeners[stamp];
               delete _fun[stamp];
               delete _funParamer[stamp];
               --_listenerCount;
            }
         }
      }

      private function onURLLoaderCompleteHandler(param1:Event) : *
      {
         param1.currentTarget.removeEventListener(Event.COMPLETE, onURLLoaderCompleteHandler);

         var trackInfo:Object = _codeStrack[param1.currentTarget];
         if(trackInfo == null)
         {
            trace("URLLoader 回调中找不到跟踪信息");
            return;
         }

         var rawData:String;
         var decodedData:Object;

         // 根治: 检查响应头字符判断是否为纯JSON, 避免Base64/AES误解析长字符串
         var httpResponse:String = URLLoader(param1.target).data as String;
         if(httpResponse != null && httpResponse.length > 0 && httpResponse.charAt(0) == "{")
         {
            // 新服务器纯JSON，直接使用
            rawData = httpResponse;
         }
         else
         {
            // 旧版AES加密响应
            try
            {
               rawData = AESTools.decrypt(httpResponse, KEY, IV, _responseCode);
            }
            catch(e:Error)
            {
               rawData = httpResponse;
            }
         }

         if(_debug)
         {
            trace("==========服务器返回数据===================");
            trace(rawData);
            trace("==========服务器数据完毕===================");
         }

         try
         {
            decodedData = JSON.parse(rawData);
         }
         catch(e:Error)
         {
            trace("JSON 解析失败:", e.message);
            dispatchEvent(new ControllerEvent(ControllerEvent.ERROR, {text: "服务器返回数据格式错误"}));
            cleanupListener(trackInfo.stamp);
            return;
         }

         processResponse(decodedData, trackInfo);
      }

      private function processResponse(data:Object, trackInfo:Object):void
      {
         var stamp:String = data.stamp || trackInfo.stamp;

         if(!_listeners.hasOwnProperty(stamp) && !_fun.hasOwnProperty(trackInfo.stamp))
         {
            // 尝试用 trackInfo 的 stamp
            stamp = trackInfo.stamp;
         }

         if(_listeners.hasOwnProperty(stamp))
         {
            if(_maskRelative == stamp)
            {
               _maskRelative = "";
               if(_root != null && _mask != null)
               {
                  try { _root.removeChild(_mask); } catch(e:Error) {}
               }
            }

            // 恢复回调函数
            data.fun = _fun[stamp];
            data.funParamer = _funParamer[stamp];
            delete _fun[stamp];
            delete _funParamer[stamp];

            // 调用回调
            var callback:Function = _listeners[stamp].fun as Function;
            if(callback != null)
            {
               callback(data);
            }

            // 清理
            cleanupListener(stamp);
         }
         else
         {
            // 可能重复响应或 stamp 不匹配，尝试直接调用 trackInfo 回调
            if(trackInfo.callback != null)
            {
               data.fun = trackInfo.fun;
               data.funParamer = trackInfo.funParamer;
               trackInfo.callback(data);
            }
            cleanupListener(trackInfo.stamp);
         }
      }

      private function cleanupListener(stamp:String):void
      {
         if(_listeners.hasOwnProperty(stamp))
         {
            if(_listeners[stamp].instance)
            {
               delete _codeStrack[_listeners[stamp].instance];
            }
         }
         delete _listeners[stamp];
         delete _fun[stamp];
         delete _funParamer[stamp];
         --_listenerCount;
      }

      private function onIOErrorHandler(param1:IOErrorEvent) : *
      {
         var trackInfo:Object = _codeStrack[param1.currentTarget];
         if(trackInfo == null) return;

         var statusCode:String = String(trackInfo.code || "N/A");
         var headCode:int = int(trackInfo.head);
         var stamp:String = String(trackInfo.stamp);
         var roleID:String = String(trackInfo.roleID || "");

         // 重试逻辑
         var retries:int = trackInfo.retries || 0;
         if(retries < _retryCount)
         {
            trace("请求失败，重试 " + (retries + 1) + "/" + _retryCount + ": " + trackInfo.url);
            trackInfo.retries = retries + 1;

            // 重新发送
            var retryRequest:URLRequest = new URLRequest();
            retryRequest.url = trackInfo.url;
            retryRequest.method = URLRequestMethod.POST;
            retryRequest.contentType = "application/json";
            retryRequest.data = JSON.stringify(trackInfo.requestObj);

            var retryLoader:URLLoader = new URLLoader();
            _listeners[stamp].instance = retryLoader;
            _codeStrack[retryLoader] = trackInfo;
            retryLoader.addEventListener(Event.COMPLETE, onURLLoaderCompleteHandler);
            retryLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
            retryLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityErrorHandler);
            retryLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusHandler);
            retryLoader.load(retryRequest);
            return;
         }

         trace("请求彻底失败: " + statusCode + " | head=" + headCode + " | roleID=" + roleID);
         delete _codeStrack[param1.currentTarget];
         cleanupListener(stamp);
         dispatchEvent(new ControllerEvent(ControllerEvent.ERROR, {
            text: "通讯错误，网络请求无法响应。错误码(" + statusCode + "|" + headCode + "|" + roleID + ")"
         }));
      }

      private function onSecurityErrorHandler(param1:SecurityErrorEvent) : *
      {
         dispatchEvent(new ControllerEvent(ControllerEvent.ERROR, {text: "安全错误，无法取得授权文件!"}));
      }

      // ======================== 测试数据（保持兼容） ========================

      private function loadTestData(param1:Object, param2:Function, param3:Function, param4:Array) : *
      {
         _testInstance = Test.getInstance();
         trace("使用测试模式:", _testInstance);
         if(_testInstance == null)
         {
            throw new Error("测试数据所用的实例为空");
         }
         if(_debug)
         {
            trace("==========客户端发送数据(测试)===================");
            trace(JSON.stringify(param1));
            trace("==========客户端数据发送完毕===================");
         }
         param1.fun = param3;
         param1.funParamer = param4;
         var responseData:Object = _testInstance.getData(param1);
         trace("==========收到模拟数据===================");
         trace(JSON.stringify(responseData));
         trace("==========模拟数据接收完毕===================");
         param2(responseData);
      }
   }
}

class SingletonEnforcer
{
   public function SingletonEnforcer()
   {
      super();
   }
}
