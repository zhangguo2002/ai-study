---
name: deploy-go
description: Go 后端服务本地构建、打包与服务器 Docker Compose 部署。当用户提到"部署"、"构建"、"build"Go 项目时使用。
---

# Go 项目构建与部署技能

> 适用场景：Go 后端服务的本地构建、打包、服务器部署。覆盖部署前审计、build.ps1 脚本生成、构建后验证、部署指令四个阶段。

---

## 一、触发条件

当用户说"部署"、"重新部署"、"构建并部署"时，**严格按顺序**执行：

1. **部署前审计**（第二章） — 分析项目结构、现有部署、配置、数据
2. 定位项目根目录（含 `go.mod` + `cmd/`）
3. 检查 `build.ps1` 是否存在，不存在则按第三章规范生成
4. 运行 `build.ps1`
5. **构建后验证**（第六章） — 逐项检查 build/ 产物
6. 告知用户上传内容和部署命令

---

## 二、部署前审计（BLOCKING）

> 跳过审计直接构建是违规行为。每次部署前必须完成以下检查清单。

### 2.1 现有部署拓扑

- 检查项目中是否存在**多套部署方案**（如 `deploy/`、`docker-compose.prod.yml`、根目录 `docker-compose.yml`）
- 确认当前生产环境使用的是哪一套方案（容器名、端口、网络）
- 若方案不一致，部署命令须包含 `--remove-orphans` 清除旧容器

### 2.2 端口冲突

- 读取 `docker-compose.yml` 中的端口映射
- 与服务器当前已知的端口分配交叉验证（若用户提供过服务器信息）
- 确认默认端口值与生产环境实际使用一致

### 2.3 配置文件实际内容

- 读取 build.ps1 将要复制的生产配置文件（如 `config.docker.yaml` / `config.prod.yaml`）
- **验证关键字段不是注释/模板/占位符**：数据库连接、API keys、主机列表等
- 若发现模板状态，搜索项目中其他配置文件（`deploy/`、环境变量等）寻找真实值并合并

### 2.4 数据文件

- 检查项目是否使用嵌入式数据库（SQLite、BoltDB 等）或其他本地数据文件
- 若存在 `data/` 目录或 `.db` 文件，确认 build.ps1 是否将其纳入打包
- 检查 `docker-compose.yml` 中的卷挂载方式：
  - **命名卷**（`volume-name:/path`）：首次部署时卷为空，数据文件不会自动出现
  - **绑定挂载**（`./data:/path`）：数据文件随 build/ 一起上传
  - 含嵌入式数据库的项目**应使用绑定挂载**

---

## 三、build.ps1 脚本规范

### 3.1 脚本位置

`{project-root}/build.ps1`

### 3.2 脚本模板

```powershell
$ErrorActionPreference = "Stop"

Write-Host ">>> 交叉编译 linux/amd64 ..." -ForegroundColor Cyan
$env:CGO_ENABLED = "0"
$env:GOOS = "linux"
$env:GOARCH = "amd64"
go build -trimpath -ldflags="-s -w" -o {binary-name} ./cmd/main.go
if ($LASTEXITCODE -ne 0) { throw "编译失败" }

Write-Host ">>> 打包 build/ 目录 ..." -ForegroundColor Cyan
if (Test-Path build) { Remove-Item -Recurse -Force build }
New-Item -ItemType Directory -Force build/config | Out-Null

Move-Item {binary-name} build/
Copy-Item docker-compose.yaml build/
Copy-Item config/config.prod.yaml build/config/

# 生成精简 Dockerfile（从预编译产物构建，无需多阶段）
@"
FROM alpine:latest
WORKDIR /app
RUN apk --no-cache add ca-certificates tzdata curl
ENV TZ=Asia/Shanghai
COPY {binary-name} .
RUN chmod +x ./{binary-name}
COPY config/ ./config/
RUN mkdir -p /app/data
EXPOSE {port}
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:{port}/health || exit 1
CMD ["./{binary-name}", "-config", "config/config.yaml"]
"@ | Set-Content -Path build/Dockerfile -Encoding UTF8

Remove-Item Env:GOOS
Remove-Item Env:GOARCH

Write-Host ">>> 构建完成！build/ 目录内容：" -ForegroundColor Green
Get-ChildItem build -Recurse | ForEach-Object {
    $rel = $_.FullName.Substring((Resolve-Path build).Path.Length)
    Write-Host "  $rel"
}
Write-Host ""
Write-Host "请将 build/ 文件夹上传到服务器，然后执行：" -ForegroundColor Yellow
Write-Host "  docker compose down --remove-orphans && docker compose up -d --build" -ForegroundColor Yellow
```

