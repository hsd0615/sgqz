# 4.9.11 发布记录

- 目标：`47.114.59.65:3000`，主机 `IZM2IOMVNEXNLDZ`，计划任务 `sgqz-online-4.9.0`。
- 发布前线上版本：4.9.10；发布后 `/api/version`：4.9.11，`/api/health`：ok，任务状态：Running。
- 第三关出现反叛将领且获胜后，六张翻牌必有一张对应武将；候选池包含三名君主。武将卡改为从战斗模型绘制头像，并限制在卡面内。
- 静态检查 24 名候选将领的头像模型资源均可解析。服务端 JavaScript 语法检查、Flex 编译和 SWF 版本验证通过；未做原生 Flash 客户端人工翻牌测试。
- 备份：`C:\sgqz\backup-before-fix-4.9.11`；发布包 SHA256：`6e4f184ff01ce32b0996c2fa31402b3acb8d4b2ce459f05c7183e7f29de75b55`。
- 公网重新下载两个 SWF，SHA256 均为 `fbadb50aa859216269b49b1e19fbb39c8fdacd4dfe92984a5feb68ac221def4b`，各 1,117,103 字节，内嵌版本均为 4.9.11，与本次编译产物一致。
- 临时部署 SSH 密钥已从服务器移除。Flex 编译仅有既有 `UI.as` 中 `int` 转 `Boolean` 警告。
