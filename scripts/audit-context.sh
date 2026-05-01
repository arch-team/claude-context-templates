#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# audit-context.sh - .claude/ 上下文质量审计工具
#
# 用法:
#   audit-context.sh [--target <dir>] [--json <out.json>] [--strict]
#
# 参数:
#   --target <dir>   要审计的目录 (默认: 当前目录)
#                    会自动检测 .claude/ 或作为 Monorepo 遍历子目录
#   --json <file>    额外输出机器可读的 JSON 报告
#   --strict         将 WARN 提升为 ERROR (用于 CI 严格模式)
#
# 退出码:
#   0 - 无 ERROR (可能有 WARN/INFO)
#   1 - 存在 ERROR
#   2 - 参数或环境问题
# ============================================================

# 颜色
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
  BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; BOLD=''; NC=''
fi

# 参数解析
TARGET="."
JSON_OUT=""
STRICT=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --json)   JSON_OUT="$2"; shift 2 ;;
    --strict) STRICT=1; shift ;;
    -h|--help)
      sed -n '4,17p' "$0" | sed 's/^# //; s/^#//'; exit 0 ;;
    *) echo "未知参数: $1" >&2; exit 2 ;;
  esac
done

if [[ ! -d "$TARGET" ]]; then
  echo "目标目录不存在: $TARGET" >&2; exit 2
fi
TARGET="$(cd "$TARGET" && pwd)"

# 计数器
ERRORS=0
WARNS=0
INFOS=0

# JSON 累积 (简单 tsv 到结束拼装)
FINDINGS="$(mktemp)"
trap 'rm -f "$FINDINGS"' EXIT

add_finding() {
  local severity="$1" file="$2" rule="$3" msg="$4"
  # 输出到终端
  case "$severity" in
    ERROR)
      printf "  ${RED}ERROR${NC} [%s] %s: %s\n" "$rule" "$file" "$msg"
      ERRORS=$((ERRORS + 1))
      ;;
    WARN)
      printf "  ${YELLOW}WARN${NC}  [%s] %s: %s\n" "$rule" "$file" "$msg"
      WARNS=$((WARNS + 1))
      if [[ $STRICT -eq 1 ]]; then ERRORS=$((ERRORS + 1)); fi
      ;;
    INFO)
      printf "  ${BLUE}INFO${NC}  [%s] %s: %s\n" "$rule" "$file" "$msg"
      INFOS=$((INFOS + 1))
      ;;
  esac
  # 写入 findings (tab 分隔)
  printf "%s\t%s\t%s\t%s\n" "$severity" "$rule" "$file" "$msg" >> "$FINDINGS"
}

# ============================================================
# 检查单个 .claude/ 目录
# ============================================================

