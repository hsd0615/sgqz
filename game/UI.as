package game
{
   import com.iflashigame.controller.AESController;
   import com.iflashigame.controller.ControllerEvent;
   import com.iflashigame.net.ChatManager;
   import com.iflashigame.net.P2PEvent;
   import com.iflashigame.sound.MySound;
   import com.iflashigame.talk.NetInfoType;
   import com.iflashigame.talk.TalkEvent;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.AESTools;
   import com.iflashigame.utils.GlobalTimer;
   import com.iflashigame.utils.Tools;
   import flash.display.DisplayObject;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import game.events.FightEvent;
   import game.events.TimerStr;
   import game.events.UIEvent;
   import game.fuben.StageID;
   import game.fuben.Xiongnu;
   import game.fuben.XiongnuConfig;
   import game.model.ArmyInfo;
   import game.model.Head;
   import game.model.RoleModel;
   import game.model.RoleStatus;
   import game.ui.Alert;
   import game.ui.BagPanel;
   import game.ui.ConnectWait;
   import game.ui.Cover;
   import game.ui.CreateRolePanel;
   import game.ui.FightFromPanel;
   import game.ui.FightResultPanel;
   import game.ui.FightWait;
   import game.ui.GameCenterUI;
   import game.ui.GameInfo;
   import game.ui.GameStory;
   import game.ui.GeneralInfoPanel;
   import game.ui.GeneralJinhuaPanel;
   import game.ui.GeneralListPanel;
   import game.ui.GeneralManagerPanel;
   import game.ui.GeneralZhaomuPanel;
   import game.ui.Guide;
   import game.ui.Guoqing1;
   import game.ui.Guoqing2;
   import game.ui.LeitaiGuizePanel;
   import game.ui.LeitaiPanel;
   import game.ui.LeitaiResultPanel;
   import game.ui.Map;
   import game.ui.NetStatusUI;
   import game.ui.SelectServerPanel;
   import game.ui.ShangzhenPanel;
   import game.ui.ShopPanel;
   import game.ui.SkinCode;
   import game.ui.StageListPanel;
   import game.ui.YanzhengPanel;
   import game.ui.fuben.FanpaiPanel;
   import game.ui.fuben.FubenCheckPanel;
   import game.ui.fuben.FubenResultPanel;
   
   public class UI extends Sprite
   {
       
      
      private var _cover:Cover;
      
      private var _netStatusPanel:NetStatusUI;
      
      private var _createRolePanel:CreateRolePanel;
      
      private var _gameCenter:GameCenterUI;
      
      private var _fightFromPanel:FightFromPanel;
      
      private var _generalListPanel:GeneralListPanel;
      
      private var _generalInfoPanel:GeneralInfoPanel;
      
      private var _generalManagerPanel:GeneralManagerPanel;
      
      private var _generalJinhuaPanel:GeneralJinhuaPanel;
      
      private var _shangzhenPanel:ShangzhenPanel;
      
      private var _zhaomuPanel:GeneralZhaomuPanel;
      
      private var _bagPanel:BagPanel;
      
      private var _stageListPanel:StageListPanel;
      
      private var _fightResultPanel:FightResultPanel;
      
      private var _gameStory:GameStory;
      
      private var _guoqing1:Guoqing1;
      
      private var _guoqing2:Guoqing2;
      
      private var _gameInfo:GameInfo;
      
      private var _leitaiPanel:LeitaiPanel;
      
      private var _leitaiResultPanel:LeitaiResultPanel;
      
      private var _p2pFight:P2PFight;
      
      private var _fightWait:FightWait;
      
      private var _xiongnuFuben:Xiongnu;
      
      private var _guide:Guide;
      
      private var _connectWait:ConnectWait;
      
      private var _shopPanel:ShopPanel;
      
      private var _yanzhengmaPanel:YanzhengPanel;
      
      private var _xiongnuFight:Xiongnu;
      
      private var _fubenCheckPanel:FubenCheckPanel;

      private var _fubenResultPanel:FubenResultPanel;

      private var _currentFubenStageID:int = 1;
      
      private var _fanpaiPanel:FanpaiPanel;
      
      private var _selectServerPanel:SelectServerPanel;
      
      private var _map:Map;
      
      private var _str:String = "rRDXhUsAGNLuk/NUYJt/cq8ymnINYmg1/JOGheJVDPyCmY3w7n+KxNtxN3HeXoNI0ZuuH7Uvh2Uz4tpwv5cyOH8LKNSTcEWVzo1Sd/C+tIyRfAQ1XSFGmWrrDiHQrOhuWr3MJrGfWm/ss3VwXFFGCoC0tF+iyJUNePsRFiHdJ9L6S6Djs6B7PXzJiLLe+KtV7NPHXQvKTrlGo7G2BkZOHkeVND/ZOWFlahniME4QEa0X70CBBkj5NOajzgdPfJe9EHtju3vaONVYav9H23J97NhLRYqtI9qAIwkxaPfbyRZMEf5L8s+K5j+rjxeVpTiTEwAVavbRhSSNlS+AHaOt8PssCw3rbBGNAS7J70S5HCTKieUCcxuXE/qLUC5BbwFkcjif1aMYcGd2xZibqNcWG3OZ3Vkg3IkmHm2O2BbyGPtUhcSzk3fjaRG/kque1rHhx99+7SJD1A7IfzXr2+qVCsVMErlzpmdMTj/N01CcnID7ACUtYn3g49S1jBd+JBCFWxeB5Uc/sy5JwpSv/qum8BqmtEHyq5yrysqIwNguF80XbWwMsA5dTqJGX/cl1MPxlP/DSlT0OGb/vgI+wocJFXi++uFMObmOHw3+B7w27VnsUVVFwj7awBDAeqgcjn1L4/GpYbU3/GnBcLZ3FDU9BA==";
      
      private var _channel1:String = "kHQGphrjxh+lA3/evkf1+hSLp+YGbvDdu2OjdYGvYbK8R7WpLXetDGOfn56ZB3Xs3h1vQmYx7lmtYJnMSiYprL239VIheXGZm9X/xqXxNjxTRlh/PJkwxoXNA7VT2AUCAz+UXTSfeODuqrOtKK6oX/djKweicbTEqGqheoSDObfpFiXn5hvpysCocBsmv+fi9EdVNexfBA0lnYnI2tjNOgq3jPTtl6hlq3zukrfTF5iOh2OQqee+076KkSyQwwmxJKFqRTWlBHAUZOK38FuOC8ycCHBBjRmC1S2Zpy4yRyJwXw2N0Ie8OTib9GM2pnaQPpKCybg3D3SeZAunFJPGZQ==";
      
      private var _channel2:String = "kHQGphrjxh+lA3/evkf1+hSLp+YGbvDdu2OjdYGvYbK8R7WpLXetDGOfn56ZB3Xs3h1vQmYx7lmtYJnMSiYprL239VIheXGZm9X/xqXxNjxTRlh/PJkwxoXNA7VT2AUCAz+UXTSfeODuqrOtKK6oX/djKweicbTEqGqheoSDObfpFiXn5hvpysCocBsmv+fi9EdVNexfBA0lnYnI2tjNOgq3jPTtl6hlq3zukrfTF5iOh2OQqee+076KkSyQwwmxD+sdaBxTXcJiYY+CRv7XN1bkaSawy4bQ8CxpQuP7mM/8ad+D82EDdp8JcVIUMP03fj9x6hU/tNHcfM94gaoZPw==";
      
      private var _channel3:String = "kHQGphrjxh+lA3/evkf1+hSLp+YGbvDdu2OjdYGvYbK8R7WpLXetDGOfn56ZB3Xs3h1vQmYx7lmtYJnMSiYprL239VIheXGZm9X/xqXxNjxTRlh/PJkwxoXNA7VT2AUCAz+UXTSfeODuqrOtKK6oX/djKweicbTEqGqheoSDObfpFiXn5hvpysCocBsmv+fi9EdVNexfBA0lnYnI2tjNOgq3jPTtl6hlq3zukrfTF5iOh2OQqee+076KkSyQwwmxxcmuPiNW8ckavb5/FUh1Y29paR1BiHJYYw2rLXZ88SwKpv+gJJ6TxcsDtwdIiUTYiEL4BOE9mXFucxLoz7doaA==";
      
      private var _channel4:String = "kHQGphrjxh+lA3/evkf1+hSLp+YGbvDdu2OjdYGvYbK8R7WpLXetDGOfn56ZB3Xs3h1vQmYx7lmtYJnMSiYprL239VIheXGZm9X/xqXxNjxTRlh/PJkwxoXNA7VT2AUCAz+UXTSfeODuqrOtKK6oX/djKweicbTEqGqheoSDObfpFiXn5hvpysCocBsmv+fi9EdVNexfBA0lnYnI2tjNOgq3jPTtl6hlq3zukrfTF5iOh2OQqee+076KkSyQwwmxxkdbAdHUjFuVyofv6hXPw9eeH58YsArgNTx7mTHinv0x8PtwfIWl66rd3fcTGYjequk50wnQXT6ABQQY9bfJnw==";
      
      private var _channel5:String = "kHQGphrjxh+lA3/evkf1+hSLp+YGbvDdu2OjdYGvYbK8R7WpLXetDGOfn56ZB3Xs3h1vQmYx7lmtYJnMSiYprL239VIheXGZm9X/xqXxNjxTRlh/PJkwxoXNA7VT2AUCAz+UXTSfeODuqrOtKK6oX/djKweicbTEqGqheoSDObfpFiXn5hvpysCocBsmv+fi9EdVNexfBA0lnYnI2tjNOgq3jPTtl6hlq3zukrfTF5iOh2OQqee+076KkSyQwwmxBVKPw9mCruI7fX0QDjGR22q6CPxpV609U4PQ07KylL9Npf+lWxQgzqJYYpmpHVP/aOjNUZ6d4gsGu2y8xDS+rg==";
      
      private var _channel6:String = "kHQGphrjxh+lA3/evkf1+hSLp+YGbvDdu2OjdYGvYbK8R7WpLXetDGOfn56ZB3Xs3h1vQmYx7lmtYJnMSiYprL239VIheXGZm9X/xqXxNjxTRlh/PJkwxoXNA7VT2AUCAz+UXTSfeODuqrOtKK6oX/djKweicbTEqGqheoSDObfpFiXn5hvpysCocBsmv+fi9EdVNexfBA0lnYnI2tjNOgq3jPTtl6hlq3zukrfTF5iOh2OQqee+076KkSyQwwmxlb11BrEuhyV3IVnDkVcGr1WNknbc/aAeIuTPN+a9M/74ntpq3ePsZpvkRzm7FqIA4tqGw+eujYmFemT16zjXOQ==";
      
      private var _channel7:String = "kHQGphrjxh+lA3/evkf1+hSLp+YGbvDdu2OjdYGvYbK8R7WpLXetDGOfn56ZB3Xs3h1vQmYx7lmtYJnMSiYprL239VIheXGZm9X/xqXxNjxTRlh/PJkwxoXNA7VT2AUCAz+UXTSfeODuqrOtKK6oX/djKweicbTEqGqheoSDObfpFiXn5hvpysCocBsmv+fi9EdVNexfBA0lnYnI2tjNOgq3jPTtl6hlq3zukrfTF5iOh2OQqee+076KkSyQwwmxlGisoTK/5EB6/scRp+d5RIK0FFlVvflUhR266/QkJVohqyQbzI68W2COynv4YoUBKdkKmvkeJA3DVbpggZlG6A==";
      
      private var _channel8:String = "kHQGphrjxh+lA3/evkf1+hSLp+YGbvDdu2OjdYGvYbK8R7WpLXetDGOfn56ZB3Xs3h1vQmYx7lmtYJnMSiYprL239VIheXGZm9X/xqXxNjxTRlh/PJkwxoXNA7VT2AUCAz+UXTSfeODuqrOtKK6oX/djKweicbTEqGqheoSDObfpFiXn5hvpysCocBsmv+fizGE6w6/TbhIhfFX+yNkANKXSaWfba3fkKgggZb/EI/RDid8B1P9yTMRB1Id44yoWLDyTS9nOvCbecOoAgd3q5PVgoXtFGEc25ez+eRow0SfGF8gWP9jn2iuiOxj5jc7JffpvuBqcrMgw+YLfwJ/TQA==";
      
      private var _str1:String = "puz7wy0ozSYTsrt6g/JSZOpJXZaFG/yWquacXv4kxUURaN0L2W+YWUI4jdez4lla";
      
      private var _str2:String = "ynQe53Gf6snQ8MvlHTcQNatdP0V615u0vNey14GjrmU=";
      
      public function UI()
      {
         super();
         this.initEvent();
      }
      
      private function initEvent() : *
      {
         addEventListener(UIEvent.CLOSE,this.onUICloseHandler);
         addEventListener(UIEvent.MESSAGE,this.onMessageHandler);
         addEventListener(UIEvent.GAMEINFO,this.onGameInfoBtnClickHandler);
         addEventListener(UIEvent.ENTER_GAMECENTER,this.enterGameCenterHandler);
         addEventListener(UIEvent.EXIT_GAMECENTER,this.exitGameCenterHandler);
         addEventListener(UIEvent.CLOSE_NETSTATUS_PANEL,this.netStatusPanelCloseHandler);
         addEventListener(UIEvent.CANCEL_FIGHTWAIT,this.cancelFightWaitHandler);
         addEventListener(UIEvent.OPEN_WUJIANG,this.openWujiangHandler);
         addEventListener(UIEvent.SHOW_GENERAL_INFO,this.showGeneralInfoHandler);
         addEventListener(UIEvent.OPEN_BUDUI,this.openBuduiHandler);
         addEventListener(UIEvent.OPEN_STAGE,this.openStageHandler);
         addEventListener(UIEvent.OPEN_ZHAOMU,this.openZhaomuHandler);
         addEventListener(UIEvent.OPEN_BEIBAO,this.openBeibaoHandler);
         addEventListener(UIEvent.OPEN_SHOP,this.openShopHandler);
         addEventListener(UIEvent.OPEN_BUCHANG,this.openBuchangHandler);
         addEventListener(UIEvent.LING_DIANKA,this.lingDiankaHandler);
         addEventListener(UIEvent.SERVER_SELECTED,this.serverSelectedHandler);
         addEventListener(UIEvent.OPEN_DUIZHAN,this.onConnectServerBtnClickHandler);
         addEventListener(UIEvent.JINHUA_CLICK,this.jinhuaClickHandler);
         addEventListener(UIEvent.JINHUA,this.jinhuaHandler);
         addEventListener(UIEvent.CHONGZHI_CLICK,this.onChongzhiClickHandler);
         addEventListener(TalkEvent.NET_INFO,this.onTalkEventHandler);
         ChatManager.getInstance().addEventListener(TalkEvent.CHAT_PLAIN,this.onChatPlainHandler);
         addEventListener(UIEvent.FIGHT_REQUEST,this.onFightRequestClickHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.WORLD_POST_NOTIFY,this.onWorldPostNotifyHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.AREA_POST_NOTIFY,this.onAreaPostNotifyHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.ADD_NEIGHBOR,this.addNeighBorHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.REMOVE_NEIGHBOR,this.removeNeighBorHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.CHANGE_STATUS,this.onStatusChangeHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.P2P_DATA,this.onP2PDataHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.P2P_CONNECT_FAIL,this.onP2PConnectFailHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.P2P_CONNECT_WAIT,this.onP2PWaitHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.P2P_CONNECT_SUCCESS,this.onP2PConnectSuccessHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.P2P_ABEND_CLOSE,this.onP2PAbendCloseHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.P2P_CLOSE,this.onP2PCloseHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.LEITAI_CONNECT_WAIT,this.onP2PWaitHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.LEITAI_CONNECT_SUCCESS,this.onLeitaiConnectSuccessHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.LEITAI_CONNECT_FAIL,this.onLeitaiConnectFailHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.LEITAI_ABEND_CLOSE,this.onLeitaiCloseHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.LEITAI_CLOSE,this.onLeitaiCloseHandler);
         addEventListener(UIEvent.CONTINUE_LEIZHU,this.continueLeizhuHandler);
         addEventListener(UIEvent.EXIT_LEIZHU,this.exitLeizhuHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.NET_DISCONNECTION,this.onNetDisconnectionHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.SERVER_DOWN,this.onServerDownHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.P2P_MESSAGE,this.onP2PMessageHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.P2P_MODIFY,this.onP2PModifyHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.P2P_KICK,this.onP2PKickHandler);
         addEventListener(UIEvent.XIONGNU_CLICK,this.xiongnuClickHandler);
         addEventListener(UIEvent.INJOY_FUBEN,this.injoyFubenHandler);
         addEventListener(FightEvent.XIONGNU_FIGHT_COMPLETE,this.onXiongnuCompleteHandler);
         addEventListener(UIEvent.START_FUBEN,this.startFubenHandler);
         addEventListener(UIEvent.CLOSE_FUBEN,this.closeFubenHandler);
         addEventListener(UIEvent.OPEN_FANPAI,this.openFanpaiHandler);
         addEventListener(UIEvent.SEND_PAIMIAN,this.sendPaimianHandler);
         addEventListener(UIEvent.FUBEN_SPEED_CHECKOUT,this.fubenSpeedCheckOutHandler);
         addEventListener(UIEvent.OPEN_LEITAI,this.leitaiListRequest);
         addEventListener(UIEvent.OPEN_LEITAI_GUIZE,this.openLeitaiGuize);
         addEventListener(UIEvent.BECOME_LEIZHU,this.becomeLeizhu);
         addEventListener(UIEvent.SPEED_CHECKOUT,this.speedCheckOutHandler);
         addEventListener(UIEvent.LING_GUOQING,this.lingGuoqingHandler);
      }
      
      public function addCover() : *
      {
         if(this._cover == null)
         {
            this._cover = new Cover(SkinCode.COVER);
            this._cover.x = stage.stageWidth / 2;
            this._cover.y = stage.stageHeight / 2;
            addChild(this._cover);
            this._cover.tabChildren = false;
            this._cover.tabEnabled = false;
         }
      }
      
      public function removeCover() : *
      {
         if(this._cover != null)
         {
            removeChild(this._cover);
            this._cover = null;
         }
      }
      
      public function addMap() : *
      {
         var _loc1_:Object = null;
         if(this._map == null)
         {
            this._map = new Map(SkinCode.MAP);
            this._map.x = stage.stageWidth / 2;
            this._map.y = stage.stageHeight / 2;
            _loc1_ = {};
            _loc1_.name = RoleModel.getInstance().roleName;
            _loc1_.level = RoleModel.getInstance().level;
            _loc1_.reverence = RoleModel.getInstance().reverence;
            _loc1_.money = RoleModel.getInstance().money;
            _loc1_.exploit = RoleModel.getInstance().exploit;
            _loc1_.image = RoleModel.getInstance().imageID;
            _loc1_.history = RoleModel.getInstance().getHistory();
            _loc1_.dianka = RoleModel.getInstance().dianka;
            this._map.initData(_loc1_);
            RoleModel.getInstance().addEventListener(Event.CHANGE,this.roleModelChangeHandler);
            addChild(this._map);
         }
      }
      
      public function removeMap() : *
      {
         if(this._map != null)
         {
            RoleModel.getInstance().removeEventListener(Event.CHANGE,this.roleModelChangeHandler);
            removeChild(this._map);
            this._map = null;
         }
      }
      
      private function roleModelChangeHandler(param1:Event) : *
      {
         var _loc2_:Object = null;
         if(this._map != null)
         {
            _loc2_ = {};
            _loc2_.name = RoleModel.getInstance().roleName;
            _loc2_.level = RoleModel.getInstance().level;
            _loc2_.reverence = RoleModel.getInstance().reverence;
            _loc2_.money = RoleModel.getInstance().money;
            _loc2_.exploit = RoleModel.getInstance().exploit;
            _loc2_.image = RoleModel.getInstance().imageID;
            _loc2_.history = RoleModel.getInstance().getHistory();
            _loc2_.dianka = RoleModel.getInstance().dianka;
            this._map.setInfo(_loc2_);
         }
         if(this._gameCenter != null)
         {
            this._gameCenter.setRole(RoleModel.getInstance());
         }
         if(this._shopPanel != null)
         {
            this._shopPanel.flush();
         }
         if(this._generalListPanel != null)
         {
            this._generalListPanel.flush();
         }
      }
      
      public function openNetStatusPanel(param1:Boolean = false) : *
      {
         // 网页版：创建面板但不可见，走完整连接流程
         if(Config.IS_WEB)
         {
            // 网页版直接用服务器地址作为房间标识
            Config.server1 = Config.SERVER_HOST;
            Config.server2 = Config.SERVER_HOST;
            Config.server3 = Config.SERVER_HOST;
            this._netStatusPanel = new NetStatusUI(SkinCode.CONNECT_STATUS);
            this._netStatusPanel.x = -1000;
            this._netStatusPanel.y = -1000;
            this._netStatusPanel.visible = false;
            addChild(this._netStatusPanel);
            this.connectGoogle();
            return;
         }
         if(this._netStatusPanel == null)
         {
            this._netStatusPanel = new NetStatusUI(SkinCode.CONNECT_STATUS);
            this._netStatusPanel.x = stage.stageWidth / 2;
            this._netStatusPanel.y = stage.stageHeight / 2;
            this._netStatusPanel.newPlayer = param1;
            this._netStatusPanel.setCancelBtnEnabled(false);
            this._netStatusPanel.setOkBtnEnabled(true);
            addChild(this._netStatusPanel);
            this._netStatusPanel.createMask(0,0.4);
            this._netStatusPanel.zoomFrom(1,1,0,1,this.connectGoogle);
            this._netStatusPanel.setStatus1("1.等待连接云端服务器.");
            this._netStatusPanel.setStatus2("2.等待连接登录服务器.");
            this._netStatusPanel.setStatus3("3.等待连接聊天服务器.");
            this._netStatusPanel.setStatus4("4.等待连接游戏服务器.");
         }
      }
      
      public function closeNetStatusPanel() : *
      {
         if(this._netStatusPanel != null)
         {
            removeChild(this._netStatusPanel);
            this._netStatusPanel = null;
         }
      }
      
      public function openCreateRolePanel(param1:Boolean = true) : *
      {
         if(this._createRolePanel == null)
         {
            this._createRolePanel = new CreateRolePanel(SkinCode.CREATE_ROLE);
            this._createRolePanel.x = stage.stageWidth / 2;
            this._createRolePanel.y = stage.stageHeight / 2;
            addChild(this._createRolePanel);
            this._createRolePanel.p2p = param1;
            this._createRolePanel.createMask(0,0.4);
            this._createRolePanel.zoomFrom(1,1,0,1);
         }
      }
      
      public function closeCreateRolePanel() : *
      {
         if(this._createRolePanel != null)
         {
            removeChild(this._createRolePanel);
            this._createRolePanel = null;
         }
      }
      
      public function openFightFromPanel() : *
      {
         if(this._fightFromPanel == null)
         {
            this._fightFromPanel = new FightFromPanel(SkinCode.FIGHT_POPUP);
            this._fightFromPanel.x = stage.stageWidth / 2;
            this._fightFromPanel.y = stage.stageHeight / 2;
            addChild(this._fightFromPanel);
            this._fightFromPanel.createMask(0,0.4);
            this._fightFromPanel.zoomFrom(1,1,0,1);
         }
      }
      
      public function closeFightFromPanel() : *
      {
         if(this._fightFromPanel != null)
         {
            removeChild(this._fightFromPanel);
            this._fightFromPanel = null;
         }
      }
      
      public function openGeneralListPanel() : *
      {
         if(this._generalListPanel == null)
         {
            this._generalListPanel = new GeneralListPanel(SkinCode.GENERAL_LIST_PANEL);
            this._generalListPanel.x = stage.stageWidth / 2;
            this._generalListPanel.y = stage.stageHeight / 2;
            addChild(this._generalListPanel);
         }
      }
      
      public function closeGeneralListPanel() : *
      {
         if(this._generalListPanel != null)
         {
            removeChild(this._generalListPanel);
            this._generalListPanel = null;
         }
      }
      
      public function openGeneralInfoPanel() : *
      {
         if(this._generalInfoPanel == null)
         {
            this._generalInfoPanel = new GeneralInfoPanel(SkinCode.GENERAL_INFO_PANEL);
            this._generalInfoPanel.x = stage.stageWidth / 2;
            this._generalInfoPanel.y = stage.stageHeight / 2;
            addChild(this._generalInfoPanel);
         }
      }
      
      public function closeGeneralInfoPanel() : *
      {
         if(this._generalInfoPanel != null)
         {
            removeChild(this._generalInfoPanel);
            this._generalInfoPanel = null;
         }
      }
      
      public function openGeneralJinhuaPanel() : *
      {
         if(this._generalJinhuaPanel == null)
         {
            this._generalJinhuaPanel = new GeneralJinhuaPanel(SkinCode.GENERAL_JINHUA_PANEL);
            this._generalJinhuaPanel.x = stage.stageWidth / 2;
            this._generalJinhuaPanel.y = stage.stageHeight / 2;
            addChild(this._generalJinhuaPanel);
            this._generalJinhuaPanel.createMask(0,0.4);
         }
      }
      
      public function closeGeneralJinhuaPanel() : *
      {
         if(this._generalJinhuaPanel != null)
         {
            removeChild(this._generalJinhuaPanel);
            this._generalJinhuaPanel = null;
         }
      }
      
      public function openShangzhenPanel() : *
      {
         if(this._shangzhenPanel == null)
         {
            this._shangzhenPanel = new ShangzhenPanel(SkinCode.SHANGZHEN_PANEL);
            this._shangzhenPanel.x = stage.stageWidth / 2;
            this._shangzhenPanel.y = stage.stageHeight / 2;
            addChild(this._shangzhenPanel);
         }
         else
         {
            addChild(this._shangzhenPanel);
         }
      }
      
      public function closeShangzhenPanel() : *
      {
         if(this._shangzhenPanel != null)
         {
            removeChild(this._shangzhenPanel);
            this._shangzhenPanel = null;
         }
      }
      
      public function openZhaomuPanel() : *
      {
         if(this._zhaomuPanel == null)
         {
            this._zhaomuPanel = new GeneralZhaomuPanel(SkinCode.ZHAOMU_PANEL);
            this._zhaomuPanel.x = stage.stageWidth / 2;
            this._zhaomuPanel.y = stage.stageHeight / 2;
            addChild(this._zhaomuPanel);
            this._zhaomuPanel.createMask(0,0.4);
         }
      }
      
      public function closeZhaomuPanel() : *
      {
         if(this._zhaomuPanel != null)
         {
            removeChild(this._zhaomuPanel);
            this._zhaomuPanel = null;
         }
      }
      
      public function openBagPanel() : *
      {
         if(this._bagPanel == null)
         {
            this._bagPanel = new BagPanel(SkinCode.BAG_PANEL);
            this._bagPanel.x = stage.stageWidth / 2;
            this._bagPanel.y = stage.stageHeight / 2;
            addChild(this._bagPanel);
            this._bagPanel.createMask(0,0.4);
         }
      }
      
      public function closeBagPanel() : *
      {
         if(this._bagPanel != null)
         {
            removeChild(this._bagPanel);
            this._bagPanel = null;
         }
      }
      
      public function openShopPanel() : *
      {
         if(this._shopPanel == null)
         {
            this._shopPanel = new ShopPanel(SkinCode.SHOP_PANEL);
            this._shopPanel.x = stage.stageWidth / 2;
            this._shopPanel.y = stage.stageHeight / 2;
            addChild(this._shopPanel);
            this._shopPanel.createMask(0,0.4);
         }
      }
      
      public function closeShopPanel() : *
      {
         if(this._shopPanel != null)
         {
            removeChild(this._shopPanel);
            this._shopPanel = null;
         }
      }
      
      public function openStageListPanel() : *
      {
         if(this._stageListPanel == null)
         {
            this._stageListPanel = new StageListPanel(SkinCode.STAGE_LIST_PANEL);
            this._stageListPanel.x = stage.stageWidth / 2;
            this._stageListPanel.y = stage.stageHeight / 2;
            addChild(this._stageListPanel);
            this._stageListPanel.createMask(0,0.4);
         }
      }
      
      public function closeStageListPanel() : *
      {
         if(this._stageListPanel != null)
         {
            removeChild(this._stageListPanel);
            this._stageListPanel = null;
         }
      }
      
      public function openFightResultPanel() : *
      {
         if(this._fightResultPanel == null)
         {
            this._fightResultPanel = new FightResultPanel(SkinCode.FIGHT_RESULT_PANEL);
            this._fightResultPanel.x = stage.stageWidth / 2;
            this._fightResultPanel.y = stage.stageHeight / 2;
            addChild(this._fightResultPanel);
            this._fightResultPanel.createMask(0,0.4);
         }
      }
      
      public function closeFightResultPanel() : *
      {
         if(this._fightResultPanel != null)
         {
            removeChild(this._fightResultPanel);
            this._fightResultPanel = null;
         }
      }
      
      public function openYanzhengmaPanel() : *
      {
         if(this._yanzhengmaPanel == null)
         {
            this._yanzhengmaPanel = new YanzhengPanel(SkinCode.YANZHENGMA_PANEL);
            this._yanzhengmaPanel.x = stage.stageWidth / 2;
            this._yanzhengmaPanel.y = stage.stageHeight / 2;
            addChild(this._yanzhengmaPanel);
            this._yanzhengmaPanel.createMask(0,0.5);
            this._yanzhengmaPanel.initData(null);
         }
      }
      
      public function closeYanzhengmaPanel() : *
      {
         if(this._yanzhengmaPanel != null)
         {
            removeChild(this._yanzhengmaPanel);
            this._yanzhengmaPanel = null;
         }
      }
      
      public function openFubenCheckPanel() : *
      {
         if(this._fubenCheckPanel == null)
         {
            this._fubenCheckPanel = new FubenCheckPanel(SkinCode.FUBEN_CHECK_PANEL);
            this._fubenCheckPanel.x = stage.stageWidth / 2;
            this._fubenCheckPanel.y = stage.stageHeight / 2;
            addChild(this._fubenCheckPanel);
            this._fubenCheckPanel.createMask(0,0.5);
         }
      }
      
      public function closeFubenCheckPanel() : *
      {
         if(this._fubenCheckPanel != null)
         {
            removeChild(this._fubenCheckPanel);
            this._fubenCheckPanel = null;
         }
      }
      
      public function openFubenResultPanel() : *
      {
         if(this._fubenResultPanel == null)
         {
            this._fubenResultPanel = new FubenResultPanel(SkinCode.FUBEN_RESULT_PANEL);
            this._fubenResultPanel.x = stage.stageWidth / 2;
            this._fubenResultPanel.y = stage.stageHeight / 2;
            addChild(this._fubenResultPanel);
            this._fubenResultPanel.createMask(0,0.5);
         }
      }
      
      public function closeFubenResultPanel() : *
      {
         if(this._fubenResultPanel != null)
         {
            removeChild(this._fubenResultPanel);
            this._fubenResultPanel = null;
         }
      }
      
      public function openFanpaiPanel() : *
      {
         if(this._fanpaiPanel == null)
         {
            this._fanpaiPanel = new FanpaiPanel(SkinCode.FUBEN_FANPAI_PANEL);
            this._fanpaiPanel.x = stage.stageWidth / 2;
            this._fanpaiPanel.y = stage.stageHeight / 2;
            addChild(this._fanpaiPanel);
            this._fanpaiPanel.createMask(0,0.5);
         }
      }
      
      public function closeFanpaiPanel() : *
      {
         if(this._fanpaiPanel != null)
         {
            removeChild(this._fanpaiPanel);
            this._fanpaiPanel = null;
         }
      }
      
      public function openConnectWait() : *
      {
         if(this._connectWait == null)
         {
            this._connectWait = new ConnectWait(SkinCode.CONNECT_WAIT);
            this._connectWait.x = stage.stageWidth / 2;
            this._connectWait.y = stage.stageHeight / 2;
            addChild(this._connectWait);
            this._connectWait.createMask(0,0.4);
         }
         else
         {
            addChild(this._connectWait);
         }
      }
      
      public function closeConnectWait() : *
      {
         if(this._connectWait != null)
         {
            removeChild(this._connectWait);
            this._connectWait = null;
         }
      }
      
      public function openGameInfo() : *
      {
         if(this._gameInfo == null)
         {
            this._gameInfo = new GameInfo(SkinCode.GAMEINFO);
            this._gameInfo.x = stage.stageWidth / 2;
            this._gameInfo.y = stage.stageHeight / 2;
            addChild(this._gameInfo);
            this._gameInfo.zoomFrom(1,1,0,1);
         }
      }
      
      public function closeGameInfo() : *
      {
         if(this._gameInfo != null)
         {
            removeChild(this._gameInfo);
            this._gameInfo = null;
         }
      }
      
      public function openLeitai(param1:Object) : *
      {
         if(this._leitaiPanel == null)
         {
            this._leitaiPanel = new LeitaiPanel(SkinCode.LEITAI_PANEL);
            this._leitaiPanel.x = stage.stageWidth / 2;
            this._leitaiPanel.y = stage.stageHeight / 2;
            addChild(this._leitaiPanel);
         }
         this._leitaiPanel.initData(param1);
      }
      
      public function closeLeitai() : *
      {
         if(this._leitaiPanel != null)
         {
            removeChild(this._leitaiPanel);
            this._leitaiPanel = null;
         }
      }
      
      public function openLeitaiResult(param1:Object) : *
      {
         if(this._leitaiResultPanel == null)
         {
            this._leitaiResultPanel = new LeitaiResultPanel(SkinCode.LEITAI_RESULT_PANEL);
            this._leitaiResultPanel.x = stage.stageWidth / 2;
            this._leitaiResultPanel.y = stage.stageHeight / 2;
            addChild(this._leitaiResultPanel);
            this._leitaiResultPanel.createMask(0,0.4);
         }
         this._leitaiResultPanel.initData(param1);
      }
      
      public function closeLeitaiResult() : *
      {
         if(this._leitaiResultPanel != null)
         {
            removeChild(this._leitaiResultPanel);
            this._leitaiResultPanel = null;
         }
         GlobalTimer.getInstance().playListener(TimerStr.LEITAI_FLUSH);
         GlobalTimer.getInstance().playListener(TimerStr.PAIHANG_FLUSH);
      }
      
      public function openLeitaiGuize(param1:UIEvent = null) : *
      {
         var _loc2_:LeitaiGuizePanel = new LeitaiGuizePanel(SkinCode.LEITAI_GUIZE_PANEL);
         _loc2_.x = stage.stageWidth / 2;
         _loc2_.y = stage.stageHeight / 2;
         addChild(_loc2_);
         _loc2_.createMask(0,0.4);
      }
      
      public function openSelectServerPanel(param1:Boolean = false) : *
      {
         // 网页版：单服务器，跳过选择面板直接连接
         if(Config.IS_WEB)
         {
            this.openNetStatusPanel(param1);
            return;
         }
         if(this._selectServerPanel == null)
         {
            this._selectServerPanel = new SelectServerPanel(SkinCode.SELECT_SERVER);
            this._selectServerPanel.x = stage.stageWidth / 2;
            this._selectServerPanel.y = stage.stageHeight / 2;
            addChild(this._selectServerPanel);
            this._selectServerPanel.newPlayer = param1;
            this._selectServerPanel.createMask(0,0.4);
         }
      }
      
      public function closeSelectServerPanel() : *
      {
         if(this._selectServerPanel != null)
         {
            removeChild(this._selectServerPanel);
            this._selectServerPanel = null;
         }
      }
      
      public function openGuoqing1(param1:int, param2:Object) : *
      {
         if(this._guoqing1 == null)
         {
            if(param1 == 1)
            {
               this._guoqing1 = new Guoqing1(SkinCode.GUOQING1);
               this._guoqing1.x = stage.stageWidth / 2;
               this._guoqing1.y = stage.stageHeight / 2;
               addChild(this._guoqing1);
               this._guoqing1.createMask(0,0.4);
            }
            else
            {
               this._guoqing1 = new Guoqing1(SkinCode.GUOQING2);
               this._guoqing1.x = stage.stageWidth / 2;
               this._guoqing1.y = stage.stageHeight / 2;
               addChild(this._guoqing1);
               this._guoqing1.createMask(0,0.4);
            }
            this._guoqing1.initData(param2);
         }
      }
      
      public function closeGuoqing1() : *
      {
         if(this._guoqing1 != null)
         {
            removeChild(this._guoqing1);
            this._guoqing1 = null;
         }
      }
      
      public function openGuoqing2(param1:Object) : *
      {
         if(this._guoqing2 == null)
         {
            this._guoqing2 = new Guoqing2(SkinCode.GUOQING3);
            this._guoqing2.x = stage.stageWidth / 2;
            this._guoqing2.y = stage.stageHeight / 2;
            addChild(this._guoqing2);
            this._guoqing2.createMask(0,0.4);
            this._guoqing2.initData(param1);
         }
      }
      
      public function closeGuoqing2() : *
      {
         if(this._guoqing2 != null)
         {
            removeChild(this._guoqing2);
            this._guoqing2 = null;
         }
      }
      
      public function addGameCenter() : *
      {
         if(this._gameCenter == null)
         {
            this._gameCenter = new GameCenterUI(SkinCode.GAME_CENTER);
            this._gameCenter.x = stage.stageWidth / 2;
            this._gameCenter.y = stage.stageHeight / 2;
            addChild(this._gameCenter);
            this._gameCenter.addEventListener(UIEvent.CHANGE_STATUS,this.onDefusCheckBoxClickHandler);
         }
      }
      
      public function removeGameCenter() : *
      {
         if(this._gameCenter != null)
         {
            this._gameCenter.removeEventListener(UIEvent.CHANGE_STATUS,this.onDefusCheckBoxClickHandler);
            removeChild(this._gameCenter);
            this._gameCenter = null;
         }
      }
      
      public function addP2PFight(param1:Vector.<ArmyInfo>, param2:Vector.<ArmyInfo>, param3:Object, param4:Object, param5:int = 1) : *
      {
         if(this._p2pFight == null)
         {
            this._p2pFight = new P2PFight(param1,param2,param3,param4,param5);
            addChild(this._p2pFight);
         }
      }
      
      public function removeP2PFight() : *
      {
         if(this._p2pFight != null)
         {
            this._p2pFight.clear();
            removeChild(this._p2pFight);
            this._p2pFight = null;
         }
      }
      
      public function addFightWait(param1:Vector.<ArmyInfo>, param2:Vector.<ArmyInfo>, param3:Object, param4:Object, param5:int) : *
      {
         var _loc6_:Object = null;
         if(this._fightWait == null)
         {
            this._fightWait = new FightWait(SkinCode.FIGHT_WAIT);
            this._fightWait.x = stage.stageWidth / 2;
            this._fightWait.y = stage.stageHeight / 2;
            addChild(this._fightWait);
            (_loc6_ = {}).leftInfo = param3;
            _loc6_.rightInfo = param4;
            _loc6_.leftArmy = param1;
            _loc6_.rightArmy = param2;
            _loc6_.direct = param5;
            this._fightWait.initData(_loc6_);
         }
      }
      
      public function removeFightWait() : *
      {
         if(this._fightWait != null)
         {
            removeChild(this._fightWait);
            this._fightWait = null;
         }
      }
      
      public function addGuide(param1:int = 2, param2:Boolean = false) : *
      {
         if(this._guide == null)
         {
            this._guide = new Guide(SkinCode.GUIDE);
            addChild(this._guide);
            this._guide.zoomFrom(1,1,0,1);
            this._guide.initData(param1);
            this._guide.flag = param2;
         }
      }
      
      public function removeGuide() : *
      {
         if(this._guide != null)
         {
            removeChild(this._guide);
            this._guide = null;
         }
      }
      
      public function addGameStory(param1:int = 1) : *
      {
         if(this._gameStory == null)
         {
            this._gameStory = new GameStory(SkinCode.GAMESTORY);
            addChild(this._gameStory);
            this._gameStory.initData(param1);
            this._gameStory.x = stage.stageWidth / 2;
            this._gameStory.y = stage.stageHeight / 2;
            this._gameStory.zoomFrom(1,1,0,1.5);
         }
      }
      
      public function removeGameStory() : *
      {
         if(this._gameStory != null)
         {
            removeChild(this._gameStory);
            this._gameStory = null;
         }
      }
      
      public function showMsg(param1:Object = null, param2:Function = null) : *
      {
         var _loc3_:Alert = null;
         if(param1.skin != null)
         {
            _loc3_ = new Alert(param1.skin);
         }
         else
         {
            _loc3_ = new Alert(SkinCode.ALERT);
         }
         _loc3_.x = stage.stageWidth / 2;
         _loc3_.y = stage.stageHeight / 2;
         _loc3_.initData(param1);
         addChild(_loc3_);
         _loc3_.createMask(0,0.4);
         _loc3_.zoomFrom(1,1,0,1,param2);
      }
      
      public function showFightResult(param1:Object) : *
      {
         this.openFightResultPanel();
         this._fightResultPanel.initData(param1);
      }
      
      private function connectGoogle() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = 1;
         _loc1_.game = Config.GAME;
         _loc1_.area = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.uID = RoleModel.getInstance().userID;
         _loc1_.uName = RoleModel.getInstance().userName;
         _loc1_.nick = RoleModel.getInstance().roleName;
         _loc1_.image = RoleModel.getInstance().imageID;
         if(Config.USE_NEW_NETWORK == true)
         {
            this.connectCirrus();
         }
         else
         {
            // 旧版：解密内置配置
            this.connectGoogleResponse(_loc1_);
         }
      }

      private function connectGoogleErrorHandler(param1:ControllerEvent) : *
      {
         this._netStatusPanel.setStatus1("1.云端服务器连接失败");
         this._netStatusPanel.setIcon1(true,3);
         this._netStatusPanel.setCancelBtnEnabled(true);
      }

      private function connectGoogleResponse(param1:Object) : *
      {
         var _loc2_:String = AESTools.decrypt(this._str,RoleModel.getInstance().openStr(Config.ARR1),RoleModel.getInstance().openStr(Config.ARR2));
         Config.server1 = _loc2_.split("|")[0];
         Config.server2 = _loc2_.split("|")[1];
         this.connectCirrus();
      }

      private function connectCirrus() : *
      {
         this._netStatusPanel.setStatus1("1.正在连接云端服务器......   连接中");
         this._netStatusPanel.setIcon1(true,1);
         ChatManager.getInstance().addEventListener(P2PEvent.CIRRUS_CONNECT_SUCCESS,this.connectCirrusHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.CIRRUS_CONNECT_FAIL,this.connectCirrusHandler);
         if(Config.USE_NEW_NETWORK == true)
         {
            // 新版：使用 Socket 连接
            trace("使用新版网络连接到:", Config.SERVER_HOST, Config.SERVER_PORT);
            ChatManager.getInstance().connectToServer(Config.SERVER_HOST, Config.SERVER_PORT, {});
         }
         else
         {
            // 旧版：使用 Adobe Cirrus
            ChatManager.getInstance().cirrusConnect(AESTools.decrypt(this._str2,RoleModel.getInstance().openStr(Config.ARR1),RoleModel.getInstance().openStr(Config.ARR2)),AESTools.decrypt(this._str1,RoleModel.getInstance().openStr(Config.ARR1),RoleModel.getInstance().openStr(Config.ARR2)));
         }
      }
      
      private function connectCirrusHandler(param1:P2PEvent) : *
      {
         ChatManager.getInstance().removeEventListener(P2PEvent.CIRRUS_CONNECT_SUCCESS,this.connectCirrusHandler);
         ChatManager.getInstance().removeEventListener(P2PEvent.CIRRUS_CONNECT_FAIL,this.connectCirrusHandler);
         if(param1.type == P2PEvent.CIRRUS_CONNECT_FAIL)
         {
            this._netStatusPanel.setStatus1("1.云端服务器连接失败");
            this._netStatusPanel.setIcon1(true,3);
            this._netStatusPanel.setCancelBtnEnabled(true);
            ChatManager.getInstance().close();
         }
         else if(param1.type == P2PEvent.CIRRUS_CONNECT_SUCCESS)
         {
            if(this._netStatusPanel) { this._netStatusPanel.setStatus1("1.连接云端服务器成功!"); this._netStatusPanel.setIcon1(true,2); }
            this.connectManageGroup();
         }
      }
      
      private function connectManageGroup() : *
      {
         this._netStatusPanel.setStatus2("2.正在连接登录服务器......   连接中");
         this._netStatusPanel.setIcon2(true,1);
         ChatManager.getInstance().addEventListener(P2PEvent.COM1_CONNECT_SUCCESS,this.connectManageGroupHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.COM1_CONNECT_FAIL,this.connectManageGroupHandler);
         ChatManager.getInstance().com1Connect(Config.server1);
      }
      
      private function connectManageGroupHandler(param1:P2PEvent) : *
      {
         ChatManager.getInstance().removeEventListener(P2PEvent.COM1_CONNECT_SUCCESS,this.connectManageGroupHandler);
         ChatManager.getInstance().removeEventListener(P2PEvent.COM1_CONNECT_FAIL,this.connectManageGroupHandler);
         if(param1.type == P2PEvent.COM1_CONNECT_FAIL)
         {
            this._netStatusPanel.setStatus2("2.登录服务器连接失败");
            this._netStatusPanel.setIcon2(true,3);
            this._netStatusPanel.setCancelBtnEnabled(true);
            ChatManager.getInstance().close();
         }
         else if(param1.type == P2PEvent.COM1_CONNECT_SUCCESS)
         {
            this._netStatusPanel.setStatus2("2.连接登录服务器成功!");
            this._netStatusPanel.setIcon2(true,2);
            this.connectTalkGroup();
         }
      }
      
      private function connectTalkGroup() : *
      {
         ChatManager.getInstance().addEventListener(P2PEvent.COM2_CONNECT_SUCCESS,this.connectTalkGroupHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.COM2_CONNECT_FAIL,this.connectTalkGroupHandler);
         this._netStatusPanel.setStatus3("3.正在连接聊天服务器......   连接中");
         this._netStatusPanel.setIcon3(true,1);
         ChatManager.getInstance().com2Connect(Config.server2);
      }
      
      private function connectTalkGroupHandler(param1:P2PEvent) : *
      {
         ChatManager.getInstance().removeEventListener(P2PEvent.COM2_CONNECT_SUCCESS,this.connectTalkGroupHandler);
         ChatManager.getInstance().removeEventListener(P2PEvent.COM2_CONNECT_FAIL,this.connectTalkGroupHandler);
         if(param1.type == P2PEvent.COM2_CONNECT_FAIL)
         {
            this._netStatusPanel.setStatus3("3.聊天服务器连接失败");
            this._netStatusPanel.setIcon3(true,3);
            this._netStatusPanel.setCancelBtnEnabled(true);
            ChatManager.getInstance().close();
         }
         else
         {
            this._netStatusPanel.setStatus3("3.连接聊天服务器成功!");
            this._netStatusPanel.setIcon3(true,2);
            this.connectAreaGroup();
         }
      }
      
      private function connectAreaGroup() : *
      {
         ChatManager.getInstance().addEventListener(P2PEvent.COM3_CONNECT_SUCCESS,this.connectAreaGroupHandler);
         ChatManager.getInstance().addEventListener(P2PEvent.COM3_CONNECT_FAIL,this.connectAreaGroupHandler);
         this._netStatusPanel.setStatus4("4.正在连接游戏服务器......   连接中");
         this._netStatusPanel.setIcon4(true,1);
         ChatManager.getInstance().com3Connect(Config.server3);
      }
      
      private function connectAreaGroupHandler(param1:P2PEvent) : *
      {
         ChatManager.getInstance().removeEventListener(P2PEvent.COM3_CONNECT_SUCCESS,this.connectAreaGroupHandler);
         ChatManager.getInstance().removeEventListener(P2PEvent.COM3_CONNECT_FAIL,this.connectAreaGroupHandler);
         if(param1.type == P2PEvent.COM3_CONNECT_FAIL)
         {
            this._netStatusPanel.setStatus4("4.游戏服务器连接失败");
            this._netStatusPanel.setIcon4(true,3);
            this._netStatusPanel.setCancelBtnEnabled(true);
            ChatManager.getInstance().close();
         }
         else
         {
            this._netStatusPanel.setStatus4("4.连接游戏服务器成功!");
            this._netStatusPanel.setIcon4(true,2);
            // 网页版：连接完成关闭面板，添加地图进入游戏
            if(Config.IS_WEB)
            {
               var _self:UI = this;
               var _closeTimer:flash.utils.Timer = new flash.utils.Timer(500, 1);
               _closeTimer.addEventListener(flash.events.TimerEvent.TIMER, function(e:*):void {
                  _self.closeNetStatusPanel();
                  _self.removeCover();
                  _self.addMap();
                  MySound.getInstance().startByName(SoundCode.MAP);
               });
               _closeTimer.start();
            }
            this._netStatusPanel.setCancelBtnEnabled(true);
            this._netStatusPanel.setOkBtnEnabled(true);
         }
      }
      
      public function sendHelloNeighbor() : *
      {
         trace("发送信息给邻居");
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeInt(Head.HELLO_NEIGHBOR);
         _loc1_.writeUTF(RoleModel.getInstance().roleID.toString());
         _loc1_.writeUTF(ChatManager.getInstance().peerID);
         _loc1_.writeUTF(Config.AGENT);
         _loc1_.writeUTF(RoleModel.getInstance().roleName);
         _loc1_.writeInt(RoleModel.getInstance().imageID);
         _loc1_.writeInt(RoleModel.getInstance().level);
         _loc1_.writeInt(RoleModel.getInstance().status);
         _loc1_.writeFloat(Math.random());
         ChatManager.getInstance().areaPost(_loc1_);
      }
      
      private function addNeighBorHandler(param1:P2PEvent) : *
      {
         if(this._gameCenter != null)
         {
            this._gameCenter.addListItem(param1.data);
         }
      }
      
      private function removeNeighBorHandler(param1:P2PEvent) : *
      {
         if(this._gameCenter != null)
         {
            this._gameCenter.removeListItem(param1.data.pID);
         }
      }
      
      private function onWorldPostNotifyHandler(param1:P2PEvent) : *
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:ByteArray = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:int = 0;
         var _loc15_:String = null;
         var _loc16_:ByteArray;
         var _loc17_:int = (_loc16_ = param1.data as ByteArray).readInt();
         var _loc18_:Object = {};
         if(_loc17_ == Head.REQUEST)
         {
            trace("有人发来对战请求");
            _loc2_ = _loc16_.readUTF();
            if(RoleModel.getInstance().status != RoleStatus.DANJI && RoleModel.getInstance().status != RoleStatus.NOMAL)
            {
               if(_loc2_ == ChatManager.getInstance().peerID)
               {
                  _loc16_.readUTF();
                  _loc3_ = _loc16_.readUTF();
                  (_loc4_ = new ByteArray()).writeInt(Head.RESPONSE);
                  _loc4_.writeUTF(_loc3_);
                  _loc4_.writeUTF(_loc2_);
                  _loc4_.writeBoolean(false);
                  _loc4_.writeFloat(Math.random());
                  ChatManager.getInstance().worldPost(_loc4_);
               }
            }
            else if(_loc2_ == ChatManager.getInstance().peerID)
            {
               _loc18_.roleID = _loc16_.readUTF();
               _loc18_.pID = _loc16_.readUTF();
               _loc18_.area = _loc16_.readUTF();
               _loc18_.name = _loc16_.readUTF();
               _loc18_.image = _loc16_.readInt();
               _loc18_.level = _loc16_.readInt();
               _loc18_.type = 2;
               _loc18_.channel = "world";
               trace("对方的信息:",_loc18_.roleID,_loc18_.pID,_loc18_.area,_loc18_.name,_loc18_.image,_loc18_.level);
               this.openFightFromPanel();
               this._fightFromPanel.initData(_loc18_);
               this._fightFromPanel.addEventListener(UIEvent.AGREE_FIGHT,this.onAgreeFightClickHandler);
               this._fightFromPanel.addEventListener(UIEvent.DEFUSE_FIGHT,this.onDefuseFightClickHandler);
               this._fightFromPanel.addEventListener(UIEvent.BE_CANCEL_FIGHT,this.beCancelFightHandler);
            }
         }
         else if(_loc17_ == Head.REQUEST_CANCEL)
         {
            trace("挑战被取消");
            _loc5_ = _loc16_.readUTF();
            _loc6_ = _loc16_.readUTF();
            if(_loc5_ == ChatManager.getInstance().peerID)
            {
               if(this._fightFromPanel != null && this._fightFromPanel.fromPID == _loc6_)
               {
                  this._fightFromPanel.initData({"type":4});
               }
            }
         }
         else if(_loc17_ == Head.RESPONSE)
         {
            trace("对方拒绝挑战");
            if((_loc7_ = _loc16_.readUTF()) == ChatManager.getInstance().peerID)
            {
               ChatManager.getInstance().farID = null;
               if(this._fightFromPanel != null)
               {
                  this._fightFromPanel.initData({"type":3});
               }
            }
         }
         else if(_loc17_ == Head.NET_INFO)
         {
            trace("接收完毕");
            _loc8_ = _loc16_.readInt();
            _loc9_ = _loc16_.readObject();
            this.netInfoProcess(_loc9_);
         }
         else if(_loc17_ == Head.FANGSHUANGKAI_POST)
         {
            trace("防双开校验");
            _loc10_ = _loc16_.readUTF();
            _loc11_ = _loc16_.readUTF();
            _loc12_ = _loc16_.readUTF();
            _loc13_ = _loc16_.readUTF();
            _loc14_ = _loc16_.readInt();
            _loc15_ = _loc16_.readUTF();
            if(_loc11_ != RoleModel.getInstance().userID)
            {
               return;
            }
            if(_loc12_ != RoleModel.getInstance().userName)
            {
               return;
            }
            if(_loc15_ == ChatManager.getInstance().peerID)
            {
               return;
            }
            if(_loc13_ != RoleModel.getInstance().roleName)
            {
               return;
            }
            if(_loc14_ != RoleModel.getInstance().imageID)
            {
               return;
            }
            if(_loc10_ != RoleModel.getInstance().agent)
            {
               return;
            }
            this.openConnectWait();
            ChatManager.getInstance().close();
            this.removeP2PFight();
            dispatchEvent(new FightEvent(FightEvent.CLOSE_FIGHT,true));
            this.showMsg({
               "type":0,
               "text":"此账号已经登录游戏!",
               "fun":this.shuangkaiChecked
            });
         }
      }
      
      private function onAreaPostNotifyHandler(param1:P2PEvent) : *
      {
         var _loc2_:ByteArray = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:ByteArray = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc15_:int = 0;
         var _loc16_:String = null;
         var _loc17_:ByteArray;
         var _loc18_:int = (_loc17_ = param1.data as ByteArray).readInt();
         var _loc19_:Object = {};
         if(_loc18_ == Head.HELLO_NEIGHBOR)
         {
            trace("邻居打招呼");
            if(RoleModel.getInstance().status == RoleStatus.DANJI || RoleModel.getInstance().status == RoleStatus.GUANKA)
            {
               return;
            }
            if(RoleModel.getInstance().status == RoleStatus.LEITAI || RoleModel.getInstance().status == RoleStatus.LEITAI_DATING)
            {
               return;
            }
            trace("处理邻居打招呼");
            _loc19_.roleID = _loc17_.readUTF();
            _loc19_.pID = _loc17_.readUTF();
            _loc19_.area = _loc17_.readUTF();
            _loc19_.name = _loc17_.readUTF();
            _loc19_.image = _loc17_.readInt();
            _loc19_.level = _loc17_.readInt();
            _loc19_.status = _loc17_.readInt();
            ChatManager.getInstance().addNeighBor(_loc19_);
            _loc2_ = new ByteArray();
            _loc2_.writeInt(Head.NEIGHBOR_REPLY);
            _loc2_.writeUTF(_loc19_.pID);
            _loc2_.writeUTF(RoleModel.getInstance().roleID.toString());
            _loc2_.writeUTF(ChatManager.getInstance().peerID);
            _loc2_.writeUTF(RoleModel.getInstance().agent);
            _loc2_.writeUTF(RoleModel.getInstance().roleName);
            _loc2_.writeInt(RoleModel.getInstance().imageID);
            _loc2_.writeInt(RoleModel.getInstance().level);
            _loc2_.writeInt(RoleModel.getInstance().status);
            _loc2_.writeFloat(Math.random());
            ChatManager.getInstance().areaPost(_loc2_);
         }
         else if(_loc18_ == Head.NEIGHBOR_REPLY)
         {
            trace("邻居回复");
            _loc19_.toPID = _loc17_.readUTF();
            if(_loc19_.toPID != ChatManager.getInstance().peerID)
            {
               return;
            }
            if(RoleModel.getInstance().status == RoleStatus.DANJI || RoleModel.getInstance().status == RoleStatus.GUANKA)
            {
               return;
            }
            _loc19_.roleID = _loc17_.readUTF();
            _loc19_.pID = _loc17_.readUTF();
            _loc19_.area = _loc17_.readUTF();
            _loc19_.name = _loc17_.readUTF();
            _loc19_.image = _loc17_.readInt();
            _loc19_.level = _loc17_.readInt();
            _loc19_.status = _loc17_.readInt();
            ChatManager.getInstance().addNeighBor(_loc19_);
         }
         else if(_loc18_ == Head.STATUS_CHANG)
         {
            trace("状态改变");
            if(RoleModel.getInstance().status == RoleStatus.DANJI || RoleModel.getInstance().status == RoleStatus.GUANKA)
            {
               return;
            }
            trace("处理状态改变");
            _loc19_.roleID = _loc17_.readUTF();
            _loc19_.pID = _loc17_.readUTF();
            _loc19_.status = _loc17_.readInt();
            ChatManager.getInstance().changeStatus(_loc19_);
         }
         else if(_loc18_ == Head.REMOVE_NEIGHBOR)
         {
            if(RoleModel.getInstance().status == RoleStatus.DANJI || RoleModel.getInstance().status == RoleStatus.GUANKA)
            {
               return;
            }
            ChatManager.getInstance().removeNeighBor(_loc17_.readUTF());
         }
         else if(_loc18_ == Head.REQUEST)
         {
            trace("有人发来对战请求");
            _loc3_ = _loc17_.readUTF();
            if(RoleModel.getInstance().status != RoleStatus.DANJI && RoleModel.getInstance().status != RoleStatus.NOMAL)
            {
               if(_loc3_ == ChatManager.getInstance().peerID)
               {
                  _loc17_.readUTF();
                  _loc4_ = _loc17_.readUTF();
                  (_loc5_ = new ByteArray()).writeInt(Head.RESPONSE);
                  _loc5_.writeUTF(_loc4_);
                  _loc5_.writeUTF(_loc3_);
                  _loc5_.writeBoolean(false);
                  _loc5_.writeFloat(Math.random());
                  ChatManager.getInstance().areaPost(_loc5_);
               }
            }
            else if(_loc3_ == ChatManager.getInstance().peerID)
            {
               _loc19_.roleID = _loc17_.readUTF();
               _loc19_.pID = _loc17_.readUTF();
               _loc19_.area = _loc17_.readUTF();
               _loc19_.name = _loc17_.readUTF();
               _loc19_.image = _loc17_.readInt();
               _loc19_.level = _loc17_.readInt();
               _loc19_.type = 2;
               _loc19_.channel = "area";
               trace("对方的信息:",_loc19_.roleID,_loc19_.pID,_loc19_.area,_loc19_.name,_loc19_.image,_loc19_.level);
               this.openFightFromPanel();
               this._fightFromPanel.initData(_loc19_);
               this._fightFromPanel.addEventListener(UIEvent.AGREE_FIGHT,this.onAgreeFightClickHandler);
               this._fightFromPanel.addEventListener(UIEvent.DEFUSE_FIGHT,this.onDefuseFightClickHandler);
               this._fightFromPanel.addEventListener(UIEvent.BE_CANCEL_FIGHT,this.beCancelFightHandler);
            }
         }
         else if(_loc18_ == Head.REQUEST_CANCEL)
         {
            trace("挑战被取消");
            _loc6_ = _loc17_.readUTF();
            _loc7_ = _loc17_.readUTF();
            if(_loc6_ == ChatManager.getInstance().peerID)
            {
               if(this._fightFromPanel != null && this._fightFromPanel.fromPID == _loc7_)
               {
                  this._fightFromPanel.initData({"type":4});
               }
            }
         }
         else if(_loc18_ == Head.RESPONSE)
         {
            trace("对方拒绝挑战");
            if((_loc8_ = _loc17_.readUTF()) == ChatManager.getInstance().peerID)
            {
               ChatManager.getInstance().farID = null;
               if(this._fightFromPanel != null)
               {
                  this._fightFromPanel.initData({"type":3});
               }
            }
         }
         else if(_loc18_ == Head.NET_INFO)
         {
            trace("接收完毕");
            _loc9_ = _loc17_.readInt();
            _loc10_ = _loc17_.readObject();
            this.netInfoProcess(_loc10_);
         }
         else if(_loc18_ == Head.FANGSHUANGKAI_POST)
         {
            trace("防双开校验");
            _loc11_ = _loc17_.readUTF();
            _loc12_ = _loc17_.readUTF();
            _loc13_ = _loc17_.readUTF();
            _loc14_ = _loc17_.readUTF();
            _loc15_ = _loc17_.readInt();
            _loc16_ = _loc17_.readUTF();
            if(_loc12_ != RoleModel.getInstance().userID)
            {
               return;
            }
            if(_loc13_ != RoleModel.getInstance().userName)
            {
               return;
            }
            if(_loc16_ == ChatManager.getInstance().peerID)
            {
               return;
            }
            if(_loc14_ != RoleModel.getInstance().roleName)
            {
               return;
            }
            if(_loc15_ != RoleModel.getInstance().imageID)
            {
               return;
            }
            if(_loc11_ != RoleModel.getInstance().agent)
            {
               return;
            }
            this.openConnectWait();
            this.showMsg({
               "type":0,
               "text":"此账号已经登录游戏!",
               "fun":this.shuangkaiChecked
            });
         }
      }
      
      private function onStatusChangeHandler(param1:P2PEvent) : *
      {
         if(this._gameCenter != null)
         {
            this._gameCenter.changeStatus(param1.data);
         }
      }
      
      private function onP2PConnectFailHandler(param1:P2PEvent) : *
      {
         var _loc2_:ByteArray = null;
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeInt(Head.RESPONSE);
         _loc3_.writeUTF(param1.data.pID);
         _loc3_.writeUTF(ChatManager.getInstance().peerID);
         _loc3_.writeBoolean(false);
         _loc3_.writeFloat(Math.random());
         ChatManager.getInstance().worldPost(_loc3_);
         if(this.isDanji() == true)
         {
            RoleModel.getInstance().status = RoleStatus.DANJI;
         }
         else
         {
            RoleModel.getInstance().status = RoleStatus.NOMAL;
            if(this.gameCenterOpened() == true)
            {
               _loc2_ = new ByteArray();
               _loc2_.writeInt(Head.STATUS_CHANG);
               _loc2_.writeUTF(RoleModel.getInstance().roleID.toString());
               _loc2_.writeUTF(ChatManager.getInstance().peerID);
               _loc2_.writeInt(RoleModel.getInstance().status);
               _loc2_.writeFloat(Math.random());
               ChatManager.getInstance().areaPost(_loc2_);
            }
         }
      }
      
      private function onP2PWaitHandler(param1:P2PEvent) : *
      {
         this.openConnectWait();
      }
      
      private function onP2PConnectSuccessHandler(param1:P2PEvent) : *
      {
         this.closeFightFromPanel();
         var _loc2_:Object = {};
         _loc2_.head = Head.DELAY_REQUEST;
         _loc2_.time = getTimer();
         ChatManager.getInstance().p2pSend(_loc2_);
      }
      
      private function onP2PAbendCloseHandler(param1:P2PEvent) : *
      {
         var _loc2_:ByteArray = null;
         trace("onP2PAbendCloseHandler");
         if(this._p2pFight != null)
         {
            this._p2pFight.clear();
            dispatchEvent(new FightEvent(FightEvent.P2P_FIGHT_COMPLETE,true,{
               "flag":"offLine",
               "relativeName":this._p2pFight.relativeName
            }));
         }
         else
         {
            if(this.isDanji() == true)
            {
               RoleModel.getInstance().status = RoleStatus.DANJI;
            }
            else
            {
               RoleModel.getInstance().status = RoleStatus.NOMAL;
               if(this.gameCenterOpened() == true)
               {
                  _loc2_ = new ByteArray();
                  _loc2_.writeInt(Head.STATUS_CHANG);
                  _loc2_.writeUTF(RoleModel.getInstance().roleID.toString());
                  _loc2_.writeUTF(ChatManager.getInstance().peerID);
                  _loc2_.writeInt(RoleModel.getInstance().status);
                  _loc2_.writeFloat(Math.random());
                  ChatManager.getInstance().areaPost(_loc2_);
               }
            }
            this.closeFightFromPanel();
            this.removeFightWait();
            this.showMsg({
               "type":0,
               "text":"对方已断网，无法继续连接！"
            });
         }
      }
      
      private function onP2PCloseHandler(param1:P2PEvent) : *
      {
         trace("onP2PCloseHandler");
         if(this._p2pFight != null && this._p2pFight.isOver == false)
         {
            this._p2pFight.clear();
            dispatchEvent(new FightEvent(FightEvent.P2P_FIGHT_COMPLETE,true,{
               "flag":"offLine",
               "relativeName":this._p2pFight.relativeName
            }));
         }
      }
      
      private function onNetDisconnectionHandler(param1:P2PEvent) : *
      {
         ChatManager.getInstance().close();
         if(Config.netError == false)
         {
            Config.netError = true;
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,false,{
               "type":0,
               "text":"网络连接中断，请检查网络是否正常重新进入游戏!",
               "fun":this.shuangkaiChecked
            }));
         }
      }
      
      private function onServerDownHandler(param1:P2PEvent) : *
      {
         ChatManager.getInstance().close();
         this.openConnectWait();
         this.showMsg({
            "type":0,
            "text":param1.data.text
         });
      }
      
      private function onP2PMessageHandler(param1:P2PEvent) : *
      {
         var _loc2_:Object = null;
         var _loc3_:* = null;
         _loc2_ = param1.data;
         switch(int(_loc2_.type))
         {
            case 1:
               _loc3_ = "<font color=\'#ff0000\'>【官方消息】</font><font color=\'#66ffff\'>" + _loc2_.text + "</font>\n";
               if(this._gameCenter != null)
               {
                  this._gameCenter.setArea(_loc3_);
               }
               if(this._map != null)
               {
                  this._map.recieveNetInfo({"text":_loc3_});
               }
               break;
            case 2:
               this.showMsg({
                  "type":0,
                  "text":_loc2_.text
               });
               break;
            case 3:
               if(this._gameCenter != null)
               {
                  this._gameCenter.setPaomadeng(_loc2_.text.split("|"));
               }
         }
      }
      
      private function onP2PModifyHandler(param1:P2PEvent) : *
      {
         var _loc2_:ArmyInfo = null;
         var _loc3_:int = int(param1.data.head);
         switch(_loc3_)
         {
            case 1:
               RoleModel.getInstance().money = RoleModel.getInstance().money + int(param1.data.value);
               break;
            case 2:
               RoleModel.getInstance().exploit = RoleModel.getInstance().exploit + int(param1.data.value);
               break;
            case 3:
               RoleModel.getInstance().reverence = RoleModel.getInstance().reverence + int(param1.data.value);
               break;
            case 4:
               RoleModel.getInstance().addBagItem(1,param1.data.code,int(param1.data.count));
               break;
            case 5:
               RoleModel.getInstance().delBagItem(param1.data.code,int(param1.data.count));
               break;
            case 6:
               _loc2_ = Data.getInstance().getArmyInfo(param1.data.code,1);
               RoleModel.getInstance().addSoldier(_loc2_);
               break;
            case 7:
               RoleModel.getInstance().removeSoldier(param1.data.code);
               break;
            case 8:
               RoleModel.getInstance().modifySoldier(param1.data.code,param1.data.level,param1.data.evolution,param1.data.feature);
         }
      }
      
      private function onP2PKickHandler(param1:P2PEvent) : *
      {
         ChatManager.getInstance().close();
         this.openConnectWait();
         this.showMsg({
            "type":0,
            "text":param1.data.text
         });
      }
      
      private function onP2PDataHandler(param1:P2PEvent) : *
      {
         var _loc2_:ByteArray = null;
         trace(RoleModel.getInstance().roleName,"接收到p2p事件",param1.data.head);
         var _loc3_:Object = {};
         switch(param1.data.head)
         {
            case Head.DELAY_REQUEST:
               _loc3_.head = Head.DELAY_RESPONSE;
               _loc3_.time = param1.data.time;
               _loc3_.time2 = getTimer();
               ChatManager.getInstance().p2pSend(_loc3_);
               break;
            case Head.DELAY_RESPONSE:
               _loc3_.head = Head.DELAY_SEND;
               _loc3_.time2 = param1.data.time2;
               ChatManager.getInstance().delay = getTimer() - int(param1.data.time);
               ChatManager.getInstance().p2pSend(_loc3_);
               break;
            case Head.DELAY_SEND:
               ChatManager.getInstance().delay = getTimer() - int(param1.data.time2);
               _loc3_.head = Head.SOLDIER_FROM_CLIENT;
               _loc3_.name = RoleModel.getInstance().roleName;
               _loc3_.roleID = RoleModel.getInstance().roleID;
               _loc3_.level = RoleModel.getInstance().level;
               _loc3_.image = RoleModel.getInstance().imageID;
               _loc3_.army = RoleModel.getInstance().getChooseSoldiersSimpleList();
               _loc3_.delay = ChatManager.getInstance().delay;
               ChatManager.getInstance().p2pSend(_loc3_);
               break;
            case Head.SOLDIER_FROM_CLIENT:
               _loc3_.head = Head.SOLDIER_FROM_SEVER;
               _loc3_.name = RoleModel.getInstance().roleName;
               _loc3_.roleID = RoleModel.getInstance().roleID;
               _loc3_.level = RoleModel.getInstance().level;
               _loc3_.image = RoleModel.getInstance().imageID;
               _loc3_.army = RoleModel.getInstance().getChooseSoldiersSimpleList();
               _loc3_.delay = ChatManager.getInstance().delay;
               ChatManager.getInstance().p2pSend(_loc3_);
               if(ChatManager.getInstance().leitaiMode == false)
               {
                  if(ChatManager.getInstance().server == true)
                  {
                     this.addFightWait(Data.getInstance().getArmyBySimpleList(param1.data.army),RoleModel.getInstance().getChooseSoldiers(),param1.data,this.getSimpleInfo(),-1);
                  }
                  else
                  {
                     this.addFightWait(RoleModel.getInstance().getChooseSoldiers(),Data.getInstance().getArmyBySimpleList(param1.data.army),this.getSimpleInfo(),param1.data,1);
                  }
               }
               else if(ChatManager.getInstance().leizhu == false)
               {
                  this.addFightWait(Data.getInstance().getArmyBySimpleList(param1.data.army),RoleModel.getInstance().getChooseSoldiers(),param1.data,this.getSimpleInfo(),-1);
               }
               else
               {
                  this.addFightWait(RoleModel.getInstance().getChooseSoldiers(),Data.getInstance().getArmyBySimpleList(param1.data.army),this.getSimpleInfo(),param1.data,1);
               }
               this._fightWait.visible = false;
               this._fightWait.fight();
               break;
            case Head.SOLDIER_FROM_SEVER:
               if(ChatManager.getInstance().leitaiMode == false)
               {
                  if(ChatManager.getInstance().server == true)
                  {
                     this.addFightWait(Data.getInstance().getArmyBySimpleList(param1.data.army),RoleModel.getInstance().getChooseSoldiers(),param1.data,this.getSimpleInfo(),-1);
                  }
                  else
                  {
                     this.addFightWait(RoleModel.getInstance().getChooseSoldiers(),Data.getInstance().getArmyBySimpleList(param1.data.army),this.getSimpleInfo(),param1.data,1);
                  }
               }
               else if(ChatManager.getInstance().leizhu == false)
               {
                  this.addFightWait(Data.getInstance().getArmyBySimpleList(param1.data.army),RoleModel.getInstance().getChooseSoldiers(),param1.data,this.getSimpleInfo(),-1);
               }
               else
               {
                  this.addFightWait(RoleModel.getInstance().getChooseSoldiers(),Data.getInstance().getArmyBySimpleList(param1.data.army),this.getSimpleInfo(),param1.data,1);
               }
               this._fightWait.visible = false;
               this._fightWait.fight();
               this.closeConnectWait();
               break;
            case Head.FIGHT_STATUS_CHANGE:
               if(this._fightWait != null)
               {
                  this._fightWait.setStatus(param1.data.direct,param1.data.status);
               }
               break;
            case Head.FIGHT_START:
               if(ChatManager.getInstance().leitaiMode == true)
               {
                  this.closeConnectWait();
               }
               if(this._fightWait != null)
               {
                  this.addP2PFight(this._fightWait.getLeftArmy(),this._fightWait.getRightArmy(),this._fightWait.getLeftInfo(),this._fightWait.getRightInfo(),this._fightWait.getDirect());
                  this.removeFightWait();
                  MySound.getInstance().startByName(SoundCode.P2PFIGHT);
               }
               break;
            case Head.CANCEL_FIGHT:
               this.removeFightWait();
               ChatManager.getInstance().farID = null;
               ChatManager.getInstance().recievedClose();
               if(this.isDanji() == true)
               {
                  RoleModel.getInstance().status = RoleStatus.DANJI;
               }
               else
               {
                  RoleModel.getInstance().status = RoleStatus.NOMAL;
                  if(this.gameCenterOpened() == true)
                  {
                     _loc2_ = new ByteArray();
                     _loc2_.writeInt(Head.STATUS_CHANG);
                     _loc2_.writeUTF(RoleModel.getInstance().roleID.toString());
                     _loc2_.writeUTF(ChatManager.getInstance().peerID);
                     _loc2_.writeInt(RoleModel.getInstance().status);
                     _loc2_.writeFloat(Math.random());
                     ChatManager.getInstance().areaPost(_loc2_);
                  }
               }
            case Head.ACTION_FROM_CLIENT:
            case Head.ACTION_FROM_SERVER:
               if(this._p2pFight != null)
               {
                  this._p2pFight.p2pAction(param1.data);
               }
               break;
            case Head.HURT_FROM_CLIENT:
            case Head.HURT_FROM_SERVER:
               if(this._p2pFight != null)
               {
                  this._p2pFight.p2pHurt(param1.data);
               }
               break;
            case Head.SHANBI_FROM_SERVER:
            case Head.SHANBI_FROM_CLIENT:
               if(this._p2pFight != null)
               {
                  this._p2pFight.p2pShanbi(param1.data);
               }
               break;
            case Head.RESULT_FROM_SERVER:
               trace("战斗结果");
               dispatchEvent(new FightEvent(FightEvent.P2P_FIGHT_COMPLETE,true,{
                  "flag":param1.data.flag,
                  "m":param1.data.m,
                  "n":param1.data.n,
                  "relativeName":param1.data.relativeName
               }));
               break;
            case Head.LEITAI_RESULT_FROM_SERVER:
               trace("p2p收到擂台战斗结果");
               dispatchEvent(new FightEvent(FightEvent.LEITAI_FIGHT_COMPLETE,true,{
                  "flag":param1.data.flag,
                  "leizhu":param1.data.leizhu,
                  "relativeName":param1.data.relativeName
               }));
            case Head.P2P_TALK:
               if(this._fightWait != null)
               {
                  this._fightWait.setArea(param1.data.text);
               }
               else if(this._p2pFight != null)
               {
                  this._p2pFight.setArea(param1.data.text);
               }
               break;
            case Head.ADD_SOLDIER:
               if(this._fightWait != null)
               {
                  this._fightWait.addSoldier(param1.data);
               }
               break;
            case Head.REMOVE_SOLDIER:
               if(this._fightWait != null)
               {
                  this._fightWait.removeSoldier(param1.data);
               }
         }
      }
      
      private function getSimpleInfo() : Object
      {
         var _loc1_:Object = {};
         _loc1_.name = RoleModel.getInstance().roleName;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.level = RoleModel.getInstance().level;
         _loc1_.image = RoleModel.getInstance().imageID;
         _loc1_.delay = ChatManager.getInstance().delay;
         return _loc1_;
      }
      
      private function onMessageHandler(param1:UIEvent) : *
      {
         this.showMsg(param1.data);
      }
      
      private function onUICloseHandler(param1:UIEvent) : *
      {
         if(param1.target == this._createRolePanel)
         {
            this.closeCreateRolePanel();
         }
         else if(param1.target == this._fightFromPanel)
         {
            this.closeFightFromPanel();
         }
         else if(param1.target == this._generalListPanel)
         {
            this.closeGeneralListPanel();
         }
         else if(param1.target == this._generalInfoPanel)
         {
            this.closeGeneralInfoPanel();
         }
         else if(param1.target == this._generalJinhuaPanel)
         {
            this.closeGeneralJinhuaPanel();
            if(this._generalListPanel != null)
            {
               this._generalListPanel.flush();
            }
            if(this._generalInfoPanel != null)
            {
               this._generalInfoPanel.flush();
            }
         }
         else if(param1.target == this._shangzhenPanel)
         {
            this.closeShangzhenPanel();
         }
         else if(param1.target == this._zhaomuPanel)
         {
            this.closeZhaomuPanel();
         }
         else if(param1.target == this._bagPanel)
         {
            this.closeBagPanel();
         }
         else if(param1.target == this._stageListPanel)
         {
            this.closeStageListPanel();
         }
         else if(param1.target == this._fightResultPanel)
         {
            this.closeFightResultPanel();
            MySound.getInstance().startByName(SoundCode.MAP);
         }
         else if(param1.target == this._gameInfo)
         {
            this.closeGameInfo();
         }
         else if(param1.target == this._fightWait)
         {
            this.removeFightWait();
         }
         else if(param1.target == this._guide)
         {
            this.removeGuide();
            if(param1.target.flag == false)
            {
               this.addGameStory(2);
               this._gameStory.createMask(0,0.4);
               MySound.getInstance().startByName(SoundCode.MAP);
            }
         }
         else if(param1.target == this._gameStory)
         {
            if(this._gameStory.type == 1)
            {
               this.removeGameStory();
               this.addMap();
               this.addGuide(2);
               MySound.getInstance().startByName(SoundCode.READY);
            }
            else
            {
               this.removeGameStory();
               this.flushDianka();
            }
         }
         else if(param1.target == this._shopPanel)
         {
            this.closeShopPanel();
         }
         else if(param1.target == this._yanzhengmaPanel)
         {
            this.closeYanzhengmaPanel();
         }
         else if(param1.target == this._fubenCheckPanel)
         {
            this.closeFubenCheckPanel();
         }
         else if(param1.target == this._fanpaiPanel)
         {
            this.closeFanpaiPanel();
         }
         else if(param1.target == this._leitaiPanel)
         {
            this.closeLeitai();
         }
         else if(param1.target == this._leitaiResultPanel)
         {
            this.closeLeitaiResult();
         }
         else if(param1.target == this._guoqing1)
         {
            this.closeGuoqing1();
         }
         else if(param1.target == this._guoqing2)
         {
            this.closeGuoqing2();
         }
         else
         {
            removeChild(param1.target as BaseUI);
         }
      }
      
      private function openWujiangHandler(param1:UIEvent) : *
      {
         this.openGeneralListPanel();
         this._generalListPanel.initData({
            "roleModel":RoleModel.getInstance(),
            "army":RoleModel.getInstance().getAllSoldiers()
         });
      }
      
      private function showGeneralInfoHandler(param1:UIEvent) : *
      {
         this.openGeneralInfoPanel();
         this._generalInfoPanel.initData(param1.data.armyInfo);
      }
      
      private function jinhuaClickHandler(param1:UIEvent) : void
      {
         this.openGeneralJinhuaPanel();
         this._generalJinhuaPanel.initData(param1.data);
      }
      
      private function jinhuaHandler(param1:UIEvent) : *
      {
         param1.stopImmediatePropagation();
         MySound.getInstance().startEventSoundByName(SoundCode.UP);
         var _loc2_:Object = {};
         if(this._generalListPanel != null)
         {
            this._generalListPanel.flush();
         }
         if(this._generalInfoPanel != null)
         {
            this._generalInfoPanel.flush();
         }
      }
      
      private function openBuduiHandler(param1:UIEvent) : *
      {
         this.openShangzhenPanel();
         this._shangzhenPanel.initData({
            "choose":RoleModel.getInstance().getChooseSoldiers(),
            "all":RoleModel.getInstance().getAllSoldierClone()
         });
      }
      
      private function openStageHandler(param1:UIEvent) : *
      {
         this.openStageListPanel();
         this._stageListPanel.initData(Data.getInstance().getGateList(param1.data.part,RoleModel.getInstance().getFinished()));
         RoleModel.getInstance().setHistory(param1.data.part);
      }
      
      private function openZhaomuHandler(param1:UIEvent) : *
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:ArmyInfo = null;
         var _loc5_:int = RoleModel.getInstance().level;
         var _loc6_:Vector.<String> = Data.getInstance().getZhaomuByLevel(_loc5_);
         var _loc7_:Vector.<String> = RoleModel.getInstance().getAllSoldierCode();
         var _loc8_:Array;
         if((_loc8_ = Tools.removeArrFromArr(_loc6_,_loc7_)).length == 0)
         {
            this.closeZhaomuPanel();
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,false,{
               "type":0,
               "text":"未发现在野武将。"
            }));
         }
         else
         {
            _loc2_ = Tools.randomFromArr(_loc8_);
            if(RoleModel.getInstance().level < 50)
            {
               _loc3_ = RoleModel.getInstance().level - 20;
               _loc3_ = _loc3_ < 1 ? 1 : _loc3_;
            }
            else
            {
               _loc3_ = 30;
            }
            _loc4_ = Data.getInstance().getArmyInfo(_loc2_,_loc3_);
            this.openZhaomuPanel();
            this._zhaomuPanel.initData(_loc4_);
         }
      }
      
      private function openBeibaoHandler(param1:UIEvent) : *
      {
         this.openBagPanel();
         this._bagPanel.initData(RoleModel.getInstance().getBagData());
      }
      
      private function openShopHandler(param1:UIEvent = null) : *
      {
         this.openShopPanel();
         this._shopPanel.initData({"label":1});
      }
      
      private function openBuchangHandler(param1:UIEvent) : *
      {
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_BUCHANG;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         AESController.getInstance().sendJSON(_loc2_,this.buchangResponse);
      }
      
      private function buchangResponse(param1:Object) : *
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:String = null;
         var _loc16_:ArmyInfo = null;
         if(param1.success == true)
         {
            _loc2_ = "尊敬的玩家你好，您领取了：";
            if(param1.data.money != null)
            {
               _loc3_ = int(param1.data.money) - RoleModel.getInstance().money;
               RoleModel.getInstance().money = int(param1.data.money);
               if(_loc3_ > 0)
               {
                  _loc2_ += _loc3_ + "银子、";
               }
            }
            if(param1.data.exploit != null)
            {
               _loc4_ = int(param1.data.exploit) - RoleModel.getInstance().exploit;
               RoleModel.getInstance().exploit = int(param1.data.exploit);
               if(_loc4_ > 0)
               {
                  _loc2_ += _loc4_ + "功勋、";
               }
            }
            if(param1.data.reverence != null)
            {
               _loc5_ = int(param1.data.reverence) - RoleModel.getInstance().reverence;
               RoleModel.getInstance().reverence = int(param1.data.reverence);
               if(_loc5_ > 0)
               {
                  _loc2_ += _loc5_ + "声望、";
               }
            }
            if(param1.data.item != null)
            {
               _loc6_ = 0;
               while(_loc6_ < param1.data.item.length)
               {
                  _loc7_ = String(param1.data.item[_loc6_].code);
                  _loc8_ = Data.getInstance().getAttributes("proto",_loc7_,"name");
                  _loc9_ = int(param1.data.item[_loc6_].count) - RoleModel.getInstance().getBagItemCount(_loc7_);
                  RoleModel.getInstance().modiBagItem(int(param1.data.item[_loc6_].id),_loc7_,int(param1.data.item[_loc6_].count));
                  if(_loc9_ > 0)
                  {
                     _loc2_ += _loc8_ + _loc9_ + "个、";
                  }
                  _loc6_++;
               }
            }
            if(param1.data.general != null)
            {
               _loc10_ = 0;
               while(_loc10_ < param1.data.general.length)
               {
                  _loc11_ = String(param1.data.general[_loc10_].code);
                  _loc12_ = int(param1.data.general[_loc10_].level);
                  _loc13_ = int(param1.data.general[_loc10_].evolution);
                  _loc14_ = int(param1.data.general[_loc10_].feature);
                  _loc15_ = String(param1.data.general[_loc10_].kezhi);
                  (_loc16_ = Data.getInstance().getArmyInfo(_loc11_,_loc12_,_loc13_,_loc14_,null,3000,100,_loc15_)).id = Number(param1.data.general[_loc10_].id);
                  RoleModel.getInstance().addSoldier(_loc16_);
                  _loc2_ += "超级武将——" + param1.data.general[_loc10_].name + "。";
                  _loc10_++;
               }
            }
            this.showMsg({
               "type":0,
               "text":_loc2_,
               "skin":SkinCode.ALERT4
            });
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function lingDiankaHandler(param1:UIEvent) : *
      {
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_LING_DIANKA;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         AESController.getInstance().sendJSON(_loc2_,this.lingDiankaResponse);
      }
      
      private function lingDiankaResponse(param1:Object) : *
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         if(param1.success == true)
         {
            _loc2_ = int(param1.data.dianka) - RoleModel.getInstance().dianka;
            RoleModel.getInstance().dianka = int(param1.data.dianka);
            _loc3_ = "您已领取到游戏补偿" + _loc2_ + "点卡，祝游戏愉快！";
            this.showMsg({
               "type":0,
               "text":_loc3_,
               "skin":SkinCode.ALERT4
            });
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function onGameInfoBtnClickHandler(param1:UIEvent) : *
      {
         this.openGameInfo();
      }
      
      public function onConnectServerBtnClickHandler(param1:UIEvent) : *
      {
         RoleModel.getInstance().status = RoleStatus.NOMAL;
         ChatManager.getInstance().resetNeightBor();
         this.enterGameCenterHandler(null);
         trace("点击了联机对战按钮");
         this.sendHelloNeighbor();
      }
      
      private function enterGameCenterHandler(param1:UIEvent) : *
      {
         dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
         this.closeNetStatusPanel();
         this.removeCover();
         this.removeMap();
         this.addGameCenter();
         this._gameCenter.setRole(RoleModel.getInstance());
         this._gameCenter.setList(ChatManager.getInstance().neighBors);
         RoleModel.getInstance().addEventListener(Event.CHANGE,this.roleModelChangeHandler);
      }
      
      private function exitGameCenterHandler(param1:UIEvent) : *
      {
         RoleModel.getInstance().removeEventListener(Event.CHANGE,this.roleModelChangeHandler);
         RoleModel.getInstance().status = RoleStatus.DANJI;
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeInt(Head.REMOVE_NEIGHBOR);
         _loc2_.writeUTF(ChatManager.getInstance().peerID);
         _loc2_.writeFloat(Math.random());
         ChatManager.getInstance().areaPost(_loc2_);
         ChatManager.getInstance().resetNeightBor();
         this.removeGameCenter();
         this.addMap();
      }
      
      private function cancelFightWaitHandler(param1:UIEvent) : *
      {
         var _loc2_:ByteArray = null;
         if(this.isDanji() == true)
         {
            RoleModel.getInstance().status = RoleStatus.DANJI;
         }
         else
         {
            RoleModel.getInstance().status = RoleStatus.NOMAL;
            if(this.gameCenterOpened() == true)
            {
               _loc2_ = new ByteArray();
               _loc2_.writeInt(Head.STATUS_CHANG);
               _loc2_.writeUTF(RoleModel.getInstance().roleID.toString());
               _loc2_.writeUTF(ChatManager.getInstance().peerID);
               _loc2_.writeInt(RoleModel.getInstance().status);
               _loc2_.writeFloat(Math.random());
               ChatManager.getInstance().areaPost(_loc2_);
            }
         }
         this.removeFightWait();
      }
      
      public function startGameAsNewPlayer() : *
      {
         this.removeCover();
         this.addMap();
         MySound.getInstance().startByName(SoundCode.MAP);
         this.addGameStory(1);
      }
      
      private function netStatusPanelCloseHandler(param1:UIEvent) : *
      {
         ChatManager.getInstance().close();
         this.closeNetStatusPanel();
      }
      
      private function onDefusCheckBoxClickHandler(param1:UIEvent) : *
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeInt(Head.STATUS_CHANG);
         _loc2_.writeUTF(RoleModel.getInstance().roleID.toString());
         _loc2_.writeUTF(ChatManager.getInstance().peerID);
         _loc2_.writeInt(RoleModel.getInstance().status);
         _loc2_.writeFloat(Math.random());
         ChatManager.getInstance().areaPost(_loc2_);
      }
      
      private function onFightRequestClickHandler(param1:UIEvent) : *
      {
         var _loc2_:ByteArray = null;
         this.openFightFromPanel();
         var _loc3_:Object = {};
         _loc3_.roleID = RoleModel.getInstance().roleID;
         _loc3_.pID = param1.data.pID;
         _loc3_.area = param1.data.area;
         _loc3_.name = param1.data.name;
         _loc3_.image = param1.data.image;
         _loc3_.level = param1.data.level;
         _loc3_.type = 1;
         _loc3_.channel = param1.data.channel;
         this._fightFromPanel.initData(_loc3_);
         this._fightFromPanel.addEventListener(UIEvent.CLOSE,this.onCancelFightClickHandler);
         this._fightFromPanel.addEventListener(UIEvent.BE_DEFUSE_FIGHT,this.onCancelFightClickHandler);
         RoleModel.getInstance().status = RoleStatus.SEND;
         if(this.isDanji() == false && this.gameCenterOpened() == true)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeInt(Head.STATUS_CHANG);
            _loc2_.writeUTF(RoleModel.getInstance().roleID.toString());
            _loc2_.writeUTF(ChatManager.getInstance().peerID);
            _loc2_.writeInt(RoleModel.getInstance().status);
            _loc2_.writeFloat(Math.random());
            ChatManager.getInstance().areaPost(_loc2_);
         }
         var _loc4_:ByteArray;
         (_loc4_ = new ByteArray()).writeInt(Head.REQUEST);
         _loc4_.writeUTF(param1.data.pID);
         _loc4_.writeUTF(RoleModel.getInstance().roleID.toString());
         _loc4_.writeUTF(ChatManager.getInstance().peerID);
         _loc4_.writeUTF(RoleModel.getInstance().agent);
         _loc4_.writeUTF(RoleModel.getInstance().roleName);
         _loc4_.writeInt(RoleModel.getInstance().imageID);
         _loc4_.writeInt(RoleModel.getInstance().level);
         _loc4_.writeFloat(Math.random());
         trace("挑战者信息：",RoleModel.getInstance().roleID.toString(),ChatManager.getInstance().peerID,RoleModel.getInstance().agent,RoleModel.getInstance().roleName,RoleModel.getInstance().imageID,RoleModel.getInstance().level);
         if(param1.data.channel == "world")
         {
            ChatManager.getInstance().worldPost(_loc4_);
         }
         else
         {
            ChatManager.getInstance().areaPost(_loc4_);
         }
         ChatManager.getInstance().farID = param1.data.pID;
         ChatManager.getInstance().server = true;
      }
      
      private function onAgreeFightClickHandler(param1:UIEvent) : *
      {
         var _loc2_:ByteArray = null;
         this._fightFromPanel.removeEventListener(UIEvent.AGREE_FIGHT,this.onAgreeFightClickHandler);
         this._fightFromPanel.removeEventListener(UIEvent.DEFUSE_FIGHT,this.onDefuseFightClickHandler);
         this._fightFromPanel.removeEventListener(UIEvent.BE_CANCEL_FIGHT,this.beCancelFightHandler);
         this.closeFightFromPanel();
         RoleModel.getInstance().status = RoleStatus.FIGHT;
         if(this.gameCenterOpened() == true)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeInt(Head.STATUS_CHANG);
            _loc2_.writeUTF(RoleModel.getInstance().roleID.toString());
            _loc2_.writeUTF(ChatManager.getInstance().peerID);
            _loc2_.writeInt(RoleModel.getInstance().status);
            _loc2_.writeFloat(Math.random());
            ChatManager.getInstance().areaPost(_loc2_);
         }
         ChatManager.getInstance().p2pConnect(param1.data.pID,false);
      }
      
      private function onDefuseFightClickHandler(param1:UIEvent) : *
      {
         var _loc2_:String = this._fightFromPanel.channel;
         this._fightFromPanel.removeEventListener(UIEvent.AGREE_FIGHT,this.onAgreeFightClickHandler);
         this._fightFromPanel.removeEventListener(UIEvent.DEFUSE_FIGHT,this.onDefuseFightClickHandler);
         this._fightFromPanel.removeEventListener(UIEvent.BE_CANCEL_FIGHT,this.beCancelFightHandler);
         this.closeFightFromPanel();
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeInt(Head.RESPONSE);
         _loc3_.writeUTF(param1.data.pID);
         _loc3_.writeUTF(ChatManager.getInstance().peerID);
         _loc3_.writeBoolean(false);
         _loc3_.writeFloat(Math.random());
         if(_loc2_ == "world")
         {
            ChatManager.getInstance().worldPost(_loc3_);
         }
         else
         {
            ChatManager.getInstance().areaPost(_loc3_);
         }
      }
      
      private function beCancelFightHandler(param1:UIEvent) : *
      {
         if(this._fightFromPanel != null)
         {
            this._fightFromPanel.removeEventListener(UIEvent.AGREE_FIGHT,this.onAgreeFightClickHandler);
            this._fightFromPanel.removeEventListener(UIEvent.DEFUSE_FIGHT,this.onDefuseFightClickHandler);
            this._fightFromPanel.removeEventListener(UIEvent.BE_CANCEL_FIGHT,this.beCancelFightHandler);
         }
         this.closeFightFromPanel();
      }
      
      private function onCancelFightClickHandler(param1:UIEvent) : *
      {
         var _loc2_:ByteArray = null;
         var _loc3_:ByteArray = null;
         param1.stopImmediatePropagation();
         var _loc4_:String = this._fightFromPanel.channel;
         this._fightFromPanel.removeEventListener(UIEvent.CLOSE,this.onCancelFightClickHandler);
         this._fightFromPanel.removeEventListener(UIEvent.BE_DEFUSE_FIGHT,this.onCancelFightClickHandler);
         this.closeFightFromPanel();
         if(this.isDanji() == true)
         {
            RoleModel.getInstance().status = RoleStatus.DANJI;
         }
         else
         {
            RoleModel.getInstance().status = RoleStatus.NOMAL;
            if(this.gameCenterOpened() == true)
            {
               _loc2_ = new ByteArray();
               _loc2_.writeInt(Head.STATUS_CHANG);
               _loc2_.writeUTF(RoleModel.getInstance().roleID.toString());
               _loc2_.writeUTF(ChatManager.getInstance().peerID);
               _loc2_.writeInt(RoleModel.getInstance().status);
               _loc2_.writeFloat(Math.random());
               ChatManager.getInstance().areaPost(_loc2_);
            }
         }
         if(param1.type == UIEvent.CLOSE)
         {
            _loc3_ = new ByteArray();
            _loc3_.writeInt(Head.REQUEST_CANCEL);
            _loc3_.writeUTF(ChatManager.getInstance().farID);
            _loc3_.writeUTF(ChatManager.getInstance().peerID);
            _loc3_.writeFloat(Math.random());
            if(_loc4_ == "world")
            {
               ChatManager.getInstance().worldPost(_loc3_);
            }
            else
            {
               ChatManager.getInstance().areaPost(_loc3_);
            }
         }
         ChatManager.getInstance().farID = null;
      }
      
      private function gameStart(param1:UIEvent) : *
      {
         MySound.getInstance().startByName(SoundCode.MAP);
         this.addGameStory(1);
      }
      
      private function onChongzhiClickHandler(param1:UIEvent) : *
      {
         // 禁用4399充值跳转 — 本地测试版
         trace("chongzhi blocked: " + Config.CHONGZHI);
         dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
            "type":0,
            "text":"冲值完成后，请再次点击商城按钮以收取点卡。",
            "fun":this.flushDianka
         }));
      }
      
      public function flushDianka() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_DIANKA;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         _loc1_.mask = true;
         AESController.getInstance().sendJSON(_loc1_,this.diankaResponse);
      }
      
      private function diankaResponse(param1:Object) : *
      {
         var _loc2_:* = null;
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param1.success == true)
         {
            RoleModel.getInstance().dianka = int(param1.data.dianka);
            if(param1.data.award != null)
            {
               _loc2_ = "恭喜!您在“欢度新春”活动中充值金额满";
               _loc2_ += param1.data.award.rmb;
               _loc2_ += "元，\n奖励:";
               if(param1.data.award.general != null && param1.data.award.general != "")
               {
                  _loc3_ = param1.data.award.general.split("|");
               }
               if(param1.data.award.item != null && param1.data.award.item != "")
               {
                  _loc4_ = param1.data.award.item.split("|");
               }
               if(_loc3_ != null)
               {
                  _loc2_ += "超级武将-";
                  _loc5_ = 0;
                  while(_loc5_ < _loc3_.length)
                  {
                     _loc2_ += Data.getInstance().getAttributes("general",_loc3_[_loc5_],"name");
                     _loc2_ += "、";
                     _loc5_++;
                  }
               }
               if(_loc4_ != null)
               {
                  _loc6_ = 0;
                  while(_loc6_ < _loc4_.length)
                  {
                     _loc2_ += Data.getInstance().getAttributes("proto",_loc4_[_loc6_].split(":")[0],"name");
                     _loc2_ += _loc4_[_loc6_].split(":")[1] + "个、";
                     _loc6_++;
                  }
               }
               if(int(param1.data.award.exploit) > 0)
               {
                  _loc2_ += "功勋" + param1.data.award.exploit + "、";
               }
               if(int(param1.data.award.money) > 0)
               {
                  _loc2_ += "银子" + param1.data.award.money + "、";
               }
               if(int(param1.data.award.dianka) > 0)
               {
                  _loc2_ += "点卡" + param1.data.award.dianka;
               }
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "skin":SkinCode.GET_AWARD,
                  "text":_loc2_,
                  "fun":this.getAwardRequest
               }));
            }
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function getGuoqingRequest(param1:int = 0) : *
      {
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_GUOQING;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         _loc2_.flag = param1;
         _loc2_.mask = true;
         AESController.getInstance().sendJSON(_loc2_,this.getGuoqingResponse);
      }
      
      private function getGuoqingResponse(param1:Object) : *
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:ArmyInfo = null;
         if(param1.success == true)
         {
            if(param1.data.general != null)
            {
               _loc2_ = 0;
               while(_loc2_ < param1.data.general.length)
               {
                  _loc3_ = String(param1.data.general[_loc2_].code);
                  _loc4_ = int(param1.data.general[_loc2_].level);
                  _loc5_ = int(param1.data.general[_loc2_].evolution);
                  _loc6_ = int(param1.data.general[_loc2_].feature);
                  _loc7_ = String(param1.data.general[_loc2_].kezhi);
                  (_loc8_ = Data.getInstance().getArmyInfo(_loc3_,_loc4_,_loc5_,_loc6_,null,3000,100,_loc7_)).id = Number(param1.data.general[_loc2_].id);
                  RoleModel.getInstance().addSoldier(_loc8_);
                  _loc2_++;
               }
            }
            if(param1.data.money != null)
            {
               RoleModel.getInstance().money = int(param1.data.money);
            }
            if(param1.data.exploit != null)
            {
               RoleModel.getInstance().exploit = int(param1.data.exploit);
            }
            if(param1.data.dianka != null)
            {
               RoleModel.getInstance().dianka = int(param1.data.dianka);
            }
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function getAwardRequest() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_GETAWARD;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         _loc1_.mask = true;
         AESController.getInstance().sendJSON(_loc1_,this.getAwardResponse);
      }
      
      private function getAwardResponse(param1:Object) : *
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:ArmyInfo = null;
         var _loc9_:int = 0;
         if(param1.success == true)
         {
            if(param1.data.general != null && param1.data.general != "")
            {
               _loc2_ = 0;
               while(_loc2_ < param1.data.general.length)
               {
                  _loc3_ = String(param1.data.general[_loc2_].code);
                  _loc4_ = int(param1.data.general[_loc2_].level);
                  _loc5_ = int(param1.data.general[_loc2_].evolution);
                  _loc6_ = int(param1.data.general[_loc2_].feature);
                  _loc7_ = String(param1.data.general[_loc2_].kezhi);
                  (_loc8_ = Data.getInstance().getArmyInfo(_loc3_,_loc4_,_loc5_,_loc6_,null,3000,100,_loc7_)).id = Number(param1.data.general[_loc2_].id);
                  RoleModel.getInstance().addSoldier(_loc8_);
                  _loc2_++;
               }
            }
            if(param1.data.item != null && param1.data.item != "")
            {
               _loc9_ = 0;
               while(_loc9_ < param1.data.item.length)
               {
                  RoleModel.getInstance().modiBagItem(param1.data.item[_loc9_].id,param1.data.item[_loc9_].code,param1.data.item[_loc9_].count);
                  _loc9_++;
               }
            }
            if(param1.data.money != null)
            {
               RoleModel.getInstance().money = int(param1.data.money);
            }
            if(param1.data.exploit != null)
            {
               RoleModel.getInstance().exploit = int(param1.data.exploit);
            }
            if(param1.data.dianka != null)
            {
               RoleModel.getInstance().dianka = int(param1.data.dianka);
            }
            RoleModel.getInstance().throttleSave();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function speedCheckOutHandler(param1:UIEvent) : *
      {
         MySound.getInstance().startByName(SoundCode.MAP);
         dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
            "type":0,
            "text":"游戏发生了严重错误，已经退出战斗。通常这是因为使用了变速工具引起的。"
         }));
         if(param1.data.flag == "fight")
         {
            dispatchEvent(new FightEvent(FightEvent.CLOSE_FIGHT,true));
         }
         else if(param1.data.flag == "p2pfight")
         {
            dispatchEvent(new FightEvent(FightEvent.CLOSE_P2P_FIGHT,true));
         }
         else if(param1.data.flag == "xiongnu")
         {
            this.closeFubenHandler(null);
         }
         else if(param1.data.flag == "leitai")
         {
            this.removeP2PFight();
            ChatManager.getInstance().farID = null;
            ChatManager.getInstance().recievedClose();
            this._leitaiPanel.resetRID();
            RoleModel.getInstance().status = RoleStatus.LEITAI_DATING;
            ChatManager.getInstance().leitaiMode = false;
            ChatManager.getInstance().leizhu = true;
         }
      }
      
      private function fubenSpeedCheckOutHandler(param1:UIEvent) : *
      {
         MySound.getInstance().startByName(SoundCode.MAP);
         dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
            "type":0,
            "text":"游戏发生了严重错误，已经退出战斗。通常这是因为使用了变速工具引起的。"
         }));
         this.closeFubenHandler(null);
      }
      
      private function onTalkEventHandler(param1:TalkEvent) : *
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeInt(Head.NET_INFO);
         switch(param1.data.type)
         {
            case NetInfoType.PRIVATE:
               _loc2_.writeInt(NetInfoType.PRIVATE);
               break;
            case NetInfoType.WORLD:
               _loc2_.writeInt(NetInfoType.WORLD);
               break;
            case NetInfoType.PUBLIC:
               _loc2_.writeInt(NetInfoType.PUBLIC);
               break;
            case NetInfoType.LABA:
               _loc2_.writeInt(NetInfoType.LABA);
               break;
            case NetInfoType.SYSTEM:
               _loc2_.writeInt(NetInfoType.SYSTEM);
               this.netInfoProcess(param1.data);
         }
         _loc2_.writeObject(param1.data);
         _loc2_.writeFloat(Math.random());
         var _plainText:String = param1.data.text;
         if(param1.data.type == NetInfoType.PUBLIC)
         {
            ChatManager.getInstance().areaPost(_loc2_, _plainText);
         }
         else
         {
            ChatManager.getInstance().worldPost(_loc2_, _plainText);
         }
      }

      /** 接收纯文本聊天消息（绕过ByteArray解码） */
      private function onChatPlainHandler(param1:TalkEvent) : *
      {
         if(this._map != null)
         {
            this._map.recieveNetInfo(param1.data);
         }
      }

      private function netInfoProcess(param1:Object) : *
      {
         switch(param1.type)
         {
            case NetInfoType.PRIVATE:
               if(param1.toName == RoleModel.getInstance().roleName)
               {
                  if(this._gameCenter != null)
                  {
                     this._gameCenter.setArea(param1.text);
                  }
                  if(this._map != null)
                  {
                     this._map.recieveNetInfo(param1);
                  }
               }
               break;
            case NetInfoType.PUBLIC:
            case NetInfoType.LABA:
            case NetInfoType.WORLD:
               if(this._gameCenter != null)
               {
                  this._gameCenter.setArea(param1.text);
               }
               if(this._map != null)
               {
                  this._map.recieveNetInfo(param1);
               }
               break;
            case NetInfoType.SYSTEM:
               if(this._gameCenter != null)
               {
                  this._gameCenter.setArea(param1.text);
               }
               if(this._map != null)
               {
                  this._map.recieveNetInfo(param1);
               }
         }
      }
      
      public function isDanji() : Boolean
      {
         if(this._map == null)
         {
            return false;
         }
         return true;
      }
      
      public function fightResult() : Boolean
      {
         if(this._fightResultPanel != null)
         {
            return true;
         }
         return false;
      }
      
      public function leitaiFightResult() : Boolean
      {
         if(this._leitaiResultPanel != null)
         {
            return true;
         }
         return false;
      }
      
      private function xiongnuClickHandler(param1:UIEvent) : *
      {
         var _loc2_:Object = null;
         this.closeFubenHandler(null);
         if(RoleModel.getInstance().level < 30)
         {
            this.showMsg({
               "type":0,
               "text":"君主等级30级以上才可进入!"
            });
         }
         else
         {
            _loc2_ = {};
            _loc2_.head = Head.HTTP_NEW_FUBEN_COUNT;
            _loc2_.agent = Config.AGENT;
            _loc2_.ver = Config.VER;
            _loc2_.token = Config.token;
            _loc2_.roleID = RoleModel.getInstance().roleID;
            _loc2_.userID = RoleModel.getInstance().userID;
            _currentFubenStageID = (param1.data && param1.data.stageID) ? int(param1.data.stageID) : StageID.XI_SHA_XIONG_NU;
            _loc2_.stageID = _currentFubenStageID;
            _loc2_.mask = true;
            AESController.getInstance().sendJSON(_loc2_,this.getFubenCountResponse);
         }
      }
      
      private function getFubenCountResponse(param1:Object) : *
      {
         var _loc2_:* = null;
         if(param1.success == true)
         {
            if(int(param1.data.count) > 0)
            {
               this.openFubenCheckPanel();
               this._fubenCheckPanel.initData({"count":param1.data.count, "stageID":_currentFubenStageID});
            }
            else
            {
               _loc2_ = "你今天的挑战次数已用完，请您隔日再来或使用副本通行令进行挑战。";
               _loc2_ += "（副本通行令在商城出售）";
               this.showMsg({
                  "type":1,
                  "text":_loc2_,
                  "fun":this.userTongxingling,
                  "skin":SkinCode.FUBEN_SKIN2
               });
            }
            RoleModel.getInstance().throttleSave();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function injoyFubenHandler(param1:UIEvent) : *
      {
         param1.stopImmediatePropagation();
         this.closeFubenCheckPanel();
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_FUBEN_LOGIN;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         _loc2_.stageID = _currentFubenStageID;
         _loc2_.proto = 0;
         _loc2_.mask = true;
         AESController.getInstance().sendJSON(_loc2_,this.enterFubenResponse);
      }
      
      private function userTongxingling() : *
      {
         if(RoleModel.getInstance().getBagItemCount("proto_3_2") == 0)
         {
            this.showMsg({
               "type":1,
               "text":"你没有副本通行令，无法进入副本，请到商城购买。",
               "fun":this.openShopHandler,
               "skin":SkinCode.FUBEN_SKIN3
            });
            return;
         }
         if(XiongnuConfig.checkGeneralLevel(RoleModel.getInstance().getChooseSoldiers()) == false)
         {
            this.showMsg({
               "type":0,
               "text":"上阵的武将等级差不能超过10级，请重新调整上阵武将。"
            });
            return;
         }
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_FUBEN_LOGIN;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         _loc1_.stageID = _currentFubenStageID;
         _loc1_.proto = 1;
         _loc1_.mask = true;
         AESController.getInstance().sendJSON(_loc1_,this.enterFubenResponse);
      }
      
      private function enterFubenResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            if(int(param1.data.proto) == 1)
            {
               RoleModel.getInstance().delBagItem("proto_3_2");
            }
            this.startFuben(int(param1.data.stageID),1);
            RoleModel.getInstance().throttleSave();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function startFuben(param1:int, param2:int) : *
      {
         RoleModel.getInstance().status = RoleStatus.GUANKA;
         switch(param1)
         {
            case 1:
            case 2:
               this._xiongnuFight = new Xiongnu(RoleModel.getInstance().getChooseSoldiers(),param2,1,param1);
               addChild(this._xiongnuFight);
               MySound.getInstance().startByName(SoundCode.XIONGNU_SOUND1);
               break;
         }
      }
      
      private function onXiongnuCompleteHandler(param1:FightEvent) : *
      {
         MySound.getInstance().stop();
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_FUBEN_AWARD;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         _loc2_.stageID = int(param1.data.stageID);
         _loc2_.index = int(param1.data.index);
         _loc2_.result = int(param1.data.result);
         _loc2_.level = int(param1.data.level);
         _loc2_.mask = true;
         AESController.getInstance().sendJSON(_loc2_,this.xiongnuResultResponse);
      }
      
      private function xiongnuResultResponse(param1:Object) : *
      {
         var _loc2_:Array = null;
         if(param1.success == true)
         {
            if(param1.data.forward != null)
            {
               _loc2_ = [];
               _loc2_.push(int(param1.data.forward[0]) - RoleModel.getInstance().money);
               _loc2_.push(int(param1.data.forward[1]) - RoleModel.getInstance().exploit);
               _loc2_.push(int(param1.data.forward[2]) - RoleModel.getInstance().reverence);
               RoleModel.getInstance().money = int(param1.data.forward[0]);
               RoleModel.getInstance().exploit = int(param1.data.forward[1]);
               RoleModel.getInstance().reverence = int(param1.data.forward[2]);
               param1.data.forward = _loc2_;
            }
            this.openFubenResultPanel();
            this._fubenResultPanel.initData(param1.data);
            RoleModel.getInstance().throttleSave();
         }
         else
         {
            this.closeFubenHandler(null);
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function startFubenHandler(param1:UIEvent) : *
      {
         this.closeFubenHandler(null);
         this.startFuben(int(param1.data.stageID),int(param1.data.index));
      }
      
      private function closeFubenHandler(param1:UIEvent) : *
      {
         this.closeFubenResultPanel();
         if(this._xiongnuFight != null)
         {
            this._xiongnuFight.clear();
            removeChild(this._xiongnuFight);
            this._xiongnuFight = null;
         }
         RoleModel.getInstance().status = RoleStatus.DANJI;
      }
      
      private function openFanpaiHandler(param1:UIEvent) : *
      {
         this.closeFubenHandler(null);
         this.openFanpaiPanel();
         this._fanpaiPanel.initData({
            "pai":param1.data.pai,
            "stageID":param1.data.stageID
         });
      }
      
      private function sendPaimianHandler(param1:UIEvent) : *
      {
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_FUBEN_FANPAI;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         _loc2_.result = param1.data.data;
         _loc2_.mask = true;
         AESController.getInstance().sendJSON(_loc2_,this.sendPaimianResponse);
      }
      
      private function sendPaimianResponse(param1:Object) : *
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         if(param1.success == true)
         {
            if(param1.data.money != null)
            {
               RoleModel.getInstance().money = int(param1.data.money);
            }
            if(param1.data.item != null)
            {
               _loc2_ = int(param1.data.item.count);
               var _bagTotal2:int = RoleModel.getInstance().getBagItemCount(param1.data.item.code) + _loc2_;
               RoleModel.getInstance().modiBagItem(param1.data.item.id,param1.data.item.code,_bagTotal2);
               _loc3_ = TextFactory.makeFuben(RoleModel.getInstance().roleName,param1.data.item.code,_loc2_);
               dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                  "type":NetInfoType.SYSTEM,
                  "text":_loc3_
               }));
            }
            this.closeFanpaiPanel();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function shuangkaiPost(param1:UIEvent) : *
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeInt(Head.FANGSHUANGKAI_POST);
         _loc2_.writeUTF(RoleModel.getInstance().agent);
         _loc2_.writeUTF(RoleModel.getInstance().userID);
         _loc2_.writeUTF(RoleModel.getInstance().userName);
         _loc2_.writeUTF(RoleModel.getInstance().roleName);
         _loc2_.writeInt(RoleModel.getInstance().imageID);
         _loc2_.writeUTF(ChatManager.getInstance().peerID);
         _loc2_.writeDouble(Math.random());
         ChatManager.getInstance().worldPost(_loc2_);
      }
      
      public function shuangkaiChecked() : *
      {
         // 禁用4399跳转 — 本地测试版
         trace("shuangkaiChecked blocked");
      }
      
      public function gameCenterOpened() : Boolean
      {
         if(this._gameCenter == null)
         {
            return false;
         }
         return true;
      }
      
      private function serverSelectedHandler(param1:UIEvent) : *
      {
         param1.stopImmediatePropagation();
         RoleModel.getInstance().loginServer = int(param1.data.serverID);
         switch(RoleModel.getInstance().loginServer)
         {
            case 1:
               this.closeSelectServerPanel();
               Config.server3 = AESTools.decrypt(this._channel1,RoleModel.getInstance().openStr(Config.ARR1),RoleModel.getInstance().openStr(Config.ARR2));
               this.openNetStatusPanel(param1.data.newPlayer);
               break;
            case 2:
               this.closeSelectServerPanel();
               Config.server3 = AESTools.decrypt(this._channel2,RoleModel.getInstance().openStr(Config.ARR1),RoleModel.getInstance().openStr(Config.ARR2));
               this.openNetStatusPanel(param1.data.newPlayer);
               break;
            case 3:
               this.closeSelectServerPanel();
               Config.server3 = AESTools.decrypt(this._channel3,RoleModel.getInstance().openStr(Config.ARR1),RoleModel.getInstance().openStr(Config.ARR2));
               this.openNetStatusPanel(param1.data.newPlayer);
               break;
            case 4:
               this.closeSelectServerPanel();
               Config.server3 = AESTools.decrypt(this._channel4,RoleModel.getInstance().openStr(Config.ARR1),RoleModel.getInstance().openStr(Config.ARR2));
               this.openNetStatusPanel(param1.data.newPlayer);
               break;
            case 5:
               this.closeSelectServerPanel();
               Config.server3 = AESTools.decrypt(this._channel5,RoleModel.getInstance().openStr(Config.ARR1),RoleModel.getInstance().openStr(Config.ARR2));
               this.openNetStatusPanel(param1.data.newPlayer);
               break;
            case 6:
               this.closeSelectServerPanel();
               Config.server3 = AESTools.decrypt(this._channel6,RoleModel.getInstance().openStr(Config.ARR1),RoleModel.getInstance().openStr(Config.ARR2));
               this.openNetStatusPanel(param1.data.newPlayer);
               break;
            case 7:
               this.closeSelectServerPanel();
               Config.server3 = AESTools.decrypt(this._channel7,RoleModel.getInstance().openStr(Config.ARR1),RoleModel.getInstance().openStr(Config.ARR2));
               this.openNetStatusPanel(param1.data.newPlayer);
               break;
            case 8:
               this.closeSelectServerPanel();
               Config.server3 = AESTools.decrypt(this._channel8,RoleModel.getInstance().openStr(Config.ARR1),RoleModel.getInstance().openStr(Config.ARR2));
               this.openNetStatusPanel(param1.data.newPlayer);
         }
      }
      
      public function createNewsInfoPanel() : *
      {
         var _loc1_:BaseUI = new BaseUI(SkinCode.NEWS_INFO_PANEL);
         addChild(_loc1_);
         _loc1_.x = stage.stageWidth / 2;
         _loc1_.y = stage.stageHeight / 2;
         _loc1_.getSkin().gotoAndStop(Config.actionMessage());
         _loc1_.addEventListener(MouseEvent.CLICK,this.onNewsInfoPanelClickHandler);
      }
      
      private function onNewsInfoPanelClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(param1.target is SimpleButton)
         {
            if(param1.target.name == "_okBtn")
            {
               removeChild(param1.currentTarget as DisplayObject);
            }
            else if(param1.target.name == "_guideBtn")
            {
               this.addGuide(2,true);
            }
         }
      }
      
      private function leitaiListRequest(param1:UIEvent) : *
      {
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_LEITAI_LIST;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         _loc2_.mask = true;
         AESController.getInstance().sendJSON(_loc2_,this.leitaiListResponse);
      }
      
      private function leitaiListResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            this.openLeitai(param1.data);
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function onLeitaiConnectSuccessHandler(param1:P2PEvent) : *
      {
         this._leitaiPanel.closeTipsPanel();
         this.closeLeitaiResult();
         this.openConnectWait();
         var _loc2_:Object = {};
         _loc2_.head = Head.DELAY_REQUEST;
         _loc2_.time = getTimer();
         ChatManager.getInstance().p2pSend(_loc2_);
      }
      
      private function onLeitaiConnectFailHandler(param1:P2PEvent) : void
      {
         this.closeConnectWait();
         if(ChatManager.getInstance().leizhu == false)
         {
            this.showMsg({
               "type":0,
               "text":"擂主已退出此擂台，请返回擂台界面重新选择需要攻打的擂台。",
               "fun":this.gongleiExit
            });
         }
         else
         {
            ChatManager.getInstance().farID = null;
            this.showMsg({
               "type":0,
               "text":"与攻擂方p2p连接失败!请与客服联系。"
            });
         }
      }
      
      private function gongleiExit() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_GONGLEI_EXIT;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         _loc1_.rID = this._leitaiPanel.rID;
         AESController.getInstance().sendJSON(_loc1_,this.gongleiExitResponse);
      }
      
      private function gongleiExitResponse(param1:Object) : *
      {
         this.removeP2PFight();
         RoleModel.getInstance().status = RoleStatus.LEITAI_DATING;
         ChatManager.getInstance().leitaiMode = false;
         ChatManager.getInstance().leizhu = true;
         if(param1.success == true)
         {
            this._leitaiPanel.resetRID();
            if(int(param1.data.money) > RoleModel.getInstance().money)
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"您选择了退出擂台，您的报名费将返还给您，请查看游戏内数据。"
               }));
            }
            else if(int(param1.data.exploit) > RoleModel.getInstance().exploit)
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"您选择了退出擂台，您的报名费将返还给您，请查看游戏内数据。"
               }));
            }
            else if(int(param1.data.dianka) > RoleModel.getInstance().dianka)
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"您选择了退出擂台，您的报名费将返还给您，请查看游戏内数据。"
               }));
            }
            RoleModel.getInstance().money = int(param1.data.money);
            RoleModel.getInstance().exploit = int(param1.data.exploit);
            RoleModel.getInstance().dianka = int(param1.data.dianka);
            RoleModel.getInstance().rongyu = int(param1.data.rongyu);
            this._leitaiPanel.flushLeitai(param1.data.leitai);
            this._leitaiPanel.flushOther(param1.data);
            GlobalTimer.getInstance().playListener(TimerStr.LEITAI_FLUSH);
            GlobalTimer.getInstance().playListener(TimerStr.PAIHANG_FLUSH);
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function onLeitaiAbendCloseHandler(param1:P2PEvent) : void
      {
         trace("对方掉线");
      }
      
      private function onLeitaiCloseHandler(param1:P2PEvent) : void
      {
         if(this._p2pFight != null && this._p2pFight.isOver == false)
         {
            this._p2pFight.clear();
            dispatchEvent(new FightEvent(FightEvent.LEITAI_FIGHT_COMPLETE,true,{
               "leizhu":ChatManager.getInstance().leizhu,
               "flag":"offLine",
               "relativeName":this._p2pFight.relativeName
            }));
         }
      }
      
      public function getLeitaiID() : int
      {
         if(this._leitaiPanel != null)
         {
            return this._leitaiPanel.rID;
         }
         return -1;
      }
      
      public function flushLeitai(param1:Object) : *
      {
         this._leitaiPanel.flushLeitai(param1.leitai);
         this._leitaiPanel.flushOther(param1);
      }
      
      private function becomeLeizhu(param1:UIEvent) : *
      {
         if(this._leitaiPanel != null)
         {
            this._leitaiPanel.becomeLeizhu(int(param1.data.roomID));
         }
      }
      
      private function continueLeizhuHandler(param1:UIEvent) : void
      {
         param1.stopImmediatePropagation();
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_LEITAI_CONTINUE;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         _loc2_.rID = param1.data.roomID;
         _loc2_.pID = ChatManager.getInstance().peerID;
         _loc2_.mask = true;
         AESController.getInstance().sendJSON(_loc2_,this.continueLeizhuResponse);
      }
      
      private function continueLeizhuResponse(param1:Object) : *
      {
         var _loc2_:Object = null;
         if(param1.success == true)
         {
            RoleModel.getInstance().status = RoleStatus.LEITAI;
            ChatManager.getInstance().leitaiMode = true;
            ChatManager.getInstance().leizhu = true;
            RoleModel.getInstance().money = int(param1.data.money);
            RoleModel.getInstance().exploit = int(param1.data.exploit);
            RoleModel.getInstance().dianka = int(param1.data.dianka);
            RoleModel.getInstance().rongyu = int(param1.data.rongyu);
            this._leitaiPanel.flushLeitai(param1.data.leitai);
            this._leitaiPanel.flushOther(param1.data);
            _loc2_ = this._leitaiPanel.findCountByrID(param1.data.rID,param1.data.leitai);
            if(this._leitaiResultPanel != null)
            {
               this._leitaiResultPanel.startTimer();
            }
            else if(_loc2_ != null)
            {
               this._leitaiPanel.openTipsPanel({
                  "rID":int(param1.data.rID),
                  "type":_loc2_.rCount == 0 ? 1 : 2
               });
            }
            else
            {
               this._leitaiPanel.openTipsPanel({
                  "rID":int(param1.data.rID),
                  "type":1
               });
            }
         }
         else
         {
            RoleModel.getInstance().status = RoleStatus.LEITAI_DATING;
            ChatManager.getInstance().leitaiMode = false;
            ChatManager.getInstance().leizhu = true;
            GlobalTimer.getInstance().playListener(TimerStr.LEITAI_FLUSH);
            GlobalTimer.getInstance().playListener(TimerStr.PAIHANG_FLUSH);
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      private function exitLeizhuHandler(param1:UIEvent) : void
      {
         param1.stopImmediatePropagation();
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_LEITAI_EXIT;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         _loc2_.rID = int(param1.data.roomID);
         _loc2_.flag = int(param1.data.flag);
         _loc2_.mask = true;
         AESController.getInstance().sendJSON(_loc2_,this.exitLeizhuResponse);
      }
      
      private function exitLeizhuResponse(param1:Object) : *
      {
         this.removeP2PFight();
         if(param1.success == true)
         {
            RoleModel.getInstance().status = RoleStatus.LEITAI_DATING;
            ChatManager.getInstance().leitaiMode = false;
            ChatManager.getInstance().leizhu = true;
            this._leitaiPanel.resetRID();
            if(int(param1.data.money) > RoleModel.getInstance().money)
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"您选择了退出擂台，您的报名费将返还给您，请查看游戏内数据。"
               }));
            }
            else if(int(param1.data.exploit) > RoleModel.getInstance().exploit)
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"您选择了退出擂台，您的报名费将返还给您，请查看游戏内数据。"
               }));
            }
            else if(int(param1.data.dianka) > RoleModel.getInstance().dianka)
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"您选择了退出擂台，您的报名费将返还给您，请查看游戏内数据。"
               }));
            }
            RoleModel.getInstance().money = int(param1.data.money);
            RoleModel.getInstance().exploit = int(param1.data.exploit);
            RoleModel.getInstance().dianka = int(param1.data.dianka);
            RoleModel.getInstance().rongyu = int(param1.data.rongyu);
            this._leitaiPanel.flushLeitai(param1.data.leitai);
            this._leitaiPanel.flushOther(param1.data);
            this._leitaiPanel.closeTipsPanel();
            this.closeLeitaiResult();
            GlobalTimer.getInstance().playListener(TimerStr.LEITAI_FLUSH);
            GlobalTimer.getInstance().playListener(TimerStr.PAIHANG_FLUSH);
         }
         else
         {
            RoleModel.getInstance().status = RoleStatus.LEITAI_DATING;
            ChatManager.getInstance().leitaiMode = false;
            ChatManager.getInstance().leizhu = true;
            GlobalTimer.getInstance().playListener(TimerStr.LEITAI_FLUSH);
            GlobalTimer.getInstance().playListener(TimerStr.PAIHANG_FLUSH);
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
      
      public function leitaiFlushFun() : *
      {
         if(this._leitaiPanel != null)
         {
            this._leitaiPanel.leitaiFlushFun();
         }
      }
      
      private function lingGuoqingHandler(param1:UIEvent) : *
      {
         param1.stopImmediatePropagation();
         var _loc2_:int = int(param1.data.select);
         this.getGuoqingRequest(_loc2_);
         this.closeGuoqing1();
         this.closeGuoqing2();
      }
   }
}
