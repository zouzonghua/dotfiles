# dotfiles

git repo + symlinks.

## bootstrap

```sh
git clone https://github.com/zouzonghua/dotfiles.git ~/personal/dotfiles
cd ~/personal/dotfiles
make
git remote set-url origin git@github-personal:zouzonghua/dotfiles.git
```

## targets

- `alacritty` → `~/.config/alacritty/alacritty.toml`
- `ghostty` → `~/.config/ghostty/config`
- `kitty` → `~/.config/kitty/kitty.conf`
- `hammerspoon` → `~/.hammerspoon/init.lua`
- `git` → `~/.config/git`
- `peco` → `~/.config/peco`
- `shell` → `~/.config/shell`
- `tmux` → `~/.config/tmux`
- `ssh` → `~/.ssh/config`, `~/.ssh/devcontainer`
- `vim` → `~/.vimrc`

## usage

```sh
make            # setup all
make <target>   # setup one target
make check      # validate configs
make uninstall  # remove symlinks and restore backups
```

`make` is idempotent: it creates missing dirs, backs up existing files to `*.backup`, and relinks with `ln -sfn`.