### 3.3 占位符替换规则

| 占位符 | 取值 | 示例 |
|--------|------|------|
| `{binary-name}` | `go.mod` 中的 module 名（最后一段） | `tweet-preprocess` |
| `{port}` | 应用监听端口（读取 config 或代码） | `8080` |
| `config/config.prod.yaml` | 项目实际的生产配置路径 | 若配置在 `internal/config/` 则调整 |

### 3.4 模板强制规则

- **Dockerfile 必须包含 `RUN chmod +x`**：Windows 交叉编译产物无 Linux 可执行权限位
- **部署指令必须包含 `--remove-orphans`**：防止旧容器残留占用端口
- **Dockerfile 由脚本内联生成**：不依赖项目中已有的多阶段 Dockerfile，确保与预编译产物匹配

### 3.5 特殊情况处理

- **有前端资源**（`web/`）：在编译前增加 `npm install` + `npm run build`，打包 `web/dist/` 到 `build/static/`，Dockerfile 追加 `COPY static/ ./static/`
- **有数据文件**（`data/*.db` 等）：打包到 `build/data/`，`docker-compose.yml` 使用绑定挂载 `./data:/app/data`
- **多二进制项目**：为每个 `cmd/xxx/main.go` 生成独立编译行

---

## 四、build/ 目录结构

```
build/
├── {binary-name}           # Linux amd64 静态二进制
├── Dockerfile              # 精简单阶段（预编译产物，含 chmod +x）
├── docker-compose.yaml     # 编排文件（绑定挂载，非命名卷）
├── config/
│   └── config.yaml         # 生产配置（真实值，非模板）
├── data/                   # [可选] 嵌入式数据库文件
└── static/                 # [可选] 前端静态资源
```

---

## 五、编译参数说明

| 参数 | 作用 |
|------|------|
| `CGO_ENABLED=0` | 纯静态链接，Alpine 容器可直接运行 |
| `GOOS=linux GOARCH=amd64` | 交叉编译目标为 Linux x86_64 |
| `-trimpath` | 去除本地路径信息 |
| `-ldflags="-s -w"` | 去除符号表和调试信息，缩减体积 |

---

## 六、构建后验证（BLOCKING）

> 构建完成后，必须逐项验证 build/ 产物，全部通过才可输出部署指令。

| 检查项 | 验证方法 | 失败处理 |
|--------|---------|---------|
| 二进制存在 | `Test-Path build/{binary-name}` | 检查编译错误 |
| Dockerfile 含 `chmod +x` | `Select-String "chmod"` | 补充赋权行 |
| 配置非模板 | 读取 config 文件，确认关键字段非注释/占位符 | 从其他配置源合并 |
| 端口映射正确 | `Select-String "SIM_PORT\|ports"` | 修正为生产端口 |
| 数据文件已打包（若适用） | `Test-Path build/data/*.db` | 补充 Copy-Item |
| 卷挂载为绑定挂载（若有数据文件） | 配置中无命名卷定义 | 改为 `./data:/app/data` |

---

## 七、部署输出格式

```
✅ 构建完成

📦 上传内容：将 build/ 整个文件夹上传到服务器目标目录

🖥️ 服务器端执行：
  cd /path/to/{project-name}
  docker compose down --remove-orphans
  docker compose up -d --build
  docker compose logs -f          # 确认启动正常
```
