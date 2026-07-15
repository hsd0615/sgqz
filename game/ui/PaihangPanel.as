package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import game.Config;
   import game.events.UIEvent;
   import game.model.RoleModel;
   import game.ui.list.ScrollBar;

   public class PaihangPanel extends BaseUI
   {
      private var __closeBtn:SimpleButton;
      private var __myRankTF:TextField;
      private var _container:RankingContainer;
      private var _scrollBar:ScrollBar;
      private var _items:Array;
      private var _loading:Boolean = false;

      public function PaihangPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1, param2);
      }

      override protected function initView() : void
      {
         // 从皮肤获取关闭按钮
         try {
            this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         } catch(_e:Error) {}

         // 列表容器（带滚动蒙版 + 鼠标滚轮）
         // 皮肤背景: 579x362, 居中于(0,0), 内容区约在y:-130~130
         this._container = new RankingContainer(520, 260);
         this._container.x = -260;
         this._container.y = -130;
         this._container.enableMouseWheel();
         addChild(this._container);

         // 滚动条
         try {
            this._scrollBar = new ScrollBar(SkinCode.PAIHANG_SCROLL_BAR);
            this._scrollBar.x = 272;
            this._scrollBar.y = -130;
            addChild(this._scrollBar);
            this._scrollBar.target = this._container;
         } catch(_e:Error) {}

         // 列标题
         var _hdr:TextField = new TextField();
         _hdr.x = 0; _hdr.y = 0;
         _hdr.width = 520; _hdr.height = 22;
         _hdr.selectable = false; _hdr.mouseEnabled = false;
         var _hfmt:TextFormat = new TextFormat("_sans", 12, 0xAAAAAA);
         _hdr.defaultTextFormat = _hfmt;
         _hdr.text = "  排名   玩家名称              等级      战斗力";
         this._container.content.addChild(_hdr);

         // 我的排名（页脚）
         this.__myRankTF = new TextField();
         this.__myRankTF.x = -150; this.__myRankTF.y = 155;
         this.__myRankTF.width = 300; this.__myRankTF.height = 24;
         this.__myRankTF.selectable = false;
         this.__myRankTF.mouseEnabled = false;
         var _mfmt:TextFormat = new TextFormat("_sans", 14, 0xFFD700);
         _mfmt.align = "center";
         this.__myRankTF.defaultTextFormat = _mfmt;
         this.__myRankTF.text = "加载中...";
         addChild(this.__myRankTF);

         this._items = [];
      }

      override protected function initEvent() : void
      {
         if(this.__closeBtn != null)
         {
            this.__closeBtn.addEventListener(MouseEvent.CLICK, this.closeBtnClickHandler);
         }
         addEventListener(Event.ADDED_TO_STAGE, this.onAddedHandler);
      }

      private function onAddedHandler(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE, this.onAddedHandler);
         this.loadRanking();
      }

      private function closeBtnClickHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE, true));
      }

      private function loadRanking() : void
      {
         if(this._loading) return;
         this._loading = true;
         this.__myRankTF.text = "加载中...";

         var _req:URLRequest = new URLRequest(Config.SERVER_URL + "/api/combat-ranking");
         _req.method = URLRequestMethod.GET;
         var _loader:URLLoader = new URLLoader();
         var _self:PaihangPanel = this;
         _loader.addEventListener(Event.COMPLETE, function(e:Event):void {
            try {
               var _data:Object = JSON.parse(_loader.data);
               if(_data.success) {
                  _self.renderList(_data.rankings);
               }
            } catch(_err:Error) {}
            _self._loading = false;
         });
         _loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:*):void { _self._loading = false; });
         _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:*):void { _self._loading = false; });
         _loader.load(_req);
      }

      private function renderList(rankings:Array) : void
      {
         // 清除旧列表项（保留标题行）
         while(this._container.content.numChildren > 1) {
            this._container.content.removeChildAt(1);
         }
         this._items = [];

         if(!rankings || rankings.length == 0) {
            this.__myRankTF.text = "暂无排行数据";
            return;
         }

         var _roleName:String;
         try { _roleName = RoleModel.getInstance().roleName; } catch(_e:Error) { _roleName = ""; }

         var _myRank:int = -1;
         var _itemH:int = 25;
         var _listItemClass:Class = null;
         try {
            _listItemClass = ApplicationDomain.currentDomain.getDefinition(SkinCode.PAIHANG_LIST_ITEM) as Class;
         } catch(_e:Error) {}

         for(var _i:int = 0; _i < rankings.length; _i++)
         {
            var _item:MovieClip;
            if(_listItemClass != null) {
               _item = new _listItemClass() as MovieClip;
               _item.mouseEnabled = false;
               _item.mouseChildren = false;
               _item.x = 0;
               _item.y = 22 + _i * _itemH;
               this._container.content.addChild(_item);

               // 填充皮肤 TextField
               try { _item._mingciTF.text = String(rankings[_i].rank); } catch(_e:Error) {}
               try { _item._nameTF.text = String(rankings[_i].name); } catch(_e:Error) {}
               try { _item._areaTF.text = "Lv." + rankings[_i].level; } catch(_e:Error) {}
               try { _item._winTF.text = String(rankings[_i].power); } catch(_e:Error) {}
               try { _item._lostTF.visible = false; } catch(_e:Error) {}

               // 前三名特殊颜色
               var _r:int = rankings[_i].rank;
               if(_r == 1) {
                  try { _item._mingciTF.textColor = 0xFFD700; } catch(_e:Error) {}
               } else if(_r == 2) {
                  try { _item._mingciTF.textColor = 0xC0C0C0; } catch(_e:Error) {}
               } else if(_r == 3) {
                  try { _item._mingciTF.textColor = 0xCD7F32; } catch(_e:Error) {}
               }

               // 高亮自己
               if(rankings[_i].name == _roleName) {
                  try {
                     _item._bkMC.graphics.clear();
                     _item._bkMC.graphics.beginFill(0xFFD700, 0.2);
                     _item._bkMC.graphics.drawRect(0, 0, 520, 24);
                     _item._bkMC.graphics.endFill();
                  } catch(_e:Error) {}
               }
            }

            if(rankings[_i].name == _roleName) {
               _myRank = rankings[_i].rank;
            }
         }

         var _myPwr:int = 0;
         try { _myPwr = RoleModel.getInstance().getCachedCombatPower(); } catch(_e:Error) {}
         this.__myRankTF.text = _myRank > 0 ? "我的排名: 第" + _myRank + "名  战力: " + _myPwr : "我的战力: " + _myPwr + " (未上榜)";

         // 通知滚动条
         if(this._scrollBar != null) {
            this._container.dispatchEvent(new Event("scroll"));
         }
      }
   }
}
