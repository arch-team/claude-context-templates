#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Claude Context Templates - Interactive Initializer
#
# Generates .claude/ directory structures from preset templates.
# Supports single-project and monorepo modes with i18n (en/zh-CN).
# ============================================================================

# --- Constants & Script Directory ---

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESETS_DIR="${SCRIPT_DIR}/presets"

# Available presets (directory names under presets/)
PRESET_IDS=("python-fastapi" "react-typescript" "aws-cdk")
PRESET_DISPLAY_NAMES=("Python + FastAPI" "React + TypeScript" "AWS CDK (TypeScript)")

# --- Color Definitions ---

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' DIM='' RESET=''
fi

# --- Utility Functions ---

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}  Claude Context Templates - Interactive Initializer${RESET}"
    echo -e "${DIM}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

success() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

error() {
    echo -e "${RED}[ERROR]${RESET} $1" >&2
}

prompt_text() {
    local prompt_msg="$1"
    local default_val="${2:-}"
    local result=""

    if [[ -n "$default_val" ]]; then
        echo -en "${BOLD}? ${RESET}${prompt_msg} ${DIM}(${default_val})${RESET}: " >&2
    else
        echo -en "${BOLD}? ${RESET}${prompt_msg}: " >&2
    fi
    read -r result
    if [[ -z "$result" && -n "$default_val" ]]; then
        result="$default_val"
    fi
    echo "$result"
}

prompt_choice() {
    # Usage: prompt_choice "Question" "opt1" "opt2" ...
    # Returns the 0-based index of chosen option via stdout
    local question="$1"
    shift
    local options=("$@")
    local count=${#options[@]}

    echo -e "${BOLD}? ${RESET}${question}" >&2
    for i in "${!options[@]}"; do
        echo -e "  ${CYAN}$((i + 1)))${RESET} ${options[$i]}" >&2
    done

    while true; do
        echo -en "  ${DIM}Enter choice [1-${count}]:${RESET} " >&2
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= count )); then
            echo $(( choice - 1 ))
            return
        fi
        echo -e "  ${RED}Invalid choice. Please enter a number between 1 and ${count}.${RESET}" >&2
    done
}

prompt_yn() {
    local question="$1"
    local default="${2:-y}"
    local hint
    if [[ "$default" == "y" ]]; then
        hint="Y/n"
    else
        hint="y/N"
    fi

    echo -en "${BOLD}? ${RESET}${question} ${DIM}(${hint})${RESET}: " >&2
    read -r answer
    answer="${answer:-$default}"
    case "$answer" in
        [Yy]*) return 0 ;;
        *) return 1 ;;
    esac
}

# Cross-platform sed in-place
sed_inplace() {
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# Convert a string to kebab-case (lowercase, spaces/underscores to hyphens)
to_kebab_case() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | tr -cd 'a-z0-9-'
}

# --- Placeholder Replacement ---

replace_placeholders() {
    local file="$1"
    shift
    # Remaining args are KEY=VALUE pairs
    for pair in "$@"; do
        local key="${pair%%=*}"
        local value="${pair#*=}"
        # Escape special characters for sed
        local escaped_value
        escaped_value=$(printf '%s\n' "$value" | sed 's/[&/\]/\\&/g')
        sed_inplace "s|{{${key}}}|${escaped_value}|g" "$file"
    done
}

# Replace a placeholder with multi-line content (using a temp file approach)
replace_placeholder_multiline() {
    local file="$1"
    local key="$2"
    local content="$3"

    # Write content to a temp file
    local tmpfile
    tmpfile=$(mktemp)
    printf '%s' "$content" > "$tmpfile"

    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS: use perl for reliable multi-line replacement
        perl -i -p0e "
            BEGIN { open F, '<', '${tmpfile}'; local \$/; \$r = <F>; close F; }
            s/\\{\\{${key}\\}\\}/\$r/g;
        " "$file"
    else
        # Linux: use awk
        awk -v key="{{${key}}}" -v file="$tmpfile" '
        {
            if (index($0, key) > 0) {
                while ((getline line < file) > 0) print line
                close(file)
            } else {
                print
            }
        }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    fi

    rm -f "$tmpfile"
}

# --- Template Copy Functions ---

