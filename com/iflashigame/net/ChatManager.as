package com.iflashigame.net
{
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.NetGroup;
   import flash.net.NetStream;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import game.Config;
   import game.model.Head;
   import game.model.RoleModel;
   import com.adobe.serialization.json.JSON;

   /**
    * ChatManager — 网络通信核心（单例）
    *
    * 新版实现：使用 SocketConnection (TCP) 替代 Adobe Cirrus RTMFP
    * 保持公开 API 完全兼容，所有 P2PEvent 事件类型不变
    */
   public class ChatManager extends EventDispatcher
   {
      private static var _instance:ChatManager;
      private static var MAX:int = 200;

      // ===== 公开属性（保持兼容） =====
      private var _peerID:String = "";
      private var _farID:String;
      private var _server:Boolean;
      private var _delay:int;
      private var _fight:Boolean;
      private var _helloMode:Boolean = false;
      private var _leitaiMode:Boolean = false;
      private var _leizhu:Boolean = true;

      // ===== 新的 Socket 连接 =====
      private var _socketConn:SocketConnection;
      private var _connected:Boolean = false;

      // ===== 房间状态 =====
      private var _currentRooms:Array = [];   // 已加入的房间名列表
      private var _pendingJoinRoom:String;     // 等待加入的房间

      // ===== 邻居列表（游戏大厅内） =====
      private var _arr:Array = [];

      // ===== P2P 对战相关 =====
      private var _battleTargetPeerID:String;  // 对战目标 peerID

      // ===== 擂台相关 =====
      private var _gongleiClock:Timer;
      private var _gongleiReplayTime:int;

      // ===== 旧的 NetConnection/NetGroup 引用（保持兼容，实际不再使用） =====
      private var _nc:NetConnection;
      private var _com1:NetGroup;
      private var _com2:NetGroup;
      private var _com3:NetGroup;
      private var _sendStream:NetStream;
      private var _recievedStream:NetStream;
      private var _publishStream:NetStream;
      private var _timerArr:Dictionary;

      public function ChatManager(param1:SingletonEnforcer)
      {
         this._arr = [];
         super();
      }

      public static function getInstance() : ChatManager
      {
         if(ChatManager._instance == null)
         {
            ChatManager._instance = new ChatManager(new SingletonEnforcer());
         }
         return ChatManager._instance;
      }

      // ======================== 公开 getter/setter（保持兼容） ========================

      public function get peerID() : String { return _peerID; }
      public function get farID() : String { return _farID; }

      public function set farID(param1:String) : *
      {
         _farID = param1;
         if(_farID == null && _connected && _leitaiMode == false)
         {
            // Notify server that battle ended
            sendWS({type: "battle_end", farId: null});
         }
      }

      public function get server() : Boolean { return _server; }
      public function set server(param1:Boolean) : * { _server = param1; }

      public function get leizhu() : Boolean { return _leizhu; }
      public function set leizhu(param1:Boolean) : * { _leizhu = param1; }

      public function get delay() : int { return _delay; }
      public function set delay(param1:int) : * { _delay = param1; }

      public function get fight() : Boolean { return _fight; }
      public function set fight(param1:Boolean) : * { _fight = param1; }

      public function get leitaiMode() : Boolean { return _leitaiMode; }
      public function set leitaiMode(param1:Boolean) : * { _leitaiMode = param1; }

      public function get neighBors() : Array { return _arr; }

      // ======================== 新版方法：TCP 连接替代 Cirrus ========================

      /**
       * 连接服务器（替代 cirrusConnect）
       * @param host 服务器地址
       * @param authStr 认证字符串 (json: {token, roleId, ...})
       */
      public function connectToServer(host:String, port:int, authData:Object):void
      {
         trace(RoleModel.getInstance().roleName, "connectToServer:", host, port);

         if(_socketConn != null)
         {
            _socketConn.close();
         }

         _socketConn = new SocketConnection();
         _socketConn.addEventListener(SocketEvent.CONNECTED, onSocketConnected);
         _socketConn.addEventListener(SocketEvent.CONNECT_FAIL, onSocketConnectFail);
         _socketConn.addEventListener(SocketEvent.CLOSED, onSocketClosed);
         _socketConn.addEventListener(SocketEvent.DATA, onSocketData);
         _socketConn.connect(host, port);
      }

      /**
       * 保持旧方法名兼容 — cirrusConnect 内部转为 connectToServer
       * 参数1: 服务器地址 (原为 rtmfp URL)
       * 参数2: 开发者密钥 (原为 Cirrus dev key，现为认证 token)
       */
      public function cirrusConnect(param1:String, param2:String) : *
      {
         trace("cirrusConnect (已适配新协议):", param1, param2);

         // 尝试从参数中解析 host:port
         var host:String = Config.SERVER_HOST || "127.0.0.1";
         var port:int = Config.SERVER_PORT || 3000;

         // 如果第一个参数包含 :// 尝试解析
         if(param1 && param1.indexOf("://") != -1)
         {
            try
            {
               var parts:Array = param1.split("://")[1].split(":");
               host = parts[0];
               if(parts.length > 1) port = parseInt(parts[1]);
            }
            catch(e:Error) {}
         }

         var authData:Object = {
            type: "auth",
            roleID: RoleModel.getInstance().roleID,
            roleName: RoleModel.getInstance().roleName,
            level: RoleModel.getInstance().level,
            imageId: RoleModel.getInstance().imageID,
            agent: Config.AGENT,
            token: Config.token 
};

         connectToServer(host, port, authData);
      }

      // ======================== 保持旧方法名兼容 ========================

      public function com1Connect(param1:String) : *
      {
         _pendingJoinRoom = "server:" + param1;
         if(_connected)
         {
            joinRoomInternal(_pendingJoinRoom);
         }
      }

      public function com2Connect(param1:String) : *
      {
         _pendingJoinRoom = "world";
         if(_connected)
         {
            joinRoomInternal(_pendingJoinRoom);
         }
      }

      public function com3Connect(param1:String) : *
      {
         _pendingJoinRoom = "area:" + param1;
         if(_connected)
         {
            joinRoomInternal(_pendingJoinRoom);
         }
      }

      private function joinRoomInternal(roomName:String):void
      {
         sendWS({type: "join_room", room: roomName});
         _currentRooms.push(roomName);
         trace("加入房间:", roomName);
      }

      // ======================== P2P 对战连接（替代 p2pConnect） ========================

      public function p2pConnect(param1:String, param2:Boolean, param3:int = -1) : *
      {
         var pID:String = param1;
         var isServer:Boolean = param2;
         var replayTime:int = param3;

         trace("向", pID, "发起p2p连接 (新协议)");

         if(_leitaiMode == false)
         {
            _server = isServer;
            _farID = pID;

            if(isServer == false)
            {
               // 客户方：请求对战
               _battleTargetPeerID = pID;
               sendWS({
                  type: "battle_request",
                  targetPeerId: pID,
                  server: false,
                  leftInfo: {
                     name: RoleModel.getInstance().roleName,
                     level: RoleModel.getInstance().level,
                     image: RoleModel.getInstance().imageID 
}
               });
               // 派发等待事件（与原有行为一致）
               dispatchEvent(new P2PEvent(P2PEvent.P2P_CONNECT_WAIT));
            }
            else
            {
               // 服务方：等待接受
               _battleTargetPeerID = pID;
               sendWS({
                  type: "battle_accept",
                  fromPeerId: pID
               });
               dispatchEvent(new P2PEvent(P2PEvent.P2P_CONNECT_SUCCESS));
            }
         }
         else
         {
            // 擂台模式
            _leizhu = isServer;
            _farID = pID;

            if(_leizhu == true)
            {
               // 擂主：等待攻擂者连接
               _battleTargetPeerID = null;  // 等待任何人
               if(_gongleiClock == null)
               {
                  _gongleiClock = new Timer(1000);
                  _gongleiClock.addEventListener(TimerEvent.TIMER_COMPLETE, gongleiCloskCompleteHandler);
               }
               _gongleiReplayTime = replayTime;
               _gongleiClock.repeatCount = replayTime;
               _gongleiClock.reset();
               _gongleiClock.start();
            }
            else
            {
               // 攻擂者：请求连接擂主
               _battleTargetPeerID = pID;
               sendWS({
                  type: "battle_request",
                  targetPeerId: pID,
                  server: false,
                  leitai: true
               });
               if(_gongleiClock == null)
               {
                  _gongleiClock = new Timer(1000);
                  _gongleiClock.addEventListener(TimerEvent.TIMER_COMPLETE, gongleiCloskCompleteHandler);
               }
               _gongleiReplayTime = replayTime;
               _gongleiClock.repeatCount = replayTime;
               _gongleiClock.reset();
               _gongleiClock.start();
               dispatchEvent(new P2PEvent(P2PEvent.LEITAI_CONNECT_WAIT));
            }
         }
      }

      private function gongleiCloskCompleteHandler(param1:TimerEvent) : *
      {
         if(_gongleiClock != null)
         {
            _gongleiClock.removeEventListener(TimerEvent.TIMER_COMPLETE, gongleiCloskCompleteHandler);
            _gongleiClock.reset();
         }
         var pID:String = _farID;
         _farID = null;
         dispatchEvent(new P2PEvent(P2PEvent.LEITAI_CONNECT_FAIL, false, {"pID": pID}));
      }

      // ======================== 发送消息 ========================

      /**
       * P2P 发送（替代 NetStream.send）
       */
      public function p2pSend(param1:Object) : *
      {
         trace(RoleModel.getInstance().roleName, "发送" + param1.head + "事件");

         if(_connected && _farID != null)
         {
            sendWS({
               type: "battle_action",
               to: _farID,
               data: param1 
});

            // 同时本地派发（模拟原 Direct Connections 的本地处理）
            if(param1.head == Head.FIGHT_START)
            {
               dispatchEvent(new P2PEvent(P2PEvent.P2P_DATA, false, param1));
            }
         }
      }

      /**
       * 世界频道广播（替代 NetGroup.post）
       */
      public function worldPost(param1:Object) : *
      {
         if(_connected)
         {
            sendWS({type: "chat", room: "world", text: param1});
         }
      }

      /**
       * 区域频道广播（替代 NetGroup.post）
       */
      public function areaPost(param1:Object) : *
      {
         if(_connected)
         {
            sendWS({type: "chat", room: "area", data: param1});
         }
      }

      // ======================== 邻居管理（保持兼容） ========================

      public function resetNeightBor() : *
      {
         _arr = [];
      }

      public function addNeighBor(param1:Object) : *
      {
         if(findNeighBor(param1.pID) != -1) return;
         if(_arr.length > MAX) return;
         _arr.push(param1);
         dispatchEvent(new P2PEvent(P2PEvent.ADD_NEIGHBOR, false, param1));
      }

      public function removeNeighBor(param1:String) : *
      {
         var index:int = findNeighBor(param1);
         if(index != -1)
         {
            _arr.splice(index, 1);
            dispatchEvent(new P2PEvent(P2PEvent.REMOVE_NEIGHBOR, false, {"pID": param1}));
         }
      }

      private function findNeighBor(param1:*) : int
      {
         var len:int = _arr.length;
         for(var i:int = 0; i < len; i++)
         {
            if(_arr[i].pID == param1) return i;
         }
         return -1;
      }

      public function changeStatus(param1:Object) : *
      {
         var index:int = findNeighBor(param1.pID);
         if(index != -1)
         {
            _arr[index].status = param1.status;
            dispatchEvent(new P2PEvent(P2PEvent.CHANGE_STATUS, false, param1));
         }
      }

      // ======================== 关闭/清理 ========================

      public function close() : *
      {
         trace("ChatManager 退出函数被调用");
         clearTimeArr();
         _helloMode = false;
         _arr = [];
         _currentRooms = [];
         _farID = null;
         _server = false;
         _leitaiMode = false;
         _leizhu = false;

         if(_socketConn != null)
         {
            _socketConn.close();
            _socketConn = null;
         }
         _connected = false;

         // 清理旧引用
         _com1 = null;
         _com2 = null;
         _com3 = null;
         _nc = null;
         _sendStream = null;
         _recievedStream = null;
         _publishStream = null;

         if(_gongleiClock != null)
         {
            _gongleiClock.reset();
            _gongleiClock.removeEventListener(TimerEvent.TIMER_COMPLETE, gongleiCloskCompleteHandler);
            _gongleiClock = null;
         }
      }

      public function recievedClose() : *
      {
         _server = false;
         if(_recievedStream != null)
         {
            try { _recievedStream.close(); } catch (e:Error) {}
            _recievedStream = null;
         }
      }

      private function clearTimeArr() : *
      {
         if(_timerArr != null)
         {
            for(var key:* in _timerArr)
            {
               try
               {
                  _timerArr[key].timer.stop();
                  _timerArr[key].stream.close();
               }
               catch(e:Error) {}
            }
            _timerArr = null;
         }
      }

      // ======================== 服务器信息请求（保持兼容） ========================

      public function requestServerInfo():void
      {
         if(_connected)
         {
            sendWS({type: "server_info"});
         }
      }

      // ======================== Socket 事件处理 ========================

      private function onSocketConnected(event:SocketEvent):void
      {
         trace("Socket 连接成功，发送认证");

         _connected = true;
         _helloMode = true;

         // 发送认证
         var authData:Object = {
            type: "auth",
            roleID: RoleModel.getInstance().roleID,
            roleName: RoleModel.getInstance().roleName,
            level: RoleModel.getInstance().level,
            imageId: RoleModel.getInstance().imageID,
            agent: Config.AGENT,
            token: Config.token 
};
         sendWS(authData);
      }

      private function onSocketConnectFail(event:SocketEvent):void
      {
         trace("Socket 连接失败:", event.message);
         _connected = false;

         // 派发失败事件（兼容原有的 CIRRUS_CONNECT_FAIL）
         dispatchEvent(new P2PEvent(P2PEvent.CIRRUS_CONNECT_FAIL));
      }

      private function onSocketClosed(event:SocketEvent):void
      {
         trace("Socket 连接关闭");
         _connected = false;
         _helloMode = false;

         // 通知 UI 断线
         dispatchEvent(new P2PEvent(P2PEvent.SERVER_DOWN));
      }

      private function onSocketData(event:SocketEvent):void
      {
         var msg:Object = event.data;
         if(msg == null) return;

         var msgType:String = msg.type as String;

         switch(msgType)
         {
            case "auth_success":
               handleAuthSuccess(msg);
               break;

            case "auth_fail":
               dispatchEvent(new P2PEvent(P2PEvent.CIRRUS_CONNECT_FAIL));
               break;

            case "room_joined":
               handleRoomJoined(msg);
               break;

            case "neighbor_join":
               handleNeighborJoin(msg);
               break;

            case "neighbor_leave":
               handleNeighborLeave(msg);
               break;

            case "neighbor_list":
               handleNeighborList(msg);
               break;

            case "chat":
               handleChat(msg);
               break;

            case "battle_request":
               handleBattleRequest(msg);
               break;

            case "battle_accept":
            case "battle_start":
               handleBattleStart(msg);
               break;

            case "battle_decline":
               handleBattleDecline(msg);
               break;

            case "battle_action":
               handleBattleAction(msg);
               break;

            case "battle_result":
               handleBattleResult(msg);
               break;

            case "battle_opponent_disconnected":
               handleOpponentDisconnected(msg);
               break;

            case "p2p_message":
               handleP2PMessage(msg);
               break;

            case "server_info_response":
               handleServerInfo(msg);
               break;

            case "server_kick":
               handleServerKick(msg);
               break;

            case "error":
               trace("服务器错误:", msg.message);
               break;

            default:
               trace("未知消息类型:", msgType);
         }
      }

      // ======================== 消息处理器 ========================

      private function handleAuthSuccess(msg:Object):void
      {
         _peerID = msg.peerId || "";
         trace("认证成功，peerID:", _peerID);

         // 派发连接成功（兼容原有的 CIRRUS_CONNECT_SUCCESS）
         dispatchEvent(new P2PEvent(P2PEvent.CIRRUS_CONNECT_SUCCESS));

         // 如果有待加入的房间，自动加入
         if(_pendingJoinRoom != null)
         {
            joinRoomInternal(_pendingJoinRoom);
            _pendingJoinRoom = null;
         }
      }

      private function handleRoomJoined(msg:Object):void
      {
         var roomName:String = msg.room;

         // 派发对应的 NetGroup 连接成功事件
         if(roomName.indexOf("server:") == 0)
         {
            dispatchEvent(new P2PEvent(P2PEvent.COM1_CONNECT_SUCCESS));
         }
         else if(roomName == "world")
         {
            dispatchEvent(new P2PEvent(P2PEvent.COM2_CONNECT_SUCCESS));
         }
         else if(roomName.indexOf("area:") == 0)
         {
            // com3 连接成功
            dispatchEvent(new P2PEvent(P2PEvent.COM3_CONNECT_SUCCESS));

            // 如果有 HELLO_NEIGHBOR 逻辑
            if(_helloMode == true)
            {
               _helloMode = false;
               dispatchEvent(new P2PEvent(P2PEvent.HELLO_NEIGHBOR, false));
            }
         }

         // 处理邻居列表
         if(msg.neighbors != null)
         {
            var neighbors:Array = msg.neighbors as Array;
            for each(var neighbor:Object in neighbors)
            {
               addNeighBor(neighbor);
            }
         }
      }

      private function handleNeighborJoin(msg:Object):void
      {
         var peer:Object = msg.peer;
         if(peer != null)
         {
            addNeighBor(peer);
            // 同时触发 AREA_POST_NOTIFY（用于大厅信息更新）
            var ba:ByteArray = new ByteArray();
            ba.writeObject(peer);
            dispatchEvent(new P2PEvent(P2PEvent.AREA_POST_NOTIFY, false, ba));
         }
      }

      private function handleNeighborLeave(msg:Object):void
      {
         var peerId:String = msg.peerId;
         if(peerId != null)
         {
            removeNeighBor(peerId);
            // 通过 POST_NOTIFY 通知移除
            var ba:ByteArray = new ByteArray();
            ba.writeUTF(peerId);
            dispatchEvent(new P2PEvent(P2PEvent.AREA_POST_NOTIFY, false, ba));
         }
      }

      private function handleNeighborList(msg:Object):void
      {
         if(msg.neighbors != null)
         {
            resetNeightBor();
            var neighbors:Array = msg.neighbors as Array;
            for each(var neighbor:Object in neighbors)
            {
               addNeighBor(neighbor);
            }
         }
      }

      private function handleChat(msg:Object):void
      {
         var ba:ByteArray = new ByteArray();

         // 根据聊天房间类型派发不同事件
         if(msg.room == "world")
         {
            ba.writeObject(msg);
            dispatchEvent(new P2PEvent(P2PEvent.WORLD_POST_NOTIFY, false, ba));
         }
         else
         {
            ba.writeObject(msg);
            dispatchEvent(new P2PEvent(P2PEvent.AREA_POST_NOTIFY, false, ba));
         }
      }

      private function handleBattleRequest(msg:Object):void
      {
         trace("收到对战请求:", msg.fromName);

         _farID = msg.from;
         _server = (msg.server == true);

         if(_leitaiMode == true)
         {
            // 擂台模式：擂主收到攻擂者请求
            if(_leizhu)
            {
               _farID = msg.from;
               sendWS({
                  type: "battle_accept",
                  fromPeerId: msg.from
               });
               dispatchEvent(new P2PEvent(P2PEvent.LEITAI_CONNECT_SUCCESS));
            }
         }
         else
         {
            // 普通 P2P：收到对战请求
            _farID = msg.from;
            // 等待 UI 层调用 p2pConnect 响应
            // 现在先通知 P2P 相关逻辑
            var ba:ByteArray = new ByteArray();
            ba.writeObject({
               from: msg.from,
               fromName: msg.fromName,
               fromLevel: msg.fromLevel,
               fromImage: msg.fromImage
            });
            dispatchEvent(new P2PEvent(P2PEvent.P2P_DATA, false, {head: Head.REQUEST, data: msg}));
         }
      }

      private function handleBattleStart(msg:Object):void
      {
         trace("战斗开始!");

         // 停止擂台计时器
         if(_gongleiClock != null)
         {
            _gongleiClock.reset();
            _gongleiClock.removeEventListener(TimerEvent.TIMER_COMPLETE, gongleiCloskCompleteHandler);
         }

         if(msg.opponentPID != null)
         {
            _farID = msg.opponentPID;
         }

         if(_leitaiMode)
         {
            dispatchEvent(new P2PEvent(P2PEvent.LEITAI_CONNECT_SUCCESS));
         }

         // 派发战斗数据事件（包含 leftInfo/rightInfo/direct）
         var ba:ByteArray = new ByteArray();
         ba.writeObject(msg);
         dispatchEvent(new P2PEvent(P2PEvent.P2P_DATA, false, msg));
      }

      private function handleBattleDecline(msg:Object):void
      {
         trace("对战被拒绝:", msg.from);
         _farID = null;
         dispatchEvent(new P2PEvent(P2PEvent.P2P_CONNECT_FAIL, false, {pID: msg.from}));
      }

      private function handleBattleAction(msg:Object):void
      {
         // 直接转发对战数据给 UI 处理
         if(msg.data != null)
         {
            dispatchEvent(new P2PEvent(P2PEvent.P2P_DATA, false, msg.data));
         }
      }

      private function handleBattleResult(msg:Object):void
      {
         trace("收到战斗结果:", msg.result);
         _farID = null;
         var ba:ByteArray = new ByteArray();
         ba.writeObject(msg);
         dispatchEvent(new P2PEvent(P2PEvent.P2P_DATA, false, msg));
      }

      private function handleOpponentDisconnected(msg:Object):void
      {
         trace("对手断开连接:", msg.peerId);
         _farID = null;

         if(_leitaiMode)
         {
            dispatchEvent(new P2PEvent(P2PEvent.LEITAI_ABEND_CLOSE));
         }
         else
         {
            dispatchEvent(new P2PEvent(P2PEvent.P2P_ABEND_CLOSE));
         }
      }

      private function handleP2PMessage(msg:Object):void
      {
         if(msg.data != null)
         {
            dispatchEvent(new P2PEvent(P2PEvent.P2P_MESSAGE, false, msg.data));
         }
      }

      private function handleServerInfo(msg:Object):void
      {
         // 服务器信息响应：统计在线人数等
         var ba:ByteArray = new ByteArray();
         ba.writeObject(msg);
         dispatchEvent(new P2PEvent(P2PEvent.AREA_POST_NOTIFY, false, ba));
      }

      private function handleServerKick(msg:Object):void
      {
         trace("被踢出:", msg.reason);
         dispatchEvent(new P2PEvent(P2PEvent.P2P_KICK, false, msg));
      }

      // ======================== 内部辅助方法 ========================

      private function sendWS(msg:Object):void
      {
         if(_socketConn != null && _socketConn.connected)
         {
            _socketConn.send(msg);
         }
         else
         {
            trace("[ChatManager] Socket未连接，消息未发送:", msg.type);
         }
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
