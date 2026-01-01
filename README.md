# AI API Gateway

简体中文 | [English](./README-en.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D16.0.0-brightgreen)](https://nodejs.org/)
[![HTTPS](https://img.shields.io/badge/HTTPS-Full%20(Strict)-green)](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/)

一个安全、高性能的 AI API 反向代理网关，支持 Google Gemini、OpenAI、Anthropic Claude 等主流 AI API，提供全链路 HTTPS 加密。

**通过本项目你可以实现：**
- 🌍 **突破地域限制** - 在受限地区正常访问 OpenAI、Claude 等 AI 服务
- 🔒 **保护 API 密钥** - 通过 HTTPS 全链路加密，避免密钥在传输中泄露
- ⚡ **加速访问体验** - 利用 Cloudflare 全球 CDN，显著提升 API 响应速度
- 🎯 **统一接入管理** - 一个域名代理多个 AI 服务，简化应用集成
- 💰 **节省成本** - 无需购买昂贵的代理服务，自建更经济

<div align="center">
  <img src="./images/proxy_pic.jpg" alt="AI API Gateway 架构流程图" width="800">
  <p><i>请求流转流程效果</i></p>
</div>

## ⚠️ 免责声明与使用须知

**本项目的设计初衷：**
- 本项目旨在帮助用户绕开 AI API 提供商的地域限制
- 解决因地域原因被拒绝服务的地区无法使用主流 AI 模型 API 的困扰
- 为合法用户提供技术解决方案，促进 AI 技术的全球可访问性

**重要警告：**
- ⚠️ **请勿将本项目用于任何违法犯罪活动**
- ⚠️ 使用者应遵守所在地区的法律法规和 AI API 服务商的使用条款
- ⚠️ 本项目开发者不对使用者的任何违法行为承担责任
- ⚠️ 使用本项目即表示您同意合法合规使用，并自行承担所有使用风险

**建议用途：**
- 学习研究 AI 技术
- 合法的商业应用开发
- 个人学习和技术探索

---

## ✨ 特性

- 🤖 **多 AI API 支持** - 支持 Google Gemini、OpenAI、Anthropic Claude 等主流 AI API
- 🔒 **端到端 HTTPS 加密** - 使用 Cloudflare Origin Certificate，API Key 全程加密传输
- 🚀 **流式响应支持** - 完美支持 SSE (Server-Sent Events) 流式生成
- 🌐 **CORS 跨域** - 自动处理 CORS，支持所有来源
- 🛡️ **安全请求头过滤** - 只转发必要的请求头，保护隐私
- ⚡ **高可用性** - PM2 进程守护，自动重启
- 🌍 **全球加速** - 集成 Cloudflare CDN
- 🎯 **一键部署** - 交互式部署脚本，选择 API 类型即可
- 📝 **详细日志** - 完整的请求日志记录

## 🤖 支持的 AI API

| AI 服务 | API 类型 | 目标地址 | 认证方式 |
|---------|---------|---------|---------|
| **Google Gemini** | `gemini` | `https://generativelanguage.googleapis.com` | `x-goog-api-key` |
| **OpenAI** | `openai` | `https://api.openai.com` | `Authorization: Bearer TOKEN` |
| **Anthropic Claude** | `claude` | `https://api.anthropic.com` | `x-api-key` + `anthropic-version` |

> 💡 部署时可通过交互式脚本选择要代理的 API 类型，也可以手动配置切换。

## 🏗️ 架构

### 🔐 架构说明

```
┌─────────┐  HTTPS   ┌──────────┐  HTTPS   ┌─────────┐  HTTPS   ┌──────────────┐
│  用户   │ ───────> │ Cloudflare│ ───────> │  服务器  │ ───────> │   AI API     │
│ 浏览器  │          │    CDN    │          │ Node.js │          │ Gemini/GPT   │
└─────────┘          └──────────┘          └─────────┘          │  /Claude     │
             SSL/TLS           Origin                            └──────────────┘
            Full (Strict)    Certificate
```

**安全保证**：API Key 在整个传输链路中都经过 TLS 加密，杜绝明文泄露风险。

---

## 📋 前置准备

在部署本项目之前，你需要完成以下前置准备工作。这些步骤是确保服务正常运行的基础。

### 1. 环境要求

#### 服务器/系统要求
- **操作系统**：
  - **Linux 服务器**：CentOS 7+ / Ubuntu 18.04+ / Debian 10+
  - **macOS 开发环境**：macOS 10.14+ (Mojave 或更高版本)
- **CPU**：1核或以上
- **内存**：512MB 或以上（生产环境建议 1GB+）
- **存储空间**：1GB 可用空间
- **网络**：可访问公网，能够连接目标 AI API

#### 软件要求
- **Node.js**：16.x 或更高版本
- **PM2**：最新版本
- **Git**（可选）：用于克隆项目
- **Homebrew**（macOS）：用于安装 Node.js（脚本会自动安装）

> 💡 **提示**：
> - Linux 服务器：适合生产环境部署，需要使用 root 或 sudo 权限
> - macOS 环境：适合本地开发和测试，部分功能需要 sudo 权限（如监听 443 端口）

### 2. 域名准备

你需要拥有一个域名才能使用本服务。

#### 选项 A：使用已有域名
如果你已经有域名，可以直接使用。

#### 选项 B：购买新域名
推荐的域名注册商：
- [Cloudflare Registrar](https://www.cloudflare.com/products/registrar/)（成本价，无额外费用）
- [NameSilo](https://www.namesilo.com/)
- [Namecheap](https://www.namecheap.com/)
- [GoDaddy](https://www.godaddy.com/)
- [阿里云（万网）](https://wanwang.aliyun.com/)

> **提示**：`.com`、`.net`、`.org` 等常见后缀的域名每年费用约为 $10-15。

### 3. Cloudflare 配置

本项目使用 Cloudflare 提供 CDN 加速和 SSL 证书服务。以下是完整的配置步骤。

#### 3.1 注册 Cloudflare 账号

1. 访问 [Cloudflare 官网](https://www.cloudflare.com/)
2. 点击右上角 **Sign Up** 注册账号
3. 验证邮箱地址

#### 3.2 添加域名到 Cloudflare

1. 登录 Cloudflare Dashboard
2. 点击 **Add a Site**
3. 输入你的域名（例如：`example.com`）
4. 选择 **Free** 计划（免费版即可）
5. Cloudflare 会自动扫描现有的 DNS 记录

#### 3.3 修改域名 DNS 服务器

Cloudflare 会提供两个 nameserver 地址，类似：

```
nameserver1.cloudflare.com
nameserver2.cloudflare.com
```

**操作步骤**：

1. 登录你的域名注册商控制台
2. 找到 DNS 设置或 Nameserver 设置
3. 将原有的 nameserver 替换为 Cloudflare 提供的 nameserver
4. 保存设置

> **注意**：DNS 更改可能需要 1-48 小时生效，通常在几小时内完成。

#### 3.4 配置 DNS 解析

回到 Cloudflare Dashboard，在 **DNS** 选项卡中添加 A 记录：

| 类型 | 名称 | IPv4 地址 | 代理状态 | TTL |
|------|------|-----------|---------|-----|
| A | @ | 你的服务器IP | 已代理（橙云☁️） | 自动 |

**说明**：
- **名称 `@`**：表示主域名（例如 `example.com`）
- **如果要使用子域名**：可以填写 `api`（表示 `api.example.com`）
- **代理状态必须启用**：确保显示为橙色云朵图标，这样才能使用 Cloudflare 的 CDN 和 SSL 功能

#### 3.5 生成 SSL 证书

本项目使用 Cloudflare Origin Certificate（免费、15年有效）。

**操作步骤**：

1. 在 Cloudflare Dashboard 中，选择你的域名
2. 进入 **SSL/TLS** → **Origin Server**
3. 点击 **Create Certificate** 按钮
4. 配置证书：
   - **Private key type**: 选择 `RSA (2048)`
   - **Hostnames**: 保持默认（会自动包含你的域名和 `*.yourdomain.com`）
   - **Certificate Validity**: 选择 `15 years`
5. 点击 **Create** 按钮
6. **重要**：立即复制并保存以下两个内容：

**Origin Certificate**（以下内容需要保存为 `cert.pem`）：
```
-----BEGIN CERTIFICATE-----
MIIEpDCCA4ygAwIBAgIUXXXXXXXXXXXXXXXXXXXXXXXXXXX...
（一长串内容）
...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-----END CERTIFICATE-----
```

**Private Key**（以下内容需要保存为 `key.pem`）：
```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASC...
（一长串内容）
...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-----END PRIVATE KEY-----
```

> **重要提示**：私钥只会显示这一次，务必妥善保存！如果丢失，需要重新生成证书。

#### 3.6 配置 SSL/TLS 模式

1. 在 Cloudflare Dashboard 中，进入 **SSL/TLS** → **Overview**
2. 将加密模式设置为 **Full (Strict)**
3. 确认设置已保存

**SSL/TLS 模式说明**：

| 模式 | 用户到CF | CF到源服务器 | 安全性 |
|------|---------|------------|--------|
| Off | HTTP | HTTP | ❌ 不安全 |
| Flexible | HTTPS | **HTTP（明文）** | ⚠️ 不安全 |
| Full | HTTPS | HTTPS（不验证） | ⚠️ 较安全 |
| **Full (Strict)** | **HTTPS** | **HTTPS（验证证书）** | ✅ **最安全** |

> **必须选择 Full (Strict)**：这样才能确保 API Key 在整个传输链路中都被加密。

### 4. 服务器准备

#### 4.1 准备证书文件

在你的本地电脑上，创建以下两个文件：

**cert.pem**：
```bash
cat > cert.pem << 'EOF'
-----BEGIN CERTIFICATE-----
（粘贴你刚才从 Cloudflare 复制的 Origin Certificate）
-----END CERTIFICATE-----
EOF
```

**key.pem**：
```bash
cat > key.pem << 'EOF'
-----BEGIN PRIVATE KEY-----
（粘贴你刚才从 Cloudflare 复制的 Private Key）
-----END PRIVATE KEY-----
EOF
```

#### 4.2 配置服务器防火墙和安全组

确保服务器的 443 端口（HTTPS）对外开放。

**CentOS/RHEL (firewalld)**：
```bash
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

**Ubuntu/Debian (ufw)**：
```bash
sudo ufw allow 443/tcp
sudo ufw reload
```

**macOS**：
```bash
# macOS 通常在开发环境使用，防火墙配置可选
# 如果启用了防火墙，需要：
# 系统偏好设置 → 安全性与隐私 → 防火墙 → 防火墙选项
# 允许 Node 应用接入网络
```

**云服务商安全组**（腾讯云/阿里云/AWS等）：

在云服务商控制台的安全组设置中，添加入站规则：
- **协议**：TCP
- **端口范围**：443
- **来源**：0.0.0.0/0（允许所有来源）

---

## 🚀 一键部署

完成前置准备后，现在可以开始部署项目了！

### 方式 1：使用 Git 克隆（推荐）

```bash
# 1. 克隆项目到服务器
git clone https://github.com/HgLiJiahao/ai-api-gateway.git
cd ai-api-gateway

# 2. 上传证书文件
# 将你之前准备的 cert.pem 和 key.pem 上传到 certs/ 目录
mkdir -p certs
# 使用 scp 或 SFTP 上传文件，或者手动创建：
# vi certs/cert.pem  （粘贴证书内容）
# vi certs/key.pem   （粘贴私钥内容）

# 3. 设置证书权限
chmod 600 certs/key.pem
chmod 644 certs/cert.pem

# 4. 执行一键部署脚本
chmod +x deploy.sh
sudo ./deploy.sh  # Linux 服务器使用 sudo
# macOS 用户可以直接运行: ./deploy.sh
```

> **macOS 用户提示**：
> - macOS 环境通常用于本地开发测试
> - 监听 443 端口需要 sudo 权限：`sudo pm2 start ecosystem.config.js`
> - 可以修改 `ecosystem.config.js` 中的端口为 8443 等非特权端口
> - 部署脚本会自动检测并安装 Homebrew（如未安装）

### 方式 2：手动上传文件

如果服务器无法访问 GitHub，可以手动上传文件：

```bash
# 1. 在服务器上创建项目目录（选择你喜欢的位置）
mkdir -p ai-api-gateway
cd ai-api-gateway

# 2. 上传以下文件到服务器（使用 scp、SFTP 或其他方式）：
#    - server.js
#    - package.json
#    - ecosystem.config.js
#    - deploy.sh

# 3. 创建 certs 目录并上传证书
mkdir -p certs
# 上传 cert.pem 和 key.pem 到 certs/ 目录

# 4. 设置证书权限
chmod 600 certs/key.pem
chmod 644 certs/cert.pem

# 5. 执行一键部署脚本
chmod +x deploy.sh
sudo ./deploy.sh
```

### deploy.sh 脚本会自动完成以下操作：

1. ✅ 检测并安装 Node.js（如未安装）
2. ✅ 检测并安装 PM2（如未安装）
3. ✅ 安装项目依赖（npm install）
4. ✅ 创建日志目录
5. ✅ 配置防火墙（开放 443 端口）
6. ✅ 启动服务（pm2 start）
7. ✅ 保存 PM2 配置（pm2 save）
8. ✅ 设置开机自启（pm2 startup）
9. ✅ 验证服务状态

### 验证部署

部署完成后，脚本会自动执行验证。你也可以手动验证：

```bash
# 1. 检查 PM2 服务状态
pm2 list

# 2. 查看服务日志
pm2 logs ai-api-proxy --lines 20

# 3. 本地健康检查（-k 参数忽略证书验证）
curl -k https://localhost/health

# 4. 通过域名访问（等待 1-2 分钟让 Cloudflare 生效）
curl https://your-domain.com/health
```

**预期结果**：

```json
{
  "status": "ok",
  "service": "Google API Proxy",
  "timestamp": "2025-01-01T12:00:00.000Z"
}
```

如果看到以上 JSON 响应，说明部署成功！🎉

---

## 📖 使用方法

### API 调用说明

将原始 Google API 地址替换为你的代理地址即可。

**原始地址**：
```
https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent
```

**代理地址**：
```
https://your-domain.com/v1beta/models/gemini-2.0-flash-exp:generateContent
```

### cURL 示例

#### 1. 健康检查

```bash
curl https://your-domain.com/health
```

#### 2. 非流式生成

```bash
curl -X POST https://your-domain.com/v1beta/models/gemini-2.0-flash-exp:generateContent \
  -H "Content-Type: application/json" \
  -H "x-goog-api-key: YOUR_API_KEY" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "你好，介绍一下自己"
      }]
    }]
  }'
```

#### 3. 流式生成（SSE）

```bash
curl -X POST https://your-domain.com/v1beta/models/gemini-2.0-flash-exp:streamGenerateContent?alt=sse \
  -H "Content-Type: application/json" \
  -H "x-goog-api-key: YOUR_API_KEY" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "写一个关于人工智能的故事"
      }]
    }]
  }'
