package game.ui.list
{
   import com.iflashigame.ui.BaseUI;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.model.RoleStatus;
   
   public class ListItem extends BaseUI
   {
       
      
      private var __bkMC:MovieClip;
      
      private var __frameMC:MovieClip;
      
      private var __idTF:TextField;
      
      private var __areaTF:TextField;
      
      private var __nameTF:TextField;
      
      private var __levelTF:TextField;
      
      private var __statusTF:TextField;
      
      private var _status:int;
      
      private var _active:Boolean;
      
      public var pID:String;
      
      private var __image:int;
      
      public function ListItem(param1:String, param2:ApplicationDomain = null)
      {
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__bkMC = _skin.getChildByName("_bkMC") as MovieClip;
         this.__frameMC = _skin.getChildByName("_frameMC") as MovieClip;
         this.__idTF = _skin.getChildByName("_idTF") as TextField;
         this.__areaTF = _skin.getChildByName("_areaTF") as TextField;
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
         this.pID = param1.pID;
         this.__image = param1.image;
         if(param1.bk != null)
         {
            this.setBK(param1.bk);
         }
         this.setFrame(false);
         if(param1.roleID != null)
         {
            if(param1.roleIDColor != null)
            {
               this.setRoleID(param1.roleID,param1.roleIDColor);
            }
            else
            {
               this.setRoleID(param1.roleID);
            }
         }
         if(param1.area != null)
         {
            if(param1.areaColor != null)
            {
               this.setArea(param1.area,param1.areaColor);
            }
            else
            {
               this.setArea(param1.area);
            }
         }
         if(param1.name != null)
         {
            if(param1.image % 2 == 1)
            {
               this.setName(param1.name,7134709);
            }
            else
            {
               this.setName(param1.name,16553365);
            }
         }
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
      
      public function setRoleID(param1:String, param2:uint = 16777215) : *
      {
         this.__idTF.text = param1;
         this.__idTF.textColor = param2;
      }
      
      public function setArea(param1:String, param2:uint = 16777215) : *
      {
         this.__areaTF.text = param1;
         this.__areaTF.textColor = param2;
      }
      
      public function setName(param1:String, param2:uint = 7134709) : *
      {
         this.__nameTF.text = param1;
         this.__nameTF.textColor = param2;
      }
      
      public function setLevel(param1:String, param2:uint = 16777215) : *
      {
         this.__levelTF.text = param1;
         this.__levelTF.textColor = param2;
      }
      
      public function setStatus(param1:int, param2:uint = 978457) : *
      {
         this._status = param1;
         if(this._status == RoleStatus.XIUZHAN)
         {
            this.__statusTF.text = "休战";
            this.__statusTF.textColor = 15135757;
         }
         else if(this._status == RoleStatus.FIGHT || this._status == RoleStatus.SEND || this._status == RoleStatus.RECIEVED)
         {
            this.__statusTF.text = "对战";
            this.__statusTF.textColor = 16069125;
         }
         else if(this._status == RoleStatus.NOMAL)
         {
            this.__statusTF.text = "空闲";
            this.__statusTF.textColor = 978457;
         }
      }
      
      public function getRoleID() : Number
      {
         return Number(this.__idTF.text);
      }
      
      public function getName() : String
      {
         return this.__nameTF.text;
      }
      
      public function getArea() : String
      {
         return this.__areaTF.text;
      }
      
      public function getLevel() : int
      {
         return int(this.__levelTF.text);
      }
      
      public function getStatus() : int
      {
         return this._status;
      }
      
      public function getImage() : int
      {
         return this.__image;
      }
   }
}
