package game.ui
{
   import com.iflashigame.controller.AESController;
   import com.iflashigame.talk.NetInfoType;
   import com.iflashigame.talk.TalkEvent;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.BlurFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFieldAutoSize;
   import game.Config;
   import game.Data;
   import game.Logic;
   import game.TextFactory;
   import game.events.UIEvent;
   import game.model.ArmyInfo;
   import game.model.EquipData;
   import game.model.Head;
   import game.model.RoleModel;
   import game.model.Type;
   import game.ui.EquipIconAssets;

   public class GeneralInfoPanel extends BaseUI
   {


      private var __nameTF:TextField;

      private var __titleTF:TextField;

      private var __valueTF:TextField;

      private var __xiaohaoTF:TextField;

      private var __shengjiBtn:SimpleButton;

      private var __jinhuaBtn:SimpleButton;

      private var __sxcxBtn:MovieClip;

      private var __kezhi1TF:TextField;

      private var __kezhi2TF:TextField;

      private var __kezhi3TF:TextField;

      private var __kezhi1Btn:MovieClip;

      private var __kezhi2Btn:MovieClip;

      private var __kezhi3Btn:MovieClip;

      private var __tianfuNameTF:TextField;

      private var __tianfuDescTF:TextField;

      private var __chongxiBtn:MovieClip;

      private var __jihuoBtn:MovieClip;

      private var __moneyTF:TextField;

      private var __exploitTF:TextField;

      private var __closeBtn:SimpleButton;

      private var __shopBtn:SimpleButton;

      private var _pos1:Point;

      private var _pos2:Point;

      private var _pos3:Point;

      private var _point:Point;

      private var _armyInfo:ArmyInfo;

      private var _general:MovieClip;

      private var _icon1:Sprite;

      private var _icon2:Sprite;

      private var _icon3:Sprite;

      // 6个装备槽 (皮肤中的MovieClip或程序化创建的Sprite)
      private var _equipSlots:Array = [];
      // 6个槽位的标签: 0=武器 1=铠甲 2=饰品Ⅰ 3=头盔 4=战靴 5=饰品Ⅱ
      private static const SLOT_LABELS:Array = ["武器","铠甲","饰品Ⅰ","头盔","战靴","饰品Ⅱ"];
      private var _equipBtn:Sprite;
      // 装备选择列表
      private var _bagList:Sprite;
      private var _selectingSlot:int = -1;

      public function GeneralInfoPanel(param1:String, param2:ApplicationDomain = null)
      {
         this._pos1 = new Point(-300,69);
         this._pos2 = new Point(-231,69);
         this._pos3 = new Point(-163,69);
         this._point = new Point(-235,-65);
         super(param1,param2);
      }

      override protected function initView() : void
      {
         this.__nameTF = _skin.getChildByName("_nameTF") as TextField;
         this.__titleTF = _skin.getChildByName("_titleTF") as TextField;
         this.__valueTF = _skin.getChildByName("_valueTF") as TextField;
         this.__xiaohaoTF = _skin.getChildByName("_xiaohaoTF") as TextField;
         this.__shengjiBtn = _skin.getChildByName("_shengjiBtn") as SimpleButton;
         this.__jinhuaBtn = _skin.getChildByName("_jinhuaBtn") as SimpleButton;
         this.__sxcxBtn = _skin.getChildByName("_sxcxBtn") as MovieClip;
         this.__kezhi1TF = _skin.getChildByName("_kezhi1TF") as TextField;
         this.__kezhi2TF = _skin.getChildByName("_kezhi2TF") as TextField;
         this.__kezhi3TF = _skin.getChildByName("_kezhi3TF") as TextField;
         this.__kezhi1Btn = _skin.getChildByName("_kezhi1Btn") as MovieClip;
         this.__kezhi2Btn = _skin.getChildByName("_kezhi2Btn") as MovieClip;
         this.__kezhi3Btn = _skin.getChildByName("_kezhi3Btn") as MovieClip;
         this.__tianfuNameTF = _skin.getChildByName("_tianfuNameTF") as TextField;
         this.__tianfuDescTF = _skin.getChildByName("_tianfuDescTF") as TextField;
         this.__chongxiBtn = _skin.getChildByName("_chongxiBtn") as MovieClip;
         this.__jihuoBtn = _skin.getChildByName("_jihuoBtn") as MovieClip;
         this.__moneyTF = _skin.getChildByName("_moneyTF") as TextField;
         this.__exploitTF = _skin.getChildByName("_exploitTF") as TextField;
         this.__closeBtn = _skin.getChildByName("_closeBtn") as SimpleButton;
         this.__shopBtn = _skin.getChildByName("_shopBtn") as SimpleButton;
         this.__kezhi1Btn.buttonMode = true;
         this.__kezhi2Btn.buttonMode = true;
         this.__kezhi3Btn.buttonMode = true;
         this.__jihuoBtn.buttonMode = true;
         this.__chongxiBtn.buttonMode = true;
         this.__sxcxBtn.buttonMode = true;
         this.__jihuoBtn.visible = false;
         this.__chongxiBtn.visible = false;
         this.__sxcxBtn.visible = true;

         // 创建6个装备槽(程序化, 放在武将模型左上)
         this.findEquipSlots();
         var _ai:int = 0;
         while(_ai < 6)
         {
            if(this._equipSlots[_ai] != null) addChild(this._equipSlots[_ai] as DisplayObject);
            _ai++;
         }

         // 创建装备选择列表(初始隐藏)
         this._bagList = new Sprite();
         this._bagList.visible = false;
         addChild(this._bagList);
      }

      /**
       * 创建6个透明交互覆盖层, 叠加在皮肤已有的装备槽背景图上
       *
       * 对齐策略(按优先级降级):
       *   ① 扫描_skin无实例名子对象 — 按尺寸+位置聚类发现真实槽位图形
       *   ② BitmapData像素扫描 — 检测金色矩形边框定位槽位
       *   ③ 锚点相对网格 — 以武将中心_point为原点偏移出2×3网格
       *   ④ 硬编码兜底 — 历史坐标值
       *
       * SWF皮肤中槽位为静态美术图形, 无实例名, 需代码创建交互层
       */
      private function findEquipSlots() : void
      {
         var _sW:int = 48;
         var _sH:int = 48;
         var _slotPositions:Array = null;
         var _candidates:Array;

         // ── 策略①: 扫描_skin中无名子对象, 自动发现槽位图形 ──
         if(_slotPositions == null && _skin != null)
         {
            _candidates = scanSkinChildren();
            if(_candidates.length >= 6)
            {
               _slotPositions = clusterSlotPositions(_candidates);
            }
         }

         // ── 策略②: BitmapData像素扫描 — 检测金色矩形边框 ──
         if(_slotPositions == null && _skin != null)
         {
            _candidates = scanPixelsForSlots();
            if(_candidates.length >= 6)
            {
               _slotPositions = clusterSlotPositions(_candidates);
            }
         }

         // ── 策略③: 锚点相对网格 (以武将中心_point为原点) ──
         if(_slotPositions == null)
         {
            var _anchorX:Number = this._point.x - 105;
            var _anchorY:Number = this._point.y - 85;
            _slotPositions = buildSlotGrid(_anchorX, _anchorY, 56, 54);
         }

         // ── 策略④: 硬编码兜底 ──
         if(_slotPositions == null)
         {
            _slotPositions = [
               {x:-340, y:-150}, {x:-284, y:-150}, {x:-228, y:-150},
               {x:-340, y:-96},  {x:-284, y:-96},  {x:-228, y:-96}
            ];
         }

         // ── 创建6个槽位Sprite (应用手动校准偏移) ──
         var _j:int = 0;
         while(_j < 6)
         {
            var _s:Sprite = new Sprite();
            _s.name = "equipSlot" + _j;
            _s.buttonMode = true;
            _s.mouseChildren = false;
            _s.x = _slotPositions[_j].x + CALIB_OFFSET_X;
            _s.y = _slotPositions[_j].y + CALIB_OFFSET_Y;

            // 暗色底 + 金色边框
            var _bb:Shape = new Shape();
            _bb.graphics.beginFill(0x1a1008, 0.85);
            _bb.graphics.lineStyle(1, 0xC8A84E, 0.8);
            _bb.graphics.drawRoundRect(0, 0, _sW, _sH, 5, 5);
            _bb.graphics.endFill();
            _s.addChild(_bb);

            // 槽位标签
            var _ltf:TextField = new TextField();
            _ltf.defaultTextFormat = new TextFormat("SimSun", 9, 0x8B6914);
            _ltf.text = SLOT_LABELS[_j];
            _ltf.selectable = false;
            _ltf.width = _sW;
            _ltf.height = 14;
            _ltf.x = 0;
            _ltf.y = _sH + 2;
            _s.addChild(_ltf);

            this._equipSlots[_j] = _s;
            _j++;
         }

         // Debug: 标注每个槽位的坐标
         if(DEBUG_SCAN)
         {
            debugDrawSlotLabels(_slotPositions);
         }
      }

      // 已知有实例名的子对象 — 扫描时排除
      private static const KNOWN_NAMES:Array = [
         "_nameTF","_titleTF","_valueTF","_xiaohaoTF",
         "_shengjiBtn","_jinhuaBtn","_sxcxBtn",
         "_kezhi1TF","_kezhi2TF","_kezhi3TF",
         "_kezhi1Btn","_kezhi2Btn","_kezhi3Btn",
         "_tianfuNameTF","_tianfuDescTF",
         "_chongxiBtn","_jihuoBtn",
         "_moneyTF","_exploitTF","_closeBtn","_shopBtn"
      ];

      /**
       * 扫描_skin中无实例名的DisplayObject, 找出可能是装备槽图形的对象
       * 筛选条件: 尺寸30~70px(方形), 位于武将上方区域
       * @return [{x,y,width,height}, ...] 按y再x排序
       */
      private function scanSkinChildren() : Array
      {
         var _result:Array = [];
         if(_skin == null) return _result;

         var _total:int = _skin.numChildren;
         var _ic:int = 0;
         while(_ic < _total)
         {
            var _child:DisplayObject = _skin.getChildAt(_ic);
            // 跳过有名实例
            if(_child.name != null && _child.name != "" && KNOWN_NAMES.indexOf(_child.name) >= 0)
            {
               _ic++; continue;
            }
            // 跳过 TextField / SimpleButton
            if(_child is TextField || _child is SimpleButton)
            {
               _ic++; continue;
            }

            // 获取子对象在_skin坐标系中的bounds
            var _rb:Rectangle = _child.getBounds(_skin);
            var _rw:Number = _rb.width;
            var _rh:Number = _rb.height;

            // 筛选: 近似方形, 尺寸在槽位范围(25~80px)
            if(_rw >= 25 && _rw <= 80 && _rh >= 25 && _rh <= 80)
            {
               var _ratio:Number = _rw / _rh;
               if(_ratio >= 0.55 && _ratio <= 1.8)
               {
                  // 记录中心坐标
                  _result.push({
                     x: _rb.x + _rw / 2,
                     y: _rb.y + _rh / 2,
                     width: _rw,
                     height: _rh
                  });
               }
            }
            _ic++;
         }

         // 按 y 再 x 排序(从上到下, 从左到右)
         _result.sortOn("y", Array.NUMERIC);
         // 稳定排序: 同一行内按x排
         var _sorted:Array = [];
         var _ki:int = 0;
         while(_ki < _result.length)
         {
            var _rowGroup:Array = [_result[_ki]];
            var _kj:int = _ki + 1;
            while(_kj < _result.length && Math.abs(_result[_kj].y - _result[_ki].y) < 25)
            {
               _rowGroup.push(_result[_kj]);
               _kj++;
            }
            _rowGroup.sortOn("x", Array.NUMERIC);
            _sorted = _sorted.concat(_rowGroup);
            _ki = _kj;
         }

         return _sorted;
      }

      // ── Debug: 设为true可在皮肤上画出检测候选标记(彩色十字) ──
      private static const DEBUG_SCAN:Boolean = true;
      // ── 手动校准偏移: 调整这些值移动整个槽位网格 ──
      private static const CALIB_OFFSET_X:int = 0;  // 正=右移
      private static const CALIB_OFFSET_Y:int = 0;  // 正=下移
      private var _debugLayer:Sprite = null;

      /**
       * 增强像素扫描: 检测高对比度圆形/blob区域
       * 不限定颜色 — 检测亮度边缘, 找环形/圆形特征
       * @return [{x,y}, ...] 候选中心点
       */
      private function scanPixelsForSlots() : Array
      {
         var _result:Array = [];
         if(_skin == null) return _result;

         var _sb:Rectangle = _skin.getBounds(_skin);
         if(_sb.width < 20 || _sb.height < 20) return _result;

         // 扫描范围: 皮肤全区域
         var _scanX:int = int(_sb.x);
         var _scanY:int = int(_sb.y);
         var _scanW:int = int(_sb.width);
         var _scanH:int = int(_sb.height);
         if(_scanW < 80 || _scanH < 80) return _result;
         if(_scanW > 500) _scanW = 500;
         if(_scanH > 400) _scanH = 400;

         var _bmd:BitmapData = null;
         try
         {
            _bmd = new BitmapData(_scanW, _scanH, true, 0);
            var _mtx:Matrix = new Matrix();
            _mtx.translate(-_scanX, -_scanY);
            _bmd.draw(_skin, _mtx, null, null, null, true);
         }
         catch(_err:Error)
         {
            if(_bmd != null) _bmd.dispose();
            return _result;
         }

         // ── 方法: 检测高对比度边缘 → 找圆形闭合轮廓 ──
         // 先转灰度, 然后找亮度峰值(亮色圆圈)和暗色中心
         var _step:int = 3;
         var _edgeHits:Array = [];

         var _py:int = _step;
         while(_py < _scanH - _step)
         {
            var _px:int = _step;
            while(_px < _scanW - _step)
            {
               var _c:uint = _bmd.getPixel32(_px, _py);
               var _a:int = (_c >> 24) & 0xFF;
               if(_a < 80) { _px += _step; continue; }

               // 检测局部区域对比度: 中心 vs 环形邻域
               var _cl:uint = _bmd.getPixel32(_px - _step, _py);
               var _cr:uint = _bmd.getPixel32(_px + _step, _py);
               var _cu:uint = _bmd.getPixel32(_px, _py - _step);
               var _cd:uint = _bmd.getPixel32(_px, _py + _step);

               var _lumC:Number = rgbLum(_c);
               var _lumL:Number = rgbLum(_cl);
               var _lumR:Number = rgbLum(_cr);
               var _lumU:Number = rgbLum(_cu);
               var _lumD:Number = rgbLum(_cd);

               // 高对比度: 中心与邻域亮度差 > 60
               var _contrast:Number = Math.max(
                  Math.abs(_lumC - _lumL), Math.abs(_lumC - _lumR),
                  Math.abs(_lumC - _lumU), Math.abs(_lumC - _lumD)
               );

               if(_contrast > 55)
               {
                  _edgeHits.push({x: _scanX + _px, y: _scanY + _py});
               }
               _px += _step;
            }
            _py += _step;
         }
         _bmd.dispose();

         if(DEBUG_SCAN) debugDrawMarkers(_edgeHits, 0xFF00FF); // 洋红色 = 像素扫描候选

         if(_edgeHits.length < 20) return _result;

         // 密度聚类: 将边沿命中点聚合成候选中心
         return densityCluster(_edgeHits, 25);
      }

      /** RGB转感知亮度 (0~255) */
      private function rgbLum(param1:uint) : Number
      {
         return 0.299 * ((param1 >> 16) & 0xFF)
              + 0.587 * ((param1 >> 8) & 0xFF)
              + 0.114 * (param1 & 0xFF);
      }

      /**
       * 密度聚类: 将散点按距离合并, 返回簇中心
       * @param points [{x,y}...]
       * @param radius 聚类半径(px)
       * @return [{x,y}...] 簇中心, 按y再x排序
       */
      private function densityCluster(param1:Array, param2:int) : Array
      {
         if(param1.length == 0) return [];

         var _clusters:Array = [];
         var _used:Object = {};

         for each(var _p:Object in param1)
         {
            if(_used[_p.x + "_" + _p.y]) continue;

            var _group:Array = [_p];
            _used[_p.x + "_" + _p.y] = true;

            // 扩张: 找半径内所有点
            var _changed:Boolean = true;
            while(_changed)
            {
               _changed = false;
               for each(var _q:Object in param1)
               {
                  var _key:String = _q.x + "_" + _q.y;
                  if(_used[_key]) continue;
                  for each(var _m:Object in _group)
                  {
                     var _dx:Number = _q.x - _m.x;
                     var _dy:Number = _q.y - _m.y;
                     if(_dx*_dx + _dy*_dy < param2*param2)
                     {
                        _group.push(_q);
                        _used[_key] = true;
                        _changed = true;
                        break;
                     }
                  }
               }
            }

            // 簇中心 = 平均
            var _sx:Number = 0, _sy:Number = 0;
            for each(var _n:Object in _group) { _sx += _n.x; _sy += _n.y; }
            _clusters.push({x: _sx / _group.length, y: _sy / _group.length, size: _group.length});
         }

         // 过滤: 至少3个点才算有效簇
         _clusters = _clusters.filter(function(item:*, idx:int, arr:Array):Boolean {
            return item.size >= 3;
         });

         // 按y再x排序
         _clusters.sortOn("y", Array.NUMERIC);
         var _sorted:Array = [];
         var _ki:int = 0;
         while(_ki < _clusters.length)
         {
            var _rowGroup:Array = [_clusters[_ki]];
            var _kj:int = _ki + 1;
            while(_kj < _clusters.length && Math.abs(_clusters[_kj].y - _clusters[_ki].y) < 35)
            {
               _rowGroup.push(_clusters[_kj]);
               _kj++;
            }
            _rowGroup.sortOn("x", Array.NUMERIC);
            _sorted = _sorted.concat(_rowGroup);
            _ki = _kj;
         }

         if(DEBUG_SCAN) debugDrawMarkers(_sorted, 0x00FFFF); // 青色 = 聚类结果

         return _sorted;
      }

      /**
       * 调试可视化: 大号彩色十字 + 编号
       */
      private function debugDrawMarkers(param1:Array, param2:uint) : void
      {
         if(_debugLayer == null)
         {
            _debugLayer = new Sprite();
            _debugLayer.name = "_debugScan";
            _debugLayer.mouseEnabled = false;
            _debugLayer.mouseChildren = false;
            addChild(_debugLayer);
         }

         var _g:Graphics = _debugLayer.graphics;
         _g.lineStyle(2, param2, 0.95);

         var _count:int = 0;
         for each(var _p:Object in param1)
         {
            if(_count > 30) break;

            var _cx:Number = _p.x;
            var _cy:Number = _p.y;
            // 大号十字线(12px)
            _g.moveTo(_cx - 12, _cy);
            _g.lineTo(_cx + 12, _cy);
            _g.moveTo(_cx, _cy - 12);
            _g.lineTo(_cx, _cy + 12);
            // 空心圆(半径8)
            _g.drawCircle(_cx, _cy, 8);

            // 编号标签
            var _tf:TextField = new TextField();
            _tf.defaultTextFormat = new TextFormat("_sans", 12, param2, true);
            _tf.text = String(_count);
            _tf.selectable = false;
            _tf.width = 24; _tf.height = 18;
            _tf.x = _cx + 10; _tf.y = _cy - 9;
            _debugLayer.addChild(_tf);

            _count++;
         }
      }

      /**
       * Debug: 在槽位左上角显示坐标
       */
      private function debugDrawSlotLabels(param1:Array) : void
      {
         if(_debugLayer == null)
         {
            _debugLayer = new Sprite();
            _debugLayer.name = "_debugScan";
            _debugLayer.mouseEnabled = false;
            _debugLayer.mouseChildren = false;
            addChild(_debugLayer);
         }

         var _j:int = 0;
         while(_j < 6)
         {
            var _tf:TextField = new TextField();
            _tf.defaultTextFormat = new TextFormat("_sans", 9, 0xFF4444, true);
            _tf.text = int(param1[_j].x) + "," + int(param1[_j].y);
            _tf.selectable = false;
            _tf.width = 60; _tf.height = 14;
            _tf.x = param1[_j].x + CALIB_OFFSET_X;
            _tf.y = param1[_j].y + CALIB_OFFSET_Y - 16;
            _debugLayer.addChild(_tf);
            _j++;
         }
      }

      /**
       * 从候选点中聚类出2×3网格的6个槽位中心
       */
      private function clusterSlotPositions(param1:Array) : Array
      {
         if(param1.length < 6)
         {
            return null;
         }

         // 按y坐标分成两组(上下两行)
         param1.sortOn("y", Array.NUMERIC);
         var _gapMax:Number = 0;
         var _gapIdx:int = int(param1.length / 2);
         var _gk:int = 0;
         while(_gk < param1.length - 1)
         {
            var _gy:Number = param1[_gk + 1].y - param1[_gk].y;
            if(_gy > _gapMax) { _gapMax = _gy; _gapIdx = _gk + 1; }
            _gk++;
         }

         var _topRow:Array = param1.slice(0, _gapIdx);
         var _botRow:Array = param1.slice(_gapIdx);

         _topRow.sortOn("x", Array.NUMERIC);
         _botRow.sortOn("x", Array.NUMERIC);

         var _result:Array = [];
         var _row:int = 0;
         while(_row < 2)
         {
            var _rowData:Array = (_row == 0) ? _topRow : _botRow;
            var _col:int = 0;
            while(_col < 3)
            {
               var _ci:int = int(_rowData.length * _col / 3);
               if(_ci >= _rowData.length) _ci = _rowData.length - 1;
               _result.push({
                  x: _rowData[_ci].x - 24,
                  y: _rowData[_ci].y - 24
               });
               _col++;
            }
            _row++;
         }

         return _result.length >= 6 ? _result.slice(0, 6) : null;
      }

      /**
       * 构建2行×3列槽位坐标网格
       */
      private function buildSlotGrid(param1:Number, param2:Number, param3:Number, param4:Number) : Array
      {
         var _result:Array = [];
         var _row:int = 0;
         while(_row < 2)
         {
            var _col:int = 0;
            while(_col < 3)
            {
               _result.push({
                  x: param1 + _col * param3,
                  y: param2 + _row * param4
               });
               _col++;
            }
            _row++;
         }
         return _result;
      }

      override protected function initEvent() : void
      {
         RoleModel.getInstance().addEventListener(Event.CHANGE,this.onRoleModelChange);
         this.__shengjiBtn.addEventListener(MouseEvent.CLICK,this.shengjiBtnClickHandler);
         this.__jinhuaBtn.addEventListener(MouseEvent.CLICK,this.jinhuaBtnClickHandler);
         this.__kezhi1Btn.addEventListener(MouseEvent.CLICK,this.kezhi1BtnClickHandler);
         this.__kezhi2Btn.addEventListener(MouseEvent.CLICK,this.kezhi2BtnClickHandler);
         this.__kezhi3Btn.addEventListener(MouseEvent.CLICK,this.kezhi3BtnClickHandler);
         this.__chongxiBtn.addEventListener(MouseEvent.CLICK,this.chongxiBtnClickHandler);
         this.__jihuoBtn.addEventListener(MouseEvent.CLICK,this.jihuoBtnClickHandler);
         this.__closeBtn.addEventListener(MouseEvent.CLICK,this.closeBtnClickHandler);
         this.__shopBtn.addEventListener(MouseEvent.CLICK,this.onShopBtnClickHandler);
         this.__sxcxBtn.addEventListener(MouseEvent.CLICK,this.onSxcxBtnClickHandler);

         // 6个装备槽点击事件
         var _si:int = 0;
         while(_si < 6)
         {
            var _slot:DisplayObject = this._equipSlots[_si] as DisplayObject;
            if(_slot != null)
            {
               if(_slot is Sprite) (_slot as Sprite).mouseEnabled = true;
               if(_slot is MovieClip) (_slot as MovieClip).mouseEnabled = true;
               if(_slot is Sprite) (_slot as Sprite).buttonMode = true;
               _slot.addEventListener(MouseEvent.CLICK, this.onEquipSlotClick);
            }
            _si++;
         }
      }

      override public function initData(param1:Object) : void
      {
         this._armyInfo = param1 as ArmyInfo;
         this.flush();
      }

      public function flush() : *
      {
         this.__nameTF.text = this._armyInfo.name + "\nLv:" + this._armyInfo.level;
         this.createGeneral(this._armyInfo.skin);
         this.__titleTF.htmlText = Type.createTitle(this._armyInfo.title);
         this.createValueTF();
         this.createXiaohaoTF();
         this.createKezhi();
         this.createTianfu();
         this.__moneyTF.text = RoleModel.getInstance().money.toString();
         this.__exploitTF.text = RoleModel.getInstance().exploit.toString();
         this.showEquipSlots();
         this.showEquipBtn();
      }

      private function showEquipBtn() : void
      {
         if(this._equipBtn != null) { removeChild(this._equipBtn); this._equipBtn = null; }
         this._equipBtn = new Sprite();
         var _bg:Shape = new Shape();
         _bg.graphics.beginFill(0x4a2010, 0.94);
         _bg.graphics.lineStyle(2, 0xFFD700, 0.9);
         _bg.graphics.drawRoundRect(0, 0, 80, 28, 6, 6);
         _bg.graphics.endFill();
         this._equipBtn.addChild(_bg);
         var _tf:TextField = new TextField();
         _tf.defaultTextFormat = new TextFormat("SimHei", 13, 0xFFD700, true);
         _tf.text = "装 备";
         _tf.selectable = false;
         _tf.autoSize = TextFieldAutoSize.CENTER;
         _tf.x = (80 - _tf.width) / 2; _tf.y = 4;
         this._equipBtn.addChild(_tf);
         this._equipBtn.buttonMode = true;
         this._equipBtn.x = this.__shengjiBtn.x;
         this._equipBtn.y = this.__shengjiBtn.y + this.__shengjiBtn.height + 6;
         var _self:GeneralInfoPanel = this;
         this._equipBtn.addEventListener(MouseEvent.CLICK, function(p:MouseEvent):void {
            p.stopImmediatePropagation();
            _self.dispatchEvent(new UIEvent(UIEvent.OPEN_EQUIP, true, _self._armyInfo));
         });
         addChild(this._equipBtn);
      }

      /**
       * 在6个装备槽中显示已装备的图标
       */
      private function showEquipSlots() : void
      {
         var _si:int = 0;
         while(_si < 6)
         {
            var _slot:DisplayObject = this._equipSlots[_si] as DisplayObject;
            if(_slot == null) { _si++; continue; }
            var _eqCode:String = this._armyInfo.getEquipSlot(_si);

            // 清除旧图标 - 只移除Bitmap, 保留背景Shape(确保点击区域)
            if(_slot is Sprite)
            {
               var _spr:Sprite = _slot as Sprite;
               var _ci:int = _spr.numChildren - 1;
               while(_ci >= 0)
               {
                  var _child:* = _spr.getChildAt(_ci);
                  if(_child is Bitmap) _spr.removeChildAt(_ci);
                  _ci--;
               }
            }
            if(_slot is MovieClip)
            {
               var _mc:MovieClip = _slot as MovieClip;
               var _cim:int = _mc.numChildren - 1;
               while(_cim >= 0)
               {
                  if(_mc.getChildAt(_cim) is Bitmap) _mc.removeChildAt(_cim);
                  _cim--;
               }
            }

            // 记录槽位索引
            _slot.name = "equipSlot" + _si;

            if(_eqCode != null && _eqCode != "" && _eqCode != "0")
            {
               // 显示装备图标
               var _bmp:Bitmap = this.getEquipBmp(_eqCode);
               if(_bmp != null)
               {
                  _bmp.scaleX = 0.3;
                  _bmp.scaleY = 0.3;
                  _bmp.smoothing = true;
                  _bmp.x = int((_slot.width - _bmp.width) / 2);
                  _bmp.y = int((_slot.height - _bmp.height) / 2);
                  if(_bmp.x < 0) _bmp.x = 0;
                  if(_bmp.y < 0) _bmp.y = 0;
                  if(_slot is Sprite)
                  {
                     (_slot as Sprite).addChild(_bmp);
                  }
                  else
                  {
                     (_slot as MovieClip).addChild(_bmp);
                  }
               }
               // 品质光晕
               var _q:int = int(EquipData.get(_eqCode,"quality"));
               _slot.filters = [new GlowFilter(getQualityColor(_q), 0.5, 4, 4, 1)];
            }
            else
            {
               // 空槽 - 去除光晕
               _slot.filters = [];
            }
            _si++;
         }
      }

      private function getEquipBmp(param1:String) : Bitmap
      {
         if(param1 == null || param1 == "") return null;
         var _parts:Array = param1.split("_");
         var _num:int = 0;
         if(_parts.length >= 3) _num = int(_parts[_parts.length - 1]);
         if(_num >= 26) return EquipIconAssets.accessory();
         if(_num >= 21) return EquipIconAssets.accessory();
         if(_num >= 16) return EquipIconAssets.boots();
         if(_num >= 11) return EquipIconAssets.armor();
         if(_num >= 6) return EquipIconAssets.helmet();
         return EquipIconAssets.weapon();
      }

      private var _qualityColors:Array = [0x999999,0xCCCCCC,0x4bea13,0x16d2fa,0xe720f9,0xFFD700];
      private var _qualityNames:Array = ["","普通","精良","稀有","史诗","传说"];
      private function getQualityColor(param1:int):uint { return _qualityColors[param1] || 0xCCCCCC; }

      /**
       * 装备槽点击处理: 空→弹列表选装备, 已有→卸下
       */
      private function onEquipSlotClick(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         var _slotName:String = (param1.currentTarget as DisplayObject).name;
         // 从 "equipSlot0" 提取索引
         var _slotIdx:int = int(_slotName.replace("equipSlot",""));
         if(_slotIdx < 0 || _slotIdx > 5) return;

         var _eqCode:String = this._armyInfo.getEquipSlot(_slotIdx);
         if(_eqCode != null && _eqCode != "" && _eqCode != "0")
         {
            this.unequipItem(_slotIdx);
         }
         else
         {
            this.showEquipBagList(_slotIdx);
         }
      }

      private function unequipItem(param1:int) : void
      {
         var _self:GeneralInfoPanel = this;
         var _obj:Object = {};
         _obj.head = Head.HTTP_NEW_UNEQUIP;
         _obj.agent = Config.AGENT;
         _obj.ver = Config.VER;
         _obj.token = Config.token;
         _obj.roleID = RoleModel.getInstance().roleID;
         _obj.userID = RoleModel.getInstance().userID;
         _obj.id = this._armyInfo.id;
         _obj.slot = param1;
         _obj.mask = true;
         AESController.getInstance().sendJSON(_obj, function(param2:Object):void {
            if(param2.success == true)
            {
               if(param2.data.general)
               {
                  _self._armyInfo.setEquipSlot(param1, "");
                  _self._armyInfo.hp = _self._armyInfo.hp;
               }
               if(param2.data.bagModel)
               {
                  RoleModel.getInstance().initBagModel(param2.data.bagModel);
               }
               if(param2.data.money != undefined) RoleModel.getInstance().money = int(param2.data.money);
               _self.flush();
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"装备已卸下,已放回背包。"}));
            }
            else
            {
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:param2.message||"卸下失败"}));
            }
         });
      }

      private function showEquipBagList(param1:int) : void
      {
         this.hideEquipBagList();
         this._selectingSlot = param1;
         var _items:Array = RoleModel.getInstance().getBagEquipItems(param1 + 1);
         if(_items.length == 0)
         {
            this.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"背包中没有可用的" + SLOT_LABELS[param1] + "类装备。"}));
            return;
         }

         // 列表放在面板中央
         this._bagList.x = 100;
         this._bagList.y = 180;
         var _listW:int = 240;
         var _listH:int = Math.min(_items.length, 5) * 26 + 8;
         this._bagList.graphics.clear();
         this._bagList.graphics.beginFill(0x1a1008, 0.97);
         this._bagList.graphics.lineStyle(1, 0x8B6914, 0.9);
         this._bagList.graphics.drawRoundRect(0, 0, _listW, _listH, 5, 5);
         this._bagList.graphics.endFill();

         var _self:GeneralInfoPanel = this;
         var _ii:int = 0;
         while(_ii < _items.length)
         {
            var _item:Object = _items[_ii];
            var _elr:* = EquipData.get(_item.code,"levelReq");
            var _row:Sprite = new Sprite();
            _row.y = 4 + _ii * 26;
            var _rowTF:TextField = new TextField();
            _rowTF.defaultTextFormat = new TextFormat("SimSun", 11, 0xD4C8A0);
            _rowTF.selectable = false;
            _rowTF.width = _listW - 8; _rowTF.height = 20;
            _rowTF.x = 4; _rowTF.y = 0;
            var _txt:String = formatEquipInfo(_item.code);
            _txt += "  Lv." + (int(_elr)||1);
            if(this._armyInfo.level < (int(_elr)||1))
            {
               _txt += " (等级不足)";
               _rowTF.textColor = 0x666666;
            }
            else
            {
               var _q2:int = int(EquipData.get(_item.code,"quality"));
               _rowTF.textColor = getQualityColor(_q2);
            }
            _rowTF.text = _txt;
            _row.addChild(_rowTF);
            _row.buttonMode = (this._armyInfo.level >= (int(_elr)||1));
            _row.name = _item.code;
            _row.addEventListener(MouseEvent.CLICK, function(p:*):void {
               var _code:String = p.currentTarget.name;
               _self.equipItem(_self._selectingSlot, _code);
            });
            this._bagList.addChild(_row);
            _ii++;
         }
         this._bagList.visible = true;
      }

      private function hideEquipBagList() : void
      {
         this._bagList.visible = false;
         while(this._bagList.numChildren > 0) this._bagList.removeChildAt(0);
         this._selectingSlot = -1;
      }

      private function equipItem(param1:int, param2:String) : void
      {
         var _self:GeneralInfoPanel = this;
         var _obj:Object = {};
         _obj.head = Head.HTTP_NEW_EQUIP;
         _obj.agent = Config.AGENT;
         _obj.ver = Config.VER;
         _obj.token = Config.token;
         _obj.roleID = RoleModel.getInstance().roleID;
         _obj.userID = RoleModel.getInstance().userID;
         _obj.id = this._armyInfo.id;
         _obj.slot = param1;
         _obj.itemCode = param2;
         _obj.mask = true;
         AESController.getInstance().sendJSON(_obj, function(param3:Object):void {
            if(param3.success == true)
            {
               if(param3.data.general)
               {
                  var _eqArr:Array = param3.data.general.equipment.split(",");
                  if(_eqArr.length > param1 && _eqArr[param1] != "0")
                  {
                     _self._armyInfo.setEquipSlot(param1, _eqArr[param1]);
                  }
                  else
                  {
                     _self._armyInfo.setEquipSlot(param1, param2);
                  }
               }
               if(param3.data.bagModel)
               {
                  RoleModel.getInstance().initBagModel(param3.data.bagModel);
               }
               if(param3.data.money != undefined) RoleModel.getInstance().money = int(param3.data.money);
               _self.flush();
               var _en2:* = EquipData.get(param2,"name");
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:"已装备 " + String(_en2||"")}));
            }
            else
            {
               _self.dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{type:0,text:param3.message||"装备失败"}));
            }
         });
      }

      private function formatEquipInfo(param1:String):String
      {
         if(param1 == "" || param1 == null || param1 == "0") return "空";
         var _n:* = EquipData.get(param1,"name");
         var _atk:* = EquipData.get(param1,"attack");
         var _atkp:* = EquipData.get(param1,"attackPct");
         var _def:* = EquipData.get(param1,"defense");
         var _defp:* = EquipData.get(param1,"defensePct");
         var _hp:* = EquipData.get(param1,"hp");
         var _hpp:* = EquipData.get(param1,"hpPct");
         var _q:int = int(EquipData.get(param1,"quality"));
         var _s:String = "[" + this._qualityNames[_q] + "] " + String(_n||"?");
         if(int(_atk) > 0) _s += " 攻+" + int(_atk);
         if(int(_atkp) > 0) _s += " 攻+" + int(_atkp) + "%";
         if(int(_def) > 0) _s += " 防+" + int(_def);
         if(int(_defp) > 0) _s += " 防+" + int(_defp) + "%";
         if(int(_hp) > 0) _s += " HP+" + int(_hp);
         if(int(_hpp) > 0) _s += " HP+" + int(_hpp) + "%";
         return _s;
      }

      private function createGeneral(param1:String) : *
      {
         if(this._general != null)
         {
            removeChild(this._general);
            this._general = null;
         }
         var _loc2_:Class = ApplicationDomain.currentDomain.getDefinition(param1) as Class;
         this._general = new _loc2_() as MovieClip;
         this._general.mouseChildren = false;
         if(this._armyInfo.code == "general_5_19" || this._armyInfo.type == Type.JUNZHU)
         {
            this._general.scaleX = 0.52;
            this._general.scaleY = 0.52;
         }
         else if(this._general.evolution > 1)
         {
            this._general.scaleX = 0.65;
            this._general.scaleY = 0.65;
         }
         else
         {
            this._general.scaleX = 0.65;
            this._general.scaleY = 0.65;
         }
         this._general.x = this._point.x;
         this._general.y = this._point.y;
         addChild(this._general);
         var _loc3_:Shape = new Shape();
         _loc3_.graphics.beginFill(16764006);
         _loc3_.graphics.drawEllipse(-40,-12,80,24);
         _loc3_.filters = [new BlurFilter(20,12)];
         this._general.addChildAt(_loc3_,0);
      }

      private function createKezhi() : void
      {
         if(this._icon1 != null)
         {
            this._icon1.removeEventListener(MouseEvent.MOUSE_OVER,this.iconOverHandler);
            this._icon1.removeEventListener(MouseEvent.MOUSE_OUT,this.iconOutHandler);
            removeChild(this._icon1);
            this._icon1 = null;
         }
         if(this._icon2 != null)
         {
            this._icon2.removeEventListener(MouseEvent.MOUSE_OVER,this.iconOverHandler);
            this._icon2.removeEventListener(MouseEvent.MOUSE_OUT,this.iconOutHandler);
            removeChild(this._icon2);
            this._icon2 = null;
         }
         if(this._icon3 != null)
         {
            this._icon3.removeEventListener(MouseEvent.MOUSE_OVER,this.iconOverHandler);
            this._icon3.removeEventListener(MouseEvent.MOUSE_OUT,this.iconOutHandler);
            removeChild(this._icon3);
            this._icon3 = null;
         }
         if(this._armyInfo.type == Type.TOUSHICHE)
         {
            this.__kezhi1TF.text = "无克制";
            this.__kezhi2TF.text = "无克制";
            this.__kezhi3TF.text = "无克制";
            Tools.setDisabled(this.__kezhi1Btn,true);
            Tools.setDisabled(this.__kezhi2Btn,true);
            Tools.setDisabled(this.__kezhi3Btn,true);
            return;
         }
         var _loc1_:Class = ApplicationDomain.currentDomain.getDefinition("kezhiIcon" + this._armyInfo.kezhi1) as Class;
         this._icon1 = new Sprite();
         this._icon1.addChild(new Bitmap(new _loc1_() as BitmapData));
         _loc1_ = ApplicationDomain.currentDomain.getDefinition("kezhiIcon" + this._armyInfo.kezhi2) as Class;
         this._icon2 = new Sprite();
         this._icon2.addChild(new Bitmap(new _loc1_() as BitmapData));
         _loc1_ = ApplicationDomain.currentDomain.getDefinition("kezhiIcon" + this._armyInfo.kezhi3) as Class;
         this._icon3 = new Sprite();
         this._icon3.addChild(new Bitmap(new _loc1_() as BitmapData));
         this._icon1.x = this._pos1.x;
         this._icon1.y = this._pos1.y;
         this._icon2.x = this._pos2.x;
         this._icon2.y = this._pos2.y;
         this._icon3.x = this._pos3.x;
         this._icon3.y = this._pos3.y;
         addChild(this._icon1);
         addChild(this._icon2);
         addChild(this._icon3);
         this._icon1.addEventListener(MouseEvent.MOUSE_OVER,this.iconOverHandler);
         this._icon2.addEventListener(MouseEvent.MOUSE_OVER,this.iconOverHandler);
         this._icon3.addEventListener(MouseEvent.MOUSE_OVER,this.iconOverHandler);
         this._icon1.addEventListener(MouseEvent.MOUSE_OUT,this.iconOutHandler);
         this._icon2.addEventListener(MouseEvent.MOUSE_OUT,this.iconOutHandler);
         this._icon3.addEventListener(MouseEvent.MOUSE_OUT,this.iconOutHandler);
         this.__kezhi1TF.text = Type.createKezhiStr(this._armyInfo.kezhi1) + this._armyInfo.kezhiLevel1.toString() + "级";
         this.__kezhi2TF.text = Type.createKezhiStr(this._armyInfo.kezhi2) + this._armyInfo.kezhiLevel2.toString() + "级";
         this.__kezhi3TF.text = Type.createKezhiStr(this._armyInfo.kezhi3) + this._armyInfo.kezhiLevel3.toString() + "级";
         if(this._armyInfo.kezhiLevel1 > 9)
         {
            Tools.setDisabled(this.__kezhi1Btn,true);
         }
         else
         {
            Tools.setDisabled(this.__kezhi1Btn,false);
         }
         if(this._armyInfo.kezhiLevel2 > 9)
         {
            Tools.setDisabled(this.__kezhi2Btn,true);
         }
         else
         {
            Tools.setDisabled(this.__kezhi2Btn,false);
         }
         if(this._armyInfo.kezhiLevel3 > 9)
         {
            Tools.setDisabled(this.__kezhi3Btn,true);
         }
         else
         {
            Tools.setDisabled(this.__kezhi3Btn,false);
         }
      }

      private function iconOverHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         var _loc2_:String = "";
         if(param1.currentTarget == this._icon1)
         {
            _loc2_ += Type.createKezhiStr(this._armyInfo.kezhi1) + "\n";
            _loc2_ += "攻击与防御额外提升" + Logic.kezhiBilv[this._armyInfo.kezhiLevel1] + "%";
         }
         else if(param1.currentTarget == this._icon2)
         {
            _loc2_ += Type.createKezhiStr(this._armyInfo.kezhi2) + "\n";
            _loc2_ += "攻击与防御额外提升" + Logic.kezhiBilv[this._armyInfo.kezhiLevel2] + "%";
         }
         else if(param1.currentTarget == this._icon3)
         {
            _loc2_ += Type.createKezhiStr(this._armyInfo.kezhi3) + "\n";
            _loc2_ += "攻击与防御额外提升" + Logic.kezhiBilv[this._armyInfo.kezhiLevel3] + "%";
         }
         dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
            "htmlText":_loc2_,
            "type":3,
            "width":150,
            "height":45
         }));
      }

      private function iconOutHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
      }

      private function createTianfu() : void
      {
         if(this._armyInfo.type == Type.TOUSHICHE)
         {
            this.__tianfuNameTF.text = "无";
            this.__tianfuDescTF.text = "投石车无天赋属性，其他类型武将可以免费激活武将天赋。";
            this.__chongxiBtn.visible = false;
            this.__jihuoBtn.visible = false;
         }
         else if(this._armyInfo.tianfu == null)
         {
            this.__tianfuNameTF.text = "点击激活按钮，免费激活武将天赋";
            this.__tianfuDescTF.text = "天赋激活后，如果对武将天赋属性不满意可以使用点卡重洗天赋。";
            this.__chongxiBtn.visible = false;
            this.__jihuoBtn.visible = true;
         }
         else
         {
            this.__tianfuNameTF.text = Data.getInstance().getAttributes("tianfu",this._armyInfo.tianfu,"name");
            this.__tianfuDescTF.text = Data.getInstance().getAttributes("tianfu",this._armyInfo.tianfu,"desc");
            this.__chongxiBtn.visible = true;
            this.__jihuoBtn.visible = false;
         }
      }

      private function createValueTF() : void
      {
         var _loc1_:* = "";
         _loc1_ += Type.createType(this._armyInfo.type) + "\n";
         _loc1_ += this._armyInfo.attack + "\n";
         _loc1_ += this._armyInfo.defense + "\n";
         _loc1_ += this._armyInfo.hp + "\n";
         _loc1_ += this._armyInfo.attackDistance + "\n";
         if(this._armyInfo.evolution == 0)
         {
            if(this._armyInfo.level < 30)
            {
               _loc1_ += "    无 <font color=\'#4bea13\'>(30级后可以进化)</font>\n";
            }
            else
            {
               _loc1_ += "    无 <font color=\'#4bea13\'>(进化后获得加成)</font>\n";
            }
            Tools.setDisabled(this.__sxcxBtn,true);
         }
         else
         {
            _loc1_ += "    " + this._armyInfo.evolution + "级 <font color=\'#4bea13\'>全属性增加" + this._armyInfo.getAddtion() * 100 + "%</font>\n";
            Tools.setDisabled(this.__sxcxBtn,false);
         }
         if(this._armyInfo.feature == 0)
         {
            if(this._armyInfo.type == Type.TOUSHICHE)
            {
               _loc1_ += "    无\n";
            }
            else
            {
               _loc1_ += "    无 <font color=\'#4bea13\'>(进化后获得属相)</font>\n";
            }
         }
         else if(this._armyInfo.feature == 1)
         {
            if(this._armyInfo.type == Type.TOUSHICHE)
            {
               _loc1_ += "    无\n";
            }
            else
            {
               _loc1_ += "    <font color=\'#16d2fa\'>冰</font>";
               _loc1_ += " <font color=\'#f45415\'>克制火，被雷克制</font>\n";
            }
         }
         else if(this._armyInfo.feature == 2)
         {
            _loc1_ += "    <font color=\'#ff3333\'>火</font>";
            _loc1_ += " <font color=\'#f45415\'>克制风，被冰克制</font>\n";
         }
         else if(this._armyInfo.feature == 3)
         {
            _loc1_ += "    <font color=\'#4bea13\'>风</font>";
            _loc1_ += " <font color=\'#f45415\'>克制雷，被火克制</font>\n";
         }
         else if(this._armyInfo.feature == 4)
         {
            _loc1_ += "    <font color=\'#e720f9\'>雷</font>";
            _loc1_ += " <font color=\'#f45415\'>克制冰，被风克制</font>\n";
         }
         if(this._armyInfo.equipAttackBonus > 0 || this._armyInfo.equipDefenseBonus > 0 || this._armyInfo.equipHPBonus > 0)
         {
            _loc1_ += "<font color='#FFD700'>--装备加成--</font>\n";
            if(this._armyInfo.equipAttackFlat > 0) _loc1_ += "攻击 <font color='#4bea13'>+" + this._armyInfo.equipAttackFlat + "</font>";
            if(this._armyInfo.equipAttackPct > 0) _loc1_ += " <font color='#4bea13'>+" + this._armyInfo.equipAttackPct + "%</font>";
            if(this._armyInfo.equipAttackFlat > 0 || this._armyInfo.equipAttackPct > 0) _loc1_ += " ";
            if(this._armyInfo.equipDefenseFlat > 0) _loc1_ += "防御 <font color='#16d2fa'>+" + this._armyInfo.equipDefenseFlat + "</font>";
            if(this._armyInfo.equipDefensePct > 0) _loc1_ += " <font color='#16d2fa'>+" + this._armyInfo.equipDefensePct + "%</font>";
            if(this._armyInfo.equipDefenseFlat > 0 || this._armyInfo.equipDefensePct > 0) _loc1_ += " ";
            if(this._armyInfo.equipHPFlat > 0) _loc1_ += "生命 <font color='#ff3333'>+" + this._armyInfo.equipHPFlat + "</font>";
            if(this._armyInfo.equipHPPct > 0) _loc1_ += " <font color='#ff3333'>+" + this._armyInfo.equipHPPct + "%</font>";
            _loc1_ += "\n";
         }
         this.__valueTF.htmlText = _loc1_;
      }

      private function createXiaohaoTF() : void
      {
         this.__xiaohaoTF.text = "需要功勋 " + Logic.getExploitByLevel(this._armyInfo.level) + "\n需要银子 " + Logic.getMoneyByLevel(this._armyInfo.level);
      }

      private function onRoleModelChange(param1:Event) : void
      {
         if(this.__moneyTF) this.__moneyTF.text = RoleModel.getInstance().money.toString();
         if(this.__exploitTF) this.__exploitTF.text = RoleModel.getInstance().exploit.toString();
      }

      private function shengjiBtnClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         param1.stopImmediatePropagation();
         if(this._armyInfo.level < 200)
         {
            _loc2_ = Logic.getMoneyByLevel(this._armyInfo.level);
            _loc3_ = Logic.getExploitByLevel(this._armyInfo.level);
            if(RoleModel.getInstance().money >= _loc2_ && RoleModel.getInstance().exploit >= _loc3_)
            {
               this.sendToHttpNew(Head.HTTP_NEW_GENERAL_SHENGJI);
            }
            else
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"所需功勋或银子不足，无法提升等级。"
               }));
            }
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"武将更高等级尚未开放，请关注官方最新消息。"
            }));
         }
      }

      private function jinhuaBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._armyInfo.evolution >= 10)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"武将更高进化等级尚未开放，请关注官方消息"
            }));
         }
         else if(this._armyInfo.level >= 30)
         {
            dispatchEvent(new UIEvent(UIEvent.JINHUA_CLICK,true,this._armyInfo));
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"武将等级不满足进化要求，30级以后才能进化。\n提示：武将进化后可获得全属性加成，并随机获得攻击属相。"
            }));
         }
      }

      private function kezhi1BtnClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:* = null;
         param1.stopImmediatePropagation();
         if(RoleModel.getInstance().getBagItemCount("proto_3_4") < 1)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"您没有克制进阶符，无法升级。克制进阶符在副本中抽取，也可以在商城中购买。"
            }));
         }
         else if(RoleModel.getInstance().money < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有足够的银子，进阶克制属性需要消耗1000银子。"
            }));
         }
         else if(RoleModel.getInstance().exploit < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有足够的功勋，进阶克制属性需要消耗1000功勋。"
            }));
         }
         else if(this._armyInfo.kezhiLevel1 > 9)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"克制等级最高为10级。"
            }));
         }
         else
         {
            _loc2_ = Type.createKezhiStr(this._armyInfo.kezhi1) + "进阶至" + (this._armyInfo.kezhiLevel1 + 1) + "级，对战";
            _loc2_ += Type.createType(this._armyInfo.kezhi1);
            _loc2_ += "时攻击和防御提升" + Logic.kezhiBilv[this._armyInfo.kezhiLevel1 + 1];
            _loc2_ += "%\n";
            _loc2_ += "进阶成功率：" + Logic.getKezhiJilv(this._armyInfo.kezhiLevel1) * 100 + "%\n";
            _loc2_ += "进阶消耗：克制进阶符1个、 功勋1000、银子1000";
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":1,
               "text":_loc2_,
               "fun":this.jinjie1
            }));
         }
      }

      private function jinjie1() : *
      {
         this.sendToHttpNew(Head.HTTP_NEW_GENERAL_KEZHI_SHENGJI,0);
      }

      private function kezhi2BtnClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:* = null;
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.SHUANGKAI_POST,true));
         if(RoleModel.getInstance().getBagItemCount("proto_3_4") < 1)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"您没有克制进阶符，无法升级。克制进阶符在副本中抽取，也可以在商城中购买。"
            }));
         }
         else if(RoleModel.getInstance().money < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有足够的银子，进阶克制属性需要消耗1000银子。"
            }));
         }
         else if(RoleModel.getInstance().exploit < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有足够的功勋，进阶克制属性需要消耗1000功勋。"
            }));
         }
         else if(this._armyInfo.kezhiLevel2 > 9)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"克制等级最高为10级。"
            }));
         }
         else
         {
            _loc2_ = Type.createKezhiStr(this._armyInfo.kezhi2) + "进阶至" + (this._armyInfo.kezhiLevel2 + 1) + "级，对战";
            _loc2_ += Type.createType(this._armyInfo.kezhi2);
            _loc2_ += "时攻击和防御提升" + Logic.kezhiBilv[this._armyInfo.kezhiLevel2 + 1];
            _loc2_ += "%\n";
            _loc2_ += "进阶成功率：" + Logic.getKezhiJilv(this._armyInfo.kezhiLevel2) * 100 + "%\n";
            _loc2_ += "进阶消耗：克制进阶符1个、 功勋1000、银子1000";
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":1,
               "text":_loc2_,
               "fun":this.jinjie2
            }));
         }
      }

      private function jinjie2() : *
      {
         this.sendToHttpNew(Head.HTTP_NEW_GENERAL_KEZHI_SHENGJI,1);
      }

      private function kezhi3BtnClickHandler(param1:MouseEvent) : *
      {
         var _loc2_:* = null;
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.SHUANGKAI_POST,true));
         if(RoleModel.getInstance().getBagItemCount("proto_3_4") < 1)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"您没有克制进阶符，无法升级。克制进阶符在副本中抽取，也可以在商城中购买。"
            }));
         }
         else if(RoleModel.getInstance().money < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有足够的银子，进阶克制属性需要消耗1000银子。"
            }));
         }
         else if(RoleModel.getInstance().exploit < 1000)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"没有足够的功勋，进阶克制属性需要消耗1000功勋。"
            }));
         }
         else if(this._armyInfo.kezhiLevel3 > 9)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"克制等级最高为10级。"
            }));
         }
         else
         {
            _loc2_ = Type.createKezhiStr(this._armyInfo.kezhi3) + "进阶至" + (this._armyInfo.kezhiLevel3 + 1) + "级，对战";
            _loc2_ += Type.createType(this._armyInfo.kezhi3);
            _loc2_ += "时攻击和防御提升" + Logic.kezhiBilv[this._armyInfo.kezhiLevel3 + 1];
            _loc2_ += "%\n";
            _loc2_ += "进阶成功率：" + Logic.getKezhiJilv(this._armyInfo.kezhiLevel3) * 100 + "%\n";
            _loc2_ += "进阶消耗：克制进阶符1个、 功勋1000、银子1000";
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":1,
               "text":_loc2_,
               "fun":this.jinjie3
            }));
         }
      }

      private function jinjie3() : *
      {
         this.sendToHttpNew(Head.HTTP_NEW_GENERAL_KEZHI_SHENGJI,2);
      }

      private function chongxiBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
            "type":1,
            "text":"重洗武将天赋需要花费100点卡，是否确认使用？",
            "fun":this.realyChongxi
         }));
      }

      private function realyChongxi() : *
      {
         if(RoleModel.getInstance().dianka < 100)
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"点卡不足，无法重洗武将天赋。"
            }));
         }
         else
         {
            this.sendToHttpNew(Head.HTTP_NEW_GENERAL_TIANFU);
         }
      }

      private function jihuoBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         this.sendToHttpNew(Head.HTTP_NEW_GENERAL_TIANFU);
      }

      private function closeBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
      }

      private function onShopBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         dispatchEvent(new UIEvent(UIEvent.OPEN_SHOP,true));
      }

      private function sendToHttpNew(param1:int, param2:int = 1) : *
      {
         var _loc3_:Object = {};
         _loc3_.head = param1;
         _loc3_.agent = Config.AGENT;
         _loc3_.ver = Config.VER;
         _loc3_.token = Config.token;
         _loc3_.roleID = RoleModel.getInstance().roleID;
         _loc3_.userID = RoleModel.getInstance().userID;
         _loc3_.id = this._armyInfo.id;
         _loc3_.mask = true;
         switch(param1)
         {
            case Head.HTTP_NEW_GENERAL_SHENGJI:
               AESController.getInstance().sendJSON(_loc3_,this.shengjiResponse);
               break;
            case Head.HTTP_NEW_GENERAL_KEZHI_SHENGJI:
               _loc3_.index = param2;
               AESController.getInstance().sendJSON(_loc3_,this.kezhiResponse);
               break;
            case Head.HTTP_NEW_GENERAL_TIANFU:
               AESController.getInstance().sendJSON(_loc3_,this.tianfuResponse);
               break;
            case Head.HTTP_NEW_SHUXINGCHONGXI:
               AESController.getInstance().sendJSON(_loc3_,this.sxcxResponse);
         }
      }

      private function shengjiResponse(param1:Object) : *
      {
         var _loc2_:String = null;
         if(param1.success == true)
         {
            RoleModel.getInstance().money = param1.data.money;
            RoleModel.getInstance().exploit = param1.data.exploit;
            this._armyInfo.setLevel(param1.data.level);
            RoleModel.getInstance().throttleSave();
            this.flush();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }

      private function kezhiResponse(param1:Object) : *
      {
         var _loc2_:String = null;
         if(param1.success == true)
         {
            RoleModel.getInstance().money = param1.data.money + 100;
            RoleModel.getInstance().exploit = param1.data.exploit + 100;
            RoleModel.getInstance().delBagItemByID(param1.data.itemID);
            if(param1.data.general != null)
            {
               this._armyInfo.setKezhiStr(param1.data.general.kezhi);
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"克制属性进阶成功。"
               }));
               if(param1.data.index == 0)
               {
                  _loc2_ = TextFactory.makeKezhiJinjie(RoleModel.getInstance().roleName,this._armyInfo.name,Type.createType(this._armyInfo.kezhi1),this._armyInfo.kezhiLevel1.toString());
                  dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                     "type":NetInfoType.SYSTEM,
                     "text":_loc2_
                  }));
               }
               else if(param1.data.index == 1)
               {
                  _loc2_ = TextFactory.makeKezhiJinjie(RoleModel.getInstance().roleName,this._armyInfo.name,Type.createType(this._armyInfo.kezhi2),this._armyInfo.kezhiLevel2.toString());
                  dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                     "type":NetInfoType.SYSTEM,
                     "text":_loc2_
                  }));
               }
               else if(param1.data.index == 2)
               {
                  _loc2_ = TextFactory.makeKezhiJinjie(RoleModel.getInstance().roleName,this._armyInfo.name,Type.createType(this._armyInfo.kezhi3),this._armyInfo.kezhiLevel3.toString());
                  dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                     "type":NetInfoType.SYSTEM,
                     "text":_loc2_
                  }));
               }
               RoleModel.getInstance().throttleSave();
            }
            else
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"克制属性进阶失败。"
               }));
            }
            this.flush();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }

      private function tianfuResponse(param1:Object) : *
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         if(param1.success == true)
         {
            if(RoleModel.getInstance().dianka == int(param1.data.dianka))
            {
               this._armyInfo.tianfu = param1.data.general.genius;
               this.flush();
               this.__jihuoBtn.visible = false;
               this.__chongxiBtn.visible = true;
            }
            else
            {
               RoleModel.getInstance().dianka = param1.data.dianka;
               this._armyInfo.tianfu = param1.data.general.genius;
               this.flush();
               _loc2_ = int(Data.getInstance().getAttributes("tianfu",this._armyInfo.tianfu,"level"));
               if(_loc2_ == 3)
               {
                  _loc3_ = TextFactory.makeTianfu(RoleModel.getInstance().roleName,this._armyInfo);
                  dispatchEvent(new TalkEvent(TalkEvent.NET_INFO,true,{
                     "type":NetInfoType.SYSTEM,
                     "text":_loc3_
                  }));
               }
            }
            RoleModel.getInstance().throttleSave();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }

      private function onSxcxBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._armyInfo.feature > 0)
         {
            if(RoleModel.getInstance().dianka < 100)
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":0,
                  "text":"点卡不足，无法重洗武将属相。"
               }));
            }
            else
            {
               dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
                  "type":1,
                  "text":"重洗武将属相需要花费100点卡，是否确认使用？",
                  "fun":this.realSxcxFun
               }));
            }
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":"此武将尚未进化，无法重洗属性。"
            }));
         }
      }

      private function realSxcxFun() : *
      {
         this.sendToHttpNew(Head.HTTP_NEW_SHUXINGCHONGXI);
      }

      private function sxcxResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            RoleModel.getInstance().dianka = param1.data.dianka;
            this._armyInfo.feature = param1.data.feature;
            this.flush();
            RoleModel.getInstance().throttleSave();
         }
         else
         {
            dispatchEvent(new UIEvent(UIEvent.MESSAGE,true,{
               "type":0,
               "text":param1.message
            }));
         }
      }
   }
}
