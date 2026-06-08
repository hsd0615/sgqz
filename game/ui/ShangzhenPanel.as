package game.ui
{
   import com.iflashigame.controller.AESController;
   import com.iflashigame.net.ChatManager;
   import com.iflashigame.net.P2PEvent;
   import com.iflashigame.ui.BaseUI;
   import com.iflashigame.utils.Tools;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import game.Config;
   import game.Data;
   import game.events.UIEvent;
   import game.model.ArmyInfo;
   import game.model.Head;
   import game.model.RoleModel;
   import game.model.Type;
   
   public class ShangzhenPanel extends BaseUI
   {
       
      
      private var __preBtn:SimpleButton;
      
      private var __nextBtn:SimpleButton;
      
      private var __okBtn:SimpleButton;
      
      private var __pageTF:TextField;
      
      private var _pos11:Point;
      
      private var _pos12:Point;
      
      private var _pos13:Point;
      
      private var _pos14:Point;
      
      private var _pos15:Point;
      
      private var _qixie:Point;
      
      private var _pos21:Point;
      
      private var _pos22:Point;
      
      private var _pos23:Point;
      
      private var _pos24:Point;
      
      private var _pos25:Point;
      
      private var _pos26:Point;
      
      private var _block11:GeneralBlock;
      
      private var _block12:GeneralBlock;
      
      private var _block13:GeneralBlock;
      
      private var _block14:GeneralBlock;
      
      private var _block15:GeneralBlock;
      
      private var _junshiBlock:JunshiBlock;
      
      private var _qixieBlock:JunshiBlock;
      
      private var _block21:GeneralBlock;
      
      private var _block22:GeneralBlock;
      
      private var _block23:GeneralBlock;
      
      private var _block24:GeneralBlock;
      
      private var _block25:GeneralBlock;
      
      private var _block26:GeneralBlock;
      
      private var _chooseArmy:Vector.<ArmyInfo>;
      
      private var _allArmy:Vector.<ArmyInfo>;
      
      private var _currentPage:int;
      
      private var _maxPage:int;
      
      public function ShangzhenPanel(param1:String, param2:ApplicationDomain = null)
      {
         this._pos11 = new Point(-350.6,-205.65);
         this._pos12 = new Point(-238.9,-205.65);
         this._pos13 = new Point(-127.2,-205.65);
         this._pos14 = new Point(-15.5,-205.65);
         this._pos15 = new Point(96.35,-205.65);
         this._qixie = new Point(240.45,-133.9);
         this._pos21 = new Point(-337.55,13.55);
         this._pos22 = new Point(-222.8,13.55);
         this._pos23 = new Point(-108.05,13.55);
         this._pos24 = new Point(6.7,13.55);
         this._pos25 = new Point(121.45,13.55);
         this._pos26 = new Point(236.4,13.55);
         super(param1,param2);
      }
      
      override protected function initView() : void
      {
         this.__preBtn = _skin.getChildByName("_preBtn") as SimpleButton;
         this.__nextBtn = _skin.getChildByName("_nextBtn") as SimpleButton;
         this.__okBtn = _skin.getChildByName("_okBtn") as SimpleButton;
         this.__pageTF = _skin.getChildByName("_pageTF") as TextField;
      }
      
      override protected function initEvent() : void
      {
         this.__preBtn.addEventListener(MouseEvent.CLICK,this.preBtnClickHandler);
         this.__nextBtn.addEventListener(MouseEvent.CLICK,this.nextBtnClickHandler);
         this.__okBtn.addEventListener(MouseEvent.CLICK,this.okBtnClickHandler);
         addEventListener(MouseEvent.CLICK,this.onMouseClickHandler);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverHandler);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutHandler);
      }
      
      private function onMouseOverHandler(param1:MouseEvent) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:* = null;
         param1.stopImmediatePropagation();
         if(param1.target is GeneralBlock || param1.target is JunshiBlock)
         {
            if(param1.target.active == true)
            {
               _loc2_ = param1.target;
               _loc3_ = "";
               _loc3_ += "<font face=\'_sans\'>";
               _loc3_ += this.createTitle(_loc2_.armyInfo.title);
               _loc3_ += "<font color=\'#e5ce10\'>姓名：</font>" + _loc2_.armyInfo.name + "\n";
               _loc3_ += "<font color=\'#e5ce10\'>等级：</font>" + _loc2_.armyInfo.level + "\n";
               _loc3_ += "<font color=\'#e5ce10\'>类型：</font>" + this.createType(_loc2_.armyInfo.type);
               _loc3_ += "<font color=\'#e5ce10\'>攻击：</font>";
               _loc3_ += _loc2_.armyInfo.attack + "\n";
               _loc3_ += "<font color=\'#e5ce10\'>防御：</font>";
               _loc3_ += _loc2_.armyInfo.defense + "\n";
               _loc3_ += "<font color=\'#e5ce10\'>血量：</font>";
               _loc3_ += _loc2_.armyInfo.hp + "\n";
               _loc3_ += "<font color=\'#e5ce10\'>射程：</font>";
               _loc3_ += _loc2_.armyInfo.attackDistance + "\n";
               _loc3_ += "<font color=\'#e5ce10\'>进化等级：</font>";
               if(_loc2_.armyInfo.evolution == 0)
               {
                  _loc3_ += "无\n";
               }
               else
               {
                  _loc3_ += _loc2_.armyInfo.evolution + "级 <font color=\'#4bea13\'>全属性增加" + _loc2_.armyInfo.getAddtion() * 100 + "%</font>\n";
               }
               _loc3_ += "<font color=\'#e5ce10\'>攻击属相：</font>";
               if(_loc2_.armyInfo.feature == 0)
               {
                  _loc3_ += "无\n";
               }
               else if(_loc2_.armyInfo.feature == 1)
               {
                  _loc3_ += "<font color=\'#16d2fa\'>冰</font>";
                  _loc3_ += " <font color=\'#f45415\'>克制火，被雷克制</font>\n";
               }
               else if(_loc2_.armyInfo.feature == 2)
               {
                  _loc3_ += "<font color=\'#ff3333\'>火</font>";
                  _loc3_ += " <font color=\'#f45415\'>克制风，被冰克制</font>\n";
               }
               else if(_loc2_.armyInfo.feature == 3)
               {
                  _loc3_ += "<font color=\'#4bea13\'>风</font>";
                  _loc3_ += " <font color=\'#f45415\'>克制雷，被火克制</font>\n";
               }
               else if(_loc2_.armyInfo.feature == 4)
               {
                  _loc3_ += "<font color=\'#e720f9\'>雷</font>";
                  _loc3_ += " <font color=\'#f45415\'>克制冰，被风克制</font>\n";
               }
               if(_loc2_.armyInfo.type != Type.TOUSHICHE)
               {
                  if(_loc2_.armyInfo.tianfu != null)
                  {
                     _loc3_ += "<font color=\'#e5ce10\'>天赋：</font>" + Data.getInstance().getAttributes("tianfu",_loc2_.armyInfo.tianfu,"name") + "\n";
                  }
                  else
                  {
                     _loc3_ += "<font color=\'#e5ce10\'>天赋：</font>" + "无\n";
                  }
                  _loc3_ += "<font color=\'#e5ce10\'>克制" + Type.TYPE_NAME[_loc2_.armyInfo.kezhi1] + ":</font>" + _loc2_.armyInfo.kezhiLevel1 + "级\n";
                  _loc3_ += "<font color=\'#e5ce10\'>克制" + Type.TYPE_NAME[_loc2_.armyInfo.kezhi2] + ":</font>" + _loc2_.armyInfo.kezhiLevel2 + "级\n";
                  _loc3_ += "<font color=\'#e5ce10\'>克制" + Type.TYPE_NAME[_loc2_.armyInfo.kezhi3] + ":</font>" + _loc2_.armyInfo.kezhiLevel3 + "级\n";
                  _loc3_ += "</font>";
                  dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
                     "htmlText":_loc3_,
                     "type":3,
                     "width":150,
                     "height":220
                  }));
               }
               else
               {
                  _loc3_ += "</font>";
                  dispatchEvent(new UIEvent(UIEvent.SHOW_TIPS,true,{
                     "htmlText":_loc3_,
                     "type":3,
                     "width":150,
                     "height":155
                  }));
               }
            }
         }
      }
      
      private function createType(param1:int) : String
      {
         var _loc2_:String = null;
         switch(param1)
         {
            case Type.CHANGQIANGBING:
               _loc2_ = "长枪兵\n";
               break;
            case Type.CHUIBING:
               _loc2_ = "锤兵\n";
               break;
            case Type.FEIDAOBING:
               _loc2_ = "飞刀兵\n";
               break;
            case Type.FUBING:
               _loc2_ = "斧兵\n";
               break;
            case Type.GONGBING:
               _loc2_ = "弓兵\n";
               break;
            case Type.PUDAOBING:
               _loc2_ = "朴刀兵\n";
               break;
            case Type.QIBING:
               _loc2_ = "骑兵\n";
               break;
            case Type.TENGJIABING:
               _loc2_ = "藤甲兵\n";
               break;
            case Type.TOUSHICHE:
               _loc2_ = "投石车\n";
               break;
            case Type.WUDOUBING:
               _loc2_ = "武斗兵\n";
               break;
            case Type.JUNZHU:
               _loc2_ = "君主\n";
         }
         return _loc2_;
      }
      
      private function createTitle(param1:int) : String
      {
         var _loc2_:String = null;
         switch(param1)
         {
            case 0:
               _loc2_ = "<font color=\'#ff6600\'>超级武将</font>\n";
               break;
            case 1:
               _loc2_ = "<font color=\'#33ccff\'>一流武将</font>\n";
               break;
            case 2:
               _loc2_ = "<font color=\'#99ff33\'>二流武将</font>\n";
               break;
            default:
               _loc2_ = "<font color=\'#ffcc99\'>三流武将</font>\n";
         }
         return _loc2_;
      }
      
      private function onMouseOutHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         if(param1.target is GeneralBlock || param1.target is JunshiBlock)
         {
            if(param1.target.active == true)
            {
               dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
            }
         }
      }
      
      private function onMouseClickHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         var _loc2_:Object = {};
         if(ChatManager.getInstance().server == true)
         {
            _loc2_.direct = -1;
         }
         else
         {
            _loc2_.direct = 1;
         }
         if(param1.target is GeneralBlock || param1.target is JunshiBlock)
         {
            dispatchEvent(new UIEvent(UIEvent.HIDE_TIPS,true));
         }
         if(param1.target == this._qixieBlock)
         {
            if(this._qixieBlock.active == true)
            {
               _loc2_.head = Head.REMOVE_SOLDIER;
               _loc2_.code = this._qixieBlock.armyInfo.code;
               RoleModel.getInstance().removeChooseSoldier(this._qixieBlock.armyInfo.code);
               this.removeSoldierFromChoose(this._qixieBlock.armyInfo.code);
               this.addSoldierToAll(this._qixieBlock.armyInfo.clone());
               this._qixieBlock.clear();
            }
         }
         else if(param1.target == this._block11)
         {
            if(this._block11.active == true)
            {
               _loc2_.head = Head.REMOVE_SOLDIER;
               _loc2_.code = this._block11.armyInfo.code;
               RoleModel.getInstance().removeChooseSoldier(this._block11.armyInfo.code);
               this.removeSoldierFromChoose(this._block11.armyInfo.code);
               this.addSoldierToAll(this._block11.armyInfo.clone());
               this._block11.clear();
            }
         }
         else if(param1.target == this._block12)
         {
            if(this._block12.active == true)
            {
               _loc2_.head = Head.REMOVE_SOLDIER;
               _loc2_.code = this._block12.armyInfo.code;
               RoleModel.getInstance().removeChooseSoldier(this._block12.armyInfo.code);
               this.removeSoldierFromChoose(this._block12.armyInfo.code);
               this.addSoldierToAll(this._block12.armyInfo.clone());
               this._block12.clear();
            }
         }
         else if(param1.target == this._block13)
         {
            if(this._block13.active == true)
            {
               _loc2_.head = Head.REMOVE_SOLDIER;
               _loc2_.code = this._block13.armyInfo.code;
               RoleModel.getInstance().removeChooseSoldier(this._block13.armyInfo.code);
               this.removeSoldierFromChoose(this._block13.armyInfo.code);
               this.addSoldierToAll(this._block13.armyInfo.clone());
               this._block13.clear();
            }
         }
         else if(param1.target == this._block14)
         {
            if(this._block14.active == true)
            {
               _loc2_.head = Head.REMOVE_SOLDIER;
               _loc2_.code = this._block14.armyInfo.code;
               RoleModel.getInstance().removeChooseSoldier(this._block14.armyInfo.code);
               this.removeSoldierFromChoose(this._block14.armyInfo.code);
               this.addSoldierToAll(this._block14.armyInfo.clone());
               this._block14.clear();
            }
         }
         else if(param1.target == this._block15)
         {
            if(this._block15.active == true)
            {
               _loc2_.head = Head.REMOVE_SOLDIER;
               _loc2_.code = this._block15.armyInfo.code;
               RoleModel.getInstance().removeChooseSoldier(this._block15.armyInfo.code);
               this.removeSoldierFromChoose(this._block15.armyInfo.code);
               this.addSoldierToAll(this._block15.armyInfo.clone());
               this._block15.clear();
            }
         }
         else if(param1.target == this._block21)
         {
            if(this._block21.armyInfo.type != Type.TOUSHICHE)
            {
               if(this._qixieBlock.active == false && this._chooseArmy.length >= 5)
               {
                  return;
               }
               if(this._chooseArmy.length >= 6)
               {
                  return;
               }
            }
            if(this._block21.active == true)
            {
               _loc2_.head = Head.ADD_SOLDIER;
               _loc2_.code = this._block21.armyInfo.code;
               _loc2_.level = this._block21.armyInfo.level;
               _loc2_.evolution = this._block21.armyInfo.evolution;
               _loc2_.feature = this._block21.armyInfo.feature;
               _loc2_.name = this._block21.armyInfo.name;
               _loc2_.delay = this._block21.armyInfo.delay;
               _loc2_.ai = this._block21.armyInfo.ai;
               _loc2_.kezhi = this._block21.armyInfo.getKezhiStr();
               _loc2_.tianfu = this._block21.armyInfo.tianfu;
               RoleModel.getInstance().addChooseSoldier(this._block21.armyInfo.code);
               this.addSoldierToChoose(this._block21.armyInfo.clone());
               this.removeSoldierFromAll(this._block21.armyInfo.code);
            }
         }
         else if(param1.target == this._block22)
         {
            if(this._block22.armyInfo.type != Type.TOUSHICHE)
            {
               if(this._qixieBlock.active == false && this._chooseArmy.length >= 5)
               {
                  return;
               }
               if(this._chooseArmy.length >= 6)
               {
                  return;
               }
            }
            if(this._block22.active == true)
            {
               _loc2_.head = Head.ADD_SOLDIER;
               _loc2_.code = this._block22.armyInfo.code;
               _loc2_.level = this._block22.armyInfo.level;
               _loc2_.evolution = this._block22.armyInfo.evolution;
               _loc2_.feature = this._block22.armyInfo.feature;
               _loc2_.name = this._block22.armyInfo.name;
               _loc2_.delay = this._block22.armyInfo.delay;
               _loc2_.ai = this._block22.armyInfo.ai;
               _loc2_.kezhi = this._block22.armyInfo.getKezhiStr();
               _loc2_.tianfu = this._block22.armyInfo.tianfu;
               RoleModel.getInstance().addChooseSoldier(this._block22.armyInfo.code);
               this.addSoldierToChoose(this._block22.armyInfo.clone());
               this.removeSoldierFromAll(this._block22.armyInfo.code);
            }
         }
         else if(param1.target == this._block23)
         {
            if(this._block23.armyInfo.type != Type.TOUSHICHE)
            {
               if(this._qixieBlock.active == false && this._chooseArmy.length >= 5)
               {
                  return;
               }
               if(this._chooseArmy.length >= 6)
               {
                  return;
               }
            }
            if(this._block23.active == true)
            {
               _loc2_.head = Head.ADD_SOLDIER;
               _loc2_.code = this._block23.armyInfo.code;
               _loc2_.level = this._block23.armyInfo.level;
               _loc2_.evolution = this._block23.armyInfo.evolution;
               _loc2_.feature = this._block23.armyInfo.feature;
               _loc2_.name = this._block23.armyInfo.name;
               _loc2_.delay = this._block23.armyInfo.delay;
               _loc2_.ai = this._block23.armyInfo.ai;
               _loc2_.kezhi = this._block23.armyInfo.getKezhiStr();
               _loc2_.tianfu = this._block23.armyInfo.tianfu;
               RoleModel.getInstance().addChooseSoldier(this._block23.armyInfo.code);
               this.addSoldierToChoose(this._block23.armyInfo.clone());
               this.removeSoldierFromAll(this._block23.armyInfo.code);
            }
         }
         else if(param1.target == this._block24)
         {
            if(this._block24.armyInfo.type != Type.TOUSHICHE)
            {
               if(this._qixieBlock.active == false && this._chooseArmy.length >= 5)
               {
                  return;
               }
               if(this._chooseArmy.length >= 6)
               {
                  return;
               }
            }
            if(this._block24.active == true)
            {
               _loc2_.head = Head.ADD_SOLDIER;
               _loc2_.code = this._block24.armyInfo.code;
               _loc2_.level = this._block24.armyInfo.level;
               _loc2_.evolution = this._block24.armyInfo.evolution;
               _loc2_.feature = this._block24.armyInfo.feature;
               _loc2_.name = this._block24.armyInfo.name;
               _loc2_.delay = this._block24.armyInfo.delay;
               _loc2_.ai = this._block24.armyInfo.ai;
               _loc2_.kezhi = this._block24.armyInfo.getKezhiStr();
               _loc2_.tianfu = this._block24.armyInfo.tianfu;
               RoleModel.getInstance().addChooseSoldier(this._block24.armyInfo.code);
               this.addSoldierToChoose(this._block24.armyInfo.clone());
               this.removeSoldierFromAll(this._block24.armyInfo.code);
            }
         }
         else if(param1.target == this._block25)
         {
            if(this._block25.armyInfo.type != Type.TOUSHICHE)
            {
               if(this._qixieBlock.active == false && this._chooseArmy.length >= 5)
               {
                  return;
               }
               if(this._chooseArmy.length >= 6)
               {
                  return;
               }
            }
            if(this._block25.active == true)
            {
               _loc2_.head = Head.ADD_SOLDIER;
               _loc2_.code = this._block25.armyInfo.code;
               _loc2_.level = this._block25.armyInfo.level;
               _loc2_.evolution = this._block25.armyInfo.evolution;
               _loc2_.feature = this._block25.armyInfo.feature;
               _loc2_.name = this._block25.armyInfo.name;
               _loc2_.delay = this._block25.armyInfo.delay;
               _loc2_.ai = this._block25.armyInfo.ai;
               _loc2_.kezhi = this._block25.armyInfo.getKezhiStr();
               _loc2_.tianfu = this._block25.armyInfo.tianfu;
               RoleModel.getInstance().addChooseSoldier(this._block25.armyInfo.code);
               this.addSoldierToChoose(this._block25.armyInfo.clone());
               this.removeSoldierFromAll(this._block25.armyInfo.code);
            }
         }
         else if(param1.target == this._block26)
         {
            if(this._block26.armyInfo.type != Type.TOUSHICHE)
            {
               if(this._qixieBlock.active == false && this._chooseArmy.length >= 5)
               {
                  return;
               }
               if(this._chooseArmy.length >= 6)
               {
                  return;
               }
            }
            if(this._block26.active == true)
            {
               _loc2_.head = Head.ADD_SOLDIER;
               _loc2_.code = this._block26.armyInfo.code;
               _loc2_.level = this._block26.armyInfo.level;
               _loc2_.evolution = this._block26.armyInfo.evolution;
               _loc2_.feature = this._block26.armyInfo.feature;
               _loc2_.name = this._block26.armyInfo.name;
               _loc2_.delay = this._block26.armyInfo.delay;
               _loc2_.ai = this._block26.armyInfo.ai;
               _loc2_.kezhi = this._block26.armyInfo.getKezhiStr();
               _loc2_.tianfu = this._block26.armyInfo.tianfu;
               RoleModel.getInstance().addChooseSoldier(this._block26.armyInfo.code);
               this.addSoldierToChoose(this._block26.armyInfo.clone());
               this.removeSoldierFromAll(this._block26.armyInfo.code);
            }
         }
         if(_loc2_.head != null)
         {
            ChatManager.getInstance().p2pSend(_loc2_);
            ChatManager.getInstance().dispatchEvent(new P2PEvent(P2PEvent.P2P_DATA,false,_loc2_));
         }
         this.flush();
      }
      
      override public function initData(param1:Object) : void
      {
         this._allArmy = param1.all;
         this._chooseArmy = param1.choose;
         this._allArmy.sort(this.sortRule);
         this._currentPage = 1;
         this._maxPage = this._allArmy.length % 6 == 0 ? int(this._allArmy.length / 6) : int(this._allArmy.length / 6) + 1;
         this.createAll();
         this.createChoose();
         var _loc2_:int = 1;
         var _loc3_:int = 1;
         while(_loc3_ <= this._chooseArmy.length)
         {
            if(this._chooseArmy[_loc3_ - 1].type == Type.TOUSHICHE)
            {
               this._qixieBlock.initData(this._chooseArmy[_loc3_ - 1]);
            }
            else
            {
               this["_block1" + _loc2_].initData(this._chooseArmy[_loc3_ - 1]);
               _loc2_++;
            }
            _loc3_++;
         }
         this.flush();
      }
      
      private function flush() : *
      {
         var _loc1_:int = 0;
         if(this._allArmy.length == 0)
         {
            this._maxPage = 1;
         }
         else
         {
            this._maxPage = this._allArmy.length % 6 == 0 ? int(this._allArmy.length / 6) : int(this._allArmy.length / 6) + 1;
         }
         if(this._currentPage > this._maxPage)
         {
            this._currentPage = this._maxPage;
         }
         this.__pageTF.text = this._currentPage + "/" + this._maxPage;
         if(this._currentPage == 1)
         {
            Tools.setDisabled(this.__preBtn,true);
         }
         else
         {
            Tools.setDisabled(this.__preBtn,false);
         }
         if(this._currentPage == this._maxPage)
         {
            Tools.setDisabled(this.__nextBtn,true);
         }
         else
         {
            Tools.setDisabled(this.__nextBtn,false);
         }
         this._block21.clear();
         this._block22.clear();
         this._block23.clear();
         this._block24.clear();
         this._block25.clear();
         this._block26.clear();
         var _loc2_:int = 1;
         while(_loc2_ <= 6)
         {
            _loc1_ = (this._currentPage - 1) * 6 + _loc2_ - 1;
            if(_loc1_ >= this._allArmy.length)
            {
               return;
            }
            this["_block2" + _loc2_].initData(this._allArmy[_loc1_]);
            _loc2_++;
         }
      }
      
      private function createChoose() : *
      {
         this._block11 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
         this._block12 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
         this._block13 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
         this._block14 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
         this._block15 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
         this._qixieBlock = new JunshiBlock(SkinCode.JUNSHI_BLOCK);
         this._block11.buttonMode = true;
         this._block12.buttonMode = true;
         this._block13.buttonMode = true;
         this._block14.buttonMode = true;
         this._block15.buttonMode = true;
         this._qixieBlock.buttonMode = true;
         this._block11.x = this._pos11.x;
         this._block11.y = this._pos11.y;
         this._block12.x = this._pos12.x;
         this._block12.y = this._pos12.y;
         this._block13.x = this._pos13.x;
         this._block13.y = this._pos13.y;
         this._block14.x = this._pos14.x;
         this._block14.y = this._pos14.y;
         this._block15.x = this._pos15.x;
         this._block15.y = this._pos15.y;
         this._qixieBlock.x = this._qixie.x;
         this._qixieBlock.y = this._qixie.y;
         addChild(this._block11);
         addChild(this._block12);
         addChild(this._block13);
         addChild(this._block14);
         addChild(this._block15);
         addChild(this._qixieBlock);
         this._block11.clear();
         this._block12.clear();
         this._block13.clear();
         this._block14.clear();
         this._block15.clear();
         this._qixieBlock.clear();
      }
      
      private function createAll() : *
      {
         this._block21 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
         this._block22 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
         this._block23 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
         this._block24 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
         this._block25 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
         this._block26 = new GeneralBlock(SkinCode.GENERAL_BLOCK);
         this._block21.buttonMode = true;
         this._block22.buttonMode = true;
         this._block23.buttonMode = true;
         this._block24.buttonMode = true;
         this._block25.buttonMode = true;
         this._block26.buttonMode = true;
         this._block21.x = this._pos21.x;
         this._block21.y = this._pos21.y;
         this._block22.x = this._pos22.x;
         this._block22.y = this._pos22.y;
         this._block23.x = this._pos23.x;
         this._block23.y = this._pos23.y;
         this._block24.x = this._pos24.x;
         this._block24.y = this._pos24.y;
         this._block25.x = this._pos25.x;
         this._block25.y = this._pos25.y;
         this._block26.x = this._pos26.x;
         this._block26.y = this._pos26.y;
         addChild(this._block21);
         addChild(this._block22);
         addChild(this._block23);
         addChild(this._block24);
         addChild(this._block25);
         addChild(this._block26);
         this._block21.clear();
         this._block22.clear();
         this._block23.clear();
         this._block24.clear();
         this._block25.clear();
         this._block26.clear();
      }
      
      private function preBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         --this._currentPage;
         this.flush();
      }
      
      private function nextBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         ++this._currentPage;
         this.flush();
      }
      
      private function okBtnClickHandler(param1:MouseEvent) : *
      {
         param1.stopImmediatePropagation();
         if(this._chooseArmy.length == 0)
         {
            // 无上阵武将时，自动选前6个可用武将
            var allGens:Vector.<ArmyInfo> = RoleModel.getInstance().getAllSoldiers();
            var autoCount:int = Math.min(6, allGens.length);
            for(var ai:int = 0; ai < autoCount; ai++) {
               this.addSoldierToChoose(allGens[ai].clone());
               RoleModel.getInstance().addChooseSoldier(allGens[ai].code);
            }
         }
         this.sendToHttpNew();
      }

      private function checkSaberCount() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < 10)
         {
            _loc1_ = 0;
            while(_loc1_ < this._chooseArmy.length)
            {
               if(this._chooseArmy[_loc1_].type == _loc3_)
               {
                  _loc2_++;
               }
               if(_loc2_ > 1)
               {
                  return false;
               }
               _loc1_++;
            }
            _loc2_ = 0;
            _loc3_++;
         }
         return true;
      }
      
      private function addSoldierToAll(param1:ArmyInfo) : *
      {
         this._allArmy.push(param1);
         this._allArmy.sort(this.sortRule);
      }
      
      private function removeSoldierFromAll(param1:String) : *
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._allArmy.length)
         {
            if(this._allArmy[_loc2_].code == param1)
            {
               this._allArmy.splice(_loc2_,1);
            }
            _loc2_++;
         }
         this._allArmy.sort(this.sortRule);
      }
      
      private function addSoldierToChoose(param1:ArmyInfo) : *
      {
         this._chooseArmy.push(param1);
         if(param1.type == Type.TOUSHICHE)
         {
            this._qixieBlock.initData(param1);
            return;
         }
         var _loc2_:int = 1;
         while(_loc2_ <= 5)
         {
            if(this["_block1" + _loc2_].active == false)
            {
               this["_block1" + _loc2_].initData(param1);
               return;
            }
            _loc2_++;
         }
      }
      
      private function removeSoldierFromChoose(param1:String) : *
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._chooseArmy.length)
         {
            if(this._chooseArmy[_loc2_].code == param1)
            {
               this._chooseArmy.splice(_loc2_,1);
               return;
            }
            _loc2_++;
         }
      }
      
      private function sortRule(param1:ArmyInfo, param2:ArmyInfo) : *
      {
         if(param1.title < param2.title)
         {
            return -1;
         }
         if(param1.title > param2.title)
         {
            return 1;
         }
         if(param1.level > param2.level)
         {
            return -1;
         }
         if(param1.level < param2.level)
         {
            return 1;
         }
         return 0;
      }
      
      private function sendToHttpNew() : *
      {
         var _loc1_:Object = {};
         _loc1_.head = Head.HTTP_NEW_SHANGZHEN;
         _loc1_.agent = Config.AGENT;
         _loc1_.ver = Config.VER;
         _loc1_.token = Config.token;
         _loc1_.roleID = RoleModel.getInstance().roleID;
         _loc1_.userID = RoleModel.getInstance().userID;
         _loc1_.choose = RoleModel.getInstance().getChooseSoldierStr();
         _loc1_.mask = true;
         AESController.getInstance().sendJSON(_loc1_,this.shangzhenResponse);
      }
      
      private function shangzhenResponse(param1:Object) : *
      {
         if(param1.success == true)
         {
            RoleModel.getInstance().importChoose(param1.data.choose);
            dispatchEvent(new UIEvent(UIEvent.CLOSE,true));
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
