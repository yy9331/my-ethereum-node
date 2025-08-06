# 以太坊 RPC 节点部署

这是一个完整的以太坊 RPC 节点部署方案，使用 Docker 和 Geth 客户端。

## 🚀 快速开始

### 1. 启动节点

```bash
# 给脚本执行权限
chmod +x start-node.sh manage-node.sh

# 启动节点
./start-node.sh
```

### 2. 使用管理脚本

```bash
# 查看帮助
./manage-node.sh help

# 启动节点
./manage-node.sh start

# 查看状态
./manage-node.sh status

# 查看日志
./manage-node.sh logs

# 停止节点
./manage-node.sh stop

# 重启节点
./manage-node.sh restart
```

## 📡 可用端点

启动成功后，您可以使用以下端点：

- **HTTP RPC**: `http://localhost:8545`
- **WebSocket RPC**: `ws://localhost:8546`
- **API Gateway**: `http://localhost:8080`

## 🔧 配置说明

### Docker Compose 配置

节点使用以下配置：

- **同步模式**: `snap` (快速同步)
- **缓存大小**: 4GB
- **最大连接数**: 50
- **HTTP API**: `eth,net,web3,personal,debug`
- **WebSocket API**: `eth,net,web3`

### 端口映射

- `8545`: HTTP RPC
- `8546`: WebSocket RPC
- `30303`: P2P 通信
- `8080`: API 网关

## 📊 监控和日志

### 查看节点状态

```bash
# 检查节点是否运行
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545
```

### 查看同步状态

```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545
```

### 查看日志

```bash
# 实时查看日志
docker-compose logs -f ethereum-node

# 查看最近 100 行日志
docker-compose logs --tail=100 ethereum-node
```

## 🔗 集成到您的项目

### 更新您的监控程序配置

在您的 `uniswap-monitor-scheduler` 项目中，将 RPC 端点更新为：

```javascript
// 配置示例
const config = {
  rpcUrl: 'http://localhost:8545',
  wsUrl: 'ws://localhost:8546',
  // 其他配置...
};
```

### 子图配置

在您的 `uniswap-v2-monitor-subgraph` 中，更新 `subgraph.yaml`：

```yaml
networks:
  mainnet:
    address: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
    startBlock: 10000835
    # 使用本地节点
    rpcUrl: "http://localhost:8545"
```

## 🛠️ 故障排除

### 常见问题

1. **节点启动失败**
   ```bash
   # 检查 Docker 是否运行
   docker info
   
   # 检查端口是否被占用
   netstat -tulpn | grep :8545
   ```

2. **同步速度慢**
   - 确保有足够的磁盘空间（至少 500GB）
   - 检查网络连接
   - 考虑使用 SSD 存储

3. **内存不足**
   - 调整 `--cache` 参数
   - 增加系统内存

### 性能优化

1. **使用 SSD 存储**
2. **增加系统内存**
3. **优化网络连接**
4. **调整缓存大小**

## 📁 目录结构

```
ethereum-node/
├── docker-compose.yml    # Docker 配置
├── nginx.conf           # Nginx 配置
├── start-node.sh        # 启动脚本
├── manage-node.sh       # 管理脚本
├── README.md           # 说明文档
├── data/               # 节点数据（自动创建）
└── logs/               # 日志文件（自动创建）
```

## 🔒 安全建议

1. **防火墙配置**
   ```bash
   # 只允许本地访问
   ufw allow from 127.0.0.1 to any port 8545
   ufw allow from 127.0.0.1 to any port 8546
   ```

2. **定期备份**
   ```bash
   # 备份数据目录
   tar -czf ethereum-backup-$(date +%Y%m%d).tar.gz data/
   ```

3. **监控资源使用**
   ```bash
   # 监控磁盘使用
   df -h data/
   
   # 监控内存使用
   docker stats ethereum-geth-node
   ```

## 📈 扩展功能

### 添加监控

可以集成 Prometheus 和 Grafana 来监控节点性能：

```yaml
# 在 docker-compose.yml 中添加
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
```

### 负载均衡

对于高流量应用，可以部署多个节点并使用负载均衡器。

## 🤝 支持

如果遇到问题，请检查：

1. Docker 是否正常运行
2. 端口是否被占用
3. 磁盘空间是否充足
4. 网络连接是否正常

查看详细日志：
```bash
./manage-node.sh logs
``` 