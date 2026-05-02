# Claude Context Templates Hook 体系

> 本目录结构遵循 `rules/hook-command-script.md` 规范。
> 质量门禁约束执行分级见 `rules/core-constraints.md` "约束执行分级"章节。

## 三级质量门禁

| 级别 | 执行方式 | 适用场景 | 状态 |
|------|---------|---------|------|
| 铁律（Level 3） | Hook Script (`sys.exit(2)` 阻断) | P0 铁律（版本同步/结构完整性/分层约束） | v2.0 实现 |
| 强约束（Level 2） | ANTI-RATIONALIZATION（SKILL.md 段落） | P1 强约束（CSO/尺寸/命名） | ✅ 已引入 |
| 推荐（Level 1） | 文本声明（rules/*.md） | P2 推荐（风格/最佳实践） | ✅ 已存在 |

## Hook 检查维度（v2.0 计划）

基于 `rules/compliance-checklist.md` 的 P0 清单，规划以下 Hook 脚本：

| 检查维度 | 脚本名 | 事件 | 阻断语义 | 来源清单 |
|---------|--------|------|---------|---------|
| 版本同步 | `validate-version-sync.py` | PostToolUse (Write) | error | compliance-checklist.md "版本同步" |
| Preset 结构 | `validate-preset-structure.py` | PostToolUse (Write) | warning | compliance-checklist.md "结构完整性" |
| SKILL 格式 | `validate-skill-format.py` | PostToolUse (Write) | warning | skill-writing.md "段落构成" |
| 分层约束 | `validate-layer-dependency.py` | PostToolUse (Write) | error | project-structure.md §3 |

## 脚本输出格式

遵循 `rules/hook-command-script.md` 的 JSON 输出规范：

```json
{
  "status": "success | warning | error",
  "summary": "一句话描述检查结果",
  "next_actions": ["根因描述", "安全重试指令", "停止条件"],
  "artifacts": ["相关文件路径"]
}
```

## Hook 注册格式（v2.0）

```json
{
  "hooks": [
    {
      "event": "PostToolUse",
      "matcher": { "tool": "Write", "path": "**/plugin.json" },
      "script": "scripts/validate-version-sync.py",
      "description": "校验 4 处版本号一致性"
    },
    {
      "event": "PostToolUse",
      "matcher": { "tool": "Write", "path": "**/presets/**" },
      "script": "scripts/validate-preset-structure.py",
      "description": "校验 Preset 双语对称性 + required files"
    }
  ]
}
```

## 语言规范

- 默认 Python 3 标准库（`#!/usr/bin/env python3`）
- 禁止运行时引入第三方依赖（pip / npm）
- 超过 100 行的脚本须有对应测试文件

## 实现时间线

| 里程碑 | 内容 | 对应路线图 |
|--------|------|----------|
| M2.C.1 | Hook 模板库（opt-in） | v2.0 支柱 C |
| M2.C.2 | 安全加固 Preset 组件 | v2.0 支柱 C |
| M2.A.2 | SessionStart Hook 模板 | v2.0 支柱 A |

## 目录结构（v2.0 目标）

```
plugin/hooks/
├── README.md                         # 本文件
├── hooks.json                        # Hook 注册清单
└── scripts/                          # Hook 脚本
    ├── validate-version-sync.py      # 版本同步校验
    ├── validate-preset-structure.py  # Preset 结构校验
    ├── validate-skill-format.py      # SKILL.md 格式校验
    └── validate-layer-dependency.py  # 分层约束校验
```
