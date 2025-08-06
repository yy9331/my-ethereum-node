# 轻量级以太坊 RPC 节点

这是一个专为演示和轻量级使用设计的以太坊 RPC 节点，只保留最近3个月的区块数据，完美适合50GB服务器。

## 🎯 设计目标

- **存储优化**: 只保留最近3个月的数据，节省存储空间
- **演示友好**: 适合开发和演示用途
- **自动管理**: 每天自动清理旧数据
- **磁盘监控**: 防止磁盘空间不足

## 📊 存储需求

- **预计总存储**: 8-10GB
- **当前使用**: 约1GB
- **磁盘使用率**: 17% (50GB服务器)

## 🚀 快速开始

### 1. 启动轻量级节点

```bash
./start-light-node.sh
```

### 2. 查看状态

```bash
./status-report.sh
```

### 3. 设置定时清理

```bash
./setup-cron.sh
```

## 📡 可用端点

- **HTTP RPC**: `http://localhost:8545`
- **WebSocket RPC**: `ws://localhost:8546`
- **API Gateway**: `http://localhost:8080`

## 🔧 配置说明

### 数据保留策略

- **区块历史**: 只保留合并后的区块 (postmerge)
- **日志索引**: 最近657,000个区块
- **交易索引**: 最近657,000个区块
- **状态历史**: 最近90,000个区块

### 自动清理

- **清理频率**: 每天凌晨2点
- **保留时间**: 3个月
- **清理内容**: 3个月之前的区块数据

## 📋 管理命令

### 统一管理脚本（推荐）
```bash
# 启动节点
./manage.sh start

# 查看状态
./manage.sh status

# 查看日志
./manage.sh logs

# 重启节点
./manage.sh restart

# 停止节点
./manage.sh stop

# 手动清理数据
./manage.sh cleanup

# 设置定时任务
./manage.sh setup

# 查看帮助
./manage.sh help
```

### 直接调用脚本
```bash
# 查看完整状态
./status-report.sh

# 手动清理数据
./cleanup-old-data.sh

# 设置定时任务
./setup-cron.sh

# 查看日志
docker-compose -f docker-compose-light.yml logs -f

# 重启节点
docker-compose -f docker-compose-light.yml restart

# 停止节点
docker-compose -f docker-compose-light.yml down
```

## ⚠️ 重要提醒

1. **数据限制**: 此节点只保留最近3个月的数据，不适合需要完整历史数据的应用
2. **演示用途**: 主要用于开发和演示，不建议用于生产环境
3. **磁盘监控**: 系统会自动监控磁盘使用情况，超过80%会发出警告
4. **自动清理**: 每天凌晨2点自动清理旧数据

## 🔍 故障排除

### 节点未同步
```bash
# 检查容器状态
docker ps

# 查看日志
docker-compose -f docker-compose-light.yml logs ethereum-geth-light-node
```

### 磁盘空间不足
```bash
# 运行状态检查（包含磁盘监控）
./status-report.sh

# 手动清理
./cleanup-old-data.sh

# 清理Docker缓存
docker system prune -f
```

### 定时任务未设置
```bash
# 重新设置定时任务
./setup-cron.sh
```

## 📈 性能优化

- **缓存大小**: 4GB (适合轻量级使用)
- **最大连接数**: 50个对等节点
- **同步模式**: snap (快速同步)
- **垃圾回收**: archive模式 (保留完整状态)

## 🎉 成功部署

您的轻量级以太坊 RPC 节点已经成功部署！

- ✅ 容器运行正常
- ✅ 磁盘使用率: 17% (正常)
- ✅ 定时清理已设置
- ✅ 磁盘监控已启用

现在您可以开始使用这个轻量级的以太坊节点进行开发和演示了！

## 📁 项目结构

```
ethereum-node/
├── manage.sh               # 统一管理脚本（推荐使用）
├── start-light-node.sh     # 启动轻量级节点
├── status-report.sh        # 状态报告和监控
├── cleanup-old-data.sh     # 数据清理脚本
├── setup-cron.sh          # 定时任务设置
├── docker-compose-light.yml # 轻量级配置
├── nginx.conf             # Nginx配置
├── data/                  # 以太坊数据目录
├── beacon-data/           # Beacon客户端数据
└── logs/                  # 日志目录
``` 