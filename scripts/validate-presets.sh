#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# validate-presets.sh - Preset 结构验证脚本
# 验证所有 preset 的文件完整性和双语一致性
# ============================================================

# 颜色定义（支持无颜色模式）
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  BOLD=''
  NC=''
fi

# 计数器
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# 定位项目根目录（脚本所在目录的上级）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PRESETS_DIR="${PROJECT_ROOT}/presets"

# ============================================================
# 工具函数
# ============================================================

pass() {
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  PASSED_CHECKS=$((PASSED_CHECKS + 1))
  printf "  ${GREEN}PASS${NC} %s\n" "$1"
}

fail() {
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
  printf "  ${RED}FAIL${NC} %s\n" "$1"
}

warn() {
  WARNINGS=$((WARNINGS + 1))
  printf "  ${YELLOW}WARN${NC} %s\n" "$1"
}

info() {
  printf "${BLUE}==>${NC} %s\n" "$1"
}

header() {
  printf "\n${BOLD}%s${NC}\n" "$1"
}

# 从 YAML 中提取 files.required 列表（纯 bash 实现，无需 yq）
# 解析 preset.yaml 中 required: 下的 "- xxx" 行，直到遇到非列表项
parse_required_files() {
  local yaml_file="$1"
  local in_required=0
  while IFS= read -r line; do
    # 检测 required: 标记
    if [[ "$line" =~ ^[[:space:]]+required:[[:space:]]*$ ]]; then
      in_required=1
      continue
    fi
    if [[ $in_required -eq 1 ]]; then
      # 匹配列表项 "    - xxx"
      if [[ "$line" =~ ^[[:space:]]+-[[:space:]]+(.*) ]]; then
        echo "${BASH_REMATCH[1]}"
      else
        # 遇到非列表项，退出 required 区域
        break
      fi
    fi
  done < "$yaml_file"
}

# 检查 YAML 中是否包含关键字段
check_yaml_field() {
  local yaml_file="$1"
  local field="$2"
  if grep -q "^${field}:" "$yaml_file" 2>/dev/null; then
    return 0
  else
    return 1
  fi
}

# 获取目录下所有文件的相对路径列表（已排序）
list_files_relative() {
  local base_dir="$1"
  if [[ ! -d "$base_dir" ]]; then
    return
  fi
  # 使用 find 并用 sed 去除前缀，兼容 macOS 和 Linux
  find "$base_dir" -type f | while IFS= read -r f; do
    # 去除 base_dir 前缀和开头的斜杠
    local rel="${f#"$base_dir"}"
    rel="${rel#/}"
    echo "$rel"
  done | sort
}

# ============================================================
# 验证单个 preset
# ============================================================

validate_preset() {
  local preset_dir="$1"
  local preset_name
  preset_name="$(basename "$preset_dir")"

  header "Preset: ${preset_name}"

  local yaml_file="${preset_dir}/preset.yaml"

  # --- 1. preset.yaml 存在性 ---
  if [[ -f "$yaml_file" ]]; then
    pass "preset.yaml 文件存在"
  else
    fail "preset.yaml 文件不存在"
    return
  fi

  # --- 2. preset.yaml 关键字段 ---
  local required_fields=("name" "version" "defaults" "files")
  for field in "${required_fields[@]}"; do
    if check_yaml_field "$yaml_file" "$field"; then
      pass "preset.yaml 包含字段: ${field}"
    else
      fail "preset.yaml 缺少字段: ${field}"
    fi
  done

  # --- 3. files.required 中列出的文件在 zh-CN/ 和 en/ 下都存在 ---
  local required_files
  required_files="$(parse_required_files "$yaml_file")"

  if [[ -z "$required_files" ]]; then
    warn "preset.yaml 中未找到 files.required 列表"
  else
    while IFS= read -r req_file; do
      # 检查 zh-CN/
      if [[ -f "${preset_dir}/zh-CN/${req_file}" ]]; then
        pass "zh-CN/${req_file} 存在"
      else
        fail "zh-CN/${req_file} 缺失（在 files.required 中声明）"
      fi
      # 检查 en/
      if [[ -f "${preset_dir}/en/${req_file}" ]]; then
        pass "en/${req_file} 存在"
      else
        fail "en/${req_file} 缺失（在 files.required 中声明）"
      fi
    done <<< "$required_files"
  fi

  # --- 4. CLAUDE.md 存在于两个语言目录 ---
  if [[ -f "${preset_dir}/zh-CN/CLAUDE.md" ]]; then
    pass "zh-CN/CLAUDE.md 存在"
  else
    fail "zh-CN/CLAUDE.md 缺失"
  fi

  if [[ -f "${preset_dir}/en/CLAUDE.md" ]]; then
    pass "en/CLAUDE.md 存在"
  else
    fail "en/CLAUDE.md 缺失"
  fi

  # --- 5. zh-CN/ 和 en/ 文件结构对称 ---
  validate_bilingual_symmetry "$preset_dir"
}

