package game.ui
{
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   
   public class NumTips extends Sprite
   {
       
      
      private var _appDomain:ApplicationDomain;
      
      public function NumTips(param1:ApplicationDomain = null)
      {
         super();
         this._appDomain = param1 == null ? ApplicationDomain.currentDomain : param1;
         mouseChildren = false;
         mouseEnabled = false;
      }
      
      public function addTips(param1:int, param2:Point, param3:Boolean = false) : *
      {
         var _loc4_:String = null;
         var _loc5_:Sprite = new Sprite();
         var _loc6_:String = String(param1);
         var _loc7_:MovieClip;
         // 暴击红字：替换减号为红色"暴"字前缀
         if(param3) {
            (_loc7_ = new (this._appDomain.getDefinition("num_jianhao"))()).scaleX = 0.8;
            _loc7_.scaleY = 0.8;
            _loc7_.transform.colorTransform = new flash.geom.ColorTransform(1,0,0,1,255,0,0,0);
            _loc5_.addChild(_loc7_);
         } else {
            (_loc7_ = new (this._appDomain.getDefinition("num_jianhao"))()).scaleX = 0.8;
            _loc7_.scaleY = 0.8;
            _loc5_.addChild(_loc7_);
         }
         var _loc8_:* = 0;
         var _redCT:flash.geom.ColorTransform = new flash.geom.ColorTransform(1,0,0,1,255,0,0,0);
         while(_loc8_ < _loc6_.length)
         {
            _loc4_ = _loc6_.substr(_loc8_,1);
            (_loc7_ = new (this._appDomain.getDefinition("num_0" + _loc4_))()).scaleX = 0.8;
            _loc7_.scaleY = 0.8;
            _loc7_.x = _loc5_.width;
            if(param3) _loc7_.transform.colorTransform = _redCT;
            _loc5_.addChild(_loc7_);
            _loc8_++;
         }
         _loc5_.x = param2.x - _loc5_.width / 2;
         _loc5_.y = param2.y;
         addChild(_loc5_);
         if(param3)
         {
            TweenLite.to(_loc5_,0.7,{
               "y":param2.y - 100,
               "onComplete":this.onTweenHandler,
               "onCompleteParams":[_loc5_]
            });
         }
         else
         {
            TweenLite.to(_loc5_,0.7,{
               "y":param2.y - 100,
               "onComplete":this.onTweenHandler,
               "onCompleteParams":[_loc5_]
            });
         }
      }
      
      public function addTips2(param1:int, param2:Point, param3:Boolean = false) : *
      {
         var _loc7_:MovieClip = null;
         var _loc4_:String = null;
         var _loc5_:Sprite = new Sprite();
         var _loc6_:String = String(param1);
         (_loc7_ = new (this._appDomain.getDefinition("lvnum_jianhao"))()).scaleX = 0.8;
         _loc7_.scaleY = 0.8;
         _loc5_.addChild(_loc7_);
         var _loc8_:* = 0;
         while(_loc8_ < _loc6_.length)
         {
            _loc4_ = _loc6_.substr(_loc8_,1);
            (_loc7_ = new (this._appDomain.getDefinition("lvnum_0" + _loc4_))()).scaleX = 0.8;
            _loc7_.scaleY = 0.8;
            _loc7_.x = _loc5_.width;
            _loc5_.addChild(_loc7_);
            _loc8_++;
         }
         _loc5_.x = param2.x - _loc5_.width / 2;
         _loc5_.y = param2.y;
         addChild(_loc5_);
         if(param3)
         {
            TweenLite.to(_loc5_,1.2,{
               "y":param2.y - 60,
               "onComplete":this.onTweenHandler,
               "onCompleteParams":[_loc5_]
            });
         }
         else
         {
            TweenLite.to(_loc5_,1.2,{
               "y":param2.y - 60,
               "onComplete":this.onTweenHandler,
               "onCompleteParams":[_loc5_]
            });
         }
      }
      
      public function addShanbi(param1:Point, param2:Boolean = false) : *
      {
         var _loc3_:Sprite = null;
         _loc3_ = new Sprite();
         var _loc4_:MovieClip;
         (_loc4_ = new (this._appDomain.getDefinition("num_shanbi"))()).scaleX = 0.8;
         _loc4_.scaleY = 0.8;
         _loc3_.addChild(_loc4_);
         _loc3_.x = param1.x - _loc3_.width / 2;
         _loc3_.y = param1.y;
         addChild(_loc3_);
         if(param2)
         {
            TweenLite.to(_loc3_,0.7,{
               "y":param1.y - 100,
               "onComplete":this.onTweenHandler,
               "onCompleteParams":[_loc3_]
            });
         }
         else
         {
            TweenLite.to(_loc3_,0.7,{
               "y":param1.y - 100,
               "onComplete":this.onTweenHandler,
               "onCompleteParams":[_loc3_]
            });
         }
      }
      
      public function onTweenHandler(param1:Sprite) : *
      {
         removeChild(param1);
      }
   }
}
