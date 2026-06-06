package com.iflashigame.net
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.Socket;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import com.adobe.serialization.json.JSON;

   /**
    * TCP Socket 连接封装，替代 Adobe Cirrus RTMFP
    *
    * 协议格式:
    *   [4 bytes big-endian: payload length]
    *   [N bytes: UTF-8 JSON string]
    */
   public class SocketConnection extends EventDispatcher
   {
      public static const CONNECTED:String = "socketConnected";
      public static const CLOSED:String = "socketClosed";
      public static const DATA:String = "socketData";
      public static const ERROR:String = "socketError";

      private var _socket:Socket;
      private var _host:String;
      private var _port:int;
      private var _connected:Boolean = false;
      private var _connecting:Boolean = false;

      // Read buffer: accumulates partial data from TCP stream
      private var _readBuffer:ByteArray;
      private var _expectedLength:int = -1;

      public function SocketConnection()
      {
         super();
      }

      public function get connected():Boolean
      {
         return _connected;
      }

      public function get connecting():Boolean
      {
         return _connecting;
      }

      /**
       * 连接服务器
       */
      public function connect(host:String, port:int):void
      {
         trace("[SocketConnection] 连接: " + host + ":" + port);
         _host = host;
         _port = port;
         _connecting = true;

         if (_socket != null)
         {
            try { _socket.close(); } catch (e:Error) {}
         }

         _socket = new Socket();
         _socket.endian = Endian.BIG_ENDIAN;
         _socket.timeout = 10000;  // 10秒超时

         _socket.addEventListener(Event.CONNECT, onConnectHandler);
         _socket.addEventListener(Event.CLOSE, onCloseHandler);
         _socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketDataHandler);
         _socket.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
         _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityErrorHandler);

         _readBuffer = new ByteArray();
         _expectedLength = -1;

         try
         {
            _socket.connect(host, port);
         }
         catch (e:Error)
         {
            trace("[SocketConnection] 连接异常: " + e.message);
            _connecting = false;
            dispatchEvent(new SocketEvent(SocketEvent.CONNECT_FAIL, e.message));
         }
      }

      /**
       * 发送 JSON 消息
       */
      public function send(msg:Object):void
      {
         if (!_connected || _socket == null)
         {
            trace("[SocketConnection] 未连接，无法发送");
            return;
         }

         try
         {
            var jsonStr:String = com.adobe.serialization.json.JSON.encode(msg);
            var bytes:ByteArray = new ByteArray();
            bytes.endian = Endian.BIG_ENDIAN;
            bytes.writeUTFBytes(jsonStr);

            // Write length prefix + payload
            var out:ByteArray = new ByteArray();
            out.endian = Endian.BIG_ENDIAN;
            out.writeInt(bytes.length);
            out.writeBytes(bytes);

            _socket.writeBytes(out);
            _socket.flush();
            trace("[SocketConnection] 发送: " + msg.type);
         }
         catch (e:Error)
         {
            trace("[SocketConnection] 发送失败: " + e.message);
         }
      }

      /**
       * 关闭连接
       */
      public function close():void
      {
         trace("[SocketConnection] 关闭连接");
         _connected = false;
         _connecting = false;
         if (_socket != null)
         {
            try
            {
               _socket.removeEventListener(Event.CONNECT, onConnectHandler);
               _socket.removeEventListener(Event.CLOSE, onCloseHandler);
               _socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketDataHandler);
               _socket.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
               _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityErrorHandler);
               _socket.close();
            }
            catch (e:Error) {}
            _socket = null;
         }
         _readBuffer = null;
      }

      // ======================== Event Handlers ========================

      private function onConnectHandler(event:Event):void
      {
         trace("[SocketConnection] 连接成功");
         _connected = true;
         _connecting = false;
         dispatchEvent(new SocketEvent(SocketEvent.CONNECTED));
      }

      private function onCloseHandler(event:Event):void
      {
         trace("[SocketConnection] 连接关闭");
         _connected = false;
         _connecting = false;
         dispatchEvent(new SocketEvent(SocketEvent.CLOSED));
      }

      private function onIOErrorHandler(event:IOErrorEvent):void
      {
         trace("[SocketConnection] IO错误: " + event.text);
         _connecting = false;
         dispatchEvent(new SocketEvent(SocketEvent.CONNECT_FAIL, event.text));
      }

      private function onSecurityErrorHandler(event:SecurityErrorEvent):void
      {
         trace("[SocketConnection] 安全错误: " + event.text);
         _connecting = false;
         dispatchEvent(new SocketEvent(SocketEvent.CONNECT_FAIL, event.text));
      }

      /**
       * 接收数据 — 处理 TCP 粘包/拆包
       */
      private function onSocketDataHandler(event:ProgressEvent):void
      {
         try
         {
            while (_socket.bytesAvailable > 0)
            {
               // If we're waiting for a complete message
               if (_expectedLength < 0)
               {
                  // Need at least 4 bytes for the length prefix
                  if (_socket.bytesAvailable < 4)
                  {
                     break;
                  }
                  _expectedLength = _socket.readInt();
                  _readBuffer = new ByteArray();
               }

               // How many bytes can we read now
               var available:int = _socket.bytesAvailable;
               var need:int = _expectedLength - _readBuffer.length;
               var readCount:int = available < need ? available : need;

               if (readCount > 0)
               {
                  _socket.readBytes(_readBuffer, _readBuffer.length, readCount);
               }

               // Complete message received?
               if (_readBuffer.length >= _expectedLength)
               {
                  _readBuffer.position = 0;
                  var jsonStr:String = _readBuffer.readUTFBytes(_readBuffer.length);
                  try
                  {
                     var msg:Object = com.adobe.serialization.json.JSON.decode(jsonStr);
                     dispatchEvent(new SocketEvent(SocketEvent.DATA, msg));
                  }
                  catch (e:Error)
                  {
                     trace("[SocketConnection] JSON解析失败: " + e.message + " data=" + jsonStr);
                  }
                  _readBuffer = new ByteArray();
                  _expectedLength = -1;
               }
            }
         }
         catch (e:Error)
         {
            trace("[SocketConnection] 数据读取错误: " + e.message);
         }
      }
   }
}
