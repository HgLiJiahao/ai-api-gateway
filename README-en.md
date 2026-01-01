# AI API Gateway

[简体中文](./README.md) | English

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D16.0.0-brightgreen)](https://nodejs.org/)
[![HTTPS](https://img.shields.io/badge/HTTPS-Full%20(Strict)-green)](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/)

A secure, high-performance AI API reverse proxy gateway supporting Google Gemini, OpenAI, Anthropic Claude, and other mainstream AI APIs with end-to-end HTTPS encryption.

**What You Can Achieve with This Project:**
- 🌍 **Bypass Geographic Restrictions** - Access OpenAI, Claude and other AI services from restricted regions
- 🔒 **Protect API Keys** - End-to-end HTTPS encryption prevents key exposure during transmission
- ⚡ **Accelerate Access** - Leverage Cloudflare's global CDN for significantly improved API response times
- 🎯 **Unified Access Management** - One domain proxies multiple AI services, simplifying application integration
- 💰 **Cost Savings** - Self-hosted solution is more economical than expensive proxy services

<div align="center">
  <img src="./images/proxy_pic.jpg" alt="AI API Gateway Architecture Flow" width="800">
  <p><i>Request Flow Visualization</i></p>
</div>

## ⚠️ Disclaimer and Usage Notice

**Purpose of This Project:**
- This project is designed to help users bypass geographical restrictions imposed by AI API providers
- Solves the problem of regions being denied access to mainstream AI model APIs
- Provides technical solutions for legitimate users and promotes global accessibility of AI technology

**Important Warnings:**
- ⚠️ **DO NOT use this project for any illegal or criminal activities**
- ⚠️ Users must comply with local laws and regulations as well as the terms of service of AI API providers
- ⚠️ The developers of this project are not responsible for any illegal activities conducted by users
- ⚠️ By using this project, you agree to use it legally and compliantly, and assume all risks

**Recommended Use Cases:**
- Learning and researching AI technology
- Legitimate commercial application development
- Personal learning and technical exploration

---

## ✨ Features

- 🤖 **Multi-AI API Support** - Supports Google Gemini, OpenAI, Anthropic Claude, and other mainstream AI APIs
- 🔒 **End-to-End HTTPS Encryption** - Cloudflare Origin Certificate with encrypted API key transmission
- 🚀 **Streaming Support** - Full SSE (Server-Sent Events) support for streaming responses
- 🌐 **CORS Enabled** - Automatic CORS handling for all origins
- 🛡️ **Header Filtering** - Only forwards necessary headers for privacy protection
- ⚡ **High Availability** - PM2 process management with auto-restart
- 🌍 **Global CDN** - Cloudflare CDN integration
- 🎯 **One-Click Deployment** - Interactive deployment script with API type selection
- 📝 **Detailed Logging** - Complete request logging

## 🤖 Supported AI APIs

| AI Service | API Type | Target URL | Authentication |
|------------|----------|------------|----------------|
| **Google Gemini** | `gemini` | `https://generativelanguage.googleapis.com` | `x-goog-api-key` |
| **OpenAI** | `openai` | `https://api.openai.com` | `Authorization: Bearer TOKEN` |
| **Anthropic Claude** | `claude` | `https://api.anthropic.com` | `x-api-key` + `anthropic-version` |

> 💡 Choose the API type during deployment with interactive script, or configure manually.

## 🏗️ Architecture

### 🔐 Architecture Description

```
┌─────────┐  HTTPS   ┌──────────┐  HTTPS   ┌─────────┐  HTTPS   ┌──────────────┐
│  Client │ ───────> │ Cloudflare│ ───────> │  Server │ ───────> │   AI API     │
│ Browser │          │    CDN    │          │ Node.js │          │ Gemini/GPT   │
└─────────┘          └──────────┘          └─────────┘          │  /Claude     │
             SSL/TLS           Origin                            └──────────────┘
            Full (Strict)    Certificate
```

**Security Guarantee**: API keys are encrypted throughout the entire transmission chain via TLS, preventing plaintext exposure.

---

## 📋 Prerequisites

Before deploying this project, you need to complete the following prerequisites. These steps are essential for the service to run properly.

### 1. System Requirements

#### Server/System Requirements
- **Operating System**:
  - **Linux Servers**: CentOS 7+ / Ubuntu 18.04+ / Debian 10+
  - **macOS Development**: macOS 10.14+ (Mojave or higher)
- **CPU**: 1 core or more
- **RAM**: 512MB or more (1GB+ recommended for production)
- **Storage**: 1GB available space
- **Network**: Public internet access with ability to connect to target AI APIs

#### Software Requirements
- **Node.js**: 16.x or higher
- **PM2**: Latest version
- **Git** (optional): For cloning the repository
- **Homebrew** (macOS): For installing Node.js (script will auto-install)

> 💡 **Tips**:
> - Linux servers: Suitable for production deployment, requires root or sudo privileges
> - macOS environment: Suitable for local development and testing, some features require sudo (e.g., binding to port 443)

### 2. Domain Setup

You need to own a domain name to use this service.

#### Option A: Use Existing Domain
If you already have a domain, you can use it directly.

#### Option B: Purchase New Domain
Recommended domain registrars:
- [Cloudflare Registrar](https://www.cloudflare.com/products/registrar/) (at-cost pricing, no markup)
- [NameSilo](https://www.namesilo.com/)
- [Namecheap](https://www.namecheap.com/)
- [GoDaddy](https://www.godaddy.com/)

> **Tip**: Common TLDs like `.com`, `.net`, `.org` typically cost around $10-15 per year.

### 3. Cloudflare Configuration

This project uses Cloudflare for CDN acceleration and SSL certificate services. Follow these complete setup steps.

#### 3.1 Register Cloudflare Account

1. Visit [Cloudflare website](https://www.cloudflare.com/)
2. Click **Sign Up** in the top right corner
3. Verify your email address

#### 3.2 Add Domain to Cloudflare

1. Log in to Cloudflare Dashboard
2. Click **Add a Site**
3. Enter your domain (e.g., `example.com`)
4. Select the **Free** plan (free tier is sufficient)
5. Cloudflare will automatically scan existing DNS records

#### 3.3 Update Domain Nameservers

Cloudflare will provide two nameserver addresses, similar to:

```
nameserver1.cloudflare.com
nameserver2.cloudflare.com
```

**Steps**:

1. Log in to your domain registrar's control panel
2. Find DNS settings or Nameserver settings
3. Replace existing nameservers with the Cloudflare nameservers
4. Save changes

> **Note**: DNS changes may take 1-48 hours to propagate, typically completing within a few hours.

#### 3.4 Configure DNS Records

Return to Cloudflare Dashboard, add an A record in the **DNS** tab:

| Type | Name | IPv4 Address | Proxy Status | TTL |
|------|------|--------------|--------------|-----|
| A | @ | Your server IP | Proxied (orange cloud ☁️) | Auto |

**Explanation**:
- **Name `@`**: Represents the root domain (e.g., `example.com`)
- **For subdomains**: Enter `api` (represents `api.example.com`)
- **Proxy status must be enabled**: Ensure the orange cloud icon is displayed to use Cloudflare's CDN and SSL features

#### 3.5 Generate SSL Certificate

This project uses Cloudflare Origin Certificate (free, 15-year validity).

**Steps**:

1. In Cloudflare Dashboard, select your domain
2. Navigate to **SSL/TLS** → **Origin Server**
3. Click **Create Certificate** button
4. Configure certificate:
   - **Private key type**: Select `RSA (2048)`
   - **Hostnames**: Keep default (automatically includes your domain and `*.yourdomain.com`)
   - **Certificate Validity**: Select `15 years`
5. Click **Create** button
6. **Important**: Immediately copy and save the following two items:

**Origin Certificate** (save as `cert.pem`):
```
-----BEGIN CERTIFICATE-----
MIIEpDCCA4ygAwIBAgIUXXXXXXXXXXXXXXXXXXXXXXXXXXX...
(long content)
...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-----END CERTIFICATE-----
```

**Private Key** (save as `key.pem`):
```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASC...
(long content)
...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-----END PRIVATE KEY-----
```

> **Important**: The private key will only be shown once. Save it securely! If lost, you'll need to regenerate the certificate.

#### 3.6 Configure SSL/TLS Mode

1. In Cloudflare Dashboard, go to **SSL/TLS** → **Overview**
2. Set encryption mode to **Full (Strict)**
3. Confirm the setting is saved

**SSL/TLS Mode Comparison**:

| Mode | Client to CF | CF to Origin | Security |
|------|--------------|--------------|----------|
| Off | HTTP | HTTP | ❌ Not Secure |
| Flexible | HTTPS | **HTTP (plaintext)** | ⚠️ Not Secure |
| Full | HTTPS | HTTPS (unverified) | ⚠️ Moderate |
| **Full (Strict)** | **HTTPS** | **HTTPS (verified)** | ✅ **Most Secure** |

> **Must select Full (Strict)**: This ensures API keys are encrypted throughout the entire transmission chain.

### 4. Server Preparation

#### 4.1 Prepare Certificate Files

On your local computer, create the following two files:

**cert.pem**:
```bash
cat > cert.pem << 'EOF'
-----BEGIN CERTIFICATE-----
(Paste the Origin Certificate you copied from Cloudflare)
-----END CERTIFICATE-----
EOF
```

**key.pem**:
```bash
cat > key.pem << 'EOF'
-----BEGIN PRIVATE KEY-----
(Paste the Private Key you copied from Cloudflare)
-----END PRIVATE KEY-----
EOF
```

#### 4.2 Configure Server Firewall and Security Groups

Ensure port 443 (HTTPS) is open on your server.

**CentOS/RHEL (firewalld)**:
```bash
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

**Ubuntu/Debian (ufw)**:
```bash
sudo ufw allow 443/tcp
sudo ufw reload
```

**macOS**:
```bash
# macOS is typically used in development environments, firewall configuration is optional
# If firewall is enabled:
# System Preferences → Security & Privacy → Firewall → Firewall Options
# Allow Node applications to accept incoming connections
```

**Cloud Provider Security Groups** (Tencent Cloud/Alibaba Cloud/AWS, etc.):

Add an inbound rule in your cloud provider's security group settings:
- **Protocol**: TCP
- **Port Range**: 443
- **Source**: 0.0.0.0/0 (allow all sources)

---

## 🚀 One-Click Deployment

After completing the prerequisites, you can now deploy the project!

### Method 1: Clone with Git (Recommended)

```bash
# 1. Clone the project to your server
git clone https://github.com/HgLiJiahao/ai-api-gateway.git
cd ai-api-gateway

# 2. Upload certificate files
# Upload the cert.pem and key.pem you prepared earlier to the certs/ directory
mkdir -p certs
# Use scp or SFTP to upload files, or create manually:
# vi certs/cert.pem  (paste certificate content)
# vi certs/key.pem   (paste private key content)

# 3. Set certificate permissions
chmod 600 certs/key.pem
chmod 644 certs/cert.pem

# 4. Run one-click deployment script
chmod +x deploy.sh
sudo ./deploy.sh  # Use sudo on Linux servers
# macOS users can run directly: ./deploy.sh
```

> **macOS User Tips**:
> - macOS environment is typically used for local development and testing
> - Binding to port 443 requires sudo: `sudo pm2 start ecosystem.config.js`
> - You can change the port to 8443 or other non-privileged port in `ecosystem.config.js`
> - Deployment script will automatically detect and install Homebrew if not present

### Method 2: Manual File Upload

If your server cannot access GitHub, you can upload files manually:

```bash
# 1. Create project directory on server (choose your preferred location)
mkdir -p ai-api-gateway
cd ai-api-gateway

# 2. Upload the following files to server (using scp, SFTP, or other methods):
#    - server.js
#    - package.json
#    - ecosystem.config.js
#    - deploy.sh

# 3. Create certs directory and upload certificates
mkdir -p certs
# Upload cert.pem and key.pem to certs/ directory

# 4. Set certificate permissions
chmod 600 certs/key.pem
chmod 644 certs/cert.pem

# 5. Run one-click deployment script
chmod +x deploy.sh
sudo ./deploy.sh
```

### The deploy.sh script will automatically:

1. ✅ Detect and install Node.js (if not installed)
2. ✅ Detect and install PM2 (if not installed)
3. ✅ Install project dependencies (npm install)
4. ✅ Create log directory
5. ✅ Configure firewall (open port 443)
6. ✅ Start service (pm2 start)
7. ✅ Save PM2 configuration (pm2 save)
8. ✅ Set up auto-start on boot (pm2 startup)
9. ✅ Verify service status

### Verify Deployment

After deployment, the script will automatically verify. You can also verify manually:

```bash
# 1. Check PM2 service status
pm2 list

# 2. View service logs
pm2 logs ai-api-proxy --lines 20

# 3. Local health check (-k flag to skip certificate verification)
curl -k https://localhost/health

# 4. Access via domain (wait 1-2 minutes for Cloudflare to take effect)
curl https://your-domain.com/health
```

**Expected Response**:

```json
{
  "status": "ok",
  "service": "Google API Proxy",
  "timestamp": "2025-01-01T12:00:00.000Z"
}
```

If you see the above JSON response, deployment is successful! 🎉

---

## 📖 Usage

### API Call Instructions

Simply replace the original Google API URL with your proxy URL.

**Original URL**:
```
https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent
```

**Proxied URL**:
```
https://your-domain.com/v1beta/models/gemini-2.0-flash-exp:generateContent
```

### cURL Examples

#### 1. Health Check

```bash
curl https://your-domain.com/health
```

#### 2. Non-Streaming Generation

```bash
curl -X POST https://your-domain.com/v1beta/models/gemini-2.0-flash-exp:generateContent \
  -H "Content-Type: application/json" \
  -H "x-goog-api-key: YOUR_API_KEY" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Hello, introduce yourself"
      }]
    }]
  }'
```

#### 3. Streaming Generation (SSE)

```bash
curl -X POST https://your-domain.com/v1beta/models/gemini-2.0-flash-exp:streamGenerateContent?alt=sse \
  -H "Content-Type: application/json" \
  -H "x-goog-api-key: YOUR_API_KEY" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Write a story about artificial intelligence"
      }]
    }]
  }'
