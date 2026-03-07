#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# validate-generated.sh - 生成后验证脚本
# 验证 init.sh 生成的 .claude/ 目录的完整性和正确性
#
# 用法: scripts/validate-generated.sh <target-directory> [preset-id]
# ============================================================

# 颜色定义（支持无颜色模式）
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  DIM='\033[2m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  CYAN=''
  BOLD=''
  DIM=''
  NC=''
fi

# 计数器
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0
TODO_COUNT=0

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
  printf "  ${GREEN}[PASS]${NC} %s\n" "$1"
}

fail() {
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
  printf "  ${RED}[FAIL]${NC} %s\n" "$1"
}

warn() {
  WARNINGS=$((WARNINGS + 1))
  printf "  ${YELLOW}[WARN]${NC} %s\n" "$1"
}

info() {
  printf "  ${CYAN}[INFO]${NC} %s\n" "$1"
}

section() {
  printf "\n${BLUE}[CHECK]${NC} %s\n" "$1"
}

usage() {
  cat <<EOF
用法: $(basename "$0") <target-directory> [preset-id]

参数:
  target-directory  包含生成的 .claude/ 的目录
  preset-id         可选，preset 标识符 (python-fastapi, react-typescript, aws-cdk)
                    如果提供，则额外检查 preset 特定的 required 文件

示例:
  $(basename "$0") /path/to/my-project
  $(basename "$0") /path/to/my-project python-fastapi
EOF
  exit 1
}

# 从 preset.yaml 中提取 files.required 列表（纯 bash 实现）
# 复用 validate-presets.sh 的解析逻辑
parse_required_files() {
  local yaml_file="$1"
  local in_required=0
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]+required:[[:space:]]*$ ]]; then
      in_required=1
      continue
    fi
    if [[ $in_required -eq 1 ]]; then
      if [[ "$line" =~ ^[[:space:]]+-[[:space:]]+(.*) ]]; then
        echo "${BASH_REMATCH[1]}"
      else
        break
      fi
    fi
  done < "$yaml_file"
}

# ============================================================
# 检查 1: 必需文件存在性
# ============================================================

check_required_files() {
  local target_dir="$1"
  local preset_id="${2:-}"
  local claude_dir="${target_dir}/.claude"

  section "Required files..."

  # CLAUDE.md 始终必须存在
  if [[ -f "${claude_dir}/CLAUDE.md" ]]; then
    pass ".claude/CLAUDE.md"
  else
    fail ".claude/CLAUDE.md (missing)"
  fi

  # 如果指定了 preset-id，检查 preset 的 required 文件
  if [[ -n "$preset_id" ]]; then
    local yaml_file="${PRESETS_DIR}/${preset_id}/preset.yaml"
    if [[ ! -f "$yaml_file" ]]; then
      warn "Preset '${preset_id}' 的 preset.yaml 不存在: ${yaml_file}"
      return
    fi

    local required_files
    required_files="$(parse_required_files "$yaml_file")"

    if [[ -z "$required_files" ]]; then
      warn "Preset '${preset_id}' 的 preset.yaml 中未找到 files.required 列表"
      return
    fi

    while IFS= read -r req_file; do
      [[ -z "$req_file" ]] && continue
      # CLAUDE.md 已经检查过
      [[ "$req_file" == "CLAUDE.md" ]] && continue

      if [[ -f "${claude_dir}/${req_file}" ]]; then
        pass ".claude/${req_file}"
      else
        fail ".claude/${req_file} (missing)"
      fi
    done <<< "$required_files"
  fi
}

# ============================================================
# 检查 2: 无残留占位符
# ============================================================

check_placeholders() {
  local target_dir="$1"
  local claude_dir="${target_dir}/.claude"

  section "Placeholder residuals..."

  local found_any=0

  # 查找所有 .md 文件并扫描 {{VARIABLE}} 占位符
  while IFS= read -r md_file; do
    [[ -z "$md_file" ]] && continue
    local line_num=0
    while IFS= read -r line; do
      line_num=$((line_num + 1))
      # 匹配 {{VARIABLE_NAME}} 模式
      if [[ "$line" =~ \{\{[A-Z_]+\}\} ]]; then
        local display_path="${md_file#"$target_dir"/}"
        fail "${display_path}:${line_num} - 残留占位符: ${BASH_REMATCH[0]}"
        found_any=1
      fi
    done < "$md_file"
  done < <(find "$claude_dir" -name "*.md" -type f 2>/dev/null || true)

  if [[ $found_any -eq 0 ]]; then
    pass "No unreplaced placeholders found"
  fi
}

# ============================================================
# 检查 3: 相对链接有效性
# ============================================================

