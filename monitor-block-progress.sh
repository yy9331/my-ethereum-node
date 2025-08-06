#!/bin/bash
# 监控区块同步进度，特别是与目标区块的对比
echo "=== 区块同步进度监控 ==="
echo "时间: $(date)"
echo ""

# 获取当前区块
SYNC_STATUS=$(curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545)

CURRENT_BLOCK=$(echo "$SYNC_STATUS" | grep -o '"currentBlock":"[^"]*"' | cut -d'"' -f4)

if [ -z "$CURRENT_BLOCK" ] || [ "$CURRENT_BLOCK" = "0x0" ]; then
    echo "❌ 无法获取当前区块高度"
    exit 1
fi

# 转换为十进制
CURRENT_DEC=$(printf "%d" $CURRENT_BLOCK)
TARGET_BLOCK=10000835

echo "📊 区块同步状态:"
echo "   当前区块: $CURRENT_DEC"
echo "   目标区块: $TARGET_BLOCK (Uniswap V2 Factory)"
echo ""

# 计算进度
if [ $CURRENT_DEC -ge $TARGET_BLOCK ]; then
    echo "✅ 已达到目标区块！可以部署子图"
    PROGRESS=100
else
    PROGRESS=$((CURRENT_DEC * 100 / TARGET_BLOCK))
    REMAINING=$((TARGET_BLOCK - CURRENT_DEC))
    echo "⏳ 同步进度: $PROGRESS%"
    echo "   还需同步: $REMAINING 个区块"
fi

echo ""
echo "📈 详细进度:"
echo "   链同步: $((CURRENT_DEC * 100 / 16000000))% (当前/总区块)"
echo "   目标进度: $PROGRESS% (当前/目标区块)"

echo ""
echo "⏰ 预计时间:"
if [ $CURRENT_DEC -lt $TARGET_BLOCK ]; then
    # 基于当前同步速度估算
    BLOCKS_PER_HOUR=1000000  # 估算值
    HOURS_NEEDED=$((REMAINING / BLOCKS_PER_HOUR))
    echo "   预计还需: $HOURS_NEEDED 小时"
fi

echo ""
echo "=== 监控完成 ===" 