# 更新日志

所有重要的更改都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.1.0] - 2026-01-01

### 安全
- 升级到 HTTPS，使用 Cloudflare Origin Certificate
- Cloudflare SSL/TLS 模式从 Flexible 升级到 Full (Strict)
- API Key 现在全程加密传输，解决了明文传输的安全漏洞

### 变更
- 监听端口从 80 (HTTP) 改为 443 (HTTPS)
- 服务器现在使用 Node.js https 模块启动
- 更新部署脚本支持 HTTPS 和证书检查

### 新增
- 添加 HTTPS-SETUP.md 文档，详细说明 HTTPS 配置步骤
- .gitignore 添加证书文件排除规则

### 架构
```
用户 → HTTPS → Cloudflare CDN → HTTPS (443) → Node.js Express → HTTPS → Google API
```

## [1.0.0] - 2025-12-31

### 新增
- 初始版本发布
- Google Generative Language API 反向代理功能
- 支持流式响应（SSE - Server-Sent Events）
- 自动添加 CORS 跨域支持
- 只保留必要的请求头（x-goog-api-key 和 content-type）
- PM2 进程管理和守护
- 健康检查端点 `/health`
- 详细的请求日志记录
- 支持 Cloudflare CDN 集成
- 自动部署脚本
- 完整的部署文档

### 技术栈
- Node.js 16+
- Express 4.18.2
- node-fetch 2.6.7
- cors 2.8.5
- PM2 进程管理

---

## 未来计划

### [1.1.0] - 计划中
- [ ] 支持多个 API 源切换
- [ ] 添加请求速率限制
- [ ] 增加请求统计和监控
- [ ] 支持自定义请求头白名单
- [ ] 添加请求缓存机制
- [ ] Docker 容器化部署

### [1.2.0] - 计划中
- [ ] 支持 WebSocket 连接
- [ ] 添加用户认证机制
- [ ] API 使用量统计
- [ ] 多节点负载均衡
- [ ] 自动故障转移

---

## 版本说明

### 语义化版本格式：主版本号.次版本号.修订号

- **主版本号**：不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

### 更新日志类型

- **新增** (Added)：新功能
- **变更** (Changed)：现有功能的变更
- **弃用** (Deprecated)：即将移除的功能
- **移除** (Removed)：已移除的功能
- **修复** (Fixed)：Bug 修复
- **安全** (Security)：安全性相关的修复


