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
         this._infoTF.text = "正在下载...";

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
         } catch(_e:Error) {}
         if(this._appDir == "" || this._appDir == null) {
            this._infoTF.text = "错误:无法获取目录";
            this._downloading = false; return;
         }

         try {
            // 1. 写入新版 main_new.swf
            var _fs:FileStream = new FileStream();
            _fs.open(new File(_appDir + "/main_new.swf"), FileMode.WRITE);
            Object(_fs).writeBytes(param1, 0, param1.length);
            _fs.close();

            // 2. 写入静默更新脚本 update.vbs (无窗口,自动杀进程+替换+重启)
            var _vbs:FileStream = new FileStream();
            _vbs.open(new File(_appDir + "/update.vbs"), FileMode.WRITE);
            _vbs.writeUTFBytes("Dim fso, ws, dir, i\r\n");
            _vbs.writeUTFBytes("Set ws = CreateObject(\"WScript.Shell\")\r\n");
            _vbs.writeUTFBytes("Set fso = CreateObject(\"Scripting.FileSystemObject\")\r\n");
            _vbs.writeUTFBytes("dir = fso.GetParentFolderName(WScript.ScriptFullName)\r\n");
            _vbs.writeUTFBytes("WScript.Sleep 2000\r\n");
            _vbs.writeUTFBytes("ws.Run \"taskkill /f /im main.exe\", 0, True\r\n");
            _vbs.writeUTFBytes("WScript.Sleep 500\r\n");
            _vbs.writeUTFBytes("On Error Resume Next\r\n");
            _vbs.writeUTFBytes("fso.DeleteFile dir & \"\\main_old.swf\", True\r\n");
            _vbs.writeUTFBytes("fso.MoveFile dir & \"\\main.swf\", dir & \"\\main_old.swf\"\r\n");
            _vbs.writeUTFBytes("fso.MoveFile dir & \"\\main_new.swf\", dir & \"\\main.swf\"\r\n");
            _vbs.writeUTFBytes("On Error Goto 0\r\n");
            _vbs.writeUTFBytes("If fso.FileExists(dir & \"\\main.swf\") Then\r\n");
            _vbs.writeUTFBytes("  ws.Run Chr(34) & dir & \"\\main.exe\" & Chr(34), 1, False\r\n");
            _vbs.writeUTFBytes("End If\r\n");
            _vbs.writeUTFBytes("fso.DeleteFile WScript.ScriptFullName\r\n");
            _vbs.close();

            // 3. 启动 VBS 脚本 (静默) — 动态调用绕过air_stubs
            var _vbsFile:File = new File(_appDir + "/update.vbs");
            Object(_vbsFile).openWithDefaultApplication();

            // 4. 显示完成
            this._infoTF.text = "更新就绪! 即将自动重启...";
            this.graphics.clear();
            this.graphics.beginFill(0x0a1a0a, 0.92);
            this.graphics.lineStyle(1.5, 0x00FF66, 0.9);
            this.graphics.drawRoundRect(0, 0, 200, 28, 6, 6);
            this.graphics.endFill();

            // VBS 脚本会在2秒后自动杀进程+替换文件+重启游戏
         }
         catch(_e:Error) {
            this._infoTF.text = "失败: " + _e.message.substring(0, 25);
            this._downloading = false;
         }
      }
   }
}
