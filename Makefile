SHELL := /bin/bash

DOTFILES := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SCRIPTS_DIR := $(DOTFILES)/scripts

KITTY_BIN := $(firstword $(wildcard /Applications/kitty.app/Contents/MacOS/kitty) $(shell command -v kitty 2>/dev/null))
AEROSPACE_BIN := $(shell command -v aerospace 2>/dev/null)
KITTY_DIR := $(HOME)/.config/kitty
GIT_DIR := $(HOME)/.config/git
PECO_DIR := $(HOME)/.config/peco
SHELL_DIR := $(HOME)/.config/shell
TMUX_DIR := $(HOME)/.config/tmux
SSH_DIR := $(HOME)/.ssh
VIMRC := $(HOME)/.vimrc
AEROSPACE_CONFIG := $(HOME)/.config/aerospace/aerospace.toml

KITTY_FILES := kitty.conf
GIT_FILES := config work.identity personal.identity personal.devcontainer work.devcontainer
PECO_FILES := config.json
SHELL_FILES := init.sh aliases.sh prompt.sh history.sh
TMUX_FILES := tmux.conf conf bin
SSH_FILES := config devcontainer
SSH_CHECK_HOST := github-personal

.PHONY: aerospace kitty git peco tmux ssh shell vim check
.PHONY: check-aerospace check-kitty check-git check-peco check-tmux check-ssh check-shell check-vim
.PHONY: preflight install all
.PHONY: install-aerospace install-kitty install-git install-peco install-tmux install-ssh install-shell install-vim

all:
	@bash $(SCRIPTS_DIR)/check.sh install-ok "$(DOTFILES)" "$(KITTY_BIN)" "$(AEROSPACE_BIN)" "$(SSH_CHECK_HOST)" "$(MAKE)"

preflight: check

install: install-aerospace install-kitty install-git install-peco install-tmux install-ssh install-shell install-vim

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

define prepare_generated_file
	@if [ -e "$(1)" ] && [ ! -L "$(1)" ] && [ ! -e "$(1).backup" ]; then \
		echo "backup $(1)"; \
		mv "$(1)" "$(1).backup"; \
	fi
	@if [ -L "$(1)" ]; then rm -f "$(1)"; fi
endef

aerospace: check-aerospace install-aerospace

check-aerospace:
	@if [ -n "$(AEROSPACE_BIN)" ]; then \
		printf '%-32s[%s]\n' "check aerospace installed" "OK"; \
	else \
		printf '%-32s[%s]\n' "check aerospace installed" "SKIP"; \
		printf '  aerospace binary not found\n'; \
		exit 1; \
	fi

install-aerospace:
	$(call link_file,$(DOTFILES)/aerospace/aerospace.toml,$(AEROSPACE_CONFIG))
	@if [ "$(EXPLICIT_GOALS)" = "aerospace" ]; then \
		printf 'aerospace setup complete\n'; \
		printf 'reload AeroSpace with: aerospace reload-config\n'; \
	fi

kitty: check-kitty install-kitty

check-kitty:
	@bash $(SCRIPTS_DIR)/check.sh report-kitty "$(DOTFILES)" "$(KITTY_BIN)" "$(AEROSPACE_BIN)" "$(SSH_CHECK_HOST)"

install-kitty:
	@mkdir -p $(KITTY_DIR)
	$(call link_file,$(DOTFILES)/kitty/kitty.conf,$(KITTY_DIR)/kitty.conf)
	@if [ "$(EXPLICIT_GOALS)" = "kitty" ]; then printf 'kitty setup complete\n'; fi

git: check-git install-git

check-git:
	@tmp="$$(mktemp)"; \
		bash $(SCRIPTS_DIR)/generate-allowed-signers.sh "$$tmp" \
			"$(DOTFILES)/git/personal.identity" \
			"$(DOTFILES)/git/work.identity"; \
		rm -f "$$tmp"

