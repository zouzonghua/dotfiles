# AGENTS.md

This file provides the primary project context and architectural guidance for all AI agents in this repository.

## Commands

```sh
make              # show help (default goal)
make install      # install selected profile; fail safely on conflicts
make desktop      # install CLI + GUI packages (Linux explicit desktop)
make <package>    # install a single package, e.g. make tmux
make dry-run      # validate installation without changing HOME
make setup        # re-run post-install: git signing, SSH permissions, shell rc injection
make check        # verify required dependencies (stow, bash, ssh, git, awk)
make uninstall    # remove Stow symlinks and safely clean generated files
```

## Architecture

This repo uses **GNU Stow** to manage symlinks. Each top-level directory is a Stow module whose internal structure mirrors $HOME. For example, `tmux/.config/tmux/` → `~/.config/tmux/`.

**Never edit Stow-managed files under `$HOME` directly** — modify their source files in this repo. Symlinked changes take effect immediately; run `make <module>` only for first install or link reconciliation. The setup scripts intentionally manage shell rc blocks, SSH permissions, and generated Git signing data under `$HOME`.

### Module map

| Module | Destination |
|--------|-------------|
| `git/` | `~/.config/git/` (config and identity files; `allowed_signers` is generated) |
| `shell/` | `~/.config/shell/` (init.sh, aliases.sh, prompt.sh, history.sh) |
| `ssh/` | `~/.ssh/config` |
| `tmux/` | `~/.config/tmux/` |
| `kitty/` | `~/.config/kitty/` (GUI/macOS) |
| `aerospace/` | `~/.config/aerospace/` (macOS only) |
| `vim/` | `~/.vimrc` |
| `nvim/` | `~/.config/nvim/` |
| `gemini/` | `~/.gemini/` |
| `codex/` | `~/.codex/` |
| `pi/` | `~/.pi/agent/` |

**AI configurations**: Gemini, Codex, and Pi instruction entries link to `agents/AGENTS.md`; their `karpathy-guidelines` Skill entries link to `agents/skills/karpathy-guidelines/SKILL.md`. Modify shared AI resources under `agents/` only.

### `scripts/setup.sh` — what it does

- **Shell init injection**: Appends a `# BEGIN DOTFILES … # END DOTFILES` block in `~/.zshrc` and `~/.bashrc` that sources `~/.config/shell/init.sh`.
- **Git signing**: Generates `~/.config/git/allowed_signers` without overwriting unowned user content.
- **SSH permissions**: Enforces `700` on `~/.ssh/` and `600` on `config`/`config.local`.

### Git identity switching

`git/.config/git/config` uses `includeIf "gitdir:~/work/"` and `includeIf "gitdir:~/personal/"` for automatic identity switching.

## Git commit convention

Use **Conventional Commits** with Chinese messages. Required content: problem/requirement description, implementation approach, reproduction path (optional).
