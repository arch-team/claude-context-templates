# 集成配置

## 环境

| 环境 | 用途 | URL | 备注 |
|------|------|-----|------|
| production | 生产环境 | https://github.com/arch-team/claude-context-templates | GitHub 主仓库 |

## CI/CD

- **工具**: GitHub Actions（来源：auto-detect）
- **触发方式**: push/PR to main
- **构建命令**: _按需配置_
- **部署命令**: _按需配置_
- **检查命令**:
  - `scripts/validate-presets.sh`
  - `scripts/test-init.sh`
  - `scripts/check-links.sh`
  - `scripts/validate-generated.sh`

## 版本管理

- **版本文件**: _按需配置_
- **版本格式**: vX.Y.Z（从 git tags 推断）
- **当前版本**: v1.0.0
- **Tag 前缀**: v
- **版本字段**: _按需配置_

## 发布验证

- **验证命令**: _按需配置_
- **验证超时**: 30
- **额外验证**: _按需配置_

## 发布分支

- **分支模式**: direct
- **分支前缀**: release/
- **Release PR**: false
- **自动合并**: false

## 监控

- **工具**: _按需配置_
- **告警渠道**: _按需配置_

## 告警映射

| 告警类型 | 对应严重度 | 建议 CR 类型 |
|---------|----------|-------------|
| P0 / 生产不可用 | critical | hotfix |
| P1 / 功能受损 | major | defect |
| P2 / 次要问题 | minor | defect |
| P3 / 改进建议 | trivial | defect |
