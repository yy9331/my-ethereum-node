#!/bin/bash

# 以太坊节点数据清理脚本
# 清理3个月之前的区块数据

set -e

# 配置
NODE_CONTAINER="ethereum-geth-light-node"
DATA_DIR="/home/code/ethereum-node/data"
LOG_FILE="/home/code/ethereum-node/logs/cleanup.log"
DAYS_TO_KEEP=90  # 保留90天（3个月）

# 创建日志目录
mkdir -p "$(dirname "$LOG_FILE")"

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# 检查容器是否运行
check_container() {
    if ! docker ps --format "table {{.Names}}" | grep -q "^${NODE_CONTAINER}$"; then
        log "错误: 容器 ${NODE_CONTAINER} 未运行"
        exit 1
    fi
}

# 获取当前区块高度
get_current_block() {
    local response
    response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
        http://localhost:8545 2>/dev/null || echo "")
    
    if [ -n "$response" ]; then
        echo "$response" | grep -o '"result":"0x[^"]*"' | cut -d'"' -f4 | sed 's/0x//' | tr '[:lower:]' '[:upper:]'
    else
        echo "0"
    fi
}

# 计算要删除的区块范围
calculate_cleanup_range() {
    local current_block=$1
    local blocks_per_day=7200  # 大约每天7200个区块
    local days_to_keep=$2
    local blocks_to_keep=$((days_to_keep * blocks_per_day))
    
    if [ "$current_block" -gt "$blocks_to_keep" ]; then
        local cutoff_block=$((current_block - blocks_to_keep))
        echo "$cutoff_block"
    else
        echo "0"
    fi
}

# 执行数据清理
cleanup_old_data() {
    local cutoff_block=$1
    
    if [ "$cutoff_block" -gt 0 ]; then
        log "开始清理区块高度 ${cutoff_block} 之前的数据..."
        
        # 使用 geth 的 prune-history 命令清理旧数据
        docker exec "$NODE_CONTAINER" geth --datadir /root/.ethereum \
            prune-history \
            --prune.until "$cutoff_block" \
            --verbosity 3
        
        log "数据清理完成"
    else
        log "当前数据量不足3个月，无需清理"
    fi
}

# 检查磁盘使用情况
check_disk_usage() {
    local usage
    usage=$(df "$DATA_DIR" | tail -1 | awk '{print $5}' | sed 's/%//')
    log "当前磁盘使用率: ${usage}%"
    
    if [ "$usage" -gt 80 ]; then
        log "警告: 磁盘使用率超过80%，建议增加清理频率"
    fi
}

# 主函数
main() {
    log "开始执行数据清理任务"
    
    # 检查容器状态
    check_container
    
    # 获取当前区块高度
    current_block=$(get_current_block)
    if [ "$current_block" = "0" ]; then
        log "无法获取当前区块高度，跳过清理"
        exit 0
    fi
    
    log "当前区块高度: $current_block"
    
    # 计算清理范围
    cutoff_block=$(calculate_cleanup_range "$current_block" "$DAYS_TO_KEEP")
    log "将清理区块高度 ${cutoff_block} 之前的数据"
    
    # 执行清理
    cleanup_old_data "$cutoff_block"
    
    # 检查磁盘使用情况
    check_disk_usage
    
    log "数据清理任务完成"
}

# 执行主函数
main "$@" 