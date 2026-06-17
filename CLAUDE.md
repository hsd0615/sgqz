# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

三国Q战4399版 — 基于 Adobe Flash ActionScript 3 的 2D 回合制策略对战游戏，版本 `1.042`，Adobe AIR 桌面客户端。

所有 `.as` 文件是从编译后的 SWF 反编译（decompile）得到的源码，用于阅读分析和修改。**没有传统构建系统** — 无法直接编译回 SWF，修改代码后需要用 Adobe Flash Builder / Flex SDK 重新编译。

## 运行方式

1. 安装 Adobe AIR 运行时
2. 将 `data.json`（存档）放到 `C:\Users\<用户名>\AppData\Roaming\Main\Local Store\`
3. 双击 `main.exe` 启动游戏

`main.exe` 基于 `META-INF/AIR/application.xml` 配置（AIR 50.2，入口 `main.swf`）。

## 核心架构

### 入口与生命周期

- **`game/Sanguo4399.as`** — 主 Sprite，管理整个应用生命周期。初始化时通过 GreenSock LoaderMax 加载 SWF 资源文件和 XML 数据配置，然后创建 UI、Fight、ChatManager 等核心模块。持有 `_ui`、`_fight` 引用。

### 数据层（单例模式）

- **`game/Data.as`** — 静态数据层单例。解析 XML 配置表（武将 general、系数 xishu、道具 proto、商城 shop、关卡 stage、天赋 tianfu、跑马灯 paoma）。提供 `getLine()`、`getAttributes()`、`getArmyInfo()` 等查询接口，根据 code 从 XML 中查数据并构造 `ArmyInfo` 对象。
- **`game/model/RoleModel.as`** — 玩家运行时数据单例（EventDispatcher）。管理武将列表、背包、关卡进度、货币。**本地存档**通过 AES-128-CBC 加密写入 `File.applicationStorageDirectory/data.json`。
- **`game/model/ArmyInfo.as`** — 武将属性模型。所有数值属性（level、hp、attack、defense 等）的 getter/setter 都用 `Config.timer` 做偏移存储，防止直接修改内存。包含兵种克制（kezhi1/2/3 及克制等级）、天赋加成（tianfuAttack/Defence/HP）、进化加成（evolution → getAddtion）。

### 战斗系统

- **`game/Fight.as`** — 战斗场景核心类（implements `IWorld`, `IAI`）。管理布阵位置、士兵选中、瞄准、攻击发射、弹药系统、AI 驱动、加速检测。左右各最多 6 个士兵。
- **`game/Logic.as`** — 纯静态战斗公式。`getHurtVale()` 实现双重克制（兵种克制 + 五行属性克制），9 种组合情况。伤害 = `attack × 克制系数 - defense / 5`，最小值 1。投石车走 `getHurtByToushiche()` 特殊公式。还包含属性成长公式、进化/克制概率表、战斗奖励计算。
- **`game/display/`** — 士兵显示类：`AbstractSoldier`（基类）、`Saber`（骑兵/近战）、`Shooter`（远程）、`Gunner`（投石车）、`Junzhu`（君主）。`Weapon`/`StoneWeapon` 为飞行投射物。
- **`game/model/Type.as`** — 14 种兵种常量：投石车(0)、弓兵(1)、飞刀兵(2)...君主(20)。含中文名映射和克制描述。

### AI 系统

- **`game/ai/AI.as`** — 每帧随机选一个可用兵种行动，成功率 = `ai参数/100`。将士兵按类型分组（Saber/Gunner/Shooter/Junzhu），随机挑一组，再随机选组内一个。行动后进入冷却期（`delay/2` 到 `delay` 随机）。投石车 AI 根据目标距离计算抛物线角度。

### 网络通信

- **`com/iflashigame/net/ChatManager.as`** — P2P 联机核心（单例）。基于 Flash `NetGroup` 实现 P2P 对战同步，同时处理聊天消息、擂台赛匹配。
- **`com/iflashigame/utils/AESTools.as`** — AES-128-CBC 加解密，用于 HTTP 请求体和本地存档。
- **`game/Config.as`** — 全局配置。`SERVER_URL` 指向游戏服务器（默认 `192.168.1.104:8080`）。包含加密常量数组（ARR1-6）、聊天延迟、擂台赛间隔、反作弊阈值。

### 第三方库

- **`com/hurlant/`** — AS3 密码学库（AES/RSA/MD5/SHA/DES/Base64）
- **`com/greensock/`** — TweenLite 动画引擎 + LoaderMax 资源加载
- **`com/adobe/serialization/json/`** — JSON 编解码
- **`fl/controls/`** — Flash 原生 UI 组件
- **`unit4399/`** — 4399 平台 SDK

### UI 层

- **`game/UI.as`** — 主界面管理，包含主菜单、武将管理、商城、擂台等子面板
- **`game/ui/FightUI.as`** — 战斗界面 HUD（生命条、弹药选择、力度条）
- SWF 资源文件：`ui.swf`、`general.swf`、`superGeneral.swf`、`face.swf`、`fubenui.swf`、`sound.swf` 包含所有图形/动画/音效素材

### 反作弊机制

1. 所有关键数值属性用 `Config.timer` 偏移存储（真实值 = 存储值 - timer），直接改内存数值会被偏移抵消
2. `GlobalTimer` 每 5 秒检测时间流速，连续异常 6 次 → 判定变速作弊
3. 战斗操作限时检测（`Config.ERROR` / `Config.NORMAL`）

## 版本发布流程（每次修改代码必须完整执行）

### 第一步：版本号
同时修改3处版本号（当前 `2.7.0`，递增如 `2.8.0`）：
1. `game/Config.as` → `CLIENT_VER`
2. `server/start_fixed.js` → 搜索替换所有旧版本字符串
3. `CHANGELOG.md` → 在顶部新增版本条目

### 第二步：编译 SWF（仅当修改了 .as 源码时）
```bash
java -jar "D:/BaiduNetdiskDownload/flex_home/lib/mxmlc.jar" \
  +flexlib="D:/BaiduNetdiskDownload/flex_home/frameworks" \
  -compiler.source-path=. -default-size=770,500 -target-player=32.0 \
  -static-link-runtime-shared-libraries=true \
  -library-path+=air_stubs.swc \
  -- game/Sanguo4399.as
