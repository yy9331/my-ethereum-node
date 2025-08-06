const Web3 = require('web3');

// 连接到本地以太坊节点 / Connect to local Ethereum node
const web3 = new Web3('http://localhost:8545');

async function testNode() {
    try {
        console.log('🔍 测试以太坊节点连接...\n'); // Test Ethereum node connection

        // 1. 检查连接 / Check connection
        const isListening = await web3.eth.net.isListening();
        console.log('✅ 节点连接状态:', isListening ? '已连接' : '未连接'); // Node connection status: Connected/Not connected

        // 2. 获取网络 ID / Get network ID
        const networkId = await web3.eth.net.getId();
        console.log('🌐 网络 ID:', networkId); // Network ID

        // 3. 获取当前区块号 / Get current block number
        const blockNumber = await web3.eth.getBlockNumber();
        console.log('📦 当前区块号:', blockNumber); // Current block number

        // 4. 检查同步状态 / Check sync status
        const syncing = await web3.eth.isSyncing();
        if (syncing) {
            console.log('⏳ 同步状态: 正在同步'); // Sync status: Syncing
            console.log('   当前区块:', syncing.currentBlock); // Current block
            console.log('   最高区块:', syncing.highestBlock); // Highest block
            console.log('   已知区块:', syncing.knownStates); // Known states
            console.log('   拉取状态:', syncing.pulledStates); // Pulled states
        } else {
            console.log('✅ 同步状态: 已同步完成'); // Sync status: Sync completed
        }

        // 5. 获取节点信息 / Get node info
        const nodeInfo = await web3.eth.getNodeInfo();
        console.log('🔧 节点信息:', nodeInfo); // Node info

        // 6. 获取对等节点数量 / Get peer count
        const peerCount = await web3.eth.net.getPeerCount();
        console.log('👥 对等节点数量:', peerCount); // Peer count

        console.log('\n🎉 节点测试完成！'); // Node test completed
        console.log('\n📡 可用端点:'); // Available endpoints
        console.log('   HTTP RPC: http://localhost:8545');
        console.log('   WebSocket: ws://localhost:8546');
        console.log('   API Gateway: http://localhost:8080');

    } catch (error) {
        console.error('❌ 测试失败:', error.message); // Test failed
    }
}

// 运行测试
testNode(); 