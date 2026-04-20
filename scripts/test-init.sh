#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# init.sh 端到端烟雾测试
#
# 在临时目录中运行 init.sh，通过 stdin 管道模拟用户输入，
# 验证生成的 .claude/ 目录结构和文件内容。
#
# 用法: bash scripts/test-init.sh
# ============================================================================

# --- 脚本路径 ---

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
INIT_SH="${PROJECT_ROOT}/init.sh"

# --- 颜色定义 ---

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BOLD='' DIM='' RESET=''
fi

# --- 计数器 ---

PASS_COUNT=0
FAIL_COUNT=0
TOTAL_TESTS=0

# --- 工具函数 ---

log_info() {
    echo -e "${BOLD}[INFO]${RESET} $1"
}

log_pass() {
    echo -e "  ${GREEN}[PASS]${RESET} $1"
    PASS_COUNT=$((PASS_COUNT + 1))
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

log_fail() {
    echo -e "  ${RED}[FAIL]${RESET} $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

log_scenario() {
    echo ""
    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${YELLOW}${BOLD}  场景: $1${RESET}"
    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

# 创建临时目录，返回路径
create_temp_dir() {
    mktemp -d "${TMPDIR:-/tmp}/init-test-XXXXXX"
}

# 清理临时目录
cleanup_temp_dir() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        rm -rf "$dir"
    fi
}

# 验证: .claude/ 目录存在
assert_claude_dir_exists() {
    local target="$1"
    local subpath="${2:-.claude}"
    if [[ -d "${target}/${subpath}" ]]; then
        log_pass ".claude/ 目录已创建: ${subpath}"
    else
        log_fail ".claude/ 目录不存在: ${subpath}"
    fi
}

# 验证: 文件存在
assert_file_exists() {
    local filepath="$1"
    local label="${2:-$filepath}"
    if [[ -f "$filepath" ]]; then
        log_pass "文件存在: ${label}"
    else
        log_fail "文件缺失: ${label}"
    fi
}

# 验证: 无残留 {{...}} 占位符
assert_no_placeholders() {
    local target="$1"
    local search_dir="${2:-.claude}"
    local found
    found=$(grep -r '{{[A-Z_]*}}' "${target}/${search_dir}" 2>/dev/null || true)
    if [[ -z "$found" ]]; then
        log_pass "无残留 {{...}} 占位符: ${search_dir}"
    else
        log_fail "发现残留占位符: ${search_dir}"
        echo -e "    ${DIM}${found}${RESET}"
    fi
}

# 验证: .md 文件数量 > 0
assert_md_file_count() {
    local target="$1"
    local search_dir="${2:-.claude}"
    local count
    count=$(find "${target}/${search_dir}" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -gt 0 ]]; then
        log_pass "生成了 ${count} 个 .md 文件: ${search_dir}"
    else
        log_fail "未生成任何 .md 文件: ${search_dir}"
    fi
}

# 验证: exit code = 0
assert_exit_code() {
    local code="$1"
    if [[ "$code" -eq 0 ]]; then
        log_pass "init.sh 退出码 = 0"
    else
        log_fail "init.sh 退出码 = ${code} (预期 0)"
    fi
}

# ============================================================================
# 场景 1: 单项目 Python+FastAPI 中文
# ============================================================================

test_single_python_zhcn() {
    log_scenario "1: 单项目 Python+FastAPI 中文"

    local tmpdir
    tmpdir=$(create_temp_dir)
    log_info "临时目录: ${tmpdir}"

    # init.sh 交互流程 (stdin 输入顺序):
    # 1. 语言选择: 2 (中文)
    # 2. 项目模式: 1 (单项目)
    # 3. 项目名称: "测试FastAPI项目"
    # 4. 项目标识符: 按回车接受默认值 (从项目名称自动生成)
    # 5. 项目描述: "一个用于测试的Python FastAPI项目"
    # 6. 技术栈选择: 2 (Python + FastAPI，按字母序：1=aws-cdk, 2=python-fastapi, 3=react-typescript)
    # 7. 目标目录: tmpdir 的绝对路径
    # 8. 可选规范 (python-fastapi 有 4 个可选):
    #    - api-design: y
    #    - logging: y
    #    - observability: y
    #    - sdk-first: y
    local input=""
    input+="2\n"                        # 语言: 中文
    input+="1\n"                        # 模式: 单项目
    input+="TestFastAPI\n"              # 项目名称
    input+="\n"                         # 项目标识符: 接受默认
    input+="测试项目描述\n"               # 项目描述
    input+="2\n"                        # 技术栈: Python + FastAPI
    input+="${tmpdir}\n"                # 目标目录
    input+="y\n"                        # 确认生成
    input+="y\n"                        # 可选: api-design
    input+="y\n"                        # 可选: logging
    input+="y\n"                        # 可选: observability
    input+="y\n"                        # 可选: sdk-first

    local exit_code=0
    echo -e "$input" | bash "$INIT_SH" > /dev/null 2>&1 || exit_code=$?

    assert_exit_code "$exit_code"
    assert_claude_dir_exists "$tmpdir"
    assert_file_exists "${tmpdir}/.claude/CLAUDE.md" ".claude/CLAUDE.md"
    assert_file_exists "${tmpdir}/.claude/project-config.md" ".claude/project-config.md"
    assert_file_exists "${tmpdir}/.claude/rules/architecture.md" ".claude/rules/architecture.md"
    # python-fastapi 专有文件断言（防止 preset 错位的假绿）
    assert_file_exists "${tmpdir}/.claude/rules/api-design.md" ".claude/rules/api-design.md (python-fastapi 专有)"
    assert_file_exists "${tmpdir}/.claude/rules/sdk-first.md" ".claude/rules/sdk-first.md (python-fastapi 专有)"
    assert_no_placeholders "$tmpdir"
    assert_md_file_count "$tmpdir"

    cleanup_temp_dir "$tmpdir"
    log_info "临时目录已清理"
}

# ============================================================================
# 场景 2: Monorepo 英文
# ============================================================================

test_monorepo_english() {
    log_scenario "2: Monorepo 英文 (两个子项目)"

    local tmpdir
    tmpdir=$(create_temp_dir)
    log_info "临时目录: ${tmpdir}"

    # init.sh 交互流程 (stdin 输入顺序):
    # 1. 语言选择: 1 (English)
    # 2. 项目模式: 2 (Monorepo)
    # 3. 项目名称: "MyMonorepo"
    # 4. 项目标识符: 按回车接受默认值
    # 5. 项目描述: "A test monorepo project"
    # 6. 子项目 1:
    #    - 名称: "backend"
    #    - 技术栈: 2 (Python + FastAPI，字母序：1=aws-cdk, 2=python-fastapi, 3=react-typescript)
    #    - 继续添加子项目? y
    # 7. 子项目 2:
    #    - 名称: "frontend"
    #    - 技术栈: 3 (React + TypeScript)
    #    - 继续添加子项目? n (默认)
    # 8. 目标目录: tmpdir 的绝对路径
    # 9. 子项目 1 可选规范 (python-fastapi 有 4 个可选):
    #    - api-design: y
    #    - logging: y
    #    - observability: y
    #    - sdk-first: y
    # 10. 子项目 2 可选规范 (react-typescript 有 4 个可选):
    #    - component-design: y
    #    - state-management: y
    #    - performance: y
    #    - accessibility: y
    local input=""
    input+="1\n"                        # 语言: English
    input+="2\n"                        # 模式: Monorepo
    input+="MyMonorepo\n"              # 项目名称
    input+="\n"                         # 项目标识符: 接受默认
    input+="A test monorepo project\n"  # 项目描述
    input+="backend\n"                  # 子项目 1 名称
    input+="2\n"                        # 子项目 1 技术栈: Python + FastAPI
    input+="y\n"                        # 继续添加子项目? y
    input+="frontend\n"                 # 子项目 2 名称
    input+="3\n"                        # 子项目 2 技术栈: React + TypeScript
    input+="\n"                         # 继续添加子项目? n (默认)
    input+="${tmpdir}\n"                # 目标目录
    input+="y\n"                        # 确认生成
    # 子项目 1 (backend / python-fastapi) 可选规范
    input+="y\n"                        # api-design
    input+="y\n"                        # logging
    input+="y\n"                        # observability
    input+="y\n"                        # sdk-first
    # 子项目 2 (frontend / react-typescript) 可选规范
    input+="y\n"                        # component-design
    input+="y\n"                        # state-management
    input+="y\n"                        # performance
    input+="y\n"                        # accessibility

    local exit_code=0
    echo -e "$input" | bash "$INIT_SH" > /dev/null 2>&1 || exit_code=$?

    assert_exit_code "$exit_code"

    # 根级 .claude/
    assert_claude_dir_exists "$tmpdir" ".claude"
    assert_file_exists "${tmpdir}/.claude/CLAUDE.md" ".claude/CLAUDE.md (根级)"
    assert_file_exists "${tmpdir}/.claude/rules/common.md" ".claude/rules/common.md (根级)"
    assert_no_placeholders "$tmpdir" ".claude"

    # 子项目 1: backend (python-fastapi)
    assert_claude_dir_exists "$tmpdir" "backend/.claude"
    assert_file_exists "${tmpdir}/backend/.claude/CLAUDE.md" "backend/.claude/CLAUDE.md"
    assert_file_exists "${tmpdir}/backend/.claude/rules/api-design.md" "backend/.claude/rules/api-design.md (python-fastapi 专有)"
    assert_no_placeholders "$tmpdir" "backend/.claude"
    assert_md_file_count "$tmpdir" "backend/.claude"

    # 子项目 2: frontend (react-typescript)
    assert_claude_dir_exists "$tmpdir" "frontend/.claude"
    assert_file_exists "${tmpdir}/frontend/.claude/CLAUDE.md" "frontend/.claude/CLAUDE.md"
    assert_file_exists "${tmpdir}/frontend/.claude/rules/component-design.md" "frontend/.claude/rules/component-design.md (react-typescript 专有)"
    assert_no_placeholders "$tmpdir" "frontend/.claude"
    assert_md_file_count "$tmpdir" "frontend/.claude"

    cleanup_temp_dir "$tmpdir"
    log_info "临时目录已清理"
}

# ============================================================================
# 场景 3: 单项目 React+TypeScript 英文
# ============================================================================

test_single_react_english() {
    log_scenario "3: 单项目 React+TypeScript 英文"

    local tmpdir
    tmpdir=$(create_temp_dir)
    log_info "临时目录: ${tmpdir}"

    # init.sh 交互流程 (stdin 输入顺序):
    # 1. 语言选择: 1 (English)
    # 2. 项目模式: 1 (Single project)
    # 3. 项目名称: "MyReactApp"
    # 4. 项目标识符: 按回车接受默认值
    # 5. 项目描述: "A React TypeScript application"
    # 6. 技术栈选择: 3 (React + TypeScript，字母序：1=aws-cdk, 2=python-fastapi, 3=react-typescript)
    # 7. 目标目录: tmpdir 的绝对路径
    # 8. 可选规范 (react-typescript 有 4 个可选):
    #    - component-design: y
    #    - state-management: y
    #    - performance: y
    #    - accessibility: y
    local input=""
    input+="1\n"                                # 语言: English
    input+="1\n"                                # 模式: Single project
    input+="MyReactApp\n"                       # 项目名称
    input+="\n"                                 # 项目标识符: 接受默认
    input+="A React TypeScript application\n"   # 项目描述
    input+="3\n"                                # 技术栈: React + TypeScript
    input+="${tmpdir}\n"                         # 目标目录
    input+="y\n"                                # 确认生成
    input+="y\n"                                # 可选: component-design
    input+="y\n"                                # 可选: state-management
    input+="y\n"                                # 可选: performance
    input+="y\n"                                # 可选: accessibility

    local exit_code=0
    echo -e "$input" | bash "$INIT_SH" > /dev/null 2>&1 || exit_code=$?

    assert_exit_code "$exit_code"
    assert_claude_dir_exists "$tmpdir"
    assert_file_exists "${tmpdir}/.claude/CLAUDE.md" ".claude/CLAUDE.md"
    assert_file_exists "${tmpdir}/.claude/project-config.md" ".claude/project-config.md"
    assert_file_exists "${tmpdir}/.claude/rules/architecture.md" ".claude/rules/architecture.md"
    assert_file_exists "${tmpdir}/.claude/rules/testing.md" ".claude/rules/testing.md"
    # react-typescript 专有文件断言（防止 preset 错位的假绿）
    assert_file_exists "${tmpdir}/.claude/rules/component-design.md" ".claude/rules/component-design.md (react-typescript 专有)"
    assert_file_exists "${tmpdir}/.claude/rules/accessibility.md" ".claude/rules/accessibility.md (react-typescript 专有)"
    assert_no_placeholders "$tmpdir"
    assert_md_file_count "$tmpdir"

    cleanup_temp_dir "$tmpdir"
    log_info "临时目录已清理"
}

# ============================================================================
# 场景 4: 单项目 AWS CDK 中文
# ============================================================================

test_single_awscdk_zhcn() {
    log_scenario "4: 单项目 AWS CDK 中文"

    local tmpdir
    tmpdir=$(create_temp_dir)
    log_info "临时目录: ${tmpdir}"

    # init.sh 交互流程 (stdin 输入顺序):
    # 1. 语言选择: 2 (中文)
    # 2. 项目模式: 1 (单项目)
    # 3. 项目名称: "TestCDK"
    # 4. 项目标识符: 按回车接受默认值
    # 5. 项目描述: "AWS CDK 测试项目"
    # 6. 技术栈选择: 1 (AWS CDK，字母序：1=aws-cdk, 2=python-fastapi, 3=react-typescript)
    # 7. 目标目录: tmpdir 的绝对路径
    # 8. 可选规范 (aws-cdk 有 3 个可选):
    #    - construct-design: y
    #    - deployment: y
    #    - cost-optimization: y
    local input=""
    input+="2\n"                        # 语言: 中文
    input+="1\n"                        # 模式: 单项目
    input+="TestCDK\n"                  # 项目名称
    input+="\n"                         # 项目标识符: 接受默认
    input+="AWS CDK 测试项目\n"          # 项目描述
    input+="1\n"                        # 技术栈: AWS CDK
    input+="${tmpdir}\n"                # 目标目录
    input+="y\n"                        # 确认生成
    input+="y\n"                        # 可选: construct-design
    input+="y\n"                        # 可选: deployment
    input+="y\n"                        # 可选: cost-optimization

    local exit_code=0
    echo -e "$input" | bash "$INIT_SH" > /dev/null 2>&1 || exit_code=$?

    assert_exit_code "$exit_code"
    assert_claude_dir_exists "$tmpdir"
    assert_file_exists "${tmpdir}/.claude/CLAUDE.md" ".claude/CLAUDE.md"
    assert_file_exists "${tmpdir}/.claude/project-config.md" ".claude/project-config.md"
    assert_file_exists "${tmpdir}/.claude/rules/architecture.md" ".claude/rules/architecture.md"
    assert_file_exists "${tmpdir}/.claude/rules/security.md" ".claude/rules/security.md"
    assert_file_exists "${tmpdir}/.claude/rules/construct-design.md" ".claude/rules/construct-design.md (可选)"
    assert_no_placeholders "$tmpdir"
    assert_md_file_count "$tmpdir"

    cleanup_temp_dir "$tmpdir"
    log_info "临时目录已清理"
}

# ============================================================================
# 场景 5: --dry-run 模式 (不生成文件)
# ============================================================================

test_dry_run_mode() {
    log_scenario "5: --dry-run 模式"

    local tmpdir
    tmpdir=$(create_temp_dir)
    log_info "临时目录: ${tmpdir}"

    # init.sh --dry-run 交互流程:
    # 与场景 1 相同的输入，但使用 --dry-run 参数
    local input=""
    input+="1\n"                        # 语言: English
    input+="1\n"                        # 模式: Single project
    input+="DryRunTest\n"              # 项目名称
    input+="\n"                         # 项目标识符: 接受默认
    input+="Dry run test project\n"    # 项目描述
    input+="1\n"                        # 技术栈: Python + FastAPI
    input+="${tmpdir}\n"                # 目标目录
    input+="y\n"                        # 确认生成

    local exit_code=0
    echo -e "$input" | bash "$INIT_SH" --dry-run > /dev/null 2>&1 || exit_code=$?

    assert_exit_code "$exit_code"

    # --dry-run 模式下不应生成任何文件
    if [[ ! -d "${tmpdir}/.claude" ]]; then
        log_pass "--dry-run: .claude/ 目录未创建 (符合预期)"
    else
        # .claude 目录存在，检查是否有实际文件
        local file_count
        file_count=$(find "${tmpdir}/.claude" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$file_count" -eq 0 ]]; then
            log_pass "--dry-run: .claude/ 目录为空 (符合预期)"
        else
            log_fail "--dry-run: .claude/ 目录下存在 ${file_count} 个文件 (不应生成文件)"
        fi
    fi

    cleanup_temp_dir "$tmpdir"
    log_info "临时目录已清理"
}

# ============================================================================
# 主流程
# ============================================================================

main() {
    echo ""
    echo -e "${BOLD}  init.sh 端到端烟雾测试${RESET}"
    echo -e "${DIM}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    # 前置检查
    if [[ ! -f "$INIT_SH" ]]; then
        echo -e "${RED}[ERROR]${RESET} init.sh 不存在: ${INIT_SH}"
        exit 1
    fi

    test_single_python_zhcn
    test_monorepo_english
    test_single_react_english
    test_single_awscdk_zhcn
    test_dry_run_mode

    # --- 汇总 ---
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}  测试汇总${RESET}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "  总计: ${TOTAL_TESTS}"
    echo -e "  ${GREEN}通过: ${PASS_COUNT}${RESET}"
    if [[ "$FAIL_COUNT" -gt 0 ]]; then
        echo -e "  ${RED}失败: ${FAIL_COUNT}${RESET}"
    else
        echo -e "  失败: 0"
    fi
    echo ""

    if [[ "$FAIL_COUNT" -gt 0 ]]; then
        echo -e "${RED}${BOLD}  测试未全部通过!${RESET}"
        exit 1
    else
        echo -e "${GREEN}${BOLD}  所有测试通过!${RESET}"
        exit 0
    fi
}

main "$@"
