package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import com.greensock.loading.LoaderMax;
   import com.greensock.loading.SWFLoader;
   import flash.display.MovieClip;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.model.ArmyInfo;
   
   public class JunshiBlock extends BaseUI
   {
       
      
      private var __nameTF:TextField;
      
      private var __levelTF:TextField;
      
      private var _general:MovieClip;
      
      private var _armyInfo:ArmyInfo;
      
      public function JunshiBlock(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         mouseChildren = false;
         this.__nameTF = _skin.getChildByName("_nameTF") as TextField;
         this.__levelTF = _skin.getChildByName("_levelTF") as TextField;
         this.__nameTF.text = "";
         this.__levelTF.text = "";
      }
      
      override protected function initEvent() : void
      {
      }
      
      override public function initData(param1:Object) : void
      {
         this._armyInfo = param1 as ArmyInfo;
         this.__nameTF.text = this._armyInfo.name;
         this.__levelTF.text = "Lv：" + this._armyInfo.level.toString();
         this.createGeneral(this._armyInfo.skin);
      }
      
      private function createGeneral(param1:String) : *
      {
         var _loc2_:Class = null;
         try {
            var _loader:SWFLoader = LoaderMax.getLoader("game01.skin.general") as SWFLoader;
            if(_loader != null) _loc2_ = _loader.getClass(param1);
            if(_loc2_ == null) _loc2_ = ApplicationDomain.currentDomain.getDefinition(param1) as Class;
         } catch(_e:Error) {}
         if(_loc2_ == null) return;
         if(this._general != null)
         {
            removeChild(this._general);
         }
         this._general = new _loc2_() as MovieClip;
         this._general.mouseChildren = false;
         if(this._armyInfo.evolution > 1)
         {
            this._general.scaleX = 0.45;
            this._general.scaleY = 0.45;
         }
         else
         {
            this._general.scaleX = 0.45;
            this._general.scaleY = 0.45;
         }
         var _blkW:Number = this._skin.width > 0 ? this._skin.width : 130;
         var _blkH:Number = this._skin.height > 0 ? this._skin.height : 130;
         this._general.x = _blkW / 2 + 22;
         this._general.y = _blkH;
         addChildAt(this._general,0);
         // DEBUG: log createGeneral dimensions
         try {
            var _df2:File = File.applicationStorageDirectory.resolvePath("debug_shangzhen.txt");
            var _ds2:FileStream = new FileStream();
            _ds2.open(_df2, FileMode.APPEND);
            _ds2.writeUTFBytes("[JunshiBlock] createGeneral: code=" + (this._armyInfo ? this._armyInfo.code : "null") + " skin=" + param1 + " skinW=" + this._skin.width + " skinH=" + this._skin.height + " thisW=" + this.width + " thisH=" + this.height + " fallbackW=" + _blkW + " fallbackH=" + _blkH + " genX=" + this._general.x + " genY=" + this._general.y + " stage=" + (this.stage != null) + "\n");
            _ds2.close();
         } catch(_e:Error) {}
      }
      
      public function clear() : *
      {
         if(this._general != null)
         {
            removeChild(this._general);
            this._general = null;
         }
         this.__nameTF.text = "";
         this.__levelTF.text = "";
         this._armyInfo = null;
      }
      
      public function get active() : Boolean
      {
         if(this._armyInfo == null)
         {
            return false;
         }
         return true;
      }
      
      public function get armyInfo() : ArmyInfo
      {
         return this._armyInfo;
      }
   }
}
