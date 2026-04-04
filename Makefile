SHELL := /bin/bash

DOTFILES := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

GIT_DIR := $(HOME)/.config/git
SHELL_DIR := $(HOME)/.config/shell
TMUX_DIR := $(HOME)/.config/tmux
SSH_DIR := $(HOME)/.ssh
VIMRC := $(HOME)/.vimrc

.PHONY: git tmux ssh shell vim check uninstall all

all: git tmux ssh shell vim

SHELL_INIT_SOURCE := [ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh
EXPLICIT_GOALS := $(filter-out all,$(MAKECMDGOALS))

define link_file
	@if [ -e $(2) ] && [ ! -L $(2) ]; then \
		echo "backup $(2)"; \
		mv $(2) $(2).backup; \
	fi
	@ln -sfn $(1) $(2)
endef

git:
	@mkdir -p $(GIT_DIR)
	$(call link_file,$(DOTFILES)/git/config,$(GIT_DIR)/config)
	$(call link_file,$(DOTFILES)/git/work,$(GIT_DIR)/work)
	$(call link_file,$(DOTFILES)/git/personal,$(GIT_DIR)/personal)
	@if [ "$(EXPLICIT_GOALS)" = "git" ]; then printf 'git setup complete\n'; fi

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
	@if [ -f $(SSH_DIR)/config ]; then chmod 600 $(SSH_DIR)/config; fi
	@if [ "$(EXPLICIT_GOALS)" = "ssh" ]; then printf 'ssh setup complete\n'; fi

shell:
	@mkdir -p $(SHELL_DIR)
	$(call link_file,$(DOTFILES)/shell/init.sh,$(SHELL_DIR)/init.sh)
	$(call link_file,$(DOTFILES)/shell/prompt.sh,$(SHELL_DIR)/prompt.sh)
	$(call link_file,$(DOTFILES)/shell/history.sh,$(SHELL_DIR)/history.sh)
	@ensure_line() { \
		file="$$1"; \
		comment="$$2"; \
		line="$$3"; \
		touch "$$file"; \
		if ! grep -Fqx "$$line" "$$file"; then \
			printf '\n%s\n%s\n' "$$comment" "$$line" >> "$$file"; \
		fi; \
	}; \
	case "$${SHELL##*/}" in \
		zsh) \
			ensure_line "$(HOME)/.zshrc" '# shell init' '$(SHELL_INIT_SOURCE)' \
			;; \
		bash) \
			ensure_line "$(HOME)/.bashrc" '# shell init' '$(SHELL_INIT_SOURCE)' \
			;; \
		*) \
			echo "skip rc injection for unsupported shell: $$SHELL"; \
			;; \
	esac
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
	@bash -n $(DOTFILES)/tmux/bin/*.sh
	@tmux -f /dev/null source-file -n $(DOTFILES)/tmux/tmux.conf

uninstall:
	@cleanup_line() { \
		file="$$1"; \
		comment="$$2"; \
		line="$$3"; \
		[ -f "$$file" ] || return 0; \
		tmp="$${file}.tmp"; \
		awk -v comment="$$comment" -v line="$$line" ' \
			$$0 == comment { getline nextline; if (nextline == line) next; print; $$0 = nextline } \
			$$0 != line { print } \
		' "$$file" > "$$tmp"; \
		mv "$$tmp" "$$file"; \
	}; \
	restore_link() { \
		path="$$1"; \
		if [ -L "$$path" ]; then \
			rm -f "$$path"; \
		fi; \
		if [ -e "$$path.backup" ]; then \
			mv "$$path.backup" "$$path"; \
		fi; \
	}; \
	cleanup_line "$(HOME)/.zshrc" '# shell init' '$(SHELL_INIT_SOURCE)'; \
	cleanup_line "$(HOME)/.bashrc" '# shell init' '$(SHELL_INIT_SOURCE)'; \
	restore_link "$(SHELL_DIR)/init.sh"; \
	restore_link "$(SHELL_DIR)/prompt.sh"; \
	restore_link "$(SHELL_DIR)/history.sh"; \
	restore_link "$(TMUX_DIR)/tmux.conf"; \
	restore_link "$(TMUX_DIR)/conf"; \
	restore_link "$(TMUX_DIR)/bin"; \
	restore_link "$(GIT_DIR)/config"; \
	restore_link "$(GIT_DIR)/work"; \
	restore_link "$(GIT_DIR)/personal"; \
	restore_link "$(SSH_DIR)/config"; \
	restore_link "$(VIMRC)"; \
	printf 'uninstall complete\n'
