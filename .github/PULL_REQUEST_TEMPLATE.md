## Description

<!-- Briefly describe what this PR does and why. -->

## Type of Change

- [ ] New preset
- [ ] Improvement to existing preset
- [ ] Bug fix (init.sh, templates, links)
- [ ] Documentation update
- [ ] CI/CD change
- [ ] Other: <!-- describe -->

## Checklist

- [ ] Files follow naming conventions (`kebab-case.md`)
- [ ] All required files are included (for new presets)
- [ ] Both `zh-CN/` and `en/` versions are provided
- [ ] `preset.yaml` is complete and valid (for new/modified presets)
- [ ] Templates use `{{VARIABLE}}` placeholders correctly
- [ ] No project-specific content remains (proper abstraction)
- [ ] `init.sh` updated if new preset added

## Testing

- [ ] Ran `./init.sh` and verified generated output
- [ ] Ran `scripts/validate-presets.sh` — all checks pass
- [ ] Ran `scripts/check-links.sh` — no broken links
