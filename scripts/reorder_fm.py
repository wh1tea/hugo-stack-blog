#!/usr/bin/env python3
"""
批量重排 Markdown 文件中 Front Matter 的键顺序。
用法:
    python reorder_fm.py <文件或目录> [--order 键1 键2 ...]
示例:
    python reorder_fm.py ./docs --order title slug date description tags categories
"""

import os
import sys
from pathlib import Path
from io import StringIO
import ruamel.yaml
from ruamel.yaml.comments import CommentedMap

DEFAULT_ORDER = ["title", "slug", "date", "description", "tags", "categories"]


def reorder_front_matter(content: str, order: list) -> str:
    """重新排序 Front Matter，返回新内容；若无变化则返回原内容。"""
    lines = content.splitlines()
    if not lines or lines[0].strip() != "---":
        return content

    # 查找第二个 '---'
    end_idx = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end_idx = i
            break
    if end_idx is None:
        return content

    fm_lines = lines[1:end_idx]
    yaml = ruamel.yaml.YAML()
    try:
        data = yaml.load("\n".join(fm_lines))
    except Exception as e:
        print(f"YAML 解析错误: {e}", file=sys.stderr)
        return content

    if not isinstance(data, dict):
        return content

    # 构建新的有序字典
    new_data = CommentedMap()
    # 先插入指定顺序的键
    for key in order:
        if key in data:
            new_data[key] = data.pop(key)
    # 剩余键（保持原顺序）
    for key in list(data.keys()):
        new_data[key] = data[key]

    # 转回 YAML 字符串（修正点：使用 StringIO 作为流）
    out_yaml = ruamel.yaml.YAML()
    out_yaml.preserve_quotes = True
    out_yaml.width = 4096  # 禁用自动折行
    out_yaml.indent(mapping=2, sequence=4, offset=2)
    stream = StringIO()
    out_yaml.dump(new_data, stream)
    fm_str = stream.getvalue()

    # 重组整个文件
    new_lines = lines[:1] + fm_str.splitlines() + lines[end_idx:]
    return "\n".join(new_lines)


def process_file(filepath: Path, order: list):
    """处理单个文件，若内容有变化则写入。"""
    with open(filepath, "r", encoding="utf-8") as f:
        orig = f.read()
    new = reorder_front_matter(orig, order)
    if new != orig:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(new)
        print(f"已更新: {filepath}")
    else:
        print(f"无变化: {filepath}")


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="重排 Markdown 文件的 Front Matter 键顺序"
    )
    parser.add_argument("path", help="要处理的文件或目录路径")
    parser.add_argument(
        "--order",
        nargs="+",
        default=DEFAULT_ORDER,
        help=f"键顺序列表，默认: {' '.join(DEFAULT_ORDER)}",
    )
    args = parser.parse_args()

    path = Path(args.path)
    if not path.exists():
        print(f"路径不存在: {path}", file=sys.stderr)
        sys.exit(1)

    if path.is_file():
        process_file(path, args.order)
    elif path.is_dir():
        for md in path.glob("**/*.md"):
            process_file(md, args.order)
    else:
        print(f"不支持的路径类型: {path}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
