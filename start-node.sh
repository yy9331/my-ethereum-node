#!/bin/bash

# 以太坊节点启动脚本
set -e

echo "🚀 启动以太坊 RPC 节点..."

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker"
    exit 1
fi

# 创建必要的目录
mkdir -p data logs

# 设置目录权限
chmod 755 data logs

# 启动节点
echo "📦 拉取最新镜像..."
docker-compose pull

echo "🔧 启动服务..."
docker-compose up -d

# 等待节点启动
echo "⏳ 等待节点启动..."
sleep 10

# 检查节点状态
echo "🔍 检查节点状态..."
if curl -s http://localhost:8545 -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' > /dev/null 2>&1; then
    echo "✅ 以太坊节点启动成功！"
    echo "📡 RPC 端点: http://localhost:8545"
    echo "🔌 WebSocket 端点: ws://localhost:8546"
    echo "🌐 API 网关: http://localhost:8080"
    echo ""
    echo "📊 查看日志: docker-compose logs -f ethereum-node"
    echo "🛑 停止节点: docker-compose down"
else
    echo "❌ 节点启动失败，请检查日志"
    docker-compose logs ethereum-node
fi 