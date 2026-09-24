# v4.9.4 武斗兵模型修复与部署

- 修复 Fight.armyFactory 中武斗兵分支 return 被注释吞掉的问题；20 条 type=6 配置恢复正常皮肤加载，不再贯穿到 PartSoldier。
- 回归：20 条武斗兵配置 × 4 个进化等级，另验证 5 个控制分支；旧源码在同一检查中因 PartSoldier/Saber 不一致而失败。
- 使用 Flex SDK 编译成功（保留既有 UI.as forceHp 的 int→Boolean 警告）。swfdump 检查发布 SWF，武斗兵分支包含独立的 Saber constructprop 与 returnvalue，长矛兵仍独立创建 PartSoldier。
- 2026-09-24 已部署 47.114.59.65:3000，备份 C:\sgqz\backup-before-fix-4.9.4；只重启 sgqz-online-4.9.0 计划任务，保留线上服务端环境适配。
- 在线 /api/version 返回 4.9.4；main.swf 和 sanguo_web.swf 均重新下载校验，与本地编译文件一致，长度 1,114,067 字节。
- 两份 SWF SHA256：2f6392aeea7f11cc738adf061082c25f32864de9ffbb16ef8e5d1c62969f42c4；解压后含 4.9.4。
- 网页入口使用 sanguo_web.swf?v=4.9.4。武将数值表已重新生成，共185条。
- AGENTS.md 增加每次修复必须服务器部署和线上验证的要求，并标注当前 Windows 服务器与旧部署脚本的目标差异。
- 未进行原生 Flash 逐武将手工交互回归；未把另行发现的扩展皮肤后缀问题纳入此补丁。
