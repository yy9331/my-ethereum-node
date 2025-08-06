// 以太坊节点配置示例 / Ethereum Node Configuration Examples
// 用于更新您的 uniswap-monitor-scheduler 和 uniswap-v2-monitor-subgraph / For updating your uniswap-monitor-scheduler and uniswap-v2-monitor-subgraph

// ============================================================================
// 1. 监控程序配置 (uniswap-monitor-scheduler) / Monitor Program Configuration
// ============================================================================

const monitorConfig = {
  // 使用本地以太坊节点 / Use local Ethereum node
  rpcUrl: 'http://localhost:8545',
  wsUrl: 'ws://localhost:8546',
  
  // 备用节点（可选） / Fallback nodes (optional)
  fallbackRpcUrls: [
    'https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY',
    'https://mainnet.infura.io/v3/YOUR_PROJECT_ID'
  ],
  
  // 监控配置 / Monitoring configuration
  monitoring: {
    blockInterval: 1000, // 区块间隔检查（毫秒） / Block interval check (milliseconds)
    maxRetries: 3,       // 最大重试次数 / Maximum retry attempts
    timeout: 30000,      // 请求超时时间 / Request timeout
  },
  
  // 数据库配置 / Database configuration
  database: {
    host: 'localhost',
    port: 5432,
    database: 'uniswap_monitor',
    username: 'your_username',
    password: 'your_password'
  },
  
  // 通知配置 / Notification configuration
  notifications: {
    telegram: {
      botToken: 'YOUR_BOT_TOKEN',
      chatId: 'YOUR_CHAT_ID'
    },
    email: {
      smtp: 'smtp.gmail.com',
      port: 587,
      username: 'your_email@gmail.com',
      password: 'your_app_password'
    }
  }
};

// ============================================================================
// 2. 子图配置 (uniswap-v2-monitor-subgraph) / Subgraph Configuration
// ============================================================================

const subgraphConfig = {
  // subgraph.yaml 配置示例 / subgraph.yaml configuration example
  networks: {
    mainnet: {
      address: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", // Uniswap V2 Router
      startBlock: 10000835,
      rpcUrl: "http://localhost:8545" // 使用本地节点 / Use local node
    }
  },
  
  // 数据源配置 / Data source configuration
  dataSources: [
    {
      kind: "ethereum/contract",
      name: "UniswapV2Factory",
      network: "mainnet",
      source: {
        address: "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f",
        abi: "UniswapV2Factory"
      },
      mapping: {
        kind: "ethereum/events",
        apiVersion: "0.0.6",
        language: "wasm/assemblyscript",
        entities: ["Factory", "Pair"],
        abis: [
          {
            name: "UniswapV2Factory",
            data: "..." // ABI 数据
          }
        ],
        eventHandlers: [
          {
            event: "PairCreated(indexed address,indexed address,address,uint256)",
            handler: "handlePairCreated"
          }
        ],
        file: "./src/mapping.ts"
      }
    }
  ]
};

// ============================================================================
// 3. 环境变量配置 / Environment Variable Configuration
// ============================================================================

const envConfig = {
  // .env 文件示例 / .env file example
  environment: {
    // 以太坊节点配置 / Ethereum node configuration
    ETHEREUM_RPC_URL: 'http://localhost:8545',
    ETHEREUM_WS_URL: 'ws://localhost:8546',
    ETHEREUM_NETWORK_ID: '1',
    
    // 监控配置 / Monitoring configuration
    MONITOR_INTERVAL: '1000',
    MONITOR_MAX_RETRIES: '3',
    MONITOR_TIMEOUT: '30000',
    
    // 数据库配置 / Database configuration
    DB_HOST: 'localhost',
    DB_PORT: '5432',
    DB_NAME: 'uniswap_monitor',
    DB_USER: 'your_username',
    DB_PASSWORD: 'your_password',
    
    // 通知配置 / Notification configuration
    TELEGRAM_BOT_TOKEN: 'YOUR_BOT_TOKEN',
    TELEGRAM_CHAT_ID: 'YOUR_CHAT_ID',
    
    // 子图配置 / Subgraph configuration
    SUBGRAPH_RPC_URL: 'http://localhost:8545',
    SUBGRAPH_NETWORK: 'mainnet'
  }
};

// ============================================================================
// 4. 更新脚本示例 / Update Script Examples
// ============================================================================

const updateScripts = {
  // 更新监控程序配置 / Update monitor program configuration
  updateMonitorConfig: () => {
    console.log('更新监控程序配置...'); // Updating monitor program configuration
    
    // 1. 备份原配置 / Backup original configuration
    // cp /home/code/uniswap-v2-monitor/uniswap-monitor-scheduler/config.js /home/code/uniswap-v2-monitor/uniswap-monitor-scheduler/config.js.backup
    
    // 2. 更新 RPC URL / Update RPC URL
    const configPath = '/home/code/uniswap-v2-monitor/uniswap-monitor-scheduler/config.js';
    // 将 rpcUrl 更新为 'http://localhost:8545' / Update rpcUrl to 'http://localhost:8545'
    
    console.log('✅ 监控程序配置已更新'); // Monitor program configuration updated
  },
  
  // 更新子图配置 / Update subgraph configuration
  updateSubgraphConfig: () => {
    console.log('更新子图配置...'); // Updating subgraph configuration
    
    // 1. 备份原配置 / Backup original configuration
    // cp /home/code/uniswap-v2-monitor/uniswap-v2-monitor-subgraph/subgraph.yaml /home/code/uniswap-v2-monitor/uniswap-v2-monitor-subgraph/subgraph.yaml.backup
    
    // 2. 更新 RPC URL / Update RPC URL
    const subgraphPath = '/home/code/uniswap-v2-monitor/uniswap-v2-monitor-subgraph/subgraph.yaml';
    // 将 rpcUrl 更新为 'http://localhost:8545' / Update rpcUrl to 'http://localhost:8545'
    
    console.log('✅ 子图配置已更新'); // Subgraph configuration updated
  },
  
  // 重启服务 / Restart services
  restartServices: () => {
    console.log('重启监控服务...'); // Restarting monitor services
    
    // 1. 重启监控程序 / Restart monitor program
    // cd /home/code/uniswap-v2-monitor/uniswap-monitor-scheduler && npm restart
    
    // 2. 重新部署子图 / Redeploy subgraph
    // cd /home/code/uniswap-v2-monitor/uniswap-v2-monitor-subgraph && npm run deploy
    
    console.log('✅ 服务已重启'); // Services restarted
  }
};

// ============================================================================
// 5. 测试连接 / Test Connection
// ============================================================================

const testConnection = async () => {
  const Web3 = require('web3');
  const web3 = new Web3('http://localhost:8545');
  
  try {
    const blockNumber = await web3.eth.getBlockNumber();
    const isSyncing = await web3.eth.isSyncing();
    
    console.log('🔍 连接测试结果:'); // Connection test results
    console.log('   当前区块:', blockNumber); // Current block
    console.log('   同步状态:', isSyncing ? '正在同步' : '已同步'); // Sync status: Syncing/Synced
    console.log('   RPC 端点: http://localhost:8545'); // RPC endpoint
    
    return true;
  } catch (error) {
    console.error('❌ 连接失败:', error.message); // Connection failed
    return false;
  }
};

// 导出配置 / Export configurations
module.exports = {
  monitorConfig,
  subgraphConfig,
  envConfig,
  updateScripts,
  testConnection
};

// 如果直接运行此文件，执行测试 / If this file is run directly, execute test
if (require.main === module) {
  testConnection();
} 