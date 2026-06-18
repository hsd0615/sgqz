package game.events
{
   import flash.events.Event;
   
   public class UIEvent extends Event
   {
      
      public static const NEW_GAME:String = "newGame";
      
      public static const GET_SAVED:String = "getSaved";
      
      public static const GAMEINFO:String = "gameInfo";
      
      public static const MESSAGE:String = "message";
      
      public static const CLOSE:String = "uiClose";
      
      public static const CREATE_ROLE:String = "createRole";
      
      public static const CONNECT_SERVER:String = "connectServer";
      
      public static const SERVER_SUCCESS:String = "ServerSuccess";
      
      public static const ENTER_GAMECENTER:String = "enterGameCenter";
      
      public static const EXIT_GAMECENTER:String = "exitGameCenter";
      
      public static const CLOSE_NETSTATUS_PANEL:String = "closeNetstatusPanel";
      
      public static const SEND_TALK:String = "sendTalk";
      
      public static const CHANGE_STATUS:String = "changeStatus";
      
      public static const FIGHT_REQUEST:String = "fightRequest";
      
      public static const PAIHANG_CLICK:String = "paihangClick";
      
      public static const QUICK_FIGHT_REQUEST:String = "quickFightRequest";
      
      public static const AGREE_FIGHT:String = "agreeFight";
      
      public static const DEFUSE_FIGHT:String = "defuseFight";
      
      public static const BE_CANCEL_FIGHT:String = "beCancelFight";
      
      public static const BE_DEFUSE_FIGHT:String = "beDefuseFight";
      
      public static const CANCEL_FIGHTWAIT:String = "cancelFightWait";
      
      public static const CREATE_GATE:String = "createGate";
      
      public static const OPEN_SHOP:String = "openShop";
      
      public static const OPEN_STAGE:String = "openStage";
      
      public static const OPEN_WUJIANG:String = "openWujiang";
      
      public static const OPEN_BUDUI:String = "openBudui";
      
      public static const OPEN_ZHAOMU:String = "openZhaomu";
      
      public static const OPEN_DUIZHAN:String = "openDuizhan";
      
      public static const OPEN_BEIBAO:String = "openBeibao";
      
      public static const OPEN_BAOCUN:String = "openBaocun";
      
      public static const OPEN_BUCHANG:String = "openBuchang";
      
      public static const OPEN_LEITAI:String = "openLeitai";
      
      public static const OPEN_LEITAI_GUIZE:String = "openLeitaiGuize";
      
      public static const SHENGJI_CLICK:String = "shengjiClick";
      
      public static const JINHUA_CLICK:String = "jinhuaClick";
      
      public static const JINHUA:String = "jinhua";
      
      public static const SHOW_FIGHT_RESULT:String = "showFightResult";
      
      public static const PART_COMPLETE:String = "partComplete";
      
      public static const SHOW_TIPS:String = "showTips";
      
      public static const HIDE_TIPS:String = "hideTips";
      
      public static const SHOW_AGENT_LOGPANEL:String = "showAgentLogPanel";
      
      public static const CHONGZHI_CLICK:String = "chongzhiClick";
      
      public static const BUYITEM_CLICK:String = "buyItemClick";
      
      public static const QIUXIANLING_CLICK:String = "qiuxianlingClick";
      
      public static const FLUSH_DIANKA:String = "flushDianka";
      
      public static const NEW_PLAYER_CREATED:String = "newPlayerCreated";
      
      public static const SPEED_CHECKOUT:String = "speedCheckout";
      
      public static const ZHUANPAN_CLICK:String = "zhuanpanClick";
      
      public static const USE_LABA_BY_DIANKA:String = "useLabaByDianka";
      
      public static const XIONGNU_CLICK:String = "xiongnuClick";
      
      public static const WOKOU_CLICK:String = "wokouClick";
      
      public static const INJOY_FUBEN:String = "injoyFuben";
      
      public static const START_FUBEN:String = "creatFuben";
      
      public static const CLOSE_FUBEN:String = "closeFuben";
      
      public static const OPEN_FANPAI:String = "openFanpai";
      
      public static const CHOOSE_PAIMIAN:String = "choosPaimian";
      
      public static const SEND_PAIMIAN:String = "sendPaimian";
      
      public static const FUBEN_SPEED_CHECKOUT:String = "fubenSpeedCheckout";
      
      public static const SAVE_SUCCESS_DATA:String = "saveSuccessData";
      
      public static const SHUANGKAI_POST:String = "shuangkaiPost";
      
      public static const SERVER_SELECTED:String = "serverSelected";
      
      public static const SHOW_GENERAL_INFO:String = "showGeneralInfo";
      
      public static const CHONGXI_CLICK:String = "chongxiClick";
      
      public static const GET_AWARD_INFO:String = "getAwardInfo";
      
      public static const BECOME_LEIZHU:String = "becomeLeizhu";
      
      public static const GONGLEI:String = "gonglei";
      
      public static const CONTINUE_LEIZHU:String = "continueLeizhu";
      
      public static const EXIT_LEIZHU:String = "exitLeizhu";
      
      public static const LING_DIANKA:String = "lingDianka";
      
      public static const LING_GUOQING:String = "lingGuoqing";

      public static const OPEN_EQUIP:String = "openEquip";


      public var data:Object;
      
      public function UIEvent(param1:String, param2:Boolean = false, param3:Object = null, param4:Boolean = false)
      {
         this.data = param3;
         super(param1,param2,param4);
      }
      
      override public function clone() : Event
      {
         return new UIEvent(type,bubbles,this.data,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("UIEvent","type","bubbles","cancelable","eventPhase");
      }
   }
}
