#!/bin/bash

# 自动更新监控程序配置脚本
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 监控程序目录
MONITOR_DIR="/home/code/uniswap-v2-monitor/uniswap-monitor-scheduler"
SUBGRAPH_DIR="/home/code/uniswap-v2-monitor/uniswap-v2-monitor-subgraph"

# 备份原配置
backup_configs() {
    print_info "备份原配置文件..."
    
    if [ -f "$MONITOR_DIR/config.js" ]; then
        cp "$MONITOR_DIR/config.js" "$MONITOR_DIR/config.js.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "监控程序配置已备份"
    fi
    
    if [ -f "$SUBGRAPH_DIR/subgraph.yaml" ]; then
        cp "$SUBGRAPH_DIR/subgraph.yaml" "$SUBGRAPH_DIR/subgraph.yaml.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "子图配置已备份"
    fi
}

# 更新监控程序配置
update_monitor_config() {
    print_info "更新监控程序配置..."
    
    if [ ! -d "$MONITOR_DIR" ]; then
        print_error "监控程序目录不存在: $MONITOR_DIR"
        return 1
    fi
    
    # 查找配置文件
    CONFIG_FILES=("$MONITOR_DIR/config.js" "$MONITOR_DIR/config.json" "$MONITOR_DIR/.env")
    
    for config_file in "${CONFIG_FILES[@]}"; do
        if [ -f "$config_file" ]; then
            print_info "找到配置文件: $config_file"
            
            # 备份原文件
            cp "$config_file" "$config_file.backup.$(date +%Y%m%d_%H%M%S)"
            
            # 更新 RPC URL
            if [[ "$config_file" == *.js ]]; then
                # JavaScript 配置文件
                sed -i 's|https://eth-mainnet\.g\.alchemy\.com/v2/[^"]*|http://localhost:8545|g' "$config_file"
                sed -i 's|https://mainnet\.infura\.io/v3/[^"]*|http://localhost:8545|g' "$config_file"
                sed -i 's|https://api\.mainnet-beta\.solana\.com|http://localhost:8545|g' "$config_file"
                
                # 更新 WebSocket URL
                sed -i 's|wss://eth-mainnet\.g\.alchemy\.com/v2/[^"]*|ws://localhost:8546|g' "$config_file"
                sed -i 's|wss://mainnet\.infura\.io/ws/v3/[^"]*|ws://localhost:8546|g' "$config_file"
                
            elif [[ "$config_file" == *.json ]]; then
                # JSON 配置文件
                sed -i 's|"rpcUrl":\s*"[^"]*"|"rpcUrl": "http://localhost:8545"|g' "$config_file"
                sed -i 's|"wsUrl":\s*"[^"]*"|"wsUrl": "ws://localhost:8546"|g' "$config_file"
                
            elif [[ "$config_file" == *.env ]]; then
                # 环境变量文件
                sed -i 's|^ETHEREUM_RPC_URL=.*|ETHEREUM_RPC_URL=http://localhost:8545|g' "$config_file"
                sed -i 's|^ETHEREUM_WS_URL=.*|ETHEREUM_WS_URL=ws://localhost:8546|g' "$config_file"
                sed -i 's|^RPC_URL=.*|RPC_URL=http://localhost:8545|g' "$config_file"
                sed -i 's|^WS_URL=.*|WS_URL=ws://localhost:8546|g' "$config_file"
            fi
            
            print_status "配置文件已更新: $config_file"
        fi
    done
}

# 更新子图配置
update_subgraph_config() {
    print_info "更新子图配置..."
    
    if [ ! -d "$SUBGRAPH_DIR" ]; then
        print_error "子图目录不存在: $SUBGRAPH_DIR"
        return 1
    fi
    
    if [ -f "$SUBGRAPH_DIR/subgraph.yaml" ]; then
        print_info "找到子图配置文件: $SUBGRAPH_DIR/subgraph.yaml"
        
        # 备份原文件
        cp "$SUBGRAPH_DIR/subgraph.yaml" "$SUBGRAPH_DIR/subgraph.yaml.backup.$(date +%Y%m%d_%H%M%S)"
        
        # 更新 RPC URL
        sed -i 's|rpcUrl:\s*"[^"]*"|rpcUrl: "http://localhost:8545"|g' "$SUBGRAPH_DIR/subgraph.yaml"
        
        print_status "子图配置文件已更新"
    fi
}

# 测试连接
test_connection() {
    print_info "测试本地节点连接..."
    
    if curl -s http://localhost:8545 -X POST -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' > /dev/null 2>&1; then
        print_status "✅ 本地节点连接正常"
        return 0
    else
        print_error "❌ 本地节点连接失败"
        return 1
    fi
}

# 重启服务
restart_services() {
    print_info "重启监控服务..."
    
    # 重启监控程序
    if [ -d "$MONITOR_DIR" ]; then
        print_info "重启监控程序..."
        cd "$MONITOR_DIR"
        
        # 检查是否有 package.json
        if [ -f "package.json" ]; then
            # 停止现有进程
            pkill -f "node.*monitor" || true
            
            # 启动服务
            npm start &
            print_status "监控程序已重启"
        fi
    fi
    
    # 重新部署子图
    if [ -d "$SUBGRAPH_DIR" ]; then
        print_info "重新部署子图..."
        cd "$SUBGRAPH_DIR"
        
        # 检查是否有部署脚本
        if [ -f "package.json" ]; then
            npm run deploy || print_warning "子图部署失败，请手动检查"
        fi
    fi
}

# 显示帮助信息
show_help() {
    echo "以太坊节点配置更新脚本"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  backup     备份原配置"
    echo "  update     更新所有配置"
    echo "  monitor    仅更新监控程序配置"
    echo "  subgraph   仅更新子图配置"
    echo "  test       测试本地节点连接"
    echo "  restart    重启监控服务"
    echo "  help       显示此帮助信息"
    echo ""
}

# 主函数
main() {
    case "${1:-help}" in
        backup)
            backup_configs
            ;;
        update)
            print_info "开始更新所有配置..."
            backup_configs
            update_monitor_config
            update_subgraph_config
            test_connection
            print_status "所有配置已更新完成！"
            ;;
        monitor)
            update_monitor_config
            ;;
        subgraph)
            update_subgraph_config
            ;;
        test)
            test_connection
            ;;
        restart)
            restart_services
            ;;
        help|*)
            show_help
            ;;
    esac
}

# 运行主函数
main "$@" 