```

### JavaScript 示例

```javascript
const response = await fetch('https://your-domain.com/v1beta/models/gemini-2.0-flash-exp:generateContent', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'x-goog-api-key': 'YOUR_API_KEY'
  },
  body: JSON.stringify({
    contents: [{
      parts: [{ text: '你好' }]
    }]
  })
});

const data = await response.json();
console.log(data);
```

### Python 示例

```python
import requests

response = requests.post(
    'https://your-domain.com/v1beta/models/gemini-2.0-flash-exp:generateContent',
    headers={
        'Content-Type': 'application/json',
        'x-goog-api-key': 'YOUR_API_KEY'
    },
    json={
        'contents': [{
            'parts': [{'text': '你好'}]
        }]
    }
)

print(response.json())
```

---

## 🛠️ 常用命令

### PM2 进程管理

```bash
# 查看服务状态
pm2 list

# 查看实时日志
pm2 logs ai-api-proxy

# 查看最近 50 行日志
pm2 logs ai-api-proxy --lines 50

# 重启服务（重要：必须先 delete 再 start 才能更新环境变量）
pm2 delete ai-api-proxy && pm2 start ecosystem.config.js

# 停止服务
pm2 stop ai-api-proxy

# 删除服务
pm2 delete ai-api-proxy

# 实时监控
pm2 monit

