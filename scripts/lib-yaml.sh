#!/usr/bin/env bash
# ============================================================
# lib-yaml.sh — 公共 YAML 解析函数（纯 bash，无需 yq）
#
# 用法: source "$(dirname "${BASH_SOURCE[0]}")/lib-yaml.sh"
# ============================================================

# 从 preset.yaml 中提取指定 section 的列表项
# 用法: parse_yaml_list <yaml_file> <section_name>
# 示例: parse_yaml_list preset.yaml "required"
#        parse_yaml_list preset.yaml "optional"
parse_yaml_list() {
  local yaml_file="$1"
  local section="$2"
  local in_section=0

  [[ ! -f "$yaml_file" ]] && return

  while IFS= read -r line; do
    # 跳过纯注释行和空行
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// /}" ]] && continue

    # 检测目标 section 标记（支持行内注释）
    if [[ "$line" =~ ^[[:space:]]*${section}:[[:space:]]*(#.*)?$ ]]; then
      in_section=1
      continue
    fi
    if [[ $in_section -eq 1 ]]; then
      # 匹配列表项 "  - xxx"
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+(.*) ]]; then
        local value="${BASH_REMATCH[1]}"
        # 去除行尾注释和尾部空格
        value="${value%%#*}"
        value="${value%"${value##*[![:space:]]}"}"
        [[ -n "$value" ]] && echo "$value"
      elif [[ "$line" =~ ^[[:space:]]*[a-z] && ! "$line" =~ ^[[:space:]]*- ]]; then
        # 遇到新的顶级 key，退出当前 section
        break
      fi
    fi
  done < "$yaml_file"
}

# 检查 YAML 中是否包含指定顶级字段
# 用法: check_yaml_field <yaml_file> <field_name>
check_yaml_field() {
  local yaml_file="$1"
  local field="$2"
  grep -q "^${field}:" "$yaml_file" 2>/dev/null
}
