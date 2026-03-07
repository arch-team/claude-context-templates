#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# check-plugin-sync.sh — 检查 plugin/presets/ 与主仓库 presets/ 的一致性
#
# 确保 Plugin 内的 preset 模板与主仓库保持同步，防止发布时出现不一致。
# 退出码：0 = 一致，1 = 不一致
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
echo -e "${BOLD}  Claude Context Templates — Plugin Sync Check${RESET}"
echo -e "${DIM}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# 检查源目录
if [[ ! -d "$SOURCE_DIR" ]]; then
    error "Presets 源目录不存在: ${SOURCE_DIR}"
    exit 1
fi

# 检查目标目录
if [[ ! -d "$TARGET_DIR" ]]; then
    error "Plugin presets 目录不存在: ${TARGET_DIR}"
    echo ""
    echo -e "  ${DIM}请先运行 ./scripts/build-plugin.sh 同步 presets。${RESET}"
    echo ""
    exit 1
fi

# 使用 diff 递归对比
info "对比 presets/ 与 plugin/presets/ ..."
echo ""

diff_output=$(diff -rq --exclude='.DS_Store' "$SOURCE_DIR" "$TARGET_DIR" 2>&1) || true

if [[ -z "$diff_output" ]]; then
    success "Plugin presets 与主仓库完全一致!"
    echo ""
    exit 0
fi

# 存在差异，输出详情
error "检测到不一致!"
echo ""

# 解析 diff 输出，分类显示
while IFS= read -r line; do
    if [[ "$line" == *"Only in ${SOURCE_DIR}"* ]]; then
        # 仅在源目录存在（plugin 缺失）
        file_info="${line#Only in }"
        echo -e "  ${RED}缺失${RESET} plugin/ 中: ${file_info}"
    elif [[ "$line" == *"Only in ${TARGET_DIR}"* ]]; then
        # 仅在目标目录存在（plugin 多余）
        file_info="${line#Only in }"
        echo -e "  ${YELLOW}多余${RESET} plugin/ 中: ${file_info}"
    elif [[ "$line" == *"differ"* ]]; then
        # 内容不同
        echo -e "  ${RED}内容不同${RESET} ${line}"
    fi
done <<< "$diff_output"

echo ""
echo -e "  ${BOLD}修复方法:${RESET} 运行 ${DIM}./scripts/build-plugin.sh${RESET} 重新同步 presets。"
echo ""

exit 1
