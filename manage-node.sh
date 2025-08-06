#!/bin/bash

# 以太坊节点管理脚本
set -e

NODE_NAME="ethereum-geth-node"
API_GATEWAY_NAME="ethereum-api-gateway"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# 检查 Docker 是否运行
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker 未运行，请先启动 Docker"
        exit 1
    fi
}

# 启动节点
start_node() {
    print_status "启动以太坊节点..."
    check_docker
    
    mkdir -p data logs
    chmod 755 data logs
    
    docker-compose pull
    docker-compose up -d
    
    print_status "等待节点启动..."
    sleep 15
    
    if check_node_status; then
        print_status "节点启动成功！"
        show_endpoints
    else
        print_error "节点启动失败"
        show_logs
    fi
}

# 停止节点
stop_node() {
    print_status "停止以太坊节点..."
    docker-compose down
    print_status "节点已停止"
}

# 重启节点
restart_node() {
    print_status "重启以太坊节点..."
    stop_node
    sleep 5
    start_node
}

# 检查节点状态
check_node_status() {
    if curl -s http://localhost:8545 -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 显示节点状态
show_status() {
    print_info "检查节点状态..."
    
    if check_node_status; then
        print_status "✅ 节点正在运行"
        
        # 获取当前区块号
        BLOCK_NUMBER=$(curl -s http://localhost:8545 -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
        if [ ! -z "$BLOCK_NUMBER" ]; then
            DECIMAL_BLOCK=$(printf "%d" $BLOCK_NUMBER)
            print_info "📦 当前区块号: $DECIMAL_BLOCK"
        fi
        
        # 检查同步状态
        SYNC_STATUS=$(curl -s http://localhost:8545 -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')
        if echo "$SYNC_STATUS" | grep -q '"result":false'; then
            print_status "✅ 节点已同步完成"
        else
            print_warning "⏳ 节点正在同步中..."
        fi
        
        show_endpoints
    else
        print_error "❌ 节点未运行"
    fi
}

# 显示端点信息
show_endpoints() {
    echo ""
    print_info "📡 可用端点:"
    echo "   HTTP RPC:     http://localhost:8545"
    echo "   WebSocket:    ws://localhost:8546"
    echo "   API Gateway:  http://localhost:8080"
    echo ""
}

# 显示日志
show_logs() {
    print_info "显示节点日志..."
    docker-compose logs --tail=50 ethereum-node
}

# 显示容器状态
show_containers() {
    print_info "容器状态:"
    docker-compose ps
}

# 清理数据
clean_data() {
    print_warning "⚠️  这将删除所有节点数据，确定要继续吗？(y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "清理节点数据..."
        docker-compose down
        rm -rf data logs
        print_status "数据已清理"
    else
        print_info "操作已取消"
    fi
}

# 显示帮助信息
show_help() {
    echo "以太坊节点管理脚本"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  start     启动节点"
    echo "  stop      停止节点"
    echo "  restart   重启节点"
    echo "  status    显示节点状态"
    echo "  logs      显示节点日志"
    echo "  containers 显示容器状态"
    echo "  clean     清理节点数据"
    echo "  help      显示此帮助信息"
    echo ""
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
        containers)
            show_containers
            ;;
        clean)
            clean_data
            ;;
        help|*)
            show_help
            ;;
    esac
}

# 运行主函数
main "$@" 