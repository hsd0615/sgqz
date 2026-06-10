package game.display
{
   import flash.display.Bitmap; import flash.display.BitmapData; import flash.display.Loader;
   import flash.display.Sprite; import flash.events.Event; import flash.geom.Point; import flash.geom.Rectangle;
   import flash.net.URLRequest; import game.model.ArmyInfo;

   /** 帧动画兵种 — 4帧精灵表(站/走/攻/死) 覆盖在 AbstractSoldier 上 */
   public class FrameSoldier extends Sprite
   {
      private var _sheet:BitmapData; private var _frameW:int; private var _bmp:Bitmap;
      private var _frame:int=0; private var _host:AbstractSoldier;

      public function FrameSoldier(host:AbstractSoldier, sheetUrl:String, fw:int, fh:int)
      {
         _host=host;_frameW=fw;
         _bmp=new Bitmap(new BitmapData(fw,fh,true,0));
         _bmp.smoothing=true;_bmp.x=-fw/2;_bmp.y=-fh;
         addChild(_bmp);
         var self:FrameSoldier=this;
         var l:Loader=new Loader();
         l.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{
            _sheet=Bitmap(l.content).bitmapData;self.show(0);
         });
         l.load(new URLRequest(sheetUrl));
      }

      public function show(idx:int):void {
         _frame=idx;
         if(!_sheet)return;
         _bmp.bitmapData.copyPixels(_sheet,new Rectangle(idx*_frameW,0,_frameW,_sheet.height),new Point(0,0));
      }

      public function update() : void
      {
         if(!_host||!_host.parent)return;
         x=_host.x;y=_host.y;
         // 根据主机状态切换帧
         if(_host.isDead){show(3);return;}
         if(_host.fireing){show(2);return;}
         // 检测移动状态(简化：用x坐标变化判断)
         show(0);
      }
   }
}
