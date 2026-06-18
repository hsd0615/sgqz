package game.ui
{
   import com.iflashigame.controller.AESController;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLLoaderDataFormat;
   import flash.utils.ByteArray;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import game.Config;

   public class UpdateChecker extends Sprite
   {

      private var _infoTF:TextField;
      private var _downloading:Boolean = false;
      private var _appDir:String = "";
      private var _expectedVersion:String = "";

      public function UpdateChecker()
      {
         super();
         this.checkVersion();
      }

      private function checkVersion() : void
      {
         var _loader:URLLoader = new URLLoader();
         var _req:URLRequest = new URLRequest(AESController.getInstance().serverURL + "/api/version");
         _req.method = URLRequestMethod.POST;
         _req.contentType = "application/json";
         _req.data = "{}";
         var _self:UpdateChecker = this;
         _loader.addEventListener(Event.COMPLETE, function(param1:Event):void {
            try {
               var _json:Object = JSON.parse(_loader.data as String);
               if(_json.success && _json.version && _json.version != Config.CLIENT_VER) {
                  _self._expectedVersion = _json.version;
                  _self.showUpdatePrompt(_json.version);
               }
            } catch(_e:Error) {}
         });
         _loader.load(_req);
      }

      private function showUpdatePrompt(param1:String) : void
      {
         this.graphics.clear();
         this.graphics.beginFill(0x1a1008, 0.92);
         this.graphics.lineStyle(1.5, 0xFF8800, 0.9);
         this.graphics.drawRoundRect(0, 0, 200, 28, 6, 6);
         this.graphics.endFill();

         this._infoTF = new TextField();
         this._infoTF.defaultTextFormat = new TextFormat("SimSun", 10, 0xFFD700);
         this._infoTF.text = "新版本 v" + param1 + "! 点击自动更新";
         this._infoTF.autoSize = TextFieldAutoSize.LEFT;
         this._infoTF.selectable = false;
         this._infoTF.x = 10; this._infoTF.y = 6; this._infoTF.width = 190;
         addChild(this._infoTF);
         this.buttonMode = true; this.mouseChildren = false;
         var _self:UpdateChecker = this;
         this.addEventListener(flash.events.MouseEvent.CLICK, function(p:*):void { _self.startDownload(); });
      }

      private function startDownload() : void
      {
         if(this._downloading) return;
         this._downloading = true;
         this._infoTF.text = "正在验证版本...";

         // 先下载版本文件，确认服务端 SWF 版本与 /api/version 一致
         var _self:UpdateChecker = this;
         var _verLoader:URLLoader = new URLLoader();
         var _verReq:URLRequest = new URLRequest(AESController.getInstance().serverURL + "/client/version");
         _verReq.method = URLRequestMethod.GET;
         _verLoader.addEventListener(Event.COMPLETE, function(p:*):void {
            var _serverSWFVersion:String = "";
            try {
               _serverSWFVersion = (_verLoader.data as String).replace(/^\s+|\s+$/g, "");
            } catch(_e:Error) {}

            if(_serverSWFVersion && _serverSWFVersion == _self._expectedVersion) {
               // 版本确认一致，开始下载 SWF
               _self._infoTF.text = "正在下载...";
               _self.downloadSWF();
            } else if(_serverSWFVersion) {
               _self._infoTF.text = "版本异常! 服务:" + _self._expectedVersion + " 文件:" + _serverSWFVersion;
               _self._downloading = false;
            } else {
               // 版本文件不存在(老服务器)，直接下载 SWF
               _self._infoTF.text = "正在下载...";
               _self.downloadSWF();
            }
         });
         _verLoader.addEventListener(IOErrorEvent.IO_ERROR, function(p:*):void {
            // 版本文件不存在(老服务器)，直接下载 SWF 兼容
            _self._infoTF.text = "正在下载...";
            _self.downloadSWF();
         });
         _verLoader.load(_verReq);
      }

      private function downloadSWF() : void
      {
         var _loader:URLLoader = new URLLoader();
         _loader.dataFormat = URLLoaderDataFormat.BINARY;
         var _req:URLRequest = new URLRequest(AESController.getInstance().serverURL + "/client/main.swf");
         _req.method = URLRequestMethod.GET;
         var _self:UpdateChecker = this;
         _loader.addEventListener(Event.COMPLETE, function(p:*):void { _self.onDownloaded(_loader.data as ByteArray); });
         _loader.addEventListener(IOErrorEvent.IO_ERROR, function(p:*):void { _self._infoTF.text = "下载失败,请稍后重试"; _self._downloading = false; });
         _loader.load(_req);
      }

      private function onDownloaded(param1:ByteArray) : void
      {
         // 获取app目录 - AIR中loaderInfo.url可能是app:/格式
         try {
            var _url:String = this.root.loaderInfo.url;
            if(_url.indexOf("app:/") == 0) {
               // AIR打包应用: 用applicationDirectory (动态访问绕过stub)
               this._appDir = File["applicationDirectory"]["nativePath"];
            } else {
               // 本地文件: file:///C:/path/main.swf
               _url = _url.replace("file:///", "").replace("|", ":");
               _url = _url.replace(/\/[^\/]*\.swf.*$/, "");
               this._appDir = _url;
            }
         } catch(_e:Error) {
            trace("[UpdateChecker] 获取app目录失败: " + _e.message);
         }
         if(this._appDir == "" || this._appDir == null) {
            this._infoTF.text = "错误:无法获取目录";
            this._downloading = false; return;
         }

         try {
            var _appDir:String = this._appDir;  // 闭包捕获
            // 1. 写入新版 main_new.swf
            var _newSwf:File = new File(_appDir + "/main_new.swf");
            var _fs:FileStream = new FileStream();
            _fs.open(_newSwf, FileMode.WRITE);
            Object(_fs).writeBytes(param1, 0, param1.length);
            _fs.close();

            // 验证写入成功 (使用 try/catch 兼容编译期 stub)
            try {
               var _checkFs:FileStream = new FileStream();
               _checkFs.open(_newSwf, FileMode.READ);
               if(_checkFs["bytesAvailable"] < 100) {
                  _checkFs.close();
                  this._infoTF.text = "写入失败,文件异常";
                  this._downloading = false; return;
               }
               _checkFs.close();
            } catch(_e2:Error) {
               this._infoTF.text = "写入失败,请检查权限";
               this._downloading = false; return;
            }

            // 2. 写入版本标记文件(供下次启动核对)
            if(this._expectedVersion != "") {
               try {
                  var _verFs:FileStream = new FileStream();
                  _verFs.open(new File(_appDir + "/version"), FileMode.WRITE);
                  _verFs.writeUTFBytes(this._expectedVersion);
                  _verFs.close();
               } catch(_e:Error) {}
            }

            // 3. 写入自动重启批处理 (杀进程→轮询等锁→替换→验证→重启)
            var _bat:FileStream = new FileStream();
            _bat.open(new File(_appDir + "/update.bat"), FileMode.WRITE);
            _bat.writeUTFBytes("@echo off\r\n");
            _bat.writeUTFBytes("cd /d \"%~dp0\"\r\n");
            _bat.writeUTFBytes("timeout /t 3 /nobreak >nul\r\n");
            _bat.writeUTFBytes("taskkill /f /im main.exe >nul 2>&1\r\n");
            _bat.writeUTFBytes(":wait_unlock\r\n");
            _bat.writeUTFBytes("timeout /t 1 /nobreak >nul\r\n");
            _bat.writeUTFBytes("if not exist main_new.swf goto update_fail\r\n");
            _bat.writeUTFBytes("move /y main.swf main_old.swf >nul 2>&1\r\n");
            _bat.writeUTFBytes("if exist main.swf goto wait_unlock\r\n");
            _bat.writeUTFBytes("move /y main_new.swf main.swf >nul 2>&1\r\n");
            _bat.writeUTFBytes("if not exist main.swf goto wait_unlock\r\n");
            _bat.writeUTFBytes("start \"\" main.exe\r\n");
            _bat.writeUTFBytes("del \"%~f0\" >nul 2>&1\r\n");
            _bat.writeUTFBytes("exit /b 0\r\n");
            _bat.writeUTFBytes(":update_fail\r\n");
            _bat.writeUTFBytes("start \"\" main.exe\r\n");
            _bat.writeUTFBytes("del \"%~f0\" >nul 2>&1\r\n");
            _bat.writeUTFBytes("exit /b 1\r\n");
            _bat.close();

            // 4. 启动批处理
            var _batFile:File = new File(_appDir + "/update.bat");
            Object(_batFile)["openWithDefaultApplication"]();

            // 5. 显示完成 — 批处理会在3秒后杀进程自动完成
            this._infoTF.text = "更新完成! 即将自动重启...";
            this.graphics.clear();
            this.graphics.beginFill(0x0a1a0a, 0.92);
            this.graphics.lineStyle(1.5, 0x00FF66, 0.9);
            this.graphics.drawRoundRect(0, 0, 200, 28, 6, 6);
            this.graphics.endFill();
         }
         catch(_e:Error) {
            this._infoTF.text = "失败: " + _e.message.substring(0, 25);
            this._downloading = false;
         }
      }
   }
}
