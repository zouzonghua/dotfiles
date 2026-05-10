# dotfiles

本项目是一个基于 `GNU Stow` 管理的个人配置文件仓库（Dotfiles）。它通过符号链接（symlinks）将仓库中的配置映射到用户的 `$HOME` 目录。

## 项目概览

- **核心工具**: `git`, `peco`, `bash`/`zsh`, `ssh`, `tmux`, `vim`.
- **AI 增强**: `gemini`, `codex` (集成 Superpowers 技能框架)。
- **管理方式**: 使用 `Makefile` 自动化 `stow` 的执行。
- **环境适配**: 支持 macOS 和 Linux 分别通过 `PROFILE` 变量进行适配。

## 运行环境 (Runtime Context)

- **修改原则**: **禁止**直接修改 `$HOME` 下的符号链接目标。
- **操作流程**: 必须在仓库目录内（如 `~/personal/dotfiles/<module>/`）进行精准修改，然后运行 `make <module>` 或 `make setup` 同步配置。
- **自动化工具**: 
  - `make help` - 查看所有可用指令。
  - `make setup` - 执行 `scripts/setup.sh`（处理 Git 签名、SSH 权限和 Shell 注入）。
- **安全检查**: 在执行写入操作前，必须先运行 `git status` 核实工作区是否有未提交的变更。

## 架构与约定

### 模块化配置
每个顶层目录都是一个独立的 Stow 模块。目录结构对应于 `$HOME` 下的路径（如 `tmux/.config/tmux/` -> `~/.config/tmux/`）。

### 自动化逻辑
- **Shell 初始化**: 通过 `scripts/setup.sh` 采用 **Block Mode**（`# BEGIN DOTFILES`）向 `.zshrc`/`.bashrc` 注入引导代码，加载 `~/.config/shell/init.sh`。
- **Git 身份**: 自动识别 `personal.identity` 和 `work.identity` 并生成 `allowed_signers`。
- **SSH 权限**: 自动管理 `~/.ssh/` 目录及相关配置文件的权限（700/600）。

### AI 协同 (AI Synergy) 🤖
本项目不仅管理工具配置，还管理 AI 代理的行为逻辑：
- **全局准则**: `gemini/` 和 `codex/` 模块定义了 AI 的交互风格与工程标准。
- **动态技能**: 集成了 `karpathy-guidelines` 和 `code-simplifier` 等动态加载技能。
- **Git 规范**: 强制使用 **Conventional Commits** 格式，内容必须包含：问题描述、实现思路、复现路径（可选）。

## 开发指南

- **新增配置**: 在根目录创建新文件夹，按目标路径组织子目录。
- **依赖管理**: 若新配置依赖特定命令，请更新 `scripts/check.sh`。