```

### JavaScript Example

```javascript
const response = await fetch('https://your-domain.com/v1beta/models/gemini-2.0-flash-exp:generateContent', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'x-goog-api-key': 'YOUR_API_KEY'
  },
  body: JSON.stringify({
    contents: [{
      parts: [{ text: 'Hello' }]
    }]
  })
});

const data = await response.json();
console.log(data);
```

### Python Example

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
            'parts': [{'text': 'Hello'}]
        }]
    }
)

print(response.json())
```

---

## 🛠️ Common Commands

### PM2 Process Management

```bash
# View service status
pm2 list

# View real-time logs
pm2 logs ai-api-proxy

# View last 50 lines of logs
pm2 logs ai-api-proxy --lines 50

# Restart service (Important: must delete then start to update environment variables)
pm2 delete ai-api-proxy && pm2 start ecosystem.config.js

# Stop service
pm2 stop ai-api-proxy

# Delete service
pm2 delete ai-api-proxy

# Real-time monitoring
pm2 monit

# View detailed information
pm2 show ai-api-proxy

# Clear logs
pm2 flush
```

### System Checks

```bash
# Check port listening
ss -tlnp | grep :443

# Check process
ps aux | grep node

# Check system resources
top
free -h
df -h
```

### Log Management

```bash
# View access logs
tail -f logs/out.log

# View error logs
tail -f logs/error.log

# View last 100 lines
tail -100 logs/out.log

# Clear log files
> logs/out.log
> logs/error.log
```

