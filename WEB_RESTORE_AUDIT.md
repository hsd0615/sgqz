# 网页版历史核对（2026-09-24）

## 检索范围

- 已 fetch GitHub hsd0615/sgqz，检查 origin/master、origin/rc/modiitem 和全部本地历史。
- 检查主工作区、9月23日部署 worktree/web-build、本地 client、旧客户端目录、桌面游戏备份和 sanguo-backups。
- 下载新服务器实际运行的 start_fixed.js 与仓库对比；旧服务器 47.96.41.243:3000 本次无法访问。

## 可核对的历史依据

- 56587a1：网页入口是 client/index.html 的 Flash object/embed，770×500；HTTP 轮询和同源 XML/SWF。
- 47e9b81：使用 library-path+=air_stubs.swc 的通用 SWF 编译，兼容 AIR 与 Flash Player。
- 99083f8 / 当前 tools/cloud-deploy.js：将同一 main.swf 同步为 sanguo_web.swf，flashvars isWeb=1 切换网页模式。
- 1a2ea4a：战斗使用 ExternalInterface 轮询 JavaScript。当前 Fight/P2PFight 调用 _sgqzPollKey，但已提交的旧 HTML 未包含此桥接，因此恢复时补齐。
- 575b2fa 等：HttpPollConnection 和服务端消息投递后续修复。保留最新通信逻辑，不整体回退游戏业务。
- 6adf6cf：本次恢复期间改为 Ruffle，替换了原页面和在线玩家列表；不是原来的实现。
- cb6ee02：实际仅增加空行。线上脚本也仍然发送 no-cache, no-store；之前缓存已修复的结论不成立。

## 资源与显示差异

- 原 general.swf / 本地 before-external 备份为 817,771 字节；当前 general.swf 为 113,612,274 字节，已经 CWS 压缩。
- 014053c 引入大型扩展武将资源，属于后期内容变更。不能直接换回小文件，否则会丢失当前武将皮肤。
- 原 Flash 直接使用系统 _sans 中文字体。Ruffle 的字体问题不能靠替换成英文视为完成修复。
- 上一轮仅临时 web-build 和线上产物改过英文；恢复使用仓库中文源码，不沿用临时产物。

## v4.9.2 恢复内容

- 恢复原 Flash object/embed 页面、在线玩家栏、账号缓存和 HTTP 轮询。
- 按历史通用编译参数产生同一桌面/网页 SWF，保留中文。
- 补回按键状态桥接，并在通用入口中保留原 Web wrapper 的同源服务器推导，避免默认 localhost。
- 修复带查询参数的首页路由；SWF/图片缓存一天，HTML/XML 重新验证。
- 保留全部最新扩展模型，首次加载 113.6 MB 的成本依然存在，不能声称恢复到早期首次加载速度。

## 验证边界

服务端接口、SWF 编译版本/哈希、HTTP 缓存、HTML/JavaScript 合约可自动检查。当前可控的内置浏览器不提供原生 Flash；不能用 Ruffle 的截图证明原生 Flash 的登录、中文和战斗通过。需在用户原来的 Flash 运行环境完成实际交互验证。

## 已执行的发布检查

- 云端备份：C:\sgqz\backup-before-native-4.9.2，仅更新 3000/3001 新服务，未操作 8080/8088 服务。
- 服务器 /api/version 返回 4.9.2；带查询参数首页返回原生 Flash HTML，无 Ruffle 引用。
- 下载线上 sanguo_web.swf，与本地 main.swf 逐字节一致；SHA256 为 5699D16AA115B31F75EDEEF516F316533BFC848CFA972FD71B18FDD1985173FF。
- SWF 解压检查包含版本号 4.9.2 和中文“入  营”；不是英文化临时产物。
- SWF HTTP 响应缓存为 public, max-age=86400；game_web.xml 为 no-cache。
- JavaScript 语法检查和按键按下/释放/小键盘/失焦回归通过；武将数值 HTML 已重新生成（185 武将）。
- 原 tools/cloud-deploy.js 面向旧 Linux 实例，因此本次使用 Windows 云助手与 SSH 上传执行等价的备份、编译产物上传、计划任务重启和验证。
