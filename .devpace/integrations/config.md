# 集成配置

> **职责**：外部工具和服务的集成配置。

## 版本管理

- **Tag 格式**: `vX.Y.Z`
- **当前版本**: v1.0.0
- **版本文件**: plugin/.claude-plugin/plugin.json, plugin/.claude-plugin/marketplace.json, plugin/presets/manifest.json
- **变更日志**: （待创建 CHANGELOG.md）

<!-- 由 devpace 自动检测（source: auto-detect, git-tags）-->

## CI/CD

- **工具**: GitHub Actions
- **配置文件**: `.github/workflows/ci.yml`
- **触发方式**: push to main, pull_request to main
- **检查命令**:
  - `scripts/validate-presets.sh`
  - `scripts/test-init.sh`

<!-- 由 devpace 自动检测（source: auto-detect, .github/workflows/ci.yml）-->

## 环境

| 环境 | 用途 | URL |
|------|------|-----|
| production | 正式环境 | https://github.com/arch-team/claude-context-templates |

## 发布审批

- **模式**：自动发布（CI 通过即部署）
- **触发方式**：Push tag (`vX.Y.Z`)
- **验证要求**：所有 CI 检查通过

## 外部同步

- **平台**：GitHub (arch-team/claude-context-templates)
- **同步模式**：push（devpace → GitHub）
- **配置文件**：`.devpace/integrations/sync-mapping.md`
- **状态映射**：CR 状态 → GitHub Issue 标签
- **连接状态**：✅ 已验证
- **初始化状态**：✅ 标签已预创建

**使用说明**：
- 关联 CR：`/pace-sync link CR-xxx #Issue编号`
- 推送状态：`/pace-sync push`（CR 状态变更时自动提醒）
- 查看状态：`/pace-sync status`
