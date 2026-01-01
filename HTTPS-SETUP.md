# HTTPS 配置指南

本文档介绍如何将代理服务从 HTTP 升级到 HTTPS，解决 Cloudflare Flexible 模式下 API Key 明文传输的安全漏洞。

## 安全问题背景

### Flexible 模式的风险

```
用户 --HTTPS--> Cloudflare --HTTP(明文)--> 服务器(80端口)
                           ^
                           |
                    API Key 在此暴露于公网
```

Cloudflare Flexible 模式下，CF 到源服务器之间使用 HTTP 明文传输，API Key 可能被公网截获。

### Full (Strict) 模式

```
用户 --HTTPS--> Cloudflare --HTTPS(加密)--> 服务器(443端口)
                                ^
                                |
                          API Key 全程加密
```

升级到 Full (Strict) 模式后，全链路 HTTPS 加密，API Key 安全传输。

---

## 方案选择

| 方案 | 优点 | 缺点 |
|------|------|------|
| **Cloudflare Origin Certificate** | 免费、15年有效、配置简单 | 只能用于 Cloudflare 代理流量 |
| **Let's Encrypt** | 通用证书、任何场景可用 | 需要定期续期(90天)、配置稍复杂 |

**推荐使用 Cloudflare Origin Certificate**，因为服务已通过 Cloudflare 代理。

---

## 操作步骤

### 步骤 1：在 Cloudflare 生成 Origin Certificate

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com)
2. 选择你的域名 -> **SSL/TLS** -> **Origin Server**
3. 点击 **Create Certificate**
4. 配置选项：
   - Private key type: `RSA (2048)`
   - Hostnames: 保持默认（你的域名）
   - Certificate Validity: `15 years`
5. 点击 **Create**
6. **重要**：复制并保存两个内容：
   - **Origin Certificate** (以 `-----BEGIN CERTIFICATE-----` 开头)
   - **Private Key** (以 `-----BEGIN PRIVATE KEY-----` 开头)

> 私钥只会显示一次，务必妥善保存！

### 步骤 2：在服务器上保存证书

```bash
# 在项目目录中创建证书目录
mkdir -p certs

# 创建证书文件
cat > certs/cert.pem << 'EOF'
-----BEGIN CERTIFICATE-----
(粘贴你的证书内容)
-----END CERTIFICATE-----
EOF

# 创建私钥文件
cat > certs/key.pem << 'EOF'
-----BEGIN PRIVATE KEY-----
(粘贴你的私钥内容)
-----END PRIVATE KEY-----
EOF

# 设置安全权限
chmod 600 certs/key.pem
chmod 644 certs/cert.pem
```

### 步骤 3：修改 server.js

在文件顶部添加依赖：

```javascript
const https = require('https');
const fs = require('fs');
const path = require('path');
```

修改默认端口：

```javascript
const PORT = process.env.PORT || 443;
```

将启动代码从 HTTP 改为 HTTPS：

```javascript
// HTTPS 配置
const httpsOptions = {
  key: fs.readFileSync(path.join(__dirname, 'certs/key.pem')),
  cert: fs.readFileSync(path.join(__dirname, 'certs/cert.pem'))
};

// 启动 HTTPS 服务器
https.createServer(httpsOptions, app).listen(PORT, '0.0.0.0', () => {
  console.log('================================');
  console.log('Google API 代理服务已启动 (HTTPS)');
  console.log(`监听端口: ${PORT}`);
  console.log(`目标 API: ${TARGET_URL}`);
  console.log('================================');
});
```

### 步骤 4：修改 ecosystem.config.js

```javascript
env: {
  NODE_ENV: 'production',
  PORT: 443  // 从 80 改为 443
}
```

### 步骤 5：配置防火墙

```bash
# firewalld
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# 验证
sudo firewall-cmd --list-all
```

同时在云服务商控制台（如腾讯云安全组）开放 443 端口。

### 步骤 6：重启服务

