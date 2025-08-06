# Ethereum RPC Node Deployment

A complete Ethereum RPC node deployment solution using Docker and Geth client.

<div align="right">

English | [简体中文](README.md)

</div>

## 🚀 Quick Start

### 1. Start the Node

```bash
# Give execute permissions to scripts
chmod +x start-node.sh manage-node.sh

# Start the node
./start-node.sh
```

### 2. Use Management Script

```bash
# View help
./manage-node.sh help

# Start node
./manage-node.sh start

# Check status
./manage-node.sh status

# View logs
./manage-node.sh logs

# Stop node
./manage-node.sh stop

# Restart node
./manage-node.sh restart
```

## 📡 Available Endpoints

After successful startup, you can use the following endpoints:

- **HTTP RPC**: `http://localhost:8545`
- **WebSocket RPC**: `ws://localhost:8546`
- **API Gateway**: `http://localhost:8080`

## 🔧 Configuration Details

### Docker Compose Configuration

The node uses the following configuration:

- **Sync Mode**: `snap` (fast sync)
- **Cache Size**: 4GB
- **Max Connections**: 50
- **HTTP API**: `eth,net,web3,personal,debug`
- **WebSocket API**: `eth,net,web3`

### Port Mapping

- `8545`: HTTP RPC
- `8546`: WebSocket RPC
- `30303`: P2P Communication
- `8080`: API Gateway

## 📊 Monitoring and Logs

### Check Node Status

```bash
# Check if node is running
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545
```

### Check Sync Status

```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545
```

### View Logs

```bash
# View logs in real-time
docker-compose logs -f ethereum-node

# View last 100 lines of logs
docker-compose logs --tail=100 ethereum-node
```

## 🔗 Integration with Your Project

### Update Your Monitor Program Configuration

In your `uniswap-monitor-scheduler` project, update the RPC endpoint to:

```javascript
// Configuration example
const config = {
  rpcUrl: 'http://localhost:8545',
  wsUrl: 'ws://localhost:8546',
  // Other configurations...
};
```

### Subgraph Configuration

In your `uniswap-v2-monitor-subgraph`, update `subgraph.yaml`:

```yaml
networks:
  mainnet:
    address: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
    startBlock: 10000835
    # Use local node
    rpcUrl: "http://localhost:8545"
```

## 🛠️ Troubleshooting

### Common Issues

1. **Node Startup Failure**
   ```bash
   # Check if Docker is running
   docker info
   
   # Check if ports are occupied
   netstat -tulpn | grep :8545
   ```

2. **Slow Sync Speed**
   - Ensure sufficient disk space (at least 500GB)
   - Check network connection
   - Consider using SSD storage

3. **Insufficient Memory**
   - Adjust `--cache` parameter
   - Increase system memory

### Performance Optimization

1. **Use SSD Storage**
2. **Increase System Memory**
3. **Optimize Network Connection**
4. **Adjust Cache Size**

## 📁 Directory Structure

```
ethereum-node/
├── docker-compose.yml    # Docker configuration
├── nginx.conf           # Nginx configuration
├── start-node.sh        # Startup script
├── manage-node.sh       # Management script
├── README.md           # Documentation
├── data/               # Node data (auto-created)
└── logs/               # Log files (auto-created)
```

## 🔒 Security Recommendations

1. **Firewall Configuration**
   ```bash
   # Allow only local access
   ufw allow from 127.0.0.1 to any port 8545
   ufw allow from 127.0.0.1 to any port 8546
   ```

2. **Regular Backups**
   ```bash
   # Backup data directory
   tar -czf ethereum-backup-$(date +%Y%m%d).tar.gz data/
   ```

3. **Monitor Resource Usage**
   ```bash
   # Monitor disk usage
   df -h data/
   
   # Monitor memory usage
   docker stats ethereum-geth-node
   ```

## 📈 Extension Features

### Add Monitoring

You can integrate Prometheus and Grafana to monitor node performance:

```yaml
# Add to docker-compose.yml
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
```

### Load Balancing

For high-traffic applications, you can deploy multiple nodes and use a load balancer.

## 🤝 Support

If you encounter issues, please check:

1. Whether Docker is running normally
2. Whether ports are occupied
3. Whether disk space is sufficient
4. Whether network connection is normal

View detailed logs:
```bash
./manage-node.sh logs
``` 