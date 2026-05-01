#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# test-render.sh - render-template.sh 测试套件
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
RENDER="${PROJECT_ROOT}/scripts/render-template.sh"

# 颜色
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
else
  RED=''; GREEN=''; NC=''
fi

PASS=0
FAIL=0

pass() { printf "${GREEN}✓${NC} %s\n" "$1"; PASS=$((PASS + 1)); }
fail() { printf "${RED}✗${NC} %s\n%s\n" "$1" "$2"; FAIL=$((FAIL + 1)); }

assert_contains() {
  local desc="$1" file="$2" expected="$3"
  if grep -qF "$expected" "$file"; then
    pass "$desc"
  else
    fail "$desc" "文件 $file 不含: $expected"
  fi
}

assert_not_contains() {
  local desc="$1" file="$2" unexpected="$3"
  if ! grep -qF "$unexpected" "$file"; then
    pass "$desc"
  else
    fail "$desc" "文件 $file 意外含有: $unexpected"
  fi
}

# --- 准备临时工作区 ---
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

SOURCE="${TMP}/source"
TARGET="${TMP}/target"
mkdir -p "$SOURCE"

# ============================================================
# 测试用例 1: 基础单行占位符替换
# ============================================================
cat > "$SOURCE/basic.md" <<'EOF'
# {{PROJECT_NAME}}

项目标识: {{PROJECT_SLUG}}
测试覆盖率最低: {{COVERAGE_MIN}}%
EOF

bash "$RENDER" \
  --source "$SOURCE" \
  --target "$TARGET/case1" \
  --vars '{
    "PROJECT_NAME": "MyApp",
    "PROJECT_SLUG": "my-app",
    "COVERAGE_MIN": "80"
  }' >/dev/null 2>&1

assert_contains "case1: PROJECT_NAME 替换" "$TARGET/case1/basic.md" "# MyApp"
assert_contains "case1: PROJECT_SLUG 替换" "$TARGET/case1/basic.md" "项目标识: my-app"
assert_contains "case1: COVERAGE_MIN 替换" "$TARGET/case1/basic.md" "最低: 80%"
assert_not_contains "case1: 无残留占位符" "$TARGET/case1/basic.md" "{{PROJECT"

# ============================================================
# 测试用例 2: 多行占位符 (PARENT_CLAUDE_REF)
# ============================================================
cat > "$SOURCE/multiline.md" <<'EOF'
# 标题
{{PARENT_CLAUDE_REF}}

## 正文
EOF

# 注意: 当前实现把每个占位符视为 inline 替换, 多行值需含 \n 字符
# 本实现通过 JSON string 的 \n 转义支持多行
bash "$RENDER" \
  --source "$SOURCE" \
  --target "$TARGET/case2" \
  --vars '{
    "PARENT_CLAUDE_REF": "> **父级规范**: 见 [../../.claude/CLAUDE.md](../../.claude/CLAUDE.md)"
  }' >/dev/null 2>&1

assert_contains "case2: 父级引用替换" "$TARGET/case2/multiline.md" "父级规范"
assert_not_contains "case2: 无残留占位符" "$TARGET/case2/multiline.md" "{{PARENT"

# ============================================================
# 测试用例 3: JSX 代码不被误替换
# ============================================================
cat > "$SOURCE/jsx.md" <<'EOF'
# 组件示例

{{PROJECT_NAME}} 使用 React:

```tsx
const App = () => {
  const [value, setValue] = useState("")
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div dangerouslySetInnerHTML={{ __html: content }} />
    </TabsContext.Provider>
  )
}
```

结束: {{PROJECT_NAME}}
EOF

bash "$RENDER" \
  --source "$SOURCE" \
  --target "$TARGET/case3" \
  --vars '{"PROJECT_NAME": "DemoApp"}' >/dev/null 2>&1

assert_contains "case3: PROJECT_NAME 两处替换" "$TARGET/case3/jsx.md" "# 组件示例"
assert_contains "case3: JSX {{ activeTab, setActiveTab }} 保留" "$TARGET/case3/jsx.md" "{{ activeTab, setActiveTab }}"
assert_contains "case3: JSX {{ __html: content }} 保留" "$TARGET/case3/jsx.md" "{{ __html: content }}"

# 验证 {{PROJECT_NAME}} 确实被替换了 2 次
count=$(grep -c "DemoApp" "$TARGET/case3/jsx.md" || true)
if [[ "$count" -eq 2 ]]; then
  pass "case3: PROJECT_NAME 精确替换 2 次"
else
  fail "case3: PROJECT_NAME 替换次数错误" "期望 2, 实际 $count"
fi

# ============================================================
# 测试用例 4: 未提供值的占位符 -> 空字符串 + 警告
# ============================================================
cat > "$SOURCE/missing.md" <<'EOF'
# {{PROJECT_NAME}}