# ============================================================
# 验证 _common 目录
# ============================================================

validate_common() {
  local common_dir="${PRESETS_DIR}/_common"

  header "Common: _common"

  if [[ ! -d "$common_dir" ]]; then
    fail "_common 目录不存在"
    return
  fi

  pass "_common 目录存在"

  # zh-CN/ 和 en/ 文件结构对称
  validate_bilingual_symmetry "$common_dir"
}

# ============================================================
# 验证双语文件结构对称性
# ============================================================

validate_bilingual_symmetry() {
  local base_dir="$1"
  local dir_name
  dir_name="$(basename "$base_dir")"

  local zh_dir="${base_dir}/zh-CN"
  local en_dir="${base_dir}/en"

  # 检查两个语言目录是否存在
  if [[ ! -d "$zh_dir" ]]; then
    fail "${dir_name}: zh-CN/ 目录不存在"
    return
  fi

  if [[ ! -d "$en_dir" ]]; then
    fail "${dir_name}: en/ 目录不存在"
    return
  fi

  # 获取两个目录的文件列表
  local zh_files en_files
  zh_files="$(list_files_relative "$zh_dir")"
  en_files="$(list_files_relative "$en_dir")"

  # 找出 zh-CN 中有但 en 中没有的文件
  local has_diff=0
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    if ! echo "$en_files" | grep -qxF "$f"; then
      fail "文件仅在 zh-CN/ 中存在: ${f}"
      has_diff=1
    fi
  done <<< "$zh_files"

  # 找出 en 中有但 zh-CN 中没有的文件
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    if ! echo "$zh_files" | grep -qxF "$f"; then
      fail "文件仅在 en/ 中存在: ${f}"
      has_diff=1
    fi
  done <<< "$en_files"

  if [[ $has_diff -eq 0 ]]; then
    pass "zh-CN/ 和 en/ 文件结构完全对称"
  fi
}

# ============================================================
# 主流程
# ============================================================

main() {
  printf "\n${BOLD}========================================${NC}\n"
  printf "${BOLD}  Preset 结构验证${NC}\n"
  printf "${BOLD}========================================${NC}\n"

  # 检查 presets 目录
  if [[ ! -d "$PRESETS_DIR" ]]; then
    printf "\n${RED}错误: presets 目录不存在: ${PRESETS_DIR}${NC}\n"
    exit 1
  fi

  # 验证 _common
  validate_common

  # 遍历所有 preset（排除 _common）
  for preset_dir in "${PRESETS_DIR}"/*/; do
    # 去除末尾斜杠
    preset_dir="${preset_dir%/}"
    local preset_name
    preset_name="$(basename "$preset_dir")"

    # 跳过 _common
    [[ "$preset_name" == "_common" ]] && continue

    validate_preset "$preset_dir"
  done

  # ============================================================
  # 汇总结果
  # ============================================================

  printf "\n${BOLD}========================================${NC}\n"
  printf "${BOLD}  验证结果汇总${NC}\n"
  printf "${BOLD}========================================${NC}\n\n"
  printf "  检查总数:  %d\n" "$TOTAL_CHECKS"
  printf "  ${GREEN}通过:      %d${NC}\n" "$PASSED_CHECKS"
  printf "  ${RED}失败:      %d${NC}\n" "$FAILED_CHECKS"
  printf "  ${YELLOW}警告:      %d${NC}\n" "$WARNINGS"
  printf "\n"

  if [[ $FAILED_CHECKS -gt 0 ]]; then
    printf "${RED}${BOLD}验证失败！存在 %d 个错误需要修复。${NC}\n\n" "$FAILED_CHECKS"
    exit 1
  else
    printf "${GREEN}${BOLD}全部验证通过！${NC}\n\n"
    exit 0
  fi
}

main "$@"
