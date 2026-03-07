# 集成配置

<!-- source: auto-detect -->

## CI/CD

- **工具**: GitHub Actions
- **配置文件**: `.github/workflows/ci.yml`
- **触发方式**: push/pull_request to main
- **检查命令**:
  - `scripts/validate-presets.sh` - 验证预设模板结构
  - `scripts/test-init.sh` - 测试初始化脚本（跨平台）
  - `scripts/build-plugin.sh` - 构建和验证 Plugin
  - `scripts/check-links.sh` - 检查 Markdown 链接

## 版本管理

<!-- source: auto-detect, git-tags -->

- **当前版本**: v1.0.0
- **版本格式**: vX.Y.Z（语义化版本）
- **Tag 模式**: v* （带 v 前缀）

## 环境

（待配置 — 检测到发布流程时自动填充）
