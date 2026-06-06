package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
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
         var _loc2_:Class = ApplicationDomain.currentDomain.getDefinition(param1) as Class;
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
         this._general.x = this.width / 2 + 22;
         this._general.y = this.height;
         addChildAt(this._general,0);
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
