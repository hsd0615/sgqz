package game.ui
{
   import flash.display.MovieClip;
   import game.model.ArmyInfo;
   import game.model.Type;
   
   public class FightUI extends MovieClip
   {
       
      
      private var _g1:GIcon;
      
      private var _g2:GIcon;
      
      private var _g3:GIcon;
      
      private var _g4:GIcon;
      
      private var _g5:GIcon;
      
      private var _direct:int;
      
      private var _gArr:Array;
      
      public function FightUI()
      {
         this._gArr = [];
         super();
         this.initView();
         this.initEvent();
      }
      
      protected function initView() : void
      {
         this._g1 = new GIcon(SkinCode.GICON);
         this._g2 = new GIcon(SkinCode.GICON);
         this._g3 = new GIcon(SkinCode.GICON);
         this._g4 = new GIcon(SkinCode.GICON);
         this._g5 = new GIcon(SkinCode.GICON);
         addChild(this._g1);
         addChild(this._g2);
         addChild(this._g3);
         addChild(this._g4);
         addChild(this._g5);
         this._gArr.push(this._g1);
         this._gArr.push(this._g2);
         this._gArr.push(this._g3);
         this._gArr.push(this._g4);
         this._gArr.push(this._g5);
      }
      
      protected function initEvent() : void
      {
      }
      
      public function initData(param1:Vector.<ArmyInfo>, param2:int = 1) : void
      {
         this._direct = param2;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            if(param1[_loc4_].type != Type.TOUSHICHE)
            {
               this._gArr[_loc3_].initData(param1[_loc4_]);
               this._gArr[_loc3_].index = _loc3_;
               _loc3_++;
            }
            _loc4_++;
         }
         this.setPos();
      }
      
      private function setPos() : *
      {
         if(this._direct == 1)
         {
            this._g1.x = 0;
            this._g2.x = this._g1.x + this._g1.width;
            this._g3.x = this._g2.x + this._g2.width;
            this._g4.x = this._g3.x + this._g3.width;
            this._g5.x = this._g4.x + this._g4.width;
         }
         else
         {
            this._g1.x = 540;
            this._g2.x = this._g1.x + this._g1.width;
            this._g3.x = this._g2.x + this._g2.width;
            this._g4.x = this._g3.x + this._g3.width;
            this._g5.x = this._g4.x + this._g4.width;
         }
      }
      
      public function checkDead(param1:Number, param2:String) : *
      {
         var _loc3_:int = 0;
         while(_loc3_ < this._gArr.length)
         {
            if(this._gArr[_loc3_].id == param1 && this._gArr[_loc3_].code == param2)
            {
               this._gArr[_loc3_].dead();
            }
            _loc3_++;
         }
      }
      
      public function setSelect(param1:int) : *
      {
         switch(param1)
         {
            case 1:
               this._g1.setSelect();
               break;
            case 2:
               this._g2.setSelect();
               break;
            case 3:
               this._g3.setSelect();
               break;
            case 4:
               this._g4.setSelect();
               break;
            case 5:
               this._g5.setSelect();
         }
      }
   }
}
