# AGENTS.md

This file provides the primary project context and architectural guidance for all AI Agents (Claude, Gemini, Codex, etc.).

## Commands

```sh
make              # show help (default goal)
make install      # install all packages (auto-detects macOS → desktop profile)
make desktop      # install CLI + GUI packages (Linux explicit desktop)
make <package>    # install a single package, e.g. make tmux
make setup        # re-run post-install: git signing, SSH permissions, shell rc injection
make check        # verify required dependencies (stow, bash, ssh, git)
make uninstall    # remove all stow symlinks and generated files
```

## Architecture

This repo uses **GNU Stow** to manage symlinks. Each top-level directory is a Stow module whose internal structure mirrors $HOME. For example, `tmux/.config/tmux/` → `~/.config/tmux/`.

**Never edit files under $HOME directly** — always modify the source files inside the repo, then run `make <module>` or `make setup` to sync.

### Module map

| Module | Destination |
|--------|-------------|
| `git/` | `~/.config/git/` (config, identity files, allowed_signers) |
| `shell/` | `~/.config/shell/` (init.sh, aliases.sh, prompt.sh, history.sh) |
| `ssh/` | `~/.ssh/config`, `~/.ssh/devcontainer` |
| `tmux/` | `~/.config/tmux/` |
| `kitty/` | `~/.config/kitty/` (GUI/macOS) |
| `aerospace/` | `~/.config/aerospace/` (macOS only) |
| `vim/` | `~/.vimrc` |
| `peco/` | `~/.config/peco/` |
| `gemini/` | `~/.gemini/` |
| `codex/` | `~/.codex/` |
| `claude/` | `~/.claude/CLAUDE.md`（only file symlink, keep runtime data local）|

**AI configurations**: `gemini/.gemini/GEMINI.md`, `codex/.codex/AGENTS.md`, and `claude/.claude/CLAUDE.md` are symlinks to `ai/instructions.md`. Modify AI rules in `ai/instructions.md` for SSOT.

### `scripts/setup.sh` — what it does

- **Shell init injection**: Appends a `# BEGIN DOTFILES … # END DOTFILES` block in `~/.zshrc` and `~/.bashrc` that sources `~/.config/shell/init.sh`.
- **Git signing**: Generates `~/.config/git/allowed_signers` from `personal.identity` and `work.identity`.
- **SSH permissions**: Enforces `700` on `~/.ssh/` and `600` on config files.

### Git identity switching

`git/.config/git/config` uses `includeIf "gitdir:~/work/"` and `includeIf "gitdir:~/personal/"` for automatic identity switching.

## Git commit convention

Use **Conventional Commits** with Chinese messages. Required content: problem/requirement description, implementation approach, reproduction path (optional).