check_links() {
  local target_dir="$1"
  local claude_dir="${target_dir}/.claude"

  section "Link validity..."

  local found_any=0
  local link_count=0

  while IFS= read -r md_file; do
    [[ -z "$md_file" ]] && continue
    local md_dir
    md_dir="$(dirname "$md_file")"
    local display_path="${md_file#"$target_dir"/}"
    local line_num=0

    while IFS= read -r line; do
      line_num=$((line_num + 1))

      # 提取 Markdown 链接: [text](path)
      # 将正则存入变量避免 bash 解析括号问题
      local link_regex='\[([^]]*)\]\(([^)]+)\)'
      while [[ "$line" =~ $link_regex ]]; do
        local link_target="${BASH_REMATCH[2]}"
        # 从原始行中移除已匹配的部分，继续查找下一个链接
        line="${line#*"${BASH_REMATCH[0]}"}"

        # 跳过外部链接
        [[ "$link_target" =~ ^https?:// ]] && continue
        # 跳过纯锚点链接
        [[ "$link_target" =~ ^# ]] && continue

        # 去除锚点部分
        local path_part="${link_target%%#*}"
        [[ -z "$path_part" ]] && continue

        link_count=$((link_count + 1))

        # 解析相对路径
        local resolved_path="${md_dir}/${path_part}"
        if [[ ! -e "$resolved_path" ]]; then
          warn "${display_path}:${line_num} - broken link: ${link_target}"
          found_any=1
        fi
      done
    done < "$md_file"
  done < <(find "$claude_dir" -name "*.md" -type f 2>/dev/null || true)

  if [[ $found_any -eq 0 ]]; then
    if [[ $link_count -gt 0 ]]; then
      pass "All ${link_count} relative links valid"
    else
      pass "No relative links to check"
    fi
  fi
}

# ============================================================
# 检查 4: TODO 标记统计
# ============================================================

check_todos() {
  local target_dir="$1"
  local claude_dir="${target_dir}/.claude"

  section "TODO markers..."

  TODO_COUNT=0

  while IFS= read -r md_file; do
    [[ -z "$md_file" ]] && continue
    local display_path="${md_file#"$target_dir"/}"
    local line_num=0

    while IFS= read -r line; do
      line_num=$((line_num + 1))
      if [[ "$line" == *"<!-- TODO:"* ]]; then
        TODO_COUNT=$((TODO_COUNT + 1))
      fi
    done < "$md_file"
  done < <(find "$claude_dir" -name "*.md" -type f 2>/dev/null || true)

  if [[ $TODO_COUNT -gt 0 ]]; then
    info "Found ${TODO_COUNT} TODO markers (user action required)"
  else
    info "No TODO markers found"
  fi
}

# ============================================================
# 主流程
# ============================================================

main() {
  # 参数检查
  if [[ $# -lt 1 ]]; then
    usage
  fi

  local target_dir="$1"
  local preset_id="${2:-}"

  # 验证目标目录存在
  if [[ ! -d "$target_dir" ]]; then
    printf "\n${RED}错误: 目标目录不存在: ${target_dir}${NC}\n"
    exit 1
  fi

  # 验证 .claude/ 目录存在
  if [[ ! -d "${target_dir}/.claude" ]]; then
    printf "\n${RED}错误: 目标目录中不存在 .claude/ 目录: ${target_dir}${NC}\n"
    exit 1
  fi

  printf "\n${BOLD}========================================${NC}\n"
  printf "${BOLD}  生成结果验证${NC}\n"
  printf "${BOLD}========================================${NC}\n"
  printf "\n  目标目录: ${DIM}${target_dir}${NC}\n"
  if [[ -n "$preset_id" ]]; then
    printf "  Preset:   ${DIM}${preset_id}${NC}\n"
  fi

  # 执行各项检查
  check_required_files "$target_dir" "$preset_id"
  check_placeholders "$target_dir"
  check_links "$target_dir"
  check_todos "$target_dir"

  # ============================================================
  # 汇总结果
  # ============================================================

  printf "\n${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
  printf "  Results: ${GREEN}%d passed${NC}, ${RED}%d failed${NC}, ${YELLOW}%d warning${NC}\n" \
    "$PASSED_CHECKS" "$FAILED_CHECKS" "$WARNINGS"
  printf "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"

  if [[ $FAILED_CHECKS -gt 0 ]]; then
    printf "${RED}${BOLD}验证失败！存在 %d 个错误需要修复。${NC}\n\n" "$FAILED_CHECKS"
    exit 1
  else
    printf "${GREEN}${BOLD}全部验证通过！${NC}\n\n"
    exit 0
  fi
}

main "$@"
