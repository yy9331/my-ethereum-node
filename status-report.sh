#!/bin/bash

# 轻量级以太坊节点状态报告脚本

set -e

SCRIPT_DIR="/home/code/ethereum-node"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose-light.yml"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# 检查容器状态
check_containers() {
    log "=== 容器状态 ==="
    
    local containers=("ethereum-geth-light-node" "ethereum-beacon-light-client" "ethereum-api-gateway")
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "^${container}$"; then
            local status
            status=$(docker ps --format "table {{.Names}}\t{{.Status}}" | grep "^${container}" | awk '{print $2}')
            log "✓ $container: $status"
        else
            error "✗ $container: 未运行"
        fi
    done
}

# 检查RPC端点
check_rpc_endpoints() {
    log "=== RPC端点状态 ==="
    
    # 检查HTTP RPC
    local http_response
    http_response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
        http://localhost:8545 2>/dev/null || echo "")
    
    if [ -n "$http_response" ]; then
        local block_number
        block_number=$(echo "$http_response" | grep -o '"result":"0x[^"]*"' | cut -d'"' -f4 | sed 's/0x//' | tr '[:lower:]' '[:upper:]')
        if [ -n "$block_number" ] && [ "$block_number" != "0" ]; then
            log "✓ HTTP RPC (8545): 区块高度 $block_number"
        else
            warn "⚠ HTTP RPC (8545): 区块高度 0 (可能正在同步)"
        fi
    else
        error "✗ HTTP RPC (8545): 连接失败"
    fi
    
    # 检查WebSocket RPC
    if curl -s http://localhost:8546 >/dev/null 2>&1; then
        log "✓ WebSocket RPC (8546): 可访问"
    else
        warn "⚠ WebSocket RPC (8546): 可能不可用"
    fi
    
    # 检查API网关
    if curl -s http://localhost:8080 >/dev/null 2>&1; then
        log "✓ API网关 (8080): 可访问"
    else
        warn "⚠ API网关 (8080): 可能不可用"
    fi
}

# 检查同步状态
check_sync_status() {
    log "=== 同步状态 ==="
    
    local sync_response
    sync_response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
        http://localhost:8545 2>/dev/null || echo "")
    
    if [ -n "$sync_response" ]; then
        local is_syncing
        is_syncing=$(echo "$sync_response" | grep -o '"result":[^,]*' | cut -d':' -f2 | tr -d ' ')
        
        if [ "$is_syncing" = "false" ]; then
            log "✓ 节点已同步完成"
        else
            warn "⚠ 节点正在同步中"
        fi
    else
        error "✗ 无法获取同步状态"
    fi
}

# 检查磁盘使用情况
check_disk_usage() {
    log "=== 磁盘使用情况 ==="
    
    local usage
    usage=$(df "$SCRIPT_DIR" | tail -1 | awk '{print $5}' | sed 's/%//')
    local available
    available=$(df "$SCRIPT_DIR" | tail -1 | awk '{print $4}')
    available=$((available / 1024 / 1024))  # 转换为GB
    
    log "磁盘使用率: ${usage}%"
    log "可用空间: ${available}GB"
    
    if [ "$usage" -gt 80 ]; then
        warn "⚠ 磁盘使用率过高，建议清理"
        suggest_cleanup
    elif [ "$usage" -gt 60 ]; then
        warn "⚠ 磁盘使用率较高，注意监控"
    else
        log "✓ 磁盘使用率正常"
    fi
}

# 清理建议
suggest_cleanup() {
    log "=== 清理建议 ==="
    log "1. 运行数据清理: ./cleanup-old-data.sh"
    log "2. 清理Docker缓存: docker system prune -f"
    log "3. 清理日志文件: find $SCRIPT_DIR/logs -name '*.log' -mtime +7 -delete"
    log "4. 重启轻量级节点: docker-compose -f docker-compose-light.yml restart"
}

# 检查数据目录大小
check_data_sizes() {
    log "=== 数据目录大小 ==="
    
    if [ -d "$SCRIPT_DIR/data" ]; then
        local eth_size
        eth_size=$(du -sh "$SCRIPT_DIR/data" 2>/dev/null | cut -f1)
        log "以太坊数据: $eth_size"
    fi
    
    if [ -d "$SCRIPT_DIR/beacon-data" ]; then
        local beacon_size
        beacon_size=$(du -sh "$SCRIPT_DIR/beacon-data" 2>/dev/null | cut -f1)
        log "Beacon数据: $beacon_size"
    fi
}

# 检查定时任务
check_cron_jobs() {
    log "=== 定时任务 ==="
    
    if crontab -l 2>/dev/null | grep -q "cleanup-old-data.sh"; then
        log "✓ 数据清理定时任务已设置"
    else
        warn "⚠ 数据清理定时任务未设置"
    fi
}

# 显示管理命令
show_management_commands() {
    log "=== 管理命令 ==="
    echo "查看日志: docker-compose -f $COMPOSE_FILE logs -f"
    echo "停止节点: docker-compose -f $COMPOSE_FILE down"
    echo "重启节点: docker-compose -f $COMPOSE_FILE restart"
    echo "手动清理: $SCRIPT_DIR/cleanup-old-data.sh"
    echo "磁盘监控: $SCRIPT_DIR/monitor-disk-usage.sh"
    echo "设置定时任务: $SCRIPT_DIR/setup-cron.sh"
}

# 显示配置信息
show_config_info() {
    log "=== 配置信息 ==="
    echo "数据保留策略: 最近3个月 (约657,000个区块)"
    echo "历史记录限制:"
    echo "  - 区块历史: postmerge (合并后)"
    echo "  - 日志索引: 657,000个区块"
    echo "  - 交易索引: 657,000个区块"
    echo "  - 状态历史: 90,000个区块"
    echo "预计存储空间: 8-10GB"
    echo "自动清理: 每天凌晨2点"
}

# 主函数
main() {
    echo ""
    log "轻量级以太坊节点状态报告"
    echo "=================================="
    
    check_containers
    echo ""
    
    check_rpc_endpoints
    echo ""
    
    check_sync_status
    echo ""
    
    check_disk_usage
    echo ""
    
    check_data_sizes
    echo ""
    
    check_cron_jobs
    echo ""
    
    show_config_info
    echo ""
    
    show_management_commands
    echo ""
    
    log "状态报告完成"
}

# 执行主函数
main "$@" 