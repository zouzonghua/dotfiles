# Neovim 快捷键指南

Leader 键配置为逗号 `,`（`vim.g.mapleader = ","`）。

## Leader 快捷键（普通模式）

| 快捷键 | 功能 | 说明 |
|---|---|---|
| `,e` | 开关文件树 | nvim-tree |
| `,ff` | 查找文件 | Telescope 模糊检索（当前工作目录） |
| `,fg` | 全文搜索 | Telescope 实时文本搜索（依赖 `rg`） |
| `,x` | 关闭当前 Buffer | 若有未保存修改会提示保存或放弃 |
| `,hh` | 关闭左侧所有 Buffer | BufferLine |
| `,ll` | 关闭右侧所有 Buffer | BufferLine |
| `,p` | 开关 Markdown 预览 | 仅在 Markdown 文件生效 |
| `,rn` | 符号重命名 | LSP 重命名变量/函数等 |
| `,ca` | 快速代码修复 | LSP Code Action |
| `,gd` | 打开 Git Diff 视图 | DiffviewOpen |
| `,gh` | 打开 Git 文件历史 | DiffviewFileHistory |

## 普通模式快捷键

### 基础与缓冲区

| 快捷键 | 功能 | 说明 |
|---|---|---|
| `<CR>`（回车） | 切换搜索高亮开关 | 切换 `hlsearch` |
| `Ctrl-h` | 切换到上一个 Buffer | BufferLine |
| `Ctrl-l` | 切换到下一个 Buffer | BufferLine |

### 代码跳转与导航（LSP）

| 快捷键 | 功能 | 说明 |
|---|---|---|
| `gd` | 跳转到函数/符号定义 | LSP 精准跨文件直达源码定义 |
| `gD` | 跳转到符号声明 | LSP 声明跳转 |
| `K` | 查看悬浮签名/文档 | 类似鼠标悬停提示 |
| `gi` | 跳转到实现 | LSP 接口/类实现跳转 |
| `gr` | 查找所有引用 | 结合 Telescope 模糊检索全部引用 |
| `[d` | 上一个诊断错误 | 跳转到上一个语法错误/警告 |
| `]d` | 下一个诊断错误 | 跳转到下一个语法错误/警告 |
| `Ctrl-o` | 返回上一处 | 跳转后返回上一处光标位置 |
| `Ctrl-i` | 前进到下一处 | 跳转历史前进 |

## 专用视图快捷键

- **Git Diff（Diffview）**：
  - `q`：关闭 Git Diff 视图 / 文件历史视图
- **文件树（nvim-tree）**：
  - `,e`：关闭 / 展开文件树
  - 遵循 nvim-tree 默认按键（`Enter` 打开文件，`a` 新建，`d` 删除，`r` 重命名等）

## 命令行模式（Emacs 风格）

输入 `:` 或 `/` 等进入命令行时支持以下 Emacs 风格编辑按键：

| 快捷键 | 功能 |
|---|---|
| `Ctrl-a` | 移动到行首 |
| `Ctrl-e` | 移动到行尾 |
| `Ctrl-b` | 向左移动一个字符 |
| `Ctrl-f` | 向右移动一个字符 |
| `Ctrl-d` | 删除光标处字符 |
| `Ctrl-k` | 删除光标后至行尾的内容 |
| `Alt-b`（`Option-b`） | 向左移动一个词 |
| `Alt-f`（`Option-f`） | 向右移动一个词 |
| `Alt-d`（`Option-d`） | 向右删除一个词 |

## Telescope 搜索界面

- `Ctrl-n` / `Ctrl-p`：上下切换候选结果
- **输入框 Emacs 风格编辑**：
  - `Ctrl-a` / `Ctrl-e`：移动到行首 / 行尾
  - `Ctrl-b` / `Ctrl-f`：向左 / 向右移动
  - `Ctrl-d`：删除光标处字符
  - `Ctrl-k`：删除光标后至行尾内容

## 外部依赖与初始化

- **自动安装**：首次启动 Neovim 会自动通过 `vim.pack` 安装插件。
- **语言服务（Mason）**：通过 `mason.nvim` 自动管理语言服务。在普通模式运行 `:Mason` 可打开图形界面管理、安装或更新 Language Server。
  - 默认预装：`ts_ls`（JavaScript / TypeScript）、`cssls`（CSS / SCSS / Less）、`lua_ls`（Lua）。
- **依赖检查**：可在 Neovim 中运行 `:checkhealth` 检查依赖状态。
- **全文搜索（Telescope）**：依赖 `ripgrep`：macOS 可运行 `brew install ripgrep`，Linux（Debian/Ubuntu）可运行 `sudo apt install ripgrep`。
- **Markdown 预览**：依赖 Node.js 与 `npx`。
