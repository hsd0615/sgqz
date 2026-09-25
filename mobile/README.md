# Android AIR 安装测试版

## 安装包

`output/android/sanguoqz-android-arm64.apk`，约 124.4 MiB。
包名 `air.com.sanguoqz.online`，Android 6.0+，ARM64 架构。
内置 AIR 运行时，无需单独安装 AIR。自签名测试证书有效期至 2051 年。
将 APK 传到手机后打开安装；不是 iOS 安装包。

## 已配置环境

- AIR SDK 50.2.4.1：`D:/tools/AIRSDK-50.2.4.1`
- Flex SDK：`D:/BaiduNetdiskDownload/flex_home`
- JDK：`D:/jdk`
- 签名证书和本地配置：`%LOCALAPPDATA%/SGQZAndroid/`，不可随安装包发送。
- 已设置用户级 `AIR_SDK` 环境变量。

重新构建：`powershell -ExecutionPolicy Bypass -File tools/build-android.ps1`
脚本在 `output/android/source` 创建源码快照，使用真正的 airglobal.swc 编译。
编译失败或签名失败会终止；不会覆盖桌面 main.swf。
复用原签名证书可覆盖安装后续 APK，请保留签名目录。

## 验证记录（2026-09-25）

- SWF 编译成功，原有 UI.as 类型转换警告仍存在。
- ADT 生成内置运行时 ARM64 APK 成功。
- jarsigner：jar verified；自签名证书和无时间戳提示是测试签名的预期结果。
- aapt：包名、ARM64 ABI、最低 API 23、目标 API 33、联网权限、明文 HTTP 放行配置均正确。
- APK 内 main.swf、6 个资源 SWF、game_mobile.xml 与构建文件逐一 SHA256 一致。
- SWF 包含 4.9.8-android.1、当前服务器地址、移动配置路径，不含旧服务器 IP。
- APK SHA256：2f07407dd51cc211133d2ed5c8ce81b3ef4fedd46bf233b87d2557c6fa2f841d。
- 线上 POST /api/version 返回 4.9.8（仅只读查询）。
- adb 无设备；本机 MuMu 启动返回 errcode 2，未完成安装启动、登录、对战真机验证。

## 限制

这是现有工作区源码的 Android 移植测试包，不表示与线上 4.9.8 全部修复完全一致。
桌面鼠标悬停说明、滚轮、后台恢复与所有战斗触控尚未逐项完成真机验收。
现有服务使用 HTTP，本包仅对该协议做兼容，尚未迁移 HTTPS。
使用 AIR 免费层会保留其品牌启动画面；SDK 许可适用性请按实际用途核对。
未发布到应用商店，也未覆盖云端 main.swf/sanguo_web.swf 或重启服务。
Android 发布与现有桌面线上发布分开，避免以较旧工作区覆盖线上修复。