---

## 🔧 Configuration

### Change Listen Port

Edit `ecosystem.config.js`:

```javascript
env: {
  NODE_ENV: 'production',
  PORT: 443  // Change to another port (update firewall rules accordingly)
}
```

**Restart service** (must delete then start):

```bash
pm2 delete ai-api-proxy && pm2 start ecosystem.config.js
```

### Change Target API

To proxy other APIs, edit `server.js`:

```javascript
const TARGET_URL = 'https://generativelanguage.googleapis.com';
// Change to other API URL, for example:
// const TARGET_URL = 'https://api.openai.com';
```

### Log Rotation Configuration

To prevent log files from growing too large:

```bash
# Install log rotation module
pm2 install pm2-logrotate

# Set max log file size to 10MB
pm2 set pm2-logrotate:max_size 10M

# Keep last 7 log files
pm2 set pm2-logrotate:retain 7

# Compress old logs
pm2 set pm2-logrotate:compress true
```

---

## ⚠️ Troubleshooting

### Issue 1: Cloudflare 521 Error (Web server is down)

**Cause**: Cloudflare cannot connect to origin server's port 443.

**Troubleshooting Steps**:

```bash
# 1. Check if service is running
pm2 list
# Ensure ai-api-proxy status is online

# 2. Check port listening
ss -tlnp | grep :443
# Should see node process listening on port 443

# 3. Check local access
curl -k https://localhost/health
# If fails, check error logs:
pm2 logs ai-api-proxy --err --lines 50

# 4. Check firewall
sudo firewall-cmd --list-all  # CentOS
sudo ufw status               # Ubuntu

# 5. Check cloud provider security group
# Ensure port 443 is open
```

