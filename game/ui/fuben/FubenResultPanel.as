package game.ui.fuben
{
   import com.iflashigame.sound.MySound;
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextFormat;
   import flash.text.TextFieldAutoSize;
   import game.model.RoleModel;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.SoundCode;
   import game.events.UIEvent;
   
   public class FubenResultPanel extends BaseUI
   {
       
      
      private var __title0:MovieClip;
      
      private var __title1:MovieClip;
      
      private var __tf:TextField;
      
      private var __restartBtn:SimpleButton;
      
      private var __nextBtn:SimpleButton;
      
      private var __exitBtn:SimpleButton;
      
      private var __okBtn:SimpleButton;

      private var _recruitBtn:Sprite;

      private var _recruitBtnTF:TextField;

      private var _superRecruitCode:String = "";

      private var _superRecruitName:String = "";

      private var _stageID:int;
      
      private var _index:int;
      
      private var _paiArr:Array;
      
      public function FubenResultPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__title0 = _skin.getChildByName("_title0") as MovieClip;
         this.__title1 = _skin.getChildByName("_title1") as MovieClip;
         this.__tf = _skin.getChildByName("_tf") as TextField;
         this.__restartBtn = _skin.getChildByName("_restartBtn") as SimpleButton;
         this.__nextBtn = _skin.getChildByName("_nextBtn") as SimpleButton;
         this.__exitBtn = _skin.getChildByName("_exitBtn") as SimpleButton;
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this.createRecruitBtn();
         this.hideAll();
      }
      
      private function hideAll() : *
      {
         this.__title0.visible = false;
         this.__title1.visible = false;
         this.__restartBtn.visible = false;
         this.__nextBtn.visible = false;
         this.__exitBtn.visible = false;
         this.__okBtn.visible = false;
         if(this._recruitBtn != null) this._recruitBtn.visible = false;
      }
      
      override protected function initEvent() : void
      {
         this.__restartBtn.addEventListener(MouseEvent.CLICK,this.restartBtnClickHandler);
         this.__nextBtn.addEventListener(MouseEvent.CLICK,this.nextBtnClickHandler);
         this.__exitBtn.addEventListener(MouseEvent.CLICK,this.exitBtnClickHandler);
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.okBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this._stageID = int(param1.stageID);
         this._index = int(param1.index);
         if(param1.pai != null)
         {
            this._paiArr = param1.pai;
         }
         if(param1.superRecruit != null)
         {
            this._superRecruitCode = param1.superRecruit.code;
            this._superRecruitName = param1.superRecruit.name;
         }
         else
         {
            this._superRecruitCode = "";
            this._superRecruitName = "";
         }
         if(int(param1.result) == 0)
         {
            this.showLost();
            MySound.getInstance().startEventSoundByName(SoundCode.LOST);
            return;
         }
         switch(this._index)
         {
            case 1:
               this.showResult1(param1.forward, param1.equipDrop);
               break;
            case 2:
               this.showResult2(param1.forward, param1.equipDrop);
               break;
            case 3:
               this.showResult3(param1.forward, param1.equipDrop);
         }
         MySound.getInstance().startEventSoundByName(SoundCode.WIN);
      }
      
      private function showLost() : *
      {
         this.hideAll();
         this.__title0.visible = true;
         this.__tf.text = "\n胜败乃兵家常事，请秣兵历马择时再战。";
         this.__restartBtn.visible = true;
         this.__exitBtn.visible = true;
      }
      
      private function showResult1(param1:Array, param2:Object = null) : *
      {
         this.hideAll();
         this.__title1.visible = true;
         var _loc2_:* = "已成功清除匈奴营寨前哨，请继续深入敌营。\n";
         _loc2_ += "过关奖励：银子+" + param1[0] + " 功勋+" + param1[1] + " 声望+" + param1[2] + "\n";
         if(param2 != null) {
            _loc2_ += "<font color='#FFD700'>【装备掉落】" + param2.name + " (品质" + param2.quality + ")</font>\n";
         }
         _loc2_ += "下一关奖励更丰厚，加油吧！";
         this.__tf.htmlText = _loc2_;
         this.__nextBtn.visible = true;
      }

      private function showResult2(param1:Array, param2:Object = null) : *
      {
         this.hideAll();
         this.__title1.visible = true;
         var _loc2_:* = "已剿灭匈奴营寨内围，请继续深入敌营，擒拿头目。\n";
         _loc2_ += "过关奖励：银子+" + param1[0] + " 功勋+" + param1[1] + " 声望+" + param1[2] + "\n";
         if(param2 != null) {
            _loc2_ += "<font color='#FFD700'>【装备掉落】" + param2.name + " (品质" + param2.quality + ")</font>\n";
         }
         _loc2_ += "过全部关卡可获得特殊奖励，继续加油！";
         this.__tf.htmlText = _loc2_;
         this.__nextBtn.visible = true;
      }

      private function showResult3(param1:Array, param2:Object = null) : *
      {
         this.hideAll();
         this.__title1.visible = true;
         var _loc2_:* = "匈奴头目已被成功擒获，任务完成。\n";
         _loc2_ += "过关奖励：银子+" + param1[0] + " 功勋+" + param1[1] + " 声望+" + param1[2] + "\n";
         if(param2 != null) {
            _loc2_ += "<font color='#FFD700'>【装备掉落】" + param2.name + " (品质" + param2.quality + ")</font>\n";
         }
         _loc2_ += "请进入翻牌界面抽取特殊奖励！";
         if(this._superRecruitCode != "")
         {
            _loc2_ += "\n\n<font color='#FF6600' size='16'>击败了" + this._superRecruitName + "！</font>\n";
            _loc2_ += "<font color='#FFD700'>可以使用1个求贤令直接招募该超级武将</font>";
         }
         this.__tf.htmlText = _loc2_;
         this.__okBtn.visible = true;
         if(this._superRecruitCode != "")
         {
            this.updateRecruitBtnState();
            this._recruitBtn.visible = true;
         }
      }
      
      private function restartBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.XIONGNU_CLICK,true));
      }
      
      private function nextBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.START_FUBEN,true,{
            "stageID":this._stageID,
            "index":this._index + 1
         }));
      }
      
      private function exitBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE_FUBEN,true));
      }
      
      private function okBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_FANPAI,true,{
            "pai":this._paiArr,
            "stageID":this._stageID
         }));
      }

      private function createRecruitBtn() : void
      {
         this._recruitBtn = new Sprite();
         this._recruitBtn.buttonMode = true;
         this._recruitBtn.mouseChildren = false;
         // 绘制按钮背景
         this._recruitBtn.graphics.beginFill(0xCC4400);
         this._recruitBtn.graphics.drawRoundRect(0, 0, 200, 35, 6, 6);
         this._recruitBtn.graphics.endFill();
         this._recruitBtn.filters = [new GlowFilter(0xFF6600, 0.8, 8, 8, 2)];
         // 按钮文字
         this._recruitBtnTF = new TextField();
         this._recruitBtnTF.defaultTextFormat = new TextFormat("SimHei", 14, 0xFFD700, true);
         this._recruitBtnTF.autoSize = TextFieldAutoSize.CENTER;
         this._recruitBtnTF.selectable = false;
         this._recruitBtnTF.mouseEnabled = false;
         this._recruitBtnTF.text = "使用求贤令招募";
         this._recruitBtnTF.x = (200 - this._recruitBtnTF.width) / 2;
         this._recruitBtnTF.y = 8;
         this._recruitBtn.addChild(this._recruitBtnTF);
         // 定位在确认按钮上方
         this._recruitBtn.x = (770 - 200) / 2;
         this._recruitBtn.y = 380;
         this._recruitBtn.addEventListener(MouseEvent.CLICK, this.recruitBtnClickHandler);
         addChild(this._recruitBtn);
      }

      private function updateRecruitBtnState() : void
      {
         var _count:int = RoleModel.getInstance().getBagItemCount("proto_3_3");
         if(_count <= 0)
         {
            this._recruitBtn.alpha = 0.5;
            this._recruitBtnTF.text = "求贤令不足 (剩余:" + _count + ")";
         }
         else
         {
            this._recruitBtn.alpha = 1.0;
            this._recruitBtnTF.text = "使用求贤令招募 " + this._superRecruitName + " (剩余:" + _count + ")";
         }
         this._recruitBtnTF.x = (200 - this._recruitBtnTF.width) / 2;
      }

      public function refreshRecruitBtn() : void
      {
         if(this._recruitBtn != null && this._superRecruitCode != "")
         {
            this.updateRecruitBtnState();
         }
      }

      private function recruitBtnClickHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         var _count:int = RoleModel.getInstance().getBagItemCount("proto_3_3");
         if(_count <= 0)
         {
            return;
         }
         dispatchEvent(new UIEvent(UIEvent.SUPER_RECRUIT, true, {
            "superGeneralCode": this._superRecruitCode
         }));
      }
   }
}
