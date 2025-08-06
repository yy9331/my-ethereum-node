#!/bin/bash

# 详细的 ethereum-node 和 beacon-client 同步监控脚本

echo "=== 详细同步监控 ==="
echo "时间: $(date)"
echo ""

# 检查 ethereum-node 状态
echo "1. Ethereum Node 状态:"
ETH_BLOCK=$(curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545 | jq -r '.result' 2>/dev/null)

if [ "$ETH_BLOCK" = "0x0" ] || [ -z "$ETH_BLOCK" ]; then
    echo "   ❌ 区块高度: 0 (正在同步)"
else
    BLOCK_DEC=$(printf "%d" $ETH_BLOCK)
    echo "   ✅ 区块高度: $BLOCK_DEC"
fi

# 检查 ethereum-node 同步状态
echo ""
echo "2. Ethereum Node 同步状态:"
ETH_SYNC=$(curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545 2>/dev/null)

if [ -n "$ETH_SYNC" ]; then
    echo "   📊 同步状态: $ETH_SYNC"
else
    echo "   ❌ 无法获取同步状态"
fi

# 检查 beacon-client 状态
echo ""
echo "3. Beacon Client 状态:"
BEACON_LOGS=$(docker-compose logs --tail=10 beacon-client 2>/dev/null | grep -E "(Syncing|Synced|Finalized|Block production|peers)")

if [ -n "$BEACON_LOGS" ]; then
    echo "   📊 最新日志:"
    echo "$BEACON_LOGS" | sed 's/^/   /'
else
    echo "   ❌ 无法获取 beacon-client 日志"
fi

# 检查 ethereum-node 日志
echo ""
echo "4. Ethereum Node 日志:"
ETH_LOGS=$(docker-compose logs --tail=10 ethereum-node 2>/dev/null | grep -E "(Syncing|Synced|Imported|Block|peers)")

if [ -n "$ETH_LOGS" ]; then
    echo "   📊 最新日志:"
    echo "$ETH_LOGS" | sed 's/^/   /'
else
    echo "   ❌ 无法获取 ethereum-node 日志"
fi

# 检查服务状态
echo ""
echo "5. 服务状态:"
docker-compose ps | grep -E "(ethereum|beacon)"

# 检查磁盘使用情况
echo ""
echo "6. 磁盘使用情况:"
echo "   Ethereum Node 数据:"
du -sh data/ 2>/dev/null || echo "   ❌ 无法获取数据目录大小"
echo "   Beacon Client 数据:"
du -sh beacon-data/ 2>/dev/null || echo "   ❌ 无法获取 beacon 数据目录大小"

# 检查内存和 CPU 使用情况
echo ""
echo "7. 资源使用情况:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" | grep -E "(ethereum|beacon)"

echo ""
echo "=== 监控完成 ==="
echo ""
echo "同步进度说明:"
echo "- Beacon Client 需要先同步完成"
echo "- Ethereum Node 需要等待 Beacon Client 提供共识信息"
echo "- 预计总同步时间: 5-6 小时"
echo "- 当前状态: 正在同步 beacon headers" 