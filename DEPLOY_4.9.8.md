# 4.9.8 发布记录

- 目标：`47.114.59.65:3000`，主机 `IZM2IOMVNEXNLDZ`，计划任务 `sgqz-online-4.9.0`。
- 发布前线上版本：4.9.7；发布后 `/api/version`：4.9.8，`/api/health`：ok，任务状态：Running。
- 发布包：客户端两个 SWF、服务端 `start_fixed.js`、武将与关卡 XML（含客户端副本）、网页入口与版本文件。
- 备份：`C:\sgqz\backup-before-fix-4.9.8-full`，包含发布前文件与 `data\sanguo.json`。
- 线上下载 `main.swf` 与 `sanguo_web.swf` 的 SHA256 均为 `4576fb6dfb0ba4ab11839cc90a4182848996b24a68a5c7e8e0b7d70f79feebfd`，SWF 内版本字符串均为 4.9.8。
- 服务端文件 SHA256：`3a3052e35725a5f48bfe9e3ec35bb5714f175058cab2410b6134ac88a85a70a2`；线上配置 SHA256 详见 `DEPLOY_VERIFY_4.9.8.json`。
- 删除旧弓兵吕蒙后，线上数据库残留数为 0；新模型吕蒙仍有 2 条武将实例。旧武将已穿戴装备由启动迁移归还背包。
- 验证：Flex 编译成功（仅既有 `int` 转 `Boolean` 警告）；武将/碰撞、战斗翻牌、招募、匈奴装备及广播回归测试通过。未做原生 Flash 客户端人工战斗操作测试。
