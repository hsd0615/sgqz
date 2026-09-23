# 三国Q战 v4.7.3 单机版

发行包用 `tools/package-offline.ps1` 生成，包含所有章节背景和地图图标，并核对每个压缩条目的 SHA256。
解压整个目录后运行 main.exe；需要已安装 Adobe AIR。存档沿用原目录，发行包不含玩家存档。
未实现的单机请求明确提示暂不支持，避免原先通用成功响应造成假成功或异常。

该目录以 GitHub 提交 `6e62a6b`（v4.7.0，长枪兵模型加入前一个版本）为基线。

单机版行为：

- `Config.OFFLINE_MODE = true`；客户端不连接远程 HTTP、TCP、HTTP 轮询或 P2P 服务。
- 登录、注册、战斗准备、战斗结算、武将成长、商城/背包请求和其他原 HTTP 请求进入 `Test.as` 的本地处理层。
- 游戏 XML 从客户端目录加载，不再从服务器下载。
- 存档使用 AIR 的 `File.applicationStorageDirectory/data.json`。
- 公告、更新检查、排行榜、在线人数和战力上报在单机模式下关闭或显示本地提示。
- `general.swf`、`ui.swf`、音效和数据 XML 均作为本地发行文件使用。

编译命令：

```powershell
java -jar "D:/BaiduNetdiskDownload/flex_home/lib/mxmlc.jar" `
  "+flexlib=D:/BaiduNetdiskDownload/flex_home/frameworks" `
  "-compiler.source-path=." -default-size=770,500 -target-player=32.0 `
  -static-link-runtime-shared-libraries=true -library-path+=air_stubs.swc `
  -- game/Sanguo4399.as
Copy-Item game/Sanguo4399.swf main.swf -Force
```
