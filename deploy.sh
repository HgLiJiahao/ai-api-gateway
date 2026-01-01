#!/bin/bash

##############################################
# AI API 代理服务 - 自动部署脚本
# 支持 API: Google Gemini, OpenAI, Claude
# 适用系统: CentOS 7+ / Ubuntu 18.04+ / macOS 10.14+
##############################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo "========================================"
    echo "$1"
    echo "========================================"
}

# 选择 API 类型
select_api_type() {
    print_header "选择 API 类型"
    
    echo ""
    echo "请选择要部署的 AI API 类型："
    echo ""
    echo "  1) Google Gemini API"
    echo "     - 目标: https://generativelanguage.googleapis.com"
    echo "     - 认证: x-goog-api-key"
    echo ""
    echo "  2) OpenAI API"
    echo "     - 目标: https://api.openai.com"
    echo "     - 认证: Authorization (Bearer Token)"
    echo ""
    echo "  3) Anthropic Claude API"
    echo "     - 目标: https://api.anthropic.com"
    echo "     - 认证: x-api-key + anthropic-version"
    echo ""
    
    while true; do
        read -p "请输入选择 [1-3]: " choice
        case $choice in
            1)
                API_TYPE="gemini"
                API_NAME="Google Gemini"
                TARGET_URL="https://generativelanguage.googleapis.com"
                break
                ;;
            2)
                API_TYPE="openai"
                API_NAME="OpenAI"
                TARGET_URL="https://api.openai.com"
                break
                ;;
            3)
                API_TYPE="claude"
                API_NAME="Anthropic Claude"
                TARGET_URL="https://api.anthropic.com"
                break
                ;;
            *)
                print_error "无效的选择，请输入 1-3"
                ;;
        esac
    done
    
    echo ""
    print_info "已选择: ${BLUE}$API_NAME${NC}"
    print_info "API 类型: $API_TYPE"
    print_info "目标地址: $TARGET_URL"
    echo ""
    
    read -p "确认继续部署？[Y/n] " confirm
    if [[ $confirm =~ ^[Nn]$ ]]; then
        print_warn "部署已取消"
        exit 0
    fi
}

# 更新 PM2 配置
update_pm2_config() {
    print_header "更新 PM2 配置"
    
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    CONFIG_FILE="$SCRIPT_DIR/ecosystem.config.js"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "找不到配置文件: $CONFIG_FILE"
        exit 1
    fi
    
    print_info "更新 API_TYPE 为: $API_TYPE"
    
    # 使用 sed 更新 API_TYPE（兼容 macOS 和 Linux）
    if [ "$OS" = "macos" ]; then
        sed -i '' "s/API_TYPE: '[^']*'/API_TYPE: '$API_TYPE'/" "$CONFIG_FILE"
    else
        sed -i "s/API_TYPE: '[^']*'/API_TYPE: '$API_TYPE'/" "$CONFIG_FILE"
    fi
    
    print_info "PM2 配置已更新"
}

# 检查是否为 root 用户
check_root() {
    # macOS 开发环境可以不需要 root
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_warn "macOS 系统检测到，部分操作可能需要 sudo 权限"
        return 0
    fi
    
    if [ "$EUID" -ne 0 ]; then 
        print_error "请使用 root 用户运行此脚本（或使用 sudo）"
        exit 1
    fi
}

# 检测操作系统
detect_os() {
    # 检测 macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        VERSION=$(sw_vers -productVersion)
        print_info "检测到操作系统: macOS $VERSION"
        return 0
    fi
    
    # 检测 Linux
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        print_info "检测到操作系统: $OS $VERSION"
    else
        print_error "无法检测操作系统"
        exit 1
    fi
}

# 安装 Node.js
install_nodejs() {
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v)
        print_info "Node.js 已安装: $NODE_VERSION"
        return 0
    fi

    print_header "安装 Node.js"
    
    if [ "$OS" = "macos" ]; then
        # macOS
        print_info "正在为 macOS 安装 Node.js..."
        
        # 检查 Homebrew
        if ! command -v brew &> /dev/null; then
            print_info "Homebrew 未安装，正在安装 Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        print_info "使用 Homebrew 安装 Node.js..."
        brew install node
        
    elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        # CentOS/RHEL
        print_info "正在为 CentOS/RHEL 安装 Node.js 16..."
        curl -sL https://rpm.nodesource.com/setup_16.x | bash -
        yum install -y nodejs
    elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        # Ubuntu/Debian
        print_info "正在为 Ubuntu/Debian 安装 Node.js 16..."
        curl -sL https://deb.nodesource.com/setup_16.x | bash -
        apt-get install -y nodejs
    else
        print_error "不支持的操作系统: $OS"
        exit 1
    fi

    # 验证安装
    if command -v node &> /dev/null; then
        print_info "Node.js 安装成功: $(node -v)"
        print_info "npm 版本: $(npm -v)"
    else
        print_error "Node.js 安装失败"
        exit 1
    fi
}