cp game/Sanguo4399.swf main.swf
```
注意：只改了 XML 数据文件(staticxishu.xml/staticgeneral.xml)不需要重新编译。

### 第三步：部署到云端
```bash
# 改了.as源码 → 编译+部署（包含SWF上传）
node tools/cloud-deploy.js --full

# 只改了XML/服务端 → 直接部署
node tools/cloud-deploy.js

# 查看服务器状态
node tools/cloud-deploy.js --status
```

### 第四步：验证
- 服务端版本：`curl -s -X POST http://47.96.41.243:3000/api/version -d '{}'`
- SWF版本一致性：下载 `/client/main.swf`，解压检查 `CLIENT_VER` 字符串
- 生成本地武将数值HTML：`node tools/gen_general_table.js`

### 第五步：Git 提交
```bash
git add -A && git commit -m "vX.Y.Z: <描述>"
```

## 工具脚本

- **`tools/cloud-deploy.js`** — 云端一键部署（编译SWF + 上传 + 重启 + 验证 + 生成HTML）
- **`tools/gen_general_table.js`** — 武将数值表生成（读取XML → 计算公式 → 输出HTML到桌面）
- **`tools/cloud-config.json`** — 阿里云 AccessKey + 实例ID（git-ignored）
- **`tools/read_image.ps1`** — 截图 OCR 识别（文件/剪贴板）
- **`tools/img2txt.ps1`** — 备用：将图片转 ASCII 亮度网格

## 关键数据流

```
游戏启动 → LoaderMax 加载 XML + SWF
       → Data.init*XML() 解析配置
       → RoleModel 从本地 AES 解密 data.json 恢复进度
       → 玩家选关 → Data.getGateArmys() 构建敌方 Vector.<ArmyInfo>
       → Fight 创建 AbstractSoldier 实例排列战场
       → 玩家点击操作 或 AI 驱动 → Logic.getHurtVale() 计算伤害
       → 战斗结束 → RoleModel 更新进度 → AES 加密存盘
```