# 查看详细信息
pm2 show ai-api-proxy

# 清空日志
pm2 flush
```

### 系统检查

```bash
# 检查端口监听
ss -tlnp | grep :443

# 检查进程
ps aux | grep node

# 检查系统资源
top
free -h
df -h
```

### 日志管理

```bash
# 查看访问日志
tail -f logs/out.log

# 查看错误日志
tail -f logs/error.log

# 查看最近 100 行
tail -100 logs/out.log

# 清空日志文件
> logs/out.log
> logs/error.log
```

---

## 🔧 配置说明

### 修改监听端口

编辑 `ecosystem.config.js`：

```javascript
env: {
  NODE_ENV: 'production',
  PORT: 443  // 修改为其他端口（需同步修改防火墙规则）
}
```

**重启服务**（必须 delete 后重新 start）：

```bash
pm2 delete ai-api-proxy && pm2 start ecosystem.config.js
```

### 修改目标 API

如果你想代理其他 API，编辑 `server.js`：

```javascript
const TARGET_URL = 'https://generativelanguage.googleapis.com';
// 修改为其他 API 地址，例如：
// const TARGET_URL = 'https://api.openai.com';
```

### 日志轮转配置

防止日志文件过大：

```bash
# 安装日志轮转模块
pm2 install pm2-logrotate

