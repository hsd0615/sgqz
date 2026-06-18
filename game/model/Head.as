package game.model
{
   public class Head
   {
      
      public static const HELLO_NEIGHBOR:int = 2;
      
      public static const STATUS_CHANG:int = 3;
      
      public static const FIGHT_RESULT:int = 4;
      
      public static const FIGHT_RESULT_EXCEPTION:int = 13;
      
      public static const LOGOUT:int = 5;
      
      public static const CHAT:int = 6;
      
      public static const REQUEST:int = 7;
      
      public static const RESPONSE:int = 8;
      
      public static const REQUEST_CANCEL:int = 9;
      
      public static const REMOVE_NEIGHBOR:int = 11;
      
      public static const NEIGHBOR_REPLY:int = 12;
      
      public static const NET_INFO:int = 14;
      
      public static const FANGSHUANGKAI_POST:int = 15;
      
      public static const DELAY_REQUEST:int = 110;
      
      public static const DELAY_RESPONSE:int = 111;
      
      public static const DELAY_SEND:int = 112;
      
      public static const SOLDIER_FROM_SEVER:int = 120;
      
      public static const SOLDIER_FROM_CLIENT:int = 121;
      
      public static const FIGHT_START:int = 130;
      
      public static const ACTION_FROM_SERVER:int = 140;
      
      public static const ACTION_FROM_CLIENT:int = 141;
      
      public static const HURT_FROM_SERVER:int = 142;
      
      public static const HURT_FROM_CLIENT:int = 143;
      
      public static const SHANBI_FROM_SERVER:int = 1420;
      
      public static const SHANBI_FROM_CLIENT:int = 1421;
      
      public static const HUIFU_FROM_SERVER:int = 1422;
      
      public static const HUIFU_FROM_CLIENT:int = 1423;
      
      public static const FANSHANG_FROM_SERVER:int = 1424;
      
      public static const FANSHANG_FROM_CLIENT:int = 1425;
      
      public static const JIANSHANG_FROM_SERVER:int = 1426;
      
      public static const JIANSHANG_FROM_CLIENT:int = 1427;
      
      public static const RESULT_FROM_SERVER:int = 144;
      
      public static const P2P_TALK:int = 150;
      
      public static const FIGHT_STATUS_CHANGE:int = 160;
      
      public static const ADD_SOLDIER:int = 170;
      
      public static const REMOVE_SOLDIER:int = 180;
      
      public static const CANCEL_FIGHT:int = 190;
      
      public static const LEITAI_RESULT_FROM_SERVER:int = 200;
      
      public static const SERVER_DOWN:int = 10;
      
      public static const SERVER_COUNT_REQUEST:int = 1000;
      
      public static const SERVER_COUNT_RESPONSE:int = 1001;
      
      public static const SERVER_MESSAGE:int = 1002;
      
      public static const SERVER_KICK:int = 1003;
      
      public static const SERVER_INFO_REQUEST:int = 1004;
      
      public static const SERVER_INFO_RESPONSE:int = 1005;
      
      public static const SERVER_ROLE_MODIFY:int = 1007;
      
      public static const HTTP_GET_DIANKA:int = 10;
      
      public static const HTTP_BUY_ITEM:int = 11;
      
      public static const HTTP_PAY_DIANKA:int = 12;
      
      public static const HTTP_CREATE_ROLE:int = 13;
      
      public static const HTTP_GET_FUBEN_COUNT:int = 14;
      
      public static const HTTP_ENTER_FUBEN:int = 15;
      
      public static const HTTP_FUBEN_RESULT:int = 16;
      
      public static const HTTP_FUBEN_FORWORD:int = 17;
      
      public static const HTTP_SAVE_DATA:int = 18;
      
      public static const HTTP_GET_AWARD:int = 19;
      
      public static const HTTP_NEW_ACTIVE:int = 9998;
      
      public static const HTTP_NEW_LOGIN:int = 9999;
      
      public static const HTTP_NEW_REGISTER:int = 10000;
      
      public static const HTTP_NEW_PUTONG_ZHAOMU:int = 10001;
      
      public static const HTTP_NEW_QIUXIAN_ZHAOMU:int = 10002;
      
      public static const HTTP_NEW_DIANKA_ZHAOMU:int = 10003;
      
      public static const HTTP_NEW_GENERAL_SHENGJI:int = 10004;
      
      public static const HTTP_NEW_GENERAL_JINHUA:int = 10005;
      
      public static const HTTP_NEW_GENERAL_KEZHI_SHENGJI:int = 10006;
      
      public static const HTTP_NEW_GENERAL_TIANFU:int = 10007;
      
      public static const HTTP_NEW_SHANGZHEN:int = 10008;
      
      public static const HTTP_NEW_DIANKA:int = 10009;
      
      public static const HTTP_NEW_BUYITEM:int = 10010;
      
      public static const HTTP_NEW_FIGHT_RESULT:int = 10011;
      
      public static const HTTP_NEW_P2PFIGHT_RESULT:int = 10012;
      
      public static const HTTP_NEW_USE_AMMO:int = 10013;
      
      public static const HTTP_NEW_SAVE_HISTORY:int = 10014;
      
      public static const HTTP_NEW_YANZHENG:int = 10015;
      
      public static const HTTP_NEW_FUBEN_COUNT:int = 10016;
      
      public static const HTTP_NEW_FUBEN_LOGIN:int = 10017;
      
      public static const HTTP_NEW_FUBEN_AWARD:int = 10018;
      
      public static const HTTP_NEW_FUBEN_FANPAI:int = 10019;
      
      public static const HTTP_NEW_SHUXINGCHONGXI:int = 10020;
      
      public static const HTTP_NEW_GETAWARD:int = 10021;
      
      public static const HTTP_NEW_BUCHANG:int = 10022;

      public static const HTTP_NEW_EQUIP:int = 10050;

      public static const HTTP_NEW_UNEQUIP:int = 10051;
      
      public static const HTTP_NEW_LEITAI_LIST:int = 10030;
      
      public static const HTTP_NEW_LEITAI_FLUSH:int = 10031;
      
      public static const HTTP_NEW_LEITAI_BEMASTER:int = 10032;
      
      public static const HTTP_NEW_LEITAI_EXIT:int = 10033;
      
      public static const HTTP_NEW_LEITAI_BESLAVE:int = 10034;
      
      public static const HTTP_NEW_LEITAI_CONTINUE:int = 10035;
      
      public static const HTTP_NEW_LEITAI_FIGHTOVER:int = 10036;
      
      public static const HTTP_NEW_LEITAI_HEARTBEAT:int = 10037;
      
      public static const HTTP_NEW_LEITAI_PAIHANG:int = 10038;
      
      public static const HTTP_NEW_GONGLEI_EXIT:int = 10039;
      
      public static const HTTP_NEW_LING_DIANKA:int = 10040;
      
      public static const HTTP_NEW_GUOQING:int = 10041;
       
      
      public function Head()
      {
         super();
      }
   }
}
