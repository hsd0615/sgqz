package game
{
   import com.adobe.serialization.json.JSON;
   import com.greensock.events.LoaderEvent;
   import com.greensock.loading.DataLoader;
   import com.greensock.loading.LoaderMax;
   import com.greensock.loading.SWFLoader;
   import com.greensock.loading.XMLLoader;
   import com.iflashigame.controller.AESController;
   import com.iflashigame.controller.ControllerEvent;
   import com.iflashigame.controller.Test;
   import com.iflashigame.net.ChatManager;
   import com.iflashigame.sound.MySound;
   import com.iflashigame.talk.NetInfoType;
   import com.iflashigame.talk.TalkEvent;
   import com.iflashigame.ui.TipsFrame;
   import com.iflashigame.utils.GlobalTimer;
   import com.iflashigame.utils.TextFilter;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.SecurityErrorEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.net.URLRequestMethod;
   import flash.net.navigateToURL;
   import flash.system.Capabilities;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.utils.ByteArray;
   import game.events.FightEvent;
   import game.events.SoldierEvent;
   import game.events.UIEvent;
   import game.model.ArmyInfo;
   import game.model.Cache;
   import game.model.Head;
   import game.model.RoleModel;
   import game.model.RoleStatus;
   import game.ui.SkinCode;
   import game.ui.TalkFrame;
   import unit4399.events.SaveEvent;
   
   public class Sanguo4399 extends Sprite
   {
      
      public static const DEBUG:Boolean = false;
      
      public static var _4399_function_ad_id:String = "92d6cef76cd06829e088932fe9fd819b";
      
      public static var serviceHold:* = null;
       
      
      private var _ui:UI;
      
      private var _fight:Fight;
      
      private var _tipsLayer:Sprite;
      
      private var _tips:TipsFrame;
      
      private var _bar:BarMC;
      
      private var _myData:String;
      
      private var _loaded:Boolean = false;
      
      private var _data:String = "";
      
      private var _newPlayer:Boolean = false;
      
      private var _netDirect:Boolean;
      
      public function Sanguo4399()
      {
         super();
         addEventListener(Event.ENTER_FRAME,this.onEnterframeHandler);
         if(stage)
         {
            this.init(null);
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,this.init);
         }
      }
      
      public function setHold(param1:*) : void
      {
         serviceHold = param1;
      }
      
      private function onEnterframeHandler(param1:Event) : *
      {
         var _loc2_:* = undefined;
         if(numChildren > 0)
         {
            _loc2_ = this.getChildAt(0);
            if(_loc2_ is MovieClip && _loc2_.width > 210 && _loc2_.width < 211 && _loc2_.height > 53 && _loc2_.height < 54)
            {
               this.removeChildAt(0);
            }
         }
      }
      
      private function init(param1:Event) : *
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.init);
         if(this.stage.loaderInfo.parameters.id != null)
         {
            serviceHold = {"isLog":{"uid":this.stage.loaderInfo.parameters.id}};
         }
         stage.tabChildren = false;
         stage.stageFocusRect = false;
         tabChildren = false;
         tabEnabled = false;
         Config.timer = 0;

         // 启动时不再做HTTP测试（影响启动速度）
         RoleModel.getInstance().agent = Config.AGENT;
         var _loc2_:ContextMenu = new ContextMenu();
         _loc2_.customItems.push(new ContextMenuItem("三国Q战4399版V" + Config.VER + " 网络版"));
         this.contextMenu = _loc2_;
         LoaderMax.activate([SWFLoader,DataLoader]);
         if(DEBUG == true)
         {
            this.loadGame(Test.getInstance().getLoginData());
         }
         else
         {
            this.initView();
            this.initEvent();
         }
         GlobalTimer.getInstance().start();
      }
      
      /**
       * 启动时测试服务器 HTTP 连接
       */
      /**
       * 读取账号配置。支持三种模式：
       * user_config.txt 格式:
       *   登录:  userID:password
       *   注册:  new:userID:password:角色名:头像ID
       */
      private function getTestUserID() : String
      {
         try {
            var configFile:File = File.applicationStorageDirectory.resolvePath("user_config.txt");
            var fs:FileStream = new FileStream();
            fs.open(configFile, FileMode.READ);
            var raw:String = fs.readUTFBytes(fs.bytesAvailable);
            fs.close();
            var lines:Array = raw.split(/\r?\n/);
               var firstLine:String = "";
               for(var i:int = 0; i < lines.length; i++) {
                  var line:String = lines[i].replace(/^\s+|\s+$/g, "");
                  if(line.length > 0 && line.charAt(0) != "#") {
                     firstLine = line;
                     break;
                  }
               }

               // 检测注册模式: new:userID:password:roleName:imageID
               if(firstLine.indexOf("new:") == 0) {
                  _registerMode = true;
                  var parts:Array = firstLine.split(":");
                  if(parts.length >= 5) {
                     _registerUserID = parts[1];
                     _registerPassword = parts[2];
                     _registerRoleName = parts[3];
                     _registerImageID = int(parts[4]);
                  }
                  trace("[Config] 注册模式: " + _registerUserID);
                  return _registerUserID;
               }

               // 登录模式: userID:password
               var colonPos:int = firstLine.indexOf(":");
               if(colonPos > 0) {
                  _loginUserID = firstLine.substring(0, colonPos);
                  _loginPassword = firstLine.substring(colonPos + 1);
                  trace("[Config] 登录模式: " + _loginUserID);
                  return _loginUserID;
               }

               // 兼容旧格式: 仅 userID
               if(firstLine.length > 0) {
                  _loginUserID = firstLine;
                  _loginPassword = "";
                  return _loginUserID;
               }
         } catch(e:Error) {
            trace("[Config] 读取用户配置失败: " + e.message);
         }
         _loginUserID = "test_user_001";
         _loginPassword = "";
         trace("[Config] 默认账号: test_user_001");
         return _loginUserID;
      }

      // 账号配置变量
      private var _loginUserID:String = "test_user_001";
      private var _loginPassword:String = "";
      private var _registerMode:Boolean = false;
      private var _registerUserID:String = "";
      private var _registerPassword:String = "";
      private var _registerRoleName:String = "";
      private var _registerImageID:int = 1;

      /**
       * 角色选择面板 - 显示已有角色列表，支持选择和密码登录
       */
      private var _mainPanel:Sprite;
      private var _playerList:Array = [];
      private var _selectedUserID:String = "";
      private var _passInputTF:TextField;
      private var _statusTF:TextField;
      private var _isRegistering:Boolean = false;

      private function showLoginPanel() : void
      {
         if(_mainPanel != null) return;
         _mainPanel = new Sprite();
         _isRegistering = false;

         drawMainPanelBg(330, 370);
         drawTitle("将 士 录");
         drawPlayerList();
         drawPasswordInput(330);
         drawLoginButton();
         drawRegisterButton();

         _mainPanel.x = (770 - 330) / 2;
         _mainPanel.y = (500 - 370) / 2 - 10;
         addChild(_mainPanel);

         // 如果已保存用户，预选
         _selectedUserID = _loginUserID;
         loadPlayerList();
      }

      private function drawMainPanelBg(w:int, h:int) : void
      {
         // 外层阴影
         var shadow:Shape = new Shape();
         shadow.graphics.beginFill(0x000000, 0.4);
         shadow.graphics.drawRoundRect(4, 4, w, h, 14, 14);
         shadow.graphics.endFill();
         _mainPanel.addChild(shadow);

         // 主背景 - 深色仿古纸
         var bg:Shape = new Shape();
         var colors:Array = [0x1A1020, 0x0F0A14];
         var alphas:Array = [1.0, 1.0];
         var ratios:Array = [0, 255];
         bg.graphics.beginFill(0x111122, 0.97);
         bg.graphics.drawRoundRect(0, 0, w, h, 14, 14);
         bg.graphics.endFill();

         // 金边外框
         bg.graphics.lineStyle(2.5, 0xD4A017);
         bg.graphics.drawRoundRect(0, 0, w, h, 14, 14);
         // 内框
         bg.graphics.lineStyle(1, 0x8B6914);
         bg.graphics.drawRoundRect(4, 4, w - 8, h - 8, 11, 11);
         _mainPanel.addChild(bg);

         // 顶部装饰线
         var decoTop:Shape = new Shape();
         decoTop.graphics.lineStyle(1, 0xD4A017, 0.6);
         decoTop.graphics.moveTo(20, 36); decoTop.graphics.lineTo(w - 20, 36);
         decoTop.graphics.lineStyle(1, 0xD4A017, 0.3);
         decoTop.graphics.moveTo(30, 37); decoTop.graphics.lineTo(w - 30, 37);
         _mainPanel.addChild(decoTop);
      }

      private function drawTitle(title:String) : void
      {
         var tf:TextField = new TextField();
         tf.defaultTextFormat = new TextFormat("_sans", 18, 0xD4A017, true);
         tf.text = "◇  " + title + "  ◇";
         tf.width = 300; tf.height = 30;
         tf.x = (330 - tf.textWidth) / 2 - 6;
         tf.y = 6;
         tf.selectable = false;
         tf.name = "_panelTitle";
         _mainPanel.addChild(tf);
      }

      private function drawPlayerList() : void
      {
         // 列表背景 - 仿竹简
         var listBg:Shape = new Shape();
         listBg.graphics.beginFill(0x0A0A16, 0.8);
         listBg.graphics.drawRoundRect(0, 0, 290, 170, 8, 8);
         listBg.graphics.endFill();
         listBg.graphics.lineStyle(1, 0x5C4010, 0.5);
         listBg.graphics.drawRoundRect(0, 0, 290, 170, 8, 8);
         listBg.x = 20; listBg.y = 44;
         listBg.name = "_listBg";
         _mainPanel.addChild(listBg);

         // 列标题
         var headerTF:TextField = new TextField();
         headerTF.defaultTextFormat = new TextFormat("_sans", 10, 0x8B7355);
         headerTF.text = "  头像       角色名               等级/金币              账号";
         headerTF.width = 280; headerTF.height = 16;
         headerTF.x = 24; headerTF.y = 46;
         headerTF.selectable = false;
         _mainPanel.addChild(headerTF);

         var loadingTF:TextField = new TextField();
         loadingTF.defaultTextFormat = new TextFormat("_sans", 12, 0x665533);
         loadingTF.text = "       — 正在请阅将士兵册... —";
         loadingTF.width = 280; loadingTF.height = 20;
         loadingTF.x = 22; loadingTF.y = 120;
         loadingTF.selectable = false;
         loadingTF.name = "_loadingTF";
         _mainPanel.addChild(loadingTF);
      }

      private function loadPlayerList() : void
      {
         var req:URLRequest = new URLRequest(Config.SERVER_URL + "/api/auth/players");
         req.method = URLRequestMethod.GET;
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE, function(e:Event):void {
            try {
               var data:Object = com.adobe.serialization.json.JSON.decode(loader.data as String);
               if(data.success) {
                  _playerList = data.data as Array;
                  renderPlayerList();
               }
            } catch(err:Error) {}
         });
         loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
            showStatus("无法连接服务器", 0xFF4444);
         });
         loader.load(req);
      }

      private function renderPlayerList() : void
      {
         for(var i:int = _mainPanel.numChildren - 1; i >= 0; i--) {
            var child:* = _mainPanel.getChildAt(i);
            if(child is Sprite && (child as Sprite).name == "_playerItem") {
               _mainPanel.removeChildAt(i);
            }
         }
         var lt:TextField = _mainPanel.getChildByName("_loadingTF") as TextField;
         if(lt) { _mainPanel.removeChild(lt); lt = null; }

         if(_playerList.length == 0) {
            showStatus("暂无将士，请招募新兵", 0x8B7355);
            return;
         }

         var yPos:int = 66;
         var maxShow:int = 5;
         for(var j:int = 0; j < _playerList.length && j < maxShow; j++) {
            var p:Object = _playerList[j];
            var item:Sprite = createPlayerItem(p, yPos, j);
            item.name = "_playerItem";
            _mainPanel.addChild(item);
            yPos += 34;
         }
      }

      private function createPlayerItem(p:Object, yPos:int, index:int) : Sprite
      {
         var sp:Sprite = new Sprite(); sp.name = "_playerItem";
         var selected:Boolean = (p.userID == _selectedUserID);

         // 行背景 - 仿竹简条纹
         var selBg:Shape = new Shape();
         if(selected) {
            selBg.graphics.beginFill(0x3A2810, 0.7);
            selBg.graphics.lineStyle(1, 0xD4A017, 0.6);
         } else {
            selBg.graphics.beginFill(0x1A1018, 0.4 + (index % 2) * 0.15);
         }
         selBg.graphics.drawRoundRect(0, 0, 288, 32, 3, 3);
         selBg.graphics.endFill();
         selBg.name = "_selBg";
         sp.addChild(selBg);

         // 头像背景小框
         var imgBg:Shape = new Shape();
         imgBg.graphics.beginFill(0x0A0A16);
         imgBg.graphics.drawRoundRect(0, 0, 28, 28, 4, 4);
         imgBg.graphics.endFill();
         imgBg.graphics.lineStyle(1, 0x5C4010, 0.5);
         imgBg.graphics.drawRoundRect(0, 0, 28, 28, 4, 4);
         imgBg.x = 4; imgBg.y = 2;
         sp.addChild(imgBg);

         var imgTF:TextField = new TextField();
         imgTF.defaultTextFormat = new TextFormat("_sans", 16, 0xD4A017, true);
         imgTF.text = String(p.imageID);
         imgTF.width = 28; imgTF.height = 22;
         imgTF.x = 4; imgTF.y = 6;
         imgTF.selectable = false;
         sp.addChild(imgTF);

         var nameTF:TextField = new TextField();
         nameTF.defaultTextFormat = new TextFormat("_sans", 13, 0xD4A017, true);
         nameTF.text = p.roleName;
         nameTF.width = 90; nameTF.height = 18;
         nameTF.x = 38; nameTF.y = 2;
         nameTF.selectable = false;
         sp.addChild(nameTF);

         var infoTF:TextField = new TextField();
         infoTF.defaultTextFormat = new TextFormat("_sans", 10, 0x8B7355);
         infoTF.text = "Lv." + p.level + "  金" + p.money;
         infoTF.width = 120; infoTF.height = 14;
         infoTF.x = 38; infoTF.y = 18;
         infoTF.selectable = false;
         sp.addChild(infoTF);

         var uidTF:TextField = new TextField();
         uidTF.defaultTextFormat = new TextFormat("_sans", 9, 0x4A3520);
         uidTF.text = p.userID;
         uidTF.width = 130; uidTF.height = 14;
         uidTF.x = 170; uidTF.y = 10;
         uidTF.selectable = false;
         sp.addChild(uidTF);

         sp.x = 22; sp.y = yPos;
         sp.buttonMode = true;
         sp.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            _selectedUserID = p.userID;
            if(_loginUserID != p.userID) { _loginPassword = ""; if(_passInputTF) _passInputTF.text = ""; }
            _loginUserID = p.userID;
            updatePlayerSelection();
            if(_passInputTF) stage.focus = _passInputTF;
         });
         return sp;
      }

      private function updatePlayerSelection() : void
      {
         for(var i:int = 0; i < _mainPanel.numChildren; i++) {
            var child:* = _mainPanel.getChildAt(i);
            if(child is Sprite && (child as Sprite).name == "_playerItem") {
               var selBg:Shape = (child as Sprite).getChildByName("_selBg") as Shape;
               if(selBg) { selBg.visible = false; }
            }
         }
         showStatus("◇ 选中: " + _loginUserID + "  |  请输入通关密令", 0xC8A020);
      }

      private function drawPasswordInput(w:int) : void
      {
         // 分隔线
         var sep:Shape = new Shape();
         sep.graphics.lineStyle(1, 0x5C4010, 0.4);
         sep.graphics.moveTo(20, 226); sep.graphics.lineTo(w - 20, 226);
         _mainPanel.addChild(sep);

         var pwFmt:TextFormat = new TextFormat("_sans", 13, 0xB8A080);
         var pwLabel:TextField = new TextField();
         pwLabel.defaultTextFormat = pwFmt;
         pwLabel.text = "密令:";
         pwLabel.width = 45; pwLabel.height = 24;
         pwLabel.x = 22; pwLabel.y = 234;
         pwLabel.selectable = false;
         _mainPanel.addChild(pwLabel);

         _passInputTF = new TextField();
         _passInputTF.type = TextFieldType.INPUT;
         _passInputTF.displayAsPassword = true;
         _passInputTF.defaultTextFormat = new TextFormat("_sans", 13, 0xD4C080);
         _passInputTF.backgroundColor = 0x0A0A16;
         _passInputTF.background = true;
         _passInputTF.border = true;
         _passInputTF.borderColor = 0x5C4010;
         _passInputTF.width = 145; _passInputTF.height = 24;
         _passInputTF.x = 68; _passInputTF.y = 234;
         _passInputTF.maxChars = 20;
         _passInputTF.text = _loginPassword;
         _passInputTF.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
            if(e.keyCode == 13) doLogin();
         });
         _mainPanel.addChild(_passInputTF);
      }

      private function drawLoginButton() : void
      {
         var btn:Sprite = makeThemedButton("入  营", 0x8B0000, 0xFF4444, 230, 232);
         btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { doLogin(); });
         _mainPanel.addChild(btn);
      }

      private function drawRegisterButton() : void
      {
         var btn:Sprite = makeThemedButton("招兵买马", 0x3A6010, 0x66AA22, 230, 268);
         btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { showRegisterPanel(); });
         _mainPanel.addChild(btn);

         _statusTF = new TextField();
         _statusTF.defaultTextFormat = new TextFormat("_sans", 10, 0x7A6A4A);
         _statusTF.text = "请选择将士，输入通关密令方可入营";
         _statusTF.width = 300; _statusTF.height = 16;
         _statusTF.x = 22; _statusTF.y = 310;
         _statusTF.selectable = false;
         _mainPanel.addChild(_statusTF);

         // 底部装饰线
         var decoB:Shape = new Shape();
         decoB.graphics.lineStyle(1, 0xD4A017, 0.4);
         decoB.graphics.moveTo(20, 305); decoB.graphics.lineTo(310, 305);
         _mainPanel.addChild(decoB);
      }

      private function makeThemedButton(label:String, darkColor:uint, lightColor:uint, x:Number, y:Number) : Sprite
      {
         var sp:Sprite = new Sprite();
         var w:int = 85; var h:int = 28;

         // 按钮底纹
         var btnBg:Shape = new Shape();
         btnBg.graphics.beginFill(darkColor);
         btnBg.graphics.drawRoundRect(0, 0, w, h, 8, 8);
         btnBg.graphics.endFill();
         btnBg.graphics.lineStyle(1.5, lightColor, 0.6);
         btnBg.graphics.drawRoundRect(0, 0, w, h, 8, 8);
         // 高光线
         btnBg.graphics.lineStyle(1, lightColor, 0.3);
         btnBg.graphics.drawRoundRect(1, 1, w - 2, h - 2, 7, 7);
         sp.addChild(btnBg);

         var tf:TextField = new TextField();
         tf.defaultTextFormat = new TextFormat("_sans", 13, 0xFFEEDD, true);
         tf.text = label;
         tf.width = w; tf.height = 22;
         tf.x = (w - tf.textWidth) / 2;
         tf.y = 4;
         tf.selectable = false;
         sp.addChild(tf);
         sp.x = x; sp.y = y;
         sp.buttonMode = true;
         return sp;
      }

      private function showStatus(msg:String, color:uint = 0xC8A020) : void
      {
         if(_statusTF) {
            _statusTF.text = msg;
            _statusTF.setTextFormat(new TextFormat("_sans", 10, color));
         }
      }

      /** 注册面板 */
      private function showRegisterPanel() : void
      {
         if(_mainPanel) { removeChild(_mainPanel); _mainPanel = null; }
         _isRegistering = true;
         _mainPanel = new Sprite();
         drawMainPanelBg(330, 340);
         drawTitle("招 兵 买 马");

         var tf:TextField; var y:Number = 50;
         var labelFmt:TextFormat = new TextFormat("_sans", 13, 0xB8A080);

         tf = makeLabel("军  号:", 22, y); _mainPanel.addChild(tf);
         var regUserTF:TextField = makeThemedInput(105, y, _loginUserID); _mainPanel.addChild(regUserTF); y += 34;

         tf = makeLabel("通关密令:", 22, y); _mainPanel.addChild(tf);
         var regPassTF:TextField = makeThemedInput(105, y, "", true); _mainPanel.addChild(regPassTF); y += 34;

         tf = makeLabel("将 军 名:", 22, y); _mainPanel.addChild(tf);
         var regNameTF:TextField = makeThemedInput(105, y, ""); _mainPanel.addChild(regNameTF); y += 34;

         tf = makeLabel("头  像:", 22, y); _mainPanel.addChild(tf);
         var regImageTF:TextField = makeThemedInput(105, y, "1"); _mainPanel.addChild(regImageTF); y += 44;

         // 分隔线
         var sep:Shape = new Shape();
         sep.graphics.lineStyle(1, 0x5C4010, 0.4);
         sep.graphics.moveTo(20, y - 8); sep.graphics.lineTo(310, y - 8);
         _mainPanel.addChild(sep);

         // 按钮
         var regBtn:Sprite = makeThemedButton("招募入营", 0x8B0000, 0xFF5555, 22, y);
         regBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            var uid:String = regUserTF.text.replace(/^\s+|\s+$/g, "");
            var pwd:String = regPassTF.text;
            var name:String = regNameTF.text.replace(/^\s+|\s+$/g, "");
            var img:int = int(regImageTF.text);
            if(uid == "" || name == "" || pwd == "") {
               showStatus("军号、密令、将军名 缺一不可!", 0xFF5555); return;
            }
            _loginUserID = uid; _loginPassword = pwd; saveConfig();
            removeChild(_mainPanel); _mainPanel = null;
            doRegister(name, img);
         });
         _mainPanel.addChild(regBtn);

         var backBtn:Sprite = makeThemedButton("返回营帐", 0x5A4010, 0x8B6914, 120, y);
         backBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            removeChild(_mainPanel); _mainPanel = null;
            _isRegistering = false; showLoginPanel();
         });
         _mainPanel.addChild(backBtn);

         _statusTF = new TextField();
         _statusTF.defaultTextFormat = new TextFormat("_sans", 10, 0x7A6A4A);
         _statusTF.text = "新兵登记，请填写军号密令";
         _statusTF.width = 300; _statusTF.height = 16;
         _statusTF.x = 22; _statusTF.y = 280;
         _statusTF.selectable = false;
         _mainPanel.addChild(_statusTF);

         // 底部装饰
         var decoB:Shape = new Shape();
         decoB.graphics.lineStyle(1, 0xD4A017, 0.3);
         decoB.graphics.moveTo(20, 275); decoB.graphics.lineTo(310, 275);
         _mainPanel.addChild(decoB);

         _mainPanel.x = (770 - 330) / 2;
         _mainPanel.y = (500 - 340) / 2 - 10;
         addChild(_mainPanel);
      }

      private function makeLabel(text:String, x:Number, y:Number) : TextField
      {
         var tf:TextField = new TextField();
         tf.defaultTextFormat = new TextFormat("_sans", 13, 0xB8A080);
         tf.text = text;
         tf.width = 80; tf.height = 24;
         tf.x = x; tf.y = y;
         tf.selectable = false;
         return tf;
      }

      private function makeThemedInput(x:Number, y:Number, defaultText:String, isPassword:Boolean = false) : TextField
      {
         var tf:TextField = new TextField();
         tf.type = TextFieldType.INPUT;
         tf.displayAsPassword = isPassword;
         tf.defaultTextFormat = new TextFormat("_sans", 13, 0xD4C080);
         tf.backgroundColor = 0x0A0A16;
         tf.background = true;
         tf.border = true;
         tf.borderColor = 0x5C4010;
         tf.width = 185; tf.height = 24;
         tf.x = x; tf.y = y;
         tf.maxChars = 20;
         tf.text = defaultText;
         return tf;
      }

      private function saveConfig() : void
      {
         try {
            var configFile:File = File.applicationStorageDirectory.resolvePath("user_config.txt");
            var fs:FileStream = new FileStream();
            fs.open(configFile, FileMode.WRITE);
            fs.writeUTFBytes(_loginUserID + ":" + _loginPassword);
            fs.close();
         } catch(e:Error) {}
      }

      private function doLogin() : void
      {
         if(_loginUserID == "") {
            showStatus("请先选择一个角色!", 0xFF4444);
            return;
         }
         if(_passInputTF) _loginPassword = _passInputTF.text;
         if(_loginPassword == "") {
            showStatus("请输入密码!", 0xFF4444);
            return;
         }
         saveConfig();
         // 面板在 sendLoginResponse 成功时移除

         var req:Object = {};
         req.head = Head.HTTP_NEW_LOGIN;
         req.agent = Config.AGENT;
         req.ver = Config.VER;
         req.userID = _loginUserID;
         req.password = _loginPassword;
         req.mask = true;
         AESController.getInstance().sendJSON(req, this.sendLoginResponse);
      }

      private function doRegister(roleName:String, imageID:int) : void
      {
         saveConfig();
         var req:Object = {};
         req.head = Head.HTTP_NEW_REGISTER;
         req.agent = Config.AGENT;
         req.ver = Config.VER;
         req.userID = _loginUserID;
         req.password = _loginPassword;
         req.roleName = roleName;
         req.imageID = imageID;
         req.mask = true;
         AESController.getInstance().sendJSON(req, this.createRoleResponse);
      }

      private function testServerConnection() : void
      {
         // 先本地文件写入测试 — 验证代码是否执行
         try {
            var testFile:File = File.applicationStorageDirectory.resolvePath("network_test.txt");
            var fs:FileStream = new FileStream();
            fs.open(testFile, FileMode.WRITE);
            fs.writeUTFBytes("Network test at " + new Date().toString() + "\nSERVER_URL=" + Config.SERVER_URL);
            fs.close();
            trace("[启动测试] 文件写入成功: " + testFile.nativePath);
         } catch(e:Error) {
            trace("[启动测试] 文件写入失败: " + e.message);
         }

         // HTTP 测试
         // HTTP POST test
         var testReq:URLRequest = new URLRequest("http://127.0.0.1:3000/api/health");
         testReq.method = URLRequestMethod.POST;
         testReq.contentType = "application/json";
         testReq.data = "{}";
         var testLoader:URLLoader = new URLLoader();
         testLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
            var fs2:FileStream = new FileStream();
            var f2:File = File.applicationStorageDirectory.resolvePath("http_success.txt");
            fs2.open(f2, FileMode.WRITE);
            fs2.writeUTFBytes("HTTP OK: " + testLoader.data);
            fs2.close();
         });
         testLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
            var fs3:FileStream = new FileStream();
            var f3:File = File.applicationStorageDirectory.resolvePath("http_error.txt");
            fs3.open(f3, FileMode.WRITE);
            fs3.writeUTFBytes("IOError: " + e.text + "\n" + e.toString());
            fs3.close();
         });
         testLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
            var fs4:FileStream = new FileStream();
            var f4:File = File.applicationStorageDirectory.resolvePath("http_security_error.txt");
            fs4.open(f4, FileMode.WRITE);
            fs4.writeUTFBytes("SecurityError: " + e.text);
            fs4.close();
         });
         try {
            testLoader.load(testReq);
            var fs5:FileStream = new FileStream();
            var f5:File = File.applicationStorageDirectory.resolvePath("http_sent.txt");
            fs5.open(f5, FileMode.WRITE);
            fs5.writeUTFBytes("Request sent to: http://localhost:3000/api/health");
            fs5.close();
         } catch(error:Error) {
            var fs6:FileStream = new FileStream();
            var f6:File = File.applicationStorageDirectory.resolvePath("http_exception.txt");
            fs6.open(f6, FileMode.WRITE);
            fs6.writeUTFBytes("Exception: " + error.message + "\n" + error.getStackTrace());
            fs6.close();
         }
      }

      private function initView() : *
      {
         this._ui = new UI();
         addChild(this._ui);
         this._tipsLayer = new Sprite();
         this._tipsLayer.mouseEnabled = false;
         addChild(this._tipsLayer);
         this._bar = new BarMC();
         this._bar.name = "bar";
         this._tipsLayer.addChild(this._bar);
         this.loadData();
      }
      
      private function initEvent() : *
      {
         addEventListener(UIEvent.NEW_GAME,this.onNewGameClickHandler);
         addEventListener(UIEvent.CONNECT_SERVER,this.onConnectServerClickHandler);
         addEventListener(UIEvent.CREATE_ROLE,this.createRoleHandler);
         addEventListener(UIEvent.SHOW_TIPS,this.onShowTipsHandler);
         addEventListener(UIEvent.HIDE_TIPS,this.onHideTipsHandler);
         addEventListener(SoldierEvent.TALK,this.onSoldierTalkHandler);
         stage.addEventListener(UIEvent.SERVER_SUCCESS,this.serverSuccessHandler);
         addEventListener(UIEvent.CREATE_GATE,this.createGateHandler);
         addEventListener(FightEvent.FIGHT_COMPLETE,this.fightCompleteHandler);
         addEventListener(FightEvent.CLOSE_FIGHT,this.closeFightHandler);
         addEventListener(FightEvent.P2P_FIGHT_COMPLETE,this.p2pFightCompleteHandler);
         addEventListener(FightEvent.CLOSE_P2P_FIGHT,this.closeP2PFightHandler);
         addEventListener(FightEvent.LEITAI_FIGHT_COMPLETE,this.leitaiFightCompleteHandler);
         addEventListener(FightEvent.CLOSE_LEITAI_FIGHT,this.closeLeitaiFightHandler);
         addEventListener(FightEvent.USE_AMMO,this.useAmmoHandler);
         addEventListener(SoundCode.GUNNER_ATTACK_SOUND,this.eventSoundHandler);
         addEventListener(SoundCode.WEAPON_SOUND,this.eventSoundHandler);
         addEventListener(SoundCode.SABER_WALK_SOUND,this.eventSoundHandler);
         addEventListener(SoundCode.SABER_ATTACK_SOUND,this.eventSoundHandler);
         addEventListener(SoundCode.SHOOTER_WALK_SOUND,this.eventSoundHandler);
         addEventListener(SoundCode.SHOOTER_ATTACK_SOUND,this.eventSoundHandler);
         addEventListener(SoundCode.SWORDER_ATTACK_SOUND,this.eventSoundHandler);
         addEventListener(SoundCode.BOSS_ATTACK_SOUND1,this.eventSoundHandler);
         addEventListener(SoundCode.BOSS_ATTACK_SOUND2,this.eventSoundHandler);
         stage.addEventListener("userLoginOut",this.onUserLogOutHandler,false,0,true);
         AESController.getInstance().addEventListener(ControllerEvent.ERROR,this.timeOutHandler);
      }
      
      private function loadData() : *
      {
         var _loc1_:XMLLoader = new XMLLoader("game.xml",{
            "name":"config",
            "estimatedBytes":5000000,
            "onInit":this.onInitHandler,
            "onProgress":this.onProgressHandler,
            "onComplete":this.xmlCompleteHandler,
            "onChildComplete":this.xmlChildCompleteHandler,
            "noCache":true
         });
         _loc1_.load();
      }
      
      private function onInitHandler(param1:LoaderEvent) : *
      {
         AESController.getInstance().serverURL = XML(param1.target.content).server.@url;
         AESController.getInstance().serverURL = XML(param1.target.content).server.@url;
         AESController.getInstance().requestCode = XML(param1.target.content).requestCode;
         AESController.getInstance().responseCode = XML(param1.target.content).responseCode;
         AESController.getInstance().setRoot(this,SkinCode.CONNECT_WAIT);
      }
      
      private function onProgressHandler(param1:LoaderEvent) : *
      {
         var _loc2_:int = int(param1.target.progress * 100);
         this._bar.tf.text = _loc2_ + "%";
         this._bar.bar.scaleX = param1.target.progress;
         this._bar.soldier.x = this._bar.bar.x + this._bar.bar.width;
      }
      
      private function xmlChildCompleteHandler(param1:LoaderEvent) : *
      {
         if(param1.target.name == "game01.data.talkFilter")
         {
            TextFilter.getInstance().setStr(LoaderMax.getContent("game01.data.talkFilter"));
         }
         else if(param1.target.name == "game01.data.general")
         {
            Data.getInstance().initGeneralXML(LoaderMax.getContent("game01.data.general"));
         }
         else if(param1.target.name == "game01.data.xishu")
         {
            Data.getInstance().initXishuXML(LoaderMax.getContent("game01.data.xishu"));
         }
         else if(param1.target.name == "game01.data.proto")
         {
            Data.getInstance().initProtoXML(LoaderMax.getContent("game01.data.proto"));
         }
         else if(param1.target.name == "game01.data.shop")
         {
            Data.getInstance().initShopXML(LoaderMax.getContent("game01.data.shop"));
         }
         else if(param1.target.name == "game01.data.stage")
         {
            Data.getInstance().initStageXML(LoaderMax.getContent("game01.data.stage"));
         }
         else if(param1.target.name == "game01.data.paoma")
         {
            Data.getInstance().initPaomaXML(LoaderMax.getContent("game01.data.paoma"));
         }
         else if(param1.target.name == "game01.data.tianfu")
         {
            Data.getInstance().initTianfuXML(LoaderMax.getContent("game01.data.tianfu"));
         }
      }
      
      private function xmlCompleteHandler(param1:LoaderEvent) : *
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterframeHandler);
         this._tipsLayer.removeChild(this._bar);
         this._bar = null;
         this._ui.addCover();
         MySound.getInstance().startByName(SoundCode.COVER,1);
         var _loc2_:Array = Capabilities.version.split(" ")[1].split(",");
         var _loc3_:Number = Number(_loc2_[0] + "." + _loc2_[1]);
         if(_loc3_ < 10.1)
         {
            this._ui.showMsg({
               "type":1,
               "text":"您的Flash版本太低，无法正常游戏。现在升级吗？",
               "fun":this.getNewPlayer
            });
         }
      }
      
      private function getNewPlayer() : *
      {
         navigateToURL(new URLRequest("http://www.adobe.com/go/getflashplayer"),"_self");
      }
      
      private function testResponse(param1:Object) : *
      {
         trace("接收完毕");
      }
      
      private function onNewGameClickHandler(param1:UIEvent) : *
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(DEBUG == true)
         {
            if(this._data == "")
            {
               this._ui.showMsg({
                  "type":0,
                  "text":"没有接收到数据无法进入游戏。"
               });
               return;
            }
            if(this._newPlayer == true)
            {
               this._ui.openCreateRolePanel(true);
            }
            else
            {
               _loc2_ = com.adobe.serialization.json.JSON.decode(this._data);
               Config.token = String(_loc2_.token);
               RoleModel.getInstance().initData(_loc2_);
               this._ui.openSelectServerPanel();
               this._data = "";
            }
            this._ui.createNewsInfoPanel();
         }
         else
         {
            _loc3_ = serviceHold ? serviceHold.isLog : null;
            if(_loc3_ == null)
            {
               if(serviceHold)
               {
                  stage.addEventListener("logreturn",this.loginHandler);
                  serviceHold.showLogPanel();
               }
               else
               {
                  getTestUserID();
                  // 始终显示角色选择面板
                  showLoginPanel();
               }
            }
            else
            {
               (_loc4_ = {}).head = Head.HTTP_NEW_LOGIN;
               _loc4_.agent = Config.AGENT;
               _loc4_.ver = Config.VER;
               _loc4_.userID = _loc3_.uid;
               _loc4_.mask = true;
               AESController.getInstance().sendJSON(_loc4_,this.sendLoginResponse);
            }
         }
      }
      
      private function loginHandler(param1:SaveEvent) : *
      {
         stage.removeEventListener("logreturn",this.loginHandler);
         var _loc2_:Object = {};
         switch(param1.type)
         {
            case "logreturn":
               _loc2_.head = Head.HTTP_NEW_LOGIN;
               _loc2_.agent = Config.AGENT;
               _loc2_.ver = Config.VER;
               _loc2_.userID = String(param1.ret.uid);
               _loc2_.mask = true;
               AESController.getInstance().sendJSON(_loc2_,this.sendLoginResponse);
         }
      }
      
      private function sendLoginResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            if(_mainPanel != null) { removeChild(_mainPanel); _mainPanel = null; }
            Config.token = param1.data.token;
            Config.ServerTime = param1.data.currentTime;
            if(int(param1.data.flag == 1))
            {
               RoleModel.getInstance().initData(param1.data);
               this._ui.removeCover();
               this._ui.addMap();
               MySound.getInstance().startByName(SoundCode.MAP);
            }
            else if(int(param1.data.flag == 2))
            {
               this._newPlayer = true;
               this._ui.openCreateRolePanel(false);
               this._ui.createNewsInfoPanel();
            }
            else if(int(param1.data.flag == 3))
            {
               this._ui.showMsg({
                  "type":0,
                  "skin":"uiSkin_Alert4",
                  "text":"本游戏已更新至最新版本,您原有的帐号需要升级才能正常进入游戏,升级帐号不影响原有存档.",
                  "fun":this.sendActiveAct
               });
            }
         }
         else
         {
            if(_mainPanel == null) showLoginPanel();
            showStatus(param1.message || "登录失败，请检查密码", 0xFF4444);
         }
      }
      
      private function sendActiveAct() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_ACTIVE;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.userID = serviceHold.isLog.uid;
         _loc1_.mask = true;
         AESController.getInstance().sendJSON(_loc1_,this.activeResponse);
      }
      
      private function activeResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            this._ui.showMsg({
               "type":0,
               "text":"帐号升级成功,您可以正常进入游戏了.",
               "fun":this.reLogin,
               "skin":"uiSkin_Alert4"
            });
         }
         else
         {
            this._ui.showMsg({
               "type":0,
               "text":param1.message
            });
         }
      }
      
      private function reLogin() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_LOGIN;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.userID = serviceHold.isLog.uid;
         _loc1_.mask = true;
         AESController.getInstance().sendJSON(_loc1_,this.sendLoginResponse);
      }
      
      private function createRoleHandler(param1:UIEvent) : *
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Object = {};
         if(DEBUG == true)
         {
            _loc2_ = com.adobe.serialization.json.JSON.decode(this._data);
            this._data = "";
            _loc4_.head = Head.HTTP_NEW_REGISTER;
            _loc4_.agent = Config.AGENT;
            _loc4_.ver = Config.VER;
            _loc4_.token = _loc2_.token;
            _loc4_.userID = _loc2_.userID;
            _loc4_.roleName = param1.data.nickName;
            _loc4_.imageID = param1.data.image;
            _loc4_.mask = true;
            AESController.getInstance().sendJSON(_loc4_,this.createRoleResponse);
         }
         else
         {
            _loc3_ = serviceHold ? serviceHold.isLog : null;
            if(_loc3_ != null)
            {
               _loc4_.head = Head.HTTP_NEW_REGISTER;
               _loc4_.agent = Config.AGENT;
               _loc4_.ver = Config.VER;
               _loc4_.token = Config.token;
               _loc4_.userID = _loc3_.uid;
               _loc4_.roleName = param1.data.nickName;
               _loc4_.imageID = param1.data.image;
               _loc4_.mask = true;
               AESController.getInstance().sendJSON(_loc4_,this.createRoleResponse);
            }
            else if(serviceHold)
            {
               this._ui.showMsg({
                  "type":0,
                  "text":"未知错误，请重新刷新页面后重新登录",
                  "fun":this.flushPage
               });
            }
            else
            {
               // 测试模式：使用默认用户ID注册
               trace("无4399平台，使用测试用户注册");
               _loc4_.head = Head.HTTP_NEW_REGISTER;
               _loc4_.agent = Config.AGENT;
               _loc4_.ver = Config.VER;
               _loc4_.token = Config.token;
               _loc4_.userID = getTestUserID();
               _loc4_.password = _loginPassword;
               _loc4_.roleName = param1.data.nickName;
               _loc4_.imageID = param1.data.image;
               _loc4_.mask = true;
               AESController.getInstance().sendJSON(_loc4_,this.createRoleResponse);
            }
         }
      }
      
      private function createRoleResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            this._ui.closeCreateRolePanel();
            Config.token = param1.data.token;
            RoleModel.getInstance().initData(param1.data);
            this._ui.openSelectServerPanel(true);
         }
         else
         {
            this._ui.showMsg({
               "type":0,
               "text":param1.message
            });
         }
      }
      
      private function onConnectServerClickHandler(param1:UIEvent) : *
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(DEBUG == true)
         {
            if(this._data == "")
            {
               this._ui.showMsg({
                  "type":0,
                  "text":"没有接收到数据无法进入游戏。"
               });
               return;
            }
            if(this._newPlayer == true)
            {
               this._ui.showMsg({
                  "type":0,
                  "text":"你需要先创建游戏人物，领取武将后才能进入联机对战平台。",
                  "fun":this.renewGame
               });
            }
            else
            {
               this._netDirect = true;
               _loc2_ = com.adobe.serialization.json.JSON.decode(this._data);
               Config.token = _loc2_.token;
               RoleModel.getInstance().initData(_loc2_);
               this._ui.openSelectServerPanel();
               this._data = "";
            }
            this._ui.createNewsInfoPanel();
         }
         else
         {
            _loc3_ = serviceHold ? serviceHold.isLog : null;
            if(_loc3_ == null)
            {
               if(serviceHold)
               {
                  stage.addEventListener("logreturn",this.login2Handler);
                  serviceHold.showLogPanel();
               }
               else
               {
                  // 使用配置文件中的账号密码登录
                  trace("使用配置文件账号登录(联网): " + _loginUserID);
                  (_loc4_ = {}).head = Head.HTTP_NEW_LOGIN;
                  _loc4_.agent = Config.AGENT;
                  _loc4_.ver = Config.VER;
                  _loc4_.userID = getTestUserID();
                  _loc4_.password = _loginPassword;
                  _loc4_.mask = true;
                  AESController.getInstance().sendJSON(_loc4_,this.sendLoginDirectNetResponse);
               }
            }
            else
            {
               (_loc4_ = {}).head = Head.HTTP_NEW_LOGIN;
               _loc4_.agent = Config.AGENT;
               _loc4_.ver = Config.VER;
               _loc4_.userID = _loc3_.uid;
               _loc4_.mask = true;
               AESController.getInstance().sendJSON(_loc4_,this.sendLoginDirectNetResponse);
            }
         }
      }
      
      private function login2Handler(param1:SaveEvent) : *
      {
         stage.removeEventListener("logreturn",this.login2Handler);
         var _loc2_:Object = {};
         switch(param1.type)
         {
            case "logreturn":
               _loc2_.head = Head.HTTP_NEW_LOGIN;
               _loc2_.agent = Config.AGENT;
               _loc2_.ver = Config.VER;
               _loc2_.userID = String(param1.ret.uid);
               _loc2_.mask = true;
               AESController.getInstance().sendJSON(_loc2_,this.sendLoginDirectNetResponse);
         }
      }
      
      private function sendLoginDirectNetResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            Config.token = param1.data.token;
            if(int(param1.data.flag == 1))
            {
               this._netDirect = true;
               RoleModel.getInstance().initData(param1.data);
               this._ui.openSelectServerPanel();
               this._ui.createNewsInfoPanel();
            }
            else if(int(param1.data.flag == 2))
            {
               this._newPlayer = true;
               this._ui.showMsg({
                  "type":0,
                  "text":"你需要先创建游戏人物，领取武将后才能进入联机对战平台。",
                  "fun":this.renewGame
               });
            }
            else if(int(param1.data.flag == 3))
            {
               this._ui.showMsg({
                  "type":0,
                  "skin":"uiSkin_Alert4",
                  "text":"本游戏已更新至最新版本,您原有的帐号需要升级才能正常进入游戏,升级帐号不影响原有存档.",
                  "fun":this.sendActiveAct
               });
            }
         }
         else
         {
            this._ui.showMsg({
               "type":0,
               "text":param1.message
            });
         }
      }
      
      private function renewGame() : *
      {
         this._ui.openCreateRolePanel(false);
         this._ui.createNewsInfoPanel();
      }
      
      public function newGame(param1:String) : *
      {
         this._data = param1;
         this._newPlayer = true;
         this.initView();
         this.initEvent();
      }
      
      public function loadGame(param1:String) : *
      {
         this._data = param1;
         trace("检查输出的数据:\n" + this._data);
         this.initView();
         this.initEvent();
      }
      
      private function serverSuccessHandler(param1:UIEvent) : *
      {
         if(param1.data.newPlayer == false)
         {
            this.enterGame();
         }
         else
         {
            this._ui.startGameAsNewPlayer();
         }
      }
      
      private function enterGame() : *
      {
         this._ui.removeCover();
         this._ui.addMap();
         MySound.getInstance().startByName(SoundCode.MAP);
         if(this._netDirect)
         {
            this._netDirect = false;
            this._ui.onConnectServerBtnClickHandler(null);
         }
      }
      
      private function onShowTipsHandler(param1:UIEvent) : void
      {
         if(this._tips == null)
         {
            this._tips = new TipsFrame();
         }
         this._tips.initData(param1.data);
         this._tips.addEventListener(Event.ENTER_FRAME,this.onTipsEnterFrameHandler);
         this._tipsLayer.addChild(this._tips);
      }
      
      private function onHideTipsHandler(param1:UIEvent) : void
      {
         if(this._tips != null)
         {
            this._tips.removeEventListener(Event.ENTER_FRAME,this.onTipsEnterFrameHandler);
            if(this._tipsLayer.contains(this._tips))
            {
               this._tipsLayer.removeChild(this._tips);
            }
         }
      }
      
      private function onTipsEnterFrameHandler(param1:Event) : *
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:int;
         if((_loc4_ = int(param1.currentTarget.type)) == 1)
         {
            this._tips.x = mouseX - this._tips.width / 2;
            this._tips.y = mouseY - this._tips.height - 10;
         }
         else if(_loc4_ == 2)
         {
            this._tips.x = mouseX - this._tips.width / 2;
            this._tips.y = mouseY + this._tips.height - 5;
         }
         else
         {
            _loc2_ = mouseX + 12;
            _loc3_ = mouseY;
            if(_loc3_ + this._tips.height > stage.stageHeight)
            {
               _loc3_ -= this._tips.height;
            }
            if(_loc2_ + this._tips.width > stage.stage.stageWidth)
            {
               _loc2_ = _loc2_ - this._tips.width - 15;
            }
            this._tips.x = _loc2_;
            this._tips.y = _loc3_;
         }
      }
      
      private function onSoldierTalkHandler(param1:SoldierEvent) : *
      {
         var _loc2_:TalkFrame = new TalkFrame(SkinCode.TALK_FRAME);
         _loc2_.x = param1.data.point.x;
         _loc2_.y = param1.data.point.y;
         _loc2_.initData(param1.data);
         this._tipsLayer.addChild(_loc2_);
      }
      
      private function newPart(param1:int) : Boolean
      {
         switch(param1)
         {
            case 1:
               this._ui.showMsg({
                  "type":1,
                  "text":"新剧情“洛阳兵变”已经开启，你可以开始新的征程了。",
                  "fun":this.saveHistory
               });
               return true;
            case 2:
               this._ui.showMsg({
                  "type":1,
                  "text":"新剧情“群雄逐鹿”已经开启，你可以开始新的征程了。",
                  "fun":this.saveHistory
               });
               return true;
            case 3:
               this._ui.showMsg({
                  "type":1,
                  "text":"新剧情“赤壁之战”已经开启，你可以开始新的征程了。",
                  "fun":this.saveHistory
               });
               return true;
            case 4:
               this._ui.showMsg({
                  "type":1,
                  "text":"新剧情“鏖战三国”已经开启，你可以开始新的征程了。",
                  "fun":this.saveHistory
               });
               return true;
            case 5:
               this._ui.showMsg({
                  "type":1,
                  "text":"新剧情“奇袭蜀中”已经开启，你可以开始新的征程了。",
                  "fun":this.saveHistory
               });
               return true;
            case 6:
               this._ui.showMsg({
                  "type":1,
                  "text":"新剧情“进军东吴”已经开启，你可以开始新的征程了。",
                  "fun":this.saveHistory
               });
               return true;
            case 7:
               this._ui.showMsg({
                  "type":1,
                  "text":"新剧情“马踏中原”已经开启，你可以开始新的征程了。",
                  "fun":this.saveHistory
               });
               return true;
            case 8:
               this._ui.showMsg({
                  "type":1,
                  "text":"挑战关卡——试炼之地已经开启，你可以开始试炼之路了。",
                  "fun":this.saveHistory
               });
               return true;
            case 9:
               this._ui.showMsg({
                  "type":1,
                  "text":"新剧情“外敌入侵”已经开启，你可以开始新的征程了。",
                  "fun":this.saveHistory
               });
               return true;
            case 10:
               this._ui.showMsg({
                  "type":1,
                  "text":"恭喜你完成了“外敌入侵”挑战，敬请继续期待后续关卡。",
                  "fun":this.saveHistory
               });
               return false;
            default:
               return false;
         }
      }
      
      private function saveHistory() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_SAVE_HISTORY;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         _loc1_.history = RoleModel.getInstance().makeHistory();
         _loc1_.mask = true;
         AESController.getInstance().sendJSON(_loc1_,this.saveHistoryResponse);
      }
      
      private function saveHistoryResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            RoleModel.getInstance().importHistory(param1.data.history);
         }
         else
         {
            this._ui.showMsg({
               "type":0,
               "text":param1.message
            });
         }
      }
      
      private function createGateHandler(param1:UIEvent) : *
      {
         if(this._fight != null)
         {
            this._ui.removeChild(this._fight);
         }
         this._fight = new Fight(RoleModel.getInstance().getChooseSoldiers(),Data.getInstance().getGateArmys(param1.data.part,param1.data.level));
         RoleModel.getInstance().status = RoleStatus.GUANKA;
         this._ui.addChild(this._fight);
         MySound.getInstance().startByName(SoundCode.FIGHT);
         this._fight.setPartAndLevel(int(param1.data.part),int(param1.data.level));
         this._fight.startAI(5000,-1);
      }
      
      private function fightCompleteHandler(param1:FightEvent) : *
      {
         var _loc2_:Object = null;
         MySound.getInstance().stop(SoundCode.FIGHT);
         var _loc3_:Object = {};
         var _loc4_:String = Data.getInstance().getStageName(param1.target.part,param1.target.level);
         _loc3_.flag = param1.data.flag;
         _loc3_.part = param1.target.part;
         _loc3_.level = param1.target.level;
         _loc3_.p2p = false;
         _loc3_.stageName = _loc4_;
         ++Cache.getInstance().fightCount;
         if(param1.data.flag == "lost")
         {
            this._ui.showFightResult(_loc3_);
            MySound.getInstance().startEventSoundByName(SoundCode.LOST);
            if(Cache.getInstance().fightCount >= Cache.MAX_FIGHT_COUNT)
            {
               this._ui.openYanzhengmaPanel();
               Cache.getInstance().fightCount = 0;
            }
         }
         else
         {
            _loc2_ = {};
            _loc2_.head = Head.HTTP_NEW_FIGHT_RESULT;
            _loc2_.agent = Config.AGENT;
            _loc2_.ver = Config.VER;
            _loc2_.token = Config.token;
            _loc2_.roleID = RoleModel.getInstance().roleID;
            _loc2_.userID = RoleModel.getInstance().userID;
            _loc2_.part = param1.target.part;
            _loc2_.level = param1.target.level;
            _loc2_.m = param1.data.m;
            _loc2_.n = param1.data.n;
            _loc2_.mask = true;
            AESController.getInstance().sendJSON(_loc2_,this.fightResultResponse);
         }
      }
      
      private function fightResultResponse(param1:Object) : *
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:ArmyInfo = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         if(param1.success == true)
         {
            RoleModel.getInstance().money = int(param1.data.m);
            RoleModel.getInstance().exploit = int(param1.data.e);
            RoleModel.getInstance().reverence = int(param1.data.r);
            RoleModel.getInstance().importFinished(param1.data.finished);
            _loc2_ = int(param1.data.level);
            if(_loc2_ > RoleModel.getInstance().level)
            {
               RoleModel.getInstance().level = _loc2_;
            }
            if(param1.data.part == 9)
            {
               _loc3_ = TextFactory.makeStageStr(RoleModel.getInstance().roleName,_loc2_);
               this._ui.dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                  "type":NetInfoType.SYSTEM,
                  "text":_loc3_
               }));
            }
            else if(param1.data.part == 10)
            {
               _loc3_ = TextFactory.makeDixi(RoleModel.getInstance().roleName,_loc2_);
               this._ui.dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                  "type":NetInfoType.SYSTEM,
                  "text":_loc3_
               }));
            }
            (_loc4_ = {}).money = param1.data.money;
            _loc4_.exploit = param1.data.exploit;
            _loc4_.reverence = param1.data.reverence;
            _loc4_.p2p = false;
            _loc4_.flag = "win";
            _loc4_.part = param1.data.part;
            _loc4_.level = param1.data.level;
            _loc4_.stageName = Data.getInstance().getStageName(param1.data.part,param1.data.level);
            trace("得到了基本收益");
            if(param1.data.award != null)
            {
               trace("准备附加收益");
               _loc4_.addition = {};
               _loc4_.addition.money = param1.data.award.money;
               _loc4_.addition.exploit = param1.data.award.exploit;
               _loc4_.addition.reverence = param1.data.award.reverence;
               trace("收益");
               if(param1.data.award.soldier.length > 0)
               {
                  _loc4_.addition.soldier = [];
                  _loc5_ = 0;
                  while(_loc5_ < param1.data.award.soldier.length)
                  {
                     trace("添加武将");
                     _loc6_ = String(param1.data.award.soldier[_loc5_].code);
                     (_loc7_ = Data.getInstance().getArmyInfo(_loc6_,1)).id = param1.data.award.soldier[_loc5_].id;
                     RoleModel.getInstance().addSoldier(_loc7_);
                     _loc4_.addition.soldier.push(_loc6_);
                     _loc5_++;
                  }
               }
               if(param1.data.award.item.length > 0)
               {
                  _loc4_.addition.proto = [];
                  _loc8_ = 0;
                  while(_loc8_ < param1.data.award.item.length)
                  {
                     _loc9_ = int(param1.data.award.item[_loc8_].count) - RoleModel.getInstance().getBagItemCount(param1.data.award.item[_loc8_].code);
                     RoleModel.getInstance().modiBagItem(param1.data.award.item[_loc8_].id,param1.data.award.item[_loc8_].code,param1.data.award.item[_loc8_].count);
                     _loc4_.addition.proto.push(param1.data.award.item[_loc8_].code + ":" + _loc9_);
                     _loc8_++;
                  }
               }
               _loc4_.addition.recruit = param1.data.award.recruit;
            }
            this._ui.showFightResult(_loc4_);
            MySound.getInstance().startEventSoundByName(SoundCode.WIN);
            this.newPart(RoleModel.getInstance().checkHistory());
            if(Cache.getInstance().fightCount >= Cache.MAX_FIGHT_COUNT)
            {
               this._ui.openYanzhengmaPanel();
               Cache.getInstance().fightCount = 0;
            }
            RoleModel.getInstance().throttleSave();
         }
         else
         {
            trace("看你有没有处理");
            this._ui.showMsg({
               "type":0,
               "text":param1.message
            });
         }
      }
      
      private function closeFightHandler(param1:FightEvent) : *
      {
         this._ui.removeChild(this._fight);
         this._fight = null;
         RoleModel.getInstance().status = RoleStatus.DANJI;
      }
      
      private function p2pFightCompleteHandler(param1:FightEvent) : *
      {
         if(this._ui.fightResult() == true)
         {
            return;
         }
         MySound.getInstance().stop(SoundCode.P2PFIGHT);
         var _loc2_:Object = {};
         _loc2_.head = Head.HTTP_NEW_P2PFIGHT_RESULT;
         _loc2_.agent = Config.AGENT;
         _loc2_.ver = Config.VER;
         _loc2_.token = Config.token;
         _loc2_.roleID = RoleModel.getInstance().roleID;
         _loc2_.userID = RoleModel.getInstance().userID;
         _loc2_.m = param1.data.m;
         _loc2_.n = param1.data.n;
         _loc2_.relativeName = param1.data.relativeName;
         if(param1.data.flag == "lost")
         {
            _loc2_.flag = 0;
         }
         else if(param1.data.flag == "win")
         {
            _loc2_.flag = 1;
         }
         else
         {
            _loc2_.flag = -1;
            _loc2_.m = 0;
            _loc2_.n = 0;
         }
         _loc2_.mask = true;
         AESController.getInstance().sendJSON(_loc2_,this.p2pFightResultResponse);
      }
      
      private function p2pFightResultResponse(param1:Object) : *
      {
         var _loc2_:Object = null;
         if(param1.success == true)
         {
            _loc2_ = {};
            _loc2_.money = param1.data.money - RoleModel.getInstance().money;
            _loc2_.exploit = param1.data.exploit - RoleModel.getInstance().exploit;
            _loc2_.reverence = param1.data.reverence - RoleModel.getInstance().reverence;
            RoleModel.getInstance().money = param1.data.money;
            RoleModel.getInstance().exploit = param1.data.exploit;
            RoleModel.getInstance().reverence = param1.data.reverence;
            RoleModel.getInstance().winCount = param1.data.winCount;
            RoleModel.getInstance().lostCount = param1.data.lostCount;
            _loc2_.p2p = true;
            _loc2_.relativeName = param1.data.relativeName;
            if(param1.data.flag == 1)
            {
               _loc2_.flag = "win";
               this._ui.showFightResult(_loc2_);
               MySound.getInstance().startEventSoundByName(SoundCode.WIN);
            }
            else if(param1.data.flag == 0)
            {
               _loc2_.flag = "lost";
               this._ui.showFightResult(_loc2_);
               MySound.getInstance().startEventSoundByName(SoundCode.LOST);
            }
            else
            {
               _loc2_.flag = "offLine";
               this._ui.showFightResult(_loc2_);
               MySound.getInstance().startEventSoundByName(SoundCode.WIN);
            }
         }
         else
         {
            this._ui.showMsg({
               "type":0,
               "text":param1.message
            });
         }
      }
      
      private function closeP2PFightHandler(param1:FightEvent) : *
      {
         var _loc2_:ByteArray = null;
         this._ui.removeP2PFight();
         this._ui.closeFightResultPanel();
         ChatManager.getInstance().farID = null;
         ChatManager.getInstance().recievedClose();
         if(this._ui.isDanji() == true)
         {
            RoleModel.getInstance().status = RoleStatus.DANJI;
         }
         else
         {
            RoleModel.getInstance().status = RoleStatus.NOMAL;
            if(this._ui.gameCenterOpened() == true)
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
      
      private function useAmmoHandler(param1:FightEvent) : *
      {
         var _loc2_:Object = {};
         if(param1.data.id != -1)
         {
            _loc2_.head = Head.HTTP_NEW_USE_AMMO;
            _loc2_.agent = Config.AGENT;
            _loc2_.ver = Config.VER;
            _loc2_.token = Config.token;
            _loc2_.roleID = RoleModel.getInstance().roleID;
            _loc2_.userID = RoleModel.getInstance().userID;
            _loc2_.id = param1.data.id;
            AESController.getInstance().sendJSON(_loc2_,this.useAmmoResponse);
         }
      }
      
      private function useAmmoResponse(param1:Object) : *
      {
         if(param1.success != true)
         {
            this._ui.showMsg({
               "type":0,
               "text":param1.message
            });
         }
      }
      
      private function eventSoundHandler(param1:Event) : *
      {
         MySound.getInstance().startEventSoundByName(param1.type);
      }
      
      private function onUserLogOutHandler(param1:SaveEvent) : *
      {
         this._ui.showMsg({
            "type":0,
            "text":"你已经退出登录，请重新刷新页面后重新登录",
            "fun":this.flushPage
         });
      }
      
      private function flushPage() : *
      {
         navigateToURL(new URLRequest(Config.GAME_URL),"_self");
      }
      
      private function timeOutHandler(param1:ControllerEvent) : *
      {
         this._ui.showMsg({
            "type":0,
            "text":param1.data.text,
            "fun":this.flushPage
         });
      }
      
      private function heartBeatFun() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_LEITAI_HEARTBEAT;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         _loc1_.pID = ChatManager.getInstance().peerID;
         AESController.getInstance().sendJSONToURL(_loc1_);
      }
      
      private function heartBeatResponse(param1:Object) : *
      {
         if(param1.success != true)
         {
            this._ui.showMsg({
               "type":0,
               "text":param1.message
            });
         }
      }
      
      private function leitaiFightCompleteHandler(param1:FightEvent) : *
      {
         var _loc2_:Object = null;
         if(this._ui.leitaiFightResult() == true)
         {
            return;
         }
         MySound.getInstance().stop(SoundCode.P2PFIGHT);
         trace(RoleModel.getInstance().userID,"收到擂台结束");
         var _loc3_:Object = {};
         _loc3_.head = Head.HTTP_NEW_LEITAI_FIGHTOVER;
         _loc3_.agent = Config.AGENT;
         _loc3_.ver = Config.VER;
         _loc3_.token = Config.token;
         _loc3_.roleID = RoleModel.getInstance().roleID;
         _loc3_.userID = RoleModel.getInstance().userID;
         _loc3_.rID = this._ui.getLeitaiID();
         _loc3_.relativeName = param1.data.relativeName;
         if(param1.data.leizhu == true)
         {
            _loc3_.flag = 1;
         }
         else
         {
            _loc3_.flag = 2;
         }
         if(param1.data.flag == "win")
         {
            trace("擂台战斗结束",RoleModel.getInstance().userID,"赢了");
            _loc3_.win = 1;
            _loc3_.mask = true;
            AESController.getInstance().sendJSON(_loc3_,this.leitaiFightResponse);
         }
         else if(param1.data.flag == "offLine")
         {
            _loc3_.win = 2;
            _loc3_.mask = true;
            AESController.getInstance().sendJSON(_loc3_,this.leitaiFightResponse);
         }
         else
         {
            trace("擂台战斗结束",RoleModel.getInstance().userID,"输了");
            _loc2_ = {};
            _loc2_.leizhu = param1.data.leizhu;
            _loc2_.flag = 0;
            this._ui.openLeitaiResult(_loc2_);
            MySound.getInstance().startEventSoundByName(SoundCode.LOST);
         }
      }
      
      private function leitaiFightResponse(param1:Object) : *
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         trace(RoleModel.getInstance().userID,"接收到擂台结果反馈");
         if(param1.success == true)
         {
            _loc2_ = {};
            _loc2_.leizhu = ChatManager.getInstance().leizhu;
            _loc2_.flag = param1.data.win;
            _loc2_.relativeName = param1.data.relativeName;
            _loc3_ = param1.data.money - RoleModel.getInstance().money;
            _loc4_ = param1.data.exploit - RoleModel.getInstance().exploit;
            _loc5_ = param1.data.dianka - RoleModel.getInstance().dianka;
            _loc6_ = param1.data.rongyu - RoleModel.getInstance().rongyu;
            _loc2_.rongyu = _loc6_;
            RoleModel.getInstance().money = param1.data.money;
            RoleModel.getInstance().exploit = param1.data.exploit;
            RoleModel.getInstance().dianka = param1.data.dianka;
            RoleModel.getInstance().rongyu = param1.data.rongyu;
            this._ui.flushLeitai(param1.data);
            if(_loc5_ > 0)
            {
               _loc2_.value = _loc5_;
            }
            else if(_loc4_ > 0)
            {
               _loc2_.value = _loc4_;
            }
            else if(_loc3_ > 0)
            {
               _loc2_.value = _loc3_;
            }
            _loc7_ = 0;
            while(_loc7_ < param1.data.leitai.length)
            {
               if(param1.data.rID == param1.data.leitai[_loc7_].rID)
               {
                  _loc2_.leitai = param1.data.leitai[_loc7_];
                  break;
               }
               _loc7_++;
            }
            this._ui.removeP2PFight();
            this._ui.openLeitaiResult(_loc2_);
            MySound.getInstance().startEventSoundByName(SoundCode.WIN);
            ChatManager.getInstance().farID = null;
            ChatManager.getInstance().recievedClose();
            RoleModel.getInstance().status = RoleStatus.LEITAI;
            ChatManager.getInstance().leitaiMode = true;
            ChatManager.getInstance().leizhu = true;
         }
         else
         {
            this._ui.removeP2PFight();
            this._ui.showMsg({
               "type":0,
               "text":param1.message
            });
         }
      }
      
      private function closeLeitaiFightHandler(param1:FightEvent) : *
      {
         trace("关闭擂台结果页面");
         this._ui.removeP2PFight();
         this._ui.closeLeitaiResult();
         this._ui.leitaiFlushFun();
         ChatManager.getInstance().farID = null;
         ChatManager.getInstance().recievedClose();
         RoleModel.getInstance().status = RoleStatus.LEITAI_DATING;
         ChatManager.getInstance().leitaiMode = false;
         ChatManager.getInstance().leizhu = true;
      }
   }
}
