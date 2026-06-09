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
            try
            {
               var _json:Object = JSON.parse(_loader.data as String);
               if(_json.success && _json.version && _json.version != Config.CLIENT_VER)
               {
                  _self.showUpdatePrompt(_json.version);
               }
            }
            catch(_e:Error) {}
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
         this._infoTF.text = "新版本 v" + param1 + " 可用! 点击更新";
         this._infoTF.autoSize = TextFieldAutoSize.LEFT;
         this._infoTF.selectable = false;
         this._infoTF.x = 10;
         this._infoTF.y = 6;
         this._infoTF.width = 180;
         addChild(this._infoTF);

         this.buttonMode = true;
         this.mouseChildren = false;
         var _self:UpdateChecker = this;
         this.addEventListener(flash.events.MouseEvent.CLICK, function(param1:*):void {
            _self.startDownload();
         });
      }

      private function startDownload() : void
      {
         if(this._downloading) return;
         this._downloading = true;
         this._infoTF.text = "正在下载更新...";

         var _loader:URLLoader = new URLLoader();
         _loader.dataFormat = URLLoaderDataFormat.BINARY;
         var _req:URLRequest = new URLRequest(AESController.getInstance().serverURL + "/client/main.swf");
         _req.method = URLRequestMethod.GET;
         var _self:UpdateChecker = this;
         _loader.addEventListener(Event.COMPLETE, function(param1:Event):void {
            _self.saveAndNotify(_loader.data as ByteArray);
         });
         _loader.addEventListener(IOErrorEvent.IO_ERROR, function(param1:IOErrorEvent):void {
            _self._infoTF.text = "下载失败(IO): 请检查网络";
            _self._downloading = false;
         });
         _loader.load(_req);
      }

      private function saveAndNotify(param1:ByteArray) : void
      {
         try
         {
            // 获取app目录路径
            var _swfUrl:String = this.root.loaderInfo.url;
            _swfUrl = _swfUrl.replace("file:///", "");
            _swfUrl = _swfUrl.replace("|", ":");
            _swfUrl = _swfUrl.replace(/\/[^\/]*\.swf.*$/, "");
            var _appDir:String = _swfUrl;

            // 写入 main_new.swf (运行中的 main.swf 被锁定无法覆盖)
            var _newFile:File = new File(_appDir + "/main_new.swf");
            var _fs:FileStream = new FileStream();
            _fs.open(_newFile, FileMode.WRITE);
            Object(_fs).writeBytes(param1, 0, param1.length);
            _fs.close();

            // 写入更新批处理脚本
            var _batFile:File = new File(_appDir + "/update.bat");
            var _fsBat:FileStream = new FileStream();
            _fsBat.open(_batFile, FileMode.WRITE);
            _fsBat.writeUTFBytes("@echo off\r\n");
            _fsBat.writeUTFBytes("cd /d \"%~dp0\"\r\n");
            _fsBat.writeUTFBytes("echo 正在应用更新...\r\n");
            _fsBat.writeUTFBytes("timeout /t 2 /nobreak >nul\r\n");
            _fsBat.writeUTFBytes("move /y main.swf main_old.swf\r\n");
            _fsBat.writeUTFBytes("move /y main_new.swf main.swf\r\n");
            _fsBat.writeUTFBytes("echo 更新完成! 请重新启动游戏\r\n");
            _fsBat.writeUTFBytes("del \"%~f0\"\r\n");
            _fsBat.writeUTFBytes("pause\r\n");
            _fsBat.close();

            // 通知用户
            this._infoTF.text = "更新就绪! 关闭游戏后双击 update.bat";
            this.graphics.clear();
            this.graphics.beginFill(0x0a1a0a, 0.92);
            this.graphics.lineStyle(1.5, 0x00FF66, 0.9);
            this.graphics.drawRoundRect(0, 0, 200, 28, 6, 6);
            this.graphics.endFill();
            this.width = 210;
         }
         catch(_e:Error)
         {
            this._infoTF.text = "保存失败: " + _e.message.substring(0, 25);
            this._downloading = false;
         }
      }
   }
}
