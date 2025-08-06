const Web3 = require('web3');

// 连接到本地以太坊节点
const web3 = new Web3('http://localhost:8545');

async function testNode() {
    try {
        console.log('🔍 测试以太坊节点连接...\n');

        // 1. 检查连接
        const isListening = await web3.eth.net.isListening();
        console.log('✅ 节点连接状态:', isListening ? '已连接' : '未连接');

        // 2. 获取网络 ID
        const networkId = await web3.eth.net.getId();
        console.log('🌐 网络 ID:', networkId);

        // 3. 获取当前区块号
        const blockNumber = await web3.eth.getBlockNumber();
        console.log('📦 当前区块号:', blockNumber);

        // 4. 检查同步状态
        const syncing = await web3.eth.isSyncing();
        if (syncing) {
            console.log('⏳ 同步状态: 正在同步');
            console.log('   当前区块:', syncing.currentBlock);
            console.log('   最高区块:', syncing.highestBlock);
            console.log('   已知区块:', syncing.knownStates);
            console.log('   拉取状态:', syncing.pulledStates);
        } else {
            console.log('✅ 同步状态: 已同步完成');
        }

        // 5. 获取节点信息
        const nodeInfo = await web3.eth.getNodeInfo();
        console.log('🔧 节点信息:', nodeInfo);

        // 6. 获取对等节点数量
        const peerCount = await web3.eth.net.getPeerCount();
        console.log('👥 对等节点数量:', peerCount);

        console.log('\n🎉 节点测试完成！');
        console.log('\n📡 可用端点:');
        console.log('   HTTP RPC: http://localhost:8545');
        console.log('   WebSocket: ws://localhost:8546');
        console.log('   API Gateway: http://localhost:8080');

    } catch (error) {
        console.error('❌ 测试失败:', error.message);
    }
}

// 运行测试
testNode(); 