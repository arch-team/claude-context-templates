#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# render-template.sh - 标准化模板渲染工具
# 将 preset 模板复制到目标目录并替换占位符
#
# 占位符规则:
#   - 只匹配 {{UPPER_SNAKE_CASE}} 形式 (首字符大写字母, 后跟大写/数字/下划线)
#   - 自动避开 JSX/YAML 的 {{ identifier }} 或 {{ expression }}
#     (含空格、小写字母、或特殊字符的不会被替换)
#   - 未提供值的占位符: 替换为空字符串
#   - 未使用的输入变量: 提示警告
#
# 用法:
#   render-template.sh \
#     --preset <preset_id>       # 例: python-fastapi
#     --lang <lang>              # zh-CN | en
#     --source <source_dir>      # 可选, 默认 plugin/presets/<preset>/<lang>
#     --target <target_dir>      # 例: backend/.claude/
#     --vars <json_or_file>      # JSON 字符串或 @/path/to/vars.json
#     [--dry-run]                # 仅打印将进行的操作
#     [--verbose]                # 显示每处替换
# ============================================================

# 颜色支持
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; NC=''
fi

log_info()  { printf "${GREEN}[INFO]${NC} %s\n" "$*"; }
log_warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$*" >&2; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; }

# --- 解析参数 ---
PRESET=""
LANG_CODE=""
SOURCE=""
TARGET=""
VARS=""
DRY_RUN=0
VERBOSE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preset)   PRESET="$2"; shift 2 ;;
    --lang)     LANG_CODE="$2"; shift 2 ;;
    --source)   SOURCE="$2"; shift 2 ;;
    --target)   TARGET="$2"; shift 2 ;;
    --vars)     VARS="$2"; shift 2 ;;
    --dry-run)  DRY_RUN=1; shift ;;
    --verbose)  VERBOSE=1; shift ;;
    -h|--help)
      sed -n '4,24p' "$0" | sed 's/^# //; s/^#//'
      exit 0
      ;;
    *) log_error "未知参数: $1"; exit 2 ;;
  esac
done

# --- 参数校验 ---
if [[ -z "$TARGET" ]]; then log_error "--target 必填"; exit 2; fi
if [[ -z "$VARS" ]];   then log_error "--vars 必填 (JSON 字符串或 @path)"; exit 2; fi

# 定位 source 目录
if [[ -z "$SOURCE" ]]; then
  if [[ -z "$PRESET" || -z "$LANG_CODE" ]]; then
    log_error "未指定 --source 时, 必须同时提供 --preset 和 --lang"
    exit 2
  fi
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
  SOURCE="${PROJECT_ROOT}/plugin/presets/${PRESET}/${LANG_CODE}"
fi

if [[ ! -d "$SOURCE" ]]; then
  log_error "source 目录不存在: $SOURCE"; exit 3
fi

# --- 读取 vars JSON ---
if [[ "$VARS" == @* ]]; then
  VARS_FILE="${VARS:1}"
  if [[ ! -f "$VARS_FILE" ]]; then
    log_error "vars 文件不存在: $VARS_FILE"; exit 3
  fi
  VARS_JSON="$(cat "$VARS_FILE")"
else
  VARS_JSON="$VARS"
fi

# 校验 JSON
if ! echo "$VARS_JSON" | jq . >/dev/null 2>&1; then
  log_error "vars 不是合法的 JSON"; exit 4
fi

# --- 提取变量名列表 (大写转换后用于正则匹配) ---
VAR_NAMES=$(echo "$VARS_JSON" | jq -r 'keys[]')

# --- 创建目标目录 ---
if [[ $DRY_RUN -eq 0 ]]; then
  mkdir -p "$TARGET"
fi

# --- 复制源目录到目标 (保持结构) ---
if [[ $DRY_RUN -eq 0 ]]; then
  # 使用 cp -R 保持子目录结构
  (cd "$SOURCE" && find . -type f) | while IFS= read -r rel; do
    src_file="${SOURCE}/${rel#./}"
    dst_file="${TARGET}/${rel#./}"
    mkdir -p "$(dirname "$dst_file")"
    cp "$src_file" "$dst_file"
  done
fi

log_info "已复制 ${SOURCE} → ${TARGET}"

# --- 渲染占位符 ---
# 使用 awk 做替换, 正则严格: \{\{[A-Z][A-Z0-9_]*\}\}
# 避开 JSX 的 {{ foo }}, YAML 的 {{ expr }} (含空格或小写字母的不会被匹配)
#
# 占位符验证策略:
#   - PARENT_CLAUDE_REF: 允许空值 (单项目模式无父级引用)
#   - 其他变量: 模板中存在但未提供值时 → 报 WARN (不阻断, 由 audit 兜底)

