# dotfiles

git repo + symlinks.

## principles

- no bare repo
- no stow / chezmoi
- no install script
- config only
- no private keys

## bootstrap

```sh
git clone https://github.com/zouzonghua/dotfiles.git ~/personal/dotfiles
cd ~/personal/dotfiles
make
git remote set-url origin git@github-personal:zouzonghua/dotfiles.git
```

## targets

- `alacritty` → `~/.config/alacritty/alacritty.toml`
- `aerospace` → `~/.config/aerospace/aerospace.toml`
- `git` → `~/.config/git`
- `peco` → `~/.config/peco`
- `shell` → `~/.config/shell`
- `tmux` → `~/.config/tmux`
- `ssh` → `~/.ssh/config`
- `vim` → `~/.vimrc`

## usage

```sh
make            # setup all
make <target>   # setup one target
make check      # validate configs
```

`make` is idempotent: it creates missing dirs, backs up existing files to `*.backup`, and relinks with `ln -sfn`.

`make check` runs:

- `bash -n` on tmux shell scripts
- `tmux -f /dev/null source-file -n` on tmux configs
