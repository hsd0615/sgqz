package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import com.greensock.loading.LoaderMax;
   import com.greensock.loading.SWFLoader;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.filters.BlurFilter;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.model.ArmyInfo;
   import game.model.Type;
   
   public class GeneralBlock extends BaseUI
   {
       
      
      private var __nameTF:TextField;
      
      private var __levelTF:TextField;
      
      private var __icon:MovieClip;
      
      private var _general:MovieClip;
      
      private var _armyInfo:ArmyInfo;
      
      public function GeneralBlock(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         mouseChildren = false;
         this.__nameTF = _skin.getChildByName("_nameTF") as TextField;
         this.__levelTF = _skin.getChildByName("_levelTF") as TextField;
         this.__icon = _skin.getChildByName("_icon") as MovieClip;
      }
      
      override protected function initEvent() : void
      {
      }
      
      override public function initData(param1:Object) : void
      {
         this._armyInfo = param1 as ArmyInfo;
         this.__nameTF.text = this._armyInfo.name;
         this.__levelTF.text = "Lv：" + this._armyInfo.level.toString();
         if(this._armyInfo.feature == 0)
         {
            this.__icon.visible = false;
         }
         else
         {
            this.__icon.visible = true;
            this.__icon.gotoAndStop(this._armyInfo.feature);
         }
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
         if(this._armyInfo.code == "general_5_19" || this._armyInfo.type == Type.JUNZHU)
         {
            this._general.scaleX = 0.52;
            this._general.scaleY = 0.52;
         }
         else if(this._armyInfo.evolution > 1)
         {
            this._general.scaleX = 0.65;
            this._general.scaleY = 0.65;
         }
         else
         {
            this._general.scaleX = 0.65;
            this._general.scaleY = 0.65;
         }
         var _blkW:Number = this._skin.width > 0 ? this._skin.width : 115;
         var _blkH:Number = this._skin.height > 0 ? this._skin.height : 130;
         this._general.x = _blkW / 2;
         this._general.y = _blkH - 15;
         addChild(this._general);
         var _loc3_:Shape = new Shape();
         _loc3_.graphics.beginFill(16764006);
         _loc3_.graphics.drawEllipse(-40,-12,80,24);
         _loc3_.filters = [new BlurFilter(20,12)];
         this._general.addChildAt(_loc3_,0);
         // DEBUG: log createGeneral dimensions
         try {
            var _df2:File = File.applicationStorageDirectory.resolvePath("debug_shangzhen.txt");
            var _ds2:FileStream = new FileStream();
            _ds2.open(_df2, FileMode.APPEND);
            _ds2.writeUTFBytes("[GenBlock] createGeneral: code=" + (this._armyInfo ? this._armyInfo.code : "null") + " skin=" + param1 + " skinW=" + this._skin.width + " skinH=" + this._skin.height + " thisW=" + this.width + " thisH=" + this.height + " fallbackW=" + _blkW + " fallbackH=" + _blkH + " genX=" + this._general.x + " genY=" + this._general.y + " stage=" + (this.stage != null) + "\n");
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
         this.__icon.visible = false;
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
