#!/bin/bash

# 轻量级以太坊节点启动脚本
# 只保留3个月数据

set -e

SCRIPT_DIR="/home/code/ethereum-node"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose-light.yml"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# 检查Docker是否运行
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        error "Docker未运行，请先启动Docker服务"
        exit 1
    fi
}

# 检查磁盘空间
check_disk_space() {
    local required_space=10  # 10GB
    local available_space
    available_space=$(df "$SCRIPT_DIR" | tail -1 | awk '{print $4}')
    available_space=$((available_space / 1024 / 1024))  # 转换为GB
    
    if [ "$available_space" -lt "$required_space" ]; then
        warn "可用磁盘空间不足 ${required_space}GB (当前: ${available_space}GB)"
        warn "建议确保有足够的磁盘空间用于节点数据"
    else
        log "磁盘空间检查通过 (可用: ${available_space}GB)"
    fi
}

# 创建必要的目录
create_directories() {
    log "创建必要的目录..."
    mkdir -p "$SCRIPT_DIR/data"
    mkdir -p "$SCRIPT_DIR/beacon-data"
    mkdir -p "$SCRIPT_DIR/logs"
    chmod 755 "$SCRIPT_DIR/data"
    chmod 755 "$SCRIPT_DIR/beacon-data"
    chmod 755 "$SCRIPT_DIR/logs"
}

# 生成JWT密钥
generate_jwt_secret() {
    if [ ! -f "$SCRIPT_DIR/data/geth/jwtsecret" ]; then
        log "生成JWT密钥..."
        mkdir -p "$SCRIPT_DIR/data/geth"
        openssl rand -hex 32 > "$SCRIPT_DIR/data/geth/jwtsecret"
        chmod 600 "$SCRIPT_DIR/data/geth/jwtsecret"
    fi
}

# 启动节点
start_node() {
    log "启动轻量级以太坊节点..."
    
    # 停止可能存在的旧容器
    docker-compose -f "$COMPOSE_FILE" down 2>/dev/null || true
    
    # 启动新容器
    docker-compose -f "$COMPOSE_FILE" up -d
    
    log "节点启动中，请等待同步完成..."
    log "可以使用以下命令查看状态："
    log "  docker-compose -f $COMPOSE_FILE logs -f"
    log "  curl -X POST -H 'Content-Type: application/json' -d '{\"jsonrpc\":\"2.0\",\"method\":\"eth_blockNumber\",\"params\":[],\"id\":1}' http://localhost:8545"
}

# 设置定时任务
setup_cron() {
    log "设置定时清理任务..."
    chmod +x "$SCRIPT_DIR/setup-cron.sh"
    "$SCRIPT_DIR/setup-cron.sh"
}

# 显示状态信息
show_status() {
    echo ""
    log "=== 轻量级以太坊节点状态 ==="
    log "节点容器: ethereum-geth-light-node"
    log "Beacon客户端: ethereum-beacon-light-client"
    log "HTTP RPC: http://localhost:8545"
    log "WebSocket RPC: ws://localhost:8546"
    log "API网关: http://localhost:8080"
    log "数据目录: $SCRIPT_DIR/data"
    log "日志目录: $SCRIPT_DIR/logs"
    echo ""
    log "=== 管理命令 ==="
    log "查看日志: docker-compose -f $COMPOSE_FILE logs -f"
    log "停止节点: docker-compose -f $COMPOSE_FILE down"
    log "重启节点: docker-compose -f $COMPOSE_FILE restart"
    log "手动清理: $SCRIPT_DIR/cleanup-old-data.sh"
    echo ""
    log "=== 数据保留策略 ==="
    log "保留最近3个月的区块数据"
    log "每天凌晨2点自动清理旧数据"
    log "预计存储空间: 8-10GB"
}

# 主函数
main() {
    log "开始启动轻量级以太坊节点..."
    
    # 检查环境
    check_docker
    check_disk_space
    
    # 准备环境
    create_directories
    generate_jwt_secret
    
    # 启动节点
    start_node
    
    # 设置定时任务
    setup_cron
    
    # 显示状态
    show_status
    
    log "轻量级以太坊节点启动完成！"
}

# 执行主函数
main "$@" 