### Issue 2: Cloudflare 525 Error (SSL handshake failed)

**Cause**: SSL certificate configuration issue.

**Troubleshooting Steps**:

```bash
# 1. Check if certificate files exist
ls -la certs/
# Should see cert.pem and key.pem

# 2. Check certificate file content
head -n 1 certs/cert.pem
# Should display: -----BEGIN CERTIFICATE-----

head -n 1 certs/key.pem
# Should display: -----BEGIN PRIVATE KEY-----

# 3. Check file permissions
# cert.pem should be 644, key.pem should be 600

# 4. Check Cloudflare SSL mode
# Must be set to Full (Strict)
```

### Issue 3: Port Already in Use (EADDRINUSE)

**Error message**: `Error: bind EADDRINUSE 0.0.0.0:443`

**Solution**:

```bash
# Find process using port
sudo lsof -i :443
sudo ss -tlnp | grep :443

# Stop process
sudo kill -9 PID

# Or stop all PM2 processes and restart
pm2 delete all
pm2 start ecosystem.config.js
pm2 save
```

### Issue 4: Service Frequently Restarting

**Troubleshooting Steps**:

```bash
# View error logs
pm2 logs ai-api-proxy --err --lines 100

# Common causes:
# 1. Dependencies not installed
npm install

# 2. Certificate file path error
ls -la certs/

# 3. Permission issues (port 443 requires root)
# Ensure running as root user
```

