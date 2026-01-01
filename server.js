const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');
const https = require('https');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 443;

// API 类型配置：gemini, openai 或 claude
const API_TYPE = process.env.API_TYPE || 'gemini';

// API 配置映射
const API_CONFIGS = {
  gemini: {
    targetUrl: 'https://generativelanguage.googleapis.com',
    serviceName: 'Google Gemini API Proxy',
    // Gemini API 需要的请求头
    allowedHeaders: ['x-goog-api-key', 'content-type'],
    headerFilter: (headers) => {
      const filtered = {};
      if (headers['x-goog-api-key']) {
        filtered['x-goog-api-key'] = headers['x-goog-api-key'];
      }
      if (headers['content-type']) {
        filtered['content-type'] = headers['content-type'];
      }
      return filtered;
    }
  },
  openai: {
    targetUrl: 'https://api.openai.com',
    serviceName: 'OpenAI API Proxy',
    // OpenAI API 需要的请求头
    allowedHeaders: ['authorization', 'openai-organization', 'openai-project', 'content-type'],
    headerFilter: (headers) => {
      const filtered = {};
      if (headers['authorization']) {
        filtered['authorization'] = headers['authorization'];
      }
      if (headers['openai-organization']) {
        filtered['openai-organization'] = headers['openai-organization'];
      }
      if (headers['openai-project']) {
        filtered['openai-project'] = headers['openai-project'];
      }
      if (headers['content-type']) {
        filtered['content-type'] = headers['content-type'];
      }
      return filtered;
    }
  },
  claude: {
    targetUrl: 'https://api.anthropic.com',
    serviceName: 'Anthropic Claude API Proxy',
    // Claude API 需要的请求头
    allowedHeaders: ['x-api-key', 'anthropic-version', 'content-type'],
    headerFilter: (headers) => {
      const filtered = {};
      if (headers['x-api-key']) {
        filtered['x-api-key'] = headers['x-api-key'];
      }
      if (headers['anthropic-version']) {
        filtered['anthropic-version'] = headers['anthropic-version'];
      }
      if (headers['content-type']) {
        filtered['content-type'] = headers['content-type'];
      }
      return filtered;
    }
  }
};

// 获取当前 API 配置
const currentConfig = API_CONFIGS[API_TYPE];
if (!currentConfig) {
  console.error(`❌ 不支持的 API 类型: ${API_TYPE}`);
  console.error(`   支持的类型: ${Object.keys(API_CONFIGS).join(', ')}`);
  process.exit(1);
}

const TARGET_URL = currentConfig.targetUrl;
const SERVICE_NAME = currentConfig.serviceName;

// CORS 配置
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: '*'
}));

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: SERVICE_NAME,
    apiType: API_TYPE,
    targetUrl: TARGET_URL,
    timestamp: new Date().toISOString()
  });
});

// 代理中间件
app.use('/', async (req, res) => {
  try {
    const requestId = Math.random().toString(36).substring(7);
    console.log(`[${requestId}] ${req.method} ${req.path}`);
    
    // 构建目标 URL
    const targetUrl = `${TARGET_URL}${req.url}`;
    console.log(`[${requestId}] 目标: ${targetUrl}`);
    
    // 根据 API 类型过滤请求头
    const headers = currentConfig.headerFilter(req.headers);
    
    // 记录关键认证信息（不记录完整内容）
    if (API_TYPE === 'gemini' && headers['x-goog-api-key']) {
      console.log(`[${requestId}] Gemini API Key: 存在`);
    }
    if (API_TYPE === 'openai' && headers['authorization']) {
      console.log(`[${requestId}] OpenAI Authorization: 存在`);
    }
    if (API_TYPE === 'claude' && headers['x-api-key']) {
      console.log(`[${requestId}] Claude API Key: 存在`);
    }
    
    // 发起请求（直接传递 req 作为 body，支持流式）
    const response = await fetch(targetUrl, {
      method: req.method,
      headers: headers,
      body: req.method !== 'GET' && req.method !== 'HEAD' ? req : undefined
    });
    
    console.log(`[${requestId}] 响应: ${response.status}`);
    
    // 设置响应状态
    res.status(response.status);
    
    // 复制必要的响应头
    response.headers.forEach((value, key) => {
      res.setHeader(key, value);
    });
    
    // 设置 CORS 响应头
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', '*');
    res.setHeader('Access-Control-Allow-Headers', '*');
    
    // 流式返回响应体
    response.body.pipe(res);
    
  } catch (error) {
    console.error(`错误: ${error.message}`);
    res.status(500).json({
      error: '代理请求失败',
      message: error.message
    });
  }
});

// HTTPS 配置
const httpsOptions = {
  key: fs.readFileSync(path.join(__dirname, 'certs/key.pem')),
  cert: fs.readFileSync(path.join(__dirname, 'certs/cert.pem'))
};

// 启动 HTTPS 服务器
https.createServer(httpsOptions, app).listen(PORT, '0.0.0.0', () => {
  console.log('================================');
  console.log(`🔒 ${SERVICE_NAME} 已启动 (HTTPS)`);
  console.log(`📍 监听端口: ${PORT}`);
  console.log(`🎯 API 类型: ${API_TYPE}`);
  console.log(`🌐 目标 API: ${TARGET_URL}`);
  console.log('================================');
});

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('收到 SIGTERM 信号，正在关闭服务器...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('收到 SIGINT 信号，正在关闭服务器...');
  process.exit(0);
});
