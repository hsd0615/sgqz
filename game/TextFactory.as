package game
{
   import game.model.ArmyInfo;
   
   public class TextFactory
   {
       
      
      public function TextFactory()
      {
         super();
      }
      
      public static function makeZhankuang(param1:String, param2:String) : String
      {
         if(Math.random() > 0.5)
         {
            return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【战情】</font>五丈原沙场，<font color=\'#ff9966\'>[" + param1 + "]</font>率精兵无数摆下十面埋伏。一举击败了<font color=\'#ff9966\'>[" + param2 + "]</font>的精锐部队，凯旋而归。</font>\n";
         }
         return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【战情】</font><font color=\'#ff9966\'>[" + param2 + "]</font>将士虽勇猛，却有勇无谋。手下武将被<font color=\'#ff9966\'>[" + param1 + "]</font>用连环计逐个击破，打得落荒而逃。</font>\n";
      }
      
      public static function makeZhankuangException(param1:String, param2:String) : String
      {
         return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【战情】</font>漠北沙场上，<font color=\'#ff9966\'>[" + param1 + "]</font>正与<font color=\'#ff9966\'>[" + param2 + "]</font>杀得天昏地暗。忽然狂风啸起、黄沙漫天，<font color=\'#ff9966\'>[" + param2 + "]</font>的军队居然被风沙卷走，<font color=\'#ff9966\'>[" + param1 + "]</font>神奇般获胜。</font>\n";
      }
      
      public static function makeZhaomu(param1:String, param2:ArmyInfo) : String
      {
         var _loc3_:String = param2.title == 0 ? "<font color=\'#66ffcc\'>超级武将</font>" : "<font color=\'#66ffcc\'>一流武将</font>";
         var _loc4_:String = "<font color=\'#ff3300\'>【系统】</font>";
         var _loc5_:Number;
         if((_loc5_ = Math.random()) < 0.25)
         {
            _loc4_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>成功招募到" + _loc3_ + "<font color=\'#ff9966\'>[" + param2.name + "]</font>，迎风一摆小腰，说道：不要羡慕哥，哥只是个传说。";
         }
         else if(_loc5_ < 0.5)
         {
            _loc4_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>对着" + _loc3_ + "<font color=\'#ff9966\'>[" + param2.name + "]</font>不停抛媚眼，对方招架不住，终于无奈宣布效忠。";
         }
         else if(_loc5_ < 0.75)
         {
            _loc4_ += _loc3_ + "<font color=\'#ff9966\'>[" + param2.name + "]</font>面对玩家<font color=\'#ff9966\'>[" + param1 + "]</font>摆出的大量金银珠宝，两眼放光，大叫一声“老大，我要”。";
         }
         else
         {
            _loc4_ += "<font color=\'#ff9966\'>[" + param1 + "]</font>出门打酱油，遇到了正在闲逛的" + _loc3_ + "<font color=\'#ff9966\'>[" + param2.name + "]</font>，在一番大肆吹嘘之后，武将<font color=\'#ff9966\'>[" + param2.name + "]</font>竟然愿意追随于他。";
         }
         return _loc4_ + "\n";
      }
      
      public static function makeJinhua(param1:String, param2:ArmyInfo) : String
      {
         var _loc3_:String = "<font color=\'#ff3300\'>【系统】</font>";
         var _loc4_:Number;
         if((_loc4_ = Math.random()) < 0.3)
         {
            _loc3_ += "一阵金光闪过，玩家<font color=\'#ff9966\'>[" + param1 + "]</font>的武将<font color=\'#ff9966\'>[" + param2.name + "]</font>成功进化到了<font color=\'#ff9966\'>" + param2.evolution + "</font>级。";
         }
         else if(_loc4_ < 0.6)
         {
            _loc3_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>在进化神坛满眼期待地看着，突然武将<font color=\'#ff9966\'>[" + param2.name + "]</font>大吼一声，终于进化到了<font color=\'#ff9966\'>" + param2.evolution + "</font>级。";
         }
         else
         {
            _loc3_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>对着武将<font color=\'#ff9966\'>[" + param2.name + "]</font>说：“再不进化到<font color=\'#ff9966\'>" + param2.evolution + "</font>级，晚上晚饭取消!”，对方迫于压力，只得乖乖就范。";
         }
         return _loc3_ + "\n";
      }
      
      public static function makeFuben(param1:String, param2:String, param3:int) : String
      {
         var _loc4_:String = Data.getInstance().getAttributes("proto",param2,"name");
         var _loc5_:String = "<font color=\'#ff3300\'>【系统】</font><font color=\'#f8a3cd\'>";
         var _loc6_:Number;
         if((_loc6_ = Math.random()) < 0.3)
         {
            _loc5_ += "玩家<font color=\'#00e3ff\'>[" + param1 + "]</font>号令众武将对着匈奴头目一阵拳打脚踢，趁机顺手牵羊得手<font color=\'#eaf800\'>[" + _loc4_ + "]</font>" + param3 + "个。";
         }
         else if(_loc6_ < 0.6)
         {
            _loc5_ += "玩家<font color=\'#00e3ff\'>[" + param1 + "]</font>狂追着匈奴头目脚底一滑，低头一看，" + param3 + "个<font color=\'#eaf800\'>[" + _loc4_ + "]</font>在闪闪发光，大笑一声，满意而归。";
         }
         else
         {
            _loc5_ += "匈奴头目鼻青脸肿地捧上" + param3 + "个<font color=\'#eaf800\'>[" + _loc4_ + "]</font>，对着玩家<font color=\'#00e3ff\'>[" + param1 + "]</font>轻声说：“你要你就说嘛，把别人脸都打破相了，怎么见人啊”";
         }
         return _loc5_ + "\n</font>";
      }
      
      public static function makeTianfu(param1:String, param2:ArmyInfo) : String
      {
         var _loc3_:String = Data.getInstance().getAttributes("tianfu",param2.tianfu,"name");
         var _loc4_:String;
         return (_loc4_ = (_loc4_ = "<font color=\'#ff3300\'>【系统】</font>") + ("玩家<font color=\'#ff9966\'>[" + param1 + "]</font>耗尽心力为心爱的武将<font color=\'#ff9966\'>[" + param2.name + "]</font>伐精洗髓,终获回报-天赋：<font color=\'#ff9966\'>" + _loc3_ + "</font>惊耀现世!")) + "\n";
      }
      
      public static function makeKezhiJinjie(param1:String, param2:String, param3:String, param4:String) : String
      {
         var _loc5_:String = "<font color=\'#ff3300\'>【系统】</font>";
         var _loc6_:Number;
         if((_loc6_ = Math.random()) < 0.5)
         {
            _loc5_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>心腹爱将<font color=\'#ff9966\'>[" + param2 + "]</font>终日勤修兵书，成功进阶到<font color=\'#ff9966\'>克制" + param3 + param4 + "级</font>。";
         }
         else
         {
            _loc5_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>军中将领<font color=\'#ff9966\'>[" + param2 + "]</font>成功进阶到<font color=\'#ff9966\'>克制" + param3 + param4 + "级</font>，令天下" + param3 + "胆寒。";
         }
         return _loc5_ + "\n";
      }
      
      public static function makeStageStr(param1:String, param2:int) : String
      {
         var _loc3_:String = "<font color=\'#ff3300\'>【快报】</font>";
         switch(param2)
         {
            case 111:
               _loc3_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>兵强马壮，强力冲击试炼之地-<font color=\'#ff9966\'>巨斧阵</font>成功！";
               break;
            case 113:
               _loc3_ += "试炼之地-<font color=\'#ff9966\'>狂骑阵</font>忽然人仰马翻，原来玩家<font color=\'#ff9966\'>[" + param1 + "]</font>率领大军杀入，果真威猛!";
               break;
            case 112:
               _loc3_ += "试炼之地-<font color=\'#ff9966\'>银枪阵</font>看似凶险无比，玩家<font color=\'#ff9966\'>[" + param1 + "]</font>一骑杀出、仰天大笑，我将全部克枪，你能耐我何！";
               break;
            case 114:
               _loc3_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>突入试炼之地-<font color=\'#ff9966\'>飞矢阵</font>，冒着箭雨强夺对方将旗，真英雄也！";
               break;
            case 115:
               _loc3_ += "试炼之地-<font color=\'#ff9966\'>铁拳阵</font>传来马蹄隆隆，敌将纷纷逃散，原来是玩家<font color=\'#ff9966\'>[" + param1 + "]</font>冲阵成功！";
               break;
            case 116:
               _loc3_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>真不知道怜香惜玉，大破<font color=\'#ff9966\'>凤舞阵<font>，美女飞刀兵们一脸哀怨。";
               break;
            case 117:
               _loc3_ += "试炼之地-<font color=\'#ff9966\'>铜锤阵</font>传出异相，只见铜锤满地，不见敌将踪影，唯有玩家<font color=\'#ff9966\'>[" + param1 + "]</font>横戟长啸！";
               break;
            case 118:
               _loc3_ += "试炼之地-<font color=\'#ff9966\'>北斗七星阵</font>内星光忽然暗淡下来，玩家<font color=\'#ff9966\'>[" + param1 + "]</font>破阵而出，众将齐吼，我军威武！";
               break;
            case 119:
               _loc3_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>厉兵秣马，再踏试炼之地-<font color=\'#ff9966\'>八门金锁阵</font>，旋风般斩关夺将，留下迷一般的身影。";
               break;
            case 120:
               _loc3_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>直捣试炼之地-<font color=\'#ff9966\'>十面埋伏阵</font>，敌军不堪抵挡，纷纷落马！ ";
               break;
            default:
               return null;
         }
         return _loc3_ + "\n";
      }
      
      public static function makeDixi(param1:String, param2:int) : String
      {
         var _loc3_:String = "<font color=\'#ff3300\'>【快报】</font>";
         switch(param2)
         {
            case 121:
               _loc3_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>听闻外敌入侵，立马率将士前往战场，如狂风扫过，匈奴前哨纷纷落马!";
               break;
            case 122:
               _loc3_ += "匈奴军队处心积虑安排伏击，被玩家<font color=\'#ff9966\'>[" + param1 + "]一眼识破，将计就计，大破伏击阵!";
               break;
            case 123:
               _loc3_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>一骑当先，深入匈奴战场腹地，顿时硝烟四起，杀得敌军四散逃窜。";
               break;
            case 124:
               _loc3_ += "圆弓阵来袭气势汹汹，玩家<font color=\'#ff9966\'>[" + param1 + "]</font>大笑一声，我将血厚防高，你能奈我何？";
               break;
            case 125:
               _loc3_ += "匈奴军队竖壁清野，玩家<font color=\'#ff9966\'>[" + param1 + "]</font>闯入深沟壁垒，历经苦战，终擒获敌手！";
               break;
            case 126:
               _loc3_ += "大地震动，远处大批匈奴铁骑蜂拥而来，玩家<font color=\'#ff9966\'>[" + param1 + "]</font>乱军之中指挥有度，浴血击败来犯之敌！";
               break;
            case 127:
               _loc3_ += "盟军有难，玩家<font color=\'#ff9966\'>[" + param1 + "]</font>飞速驰援，宛如战神再世！";
               break;
            case 128:
               _loc3_ += "匈奴军队用烈火燎原之计，玩家<font color=\'#ff9966\'>[" + param1 + "]</font>血染战衣，斗志愈加昂扬，终大退敌军。";
               break;
            case 129:
               _loc3_ += "玩家<font color=\'#ff9966\'>[" + param1 + "]</font>中计陷入绝境，但将士们齐心协力，破釜成舟，展开绝地大反击！大胜！";
               break;
            case 130:
               _loc3_ += "匈奴大单于亲领大军来犯，玩家<font color=\'#ff9966\'>[" + param1 + "]</font>大吼：犯我大汉天威，虽远必诛!强势灭之，一战扬名！天下英雄为之楷模也！";
               break;
            default:
               return null;
         }
         return _loc3_ + "\n";
      }
      
      public static function makeLeitai(param1:int, param2:String) : String
      {
         var _loc3_:Number = Math.random();
         if(Math.random() > 0.6)
         {
            return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【擂台】</font><font color=\'#ff9966\'>" + param1.toString() + "级</font>的擂台已被<font color=\'#ff9966\'>[" + param2 + "]</font>开启，有实力的高手速度报名啊！</font>\n";
         }
         if(Math.random() > 0.3)
         {
            return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【擂台】</font><font color=\'#ff9966\'>[" + param2 + "]</font>一跃而上<font color=\'#ff9966\'>" + param1.toString() + "级</font>的擂台，虎躯一振，大吼：谁敢挑战我！</font>\n";
         }
         return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【擂台】</font><font color=\'#ff9966\'>[" + param2 + "]</font>在众人的围观中缓步踏上<font color=\'#ff9966\'>" + param1.toString() + "级</font>的擂台，一弹衣袖：我当擂主，有谁不服？</font>\n";
      }
      
      public static function makeShouleiFirst(param1:String, param2:String) : String
      {
         var _loc3_:Number = Math.random();
         if(Math.random() > 0.5)
         {
            return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【擂台】</font>擂台上兵来将往，几个回合下来，擂主<font color=\'#ff9966\'>[" + param1 + "]</font>率领众将士力夺对方帅旗，攻擂方<font color=\'#ff9966\'>[" + param2 + "]</font>铩羽而归。</font>\n";
         }
         return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【擂台】</font><font color=\'#ff9966\'>[" + param2 + "]</font>带领爱将气势汹汹攻打擂台，然而擂主<font color=\'#ff9966\'>[" + param1 + "]</font>技高一筹，笑言：我的擂台我做主！</font>\n";
      }
      
      public static function makeGonglei(param1:String, param2:String) : String
      {
         var _loc3_:Number = Math.random();
         if(Math.random() > 0.5)
         {
            return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【擂台】</font><font color=\'#ff9966\'>[" + param2 + "]</font>猛将如云，策马狂奔直上擂台，擂主<font color=\'#ff9966\'>[" + param1 + "]</font>不慎落马，擂主之位被迫拱手相让。</font>\n";
         }
         return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【擂台】</font>擂台下围观众人一声暴喝：好！，只见<font color=\'#ff9966\'>[" + param2 + "]</font>成功夺得擂主宝座，正乐呵呵地抱着奖池数钱中。</font>\n";
      }
      
      public static function makeShoulei(param1:String, param2:int, param3:int) : String
      {
         var _loc4_:Number = Math.random();
         if(Math.random() > 0.5)
         {
            return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【擂台】</font>擂主<font color=\'#ff9966\'>[" + param1 + "]</font>兵强马壮，再次守擂成功！奖池基金累计到<font color=\'#ff9966\'>" + param3.toString() + "</font>，望有实力的君主速来赢取。</font>\n";
         }
         return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【擂台】</font>号外号外！<font color=\'#ff9966\'>" + param2.toString() + "级</font>的擂台奖池基金已累计到<font color=\'#ff9966\'>" + param3.toString() + "</font>，呼唤高手速度打败擂主<font color=\'#ff9966\'>[" + param1 + "]</font>，领取全额奖金！</font>\n";
      }
      
      public static function makeShouleiSuccess(param1:String, param2:int) : String
      {
         return "<font color=\'#00ccff\'><font color=\'#ff3300\'>【擂台】</font><font color=\'#ff9966\'>[" + param1 + "]</font>实力在擂台连胜20场，独得全额奖池基金：<font color=\'#ff9966\'>" + param2.toString() + "</font></font>\n";
      }
   }
}
