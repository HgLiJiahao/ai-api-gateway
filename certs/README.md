# SSL 证书目录

此目录用于存放 Cloudflare Origin Certificate。

## 文件说明

- `cert.pem` - Cloudflare Origin Certificate（证书）
- `key.pem` - 私钥

## 重要提醒

⚠️ **请勿将证书文件提交到 Git 仓库！**

这些文件已在 `.gitignore` 中排除，但请确保：
1. 证书文件权限设置正确：
   ```bash
   chmod 600 key.pem
   chmod 644 cert.pem
   ```
2. 不要在任何地方分享私钥
3. 如果私钥泄露，立即在 Cloudflare 重新生成证书

## 如何获取证书

请参考 [HTTPS-SETUP.md](../HTTPS-SETUP.md) 中的详细步骤。

简要步骤：
1. 登录 Cloudflare Dashboard
2. 选择域名 → SSL/TLS → Origin Server
3. 点击 Create Certificate
4. 复制证书内容到 `cert.pem`
5. 复制私钥内容到 `key.pem`

## 证书格式示例

### cert.pem
```
-----BEGIN CERTIFICATE-----
MIIEpDCCAowCCQDO...（证书内容）...==
-----END CERTIFICATE-----
```

### key.pem
```
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkq...（私钥内容）...==
-----END PRIVATE KEY-----
```

---

**This directory is for storing Cloudflare Origin Certificate.**

⚠️ **DO NOT commit certificate files to Git repository!**

For detailed instructions, see [HTTPS-SETUP.md](../HTTPS-SETUP.md).

