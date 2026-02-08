#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# check-links.sh - Markdown 相对链接检查脚本
# 遍历项目中所有 .md 文件，验证相对链接目标是否存在
# ============================================================

# 颜色定义（支持无颜色模式）
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BOLD=''
  NC=''
fi

# 计数器
TOTAL_LINKS=0
BROKEN_LINKS=0
CHECKED_FILES=0

# 定位项目根目录（脚本所在目录的上级）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ============================================================
# 工具函数
# ============================================================

pass() {
  printf "  ${GREEN}PASS${NC} %s -> %s\n" "$1" "$2"
}

fail() {
  printf "  ${RED}FAIL${NC} %s -> %s\n" "$1" "$2"
}

# ============================================================
# 检查单个 Markdown 文件中的相对链接
# ============================================================

check_file_links() {
  local md_file="$1"
  local md_dir
  md_dir="$(dirname "$md_file")"

  # 计算相对于项目根的显示路径
  local display_path="${md_file#"$PROJECT_ROOT"/}"

  local file_has_links=0
  local file_broken=0

  # 提取 Markdown 链接: [text](path)
  # 排除:
  #   - http:// 和 https:// 开头的外部链接
  #   - # 开头的纯锚点链接
  #   - 空链接
  while IFS= read -r link_target; do
    # 跳过空结果
    [[ -z "$link_target" ]] && continue

    # 去除锚点部分 (例如 file.md#section -> file.md)
    local path_part="${link_target%%#*}"

    # 如果去除锚点后为空，说明是纯锚点链接 (#section)，跳过
    [[ -z "$path_part" ]] && continue

    file_has_links=1
    TOTAL_LINKS=$((TOTAL_LINKS + 1))

    # 解析相对路径（相对于链接所在文件的目录）
    local resolved_path="${md_dir}/${path_part}"

    # 检查目标是否存在（文件或目录）
    if [[ -e "$resolved_path" ]]; then
      pass "$display_path" "$link_target"
    else
      fail "$display_path" "$link_target"
      BROKEN_LINKS=$((BROKEN_LINKS + 1))
      file_broken=1
    fi
  done < <(
    # 先去除代码块包裹的内容，再提取链接目标
    # 排除 http/https 外部链接和纯锚点链接
    sed -n '/^[[:space:]]*\x60\x60\x60/,/^[[:space:]]*\x60\x60\x60/!p' "$md_file" 2>/dev/null \
      | grep -oE '\[([^]]*)\]\(([^)]+)\)' \
      | sed -E 's/\[([^]]*)\]\(([^)]+)\)/\2/' \
      | grep -v '^https\?://' \
      | grep -v '^#' \
      || true
  )

  if [[ $file_has_links -eq 1 ]]; then
    CHECKED_FILES=$((CHECKED_FILES + 1))
  fi

  return 0
}

# ============================================================
# 主流程
# ============================================================

main() {
  printf "\n${BOLD}========================================${NC}\n"
  printf "${BOLD}  Markdown 相对链接检查${NC}\n"
  printf "${BOLD}========================================${NC}\n\n"

  # 查找所有 .md 文件
  # 排除：.git、node_modules、.venv、examples/（示例只含入口文件，引用的 rules 未创建）、
  #       presets/（模板中的相对链接只在生成后才有效）
  local md_files
  md_files=$(find "$PROJECT_ROOT" \
    -name "*.md" \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/.venv/*" \
    -not -path "*/examples/*" \
    -not -path "*/presets/*" \
    -type f | sort)

  if [[ -z "$md_files" ]]; then
    printf "${YELLOW}未找到任何 .md 文件${NC}\n"
    exit 0
  fi

  while IFS= read -r md_file; do
    check_file_links "$md_file"
  done <<< "$md_files"

  # ============================================================
  # 汇总结果
  # ============================================================

  printf "\n${BOLD}========================================${NC}\n"
  printf "${BOLD}  检查结果汇总${NC}\n"
  printf "${BOLD}========================================${NC}\n\n"
  printf "  含链接的文件数:  %d\n" "$CHECKED_FILES"
  printf "  检查链接总数:    %d\n" "$TOTAL_LINKS"
  printf "  ${GREEN}有效链接:        %d${NC}\n" "$((TOTAL_LINKS - BROKEN_LINKS))"
  printf "  ${RED}断链数量:        %d${NC}\n" "$BROKEN_LINKS"
  printf "\n"

  if [[ $BROKEN_LINKS -gt 0 ]]; then
    printf "${RED}${BOLD}检查失败！发现 %d 个断链需要修复。${NC}\n\n" "$BROKEN_LINKS"
    exit 1
  else
    printf "${GREEN}${BOLD}所有链接检查通过！${NC}\n\n"
    exit 0
  fi
}

main "$@"
