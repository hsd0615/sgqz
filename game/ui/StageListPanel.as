package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import game.Data;
   import game.events.UIEvent;
   import game.model.MyPoint;
   import game.model.RoleModel;
   import game.ui.list.StageList;
   
   public class StageListPanel extends BaseUI
   {
       
      
      private var __fightBtn:SimpleButton;
      
      private var __closeBtn:SimpleButton;
      
      private var _title:DisplayObject;
      
      private var _lastPoint:Point;
      
      private var _list:StageList;
      
      public function StageListPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__fightBtn = _skin.getChildByName("_fightBtn") as SimpleButton;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this._list = new StageList(542,255);
         this._list.x = -272;
         this._list.y = -142;
         addChild(this._list);
      }
      
      override protected function initEvent() : void
      {
         this.__fightBtn.addEventListener(MouseEvent.CLICK,this.fightBtnClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this._list.addEventListener(MouseEvent.MOUSE_DOWN,this.listMouseDownHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         if(param1 == null || (param1 is Array && (param1 as Array).length == 0))
         {
            var _errTF:TextField = new TextField();
            _errTF.defaultTextFormat = new TextFormat("SimHei",16,0xFF4444,true);
            _errTF.text = "暂无该章节数据\\n请重新登录后重试";
            _errTF.selectable = false;
            _errTF.width = 300;
            _errTF.height = 60;
            _errTF.x = -150;
            _errTF.y = -30;
            addChild(_errTF);
            return;
         }
         this.initTitle(param1[0].part);
         this._list.initData(param1);
      }
      
      private function initTitle(param1:int) : *
      {
         try
         {
            var _loc2_:Class = ApplicationDomain.currentDomain.getDefinition("listTitle_" + param1) as Class;
            this._title = new _loc2_() as MovieClip;
         }
         catch(_e:Error)
         {
            var _tf:TextField = new TextField();
            var _names:Array = ["","黄巾之乱","洛阳兵变","群雄逐鹿","赤壁之战","鏖战三国","奇袭蜀中","进军东吴","马踏中原","试炼之地","外敌入侵","邪魔入侵","时空漩涡"];
            var _colors:Array = [0,0xFFCC00,0xCC3333,0x3399FF,0xFF6600,0xCC0000,0x33CC66,0x3366FF,0xFF9900,0x9966FF,0xFF3366,0xFF0044,0x44AAFF];
            _tf.defaultTextFormat = new TextFormat("SimHei",20,_colors[param1]||0xFFCC00,true);
            _tf.text = _names[param1] || "第" + param1 + "章";
            _tf.selectable = false;
            _tf.width = 200;
            _tf.height = 40;
            this._title = _tf;
         }
         this._title.y = -186.5;
         addChild(this._title);
      }
      
      private function fightBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(MyPoint.stagePoint_old == null)
         {
            MyPoint.stagePoint_old = this._lastPoint.clone();
         }
         else
         {
            MyPoint.stagePoint_new = this._lastPoint.clone();
         }
         if(this._list.item == null)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"请选择你希望挑战的关卡。"
            }));
         }
         else if(this.checkStage() == false)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"挑战此关卡必须完成上一关卡，请先挑战上一关卡！"
            }));
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.CREATE_GATE,true,{
               "part":this._list.item.part,
               "level":this._list.item.level
            }));
            dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
         }
      }
      
      private function checkStage() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:Vector.<int> = RoleModel.getInstance().getFinished();
         if(_loc2_.length == 0)
         {
            _loc1_ = 0;
         }
         else
         {
            _loc1_ = _loc2_[_loc2_.length - 1];
         }
         var _loc3_:int = Data.getInstance().getStageID(this._list.item.part,this._list.item.level);
         if(_loc3_ - _loc1_ >= 2)
         {
            return false;
         }
         return true;
      }
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
      
      private function listMouseDownHandler(param1:MouseEvent) : *
      {
         this._lastPoint = new Point(param1.localX,param1.localY);
      }
   }
}
