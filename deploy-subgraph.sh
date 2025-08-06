#!/bin/bash

# 部署和监控 uniswap-v2-monitor-subgraph 的脚本

SUBGRAPH_DIR="/home/code/uniswap-v2-monitor/uniswap-v2-monitor-subgraph"

echo "=== Uniswap V2 Monitor Subgraph 部署脚本 ==="
echo "时间: $(date)"
echo ""

# 检查 ethereum-node 是否可用
echo "1. 检查 Ethereum Node 连接:"
ETH_BLOCK=$(curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545 | jq -r '.result' 2>/dev/null)

if [ "$ETH_BLOCK" = "0x0" ] || [ -z "$ETH_BLOCK" ]; then
    echo "   ❌ Ethereum Node 未同步，无法部署子图"
    echo "   请等待 ethereum-node 同步完成后再运行此脚本"
    exit 1
else
    BLOCK_DEC=$(printf "%d" $ETH_BLOCK)
    echo "   ✅ Ethereum Node 已同步到区块: $BLOCK_DEC"
fi

# 检查子图服务状态
echo ""
echo "2. 检查子图服务状态:"
cd "$SUBGRAPH_DIR"
if docker-compose ps | grep -q "Up"; then
    echo "   ✅ 子图服务正在运行"
else
    echo "   ❌ 子图服务未运行，正在启动..."
    docker-compose up -d
    sleep 10
fi

# 检查 Graph Node 连接
echo ""
echo "3. 检查 Graph Node 连接:"
GRAPH_HEALTH=$(curl -s http://localhost:8000/graphql -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{ indexingStatusForCurrentVersion(subgraphName: \"uniswap-v2-monitor\") { synced health fatalError { message } chains { chainHeadBlock { number } latestBlock { number } } } }"}' 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "   ✅ Graph Node 可访问"
    echo "   📊 响应: $GRAPH_HEALTH"
else
    echo "   ❌ Graph Node 无法访问"
fi

# 检查数据库状态
echo ""
echo "4. 检查数据库状态:"
DB_BLOCKS=$(docker exec uniswap-v2-monitor-subgraph_postgres_1 psql -U graph-node -d graph-node -c "SELECT COUNT(*) FROM ethereum_blocks;" 2>/dev/null | tail -n 1)

if [ -n "$DB_BLOCKS" ] && [ "$DB_BLOCKS" != "count" ]; then
    echo "   📊 数据库中的区块数: $DB_BLOCKS"
else
    echo "   ❌ 无法获取数据库状态"
fi

# 检查 IPFS 状态
echo ""
echo "5. 检查 IPFS 状态:"
IPFS_PEERS=$(curl -s http://localhost:5001/api/v0/swarm/peers 2>/dev/null | jq '.Strings | length' 2>/dev/null)

if [ -n "$IPFS_PEERS" ] && [ "$IPFS_PEERS" != "null" ]; then
    echo "   ✅ IPFS 连接正常，对等节点数: $IPFS_PEERS"
else
    echo "   ❌ IPFS 连接异常"
fi

echo ""
echo "=== 部署检查完成 ==="
echo ""
echo "下一步操作:"
echo "1. 等待 ethereum-node 完全同步"
echo "2. 部署子图: cd $SUBGRAPH_DIR && npm run deploy"
echo "3. 监控同步进度: ./monitor-sync.sh" 