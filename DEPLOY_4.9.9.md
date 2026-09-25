# 4.9.9 发布记录

- 目标：`47.114.59.65:3000`，主机 `IZM2IOMVNEXNLDZ`，计划任务 `sgqz-online-4.9.0`。
- 发布前线上版本：4.9.8；发布后 `/api/version`：4.9.9，`/api/health`：ok，任务状态：Running。
- 发布包：客户端 `main.swf`、`sanguo_web.swf`、网页入口及版本文件，服务端 `start_fixed.js`。
- 发布前备份：`C:\sgqz\backup-before-fix-4.9.9`。远端发布包 SHA256：`ecded6db3bde835bc1a5563639239963d061bdb7e0858ea96ecebbfc69412889`。
- 从公网重新下载两个 SWF，SHA256 均为 `2b55ac8dcc80601270f10e3857c8f77a928dc00b9933d4c9e35f27a0d8c7499d`，各 1,116,725 字节，与本地编译产物一致；解压检查均含版本 `4.9.9`。
- Flex 编译成功，仅有既有的 `UI.as` 中 `int` 转 `Boolean` 警告。静态核对六名新模型站立帧透明像素边界与碰撞区、四种战斗场景的移动停止条件；未做原生 Flash 客户端人工战斗操作测试。
