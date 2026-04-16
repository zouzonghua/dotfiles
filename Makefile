SHELL := /bin/bash

DOTFILES := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SCRIPTS_DIR := $(DOTFILES)/scripts

GHOSTTY_BIN := $(firstword $(wildcard /Applications/Ghostty.app/Contents/MacOS/ghostty) $(shell command -v ghostty 2>/dev/null))
KITTY_BIN := $(firstword $(wildcard /Applications/kitty.app/Contents/MacOS/kitty) $(shell command -v kitty 2>/dev/null))
GHOSTTY_DIR := $(HOME)/.config/ghostty
KITTY_DIR := $(HOME)/.config/kitty
GIT_DIR := $(HOME)/.config/git
PECO_DIR := $(HOME)/.config/peco
SHELL_DIR := $(HOME)/.config/shell
TMUX_DIR := $(HOME)/.config/tmux
SSH_DIR := $(HOME)/.ssh
VIMRC := $(HOME)/.vimrc

GHOSTTY_FILES := config
KITTY_FILES := kitty.conf
GIT_FILES := config work.identity personal.identity personal.devcontainer work.devcontainer
PECO_FILES := config.json
SHELL_FILES := init.sh aliases.sh prompt.sh history.sh
TMUX_FILES := tmux.conf conf bin
SSH_FILES := config devcontainer
SSH_CHECK_HOST := github-personal

.PHONY: ghostty kitty git peco tmux ssh shell vim check uninstall all

all: ghostty kitty git peco tmux ssh shell vim

SHELL_INIT_SOURCE := [ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh
EXPLICIT_GOALS := $(filter-out all,$(MAKECMDGOALS))

define link_file
	@if [ ! -e "$(1)" ]; then \
		echo "missing source: $(1)" >&2; \
		exit 1; \
	fi
	@if [ -e "$(2)" ] && [ ! -L "$(2)" ]; then \
		echo "backup $(2)"; \
		mv "$(2)" "$(2).backup"; \
	fi
	@ln -sfn "$(1)" "$(2)"
endef

define spoon_hint
	@if [ ! -d "$(2)" ]; then \
		printf 'missing $(1)\n'; \
		printf 'run: git clone $(3) "%s"\n' "$(2)"; \
	else \
		printf 'update $(1): cd "%s" && git pull\n' "$(2)"; \
	fi
endef

define chmod_files
	@for file in $(2); do \
		if [ -f "$(1)/$$file" ]; then chmod 600 "$(1)/$$file"; fi; \
	done
endef

ghostty:
	@mkdir -p $(GHOSTTY_DIR)
	$(call link_file,$(DOTFILES)/ghostty/config,$(GHOSTTY_DIR)/config)
	@if [ "$(EXPLICIT_GOALS)" = "ghostty" ]; then printf 'ghostty setup complete\n'; fi

kitty:
	@mkdir -p $(KITTY_DIR)
	$(call link_file,$(DOTFILES)/kitty/kitty.conf,$(KITTY_DIR)/kitty.conf)
	@if [ "$(EXPLICIT_GOALS)" = "kitty" ]; then printf 'kitty setup complete\n'; fi

git:
	@mkdir -p $(GIT_DIR)
	$(call link_file,$(DOTFILES)/git/config,$(GIT_DIR)/config)
	$(call link_file,$(DOTFILES)/git/work.identity,$(GIT_DIR)/work.identity)
	$(call link_file,$(DOTFILES)/git/personal.identity,$(GIT_DIR)/personal.identity)
	$(call link_file,$(DOTFILES)/git/personal.devcontainer,$(GIT_DIR)/personal.devcontainer)
	$(call link_file,$(DOTFILES)/git/work.devcontainer,$(GIT_DIR)/work.devcontainer)
	@if [ "$(EXPLICIT_GOALS)" = "git" ]; then printf 'git setup complete\n'; fi

peco:
	@mkdir -p $(PECO_DIR)
	$(call link_file,$(DOTFILES)/peco/config.json,$(PECO_DIR)/config.json)
	@if [ "$(EXPLICIT_GOALS)" = "peco" ]; then printf 'peco setup complete\n'; fi

tmux:
	@mkdir -p $(TMUX_DIR)
	$(call link_file,$(DOTFILES)/tmux/tmux.conf,$(TMUX_DIR)/tmux.conf)
	$(call link_file,$(DOTFILES)/tmux/conf,$(TMUX_DIR)/conf)
	$(call link_file,$(DOTFILES)/tmux/bin,$(TMUX_DIR)/bin)
	@if [ "$(EXPLICIT_GOALS)" = "tmux" ]; then \
		printf 'tmux setup complete\n'; \
		printf 'reload tmux with: tmux source-file ~/.config/tmux/tmux.conf\n'; \
	fi

ssh:
	@mkdir -p $(SSH_DIR)
	$(call link_file,$(DOTFILES)/ssh/config,$(SSH_DIR)/config)
	$(call link_file,$(DOTFILES)/ssh/devcontainer,$(SSH_DIR)/devcontainer)
	$(call chmod_files,$(SSH_DIR),$(SSH_FILES))
	@if [ "$(EXPLICIT_GOALS)" = "ssh" ]; then printf 'ssh setup complete\n'; fi

shell:
	@mkdir -p $(SHELL_DIR)
	$(call link_file,$(DOTFILES)/shell/init.sh,$(SHELL_DIR)/init.sh)
	$(call link_file,$(DOTFILES)/shell/aliases.sh,$(SHELL_DIR)/aliases.sh)
	$(call link_file,$(DOTFILES)/shell/prompt.sh,$(SHELL_DIR)/prompt.sh)
	$(call link_file,$(DOTFILES)/shell/history.sh,$(SHELL_DIR)/history.sh)
	@$(SCRIPTS_DIR)/setup-shell-init.sh "$(SHELL_INIT_SOURCE)"
	@if [ "$(EXPLICIT_GOALS)" = "shell" ]; then \
		printf 'shell setup complete\n'; \
		case "$${SHELL##*/}" in \
			zsh) printf 'reload your shell or run: source ~/.zshrc\n' ;; \
			bash) printf 'reload your shell or run: source ~/.bashrc\n' ;; \
			*) printf 'reload your shell to pick up changes\n' ;; \
		esac; \
	fi

vim:
	$(call link_file,$(DOTFILES)/vim/.vimrc,$(VIMRC))
	@if [ "$(EXPLICIT_GOALS)" = "vim" ]; then printf 'vim setup complete\n'; fi

check:
	@$(SCRIPTS_DIR)/check.sh "$(DOTFILES)" "$(GHOSTTY_BIN)" "$(KITTY_BIN)" "$(SSH_CHECK_HOST)"

uninstall:
	@$(SCRIPTS_DIR)/uninstall.sh "$(SHELL_INIT_SOURCE)" "$(SHELL_DIR)" "$(GHOSTTY_DIR)" "$(KITTY_DIR)" "$(TMUX_DIR)" "$(GIT_DIR)" "$(PECO_DIR)" "$(SSH_DIR)" "$(VIMRC)"
