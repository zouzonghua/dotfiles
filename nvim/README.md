# Telescope 快捷键

普通模式下使用，Leader 为逗号 ,。搜索范围默认是当前工作目录（:pwd）。

| 快捷键 | 功能 |
|---|---|
| ,ff | 查找文件 |
| ,fg | 全文搜索（需要 rg） |

输入框支持 Emacs 风格编辑：Ctrl-a/e 到行首/行尾，Ctrl-b/f 左右移动，
Ctrl-d 删除光标处字符，Ctrl-k 删除到行尾。Ctrl-n/p 上下选择结果。

首次启动 Neovim 时会自动安装插件。可用 :checkhealth telescope 检查依赖。
macOS 可运行 brew install ripgrep 安装全文搜索依赖。