install-git:
	@mkdir -p $(GIT_DIR)
	$(call link_file,$(DOTFILES)/git/config,$(GIT_DIR)/config)
	$(call link_file,$(DOTFILES)/git/work.identity,$(GIT_DIR)/work.identity)
	$(call link_file,$(DOTFILES)/git/personal.identity,$(GIT_DIR)/personal.identity)
	$(call link_file,$(DOTFILES)/git/personal.devcontainer,$(GIT_DIR)/personal.devcontainer)
	$(call link_file,$(DOTFILES)/git/work.devcontainer,$(GIT_DIR)/work.devcontainer)
	$(call prepare_generated_file,$(GIT_DIR)/allowed_signers)
	@bash $(SCRIPTS_DIR)/generate-allowed-signers.sh "$(GIT_DIR)/allowed_signers" \
		"$(DOTFILES)/git/personal.identity" \
		"$(DOTFILES)/git/work.identity"
	@if [ "$(EXPLICIT_GOALS)" = "git" ]; then printf 'git setup complete\n'; fi

peco: check-peco install-peco

check-peco:
	@:

install-peco:
	@mkdir -p $(PECO_DIR)
	$(call link_file,$(DOTFILES)/peco/config.json,$(PECO_DIR)/config.json)
	@if [ "$(EXPLICIT_GOALS)" = "peco" ]; then printf 'peco setup complete\n'; fi

tmux: check-tmux install-tmux

check-tmux:
	@bash $(SCRIPTS_DIR)/check.sh report-tmux "$(DOTFILES)" "$(KITTY_BIN)" "$(AEROSPACE_BIN)" "$(SSH_CHECK_HOST)"

install-tmux:
	@mkdir -p $(TMUX_DIR)
	$(call link_file,$(DOTFILES)/tmux/tmux.conf,$(TMUX_DIR)/tmux.conf)
	$(call link_file,$(DOTFILES)/tmux/conf,$(TMUX_DIR)/conf)
	$(call link_file,$(DOTFILES)/tmux/bin,$(TMUX_DIR)/bin)
	@if [ "$(EXPLICIT_GOALS)" = "tmux" ]; then \
		printf 'tmux setup complete\n'; \
		printf 'reload tmux with: tmux source-file ~/.config/tmux/tmux.conf\n'; \
	fi

ssh: check-ssh install-ssh

check-ssh:
	@bash $(SCRIPTS_DIR)/check.sh report-ssh "$(DOTFILES)" "$(KITTY_BIN)" "$(AEROSPACE_BIN)" "$(SSH_CHECK_HOST)"

install-ssh:
	@mkdir -p $(SSH_DIR)
	$(call link_file,$(DOTFILES)/ssh/config,$(SSH_DIR)/config)
	$(call link_file,$(DOTFILES)/ssh/devcontainer,$(SSH_DIR)/devcontainer)
	$(call chmod_files,$(SSH_DIR),$(SSH_FILES))
	@if [ "$(EXPLICIT_GOALS)" = "ssh" ]; then printf 'ssh setup complete\n'; fi

shell: check-shell install-shell

check-shell:
	@bash $(SCRIPTS_DIR)/check.sh report-shell "$(DOTFILES)" "$(KITTY_BIN)" "$(AEROSPACE_BIN)" "$(SSH_CHECK_HOST)"

install-shell:
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

vim: check-vim install-vim

check-vim:
	@:

install-vim:
	$(call link_file,$(DOTFILES)/vim/.vimrc,$(VIMRC))
	@if [ "$(EXPLICIT_GOALS)" = "vim" ]; then printf 'vim setup complete\n'; fi

check:
	@bash $(SCRIPTS_DIR)/check.sh report "$(DOTFILES)" "$(KITTY_BIN)" "$(AEROSPACE_BIN)" "$(SSH_CHECK_HOST)"

uninstall:
	@$(SCRIPTS_DIR)/uninstall.sh "$(SHELL_INIT_SOURCE)" "$(SHELL_DIR)" "$(KITTY_DIR)" "$(TMUX_DIR)" "$(GIT_DIR)" "$(PECO_DIR)" "$(SSH_DIR)" "$(VIMRC)" "$(AEROSPACE_CONFIG)"
