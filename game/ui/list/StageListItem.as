package game.ui.list
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   
   public class StageListItem extends BaseUI
   {
       
      
      private var __bkMC:MovieClip;
      
      private var __frameMC:MovieClip;
      
      private var __levelTF:TextField;
      
      private var __nameTF:TextField;
      
      private var __groupTF:TextField;
      
      private var __statusTF:TextField;
      
      private var _status:int;
      
      private var _part:int;
      
      private var _active:Boolean;
      
      public function StageListItem(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__bkMC = _skin.getChildByName("_bkMC") as MovieClip;
         this.__frameMC = _skin.getChildByName("_frameMC") as MovieClip;
         this.__groupTF = _skin.getChildByName("_groupTF") as TextField;
         this.__nameTF = _skin.getChildByName("_nameTF") as TextField;
         this.__levelTF = _skin.getChildByName("_levelTF") as TextField;
         this.__statusTF = _skin.getChildByName("_statusTF") as TextField;
         mouseChildren = false;
      }
      
      override protected function initEvent() : void
      {
      }
      
      override public function initData(param1:Object) : void
      {
         this._part = param1.part;
         if(param1.bk != null)
         {
            this.setBK(param1.bk);
         }
         this.setFrame(false);
         if(param1.level != null)
         {
            if(param1.levelColor != null)
            {
               this.setLevel(param1.level,param1.levelColor);
            }
            else
            {
               this.setLevel(param1.level);
            }
         }
         if(param1.name != null)
         {
            if(param1.nameColor != null)
            {
               this.setName(param1.name,param1.nameColor);
            }
            else
            {
               this.setName(param1.name);
            }
         }
         if(param1.group != null)
         {
            if(param1.groupColor != null)
            {
               this.setGroup(param1.group,param1.groupColor);
            }
            else
            {
               this.setGroup(param1.group);
            }
         }
         if(param1.status != null)
         {
            if(param1.statusColor != null)
            {
               this.setStatus(param1.status,param1.statusColor);
            }
            else
            {
               this.setStatus(param1.status);
            }
         }
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHandler);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutHandler);
      }
      
      private function onMouseOverHandler(param1:MouseEvent) : *
      {
         if(!this._active)
         {
            this.setFrame(true);
         }
      }
      
      private function onMouseOutHandler(param1:MouseEvent) : *
      {
         if(!this._active)
         {
            this.setFrame(false);
         }
      }
      
      public function setBK(param1:int) : *
      {
         this.__bkMC.gotoAndStop(param1);
      }
      
      public function setFrame(param1:Boolean) : *
      {
         this.__frameMC.visible = param1;
      }
      
      public function setActive(param1:Boolean) : *
      {
         this._active = param1;
         if(this._active)
         {
            this.setFrame(true);
         }
         else
         {
            this.setFrame(false);
         }
      }
      
      public function get active() : Boolean
      {
         return this._active;
      }
      
      public function setName(param1:String, param2:uint = 16777215) : *
      {
         this.__nameTF.text = param1;
         this.__nameTF.textColor = param2;
      }
      
      public function setLevel(param1:String, param2:uint = 16777215) : *
      {
         this.__levelTF.text = param1;
         this.__levelTF.textColor = param2;
      }
      
      public function setGroup(param1:String, param2:uint = 16777215) : *
      {
         this.__groupTF.text = param1;
         this.__groupTF.textColor = param2;
      }
      
      public function setStatus(param1:int, param2:uint = 978457) : *
      {
         this._status = param1;
         if(this._status == 0)
         {
            this.__statusTF.text = "未通过";
            this.__statusTF.textColor = 16777215;
         }
         else
         {
            this.__statusTF.text = "已通过";
            this.__statusTF.textColor = 978457;
         }
      }
      
      public function get part() : int
      {
         return this._part;
      }
      
      public function get level() : int
      {
         return int(this.__levelTF.text);
      }
   }
}