### Issue 5: Local curl Certificate Error

**Error message**: `SSL certificate problem: unable to get local issuer certificate`

**Cause**: This is normal. Cloudflare Origin Certificate is only trusted by Cloudflare. Local testing requires skipping certificate verification.

**Solution**:

```bash
# Add -k flag for local testing
curl -k https://localhost/health

# Access via domain doesn't need -k (Cloudflare handles certificate)
curl https://your-domain.com/health
```

### Issue 6: Cannot Access Google API

**Error message**: API returns 403/503 errors.

**Possible Causes**:

1. **Server Region Restriction**: Servers in some regions may not be able to directly access Google API
2. **Invalid API Key**: API key expired or quota exhausted

**Troubleshooting Steps**:

```bash
# 1. Test if server can access Google API
curl https://generativelanguage.googleapis.com/v1beta/models

# 2. View proxy logs
pm2 logs ai-api-proxy --lines 100

# 3. Verify API Key
curl "https://generativelanguage.googleapis.com/v1beta/models?key=YOUR_API_KEY"
```

---

## 📊 Project Structure

```
ai-api-gateway/
├── server.js              # Main service file (HTTPS)
├── package.json           # npm dependencies
├── ecosystem.config.js    # PM2 configuration
├── deploy.sh              # One-click deployment script
├── certs/                 # SSL certificates (.gitignore)
│   ├── cert.pem          # Cloudflare Origin Certificate
│   ├── key.pem           # Private key
│   └── README.md         # Certificate documentation
├── logs/                  # Log directory (auto-created)
│   ├── out.log           # Access logs
│   └── error.log         # Error logs
├── README.md              # This file (English)
├── README-zh.md           # Chinese documentation
├── HTTPS-SETUP.md         # HTTPS setup details
├── CHANGELOG.md           # Version changelog
├── LICENSE                # MIT License
└── .gitignore             # Git ignore configuration
```

