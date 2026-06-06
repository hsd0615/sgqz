package game.ui
{
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.events.UIEvent;
   
   public class NetStatusUI extends BaseUI
   {
       
      
      private var __returnBtn:SimpleButton;
      
      private var __enterBtn:SimpleButton;
      
      private var __comServerTF:TextField;
      
      private var __comServerMC:MovieClip;
      
      private var __loginServerTF:TextField;
      
      private var __loginServerMC:MovieClip;
      
      private var __fightServerTF:TextField;
      
      private var __fightServerMC:MovieClip;
      
      private var __talkServerTF:TextField;
      
      private var __talkServerMC:MovieClip;
      
      public var newPlayer:Boolean = false;
      
      public function NetStatusUI(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__returnBtn = _skin.getChildByName("_returnBtn") as SimpleButton;
         this.__enterBtn = _skin.getChildByName("_enterBtn") as SimpleButton;
         this.__comServerTF = _skin.getChildByName("_comServerTF") as TextField;
         this.__comServerMC = _skin.getChildByName("_comServerMC") as MovieClip;
         this.__loginServerTF = _skin.getChildByName("_loginServerTF") as TextField;
         this.__loginServerMC = _skin.getChildByName("_loginServerMC") as MovieClip;
         this.__fightServerTF = _skin.getChildByName("_fightServerTF") as TextField;
         this.__fightServerMC = _skin.getChildByName("_fightServerMC") as MovieClip;
         this.__talkServerTF = _skin.getChildByName("_talkServerTF") as TextField;
         this.__talkServerMC = _skin.getChildByName("_talkServerMC") as MovieClip;
         this.__comServerMC.visible = false;
         this.__loginServerMC.visible = false;
         this.__fightServerMC.visible = false;
         this.__talkServerMC.visible = false;
         this.__comServerTF.text = "";
         this.__loginServerTF.text = "";
         this.__fightServerTF.text = "";
         this.__talkServerTF.text = "";
      }
      
      override protected function initEvent() : void
      {
         this.__returnBtn.addEventListener(MouseEvent.CLICK,this.returnBtnClickHandler);
         this.__enterBtn.addEventListener(MouseEvent.CLICK,this.enterBtnClickHandler);
      }
      
      override public function initData(param1:Object) : void
      {
      }
      
      public function setStatus1(param1:String) : *
      {
         this.__comServerTF.text = param1;
      }
      
      public function setStatus2(param1:String) : *
      {
         this.__loginServerTF.text = param1;
      }
      
      public function setStatus3(param1:String) : *
      {
         this.__fightServerTF.text = param1;
      }
      
      public function setStatus4(param1:String) : *
      {
         this.__talkServerTF.text = param1;
      }
      
      public function setIcon1(param1:Boolean, param2:int) : *
      {
         this.__comServerMC.visible = param1;
         this.__comServerMC.gotoAndStop(param2);
      }
      
      public function setIcon2(param1:Boolean, param2:int) : *
      {
         this.__loginServerMC.visible = param1;
         this.__loginServerMC.gotoAndStop(param2);
      }
      
      public function setIcon3(param1:Boolean, param2:int) : *
      {
         this.__fightServerMC.visible = param1;
         this.__fightServerMC.gotoAndStop(param2);
      }
      
      public function setIcon4(param1:Boolean, param2:int) : *
      {
         this.__talkServerMC.visible = param1;
         this.__talkServerMC.gotoAndStop(param2);
      }
      
      public function setOkBtnEnabled(param1:Boolean) : *
      {
         Tools.setDisabled(this.__enterBtn,!param1);
      }
      
      public function setCancelBtnEnabled(param1:Boolean) : *
      {
         Tools.setDisabled(this.__returnBtn,!param1);
      }
      
      private function returnBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.SERVER_SUCCESS,true,{"newPlayer":this.newPlayer}));
      }
      
      private function enterBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.SERVER_SUCCESS,true,{"newPlayer":this.newPlayer}));
      }
   }
}
