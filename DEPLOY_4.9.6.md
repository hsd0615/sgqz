# v4.9.6 发布记录

## 修复

- 匈奴副本：staticgeneral.xml 缺少 general_10_1、11_1、12_1、13_1，XiongnuConfig 创建敌兵时对空对象读取属性，导致加载失败。按原始备份恢复弯刀兵、箭塔兵、强弓兵、头目四条配置，模型符号在现有 general.swf 中存在。同时保护无封面资源时的剧情回退。
- 投石车：客户端隐藏装备槽并阻止装备操作，服务端拒绝装备请求；战斗装备加成和服务端战力计算均排除投石车。启动迁移将历史装备按原所属玩家逐件退回背包，重复执行不会重复返还。
- 白装：旧编号草鞋 proto_4_16 缺少属性，补齐为防御14，与现有新版草鞋一致。补齐服务端特殊属性读取，木符与戒指的伤害加成正常通过 game-data 接口返回。其他装备平衡未调整。

## 验证

- test-xiongnu-equipment：匈奴配置与模型资源依赖、投石车限制、重复装备逐件返还和迁移幂等、12条白装客户端与服务端有效属性通过。
- 既有 army-factory、battle-cards、recruit-policy 回归通过；实际待部署服务端也通过装备及抽卡测试。
- Flex 编译通过，保留已有 UI.as forceHp 隐式布尔转换警告；重新生成189条武将数值表。
- 未执行原生 Flash 客户端逐场景交互测试。

## 部署与线上校验

- 目标 47.114.59.65:3000，实例 i-bp1e0xihm2iomvnexnld，主机 IZM2IOMVNEXNLDZ，仅重启 sgqz-online-4.9.0。
- 从线上实际服务端移植本次修改，保留 Windows 路径、认证等既有差异。
- 部署前版本4.9.5，核对服务端、SWF与根目录/客户端XML哈希后发布。
- 发布文件备份：C:\sgqz\backup-before-fix-4.9.6。该备份包含被替换的发布文件，不含玩家数据库；迁移后的数据库另存 C:\sgqz\backup-after-fix-4.9.6\data\sanguo.json。
- /api/version 返回4.9.6；main.swf、sanguo_web.swf重新下载后 SHA256 与编译产物相同，解压均含4.9.6；XML、网页缓存版本也通过下载哈希校验。
- SWF SHA256：21bd8eba97a2e6269998a8403e2b89d5d879cf0f4edd600a3e70307bd8b95117，1115196字节。
- 线上迁移日志确认返还12件；数据库检查投石车剩余装备0件；匈奴NPC配置4条，计划任务Running。
- 线上 /api/game-data 中12条白装均至少一项有效属性，含饰品特殊属性。
- 完整校验值见 DEPLOY_VERIFY_4.9.6.json。

## 工作区

发布代码位于 codex/restore-online-new-server 分支的隔离发布工作区。主工作区含用户其他未提交修改，本次未覆盖。发布记录同步至主工作区 output/model-audit 便于查阅。
