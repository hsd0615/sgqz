package game.ui
{
   import com.iflashigame.controller.AESController;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;

   public class ChangelogPanel extends Sprite
   {
      private var _bg:Shape;
      private var _titleTF:TextField;
      private var _bodyTF:TextField;
      private var _closeBtn:Sprite;
      private var _scrollMask:Shape;
      private var _scrollDragY:Number = 0;
      private var _scrollOffset:Number = 0;
      private var _maxScroll:Number = 0;

      public function ChangelogPanel()
      {
         super();
         this.loadChangelog();
      }

      private function loadChangelog() : void
      {
         var _loader:URLLoader = new URLLoader();
         var _req:URLRequest = new URLRequest(AESController.getInstance().serverURL + "/api/changelog");
         _req.method = URLRequestMethod.POST;
         _req.contentType = "application/json";
         _req.data = "{}";
         var _self:ChangelogPanel = this;
         _loader.addEventListener(Event.COMPLETE, function(e:Event):void {
            try {
               var _json:Object = JSON.parse(_loader.data as String);
               if(_json.success && _json.entries && _json.entries.length > 0) {
                  _self.buildUI(_json.entries);
               }
            } catch(_err:Error) {}
         });
         _loader.load(_req);
      }

      private function buildUI(entries:Array) : void
      {
         var _w:int = 420;
         var _h:int = 320;

         // 背景
         this._bg = new Shape();
         this._bg.graphics.beginFill(0x0d0804, 0.95);
         this._bg.graphics.lineStyle(2, 0x8B6914, 0.9);
         this._bg.graphics.drawRoundRect(0, 0, _w, _h, 12, 12);
         this._bg.graphics.endFill();
         // 顶部装饰线
         this._bg.graphics.lineStyle(1, 0xC8A84E, 0.6);
         this._bg.graphics.moveTo(10, 36); this._bg.graphics.lineTo(_w - 10, 36);
         addChild(this._bg);

         // 标题
         this._titleTF = new TextField();
         this._titleTF.defaultTextFormat = new TextFormat("SimHei", 18, 0xFFD700, true);
         this._titleTF.text = "📋 更新公告";
         this._titleTF.selectable = false;
         this._titleTF.autoSize = TextFieldAutoSize.CENTER;
         this._titleTF.x = (_w - this._titleTF.width) / 2;
         this._titleTF.y = 8;
         addChild(this._titleTF);

         // 构建内容
         var _bodyStr:String = "";
         for(var i:int = 0; i < entries.length; i++)
         {
            _bodyStr += "━━ v" + entries[i].version + " ━━ " + entries[i].title + "\n";
            _bodyStr += entries[i].body + "\n";
         }

         // 正文
         this._bodyTF = new TextField();
         this._bodyTF.defaultTextFormat = new TextFormat("SimSun", 12, 0xD4C8A0);
         this._bodyTF.wordWrap = true;
         this._bodyTF.multiline = true;
         this._bodyTF.selectable = false;
         this._bodyTF.width = _w - 24;
         this._bodyTF.height = _h - 52;
         this._bodyTF.x = 12;
         this._bodyTF.y = 42;
         this._bodyTF.text = _bodyStr;
         this._bodyTF.filters = [new GlowFilter(0x000000, 0.5, 3, 3, 1)];
         addChild(this._bodyTF);

         // 滚动遮罩
         this._scrollMask = new Shape();
         this._scrollMask.graphics.beginFill(0);
         this._scrollMask.graphics.drawRect(12, 42, _w - 24, _h - 52);
         this._scrollMask.graphics.endFill();
         addChild(this._scrollMask);
         this._bodyTF.mask = this._scrollMask;

         // 滚动支持
         this._maxScroll = Math.max(0, this._bodyTF.textHeight - (_h - 52));
         if(this._maxScroll > 0)
         {
            this._bodyTF.addEventListener(MouseEvent.MOUSE_DOWN, this.onScrollStart);
            this._bodyTF.addEventListener(MouseEvent.MOUSE_UP, this.onScrollEnd);
         }

         // 关闭按钮
         this._closeBtn = new Sprite();
         var _cbg:Shape = new Shape();
         _cbg.graphics.beginFill(0x5a3010, 0.9);
         _cbg.graphics.lineStyle(1, 0xC8A84E, 0.8);
         _cbg.graphics.drawRoundRect(0, 0, 80, 26, 6, 6);
         _cbg.graphics.endFill();
         this._closeBtn.addChild(_cbg);
         var _ctf:TextField = new TextField();
         _ctf.defaultTextFormat = new TextFormat("SimHei", 13, 0xFFD700, true);
         _ctf.text = "知道了";
         _ctf.selectable = false;
         _ctf.autoSize = TextFieldAutoSize.CENTER;
         _ctf.x = (80 - _ctf.width) / 2;
         _ctf.y = 4;
         this._closeBtn.addChild(_ctf);
         this._closeBtn.buttonMode = true;
         this._closeBtn.x = (_w - 80) / 2;
         this._closeBtn.y = _h - 34;
         var _self:ChangelogPanel = this;
         this._closeBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { _self.close(); });
         addChild(this._closeBtn);

         // 淡入效果
         this.alpha = 0;
         addEventListener(Event.ENTER_FRAME, this.fadeIn);
      }

      private function fadeIn(e:Event) : void
      {
         this.alpha += 0.1;
         if(this.alpha >= 1)
         {
            this.alpha = 1;
            removeEventListener(Event.ENTER_FRAME, this.fadeIn);
         }
      }

      private function onScrollStart(e:MouseEvent) : void
      {
         this._scrollDragY = e.stageY;
         this._bodyTF.addEventListener(Event.ENTER_FRAME, this.onScrollMove);
      }

      private function onScrollEnd(e:MouseEvent) : void
      {
         this._bodyTF.removeEventListener(Event.ENTER_FRAME, this.onScrollMove);
      }

      private function onScrollMove(e:Event) : void
      {
         if(this._bodyTF.hasOwnProperty("stage") && this._bodyTF.stage)
         {
            var _dy:Number = (this._bodyTF.stage.mouseY || 0) - this._scrollDragY;
            this._scrollDragY = this._bodyTF.stage.mouseY || 0;
            this._scrollOffset += _dy * 0.5;
            this._scrollOffset = Math.max(0, Math.min(this._maxScroll, this._scrollOffset));
            this._bodyTF.y = 42 - this._scrollOffset;
         }
      }

      public function close() : void
      {
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
      }
   }
}