# 安装 PM2
install_pm2() {
    if command -v pm2 &> /dev/null; then
        PM2_VERSION=$(pm2 -v)
        print_info "PM2 已安装: $PM2_VERSION"
        return 0
    fi

    print_header "安装 PM2"
    npm install -g pm2
    
    # 刷新命令缓存
    hash -r 2>/dev/null || true
    
    # 等待一秒，确保安装完成
    sleep 1
    
    # 检测 PM2 是否安装成功
    if command -v pm2 &> /dev/null; then
        print_info "PM2 安装成功: $(pm2 -v)"
    elif [ -f "/usr/local/bin/pm2" ]; then
        # 如果 pm2 在标准路径但未在 PATH 中，添加到 PATH
        export PATH="/usr/local/bin:$PATH"
        print_info "PM2 安装成功: $(pm2 -v)"
    else
        print_error "PM2 安装失败"
        print_error "请尝试手动安装: npm install -g pm2"
        exit 1
    fi
}

# 配置防火墙
configure_firewall() {
    print_header "配置防火墙"

    if [ "$OS" = "macos" ]; then
        # macOS
        print_info "macOS 系统检测到"
        print_warn "macOS 防火墙配置："
        print_warn "  - 系统偏好设置 → 安全性与隐私 → 防火墙"
        print_warn "  - 如果启用了防火墙，需要允许 Node 应用接入网络"
        print_warn "  - 开发环境通常可以跳过此步骤"
        return 0
    fi

    if command -v firewall-cmd &> /dev/null; then
        # CentOS firewalld
        if systemctl is-active --quiet firewalld; then
            print_info "配置 firewalld..."
            firewall-cmd --permanent --add-service=https
            firewall-cmd --reload
            print_info "firewalld 配置完成"
        else
            print_warn "firewalld 未运行，跳过防火墙配置"
        fi
    elif command -v ufw &> /dev/null; then
        # Ubuntu ufw
        print_info "配置 ufw..."
        ufw allow 443/tcp
        print_info "ufw 配置完成"
    else
        print_warn "未检测到防火墙管理工具，请手动开放 443 端口"
    fi
}

# 部署应用
deploy_app() {
    print_header "部署应用"
    
    # 获取当前脚本所在目录
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    print_info "项目目录: $SCRIPT_DIR"
    
    cd "$SCRIPT_DIR"
    
    # 检查必需文件
    print_info "检查必需文件..."
    REQUIRED_FILES=("server.js" "package.json" "ecosystem.config.js")
    for file in "${REQUIRED_FILES[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "缺少必需文件: $file"
            exit 1
        fi
        print_info "✓ $file"
    done

    # 检查证书文件
    print_info "检查 SSL 证书..."
    if [ ! -f "certs/cert.pem" ] || [ ! -f "certs/key.pem" ]; then
        print_error "缺少 SSL 证书文件，请先配置 certs/cert.pem 和 certs/key.pem"
        print_info "参考文档: HTTPS-SETUP.md"
        exit 1
    fi
    print_info "✓ certs/cert.pem"
    print_info "✓ certs/key.pem"

    # 设置证书权限
    chmod 600 certs/key.pem
    chmod 644 certs/cert.pem
    print_info "证书权限已设置"
    
    # 创建日志目录
    mkdir -p logs
    print_info "日志目录已创建"
    
    # 安装依赖
    print_info "安装 npm 依赖..."
    npm install
    print_info "npm 依赖安装完成"
    
    # 停止旧服务（如果存在）
    if pm2 list | grep -q "ai-api-proxy"; then
        print_info "停止旧服务..."
        pm2 delete ai-api-proxy || true
    fi
    
    # 启动服务
    print_info "启动服务..."
    pm2 start ecosystem.config.js
    
    # 保存 PM2 配置
    pm2 save
    
    # 设置开机自启
    print_info "配置开机自启..."
    if [ "$OS" = "macos" ]; then
        pm2 startup launchd
    else
        pm2 startup systemd -u root --hp /root
    fi
    
    print_info "应用部署完成"
}