audit_claude_dir() {
  local claude_dir="$1"
  local label="${claude_dir#$TARGET/}"
  [[ "$label" == "$TARGET" ]] && label=".claude"

  printf "\n${BOLD}审计: %s${NC}\n" "$label"

  if [[ ! -d "$claude_dir" ]]; then
    add_finding ERROR "$label" "STRUCT_001" ".claude/ 目录不存在"
    return
  fi

  # ------ 1. 残留占位符检查 ------
  local files
  files=$(find "$claude_dir" -type f -name "*.md")

  if [[ -n "$files" ]]; then
    while IFS= read -r f; do
      local rel="${f#$claude_dir/}"

      # 检查 {{AI_GENERATED:xxx}} 残留
      if grep -q '{{AI_GENERATED:' "$f" 2>/dev/null; then
        local count
        count=$(grep -c '{{AI_GENERATED:' "$f")
        add_finding ERROR "$rel" "PLACEHOLDER_AI" "含 $count 处未替换的 {{AI_GENERATED:...}} 占位符"
      fi

      # 检查 {{UPPER_SNAKE_CASE}} 残留 (排除代码块内的 JSX/YAML)
      # 用 awk 识别代码块, 只在普通正文中检查
      local bad_ph
      bad_ph=$(awk '
        /^```/ { in_code = !in_code; next }
        !in_code {
          while (match($0, /\{\{[A-Z][A-Z0-9_]*\}\}/)) {
            print substr($0, RSTART, RLENGTH)
            $0 = substr($0, RSTART + RLENGTH)
          }
        }
      ' "$f" | sort -u | tr '\n' ' ')

      if [[ -n "$bad_ph" ]]; then
        add_finding ERROR "$rel" "PLACEHOLDER_RAW" "含未替换占位符: $bad_ph"
      fi
    done <<< "$files"
  fi

  # ------ 2. 文件行数范围 ------
  if [[ -d "$claude_dir/rules" ]]; then
    while IFS= read -r f; do
      local rel="${f#$claude_dir/}"
      local lines
      lines=$(wc -l < "$f" | tr -d ' ')
      if [[ $lines -lt 30 ]]; then
        add_finding WARN "$rel" "FILE_LEN_MIN" "文件过短 (${lines} 行 < 30), 内容可能空洞"
      elif [[ $lines -gt 500 ]]; then
        add_finding WARN "$rel" "FILE_LEN_MAX" "文件过长 (${lines} 行 > 500), 难以维护"
      fi
    done < <(find "$claude_dir/rules" -maxdepth 1 -type f -name "*.md" 2>/dev/null)
  fi

  # ------ 3. Section 0 速查卡片 ------
  if [[ -d "$claude_dir/rules" ]]; then
    while IFS= read -r f; do
      local rel="${f#$claude_dir/}"
      # rules/*.md 推荐包含 ## 0. 或 ## 速查 开头的章节
      if ! grep -qE '^## (0\.|速查|Quick)' "$f" 2>/dev/null; then
        add_finding INFO "$rel" "QUICK_REF" "建议添加 Section 0 速查卡片 (## 0. 速查 或类似标题)"
      fi
    done < <(find "$claude_dir/rules" -maxdepth 1 -type f -name "*.md" 2>/dev/null)
  fi

  # ------ 4. Markdown 链接有效性 ------
  if [[ -n "$files" ]]; then
    while IFS= read -r f; do
      local rel="${f#$claude_dir/}"
      local file_dir
      file_dir="$(dirname "$f")"

      # 提取形如 [text](./path.md) 或 [text](../path.md) 或 [text](path.md) 的相对链接
      # 排除 http(s):// 开头的外链
      while IFS= read -r link; do
        [[ -z "$link" ]] && continue
        # 去锚点 #xxx
        local link_path="${link%%#*}"
        [[ -z "$link_path" ]] && continue
        # 只检查以 .md 结尾的
        [[ "$link_path" != *.md ]] && continue
        # 拼出绝对路径并规范化
        local abs
        if [[ "$link_path" == /* ]]; then
          abs="$link_path"
        else
          abs="$file_dir/$link_path"
        fi
        # 规范化 (../ ./)
        local normalized=""
        if [[ -d "$(dirname "$abs")" ]]; then
          normalized="$(cd "$(dirname "$abs")" && pwd)/$(basename "$abs")"
        fi
        if [[ -n "$normalized" ]] && [[ ! -f "$normalized" ]]; then
          add_finding WARN "$rel" "BROKEN_LINK" "链接指向不存在的文件: $link"
        fi
      done < <(grep -oE '\]\([^)]+\.md[^)]*\)' "$f" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//' || true)
    done <<< "$files"
  fi

  # ------ 5. TODO 标记数量 (INFO) ------
  local todo_count=0
  todo_count=$(grep -r '<!-- TODO' "$claude_dir" 2>/dev/null | wc -l | tr -d ' \n' || echo 0)
  # 兼容 wc 输出多行的情况, 确保 todo_count 是单个数字
  todo_count="${todo_count:-0}"
  if [[ "$todo_count" =~ ^[0-9]+$ ]] && [[ "$todo_count" -gt 0 ]]; then
    add_finding INFO "$label" "TODO_COUNT" "发现 $todo_count 处 <!-- TODO --> 标记, 请填写实际内容"
  fi

  # ------ 6. 核心必选文件 ------
  local required=("CLAUDE.md")
  for req in "${required[@]}"; do
    if [[ ! -f "$claude_dir/$req" ]]; then
      add_finding ERROR "$label" "MISSING_CORE" "缺少必需文件: $req"
    fi
  done
  if [[ ! -d "$claude_dir/rules" ]]; then
    add_finding WARN "$label" "MISSING_RULES" "缺少 rules/ 目录"
  fi

  # ------ 7. 占位符空值痕迹检测 ------
  if [[ -n "$files" ]]; then
    while IFS= read -r f; do
      local rel="${f#$claude_dir/}"
      # 检测可疑的空行模式 (占位符被替换为空后的痕迹)
      # 模式: "**LABEL**: " 后无内容 (粗体标签空值)
      if grep -qE '^\*\*[A-Z_]+\*\*:\s*$' "$f" 2>/dev/null; then
        add_finding WARN "$rel" "EMPTY_VALUE" "发现可能的空占位符值 (粗体标签后无内容)"
      fi
      # 模式: Markdown 表格存在空单元格行 (连续 | | |)
      if grep -qE '^\|\s*\|\s*\|' "$f" 2>/dev/null; then
        add_finding WARN "$rel" "EMPTY_TABLE_CELL" "Markdown 表格中存在空单元格行"
      fi
    done <<< "$files"
  fi

  # ------ 8. 双向链接完整性 (简单检测) ------
  if [[ -d "$claude_dir/rules" ]]; then
    local rule_files
    rule_files=$(find "$claude_dir/rules" -maxdepth 1 -type f -name "*.md" 2>/dev/null)
    if [[ -n "$rule_files" ]]; then
      while IFS= read -r f; do
        local rel="${f#$claude_dir/}"
        local basename_f
        basename_f=$(basename "$f")
        # 提取本文件引用的其他 rules 文件
        local refs
        refs=$(grep -oE '\[([^]]+)\]\(([^)]+\.md)\)' "$f" 2>/dev/null | grep -oE '\(([^)]+)\)' | tr -d '()' | sort -u || true)
        for ref_file in $refs; do
          # 只检查同目录下的 .md 引用
          [[ "$ref_file" == */* ]] && continue
          [[ "$ref_file" == "$basename_f" ]] && continue
          local ref_path="$claude_dir/rules/$ref_file"
          if [[ -f "$ref_path" ]]; then
            # 检查反向引用: ref_file 是否引用了 basename_f
            if ! grep -q "$basename_f" "$ref_path" 2>/dev/null; then
              add_finding INFO "$rel" "ONE_WAY_LINK" "$basename_f → $ref_file 但 $ref_file 未反向引用 $basename_f"
            fi
          fi
        done
      done <<< "$rule_files"
    fi
  fi
}

# ============================================================
# 自动检测 Monorepo
# ============================================================

printf "${BOLD}========================================${NC}\n"
printf "${BOLD}  .claude/ 上下文审计${NC}\n"
printf "${BOLD}========================================${NC}\n"
printf "  目标: %s\n" "$TARGET"

# 如果目标本身是 .claude/ 目录, 直接审计
if [[ "$(basename "$TARGET")" == ".claude" ]]; then
  audit_claude_dir "$TARGET"
elif [[ -d "$TARGET/.claude" ]]; then
  # 根级审计
  audit_claude_dir "$TARGET/.claude"

  # Monorepo: 检查子目录下的 .claude
  for sub_claude in "$TARGET"/*/.claude; do
    [[ -d "$sub_claude" ]] || continue
    audit_claude_dir "$sub_claude"
  done
else
  printf "\n${YELLOW}警告: %s 下未找到 .claude/ 目录${NC}\n" "$TARGET" >&2
  exit 2
fi

# ============================================================
# 输出汇总
# ============================================================

printf "\n${BOLD}========================================${NC}\n"
printf "${BOLD}  审计结果汇总${NC}\n"
printf "${BOLD}========================================${NC}\n"
printf "  ${RED}ERROR: %d${NC}\n" "$ERRORS"
printf "  ${YELLOW}WARN:  %d${NC}\n" "$WARNS"
printf "  ${BLUE}INFO:  %d${NC}\n" "$INFOS"

# JSON 输出
if [[ -n "$JSON_OUT" ]]; then
  {
    echo "{"
    printf '  "target": "%s",\n' "$TARGET"
    printf '  "summary": {"errors": %d, "warns": %d, "infos": %d},\n' "$ERRORS" "$WARNS" "$INFOS"
    echo '  "findings": ['
    local_first=1
    while IFS=$'\t' read -r sev rule f msg; do
      [[ -z "$sev" ]] && continue
      if [[ $local_first -eq 1 ]]; then local_first=0; else echo "    ,"; fi
      # 转义值中的 " 和 \
      msg_esc=$(echo "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')
      f_esc=$(echo "$f" | sed 's/\\/\\\\/g; s/"/\\"/g')
      printf '    {"severity": "%s", "rule": "%s", "file": "%s", "message": "%s"}' "$sev" "$rule" "$f_esc" "$msg_esc"
    done < "$FINDINGS"
    echo ""
    echo "  ]"
    echo "}"
  } > "$JSON_OUT"
  printf "\n  JSON 报告已写入: %s\n" "$JSON_OUT"
fi

printf "\n"

if [[ $ERRORS -gt 0 ]]; then
  printf "${RED}${BOLD}审计失败: 发现 %d 个错误${NC}\n\n" "$ERRORS"
  exit 1
else
  printf "${GREEN}${BOLD}审计通过${NC}\n\n"
  exit 0
fi