```bash
cd ai-api-gateway  # 进入你的项目目录

# 必须先删除再启动，确保环境变量更新
pm2 delete ai-api-proxy
pm2 start ecosystem.config.js

# 保存配置
pm2 save
```

> **注意**：使用 `pm2 restart` 不会更新环境变量，必须 `delete` 后重新 `start`。

### 步骤 7：验证服务

```bash
# 检查端口监听
ss -tlnp | grep :443

# 本地测试（-k 忽略证书验证，因为 Origin Certificate 只被 CF 信任）
curl -k https://localhost/health

# 查看日志确认端口
pm2 logs ai-api-proxy --lines 5
# 应显示：监听端口: 443
```

### 步骤 8：修改 Cloudflare SSL 设置

1. Cloudflare Dashboard -> **SSL/TLS** -> **Overview**
2. 将模式从 **Flexible** 改为 **Full (Strict)**
3. 等待 1-2 分钟生效

### 步骤 9：最终验证

```bash
# 通过域名测试
curl https://your-domain.com/health

# API 测试
curl -X POST https://your-domain.com/v1beta/models/gemini-2.0-flash-exp:generateContent \
  -H "Content-Type: application/json" \
  -H "x-goog-api-key: YOUR_KEY" \
  -d '{"contents":[{"parts":[{"text":"test"}]}]}'
```

---

## Full vs Full (Strict) 的区别

| 模式 | 证书验证 | 安全性 |
|------|---------|--------|
| **Full** | 不验证证书（自签名、过期都可以） | 中等 |
| **Full (Strict)** | 验证证书必须有效（CA签发或Origin Certificate） | 最高 |

使用 Cloudflare Origin Certificate 时，**推荐选择 Full (Strict)**，可完全杜绝中间人攻击。

---

## 检查清单

### 证书配置
- [ ] Cloudflare Origin Certificate 已创建
- [ ] 证书保存到 `certs/cert.pem`（项目目录下）
- [ ] 私钥保存到 `certs/key.pem`（项目目录下）
- [ ] 私钥权限设置为 600

### 代码修改
- [ ] `server.js` 添加了 https/fs/path 依赖
- [ ] `server.js` 使用 https.createServer 启动
- [ ] `ecosystem.config.js` 端口改为 443

### 网络配置
- [ ] 服务器防火墙开放 443 端口
- [ ] 云服务商安全组开放 443 端口

### 服务部署
- [ ] PM2 服务已重启（delete + start）
- [ ] 日志显示监听端口 443
- [ ] `ss -tlnp | grep :443` 显示服务正在监听

### Cloudflare 配置
- [ ] SSL/TLS 模式改为 Full (Strict)
- [ ] 域名 HTTPS 访问正常

---

## 常见问题

### Q: PM2 重启后端口仍然是 80？

PM2 缓存了旧的环境变量。必须先删除再启动：

```bash
pm2 delete ai-api-proxy
pm2 start ecosystem.config.js
```

### Q: curl 本地测试报证书错误？

这是正常的。Origin Certificate 只被 Cloudflare 信任，本地测试需要加 `-k` 参数：

```bash
curl -k https://localhost/health
```

### Q: Cloudflare 报 525 SSL handshake failed？

检查：
1. 证书文件路径是否正确
2. 证书文件内容是否完整（包含 BEGIN/END 行）
3. 服务是否正常启动在 443 端口

```bash
pm2 logs ai-api-proxy --err --lines 20
```

### Q: 服务启动报 EACCES 权限错误？

443 端口需要 root 权限。确保 PM2 以 root 运行，或者使用 `authbind` / `setcap`。

---

## 回滚方案

如需回滚到 HTTP 模式：

1. Cloudflare SSL/TLS 改回 **Flexible**
2. 恢复 `server.js` 和 `ecosystem.config.js` 的旧版本
3. 重启服务

```bash
pm2 delete ai-api-proxy
pm2 start ecosystem.config.js
```
