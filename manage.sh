#!/bin/bash

# 轻量级以太坊节点统一管理脚本

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

# 显示帮助信息
show_help() {
    echo ""
    echo "轻量级以太坊节点管理脚本"
    echo "=========================="
    echo ""
    echo "用法: ./manage.sh [命令]"
    echo ""
    echo "命令:"
    echo "  start     启动轻量级节点"
    echo "  stop      停止节点"
    echo "  restart   重启节点"
    echo "  status    查看完整状态报告"
    echo "  logs      查看日志"
    echo "  cleanup   手动清理旧数据"
    echo "  setup     设置定时任务"
    echo "  help      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ./manage.sh start    # 启动节点"
    echo "  ./manage.sh status   # 查看状态"
    echo "  ./manage.sh logs     # 查看日志"
    echo ""
}

# 启动节点
start_node() {
    log "启动轻量级以太坊节点..."
    "$SCRIPT_DIR/start-light-node.sh"
}

# 停止节点
stop_node() {
    log "停止轻量级以太坊节点..."
    docker-compose -f "$COMPOSE_FILE" down
    log "节点已停止"
}

# 重启节点
restart_node() {
    log "重启轻量级以太坊节点..."
    docker-compose -f "$COMPOSE_FILE" restart
    log "节点已重启"
}

# 查看状态
show_status() {
    log "生成状态报告..."
    "$SCRIPT_DIR/status-report.sh"
}

# 查看日志
show_logs() {
    log "显示节点日志..."
    docker-compose -f "$COMPOSE_FILE" logs -f
}

# 清理数据
cleanup_data() {
    log "手动清理旧数据..."
    "$SCRIPT_DIR/cleanup-old-data.sh"
}

# 设置定时任务
setup_cron() {
    log "设置定时任务..."
    "$SCRIPT_DIR/setup-cron.sh"
}

# 主函数
main() {
    case "${1:-help}" in
        start)
            start_node
            ;;
        stop)
            stop_node
            ;;
        restart)
            restart_node
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        cleanup)
            cleanup_data
            ;;
        setup)
            setup_cron
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 