# 将每个变量写入独立的临时文件 (文件名 = 变量名, 文件内容 = 值)
# 这样可以安全支持多行值, 避免 TSV 解析的歧义
VARS_DIR="$(mktemp -d)"
VAR_NAMES_ORDERED=""
while IFS= read -r name; do
  [[ -z "$name" ]] && continue
  # 变量名校验: 仅允许 UPPER_SNAKE_CASE
  if ! [[ "$name" =~ ^[A-Z][A-Z0-9_]*$ ]]; then
    log_warn "变量名不符合 UPPER_SNAKE_CASE 规范, 跳过: $name"
    continue
  fi
  # 从 JSON 提取值并写入文件 (保留多行)
  echo "$VARS_JSON" | jq -r --arg k "$name" '.[$k]' > "${VARS_DIR}/${name}"
  VAR_NAMES_ORDERED="${VAR_NAMES_ORDERED} ${name}"
done < <(echo "$VARS_JSON" | jq -r 'keys[]')

TOTAL_REPLACED=0
TOTAL_FILES=0
USED_VARS_FILE="$(mktemp)"
MISSING_VARS_FILE="$(mktemp)"

process_file() {
  local file="$1"
  local tmp
  tmp="$(mktemp)"
  local stats
  stats="$(mktemp)"

  awk -v vars_dir="$VARS_DIR" -v stats_file="$stats" -v verbose="$VERBOSE" -v file="$file" '
    function read_var(name,   content, line, first) {
      if (name in var_cache) return var_cache[name]
      content = ""
      first = 1
      while ((getline line < (vars_dir "/" name)) > 0) {
        if (first) { content = line; first = 0 }
        else       { content = content "\n" line }
      }
      close(vars_dir "/" name)
      var_cache[name] = content
      var_exists[name] = 1
      return content
    }
    function var_available(name) {
      # 检测变量文件是否存在
      if (name in var_exists) return var_exists[name]
      if ((getline line < (vars_dir "/" name)) > 0 || (getline line < (vars_dir "/" name)) == 0) {
        close(vars_dir "/" name)
        var_exists[name] = 1
        return 1
      }
      close(vars_dir "/" name)
      var_exists[name] = 0
      return 0
    }
    BEGIN {
      replaced_count = 0
      # 枚举 vars_dir 内的变量名
      cmd = "ls \"" vars_dir "\" 2>/dev/null"
      while ((cmd | getline fname) > 0) {
        var_exists[fname] = 1
      }
      close(cmd)
    }
    {
      line = $0
      while (match(line, /\{\{[A-Z][A-Z0-9_]*\}\}/)) {
        placeholder = substr(line, RSTART, RLENGTH)
        name = substr(placeholder, 3, RLENGTH - 4)
        if ((name in var_exists) && var_exists[name]) {
          replacement = read_var(name)
          used[name] = 1
          replaced_count++
        } else {
          replacement = ""
          missing[name] = 1
        }
        line = substr(line, 1, RSTART-1) replacement substr(line, RSTART+RLENGTH)
        if (verbose) {
          print "[replace] " file ": " placeholder > "/dev/stderr"
        }
      }
      print line
    }
    END {
      printf "STATS_REPLACED\t%d\n", replaced_count > stats_file
      for (k in used)    printf "USED\t%s\n",    k > stats_file
      for (k in missing) printf "MISSING\t%s\n", k > stats_file
      close(stats_file)
    }
  ' "$file" > "$tmp"

  # 解析统计
  local replaced=0
  while IFS=$'\t' read -r tag val; do
    case "$tag" in
      STATS_REPLACED) replaced="$val" ;;
      USED) echo "$val" >> "$USED_VARS_FILE" ;;
      MISSING) echo "$val" >> "$MISSING_VARS_FILE"
        log_warn "占位符无值: {{${val}}} in ${file#$TARGET/}" ;;
    esac
  done < "$stats"

  if [[ $DRY_RUN -eq 0 ]]; then
    mv "$tmp" "$file"
  else
    rm -f "$tmp"
  fi
  rm -f "$stats"

  TOTAL_REPLACED=$((TOTAL_REPLACED + replaced))
}

# 遍历目标目录所有 .md 文件
while IFS= read -r -d '' f; do
  process_file "$f"
  TOTAL_FILES=$((TOTAL_FILES + 1))
done < <(find "$TARGET" -type f -name "*.md" -print0)

# --- 未使用变量警告 ---
USED_SORTED="$(sort -u "$USED_VARS_FILE" 2>/dev/null || true)"
for var_name in $VAR_NAMES; do
  if ! echo "$USED_SORTED" | grep -qxF "$var_name"; then
    log_warn "变量 ${var_name} 已提供但未被任何模板使用"
  fi
done

# 清理临时文件
rm -rf "$VARS_DIR"
rm -f "$USED_VARS_FILE" "$MISSING_VARS_FILE"

log_info "渲染完成: ${TOTAL_FILES} 个文件, ${TOTAL_REPLACED} 处替换"

if [[ $DRY_RUN -eq 1 ]]; then
  log_info "(dry-run: 未写入任何文件)"
fi
