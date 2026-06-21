package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.Data;
   import game.events.FightEvent;
   import game.events.UIEvent;
   
   public class FightResultPanel extends BaseUI
   {
       
      
      private var __title0:MovieClip;
      
      private var __title1:MovieClip;
      
      private var __resultTF:TextField;
      
      private var __infoTF:TextField;
      
      private var __tipsTF:TextField;
      
      private var __fightBtn:SimpleButton;
      
      private var __closeBtn:SimpleButton;
      
      private var _part:int;
      
      private var _level:int;
      
      private var _p2p:Boolean;
      
      public function FightResultPanel(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__title0 = _skin.getChildByName("_title0") as MovieClip;
         this.__title1 = _skin.getChildByName("_title1") as MovieClip;
         this.__resultTF = _skin.getChildByName("_resultTF") as TextField;
         this.__infoTF = _skin.getChildByName("_infoTF") as TextField;
         this.__tipsTF = _skin.getChildByName("_tipsTF") as TextField;
         this.__fightBtn = _skin.getChildByName("_fightBtn") as SimpleButton;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__title0.visible = false;
         this.__title1.visible = false;
         this.__resultTF.text = "";
         this.__infoTF.text = "";
         this.__tipsTF.text = "";
      }
      
      override protected function initEvent() : void
      {
         this.__fightBtn.addEventListener(MouseEvent.CLICK,this.fightBtnClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
         this._p2p = param1.p2p;
         this._part = param1.part;
         this._level = param1.level;
         if(param1.p2p == false)
         {
            this.setInfoNoP2P(param1);
         }
         else
         {
            this.setInfoP2P(param1);
         }
      }
      
      private function setInfoNoP2P(param1:Object) : *
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc13_:int = 0;
         if(param1.flag == "lost")
         {
            this.__title0.visible = true;
            this.__resultTF.text = "挑战关卡- " + param1.stageName + "失败!";
            _loc2_ = "";
            _loc2_ += "对方军队实力太强，你的军队溃败！\n";
            _loc2_ += "<font color=\'#ffffff\'>战果：</font>无\n\n";
            this.__infoTF.htmlText = _loc2_;
            this.__tipsTF.htmlText = "提示：继续努力战斗吧，战胜对手才能更好发展自己的实力！";
         }
         else if(param1.flag == "win")
         {
            this.__title1.visible = true;
            this.__resultTF.text = "挑战关卡-" + param1.stageName + "成功!";
            this.__resultTF.textColor = 16724736;
            _loc3_ = "";
            _loc3_ += "你的军队奋勇杀敌，大胜！\n";
            _loc3_ += "<font color=\'#ffffff\'>战果：</font>";
            _loc3_ += "功勋+" + param1.exploit;
            _loc3_ += "、银子+" + param1.money;
            _loc3_ += "、声望+" + param1.reverence;
            _loc3_ += "\n";
            if(param1.addition != null)
            {
               _loc4_ = int(param1.addition.money);
               _loc5_ = int(param1.addition.reverence);
               _loc6_ = param1.addition.proto;
               _loc7_ = param1.addition.soldier;
               _loc8_ = String(param1.addition.recruit);
               _loc9_ = int(param1.addition.exploit);
               if(_loc4_ > 0 || _loc5_ > 0 || _loc9_ > 0 || _loc6_ != null || _loc7_ != null)
               {
                  _loc3_ += "\n<font color=\'#66CC33\'>特殊过关奖励：</font>\n";
               }
               if(_loc4_ > 0 && _loc5_ <= 0)
               {
                  _loc3_ += "银子+" + _loc4_ + "\n";
               }
               else if(_loc4_ > 0)
               {
                  _loc3_ += "银子+" + _loc4_ + "、";
               }
               if(_loc9_ > 0)
               {
                  _loc3_ += "功勋+" + _loc9_ + "、";
               }
               if(_loc5_ > 0)
               {
                  _loc3_ += "声望+" + _loc5_ + "\n";
               }
               else
               {
                  _loc3_ += "\n";
               }
               if(_loc7_ != null)
               {
                  _loc3_ += "获得武将：";
                  _loc10_ = 0;
                  while(_loc10_ < _loc7_.length)
                  {
                     _loc3_ += Data.getInstance().getAttributes("general",_loc7_[_loc10_],"name") + " ";
                     _loc10_++;
                  }
                  _loc3_ += "\n";
               }
               if(_loc6_ != null)
               {
                  _loc3_ += "获得道具：";
                  _loc11_ = 0;
                  while(_loc11_ < _loc6_.length)
                  {
                     _loc12_ = String(_loc6_[_loc11_].split(":")[0]);
                     _loc13_ = int(_loc6_[_loc11_].split(":")[1]);
                     _loc3_ += Data.getInstance().getAttributes("proto",_loc12_,"name") + "*" + _loc13_ + " ";
                     _loc11_++;
                  }
                  _loc3_ += "\n";
               }
               this.__tipsTF.htmlText += "\n提示：武将升级或进化后，战斗力将得到很大提升。";
               if(_loc8_ != null && _loc8_ != "" && _loc8_ != "undefined")
               {
                  this.__tipsTF.htmlText += "<font color=\'#66CC33\'>（武将-" + _loc8_ + "在野，通过招募有机会获得。）";
               }
            }
            else
            {
               this.__tipsTF.htmlText = "\n提示：武将升级或进化后，战斗力将得到很大提升。";
            }
            // 装备掉落显示
            if(param1.equipDrop != null) {
               _loc3_ += "\n<font color='#FFD700' size='13'>【装备掉落】</font>\n";
               var _ed:Object = param1.equipDrop;
               var _eqName:String = String(EquipData.get(_ed.code,"name") || _ed.name || "?");
               var _eqQ:int = int(_ed.quality||1);
               var _eqQColors:Array = ["#CCC","#CCC","#CCC","#4bea13","#16d2fa","#e720f9","#FFD700","#FF6600","#FF4444","#FF0000","#FFFFFF"];
               var _eqQNames:Array = ["","普通","精良","稀有","史诗","传说","神话","远古","至尊","超凡","入圣"];
               _loc3_ += "<font color='" + (_eqQColors[_eqQ]||"#CCC") + "'>" + _eqName + " [" + (_eqQNames[_eqQ]||"") + "]</font>\n";
            }
            this.__infoTF.htmlText = _loc3_;
         }
      }

      private function setInfoP2P(param1:Object) : *
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc4_:* = null;
         if(param1.flag == "lost")
         {
            this.__title0.visible = true;
            this.__resultTF.text = "你被" + param1.relativeName + "的军队打败了";
            _loc2_ = "";
            _loc2_ += "神马抵挡都是浮云，你的军队溃败！\n";
            _loc2_ += "<font color=\'#ffffff\'>战果：</font>无\n\n";
            this.__infoTF.htmlText = _loc2_;
            this.__infoTF.y += 15;
            this.__tipsTF.htmlText = "提示：继续努力战斗吧，战胜对手才能更好发展自己的实力！";
         }
         else if(param1.flag == "win")
         {
            this.__title1.visible = true;
            this.__resultTF.text = "你战胜了" + param1.relativeName + "的军队!";
            this.__resultTF.textColor = 16724736;
            _loc3_ = "";
            _loc3_ += "你的军队奋勇杀敌，大胜！\n";
            _loc3_ += "<font color=\'#ffffff\'>战果：</font>";
            _loc3_ += "功勋+" + param1.exploit;
            _loc3_ += "、银子+" + param1.money;
            _loc3_ += "、声望+" + param1.reverence;
            _loc3_ += "\n";
            this.__infoTF.y += 30;
            this.__infoTF.htmlText = _loc3_;
         }
         else
         {
            this.__title1.visible = true;
            this.__resultTF.text = "对方军队一看形势不妙，收兵撤退!";
            this.__resultTF.textColor = 16724736;
            _loc4_ = (_loc4_ = (_loc4_ = (_loc4_ = (_loc4_ = (_loc4_ = (_loc4_ = "") + "你的军队获得了胜利！\n") + "<font color=\'#ffffff\'>战果：</font>") + ("功勋+" + param1.exploit)) + ("、银子+" + param1.money)) + ("、声望+" + param1.reverence)) + "\n";
            this.__infoTF.y += 30;
            this.__infoTF.htmlText = _loc4_;
         }
         this.__fightBtn.visible = false;
         this.__closeBtn.x = 0;
      }
      
      private function fightBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_STAGE,true,{"part":this._part}));
         dispatchEvent(new FightEvent(FightEvent.CLOSE_FIGHT,true));
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }
      
      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._p2p == true)
         {
            dispatchEvent(new FightEvent(FightEvent.CLOSE_P2P_FIGHT,true));
         }
         else
         {
            dispatchEvent(new FightEvent(FightEvent.CLOSE_FIGHT,true));
            dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
         }
      }
   }
}
