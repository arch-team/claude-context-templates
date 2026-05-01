# 集成配置

> **职责**：外部系统和工具集成配置。

## CI/CD

- **工具**：GitHub Actions
- **触发方式**：push、pull_request
- **工作流**：`.github/workflows/ci.yml`
- **检查命令**：
  - `./scripts/validate-presets.sh`
  - `./scripts/check-links.sh`
  - `./scripts/test-init.sh`

<!-- 来源：auto-detect -->

## 版本管理

- **Tag 格式**：`v{MAJOR}.{MINOR}.{PATCH}`（语义化版本）
- **当前版本**：v1.3.1
- **版本文件**：
  - `plugin/.claude-plugin/plugin.json` → `version`
  - `plugin/.claude-plugin/marketplace.json` → `plugins[0].version`
  - `plugin/presets/manifest.json` → `plugin_version`
  - `.claude-plugin/marketplace.json` → `plugins[0].version`

<!-- 来源：git tags -->

## 环境

本项目暂无部署环境配置（CLI 工具 + Plugin 分发）。

## 外部同步

- **GitHub 仓库**：arch-team/claude-context-templates
- **同步状态**：未配置（可通过 `/pace-sync setup` 配置）
