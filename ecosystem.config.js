// PM2 配置文件
module.exports = {
  apps: [{
    name: 'ai-api-proxy',  // 通用名称，支持多种 AI API
    script: './server.js',
    instances: 1,  // 使用单实例（443端口不支持多实例直接绑定）
    exec_mode: 'fork',  // fork 模式
    watch: false,  // 不监听文件变化
    max_memory_restart: '500M',  // 内存超过 500M 自动重启
    env: {
      NODE_ENV: 'production',
      PORT: 443,  // HTTPS 端口
      API_TYPE: 'openai'  // API 类型: gemini, openai 或 claude
    },
    error_file: './logs/error.log',
    out_file: './logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,  // 自动重启
    max_restarts: 10,  // 最多重启 10 次
    restart_delay: 4000  // 重启延迟 4 秒
  }]
};
