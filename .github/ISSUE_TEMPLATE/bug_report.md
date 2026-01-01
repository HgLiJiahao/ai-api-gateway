---
name: Bug 报告 / Bug Report
about: 报告一个 Bug 帮助我们改进 / Report a bug to help us improve
title: '[BUG] '
labels: bug
assignees: ''

---

## Bug 描述 / Bug Description

<!-- 清晰简洁地描述这个 Bug / A clear and concise description of what the bug is -->

## 复现步骤 / Steps to Reproduce

<!-- 详细的复现步骤 / Steps to reproduce the behavior -->

1. 执行命令 '...' / Run command '...'
2. 访问 URL '...' / Access URL '...'
3. 看到错误 '...' / See error '...'

## 预期行为 / Expected Behavior

<!-- 你期望发生什么 / What you expected to happen -->

## 实际行为 / Actual Behavior

<!-- 实际发生了什么 / What actually happened -->

## 环境信息 / Environment

- Node.js 版本 / Node.js version: [输出 `node -v`]
- npm 版本 / npm version: [输出 `npm -v`]
- PM2 版本 / PM2 version: [输出 `pm2 -v`]
- 操作系统 / OS: [例如 CentOS 7, Ubuntu 20.04]
- Cloudflare SSL 模式 / Cloudflare SSL mode: [Flexible / Full / Full (Strict)]

## 日志 / Logs

<!-- 粘贴相关的错误日志 / Paste relevant error logs -->

```bash
# 执行以下命令获取日志 / Run this to get logs
pm2 logs google-api-proxy --err --lines 50
```

```
在此粘贴日志 / Paste logs here
```

## 截图 / Screenshots

<!-- 如果适用，添加截图 / If applicable, add screenshots -->

## 额外信息 / Additional Context

<!-- 添加任何其他相关信息 / Add any other context about the problem -->

