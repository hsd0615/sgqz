package com.iflashigame.net
{
   import flash.events.Event;
   
   public class P2PEvent extends Event
   {
      
      public static const CIRRUS_CONNECT_SUCCESS:String = "cirrusConnectSuccess";
      
      public static const CIRRUS_CONNECT_FAIL:String = "cirrusConnectFail";
      
      public static const COM1_CONNECT_SUCCESS:String = "com1ConnectSuccess";
      
      public static const COM1_CONNECT_FAIL:String = "com1ConnectFail";
      
      public static const COM2_CONNECT_SUCCESS:String = "com2ConnectSuccess";
      
      public static const COM2_CONNECT_FAIL:String = "com2ConnectFail";
      
      public static const COM3_CONNECT_SUCCESS:String = "com3ConnectSuccess";
      
      public static const COM3_CONNECT_FAIL:String = "com3ConnectFail";
      
      public static const SERVER_DOWN:String = "serverDown";
      
      public static const NET_DISCONNECTION:String = "netDisconnection";
      
      public static const ADD_NEIGHBOR:String = "addNeighBor";
      
      public static const REMOVE_NEIGHBOR:String = "removeNeighBor";
      
      public static const CHANGE_STATUS:String = "changeStatus";
      
      public static const HELLO_NEIGHBOR:String = "helloNeighBor";
      
      public static const WORLD_POST_NOTIFY:String = "worldPostNotify";
      
      public static const AREA_POST_NOTIFY:String = "areaPostNotify";
      
      public static const SENDTO_NOTIFY:String = "sendToNotify";
      
      public static const P2P_DATA:String = "p2pData";
      
      public static const P2P_CONNECT_SUCCESS:String = "p2pConnectSuccess";
      
      public static const P2P_CONNECT_FAIL:String = "p2pConnectFail";
      
      public static const P2P_CONNECT_WAIT:String = "p2pConnectWait";
      
      public static const P2P_CLOSE:String = "p2pClose";
      
      public static const P2P_ABEND_CLOSE:String = "p2pAbendClose";
      
      public static const P2P_MESSAGE:String = "p2pMessage";
      
      public static const P2P_MODIFY:String = "p2pModify";
      
      public static const P2P_KICK:String = "p2pKick";
      
      public static const LEITAI_CONNECT_SUCCESS:String = "leitaiConnectSuccess";
      
      public static const LEITAI_CONNECT_WAIT:String = "leitaiConnectWait";
      
      public static const LEITAI_CONNECT_FAIL:String = "leitaiConnectFail";
      
      public static const LEITAI_CLOSE:String = "leitaiClose";
      
      public static const LEITAI_ABEND_CLOSE:String = "leitaiAbendClose";
       
      
      public var data:Object;
      
      public function P2PEvent(param1:String, param2:Boolean = false, param3:Object = null, param4:Boolean = false)
      {
         this.data = param3;
         super(param1,param2,param4);
      }
      
      override public function clone() : Event
      {
         return new P2PEvent(type,bubbles,this.data,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("P2PEvent","type","bubbles","cancelable","eventPhase");
      }
   }
}