# 设置单个日志文件最大 10MB
pm2 set pm2-logrotate:max_size 10M

# 保留最近 7 个日志文件
pm2 set pm2-logrotate:retain 7

# 压缩旧日志
pm2 set pm2-logrotate:compress true
```

---

## ⚠️ 故障排查

### 问题 1：Cloudflare 521 错误（Web server is down）

**原因**：Cloudflare 无法连接到源服务器的 443 端口。

**排查步骤**：

```bash
# 1. 检查服务是否运行
pm2 list
# 确保 ai-api-proxy 状态为 online

# 2. 检查端口监听
ss -tlnp | grep :443
# 应该看到 node 进程监听在 443 端口

# 3. 检查本地访问
curl -k https://localhost/health
# 如果失败，查看错误日志：
pm2 logs ai-api-proxy --err --lines 50

# 4. 检查防火墙
sudo firewall-cmd --list-all  # CentOS
sudo ufw status               # Ubuntu

# 5. 检查云服务商安全组
# 确保 443 端口已开放
```

### 问题 2：Cloudflare 525 错误（SSL handshake failed）

**原因**：SSL 证书配置有问题。

**排查步骤**：

```bash
# 1. 检查证书文件是否存在
ls -la certs/
# 应该看到 cert.pem 和 key.pem