可选段落:
{{OPTIONAL_SECTION}}
结束
EOF

stderr_output=$(bash "$RENDER" \
  --source "$SOURCE" \
  --target "$TARGET/case4" \
  --vars '{"PROJECT_NAME": "App"}' 2>&1 >/dev/null)

assert_contains "case4: 已提供变量正常替换" "$TARGET/case4/missing.md" "# App"
assert_not_contains "case4: 未提供的占位符被移除" "$TARGET/case4/missing.md" "{{OPTIONAL_SECTION}}"

if echo "$stderr_output" | grep -q "OPTIONAL_SECTION"; then
  pass "case4: 产生 MISSING 警告"
else
  fail "case4: 缺少 MISSING 警告" "$stderr_output"
fi

# ============================================================
# 测试用例 5: 子目录结构保持
# ============================================================
mkdir -p "$SOURCE/rules"
cat > "$SOURCE/rules/testing.md" <<'EOF'
# 测试规范

覆盖率: {{COVERAGE_MIN}}%
EOF

rm -rf "$TARGET/case5"
bash "$RENDER" \
  --source "$SOURCE" \
  --target "$TARGET/case5" \
  --vars '{"PROJECT_NAME": "App", "PROJECT_SLUG": "app", "COVERAGE_MIN": "90", "PARENT_CLAUDE_REF": "ref", "OPTIONAL_SECTION": ""}' >/dev/null 2>&1

if [[ -f "$TARGET/case5/rules/testing.md" ]]; then
  pass "case5: 子目录结构保持"
  assert_contains "case5: 子目录文件替换成功" "$TARGET/case5/rules/testing.md" "覆盖率: 90%"
else
  fail "case5: 子目录文件未生成" "路径 $TARGET/case5/rules/testing.md 不存在"
fi

# ============================================================
# 测试用例 5b: 多行表格值 (Monorepo SUBPROJECT_LINK_TABLE)
# ============================================================
cat > "$SOURCE/monorepo.md" <<'EOF'
| 子项目 | 规范文档 |
|--------|---------|
| 通用规则 | [.claude/rules/common.md](.claude/rules/common.md) |
{{SUBPROJECT_LINK_TABLE}}

结束
EOF

multiline_value='| backend | [backend](../backend/.claude/CLAUDE.md) |
| frontend | [frontend](../frontend/.claude/CLAUDE.md) |
| infra | [infra](../infra/.claude/CLAUDE.md) |'

# 用 jq 正确编码多行值为 JSON
vars_json=$(jq -n --arg v "$multiline_value" '{SUBPROJECT_LINK_TABLE: $v}')

bash "$RENDER" \
  --source "$SOURCE" \
  --target "$TARGET/case5b" \
  --vars "$vars_json" >/dev/null 2>&1

assert_contains "case5b: backend 行渲染" "$TARGET/case5b/monorepo.md" "| backend | [backend](../backend/.claude/CLAUDE.md) |"
assert_contains "case5b: frontend 行渲染" "$TARGET/case5b/monorepo.md" "| frontend | [frontend](../frontend/.claude/CLAUDE.md) |"
assert_contains "case5b: infra 行渲染" "$TARGET/case5b/monorepo.md" "| infra | [infra](../infra/.claude/CLAUDE.md) |"
assert_contains "case5b: 原有通用规则行保留" "$TARGET/case5b/monorepo.md" "| 通用规则 |"
assert_contains "case5b: 结束标记保留" "$TARGET/case5b/monorepo.md" "结束"
assert_not_contains "case5b: 无残留占位符" "$TARGET/case5b/monorepo.md" "{{SUBPROJECT"

# ============================================================
# 测试用例 6: dry-run 不改写文件
# ============================================================
# 用一个新源, 且不提供所有变量, 否则会产生额外副作用
cat > "$SOURCE/dryrun.md" <<'EOF'
{{PROJECT_NAME}}
EOF

bash "$RENDER" \
  --source "$SOURCE" \
  --target "$TARGET/case6" \
  --vars '{"PROJECT_NAME": "Test"}' \
  --dry-run >/dev/null 2>&1

if [[ ! -d "$TARGET/case6" ]] || [[ ! -f "$TARGET/case6/dryrun.md" ]]; then
  pass "case6: dry-run 不创建目标文件"
else
  fail "case6: dry-run 创建了文件" "$(ls $TARGET/case6 2>&1 || echo '')"
fi

# ============================================================
# 汇总
# ============================================================
printf "\n"
printf "========================================\n"
printf "  测试结果\n"
printf "========================================\n"
printf "  通过:  %d\n" $PASS
printf "  失败:  %d\n" $FAIL

if [[ $FAIL -gt 0 ]]; then
  printf "${RED}测试失败${NC}\n"
  exit 1
else
  printf "${GREEN}全部通过${NC}\n"
  exit 0
fi
