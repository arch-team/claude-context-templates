#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Claude Context Templates - Remote Installer
#
# 远程安装脚本: 下载模板仓库并运行 init.sh，无需手动 git clone。
#
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/arch-team/claude-context-templates/main/install.sh | bash
#
# 或先下载再运行:
#   curl -fsSL https://raw.githubusercontent.com/arch-team/claude-context-templates/main/install.sh -o install.sh
#   bash install.sh
# ============================================================================

REPO_URL="https://github.com/arch-team/claude-context-templates"
REPO_BRANCH="main"
INSTALL_DIR=""

# --- 颜色定义 ---

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' DIM='' RESET=''
fi

info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET} $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1" >&2; }

# --- 依赖检查 ---

check_dependencies() {
    local missing=()

    if ! command -v git &>/dev/null; then
        missing+=("git")
    fi

    if ! command -v bash &>/dev/null; then
        missing+=("bash")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing[*]}"
        echo "Please install them and try again." >&2
        exit 1
    fi
}

# --- 清理函数 ---

cleanup() {
    if [[ -n "$INSTALL_DIR" ]] && [[ -d "$INSTALL_DIR" ]]; then
        rm -rf "$INSTALL_DIR"
    fi
}

trap cleanup EXIT INT TERM

# --- 主流程 ---

main() {
    echo ""
    echo -e "${CYAN}${BOLD}  Claude Context Templates - Remote Installer${RESET}"
    echo -e "${DIM}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""

    check_dependencies

    # 创建临时目录
    INSTALL_DIR=$(mktemp -d "${TMPDIR:-/tmp}/claude-ctx-XXXXXX")
    info "Downloading templates to temporary directory..."

    # 使用 git clone --depth 1 进行浅克隆（最小化下载量）
    if ! git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR" 2>/dev/null; then
        error "Failed to download templates from ${REPO_URL}"
        echo "Please check your network connection and try again." >&2
        exit 1
    fi

    success "Templates downloaded successfully."
    echo ""

    # 运行 init.sh（传递所有参数）
    bash "${INSTALL_DIR}/init.sh" "$@"
}

main "$@"
