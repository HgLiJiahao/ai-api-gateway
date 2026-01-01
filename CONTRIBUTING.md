# 贡献指南 / Contributing Guide

感谢你考虑为本项目做出贡献！/ Thank you for considering contributing to this project!

[简体中文](#简体中文) | [English](#english)

---

## 简体中文

### 如何贡献

我们欢迎各种形式的贡献：

- 🐛 报告 Bug
- 💡 提出新功能建议
- 📝 改进文档
- 🔧 提交代码修复或新功能
- 🌐 翻译文档

### 报告 Bug

在提交 Bug 报告前，请先搜索现有的 Issue，确保问题尚未被报告。

创建 Issue 时，请提供：

1. **问题描述**：清晰、简洁地描述问题
2. **复现步骤**：详细的步骤，让我们能够重现问题
3. **预期行为**：你期望发生什么
4. **实际行为**：实际发生了什么
5. **环境信息**：
   - Node.js 版本：`node -v`
   - npm 版本：`npm -v`
   - PM2 版本：`pm2 -v`
   - 操作系统：CentOS/Ubuntu/等
   - Cloudflare SSL 模式
6. **日志**：相关的错误日志（`pm2 logs ai-api-proxy --err`）
7. **截图**（如适用）

### 提出新功能

在提交新功能建议前，请先搜索现有的 Issue。

创建 Issue 时，请说明：

1. **功能描述**：你希望添加什么功能
2. **使用场景**：这个功能解决什么问题
3. **实现建议**（可选）：你认为如何实现这个功能

### 提交代码

#### 开发流程

1. **Fork 本仓库**
2. **克隆你的 Fork**
   ```bash
   git clone https://github.com/HgLiJiahao/ai-api-gateway.git
   cd ai-api-gateway
   ```
3. **创建特性分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **安装依赖**
   ```bash
   npm install
   ```
5. **进行修改**
   - 遵循代码风格（见下文）
   - 添加必要的中文注释
   - 确保代码简洁、易读
6. **测试你的修改**
   ```bash
   # 本地测试
   node server.js
   
   # 或使用 PM2
   pm2 start ecosystem.config.js
   pm2 logs ai-api-proxy
   ```
7. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 添加新功能描述"
   ```
8. **推送到你的 Fork**
   ```bash
   git push origin feature/your-feature-name
   ```
9. **创建 Pull Request**

#### 代码风格

- **语言**：JavaScript (Node.js)
- **缩进**：2 空格
- **注释**：使用中文注释，清晰说明代码逻辑
- **命名**：
  - 变量/函数：小驼峰 `camelCase`
  - 常量：大写下划线 `UPPER_SNAKE_CASE`
- **函数**：保持简洁，单一职责
- **异步**：使用 `async/await` 而非 Promise chains

**示例：**

```javascript
// 健康检查端点
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'Google API Proxy',
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
    
    // ... 更多逻辑
  } catch (error) {
    console.error(`错误: ${error.message}`);
    res.status(500).json({ error: '代理请求失败' });
  }
});
```

#### Commit 规范

遵循 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/) 规范：

```
<类型>(<范围>): <描述>

[可选的正文]

[可选的脚注]
```

**类型：**
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构（既不是新功能也不是修复）
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建/工具相关

**示例：**
```
feat(proxy): 添加请求超时配置

- 支持自定义超时时间
- 添加超时错误处理
- 更新文档

