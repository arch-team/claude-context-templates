#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# build-plugin.sh — 将 presets/ 同步到 plugin/presets/
#
# 确保 Plugin 内的 preset 模板与主仓库的 presets/ 保持一致。
# 在发布 Plugin 前运行此脚本。
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="${ROOT_DIR}/presets"
TARGET_DIR="${ROOT_DIR}/plugin/presets"

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
echo -e "${BOLD}  Claude Context Templates — Plugin Build${RESET}"
echo -e "${DIM}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# 检查源目录
if [[ ! -d "$SOURCE_DIR" ]]; then
    error "Presets 源目录不存在: ${SOURCE_DIR}"
    exit 1
fi

# 检查 plugin 目录
if [[ ! -d "${ROOT_DIR}/plugin/.claude-plugin" ]]; then
    error "Plugin 目录结构不完整，请先创建 plugin/.claude-plugin/plugin.json"
    exit 1
fi

# 同步 presets
info "同步 presets/ → plugin/presets/ ..."
rsync -av --delete \
    --exclude='.DS_Store' \
    "${SOURCE_DIR}/" "${TARGET_DIR}/"

echo ""

# 统计
file_count=$(find "$TARGET_DIR" -type f -name "*.md" -o -name "*.yaml" | wc -l | tr -d ' ')
dir_count=$(find "$TARGET_DIR" -mindepth 1 -type d | wc -l | tr -d ' ')

success "同步完成!"
echo ""
echo -e "  ${DIM}文件数: ${file_count}${RESET}"
echo -e "  ${DIM}目录数: ${dir_count}${RESET}"
echo ""

# 验证 plugin 结构
info "验证 Plugin 结构 ..."

has_error=0

check_file() {
    local file="$1"
    local desc="$2"
    if [[ -f "$file" ]]; then
        echo -e "  ${GREEN}✓${RESET} ${desc}"
    else
        echo -e "  ${RED}✗${RESET} ${desc} ${RED}(缺失)${RESET}"
        has_error=1
    fi
}

check_dir() {
    local dir="$1"
    local desc="$2"
    if [[ -d "$dir" ]]; then
        echo -e "  ${GREEN}✓${RESET} ${desc}"
    else
        echo -e "  ${RED}✗${RESET} ${desc} ${RED}(缺失)${RESET}"
        has_error=1
    fi
}

check_file "${ROOT_DIR}/plugin/.claude-plugin/plugin.json" "plugin.json"
check_file "${ROOT_DIR}/plugin/commands/init-context.md" "commands/init-context.md"
check_file "${ROOT_DIR}/plugin/skills/context-setup/SKILL.md" "skills/context-setup/SKILL.md"
check_dir  "${TARGET_DIR}/_common" "presets/_common/"
check_dir  "${TARGET_DIR}/python-fastapi" "presets/python-fastapi/"
check_dir  "${TARGET_DIR}/react-typescript" "presets/react-typescript/"
check_dir  "${TARGET_DIR}/aws-cdk" "presets/aws-cdk/"

echo ""

if [[ $has_error -eq 0 ]]; then
    success "Plugin 结构验证通过!"
else
    error "Plugin 结构存在缺失项，请检查。"
    exit 1
fi

echo ""
echo -e "${BOLD}  Plugin 构建完成。${RESET}"
echo -e "  ${DIM}可通过本地 marketplace 测试: /plugin marketplace add ./plugin${RESET}"
echo ""
