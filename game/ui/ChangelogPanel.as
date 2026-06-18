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
   import flash.filters.GlowFilter;

   public class ChangelogPanel extends Sprite
   {
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
                  return;
               }
            } catch(_err:Error) {}
            _self.buildUI([{version:"欢迎",title:"三国Q战",body:"商城可购买装备\n武将详情可管理装备\n祝游戏愉快!"}]);
         });
         _loader.load(_req);
      }

      private function buildUI(entries:Array) : void
      {
         var _w:int = 420;
         var _h:int = 310;

         var _bg:Shape = new Shape();
         _bg.graphics.beginFill(0x0d0804, 0.96);
         _bg.graphics.lineStyle(2.5, 0xFF8800, 0.95);
         _bg.graphics.drawRoundRect(0, 0, _w, _h, 12, 12);
         _bg.graphics.endFill();
         addChild(_bg);

         var _titleTF:TextField = new TextField();
         _titleTF.defaultTextFormat = new TextFormat("SimHei", 18, 0xFFD700, true);
         _titleTF.text = "更新公告";
         _titleTF.selectable = false;
         _titleTF.autoSize = TextFieldAutoSize.CENTER;
         _titleTF.x = (_w - _titleTF.width) / 2;
         _titleTF.y = 8;
         addChild(_titleTF);

         var _bodyStr:String = "";
         for(var i:int = 0; i < entries.length; i++)
         {
            _bodyStr += "━━ v" + entries[i].version + " ━━ " + entries[i].title + "\n";
            _bodyStr += entries[i].body + "\n";
         }

         var _bodyTF:TextField = new TextField();
         _bodyTF.defaultTextFormat = new TextFormat("SimSun", 12, 0xD4C8A0);
         _bodyTF.wordWrap = true;
         _bodyTF.multiline = true;
         _bodyTF.selectable = false;
         _bodyTF.width = _w - 24;
         _bodyTF.height = _h - 50;
         _bodyTF.x = 12;
         _bodyTF.y = 40;
         _bodyTF.text = _bodyStr;
         addChild(_bodyTF);

         var _closeBtn:Sprite = new Sprite();
         var _cbg:Shape = new Shape();
         _cbg.graphics.beginFill(0x5a3010, 0.9);
         _cbg.graphics.lineStyle(1, 0xFFD700, 0.8);
         _cbg.graphics.drawRoundRect(0, 0, 80, 26, 6, 6);
         _cbg.graphics.endFill();
         _closeBtn.addChild(_cbg);
         var _ctf:TextField = new TextField();
         _ctf.defaultTextFormat = new TextFormat("SimHei", 13, 0xFFD700, true);
         _ctf.text = "知道了";
         _ctf.selectable = false;
         _ctf.autoSize = TextFieldAutoSize.CENTER;
         _ctf.x = (80 - _ctf.width) / 2; _ctf.y = 4;
         _closeBtn.addChild(_ctf);
         _closeBtn.buttonMode = true;
         _closeBtn.x = (_w - 80) / 2; _closeBtn.y = _h - 34;
         var _self:ChangelogPanel = this;
         _closeBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            if(_self.parent) _self.parent.removeChild(_self);
         });
         addChild(_closeBtn);
      }
   }
}
