package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import game.Data;
   import game.events.UIEvent;
   import game.model.RoleModel;
   
   public class BagPanel extends BaseUI
   {
       
      
      private var __closeBtn:SimpleButton;
      
      private var _gridArr:Array;
      
      private var _gridContainer:Sprite;
      
      public function BagPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         var _loc1_:MovieClip = null;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this._gridContainer = new Sprite();
         addChild(this._gridContainer);
         var _loc2_:int = 1;
         while(_loc2_ <= 25)
         {
            _loc1_ = _skin.getChildByName("_grid" + _loc2_) as MovieClip;
            _loc1_.sanjiao.visible = false;
            _loc1_.mouseChildren = false;
            this._gridContainer.addChild(_loc1_);
            _loc2_++;
         }
      }
      
      private function onMouseOverHandler(param1:MouseEvent) : *
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         param1.stopImmediatePropagation();
         if(param1.target.flag == true)
         {
            _loc2_ = String(param1.target.code);
            _loc3_ = Data.getInstance().getAttributes("proto",_loc2_,"name");
            _loc4_ = Data.getInstance().getAttributes("proto",_loc2_,"type");
            _loc5_ = Data.getInstance().getAttributes("proto",_loc2_,"desc");
            _loc6_ = (_loc6_ = "") + ("<font color=\'#e5ce10\'>名称：</font>" + _loc3_ + "\n");
            if(_loc4_ == 1)
            {
               _loc6_ += "<font color=\'#e5ce10\'>类别：</font>" + "进化道具" + "\n";
            }
            else if(_loc4_ == 2)
            {
               _loc6_ += "<font color=\'#e5ce10\'>类别：</font>" + "战车弹药" + "\n";
            }
            else
            {
               _loc6_ += "<font color=\'#e5ce10\'>类别：</font>" + "其他" + "\n";
            }
            _loc6_ += "<font color=\'#e5ce10\'>说明：</font>" + _loc5_ + "\n";
            dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
               "htmlText":_loc6_,
               "type":3,
               "width":150,
               "height":70
            }));
         }
      }
      
      private function onMouseOutHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(param1.target.flag == true)
         {
            dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
         }
      }
      
      override protected function initEvent() : void
      {
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this._gridContainer.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHandler);
         this._gridContainer.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         var _loc2_:MovieClip = null;
         var _loc6_:Bitmap = null;
         _loc2_ = null;
         var _loc3_:String = null;
         var _loc4_:Class = null;
         var _loc5_:BitmapData = null;
         _loc6_ = null;
         var _loc7_:int = 0;
         while(_loc7_ < param1.length)
         {
            _loc2_ = this._gridContainer.getChildByName("_grid" + (_loc7_ + 1)) as MovieClip;
            _loc2_.code = param1[_loc7_].code;
            _loc2_.countTF.text = RoleModel.getInstance().getBagItemCount(_loc2_.code);
            _loc2_.flag = true;
            _loc3_ = Data.getInstance().getAttributes("proto",param1[_loc7_].code,"icon");
            _loc5_ = new (_loc4_ = ApplicationDomain.currentDomain.getDefinition(_loc3_) as Class)() as BitmapData;
            (_loc6_ = new Bitmap(_loc5_)).x = 2;
            _loc6_.y = 2;
            _loc2_.addChildAt(_loc6_,0);
            _loc7_++;
         }
      }
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
   }
}
