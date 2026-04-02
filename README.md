# dotfiles

Minimal setup: **git repo + manual symlink**

## rules

* no bare repo
* no stow / chezmoi
* no install script
* config only
* no private keys

## bootstrap

clone and apply:

```
git clone https://github.com/zouzonghua/dotfiles.git ~/personal/dotfiles && cd ~/personal/dotfiles && make
git remote set-url origin git@github-personal:zouzonghua/dotfiles.git
```

managed configs:

* `git` → `~/.config/git`
* `tmux` → `~/.config/tmux`
* `ssh` → `~/.ssh/config`
* `vim` → `~/.vimrc`

## make

```
make        # setup all
make git    # setup git only
make tmux   # setup tmux only
make ssh    # setup ssh only
make vim    # setup vim only
make check  # validate config files
```

behavior:

* create target directories if missing
* backup existing files → `*.backup`
* create symlink with `ln -sfn`
* safe to run multiple times

checks:

* `bash -n` for tmux shell scripts
* `tmux -n` parse check for `tmux.conf`
