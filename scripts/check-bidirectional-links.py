#!/usr/bin/env python3
"""检查 preset 中的双向链接完整性"""

import re
import sys
from pathlib import Path
from collections import defaultdict

def extract_links(content):
    """提取 Markdown 文件中的本地链接"""
    pattern = r'\[.*?\]\(([^)]*\.md)\)'
    links = re.findall(pattern, content)
    # 过滤掉 HTTP 链接，只保留本地链接
    return [Path(link).name for link in links if not link.startswith('http')]

def check_bidirectional_links(preset_name, lang):
    """检查指定 preset 的双向链接"""
    preset_dir = Path(f"plugin/presets/{preset_name}/{lang}/rules")

    if not preset_dir.exists():
        print(f"❌ 目录不存在: {preset_dir}")
        return False

    print(f"🔍 检查 {preset_name}/{lang} 的双向链接...")
    print()

    # 收集所有文件及其链接
    link_map = {}
    md_files = sorted(preset_dir.glob("*.md"))

    for file_path in md_files:
        content = file_path.read_text(encoding='utf-8')
        links = extract_links(content)
        if links:
            link_map[file_path.name] = set(links)

    # 检查双向链接
    missing = []

    for file_name, linked_files in link_map.items():
        for linked_file in linked_files:
            # 检查被引用文件是否反向引用了当前文件
            if linked_file in link_map:
                if file_name not in link_map[linked_file]:
                    missing.append((file_name, linked_file))

    # 输出结果
    print("## 双向链接检查结果")
    print()

    if not missing:
        print("✅ 所有链接均为双向")
        return True
    else:
        print(f"❌ 发现 {len(missing)} 个单向链接:")
        print()
        for source, target in missing:
            print(f"  ⚠️  {source} → {target} (单向链接，需要在 {target} 中添加反向链接)")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("用法: ./check-bidirectional-links.py <preset-name> <lang>")
        sys.exit(1)

    preset = sys.argv[1]
    lang = sys.argv[2]

    success = check_bidirectional_links(preset, lang)
    sys.exit(0 if success else 1)
