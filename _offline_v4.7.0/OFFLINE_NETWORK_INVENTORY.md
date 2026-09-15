# v4.7.0 网络访问盘点

本清单以 GitHub 提交 `6e62a6b`（v4.7.0）为基线，先记录所有可能访问远端或上传状态的入口，再进行单机化改造。

## 需要改为本地处理的写入接口

`AESController.mapHeadToURL()` 将以下请求映射到服务器：登录/注册/在线激活、战斗准备与结算、存档、历史记录、弹药、商城购买、点卡、招募、武将升级/进化/克制/天赋/重洗/上阵、装备穿戴/卸下/出售、求贤翻牌、副本进入/奖励/翻牌、擂台全部操作，以及补偿/领奖/国庆活动。这些调用统一由 `AESController.sendJSON()` 改走本地模拟处理，不再创建 `URLRequest`。

`AESController.sendJSONToURL()` 使用 `sendToURL()` 发送无响应 POST；单机模式直接记录并返回，不产生网络流量。

`RoleModel.saveToLocal()` 原本在网页模式会 POST `/api/save`；单机模式强制使用 AIR 本地 `data.json`。

## 需要改为本地数据读取的入口

- `game.xml` 中的 `DataLoader`：武将、系数、道具、商城、关卡、跑马灯、天赋和过滤词表。
- `Sanguo4399.as` 中商城/道具的二次服务器刷新和 `/api/game-data` 请求。
- 登录面板缓存账号查询 `/api/auth/player/:uid`。
- `Fight.as`、`Sanguo4399.as`、`Map.as` 中的关卡背景图片 URL。
- `WokouAssets.as` 中的 `/client/wokou_*.png`。
- `ChangelogPanel.as`、`UpdateChecker.as`、`PaihangPanel.as`、`OnlineCountUI.as` 的公告、更新、排行和在线人数请求。

## 联机专用入口

`ChatManager.as`、`HttpPollConnection.as`、`NetConnection`/`NetGroup` 以及擂台相关请求属于联机功能。单机模式保留界面代码和本地响应能力，但禁止 HTTP 轮询、P2P/TCP 连接及擂台网络发送。

## 本地已有存储

`RoleModel` 已支持 `File.applicationStorageDirectory/data.json`；`Sanguo4399.as` 已支持 `user_config.txt`。单机改造会把登录资料、角色初始化和后续所有状态更新统一落到这些本地文件。

