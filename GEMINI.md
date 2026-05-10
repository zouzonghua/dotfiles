# dotfiles

本项目是一个基于 `GNU Stow` 管理的个人配置文件仓库（Dotfiles）。它通过符号链接（symlinks）将仓库中的配置映射到用户的 `$HOME` 目录。

## 项目概览

- **核心工具**: `git`, `peco`, `bash`/`zsh`, `ssh`, `tmux`, `vim`.
- **桌面/GUI 工具**: `kitty`, `aerospace` (macOS 专用).
- **管理方式**: 使用 `Makefile` 自动化 `stow` 的执行，并结合 `scripts/setup.sh` 进行环境特定的初始化。

## 核心操作

- **安装所有配置**: `make` (默认 `PROFILE=server`, macOS 下会自动包含 GUI 工具)。
- **安装桌面配置**: `make desktop` (包含 `kitty` 等 GUI 工具)。
- **安装特定模块**: `make <target>` (例如 `make tmux` 或 `make vim`)。
- **环境检查**: `make check` (检查 `stow`, `git`, `ssh` 等依赖是否安装)。
- **清理/卸载**: `make uninstall` (移除所有由本项目创建的符号链接)。

## 架构与约定

### 模块化配置
每个顶层目录（如 `tmux/`, `vim/`, `git/`）都是一个独立的 Stow 模块。它们内部的目录结构对应于 `$HOME` 下的路径（例如 `tmux/.config/tmux/` 会被映射到 `~/.config/tmux/`）。

### Shell 初始化
通过 `scripts/setup.sh` 自动向 `~/.zshrc` 或 `~/.bashrc` 注入引导代码，加载 `~/.config/shell/init.sh`。该脚本会进一步加载别名、历史记录和提示符配置。

### Git 身份管理
- 支持在 `~/work/` 和 `~/personal/` 目录下自动切换 Git 身份。
- 依赖 `git/.config/git/personal.identity` 和 `work.identity` 文件（需手动创建或包含 SSH 签名信息）。
- 自动生成 `~/.config/git/allowed_signers` 以支持 SSH 签名验证。

### SSH 配置
- 自动管理 `~/.ssh/config` 和 `~/.ssh/devcontainer`。
- `scripts/setup.sh` 会确保 SSH 配置文件具有正确的权限（`600`）。

## 开发与贡献

- **新增配置**: 在项目根目录创建新文件夹，并按 `$HOME` 结构组织子目录。
- **依赖管理**: 如果新配置依赖特定命令，请更新 `scripts/check.sh`。
- **动态逻辑**: 如果有需要动态生成的文件，请在 `scripts/setup.sh` 中添加逻辑。
