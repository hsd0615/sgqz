# 开发协作指南

## 快速开始

```bash
git clone git@github.com:hsd0615/sgqz.git
cd sgqz
```

## 版本管理

### 分支策略

```
master         ← 稳定发布版（永远可运行）
├── dev         ← 开发分支（日常开发）
├── feature/*   ← 新功能分支（从 dev 拉，合并回 dev）
└── hotfix/*    ← 紧急修复分支（从 master 拉，合并回 master+dev）
```

### 日常流程

```bash
# 1. 从 dev 拉最新代码
git checkout dev
git pull origin dev

# 2. 创建功能分支
git checkout -b feature/my-feature

# 3. 开发、提交
git add <files>
git commit -m "feat: 添加xxx功能"

# 4. 推送并创建 PR
git push origin feature/my-feature
# 在 GitHub 上创建 Pull Request → 合并到 dev

# 5. 发布：dev → master
git checkout master
git merge dev
git tag v2.2.0
git push origin master --tags
```

### 提交规范

```
feat: 新功能
fix:  修复Bug
docs: 文档
refactor: 重构
test: 测试
chore: 构建/工具
```

### 版本号规则

`v主版本.次版本.修订号`

| 位数 | 含义 | 触发条件 |
|------|------|---------|
| 主版本 | 大更新 | 不兼容改动 |
| 次版本 | 功能更新 | 新功能/新数据 |
| 修订号 | 修复 | Bug修复 |

当前版本: **v2.1.0**

```
git tag v2.1.0  ← 创建标签
git push --tags  ← 推送标签
```

## 编译

### 环境要求

- **Windows** + Flex SDK 4.x（放在 `/d/BaiduNetdiskDownload/flex_home/`）
- 或 **macOS/Linux** + Adobe AIR SDK

### 编译命令

```bash
cd sgqz
java -jar /path/to/flex_home/lib/mxmlc.jar \
  +flexlib=/path/to/flex_home/frameworks \
  -compiler.source-path=. \
  -default-size=770,500 \
  -target-player=32.0 \
  -static-link-runtime-shared-libraries=true \
  -external-library-path=air_stubs.swc \
  -- game/Sanguo4399.as

cp game/Sanguo4399.swf main.swf
```

### SWF 文件

- `main.swf` — 编译输出，入口文件
- `*.swf` — 资源文件（ui.swf, general.swf 等），**不编译**
- `game/Sanguo4399.as` — 主入口源码

## 服务端

### 连接

| 项目 | 值 |
|------|-----|
| HTTP API | `47.96.41.243:3000` |
| TCP 大厅 | `47.96.41.243:3001` |
| 管理员密钥 | `sanguoq_admin_2024` |

### 远程管理

```bash
# 查看玩家
curl http://47.96.41.243:3000/api/auth/players

# 重启服务
curl -X POST http://47.96.41.243:3000/api/admin/restart \
  -H "Content-Type: application/json" \
  -d '{"key":"sanguoq_admin_2024"}'

# 执行命令
curl -X POST http://47.96.41.243:3000/api/admin/exec \
  -H "Content-Type: application/json" \
  -d '{"key":"sanguoq_admin_2024","cmd":"ls -la /opt"}'
```

### 文件结构

```
server/
├── start_fixed.js          ← 主服务端（Node.js）
├── start_fixed_http_backup.js
├── admin.js                ← 远程管理模块
├── patch.js                ← 补丁工具
├── src/                    ← TypeScript 源码（参考用）
└── data/                   ← 运行时数据
```

### 重启服务

服务端自带重启端点，**不需要 SSH**：
```bash
curl -X POST http://47.96.41.243:3000/api/admin/restart \
  -H "Content-Type: application/json" \
  -d '{"key":"sanguoq_admin_2024"}'
```

重启自动加载最新代码和数据库。

## 数据文件

| 文件 | 用途 | 修改方式 |
|------|------|---------|
| `recruit_rates.json` | 181武将招募概率 | 编辑 JSON，上传到 `/opt/` |
| `stage_awards.json` | 100关卡奖励 | 编辑 JSON，上传到 `/opt/` |
| `stage_id_map.json` | 关卡ID映射 | 编辑 JSON，上传到 `/opt/` |
| `stage.xml` | 关卡配置 | 客户端编译用 |
| `staticgeneral.xml` | 武将属性 | 客户端编译用 |

### 修改招募概率

1. 编辑 `recruit_rates.json`
2. 上传并重启：
```bash
base64 -w0 recruit_rates.json | curl -X POST http://47.96.41.243:3000/api/admin/exec \
  -H "Content-Type: application/json" \
  -d "{\"key\":\"sanguoq_admin_2024\",\"cmd\":\"base64 -d > /opt/recruit_rates.json\"}"
curl -X POST http://47.96.41.243:3000/api/admin/restart \
  -H "Content-Type: application/json" \
  -d '{"key":"sanguoq_admin_2024"}'
```

## 测试账号

| 账号 | 密码 | 等级 |
|------|------|------|
| test1 | 123 | 100 |
| test2 | 123 | 100 |

## 工具

- `tools/read_image.ps1` — Windows 截图 OCR
- `tools/img2txt.ps1` — 图片转 ASCII
