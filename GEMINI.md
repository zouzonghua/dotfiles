# dotfiles

本项目是一个基于 `GNU Stow` 管理的个人配置文件仓库（Dotfiles）。它通过符号链接（symlinks）将仓库中的配置映射到用户的 `$HOME` 目录。

## 项目概览

- **核心工具**: `git`, `peco`, `bash`/`zsh`, `ssh`, `tmux`, `vim`.
- **管理方式**: 使用 `Makefile` 自动化 `stow` 的执行。
- **环境适配**: 支持 macOS 和 Linux (Server/Desktop) 分别通过 `PROFILE` 变量进行适配。

## 运行环境 (Runtime Context)

- **修改原则**: **禁止**直接修改 `$HOME` 下的符号链接目标。
- **操作流程**: 必须在仓库目录内（如 `~/personal/dotfiles/<module>/`）进行精准修改，然后运行 `make <module>` 或 `make setup` 同步配置。
- **自动化工具**: 
  - `make` - 安装并配置所有模块。
  - `make setup` - 执行 `scripts/setup.sh`（处理 Git 签名、SSH 权限和 Shell 注入）。
- **安全检查**: 在执行写入操作前，必须先运行 `git status` 核实工作区是否有未提交的变更。

## 架构与约定

### 模块化配置
每个顶层目录（如 `tmux/`, `vim/`, `git/`）都是一个独立的 Stow 模块。它们内部的目录结构对应于 `$HOME` 下的路径（例如 `tmux/.config/tmux/` 会映射到 `~/.config/tmux/`）。

### 自动化逻辑
- **Shell 初始化**: 通过 `scripts/setup.sh` 自动向 `.zshrc`/`.bashrc` 注入引导代码，加载 `~/.config/shell/init.sh`。
- **Git 身份**: 在 `~/work/` 和 `~/personal/` 下自动切换身份，并自动生成 `allowed_signers`。
- **SSH 权限**: 自动修正 `.ssh/config` 和 `.ssh/devcontainer` 的权限为 `600`。

## 开发指南

- **新增配置**: 在根目录创建新文件夹，按目标路径组织子目录。
- **依赖管理**: 若新配置依赖特定命令，请更新 `scripts/check.sh`。
