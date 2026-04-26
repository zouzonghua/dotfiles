# dotfiles

git repo + stow-managed symlinks.

## bootstrap

```sh
git clone https://github.com/zouzonghua/dotfiles.git ~/personal/dotfiles
cd ~/personal/dotfiles
make
git remote set-url origin git@github-personal:zouzonghua/dotfiles.git
```

Install `stow` first:

```sh
# macOS
brew install stow

# Debian/Ubuntu
sudo apt install stow

# Fedora
sudo dnf install stow

# Arch
sudo pacman -S stow
```

## targets

- `kitty` → `~/.config/kitty/kitty.conf`
- `git` → `~/.config/git`
- `peco` → `~/.config/peco`
- `shell` → `~/.config/shell`
- `tmux` → `~/.config/tmux`
- `ssh` → `~/.ssh/config`, `~/.ssh/devcontainer`
- `vim` → `~/.vimrc`
- `aerospace` → `~/.config/aerospace/aerospace.toml` (macOS only)

## usage

```sh
make            # setup all
make desktop    # setup desktop profile on Linux
make <target>   # setup one target
make check      # check dependencies
make setup      # regenerate dynamic files and shell rc injection
make uninstall  # remove stow symlinks and generated files
```

`make` uses `stow --no-folding` so generated files like `~/.config/git/allowed_signers` stay outside the repo. `make setup` keeps the non-stow bits: git `allowed_signers`, SSH permissions, and shell rc injection.

CLI packages are installed everywhere: `git peco shell ssh tmux vim`.
GUI packages are installed by `make desktop`, and by default on macOS: `kitty`.
Darwin packages are installed only on macOS: `aerospace`.
