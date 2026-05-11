#!/bin/bash

set -euo pipefail

# 备份根目录
BACKUP_ROOT="$HOME/.dotfiles_backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

# 需要检查的包列表
PACKAGES=("$@")

if [ ${#PACKAGES[@]} -eq 0 ]; then
    exit 0
fi

HAS_CONFLICTS=0

for pkg in "${PACKAGES[@]}"; do
    if [ ! -d "$pkg" ]; then continue; fi

    # 进入包目录，寻找所有文件或目录
    # 使用 -mindepth 1 确保我们检查的是包内的内容
    find "$pkg" -mindepth 1 | while read -r item; do
        # 获取相对路径，例如 "gemini/.gemini/GEMINI.md" -> ".gemini/GEMINI.md"
        rel_path="${item#$pkg/}"
        target="$HOME/$rel_path"

        # 如果目标路径存在且不是软链接
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            # 如果两边都是目录，stow 会合并目录，不需要备份
            if [ -d "$target" ] && [ -d "$item" ]; then
                continue
            fi

            if [ "$HAS_CONFLICTS" -eq 0 ]; then
                mkdir -p "$BACKUP_DIR"
                HAS_CONFLICTS=1
                echo "⚠️ 发现现有文件冲突，准备备份..."
            fi

            echo "📦 备份: ~/$rel_path -> $BACKUP_DIR/$rel_path"
            # 创建备份子目录
            mkdir -p "$(dirname "$BACKUP_DIR/$rel_path")"
            # 移动文件或目录
            mv "$target" "$BACKUP_DIR/$rel_path"
        fi
    done
done

if [ "$HAS_CONFLICTS" -eq 1 ]; then
    echo "✅ 备份完成。冲突的文件已安全移至 $BACKUP_DIR"
fi