# 2. 检查证书文件内容
head -n 1 certs/cert.pem
# 应该显示：-----BEGIN CERTIFICATE-----

head -n 1 certs/key.pem
# 应该显示：-----BEGIN PRIVATE KEY-----

# 3. 检查文件权限
# cert.pem 应该是 644，key.pem 应该是 600

# 4. 检查 Cloudflare SSL 模式
# 必须设置为 Full (Strict)
```

### 问题 3：端口被占用（EADDRINUSE）

**错误信息**：`Error: bind EADDRINUSE 0.0.0.0:443`

**解决方案**：

```bash
# 查找占用进程
sudo lsof -i :443
sudo ss -tlnp | grep :443

# 停止占用进程
sudo kill -9 PID

# 或者停止所有 PM2 进程后重启
pm2 delete all
pm2 start ecosystem.config.js
pm2 save
```

### 问题 4：服务频繁重启

**排查步骤**：

```bash
# 查看错误日志
pm2 logs ai-api-proxy --err --lines 100

# 常见原因：
# 1. 依赖未安装
npm install

# 2. 证书文件路径错误
ls -la certs/

# 3. 权限问题（443 端口需要 root 权限）
# 确保以 root 用户运行
```

### 问题 5：本地 curl 证书错误

**错误信息**：`SSL certificate problem: unable to get local issuer certificate`

**原因**：这是正常的。Cloudflare Origin Certificate 只被 Cloudflare 信任，本地测试需要跳过证书验证。

**解决方案**：

```bash
# 本地测试时加上 -k 参数
curl -k https://localhost/health

# 通过域名访问不需要 -k（因为 Cloudflare 会处理证书）
curl https://your-domain.com/health
```

### 问题 6：无法访问 Google API

**错误信息**：API 返回 403/503 等错误。

**可能原因**：

1. **服务器地域限制**：某些地区的服务器可能无法直接访问 Google API
2. **API Key 无效**：API Key 过期或配额用尽

**排查步骤**：

```bash
# 1. 测试服务器能否访问 Google API
curl https://generativelanguage.googleapis.com/v1beta/models

# 2. 查看代理日志
pm2 logs ai-api-proxy --lines 100

