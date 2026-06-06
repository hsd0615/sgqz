package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.events.UIEvent;
   import game.model.LeitaiStatus;
   import game.model.LeitaiType;
   import game.model.RoleModel;
   
   public class Leitai extends BaseUI
   {
       
      
      private var __leitaiLevelTF:TextField;
      
      private var __nameTF:TextField;
      
      private var __levelTF:TextField;
      
      private var __countTF:TextField;
      
      private var __leijiTF:TextField;
      
      private var __leijiValueTF:TextField;
      
      private var __baomingTF:TextField;
      
      private var __yinziTF:TextField;
      
      private var __yinziValueTF:TextField;
      
      private var __leizhuBtn:SimpleButton;
      
      private var __gongleiBtn:SimpleButton;
      
      private var _pos:Point;
      
      private var _colorArr:Array;
      
      private var _txtArr:Array;
      
      private var _leijiArr:Array;
      
      private var _data:Object;
      
      private var _imageMC:MovieClip;
      
      public function Leitai(param1:String, param2:ApplicationDomain = null)
      {
         this._pos = new Point(21,38);
         this._colorArr = [14540253,323582,16737843,16776960];
         this._txtArr = ["未知","银子","功勋","点卡"];
         this._leijiArr = ["奖池累计\n未知","奖池累计\n银子","奖池累计\n功勋","奖池累计\n点卡"];
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__leitaiLevelTF = _skin.getChildByName("_leitaiLevelTF") as TextField;
         this.__nameTF = _skin.getChildByName("_nameTF") as TextField;
         this.__levelTF = _skin.getChildByName("_levelTF") as TextField;
         this.__countTF = _skin.getChildByName("_countTF") as TextField;
         this.__leijiTF = _skin.getChildByName("_leijiTF") as TextField;
         this.__leijiValueTF = _skin.getChildByName("_leijiValueTF") as TextField;
         this.__baomingTF = _skin.getChildByName("_baomingTF") as TextField;
         this.__yinziTF = _skin.getChildByName("_yinziTF") as TextField;
         this.__yinziValueTF = _skin.getChildByName("_yinziValueTF") as TextField;
         this.__leizhuBtn = _skin.getChildByName("_leizhuBtn") as SimpleButton;
         this.__gongleiBtn = _skin.getChildByName("_gongleiBtn") as SimpleButton;
         this.__leitaiLevelTF.mouseEnabled = false;
         this.__nameTF.mouseEnabled = false;
         this.__levelTF.mouseEnabled = false;
         this.__countTF.mouseEnabled = false;
         this.__leijiTF.mouseEnabled = false;
         this.__leijiValueTF.mouseEnabled = false;
         this.__baomingTF.mouseEnabled = false;
         this.__yinziTF.mouseEnabled = false;
         this.__yinziValueTF.mouseEnabled = false;
      }
      
      override protected function initEvent() : void
      {
         this.__leizhuBtn.addEventListener(MouseEvent.CLICK,this.leizhuBtnClickHandler);
         this.__gongleiBtn.addEventListener(MouseEvent.CLICK,this.gongleiBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this._data = param1;
         this.setType(this._data.rType);
         this.setLeitai(this._data);
         this.setLeizhu(this._data);
      }
      
      private function setType(param1:int) : *
      {
         this.__leijiTF.textColor = this._colorArr[param1];
         this.__baomingTF.textColor = this._colorArr[param1];
         this.__yinziTF.textColor = this._colorArr[param1];
         this.__leijiTF.text = this._leijiArr[param1];
         this.__yinziTF.text = this._txtArr[param1];
      }
      
      private function setLeitai(param1:Object) : *
      {
         this.__leitaiLevelTF.text = param1.rLevel + "级以下";
         if(int(param1.rStatus) == LeitaiStatus.EMPTY)
         {
            this.__nameTF.visible = false;
            this.__levelTF.visible = false;
            this.__countTF.visible = false;
            this.__leijiValueTF.visible = false;
            this.__leizhuBtn.visible = true;
            this.__gongleiBtn.visible = false;
         }
         else if(int(param1.rStatus) == LeitaiStatus.WAITING)
         {
            this.__nameTF.visible = true;
            this.__levelTF.visible = true;
            this.__countTF.visible = true;
            this.__leijiValueTF.visible = true;
            this.__leizhuBtn.visible = false;
            this.__gongleiBtn.visible = true;
         }
         else
         {
            this.__nameTF.visible = true;
            this.__levelTF.visible = true;
            this.__countTF.visible = true;
            this.__leijiValueTF.visible = true;
            this.__leizhuBtn.visible = false;
            this.__gongleiBtn.visible = false;
         }
         this.__yinziValueTF.text = param1.rPrice;
      }
      
      private function setLeizhu(param1:Object) : *
      {
         var _loc2_:Class = null;
         if(this._imageMC != null)
         {
            removeChild(this._imageMC);
            this._imageMC = null;
         }
         if(param1.mInfo != null)
         {
            this.__nameTF.text = param1.mInfo.roleName;
            this.__levelTF.text = "Lv:" + param1.mInfo.level;
            this.__countTF.text = "已守擂 " + param1.rCount + " 场";
            this.__leijiValueTF.text = param1.rValue;
            _loc2_ = ApplicationDomain.currentDomain.getDefinition("image" + param1.mInfo.imageID) as Class;
            this._imageMC = new _loc2_() as MovieClip;
            this._imageMC.scaleX = 0.58;
            this._imageMC.scaleY = 0.58;
            this._imageMC.x = this._pos.x;
            this._imageMC.y = this._pos.y;
            this._imageMC.gotoAndStop(2);
            addChild(this._imageMC);
         }
      }
      
      private function leizhuBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._data == null)
         {
            return;
         }
         var _loc2_:* = "";
         if(this.checkGeneralLevel() == false)
         {
            _loc2_ = "提示：此擂台上阵武将平均等级不可超过" + this._data.rLevel + "级，同时进入擂台的上阵武将等级差不可超过10级，请重新调整上阵武将后再次选择擂台。";
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":_loc2_
            }));
         }
         else if(this.checkBaomingfei() == false)
         {
            _loc2_ = "您的报名费不足，请重新选择擂台。";
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":_loc2_
            }));
         }
         else if(this.checkLeitaiStatus() == false)
         {
            _loc2_ = "此擂台已经有擂主。";
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":_loc2_
            }));
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.BECOME_LEIZHU,true,{"roomID":this._data.rID}));
         }
      }
      
      private function checkGeneralLevel() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:Array = RoleModel.getInstance().getChooseSoldiersSimpleList();
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length - 1)
         {
            _loc3_ += int(_loc2_[_loc4_].level);
            _loc1_ = 1;
            while(_loc1_ < _loc2_.length)
            {
               if(Math.abs(_loc2_[_loc4_].level - _loc2_[_loc1_].level) > 10)
               {
                  return false;
               }
               _loc1_++;
            }
            _loc4_++;
         }
         _loc3_ += int(_loc2_[_loc2_.length - 1].level);
         _loc3_ /= _loc2_.length;
         if(_loc3_ > this._data.rLevel)
         {
            return false;
         }
         return true;
      }
      
      private function checkBaomingfei() : Boolean
      {
         switch(int(this._data.rType))
         {
            case LeitaiType.YINZI:
               if(RoleModel.getInstance().money < int(this._data.rPrice))
               {
                  return false;
               }
               break;
            case LeitaiType.GONGXUN:
               if(RoleModel.getInstance().exploit < int(this._data.rPrice))
               {
                  return false;
               }
               break;
            case LeitaiType.DIANKA:
               if(RoleModel.getInstance().dianka < int(this._data.rPrice))
               {
                  return false;
               }
               break;
         }
         return true;
      }
      
      private function checkLeitaiStatus() : Boolean
      {
         if(int(this._data.rStatus) == LeitaiStatus.EMPTY)
         {
            return true;
         }
         if(this._data.mInfo != null)
         {
            if(RoleModel.getInstance().roleID == Number(this._data.mInfo.id))
            {
               return true;
            }
            return false;
         }
         return false;
      }
      
      private function gongleiBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._data == null)
         {
            return;
         }
         var _loc2_:* = "";
         if(this.checkGeneralLevel() == false)
         {
            _loc2_ = "提示：此擂台上阵武将平均等级不可超过" + this._data.rLevel + "级，同时进入擂台的上阵武将等级差不可超过10级，请重新调整上阵武将后再次选择擂台。";
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":_loc2_
            }));
         }
         else if(this.checkBaomingfei() == false)
         {
            _loc2_ = "您的报名费不足，请重新选择擂台。";
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":_loc2_
            }));
         }
         else if(this.checkLeitaiStatus() == true)
         {
            _loc2_ = "此擂台没有擂主。";
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":_loc2_
            }));
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.GONGLEI,true,{"roomID":this._data.rID}));
         }
      }
      
      public function get roomID() : int
      {
         if(this._data == null)
         {
            return -1;
         }
         return int(this._data.rID);
      }
   }
}
