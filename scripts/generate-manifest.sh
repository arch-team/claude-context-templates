#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# generate-manifest.sh — 生成 plugin/presets/manifest.json
#
# 遍历所有 preset 目录，提取版本和文件哈希，生成版本清单。
# 供轻量版本检查使用。
#
# 用法: ./scripts/generate-manifest.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PRESETS_DIR="${ROOT_DIR}/plugin/presets"
MANIFEST_FILE="${PRESETS_DIR}/manifest.json"
PLUGIN_JSON="${ROOT_DIR}/plugin/.claude-plugin/plugin.json"

# 颜色定义
if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    DIM='\033[2m'
    RESET='\033[0m'
else
    GREEN='' BLUE='' DIM='' RESET=''
fi

info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET} $1"; }

# 从 plugin.json 获取插件版本
plugin_version=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$PLUGIN_JSON" | head -1 | grep -o '"[^"]*"$' | tr -d '"')

# 从 preset.yaml 提取版本号
extract_preset_version() {
    local yaml_file="$1"
    if [[ ! -f "$yaml_file" ]]; then
        echo "unknown"
        return
    fi
    local version
    version=$(grep -m1 '^version:' "$yaml_file" | sed 's/^version:[[:space:]]*//' | tr -d '"' | tr -d "'" | tr -d ' ')
    echo "${version:-unknown}"
}

# 从 preset.yaml 提取顶层字符串字段（如 display_name, description）
# 处理普通字符串值和双语结构（取 zh-CN 值作为默认）
extract_yaml_string() {
    local yaml_file="$1"
    local field="$2"
    if [[ ! -f "$yaml_file" ]]; then
        echo ""
        return
    fi
    local value
    # 先尝试直接提取顶层字段（非嵌套结构）
    value=$(grep -m1 "^${field}:" "$yaml_file" | sed "s/^${field}:[[:space:]]*//" | tr -d '"' | tr -d "'" | sed 's/[[:space:]]*$//')
    if [[ -n "$value" ]]; then
        echo "$value"
        return
    fi
    # 如果顶层字段无值，尝试读取 zh-CN 子键
    local in_field=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^${field}: ]]; then
            in_field=1
            continue
        fi
        if [[ $in_field -eq 1 ]]; then
            if [[ "$line" =~ ^[[:space:]]+zh-CN:[[:space:]]*(.*) ]]; then
                value="${BASH_REMATCH[1]}"
                value=$(echo "$value" | tr -d '"' | tr -d "'" | sed 's/[[:space:]]*$//')
                echo "$value"
                return
            elif [[ "$line" =~ ^[a-z] ]]; then
                break
            fi
        fi
    done < "$yaml_file"
    echo ""
}

# 计算目录内容的哈希值（基于所有文件内容的 SHA256）
compute_dir_hash() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        echo "none"
        return
    fi
    # 对目录下所有文件内容拼接后计算哈希
    find "$dir" -type f -not -name '.DS_Store' -not -name 'manifest.json' -print0 | sort -z | xargs -0 cat 2>/dev/null | shasum -a 256 | cut -d' ' -f1
}

# 统计目录中的文件数
count_files() {
    local dir="$1"
    find "$dir" -type f -not -name '.DS_Store' -not -name 'manifest.json' 2>/dev/null | wc -l | tr -d ' '
}

# 生成时间戳
generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 构建 presets JSON
presets_json=""
first=true

for preset_dir in "${PRESETS_DIR}"/*/; do
    preset_dir="${preset_dir%/}"
    preset_name="$(basename "$preset_dir")"

    # 跳过 _common
    [[ "$preset_name" == "_common" ]] && continue

    local_version=$(extract_preset_version "${preset_dir}/preset.yaml")
    display_name=$(extract_yaml_string "${preset_dir}/preset.yaml" "display_name")
    description=$(extract_yaml_string "${preset_dir}/preset.yaml" "description")
    dir_hash=$(compute_dir_hash "$preset_dir")
    file_count=$(count_files "$preset_dir")

    if [[ "$first" == "true" ]]; then
        first=false
    else
        presets_json+=","
    fi

    presets_json+="
    \"${preset_name}\": {
      \"version\": \"${local_version}\",
      \"display_name\": \"${display_name}\",
      \"description\": \"${description}\",
      \"files_hash\": \"${dir_hash}\",
      \"file_count\": ${file_count}
    }"
done

# 计算 _common 哈希
common_hash=$(compute_dir_hash "${PRESETS_DIR}/_common")
common_count=$(count_files "${PRESETS_DIR}/_common")

# 写入 manifest.json
cat > "$MANIFEST_FILE" << EOF
{
  "schema_version": "1.0",
  "plugin_version": "${plugin_version}",
  "generated_at": "${generated_at}",
  "presets": {${presets_json}
  },
  "_common": {
    "files_hash": "${common_hash}",
    "file_count": ${common_count}
  }
}
EOF

success "已生成 ${MANIFEST_FILE##*/} (plugin v${plugin_version})"
