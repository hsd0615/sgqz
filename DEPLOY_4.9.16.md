# 4.9.16 发布记录

- 目标：`47.114.59.65:3000`，线上版本 4.9.16。
- 修复匈奴翻牌超级武将缺少 `general_id` 的根因：翻牌创建记录现在写入可玩 ID；启动迁移会为旧记录补齐 ID。
- 线上迁移验证：212 条武将记录中缺失 `general_id` 为 0；张飞记录已可查询到有效 ID。
- 线上备份：`C:\sgqz\backup-before-fix-4.9.16`；计划任务 `sgqz-online-4.9.0` 状态 Running。
- 编译并部署 SWF：`main.swf` 与 `sanguo_web.swf` SHA256 `6ca82ef626aad3968a883468f2d119d69742db5fd4e4f4065fcb4736500b0aa5`，内嵌版本为 4.9.16。