Closes #123
```

#### Pull Request 清单

提交 PR 前，请确保：

- [ ] 代码遵循项目风格规范
- [ ] 添加了必要的中文注释
- [ ] 本地测试通过
- [ ] 更新了相关文档（如适用）
- [ ] 更新了 CHANGELOG.md（如适用）
- [ ] Commit 信息遵循规范
- [ ] PR 描述清楚说明了修改内容

### 改进文档

文档改进包括：

- 修正拼写/语法错误
- 改进说明的清晰度
- 添加缺失的信息
- 更新过时的内容
- 添加示例代码

文档文件：
- `README.md`：完整部署指南（中文）
- `README-zh.md`：GitHub 展示（中文）
- `README-en.md`：GitHub 展示（英文）
- `QUICK-START.md`：快速开始（中文）
- `HTTPS-SETUP.md`：HTTPS 配置（中文）
- `CHANGELOG.md`：更新日志（中文）

### 翻译文档

欢迎将文档翻译成其他语言！

1. 创建新的文档文件，如 `README-ja.md`（日语）
2. 在原文档开头添加语言切换链接
3. 提交 PR

### 行为准则

- 尊重所有贡献者
- 欢迎建设性的反馈
- 保持友好和专业
- 尊重不同的观点和经验

### 许可证

通过提交贡献，你同意你的贡献将按照 [MIT License](./LICENSE) 授权。

### 问题？

如有任何问题，欢迎：
- 创建 Issue 讨论
- 在现有 Issue 下评论

---

## English

### How to Contribute

We welcome all forms of contributions:

- 🐛 Report bugs
- 💡 Suggest new features
- 📝 Improve documentation
- 🔧 Submit code fixes or new features
- 🌐 Translate documentation

### Reporting Bugs

Before submitting a bug report, please search existing Issues to ensure the problem hasn't been reported.

When creating an Issue, please provide:

1. **Problem Description**: Clear and concise description
2. **Reproduction Steps**: Detailed steps to reproduce the issue
3. **Expected Behavior**: What you expected to happen
4. **Actual Behavior**: What actually happened
5. **Environment Info**:
   - Node.js version: `node -v`
   - npm version: `npm -v`
   - PM2 version: `pm2 -v`
   - OS: CentOS/Ubuntu/etc
   - Cloudflare SSL mode
6. **Logs**: Relevant error logs (`pm2 logs ai-api-proxy --err`)
7. **Screenshots** (if applicable)

### Suggesting Features

Before suggesting a new feature, please search existing Issues.

When creating an Issue, please explain:

1. **Feature Description**: What functionality you'd like to add
2. **Use Case**: What problem this feature solves
3. **Implementation Suggestion** (optional): How you think it could be implemented

### Submitting Code

#### Development Workflow

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/HgLiJiahao/ai-api-gateway.git
   cd ai-api-gateway
   ```
3. **Create feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Install dependencies**
   ```bash
   npm install
   ```
5. **Make changes**
   - Follow code style (see below)
   - Add necessary comments (Chinese or English)
   - Keep code clean and readable
6. **Test your changes**
   ```bash
   # Local testing
   node server.js
   
   # Or with PM2
   pm2 start ecosystem.config.js
   pm2 logs ai-api-proxy
   ```
7. **Commit changes**
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   ```
8. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
9. **Create Pull Request**

#### Code Style

- **Language**: JavaScript (Node.js)
- **Indentation**: 2 spaces
- **Comments**: Use Chinese or English, clearly explain logic
- **Naming**:
  - Variables/Functions: camelCase
  - Constants: UPPER_SNAKE_CASE
- **Functions**: Keep concise, single responsibility
- **Async**: Use `async/await` instead of Promise chains

**Example:**

```javascript
// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'Google API Proxy',
    timestamp: new Date().toISOString()
  });
});

// Proxy middleware
app.use('/', async (req, res) => {
  try {
    const requestId = Math.random().toString(36).substring(7);
    console.log(`[${requestId}] ${req.method} ${req.path}`);
    
    // Build target URL
    const targetUrl = `${TARGET_URL}${req.url}`;
    
    // ... more logic
  } catch (error) {
    console.error(`Error: ${error.message}`);
    res.status(500).json({ error: 'Proxy request failed' });
  }
});
```

#### Commit Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation updates
- `style`: Code formatting (no functional changes)
- `refactor`: Refactoring (neither feature nor fix)
- `perf`: Performance improvements
- `test`: Test-related
- `chore`: Build/tooling

**Example:**
```
feat(proxy): add request timeout configuration

- Support custom timeout duration
- Add timeout error handling
- Update documentation

Closes #123
```

#### Pull Request Checklist

Before submitting PR, ensure:

- [ ] Code follows project style guide
- [ ] Added necessary comments
- [ ] Local testing passed
- [ ] Updated relevant documentation (if applicable)
- [ ] Updated CHANGELOG.md (if applicable)
- [ ] Commit messages follow conventions
- [ ] PR description clearly explains changes

### Improving Documentation

Documentation improvements include:

- Fix spelling/grammar errors
- Improve clarity of explanations
- Add missing information
- Update outdated content
- Add example code

Documentation files:
- `README.md`: Full deployment guide (Chinese)
- `README-zh.md`: GitHub display (Chinese)
- `README-en.md`: GitHub display (English)
- `QUICK-START.md`: Quick start (Chinese)
- `HTTPS-SETUP.md`: HTTPS setup (Chinese)
- `CHANGELOG.md`: Changelog (Chinese)

### Translating Documentation

Translations to other languages are welcome!

1. Create new documentation file, e.g., `README-ja.md` (Japanese)
2. Add language switch links at the top of original docs
3. Submit PR

### Code of Conduct

- Respect all contributors
- Welcome constructive feedback
- Be friendly and professional
- Respect different viewpoints and experiences

### License

By submitting contributions, you agree that your contributions will be licensed under the [MIT License](./LICENSE).

### Questions?

If you have any questions:
- Create an Issue for discussion
- Comment on existing Issues

---

**Thank you for contributing! 感谢你的贡献！**