---

## 📈 Performance Optimization

### Monitoring Metrics

**Normal Operation Metrics**:
- **CPU Usage**: < 50%
- **Memory Usage**: < 500MB
- **Response Time**: < 2s
- **Restart Count**: 0 (after stabilization)

**View Metrics**:

```bash
pm2 show ai-api-proxy
pm2 monit
```

### Cloudflare Optimization Tips

1. **Cache Rules** (optional):
   - Can enable caching for unchanging responses
   - For API requests, recommend setting `Cache Level: Bypass`

2. **Rate Limiting**:
   - Cloudflare → Security → Rate Limiting
   - Set request frequency limits to prevent abuse

3. **Page Rules**:
   - Set custom rules for specific paths
   - For example, enable caching for `/health`

---

## 🔒 Security Recommendations

### Protect Certificate Files

```bash
# Private key file must have strict permissions
chmod 600 certs/key.pem

# Don't commit certificate files to Git
# Already configured in .gitignore
```

### Request Header Security

The proxy only forwards the following headers, filtering all others:
- `x-goog-api-key`: API key
- `content-type`: Content type

This protects user privacy by preventing sensitive headers like `Cookie`, `User-Agent`, `Referer`, etc. from being forwarded.

### API Key Protection

- ✅ Use HTTPS (Full Strict mode) to ensure encrypted transmission
- ✅ Don't hardcode API keys in client-side code
- ✅ Recommend calling proxy service from backend, frontend accesses through your backend API

---

## 🤝 Contributing

Issues and Pull Requests are welcome!

1. Fork this project
2. Create your feature branch: `git checkout -b feature/AmazingFeature`
3. Commit your changes: `git commit -m 'Add some AmazingFeature'`
4. Push to the branch: `git push origin feature/AmazingFeature`
5. Submit a Pull Request

---

## 📝 Changelog

See [CHANGELOG.md](./CHANGELOG.md)

---

## 📄 License

This project is licensed under the [MIT License](./LICENSE).

---

## 🔗 Related Links

- [Google Generative Language API Documentation](https://ai.google.dev/docs)
- [Cloudflare Dashboard](https://dash.cloudflare.com/)
- [Cloudflare Origin Certificate Documentation](https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/)
- [PM2 Documentation](https://pm2.keymetrics.io/)
- [Node.js Official Website](https://nodejs.org/)

---

## ⚡ Supported Models

- Gemini 2.0 Flash Experimental
- Gemini 1.5 Pro
- Gemini 1.5 Flash
- Other models supported by Google Generative Language API

---

## ❓ FAQ

### Q: Why not use Let's Encrypt?

A: Cloudflare Origin Certificate is free, has a 15-year validity period, and is simple to configure, making it ideal for scenarios proxied through Cloudflare. If you need direct server access (not through Cloudflare), you can use Let's Encrypt.

### Q: Can I deploy on other cloud providers?

A: Yes! This project supports any server that runs Node.js, including:
- Tencent Cloud CVM
- Alibaba Cloud ECS
- AWS EC2
- Google Cloud Compute Engine
- Azure Virtual Machines
- DigitalOcean Droplets
- Vultr
- Linode

### Q: Can I proxy other APIs?

A: Yes! Just modify the `TARGET_URL` in `server.js` to proxy any HTTPS API.

### Q: Why must I use `pm2 delete` then `start`?

A: PM2's `restart` command doesn't update environment variables. If you modify configurations like `PORT` in `ecosystem.config.js`, you must `delete` then `start` for changes to take effect.

### Q: Can I proxy multiple APIs simultaneously?

A: Yes! You can add routing logic in `server.js` to forward to different target APIs based on different paths.

### Q: How to update code after deployment?

A: 

```bash
# 1. Backup current version
cd /root
tar -czf ai-api-gateway-backup-$(date +%Y%m%d).tar.gz ai-api-gateway/

# 2. Pull new code (enter project directory)
cd ai-api-gateway  # or your actual project path
git pull

# 3. Restart service
pm2 restart ai-api-proxy

# 4. Check logs
pm2 logs ai-api-proxy --lines 20
```

---

**Star ⭐ this repo if it helps you!**

