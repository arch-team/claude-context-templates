#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# test-audit.sh - audit-context.sh 测试套件
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIT="${SCRIPT_DIR}/../audit-context.sh"

if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
else
  RED=''; GREEN=''; NC=''
fi

PASS=0; FAIL=0

pass() { printf "${GREEN}✓${NC} %s\n" "$1"; PASS=$((PASS + 1)); }
fail() { printf "${RED}✗${NC} %s\n%s\n" "$1" "$2"; FAIL=$((FAIL + 1)); }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ============================================================
# case1: 健康的 .claude/ 应审计通过
# ============================================================
mkdir -p "$TMP/c1/.claude/rules"
cat > "$TMP/c1/.claude/CLAUDE.md" <<'EOF'
# 项目 A

这是项目 A 的规范入口。详见 [rules/arch.md](rules/arch.md)
EOF

cat > "$TMP/c1/.claude/rules/arch.md" <<'EOF'
# 架构

## 0. 速查卡片

- 分层架构

## 1. 原则

用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
用于 case1 的示例内容, 充数到达到最小行数要求。
EOF

bash "$AUDIT" --target "$TMP/c1" >/dev/null 2>&1 && rc=$? || rc=$?
if [[ $rc -eq 0 ]]; then
  pass "case1: 健康结构审计通过"
else
  fail "case1: 健康结构审计失败" "exit=$rc"
fi

# ============================================================
# case2: 残留 {{AI_GENERATED:xxx}} 应报 ERROR
# ============================================================
mkdir -p "$TMP/c2/.claude/rules"
echo "# 项目 B" > "$TMP/c2/.claude/CLAUDE.md"
cat > "$TMP/c2/.claude/rules/architecture.md" <<'EOF'
# 架构

{{AI_GENERATED:arch_diagram}}

更多内容见下文。
EOF

output=$(bash "$AUDIT" --target "$TMP/c2" 2>&1 || true)
if echo "$output" | grep -q "AI_GENERATED"; then
  pass "case2: 检测 {{AI_GENERATED:...}} 残留"
else
  fail "case2: 未检测到 AI_GENERATED 残留" "$output"
fi

# ============================================================
# case3: 残留 {{UPPER_CASE}} 应报 ERROR (排除代码块内)
# ============================================================
mkdir -p "$TMP/c3/.claude/rules"
echo "# 项目 C - {{PROJECT_NAME}}" > "$TMP/c3/.claude/CLAUDE.md"
cat > "$TMP/c3/.claude/rules/code.md" <<'EOF'
# 代码规范

## 0. 速查

正文中的占位符 {{SHOULD_FAIL}} 应被检测。

```tsx
const x = { value: {{ foo }} } // 代码块中的不算
```
EOF

output=$(bash "$AUDIT" --target "$TMP/c3" 2>&1 || true)
if echo "$output" | grep -q "SHOULD_FAIL"; then
  pass "case3: 检测正文中的 UPPER_CASE 占位符残留"
else
  fail "case3: 未检测残留" "$output"
fi

if echo "$output" | grep -q "PROJECT_NAME"; then
  pass "case3: 检测 CLAUDE.md 中的残留"
else
  fail "case3: CLAUDE.md 残留未检测" "$output"
fi

# ============================================================
# case4: 缺失 Section 0 应发 INFO
# ============================================================
mkdir -p "$TMP/c4/.claude/rules"
echo "# 项目 D" > "$TMP/c4/.claude/CLAUDE.md"
cat > "$TMP/c4/.claude/rules/no-section-0.md" <<'EOF'
# 代码规范

## 1. 命名

略
EOF

output=$(bash "$AUDIT" --target "$TMP/c4" 2>&1 || true)
if echo "$output" | grep -q "QUICK_REF"; then
  pass "case4: 提示缺失速查卡片"
else
  fail "case4: 未提示 QUICK_REF" "$output"
fi

# ============================================================
# case5: 断链应报 WARN
# ============================================================
mkdir -p "$TMP/c5/.claude/rules"
cat > "$TMP/c5/.claude/CLAUDE.md" <<'EOF'
# 项目 E

详见 [不存在的文件](rules/missing.md)
EOF

output=$(bash "$AUDIT" --target "$TMP/c5" 2>&1 || true)
if echo "$output" | grep -q "BROKEN_LINK"; then
  pass "case5: 检测断链"
else
  fail "case5: 未检测断链" "$output"
fi

# ============================================================
# case6: JSON 输出
# ============================================================
bash "$AUDIT" --target "$TMP/c5" --json "$TMP/c5-report.json" >/dev/null 2>&1 || true
if [[ -f "$TMP/c5-report.json" ]] && jq . "$TMP/c5-report.json" >/dev/null 2>&1; then
  pass "case6: JSON 输出合法"
  if jq -e '.findings | length > 0' "$TMP/c5-report.json" >/dev/null 2>&1; then
    pass "case6: findings 数组非空"
  else
    fail "case6: findings 数组空" "$(cat "$TMP/c5-report.json")"
  fi
else
  fail "case6: JSON 无效" "$(cat "$TMP/c5-report.json" 2>&1 || echo 'no file')"
fi

# ============================================================
# case7: strict 模式下 WARN 提升为 ERROR
# ============================================================
bash "$AUDIT" --target "$TMP/c5" --strict >/dev/null 2>&1 && rc=$? || rc=$?
if [[ $rc -eq 1 ]]; then
  pass "case7: --strict 使断链 WARN 导致 exit 1"
else
  fail "case7: --strict 未升级" "exit=$rc"
fi

# ============================================================
# case8: Monorepo 根级 + 子项目都被审计
# ============================================================
mkdir -p "$TMP/c8/.claude/rules" "$TMP/c8/backend/.claude/rules" "$TMP/c8/frontend/.claude/rules"
echo "# Root" > "$TMP/c8/.claude/CLAUDE.md"
echo "# Backend - {{BAD_ONE}}" > "$TMP/c8/backend/.claude/CLAUDE.md"
echo "# Frontend - {{BAD_TWO}}" > "$TMP/c8/frontend/.claude/CLAUDE.md"

output=$(bash "$AUDIT" --target "$TMP/c8" 2>&1 || true)
if echo "$output" | grep -q "BAD_ONE" && echo "$output" | grep -q "BAD_TWO"; then
  pass "case8: Monorepo 子项目被审计"
else
  fail "case8: Monorepo 子项目未被审计" "$output"
fi

# ============================================================
# 汇总
# ============================================================
printf "\n========================================\n"
printf "  测试结果\n"
printf "========================================\n"
printf "  通过: %d\n" $PASS
printf "  失败: %d\n" $FAIL

if [[ $FAIL -gt 0 ]]; then
  printf "${RED}测试失败${NC}\n"
  exit 1
else
  printf "${GREEN}全部通过${NC}\n"
  exit 0
fi