# 验证部署
verify_deployment() {
    print_header "验证部署"

    # 等待服务启动
    sleep 3

    # 检查 PM2 状态
    print_info "PM2 服务状态:"
    pm2 list

    # 检查端口
    print_info "检查 443 端口..."
    if ss -tlnp | grep -q ":443"; then
        print_info "✓ 443 端口已监听"
    else
        print_error "✗ 443 端口未监听"
        return 1
    fi

    # 健康检查
    print_info "执行健康检查..."
    HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" https://localhost/health)
    if [ "$HTTP_CODE" = "200" ]; then
        print_info "✓ 健康检查通过 (HTTP $HTTP_CODE)"
        echo ""
        print_info "服务响应:"
        curl -sk https://localhost/health | python -m json.tool 2>/dev/null || curl -sk https://localhost/health
    else
        print_error "✗ 健康检查失败 (HTTP $HTTP_CODE)"
        return 1
    fi
}

# 打印部署信息
print_deployment_info() {
    print_header "部署信息"

    # 获取服务器 IP
    SERVER_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || echo "未知")

    echo ""
    echo "部署成功！"
    echo ""
    echo "服务信息："
    echo "   - 服务名称: ai-api-proxy"
    echo "   - API 类型: $API_NAME ($API_TYPE)"
    echo "   - 目标地址: $TARGET_URL"
    echo "   - 监听端口: 443 (HTTPS)"
    echo "   - 服务器 IP: $SERVER_IP"
    echo "   - 项目目录: $(pwd)"
    echo ""
    echo "访问地址："
    echo "   - 本地测试: curl -k https://localhost/health"
    echo "   - 域名访问: https://your-domain.com/health (需配置 DNS)"
    echo ""
    
    if [ "$API_TYPE" = "gemini" ]; then
        echo "API 使用示例 (Gemini)："
        echo "   curl -X POST https://your-domain.com/v1beta/models/gemini-2.0-flash-exp:generateContent \\"
        echo "     -H \"Content-Type: application/json\" \\"
        echo "     -H \"x-goog-api-key: YOUR_API_KEY\" \\"
        echo "     -d '{\"contents\":[{\"parts\":[{\"text\":\"Hello\"}]}]}'"
    elif [ "$API_TYPE" = "openai" ]; then
        echo "API 使用示例 (OpenAI)："
        echo "   curl -X POST https://your-domain.com/v1/chat/completions \\"
        echo "     -H \"Content-Type: application/json\" \\"
        echo "     -H \"Authorization: Bearer YOUR_API_KEY\" \\"
        echo "     -d '{\"model\":\"gpt-4\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}'"
    elif [ "$API_TYPE" = "claude" ]; then
        echo "API 使用示例 (Claude)："
        echo "   curl -X POST https://your-domain.com/v1/messages \\"
        echo "     -H \"Content-Type: application/json\" \\"
        echo "     -H \"x-api-key: YOUR_API_KEY\" \\"
        echo "     -H \"anthropic-version: 2023-06-01\" \\"
        echo "     -d '{\"model\":\"claude-3-opus-20240229\",\"max_tokens\":1024,\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}'"
    fi
    
    echo ""
    echo "常用命令："
    echo "   - 查看状态: pm2 list"
    echo "   - 查看日志: pm2 logs ai-api-proxy"
    echo "   - 重启服务: pm2 delete ai-api-proxy && pm2 start ecosystem.config.js"
    echo "   - 停止服务: pm2 stop ai-api-proxy"
    echo "   - 实时监控: pm2 monit"
    echo ""
    echo "Cloudflare 配置："
    echo "   1. 添加 DNS A 记录: @ → $SERVER_IP"
    echo "   2. 启用代理（橙云）"
    echo "   3. SSL/TLS 模式: Full (Strict)"
    echo "   4. 云服务商安全组: 开放 TCP 443 端口"
    echo ""
    echo "完整文档: $(pwd)/README.md"
    echo "HTTPS 配置: $(pwd)/HTTPS-SETUP.md"
    echo ""
}

# 主函数
main() {
    print_header "AI API 代理服务 - 自动部署"
    
    check_root
    select_api_type
    detect_os
    install_nodejs
    install_pm2
    update_pm2_config
    configure_firewall
    deploy_app
    
    if verify_deployment; then
        print_deployment_info
    else
        print_error "部署验证失败，请检查日志: pm2 logs ai-api-proxy"
        exit 1
    fi
}

# 执行主函数
main "$@"