# 3. 验证 API Key
curl "https://generativelanguage.googleapis.com/v1beta/models?key=YOUR_API_KEY"
```

---

## 📊 项目结构

```
ai-api-gateway/
├── server.js              # 主服务文件（HTTPS）
├── package.json           # npm 依赖配置
├── ecosystem.config.js    # PM2 配置文件
├── deploy.sh              # 一键部署脚本
├── certs/                 # SSL 证书目录（.gitignore）
│   ├── cert.pem          # Cloudflare Origin Certificate
│   ├── key.pem           # 私钥
│   └── README.md         # 证书说明
├── logs/                  # 日志目录（自动创建）
│   ├── out.log           # 访问日志
│   └── error.log         # 错误日志
├── README.md              # 英文文档
├── README-zh.md           # 本文档（中文）
├── HTTPS-SETUP.md         # HTTPS 详细配置说明
├── CHANGELOG.md           # 版本更新日志
├── LICENSE                # MIT 许可证
└── .gitignore             # Git 忽略配置
```

---

## 📈 性能优化

### 监控指标

**正常运行指标**：
- **CPU 使用率**：< 50%
- **内存使用**：< 500MB
- **响应时间**：< 2s
- **重启次数**：0（稳定运行后）

**查看指标**：

```bash
pm2 show ai-api-proxy
pm2 monit
```

### Cloudflare 优化建议

1. **缓存规则**（可选）：
   - 对于不变的响应可以启用缓存
   - API 请求建议设置 `Cache Level: Bypass`

2. **限流保护**：
   - Cloudflare → Security → Rate Limiting
   - 设置请求频率限制，防止滥用

3. **页面规则**（Page Rules）：
   - 可以为特定路径设置自定义规则
   - 例如对 `/health` 启用缓存

---

## 🔒 安全建议

### 保护证书文件

```bash
# 私钥文件必须设置严格权限
chmod 600 certs/key.pem

# 不要将证书文件提交到 Git
# 已在 .gitignore 中配置
```

### 请求头安全

代理只转发以下请求头，其他请求头会被过滤：
- `x-goog-api-key`：API 密钥
- `content-type`：内容类型

这样可以保护用户隐私，防止 `Cookie`、`User-Agent`、`Referer` 等敏感信息被转发。

### API Key 保护

- ✅ 使用 HTTPS（Full Strict 模式）确保传输加密
- ✅ 不要将 API Key 硬编码在客户端代码中
- ✅ 建议在后端调用代理服务，前端通过你的后端 API 访问

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 提交更改：`git commit -m 'Add some AmazingFeature'`
4. 推送到分支：`git push origin feature/AmazingFeature`
5. 提交 Pull Request

---

## 📝 更新日志

查看 [CHANGELOG.md](./CHANGELOG.md)

---

## 📄 许可证

本项目基于 [MIT License](./LICENSE) 开源。

---

## 🔗 相关链接

- [Google Generative Language API 文档](https://ai.google.dev/docs)
- [Cloudflare Dashboard](https://dash.cloudflare.com/)
- [Cloudflare Origin Certificate 文档](https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/)
- [PM2 文档](https://pm2.keymetrics.io/)
- [Node.js 官网](https://nodejs.org/)

---

## ⚡ 支持的模型

- Gemini 2.0 Flash Experimental
- Gemini 1.5 Pro
- Gemini 1.5 Flash
- 其他 Google Generative Language API 支持的模型

---

## ❓ 常见问题

### Q: 为什么不使用 Let's Encrypt？

A: Cloudflare Origin Certificate 免费、15年有效期、配置简单，非常适合通过 Cloudflare 代理的场景。如果你需要直连服务器（不通过 Cloudflare），可以使用 Let's Encrypt。

### Q: 可以部署在其他云服务商吗？

A: 可以！本项目支持任何支持 Node.js 的服务器，包括：
- 腾讯云 CVM
- 阿里云 ECS
- AWS EC2
- Google Cloud Compute Engine
- Azure Virtual Machines
- DigitalOcean Droplets
- Vultr
- Linode

### Q: 支持代理其他 API 吗？

A: 可以！只需修改 `server.js` 中的 `TARGET_URL` 即可代理任何 HTTPS API。

### Q: 为什么必须使用 `pm2 delete` 后再 `start`？

A: PM2 的 `restart` 命令不会更新环境变量，如果你修改了 `ecosystem.config.js` 中的 `PORT` 等配置，必须先 `delete` 再 `start` 才能生效。

### Q: 可以同时代理多个 API 吗？

A: 可以！你可以在 `server.js` 中添加路由判断逻辑，根据不同的路径转发到不同的目标 API。

### Q: 部署后如何更新代码？

A: 

```bash
# 1. 备份当前版本
cd /root
tar -czf ai-api-gateway-backup-$(date +%Y%m%d).tar.gz ai-api-gateway/

# 2. 拉取新代码（进入项目目录）
cd ai-api-gateway  # 或你的项目实际路径
git pull

# 3. 重启服务
pm2 restart ai-api-proxy

# 4. 查看日志确认
pm2 logs ai-api-proxy --lines 20
```

---

**如果本项目对你有帮助，请给个 Star ⭐**