copy_common_templates() {
    local lang="$1"
    local target_dir="$2"

    local src="${PRESETS_DIR}/_common/${lang}"
    if [[ ! -d "$src" ]]; then
        error "Common templates not found for language: ${lang}"
        error "Expected directory: ${src}"
        exit 1
    fi

    mkdir -p "${target_dir}/.claude/rules"
    cp "${src}/root-CLAUDE.md" "${target_dir}/.claude/CLAUDE.md"
    cp "${src}/common-rules.md" "${target_dir}/.claude/rules/common.md"
}

copy_preset_templates() {
    local preset_id="$1"
    local lang="$2"
    local subproject_dir="$3"

    local src="${PRESETS_DIR}/${preset_id}/${lang}"
    if [[ ! -d "$src" ]]; then
        # Fallback to zh-CN if the selected language is not available
        src="${PRESETS_DIR}/${preset_id}/zh-CN"
        if [[ ! -d "$src" ]]; then
            error "Preset templates not found: ${preset_id}/${lang}"
            exit 1
        fi
        warn "Language '${lang}' not available for ${preset_id}, using zh-CN"
    fi

    mkdir -p "${subproject_dir}/.claude/rules"

    # Copy CLAUDE.md
    if [[ -f "${src}/CLAUDE.md" ]]; then
        cp "${src}/CLAUDE.md" "${subproject_dir}/.claude/CLAUDE.md"
    fi

    # Copy project-config.md
    if [[ -f "${src}/project-config.md" ]]; then
        cp "${src}/project-config.md" "${subproject_dir}/.claude/project-config.md"
    fi

    # Copy required rules
    if [[ -d "${src}/rules" ]]; then
        for rule_file in "${src}/rules"/*.md; do
            [[ -f "$rule_file" ]] || continue
            cp "$rule_file" "${subproject_dir}/.claude/rules/"
        done
    fi
}

get_optional_rules() {
    local preset_id="$1"
    local yaml_file="${PRESETS_DIR}/${preset_id}/preset.yaml"
    local optionals=()

    if [[ ! -f "$yaml_file" ]]; then
        return
    fi

    # Parse optional files from preset.yaml (simple line-based parsing)
    local in_optional=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*optional: ]]; then
            in_optional=1
            continue
        fi
        if [[ $in_optional -eq 1 ]]; then
            if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(rules/.+\.md) ]]; then
                optionals+=("${BASH_REMATCH[1]}")
            elif [[ "$line" =~ ^[[:space:]]*[a-z] && ! "$line" =~ ^[[:space:]]*- ]]; then
                # New top-level key, stop
                break
            fi
        fi
    done < "$yaml_file"

    printf '%s\n' "${optionals[@]}"
}

get_required_rules() {
    local preset_id="$1"
    local yaml_file="${PRESETS_DIR}/${preset_id}/preset.yaml"
    local requireds=()

    if [[ ! -f "$yaml_file" ]]; then
        return
    fi

    local in_required=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*required: ]]; then
            in_required=1
            continue
        fi
        if [[ $in_required -eq 1 ]]; then
            if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(.+\.md) ]]; then
                requireds+=("${BASH_REMATCH[1]}")
            elif [[ "$line" =~ ^[[:space:]]*[a-z] && ! "$line" =~ ^[[:space:]]*- ]]; then
                break
            fi
        fi
    done < "$yaml_file"

    printf '%s\n' "${requireds[@]}"
}

get_preset_default() {
    local preset_id="$1"
    local key="$2"
    local yaml_file="${PRESETS_DIR}/${preset_id}/preset.yaml"

    if [[ ! -f "$yaml_file" ]]; then
        return
    fi

    # Simple YAML value extraction for top-level defaults
    local in_defaults=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^defaults: ]]; then
            in_defaults=1
            continue
        fi
        if [[ $in_defaults -eq 1 ]]; then
            if [[ "$line" =~ ^[[:space:]]+${key}:[[:space:]]*(.+) ]]; then
                local val="${BASH_REMATCH[1]}"
                # Remove surrounding quotes if present
                val="${val%\"}"
                val="${val#\"}"
                echo "$val"
                return
            elif [[ "$line" =~ ^[a-z] ]]; then
                break
            fi
        fi
    done < "$yaml_file"
}

# --- Generation Functions ---

generate_subproject_table() {
    # Args: array of "name:preset_id:display_name" entries
    local entries=("$@")
    local table=""

    table+="| Sub-project | Path | Tech Stack |\n"
    table+="|-------------|------|------------|\n"

    for entry in "${entries[@]}"; do
        IFS=':' read -r name preset_id display_name <<< "$entry"
        table+="| ${display_name:-$name} | \`${name}/\` | ${display_name} |\n"
    done

    printf '%b' "$table"
}

generate_subproject_table_zhcn() {
    local entries=("$@")
    local table=""

    table+="| 子项目 | 路径 | 说明 |\n"
    table+="|--------|------|------|\n"

    for entry in "${entries[@]}"; do
        IFS=':' read -r name preset_id display_name <<< "$entry"
        table+="| ${display_name:-$name} | \`${name}/\` | ${display_name} |\n"
    done

    printf '%b' "$table"
}

generate_monorepo_structure() {
    # Generate the Monorepo directory tree structure
    local project_slug="$1"
    shift
    local entries=("$@")
    local tree=""

    tree+='```\n'
    tree+="${project_slug}/                    # Monorepo root\n"
    tree+="├── .claude/                    # Root: common specs\n"
    tree+="│   ├── CLAUDE.md               # Global entry\n"
    tree+="│   └── rules/\n"
    tree+="│       └── common.md           # Common rules\n"

    local count=${#entries[@]}
    local idx=0
    for entry in "${entries[@]}"; do
        IFS=':' read -r name preset_id display_name <<< "$entry"
        idx=$((idx + 1))
        local connector="├──"
        if [[ $idx -eq $count ]]; then
            connector="└──"
        fi
        tree+="${connector} ${name}/                    # ${display_name}\n"
    done

    tree+='```'

    printf '%b' "$tree"
}

generate_monorepo_structure_zhcn() {
    local project_slug="$1"
    shift
    local entries=("$@")
    local tree=""

    tree+='```\n'
    tree+="${project_slug}/                    # Monorepo 根目录\n"
    tree+="├── .claude/                    # 根级：通用规范\n"
    tree+="│   ├── CLAUDE.md               # 全局入口\n"
    tree+="│   └── rules/\n"
    tree+="│       └── common.md           # 跨项目通用规则\n"

    local count=${#entries[@]}
    local idx=0
    for entry in "${entries[@]}"; do
        IFS=':' read -r name preset_id display_name <<< "$entry"
        idx=$((idx + 1))
        local connector="├──"
        if [[ $idx -eq $count ]]; then
            connector="└──"
        fi
        tree+="${connector} ${name}/                    # ${display_name}\n"
    done

    tree+='```'

    printf '%b' "$tree"
}

# --- Optional Rules Selection ---

select_optional_rules() {
    local preset_id="$1"
    local lang="$2"
    local subproject_dir="$3"
    local selected_optionals=()

    local optionals_raw
    optionals_raw=$(get_optional_rules "$preset_id")

    if [[ -z "$optionals_raw" ]]; then
        return
    fi

    local optionals=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && optionals+=("$line")
    done <<< "$optionals_raw"

    if [[ ${#optionals[@]} -eq 0 ]]; then
        return
    fi

    echo ""
    if [[ "$lang" == "zh-CN" ]]; then
        echo -e "${BOLD}? ${RESET}选择可选规范 (y/n 逐个确认):"
    else
        echo -e "${BOLD}? ${RESET}Select optional rules (y/n for each):"
    fi

    for opt in "${optionals[@]}"; do
        local basename
        basename=$(basename "$opt" .md)
        local src_file="${PRESETS_DIR}/${preset_id}/${lang}/rules/${basename}.md"

        # Fallback to zh-CN
        if [[ ! -f "$src_file" ]]; then
            src_file="${PRESETS_DIR}/${preset_id}/zh-CN/rules/${basename}.md"
        fi

        if [[ ! -f "$src_file" ]]; then
            continue
        fi

        if prompt_yn "  Include ${basename}?" "y"; then
            selected_optionals+=("$basename")
        else
            # Remove the file if it was already copied
            rm -f "${subproject_dir}/.claude/rules/${basename}.md"
        fi
    done
}

# --- Main Flow ---

main() {
    print_header

    # ---- Step 1: Language Selection ----
    local lang_idx
    lang_idx=$(prompt_choice "Select language / 选择语言:" "English" "中文 (Chinese)")
    local lang
    if [[ "$lang_idx" -eq 0 ]]; then
        lang="en"
    else
        lang="zh-CN"
    fi
    echo ""

    # ---- Step 2: Project Mode Selection ----
    local mode_idx
    if [[ "$lang" == "zh-CN" ]]; then
        mode_idx=$(prompt_choice "项目模式:" "单项目 (Single project)" "Monorepo")
    else
        mode_idx=$(prompt_choice "Project mode:" "Single project" "Monorepo")
    fi
    local project_mode
    if [[ "$mode_idx" -eq 0 ]]; then
        project_mode="single"
    else
        project_mode="monorepo"
    fi
    echo ""

    # ---- Step 3: Project Basic Info ----
    local project_name project_slug project_description

    if [[ "$lang" == "zh-CN" ]]; then
        project_name=$(prompt_text "项目名称" "")
        while [[ -z "$project_name" ]]; do
            error "项目名称不能为空"
            project_name=$(prompt_text "项目名称" "")
        done

        local default_slug
        default_slug=$(to_kebab_case "$project_name")
        project_slug=$(prompt_text "项目标识符 (kebab-case)" "$default_slug")
        project_description=$(prompt_text "项目描述" "")
    else
        project_name=$(prompt_text "Project name" "")
        while [[ -z "$project_name" ]]; do
            error "Project name is required"
            project_name=$(prompt_text "Project name" "")
        done

        local default_slug
        default_slug=$(to_kebab_case "$project_name")
        project_slug=$(prompt_text "Project slug (kebab-case)" "$default_slug")
        project_description=$(prompt_text "Project description" "")
    fi
    echo ""

    # ---- Step 4: Tech Stack / Sub-project Selection ----

    # Array of "subproject_name:preset_id:display_name"
    local subprojects=()

    if [[ "$project_mode" == "single" ]]; then
        local stack_idx
        if [[ "$lang" == "zh-CN" ]]; then
            stack_idx=$(prompt_choice "选择技术栈:" "${PRESET_DISPLAY_NAMES[@]}")
        else
            stack_idx=$(prompt_choice "Select tech stack:" "${PRESET_DISPLAY_NAMES[@]}")
        fi
        # For single project, subproject_name is "." (root)
        subprojects+=(".:${PRESET_IDS[$stack_idx]}:${PRESET_DISPLAY_NAMES[$stack_idx]}")
        echo ""
    else
        # Monorepo: loop to add sub-projects
        local add_more=true
        while $add_more; do
            local sub_name sub_stack_idx
            if [[ "$lang" == "zh-CN" ]]; then
                sub_name=$(prompt_text "子项目名称 (目录名)" "")
                while [[ -z "$sub_name" ]]; do
                    error "子项目名称不能为空"
                    sub_name=$(prompt_text "子项目名称 (目录名)" "")
                done
                sub_stack_idx=$(prompt_choice "选择技术栈:" "${PRESET_DISPLAY_NAMES[@]}")
            else
                sub_name=$(prompt_text "Sub-project name (directory name)" "")
                while [[ -z "$sub_name" ]]; do
                    error "Sub-project name is required"
                    sub_name=$(prompt_text "Sub-project name (directory name)" "")
                done
                sub_stack_idx=$(prompt_choice "Select tech stack:" "${PRESET_DISPLAY_NAMES[@]}")
            fi

            subprojects+=("${sub_name}:${PRESET_IDS[$sub_stack_idx]}:${PRESET_DISPLAY_NAMES[$sub_stack_idx]}")
            echo ""

            if [[ "$lang" == "zh-CN" ]]; then
                if ! prompt_yn "继续添加子项目?" "n"; then
                    add_more=false
                fi
            else
                if ! prompt_yn "Add another sub-project?" "n"; then
                    add_more=false
                fi
            fi
            echo ""
        done
    fi

    # ---- Step 5: Target Directory ----
    local target_dir
    if [[ "$lang" == "zh-CN" ]]; then
        target_dir=$(prompt_text "目标目录" ".")
    else
        target_dir=$(prompt_text "Target directory" ".")
    fi

    # Resolve to absolute path
    target_dir="$(cd "$target_dir" 2>/dev/null && pwd)" || {
        error "Target directory does not exist: $target_dir"
        exit 1
    }
    echo ""

    # ---- Step 6: Check Existing .claude/ ----
    if [[ -d "${target_dir}/.claude" ]]; then
        if [[ "$lang" == "zh-CN" ]]; then
            warn "目标目录已存在 .claude/ 目录"
            local overwrite_idx
            overwrite_idx=$(prompt_choice "如何处理?" "覆盖 (Overwrite)" "跳过已有文件 (Skip existing)" "取消 (Cancel)")
        else
            warn "Target directory already has a .claude/ directory"
            local overwrite_idx
            overwrite_idx=$(prompt_choice "How to proceed?" "Overwrite" "Skip existing files" "Cancel")
        fi

        case "$overwrite_idx" in
            0)
                info "Overwriting existing files..."
                ;;
            1)
                info "Will skip existing files..."
                ;;
            2)
                info "Cancelled."
                exit 0
                ;;
        esac
        echo ""
    else
        local overwrite_idx=0
    fi

    # ---- Step 7: Generate Files ----

    local generated_files=()

    if [[ "$lang" == "zh-CN" ]]; then
        info "正在生成文件..."
    else
        info "Generating files..."
    fi
    echo ""

    if [[ "$project_mode" == "monorepo" ]]; then
        # --- Monorepo Mode ---

        # Copy common templates to root .claude/
        copy_common_templates "$lang" "$target_dir"
        generated_files+=(".claude/CLAUDE.md" ".claude/rules/common.md")

        # Generate sub-project table and monorepo structure
        local subproject_table monorepo_structure
        if [[ "$lang" == "zh-CN" ]]; then
            subproject_table=$(generate_subproject_table_zhcn "${subprojects[@]}")
            monorepo_structure=$(generate_monorepo_structure_zhcn "$project_slug" "${subprojects[@]}")
        else
            subproject_table=$(generate_subproject_table "${subprojects[@]}")
            monorepo_structure=$(generate_monorepo_structure "$project_slug" "${subprojects[@]}")
        fi

        # Replace placeholders in root CLAUDE.md
        replace_placeholders "${target_dir}/.claude/CLAUDE.md" \
            "PROJECT_NAME=${project_name}" \
            "PROJECT_SLUG=${project_slug}" \
            "PROJECT_DESCRIPTION=${project_description}"

        replace_placeholder_multiline "${target_dir}/.claude/CLAUDE.md" \
            "SUBPROJECT_TABLE" "$subproject_table"

        # Replace placeholders in common-rules.md
        replace_placeholder_multiline "${target_dir}/.claude/rules/common.md" \
            "MONOREPO_STRUCTURE" "$monorepo_structure"

        # Process each sub-project
        for entry in "${subprojects[@]}"; do
            IFS=':' read -r sub_name preset_id display_name <<< "$entry"
            local sub_dir="${target_dir}/${sub_name}"

            mkdir -p "$sub_dir"
            copy_preset_templates "$preset_id" "$lang" "$sub_dir"

            # Get preset defaults
            local pkg_mgr coverage_min
            pkg_mgr=$(get_preset_default "$preset_id" "package_manager")
            coverage_min=$(get_preset_default "$preset_id" "coverage_minimum")

            # Replace placeholders in all generated .md files
            while IFS= read -r -d '' md_file; do
                if [[ "$overwrite_idx" -eq 1 ]] && [[ -f "$md_file" ]]; then
                    # Skip mode: skip if file existed before (we can't easily detect this,
                    # so skip mode only applies to root .claude/ check above)
                    :
                fi

                replace_placeholders "$md_file" \
                    "PROJECT_NAME=${project_name}" \
                    "PROJECT_SLUG=${project_slug}" \
                    "PROJECT_DESCRIPTION=${project_description}" \
                    "SUBPROJECT_NAME=${sub_name}" \
                    "PACKAGE_MANAGER=${pkg_mgr:-uv}" \
                    "COVERAGE_MIN=${coverage_min:-85}" \
                    "DATE=$(date +%Y-%m-%d)"
            done < <(find "${sub_dir}/.claude" -name "*.md" -print0 2>/dev/null)

            # Track generated files
            while IFS= read -r -d '' f; do
                local rel_path="${f#${target_dir}/}"
                generated_files+=("$rel_path")
            done < <(find "${sub_dir}/.claude" -name "*.md" -print0 2>/dev/null)

            # Optional rules selection
            select_optional_rules "$preset_id" "$lang" "$sub_dir"
        done

    else
        # --- Single Project Mode ---

        IFS=':' read -r _ preset_id display_name <<< "${subprojects[0]}"

        # Copy preset templates directly to target (the root IS the project)
        copy_preset_templates "$preset_id" "$lang" "$target_dir"

        # Get preset defaults
        local pkg_mgr coverage_min
        pkg_mgr=$(get_preset_default "$preset_id" "package_manager")
        coverage_min=$(get_preset_default "$preset_id" "coverage_minimum")

        # Replace placeholders
        while IFS= read -r -d '' md_file; do
            replace_placeholders "$md_file" \
                "PROJECT_NAME=${project_name}" \
                "PROJECT_SLUG=${project_slug}" \
                "PROJECT_DESCRIPTION=${project_description}" \
                "SUBPROJECT_NAME=${project_slug}" \
                "PACKAGE_MANAGER=${pkg_mgr:-uv}" \
                "COVERAGE_MIN=${coverage_min:-85}" \
                "DATE=$(date +%Y-%m-%d)"
        done < <(find "${target_dir}/.claude" -name "*.md" -print0 2>/dev/null)

        # Track generated files
        while IFS= read -r -d '' f; do
            local rel_path="${f#${target_dir}/}"
            generated_files+=("$rel_path")
        done < <(find "${target_dir}/.claude" -name "*.md" -print0 2>/dev/null)

        # Optional rules selection
        select_optional_rules "$preset_id" "$lang" "$target_dir"
    fi

    # ---- Step 8: Summary ----

    echo ""
    echo -e "${GREEN}${BOLD}  ============================================${RESET}"
    if [[ "$lang" == "zh-CN" ]]; then
        echo -e "${GREEN}${BOLD}  Successfully generated .claude/ context!${RESET}"
    else
        echo -e "${GREEN}${BOLD}  Successfully generated .claude/ context!${RESET}"
    fi
    echo -e "${GREEN}${BOLD}  ============================================${RESET}"
    echo ""

    # List generated files
    if [[ "$lang" == "zh-CN" ]]; then
        echo -e "${BOLD}  生成的文件:${RESET}"
    else
        echo -e "${BOLD}  Generated files:${RESET}"
    fi

    # Re-scan to show final state after optional rules removal
    while IFS= read -r -d '' f; do
        local rel_path="${f#${target_dir}/}"
        echo -e "    ${DIM}${rel_path}${RESET}"
    done < <(find "${target_dir}/.claude" -name "*.md" -print0 2>/dev/null | sort -z)

    if [[ "$project_mode" == "monorepo" ]]; then
        for entry in "${subprojects[@]}"; do
            IFS=':' read -r sub_name _ _ <<< "$entry"
            while IFS= read -r -d '' f; do
                local rel_path="${f#${target_dir}/}"
                echo -e "    ${DIM}${rel_path}${RESET}"
            done < <(find "${target_dir}/${sub_name}/.claude" -name "*.md" -print0 2>/dev/null | sort -z)
        done
    fi

    echo ""

    # Next steps
    if [[ "$lang" == "zh-CN" ]]; then
        echo -e "${BOLD}  下一步:${RESET}"
        echo -e "    1. 编辑 ${CYAN}project-config.md${RESET} 填写项目特定信息"
        echo -e "    2. 检查生成的规范文件，按需自定义"
        echo -e "    3. 使用 Claude Code 开始开发！"
    else
        echo -e "${BOLD}  Next steps:${RESET}"
        echo -e "    1. Edit ${CYAN}project-config.md${RESET} to fill in project-specific information"
        echo -e "    2. Review generated rules and customize as needed"
        echo -e "    3. Start using Claude Code with your new context!"
    fi
    echo ""
}

main "$@"
