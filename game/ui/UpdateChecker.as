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
      private var _completeCallback:Function;

      public function UpdateChecker(param1:Function = null)
      {
         super();
         this._completeCallback = param1;
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
                  _self.showUpdatePrompt(_json.version, _json.downloadUrl);
               }
            }
            catch(_e:Error) {}
         });
         _loader.load(_req);
      }

      private function showUpdatePrompt(param1:String, param2:String) : void
      {
         // 创建"发现新版本"浮动提示条
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
         _loader.dataFormat = flash.net.URLLoaderDataFormat.BINARY;
         var _req:URLRequest = new URLRequest(AESController.getInstance().serverURL + "/client/main.swf");
         _req.method = URLRequestMethod.GET;
         var _self:UpdateChecker = this;
         _loader.addEventListener(Event.COMPLETE, function(param1:Event):void {
            _self.saveAndNotify(_loader.data as flash.utils.ByteArray);
         });
         _loader.addEventListener(IOErrorEvent.IO_ERROR, function(param1:IOErrorEvent):void {
            _self._infoTF.text = "下载失败，请稍后重试";
            _self._downloading = false;
         });
         _loader.load(_req);
      }

      private function saveAndNotify(param1:flash.utils.ByteArray) : void
      {
         try
         {
            // 使用 root.loaderInfo 获取 SWF 所在目录，避免 air_stubs.swc 缺少 applicationDirectory
            var _swfUrl:String = this.root.loaderInfo.url;
            // 去掉 file:// 前缀和 main.swf 文件名
            _swfUrl = _swfUrl.replace("file:///", "").replace(/\/main\.swf.*$/, "");
            // Windows路径使用 / 亦可
            _swfUrl = _swfUrl.split("/").join("/");
            var _appDir:File = new File(_swfUrl);
            var _newFile:File = _appDir.resolvePath("main.swf");
            var _fs:FileStream = new FileStream();
            _fs.open(_newFile, FileMode.WRITE);
            // writeBytes 在 air_stubs.swc 中未声明，运行时存在，动态调用绕过编译检查
            Object(_fs).writeBytes(param1, 0, param1.length);
            _fs.close();
            this._infoTF.text = "更新完成! 请重启游戏";
            this.graphics.clear();
            this.graphics.beginFill(0x0a1a0a, 0.92);
            this.graphics.lineStyle(1.5, 0x00FF66, 0.9);
            this.graphics.drawRoundRect(0, 0, 200, 28, 6, 6);
            this.graphics.endFill();
            if(this._completeCallback != null)
            {
               this._completeCallback();
            }
         }
         catch(_e:Error)
         {
            this._infoTF.text = "保存失败: " + _e.message.substring(0, 30);
            this._downloading = false;
         }
      }
   }
}
