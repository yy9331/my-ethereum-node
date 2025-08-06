#!/bin/bash

# 监控 ethereum-node 和 beacon-client 同步进度的脚本

echo "=== Ethereum Node 同步监控 ==="
echo "时间: $(date)"
echo ""

# 检查 ethereum-node 状态
echo "1. Ethereum Node 状态:"
ETH_BLOCK=$(curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545 | jq -r '.result' 2>/dev/null)

if [ "$ETH_BLOCK" = "0x0" ] || [ -z "$ETH_BLOCK" ]; then
    echo "   ❌ 区块高度: 0 (未同步)"
else
    BLOCK_DEC=$(printf "%d" $ETH_BLOCK)
    echo "   ✅ 区块高度: $BLOCK_DEC"
fi

# 检查 beacon-client 状态
echo ""
echo "2. Beacon Client 状态:"
BEACON_LOGS=$(docker-compose logs --tail=5 beacon-client 2>/dev/null | grep -E "(Syncing|Synced|Finalized)")

if [ -n "$BEACON_LOGS" ]; then
    echo "   📊 最新日志:"
    echo "$BEACON_LOGS" | sed 's/^/   /'
else
    echo "   ❌ 无法获取 beacon-client 日志"
fi

# 检查服务状态
echo ""
echo "3. 服务状态:"
docker-compose ps | grep -E "(ethereum|beacon)"

# 检查磁盘使用情况
echo ""
echo "4. 磁盘使用情况:"
df -h /home/code/ethereum-node/data /home/code/ethereum-node/beacon-data 2>/dev/null | tail -n +2 | while read line; do
    echo "   $line"
done

# 检查内存使用情况
echo ""
echo "5. 内存使用情况:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" | grep -E "(ethereum|beacon)"

echo ""
echo "=== 监控完成 ===" 