package com.iflashigame.controller
{
   import com.adobe.serialization.json.JSON;
   import com.iflashigame.net.ChatManager;
   import com.iflashigame.utils.Tools;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import game.Data;
   import game.Logic;
   import game.model.ArmyInfo;
   import game.model.Head;
   import game.model.LeitaiStatus;
   import game.model.RoleModel;
   import game.model.Type;
   
   public class Test implements IControllerTest
   {
      
      private static var _instance:Test;
       
      
      private var leitaiData:Array;
      
      public function Test(param1:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : Test
      {
         if(Test._instance == null)
         {
            Test._instance = new Test(new SingletonEnforcer());
         }
         return Test._instance;
      }
      
      public function getData(param1:Object) : Object
      {
         switch(param1.head)
         {
            case Head.HTTP_NEW_REGISTER:
               return this.httpRegister(param1);
            case Head.HTTP_NEW_GENERAL_SHENGJI:
               return this.generalShengji(param1);
            case Head.HTTP_NEW_PUTONG_ZHAOMU:
               return this.putongZhaomu(param1);
            case Head.HTTP_NEW_QIUXIAN_ZHAOMU:
               return this.qiuxianZhaomu(param1);
            case Head.HTTP_NEW_DIANKA_ZHAOMU:
               return this.diankaZhaomu(param1);
            case Head.HTTP_NEW_GENERAL_SHENGJI:
               return this.shengji(param1);
            case Head.HTTP_NEW_GENERAL_JINHUA:
               return this.jinhua(param1);
            case Head.HTTP_NEW_GENERAL_KEZHI_SHENGJI:
               return this.kezhiShengji(param1);
            case Head.HTTP_NEW_GENERAL_TIANFU:
               return this.tianfu(param1);
            case Head.HTTP_NEW_SHUXINGCHONGXI:
               return this.shuxingchongxi(param1);
            case Head.HTTP_NEW_SHANGZHEN:
               return this.shangzhen(param1);
            case Head.HTTP_NEW_DIANKA:
               return this.dianka(param1);
            case Head.HTTP_NEW_BUYITEM:
               return this.buyItem(param1);
            case Head.HTTP_NEW_SAVE_HISTORY:
               return this.history(param1);
            case Head.HTTP_NEW_USE_AMMO:
               return this.useAmmo(param1);
            case Head.HTTP_NEW_YANZHENG:
               return this.yanzheng(param1);
            case Head.HTTP_NEW_FIGHT_RESULT:
               return this.fightResult(param1);
            case Head.HTTP_NEW_FUBEN_COUNT:
               return this.fubenCount(param1);
            case Head.HTTP_NEW_FUBEN_LOGIN:
               return this.fubenLogin(param1);
            case Head.HTTP_NEW_FUBEN_AWARD:
               return this.fubenAward(param1);
            case Head.HTTP_NEW_FUBEN_FANPAI:
               return this.fubenFanpai(param1);
            case Head.HTTP_NEW_P2PFIGHT_RESULT:
               return this.p2pFightResult(param1);
            case Head.HTTP_NEW_GETAWARD:
               return this.getAward(param1);
            case Head.HTTP_NEW_BUCHANG:
               return this.getBuchang(param1);
            case Head.HTTP_NEW_LEITAI_LIST:
               return this.getLeitaiList(param1);
            case Head.HTTP_NEW_LEITAI_HEARTBEAT:
               return this.heartBeat(param1);
            case Head.HTTP_NEW_LEITAI_BEMASTER:
               return this.beMaster(param1);
            case Head.HTTP_NEW_LEITAI_CONTINUE:
               return this.leitaiContinue(param1);
            case Head.HTTP_NEW_LEITAI_EXIT:
               return this.leitaiExit(param1);
            default:
               return {};
         }
      }
      
      private function leitaiExit(param1:Object) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         while(_loc3_ < this.leitaiData.length)
         {
            if(this.leitaiData[_loc3_].rID == param1.rID)
            {
               _loc2_ = this.leitaiData[_loc3_];
               break;
            }
            _loc3_++;
         }
         if(_loc2_ == null)
         {
            return {
               "success":false,
               "message":"房间号错误!"
            };
         }
         if(_loc2_.mInfo.id != RoleModel.getInstance().roleID)
         {
            return {
               "success":false,
               "message":"你不是此擂台的擂主。"
            };
         }
         return {};
      }
      
      private function leitaiContinue(param1:Object) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         while(_loc3_ < this.leitaiData.length)
         {
            if(this.leitaiData[_loc3_].rID == param1.rID)
            {
               _loc2_ = this.leitaiData[_loc3_];
               break;
            }
            _loc3_++;
         }
         if(_loc2_ == null)
         {
            return {
               "success":false,
               "message":"房间号错误!"
            };
         }
         if(_loc2_.mInfo.id != RoleModel.getInstance().roleID)
         {
            return {
               "success":false,
               "message":"你不是此擂台的擂主。"
            };
         }
         var _loc4_:Object;
         (_loc4_ = {}).success = true;
         _loc4_.data = {};
         _loc4_.data.rID = param1.rID;
         _loc4_.data.type = param1.type;
         _loc4_.data.money = RoleModel.getInstance().money;
         _loc4_.data.exploit = RoleModel.getInstance().exploit;
         _loc4_.data.dianka = RoleModel.getInstance().dianka;
         _loc4_.data.rongyu = RoleModel.getInstance().rongyu;
         _loc4_.data.leitai = this.leitaiData;
         return _loc4_;
      }
      
      private function beMaster(param1:Object) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:Object = {};
         _loc3_.success = true;
         _loc3_.data = {};
         _loc3_.data.rID = param1.rID;
         var _loc4_:int = 0;
         while(_loc4_ < this.leitaiData.length)
         {
            if(this.leitaiData[_loc4_].rID == param1.rID)
            {
               _loc2_ = this.leitaiData[_loc4_];
               break;
            }
            _loc4_++;
         }
         if(_loc2_ == null)
         {
            return {
               "success":false,
               "message":"房间号错误!"
            };
         }
         if(_loc2_.rType == 1)
         {
            _loc3_.data.money = RoleModel.getInstance().money - int(_loc2_.rPrice);
            _loc3_.data.exploit = RoleModel.getInstance().exploit;
            _loc3_.data.dianka = RoleModel.getInstance().dianka;
         }
         else if(_loc2_.rType == 2)
         {
            _loc3_.data.money = RoleModel.getInstance().money;
            _loc3_.data.exploit = RoleModel.getInstance().exploit - int(_loc2_.rPrice);
            _loc3_.data.dianka = RoleModel.getInstance().dianka;
         }
         else if(_loc2_.rType == 3)
         {
            _loc3_.data.money = RoleModel.getInstance().money;
            _loc3_.data.exploit = RoleModel.getInstance().exploit;
            _loc3_.data.dianka = RoleModel.getInstance().dianka - int(_loc2_.rPrice);
         }
         _loc3_.data.rongyu = RoleModel.getInstance().rongyu;
         _loc2_.rStatus = LeitaiStatus.WAITING;
         _loc2_.mInfo = {
            "id":RoleModel.getInstance().roleID,
            "pID":ChatManager.getInstance().peerID,
            "roleName":RoleModel.getInstance().roleName,
            "level":RoleModel.getInstance().level,
            "imageID":RoleModel.getInstance().imageID
         };
         _loc3_.data.leitai = this.leitaiData;
         return _loc3_;
      }
      
      private function heartBeat(param1:Object) : Object
      {
         return {"success":true};
      }
      
      private function getLeitaiList(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         _loc2_.data = {};
         _loc2_.data.rongyu = 100045;
         _loc2_.data.ranking = 32;
         var _loc3_:Array = [];
         _loc3_.push({
            "rID":1,
            "rLevel":200,
            "rStatus":0,
            "rType":1,
            "rPrice":10000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":2,
            "rLevel":200,
            "rStatus":1,
            "rType":2,
            "rPrice":10000,
            "rValue":10000,
            "rCount":8,
            "mInfo":{
               "id":11,
               "pID":"asdfafd",
               "roleName":"张三丰的擂台",
               "level":120,
               "imageID":1
            }
         });
         _loc3_.push({
            "rID":3,
            "rLevel":200,
            "rStatus":2,
            "rType":3,
            "rPrice":30,
            "rValue":30,
            "rCount":8,
            "mInfo":{
               "id":12,
               "pID":"ceidn",
               "roleName":"李四的",
               "level":110,
               "imageID":2
            },
            "sInfo":{
               "id":13,
               "pID":"3435",
               "roleName":"王五",
               "level":100,
               "imageID":1
            }
         });
         _loc3_.push({
            "rID":4,
            "rLevel":200,
            "rStatus":1,
            "rType":1,
            "rPrice":5000,
            "rValue":8800,
            "rCount":2,
            "mInfo":{
               "id":14,
               "pID":"asdfadfadf",
               "roleName":"赵六",
               "level":80,
               "imageID":1
            }
         });
         _loc3_.push({
            "rID":5,
            "rLevel":200,
            "rStatus":1,
            "rType":2,
            "rPrice":5000,
            "rValue":12000,
            "rCount":7,
            "mInfo":{
               "id":15,
               "pID":"qweqweqw",
               "roleName":"孙琦",
               "level":80,
               "imageID":1
            }
         });
         _loc3_.push({
            "rID":6,
            "rLevel":200,
            "rStatus":1,
            "rType":3,
            "rPrice":10,
            "rValue":7000,
            "rCount":3,
            "mInfo":{
               "id":16,
               "pID":"cvadfad",
               "roleName":"刘巴",
               "level":90,
               "imageID":2
            }
         });
         _loc3_.push({
            "rID":7,
            "rLevel":180,
            "rStatus":0,
            "rType":1,
            "rPrice":10000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":8,
            "rLevel":180,
            "rStatus":0,
            "rType":2,
            "rPrice":10000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":9,
            "rLevel":180,
            "rStatus":0,
            "rType":3,
            "rPrice":30,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":10,
            "rLevel":180,
            "rStatus":0,
            "rType":1,
            "rPrice":5000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":11,
            "rLevel":180,
            "rStatus":0,
            "rType":2,
            "rPrice":5000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":12,
            "rLevel":180,
            "rStatus":0,
            "rType":3,
            "rPrice":10,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":13,
            "rLevel":160,
            "rStatus":0,
            "rType":1,
            "rPrice":8000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":14,
            "rLevel":160,
            "rStatus":0,
            "rType":2,
            "rPrice":8000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":15,
            "rLevel":160,
            "rStatus":0,
            "rType":3,
            "rPrice":30,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":16,
            "rLevel":160,
            "rStatus":0,
            "rType":1,
            "rPrice":5000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":17,
            "rLevel":160,
            "rStatus":0,
            "rType":2,
            "rPrice":5000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":18,
            "rLevel":160,
            "rStatus":0,
            "rType":3,
            "rPrice":10,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":19,
            "rLevel":140,
            "rStatus":0,
            "rType":1,
            "rPrice":8000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":20,
            "rLevel":140,
            "rStatus":0,
            "rType":2,
            "rPrice":8000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":21,
            "rLevel":140,
            "rStatus":0,
            "rType":3,
            "rPrice":30,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":22,
            "rLevel":140,
            "rStatus":0,
            "rType":1,
            "rPrice":5000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":23,
            "rLevel":140,
            "rStatus":0,
            "rType":2,
            "rPrice":5000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":24,
            "rLevel":140,
            "rStatus":0,
            "rType":3,
            "rPrice":10,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":25,
            "rLevel":120,
            "rStatus":0,
            "rType":1,
            "rPrice":5000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":26,
            "rLevel":120,
            "rStatus":0,
            "rType":2,
            "rPrice":5000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":27,
            "rLevel":120,
            "rStatus":0,
            "rType":3,
            "rPrice":30,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":28,
            "rLevel":120,
            "rStatus":0,
            "rType":1,
            "rPrice":2000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":29,
            "rLevel":120,
            "rStatus":0,
            "rType":2,
            "rPrice":2000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":30,
            "rLevel":120,
            "rStatus":0,
            "rType":3,
            "rPrice":10,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":31,
            "rLevel":90,
            "rStatus":0,
            "rType":1,
            "rPrice":5000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":32,
            "rLevel":90,
            "rStatus":0,
            "rType":2,
            "rPrice":5000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":33,
            "rLevel":90,
            "rStatus":0,
            "rType":3,
            "rPrice":30,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":34,
            "rLevel":90,
            "rStatus":0,
            "rType":1,
            "rPrice":2000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":35,
            "rLevel":90,
            "rStatus":0,
            "rType":2,
            "rPrice":2000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":36,
            "rLevel":90,
            "rStatus":0,
            "rType":3,
            "rPrice":10,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":37,
            "rLevel":60,
            "rStatus":0,
            "rType":1,
            "rPrice":3000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":38,
            "rLevel":60,
            "rStatus":0,
            "rType":2,
            "rPrice":3000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":39,
            "rLevel":60,
            "rStatus":0,
            "rType":3,
            "rPrice":30,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":40,
            "rLevel":60,
            "rStatus":0,
            "rType":1,
            "rPrice":1000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":41,
            "rLevel":60,
            "rStatus":0,
            "rType":2,
            "rPrice":1000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":42,
            "rLevel":60,
            "rStatus":0,
            "rType":3,
            "rPrice":10,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":43,
            "rLevel":30,
            "rStatus":0,
            "rType":1,
            "rPrice":3000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":44,
            "rLevel":30,
            "rStatus":0,
            "rType":2,
            "rPrice":3000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":45,
            "rLevel":30,
            "rStatus":0,
            "rType":3,
            "rPrice":30,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":46,
            "rLevel":30,
            "rStatus":0,
            "rType":1,
            "rPrice":1000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":47,
            "rLevel":30,
            "rStatus":0,
            "rType":2,
            "rPrice":1000,
            "rValue":0,
            "rCount":0
         });
         _loc3_.push({
            "rID":48,
            "rLevel":30,
            "rStatus":0,
            "rType":3,
            "rPrice":10,
            "rValue":0,
            "rCount":0
         });
         _loc2_.data.leitai = _loc3_;
         this.leitaiData = _loc3_;
         var _loc4_:Array;
         (_loc4_ = []).push({
            "roleName":"高手第一",
            "score":23456
         });
         _loc4_.push({
            "roleName":"高手第2",
            "score":23456
         });
         _loc4_.push({
            "roleName":"高手第3",
            "score":23456
         });
         _loc4_.push({
            "roleName":"高手第4",
            "score":23456
         });
         _loc4_.push({
            "roleName":"高手第5",
            "score":23456
         });
         _loc4_.push({
            "roleName":"高手第6",
            "score":23456
         });
         _loc4_.push({
            "roleName":"高手第7",
            "score":23456
         });
         _loc4_.push({
            "roleName":"高手第8",
            "score":23456
         });
         _loc4_.push({
            "roleName":"高手第9",
            "score":23456
         });
         _loc4_.push({
            "roleName":"高手第10",
            "score":23456
         });
         _loc2_.data.paihang = _loc4_;
         return _loc2_;
      }
      
      private function getBuchang(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         _loc2_.data = {
            "money":RoleModel.getInstance().money + 1000,
            "exploit":RoleModel.getInstance().exploit + 200,
            "reverence":RoleModel.getInstance().reverence + 300,
            "item":[{
               "id":2,
               "code":"proto_3_2",
               "count":"19"
            }],
            "general":[{
               "id":3000,
               "code":"general_4_19",
               "name":"夏侯霸",
               "level":1,
               "evolution":0,
               "feature":0,
               "genius":"null",
               "kezhi":"6:1|1:1|8:1"
            }]
         };
         return _loc2_;
      }
      
      private function getAward(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         _loc2_.data = {
            "general":[{
               "id":4444444444444,
               "code":"general_9_34",
               "level":10,
               "evolution":0,
               "feature":0,
               "kezhi":"3:1|4:1|8:1"
            },{
               "id":555555555,
               "code":"general_9_16",
               "level":10,
               "evolution":0,
               "feature":0,
               "kezhi":"3:1|4:1|8:1"
            }],
            "item":[{
               "id":1212121212,
               "code":"proto_3_3",
               "count":3
            },{
               "id":1111111111,
               "code":"proto_3_1",
               "count":3
            }],
            "money":RoleModel.getInstance().money + 100,
            "exploit":RoleModel.getInstance().exploit + 100
         };
         return _loc2_;
      }
      
      private function p2pFightResult(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         _loc2_.data = {};
         _loc2_.data.flag = int(param1.flag);
         _loc2_.data.relativeName = param1.relativeName;
         if(_loc2_.data.flag == 1)
         {
            _loc2_.data.money = RoleModel.getInstance().money + Logic.getMoneyByFight(param1.m,param1.n);
            _loc2_.data.exploit = RoleModel.getInstance().exploit + Logic.getExploitByFight(param1.m,param1.n);
            _loc2_.data.reverence = RoleModel.getInstance().reverence + Logic.getReverenceByFight(param1.m,param1.n);
            _loc2_.data.winCount = RoleModel.getInstance().winCount + 1;
            _loc2_.data.lostCount = RoleModel.getInstance().lostCount;
         }
         else if(_loc2_.data.flag == 0)
         {
            _loc2_.data.money = RoleModel.getInstance().money;
            _loc2_.data.exploit = RoleModel.getInstance().exploit;
            _loc2_.data.reverence = RoleModel.getInstance().reverence;
            _loc2_.data.winCount = RoleModel.getInstance().winCount;
            _loc2_.data.lostCount = RoleModel.getInstance().lostCount + 1;
         }
         else
         {
            _loc2_.data.money = RoleModel.getInstance().money + 50;
            _loc2_.data.exploit = RoleModel.getInstance().exploit + 200;
            _loc2_.data.reverence = RoleModel.getInstance().reverence + 10;
            _loc2_.data.winCount = RoleModel.getInstance().winCount;
            _loc2_.data.lostCount = RoleModel.getInstance().lostCount;
         }
         return _loc2_;
      }
      
      private function fubenFanpai(param1:Object) : Object
      {
         var _loc2_:Number = NaN;
         var _loc3_:Object = {};
         _loc3_.success = true;
         _loc3_.data = {};
         var _loc4_:Array;
         if((_loc4_ = param1.result.split("|"))[0] == 2)
         {
            _loc3_.data.money = RoleModel.getInstance().money + int(_loc4_[1]);
         }
         else
         {
            _loc3_.data.item = {};
            _loc2_ = RoleModel.getInstance().findBagItemID(_loc4_[1]);
            if(_loc2_ == -1)
            {
               _loc3_.data.item.id = int(Math.random() * 10000);
            }
            else
            {
               _loc3_.data.item.id = _loc2_;
            }
            _loc3_.data.item.code = _loc4_[1];
            _loc3_.data.item.count = int(_loc4_[2]);
         }
         return _loc3_;
      }
      
      private function fubenAward(param1:Object) : Object
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Object;
         (_loc5_ = {}).success = true;
         _loc5_.data = {};
         _loc5_.data.stageID = param1.stageID;
         _loc5_.data.index = param1.index;
         _loc5_.data.result = param1.result;
         _loc5_.data.forward = [];
         switch(param1.index)
         {
            case 1:
               _loc2_ = param1.level * 100;
               _loc3_ = param1.level * 50;
               _loc4_ = param1.level * 50;
               break;
            case 2:
               _loc2_ = param1.level * 200;
               _loc3_ = param1.level * 100;
               _loc4_ = param1.level * 100;
               break;
            case 3:
               _loc2_ = param1.level * 300;
               _loc3_ = param1.level * 200;
               _loc4_ = param1.level * 200;
         }
         _loc5_.data.forward.push(RoleModel.getInstance().money + _loc2_);
         _loc5_.data.forward.push(RoleModel.getInstance().exploit + _loc3_);
         _loc5_.data.forward.push(RoleModel.getInstance().reverence + _loc4_);
         if(param1.index == 3)
         {
            _loc5_.data.pai = [];
            _loc5_.data.pai.push("2|10000");
            _loc5_.data.pai.push("1|proto_2_1|1");
            _loc5_.data.pai.push("1|proto_2_6|5");
            _loc5_.data.pai.push("1|proto_3_1|1");
            _loc5_.data.pai.push("1|proto_3_3|1");
            _loc5_.data.pai.push("1|proto_3_4|1");
         }
         return _loc5_;
      }
      
      private function fubenLogin(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         _loc2_.data = {
            "stageID":param1.stageID,
            "proto":param1.proto
         };
         return _loc2_;
      }
      
      private function fubenCount(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         _loc2_.data = {
            "stageID":param1.stageID,
            "count":2
         };
         return _loc2_;
      }
      
      private function fightResult(param1:Object) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:ArmyInfo = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Object;
         (_loc10_ = {}).success = true;
         _loc10_.data = {};
         _loc10_.data.part = param1.part;
         _loc10_.data.level = param1.level;
         _loc10_.data.money = Logic.getMoneyByFight(param1.m,param1.n);
         _loc10_.data.exploit = Logic.getExploitByFight(param1.m,param1.n);
         _loc10_.data.reverence = Logic.getReverenceByFight(param1.m,param1.n);
         var _loc11_:int = Data.getInstance().getStageID(param1.part,param1.level);
         var _loc12_:Vector.<int>;
         if((_loc12_ = RoleModel.getInstance().getFinished()).indexOf(_loc11_) == -1)
         {
            _loc12_.push(_loc11_);
            _loc10_.data.finished = _loc12_.join("|");
            _loc10_.data.award = {};
            _loc2_ = Data.getInstance().getAward(param1.part,param1.level);
            if(_loc2_ != null && _loc2_.money != null)
            {
               _loc10_.data.award.money = _loc2_.money;
            }
            if(_loc2_ != null && _loc2_.reverence != null)
            {
               _loc10_.data.award.reverence = _loc2_.reverence;
            }
            if(_loc2_ != null && _loc2_.exploit != null)
            {
               _loc10_.data.award.exploit = _loc2_.exploit;
            }
            _loc10_.data.award.soldier = [];
            if(_loc2_ != null && _loc2_.soldier != null)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc2_.soldier.length)
               {
                  (_loc4_ = Data.getInstance().getArmyInfo(_loc2_.soldier[_loc3_],1)).id = int(Math.random() * 100000);
                  _loc10_.data.award.soldier.push({
                     "id":_loc4_.id,
                     "code":_loc4_.code,
                     "level":_loc4_.level,
                     "evolution":_loc4_.evolution,
                     "feature":_loc4_.feature,
                     "genius":_loc4_.tianfu,
                     "kezhi":_loc4_.getKezhiStr()
                  });
                  _loc3_++;
               }
            }
            _loc10_.data.award.item = [];
            if(_loc2_ != null && _loc2_.proto != null)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc2_.proto.length)
               {
                  _loc7_ = String((_loc6_ = String(_loc2_.proto[_loc5_])).split(":")[0]);
                  _loc8_ = int(_loc6_.split(":")[1]);
                  if((_loc9_ = RoleModel.getInstance().findBagItemID(_loc7_)) != -1)
                  {
                     _loc8_ = RoleModel.getInstance().getBagItemCount(_loc7_) + _loc8_;
                  }
                  else
                  {
                     _loc9_ = int(Math.random() * 10000);
                  }
                  _loc10_.data.award.item.push({
                     "id":_loc9_,
                     "code":_loc7_,
                     "count":_loc8_
                  });
                  _loc5_++;
               }
            }
            _loc10_.data.m = RoleModel.getInstance().money + _loc10_.data.money + _loc2_.money;
            _loc10_.data.e = RoleModel.getInstance().exploit + _loc10_.data.exploit + _loc2_.exploit;
            _loc10_.data.r = RoleModel.getInstance().reverence + _loc10_.data.reverence + _loc2_.reverence;
         }
         else
         {
            _loc10_.data.finished = _loc12_.join("|");
            _loc10_.data.m = RoleModel.getInstance().money + _loc10_.data.money;
            _loc10_.data.e = RoleModel.getInstance().exploit + _loc10_.data.exploit;
            _loc10_.data.r = RoleModel.getInstance().reverence + _loc10_.data.reverence;
         }
         return _loc10_;
      }
      
      private function yanzheng(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         _loc2_.data = {"money":RoleModel.getInstance().money + 500};
         return _loc2_;
      }
      
      private function useAmmo(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         _loc2_.data = {"itemID":param1.id};
         return _loc2_;
      }
      
      private function history(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         _loc2_.data = {"history":param1.history};
         return _loc2_;
      }
      
      private function buyItem(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         var _loc3_:int = Data.getInstance().getAttributes("shop",param1.shopID,"payType");
         var _loc4_:String = Data.getInstance().getAttributes("shop",param1.shopID,"code");
         var _loc5_:int = Data.getInstance().getAttributes("shop",param1.shopID,"count");
         var _loc6_:int = Data.getInstance().getAttributes("shop",param1.shopID,"newPrice");
         var _loc7_:Number = RoleModel.getInstance().findBagItemID(_loc4_);
         var _loc8_:Object = {};
         if(_loc7_ == -1)
         {
            _loc8_.id = int(Math.random() * 10000);
            _loc8_.code = _loc4_;
            _loc8_.count = _loc5_;
         }
         else
         {
            _loc8_.id = _loc7_;
            _loc8_.code = _loc4_;
            _loc8_.count = RoleModel.getInstance().getBagItemCount(_loc4_) + _loc5_;
         }
         _loc2_.data = {};
         if(_loc3_ == 1)
         {
            _loc2_.data.money = RoleModel.getInstance().money - _loc6_;
            _loc2_.data.dianka = RoleModel.getInstance().dianka;
            _loc2_.data.item = _loc8_;
         }
         else
         {
            _loc2_.data.money = RoleModel.getInstance().money;
            _loc2_.data.dianka = RoleModel.getInstance().dianka - _loc6_;
            _loc2_.data.item = _loc8_;
         }
         _loc2_.data.exploit = RoleModel.getInstance().exploit;
         _loc2_.data.reverence = RoleModel.getInstance().reverence;
         return _loc2_;
      }
      
      private function dianka(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         _loc2_.data = {"dianka":RoleModel.getInstance().dianka};
         _loc2_.data.award = {
            "rmb":300,
            "general":"general_9_34|general_9_16",
            "item":"proto_1_5:1|proto_2_3:3",
            "money":100,
            "exploit":100
         };
         return _loc2_;
      }
      
      private function shangzhen(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         _loc2_.data = {"choose":param1.choose};
         return _loc2_;
      }
      
      private function tianfu(param1:Object) : Object
      {
         var _loc2_:Object = {};
         var _loc3_:ArmyInfo = RoleModel.getInstance().findSoldier(param1.id).clone();
         _loc2_.success = true;
         _loc2_.data = {};
         if(_loc3_.tianfu == null || _loc3_.tianfu == "")
         {
            _loc2_.data.dianka = RoleModel.getInstance().dianka;
            _loc2_.data.general = {};
            _loc2_.data.general.id = _loc3_.id;
            _loc2_.data.general.code = _loc3_.code;
            _loc2_.data.general.level = _loc3_.level;
            _loc2_.data.general.evolution = _loc3_.evolution;
            _loc2_.data.general.feature = _loc3_.feature;
            _loc2_.data.general.genius = Tools.randomFromArr(["tf_1","tf_4","tf_7","tf_10","tf_13","tf_16","tf_19"]);
            _loc2_.data.general.kezhi = _loc3_.getKezhiStr();
         }
         else
         {
            _loc2_.data.dianka = RoleModel.getInstance().dianka - 100;
            _loc2_.data.general = {};
            _loc2_.data.general.id = _loc3_.id;
            _loc2_.data.general.code = _loc3_.code;
            _loc2_.data.general.level = _loc3_.level;
            _loc2_.data.general.evolution = _loc3_.evolution;
            _loc2_.data.general.feature = _loc3_.feature;
            _loc2_.data.general.genius = "tf_" + Tools.randomFromArr([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]);
            _loc2_.data.general.kezhi = _loc3_.getKezhiStr();
         }
         return _loc2_;
      }
      
      private function kezhiShengji(param1:Object) : Object
      {
         var _loc2_:Boolean = false;
         var _loc3_:Object = {};
         var _loc4_:ArmyInfo = RoleModel.getInstance().findSoldier(param1.id).clone();
         _loc3_.success = true;
         _loc3_.data = {};
         _loc3_.data.money = RoleModel.getInstance().money - 1000;
         _loc3_.data.exploit = RoleModel.getInstance().exploit - 1000;
         _loc3_.data.itemID = RoleModel.getInstance().findBagItemID("proto_3_4");
         _loc3_.data.index = param1.index;
         switch(param1.index)
         {
            case 0:
               _loc2_ = Tools.getJilv(Logic.getKezhiJilv(_loc4_.kezhiLevel1));
               if(_loc2_)
               {
                  ++_loc4_.kezhiLevel1;
               }
               break;
            case 1:
               _loc2_ = Tools.getJilv(Logic.getKezhiJilv(_loc4_.kezhiLevel2));
               if(_loc2_)
               {
                  ++_loc4_.kezhiLevel2;
               }
               break;
            case 2:
               _loc2_ = Tools.getJilv(Logic.getKezhiJilv(_loc4_.kezhiLevel3));
               if(_loc2_)
               {
                  ++_loc4_.kezhiLevel3;
               }
         }
         if(_loc2_ == true)
         {
            _loc3_.data.general = {};
            _loc3_.data.general.id = _loc4_.id;
            _loc3_.data.general.code = _loc4_.code;
            _loc3_.data.general.level = _loc4_.level;
            _loc3_.data.general.evolution = _loc4_.evolution;
            _loc3_.data.general.feature = _loc4_.feature;
            _loc3_.data.general.genius = _loc4_.tianfu;
            _loc3_.data.general.kezhi = _loc4_.getKezhiStr();
         }
         return _loc3_;
      }
      
      private function jinhua(param1:Object) : Object
      {
         var _loc2_:Number = NaN;
         var _loc3_:Object = {};
         var _loc4_:ArmyInfo;
         if((_loc4_ = RoleModel.getInstance().findSoldier(param1.id).clone()).evolution >= 10)
         {
            _loc3_.success = false;
            _loc3_.message = "武将已经为进化上限";
         }
         else
         {
            _loc3_.success = true;
            _loc3_.data = {};
            _loc3_.data.money = RoleModel.getInstance().money - 1000;
            _loc3_.data.itemID = RoleModel.getInstance().findBagItemID(Data.getInstance().getAttributes("general",_loc4_.code,"proto"));
            _loc2_ = Logic.getJinhuaJilv(_loc4_.evolution);
            if(Tools.getJilv(_loc2_) == true)
            {
               if(_loc4_.type != Type.TOUSHICHE && _loc4_.evolution == 0)
               {
                  _loc4_.feature = Tools.randomFromArr([1,2,3,4]);
               }
               ++_loc4_.evolution;
               _loc3_.data.general = _loc4_;
            }
         }
         return _loc3_;
      }
      
      private function shuxingchongxi(param1:Object) : Object
      {
         var _loc2_:Number = NaN;
         var _loc3_:Object = {};
         var _loc4_:ArmyInfo = RoleModel.getInstance().findSoldier(param1.id).clone();
         if(RoleModel.getInstance().dianka < 100)
         {
            _loc3_.success = false;
            _loc3_.message = "点卡不足";
         }
         else
         {
            _loc3_.success = true;
            _loc3_.data = {};
            _loc3_.data.dianka = RoleModel.getInstance().dianka - 100;
            _loc3_.data.feature = Tools.randomFromArr([1,2,3,4]);
         }
         return _loc3_;
      }
      
      private function shengji(param1:Object) : Object
      {
         var _loc2_:Object = {};
         var _loc3_:ArmyInfo = RoleModel.getInstance().findSoldier(param1.id);
         if(_loc3_.level >= 220)
         {
            _loc2_.success = false;
            _loc2_.message = "武将已经顶级，无法继续升级";
         }
         else
         {
            _loc2_.success = true;
            _loc2_.data = {};
            _loc2_.data.money = RoleModel.getInstance().money - 100;
            _loc2_.data.exploit = RoleModel.getInstance().exploit - 100;
            _loc2_.data.id = param1.id;
            _loc2_.data.level = _loc3_.level + 1;
         }
         return _loc2_;
      }
      
      private function diankaZhaomu(param1:Object) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:Object = {};
         _loc3_.success = true;
         _loc3_.data = {};
         _loc3_.data.dianka = RoleModel.getInstance().dianka - 20;
         _loc3_.data.reverence = RoleModel.getInstance().reverence - 1000;
         var _loc4_:int = Data.getInstance().getAttributes("general",param1.code,"coint");
         if(Tools.getJilv(_loc4_ / 100) == true)
         {
            _loc2_ = {};
            _loc2_.id = int(Math.random() * 100) + int(Math.random() * 1000);
            _loc2_.code = param1.code;
            _loc2_.level = RoleModel.getInstance().level > 50 ? 30 : 1;
            _loc2_.evolution = 0;
            _loc2_.feature = 0;
            _loc2_.genius = null;
            _loc2_.kezhi = Data.getInstance().getAttributes("general",param1.code,"kezhi");
            _loc3_.data.general = _loc2_;
         }
         return _loc3_;
      }
      
      private function qiuxianZhaomu(param1:Object) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:Object = {};
         _loc3_.success = true;
         _loc3_.data = {};
         _loc3_.data.reverence = RoleModel.getInstance().reverence - 1000;
         var _loc4_:int = Data.getInstance().getAttributes("general",param1.code,"coint");
         if(Tools.getJilv(_loc4_ / 100) == true)
         {
            _loc2_ = {};
            _loc2_.id = int(Math.random() * 100) + int(Math.random() * 1000);
            _loc2_.code = param1.code;
            _loc2_.level = RoleModel.getInstance().level > 50 ? 30 : 1;
            _loc2_.evolution = 0;
            _loc2_.feature = 0;
            _loc2_.genius = null;
            _loc2_.kezhi = Data.getInstance().getAttributes("general",param1.code,"kezhi");
            _loc3_.data.general = _loc2_;
         }
         _loc3_.data.itemID = RoleModel.getInstance().findBagItemID("proto_3_3");
         return _loc3_;
      }
      
      private function putongZhaomu(param1:Object) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:Object = {};
         _loc3_.success = true;
         _loc3_.data = {};
         _loc3_.data.money = RoleModel.getInstance().money - 1000;
         _loc3_.data.reverence = RoleModel.getInstance().reverence - 1000;
         var _loc4_:int = Data.getInstance().getAttributes("general",param1.code,"jinbi");
         if(Tools.getJilv(_loc4_ / 100) == true)
         {
            _loc2_ = {};
            _loc2_.id = int(Math.random() * 100) + int(Math.random() * 1000);
            _loc2_.code = param1.code;
            _loc2_.level = RoleModel.getInstance().level > 50 ? 30 : 1;
            _loc2_.evolution = 0;
            _loc2_.feature = 0;
            _loc2_.genius = null;
            _loc2_.kezhi = Data.getInstance().getAttributes("general",param1.code,"kezhi");
            _loc3_.data.general = _loc2_;
         }
         return _loc3_;
      }
      
      public function getRegisterData() : String
      {
         var _loc1_:Object = {};
         _loc1_.userID = 20010907;
         _loc1_.token = "asdfadsfasdfaikasdf";
         return com.adobe.serialization.json.JSON.encode(_loc1_);
      }
      
      public function getLoginData() : String
      {
         var data:String = null;
         var file:File = File.applicationStorageDirectory.resolvePath("data.json");
         var fileStream:FileStream = new FileStream();
         try
         {
            fileStream.open(file,FileMode.READ);
            data = String(fileStream.readUTFBytes(fileStream.bytesAvailable));
            fileStream.close();
            return data;
         }
         catch(error:Error)
         {
            trace("读取文件失败: " + error.message);
         }
         return "";
      }
      
      private function httpRegister(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.success = true;
         _loc2_.data = com.adobe.serialization.json.JSON.decode(this.getLoginData());
         _loc2_.data.roleModel.userID = param1.userID;
         _loc2_.data.roleModel.roleName = param1.roleName;
         _loc2_.data.roleModel.imageID = param1.imageID;
         return _loc2_;
      }
      
      private function generalShengji(param1:Object) : Object
      {
         var _loc2_:ArmyInfo = RoleModel.getInstance().findSoldier(param1.id);
         var _loc3_:int = RoleModel.getInstance().money - 100;
         var _loc4_:int = RoleModel.getInstance().exploit - 100;
         var _loc5_:Object;
         (_loc5_ = {}).success = true;
         _loc5_.data = {
            "money":_loc3_,
            "exploit":_loc4_,
            "id":param1.id,
            "level":_loc2_.level + 1
         };
         return _loc5_;
      }
   }
}

class SingletonEnforcer
{
    
   
   public function SingletonEnforcer()
   {
      super();
   }
}
