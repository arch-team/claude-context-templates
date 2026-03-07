#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# release-plugin.sh — Plugin 版本发布流程
#
# 自动化 version bump → 构建 → 验证 → 提示手动 commit/tag
#
# 用法: ./scripts/release-plugin.sh <version>
# 示例: ./scripts/release-plugin.sh 1.1.0
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PLUGIN_JSON="${ROOT_DIR}/plugin/.claude-plugin/plugin.json"
MARKETPLACE_JSON="${ROOT_DIR}/plugin/.claude-plugin/marketplace.json"

# 颜色定义
if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    DIM='\033[2m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN='' BLUE='' YELLOW='' RED='' DIM='' BOLD='' RESET=''
fi

info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET} $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1" >&2; }

echo ""
echo -e "${BOLD}  Claude Context Templates — Plugin Release${RESET}"
echo -e "${DIM}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# ============================================================================
# 1. 参数验证
# ============================================================================

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
    error "请指定版本号"
    echo ""
    echo -e "  ${BOLD}用法:${RESET} ./scripts/release-plugin.sh <version>"
    echo -e "  ${BOLD}示例:${RESET} ./scripts/release-plugin.sh 1.1.0"
    echo ""
    exit 1
fi

# 验证 semver 格式
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error "版本号格式不正确: ${VERSION}"
    echo ""
    echo -e "  ${DIM}请使用 semver 格式: X.Y.Z（例如 1.1.0）${RESET}"
    echo ""
    exit 1
fi

info "目标版本: v${VERSION}"
echo ""

# ============================================================================
# 2. 工作区检查
# ============================================================================

info "检查 Git 工作区 ..."

if ! git -C "$ROOT_DIR" diff --quiet 2>/dev/null || ! git -C "$ROOT_DIR" diff --cached --quiet 2>/dev/null; then
    error "Git 工作区存在未提交的更改"
    echo ""
    echo -e "  ${DIM}请先提交或暂存当前更改，确保工作区干净后再执行发布。${RESET}"
    echo ""
    exit 1
fi

success "Git 工作区干净"
echo ""

# ============================================================================
# 3. 版本更新
# ============================================================================

info "更新版本号 ..."

# 读取当前版本
if [[ ! -f "$PLUGIN_JSON" ]]; then
    error "plugin.json 不存在: ${PLUGIN_JSON}"
    exit 1
fi

CURRENT_VERSION=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$PLUGIN_JSON" | head -1 | grep -o '"[^"]*"$' | tr -d '"')
info "当前版本: v${CURRENT_VERSION} → v${VERSION}"

# 更新 plugin.json
if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/\"version\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"version\": \"${VERSION}\"/" "$PLUGIN_JSON"
else
    sed -i "s/\"version\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"version\": \"${VERSION}\"/" "$PLUGIN_JSON"
fi
success "已更新 plugin.json"

# 更新 marketplace.json
if [[ -f "$MARKETPLACE_JSON" ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s/\"version\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"version\": \"${VERSION}\"/" "$MARKETPLACE_JSON"
    else
        sed -i "s/\"version\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"version\": \"${VERSION}\"/" "$MARKETPLACE_JSON"
    fi
    success "已更新 marketplace.json"
else
    warn "marketplace.json 不存在，跳过"
fi

echo ""

# ============================================================================
# 4. 构建
# ============================================================================

info "运行构建脚本 ..."
echo ""

"${SCRIPT_DIR}/build-plugin.sh"

echo ""

# ============================================================================
# 5. 一致性验证
# ============================================================================

info "验证 Plugin preset 一致性 ..."
echo ""

"${SCRIPT_DIR}/check-plugin-sync.sh"

echo ""

# ============================================================================
# 6. 结构验证
# ============================================================================

info "验证 Preset 结构完整性 ..."
echo ""

"${SCRIPT_DIR}/validate-presets.sh"

echo ""

# ============================================================================
# 7. 摘要输出
# ============================================================================

echo -e "${BOLD}  发布准备完成!${RESET}"
echo -e "${DIM}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${BOLD}版本:${RESET} v${CURRENT_VERSION} → v${VERSION}"
echo ""
echo -e "  ${BOLD}已更新文件:${RESET}"
echo -e "    - plugin/.claude-plugin/plugin.json"
[[ -f "$MARKETPLACE_JSON" ]] && echo -e "    - plugin/.claude-plugin/marketplace.json"
echo ""
echo -e "  ${BOLD}后续步骤（请手动执行）:${RESET}"
echo ""
echo -e "    ${DIM}# 1. 提交版本变更${RESET}"
echo -e "    git add -A"
echo -e "    git commit -m \"release(plugin): v${VERSION}\""
echo ""
echo -e "    ${DIM}# 2. 创建 Git tag${RESET}"
echo -e "    git tag -a \"plugin-v${VERSION}\" -m \"Plugin release v${VERSION}\""
echo ""
echo -e "    ${DIM}# 3. 推送到远程${RESET}"
echo -e "    git push origin main --tags"
echo ""
