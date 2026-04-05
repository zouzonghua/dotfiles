SHELL := /bin/bash

DOTFILES := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

ALACRITTY_DIR := $(HOME)/.config/alacritty
GIT_DIR := $(HOME)/.config/git
PECO_DIR := $(HOME)/.config/peco
SHELL_DIR := $(HOME)/.config/shell
TMUX_DIR := $(HOME)/.config/tmux
SSH_DIR := $(HOME)/.ssh
VIMRC := $(HOME)/.vimrc

.PHONY: alacritty git peco tmux ssh shell vim check uninstall all

all: alacritty git peco tmux ssh shell vim

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

alacritty:
	@mkdir -p $(ALACRITTY_DIR)
	$(call link_file,$(DOTFILES)/alacritty/alacritty.toml,$(ALACRITTY_DIR)/alacritty.toml)
	$(call link_file,$(DOTFILES)/alacritty/bin,$(ALACRITTY_DIR)/bin)
	$(call link_file,$(DOTFILES)/alacritty/selenized-white.toml,$(ALACRITTY_DIR)/selenized-white.toml)
	$(call link_file,$(DOTFILES)/alacritty/selenized-dark.toml,$(ALACRITTY_DIR)/selenized-dark.toml)
	@$(ALACRITTY_DIR)/bin/theme_sync.sh
	@if [ "$(EXPLICIT_GOALS)" = "alacritty" ]; then printf 'alacritty setup complete\n'; fi

git:
	@mkdir -p $(GIT_DIR)
	$(call link_file,$(DOTFILES)/git/config,$(GIT_DIR)/config)
	$(call link_file,$(DOTFILES)/git/work,$(GIT_DIR)/work)
	$(call link_file,$(DOTFILES)/git/personal,$(GIT_DIR)/personal)
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
	@if [ -f $(SSH_DIR)/config ]; then chmod 600 $(SSH_DIR)/config; fi
	@if [ "$(EXPLICIT_GOALS)" = "ssh" ]; then printf 'ssh setup complete\n'; fi

shell:
	@mkdir -p $(SHELL_DIR)
	$(call link_file,$(DOTFILES)/shell/init.sh,$(SHELL_DIR)/init.sh)
	$(call link_file,$(DOTFILES)/shell/aliases.sh,$(SHELL_DIR)/aliases.sh)
	$(call link_file,$(DOTFILES)/shell/prompt.sh,$(SHELL_DIR)/prompt.sh)
	$(call link_file,$(DOTFILES)/shell/history.sh,$(SHELL_DIR)/history.sh)
	$(call link_file,$(DOTFILES)/shell/alacritty.sh,$(SHELL_DIR)/alacritty.sh)
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
	@bash -n $(DOTFILES)/alacritty/bin/*.sh
	@tmux -f /dev/null source-file -n $(DOTFILES)/tmux/tmux.conf

uninstall:
	@cleanup_line() { \
		file="$$1"; \
		comment="$$2"; \
		line="$$3"; \
		[ -f "$$file" ] || return 0; \
		tmp="$${file}.tmp"; \
		awk -v comment="$$comment" -v line="$$line" ' \
			prev == comment && $$0 == line { prev = ""; next } \
			prev != ""                     { print prev } \
			                               { prev = $$0 } \
			END                            { if (prev != "") print prev } \
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
	restore_link "$(SHELL_DIR)/aliases.sh"; \
	restore_link "$(SHELL_DIR)/prompt.sh"; \
	restore_link "$(SHELL_DIR)/history.sh"; \
	restore_link "$(SHELL_DIR)/alacritty.sh"; \
	restore_link "$(ALACRITTY_DIR)/alacritty.toml"; \
	restore_link "$(ALACRITTY_DIR)/bin"; \
	restore_link "$(ALACRITTY_DIR)/selenized-white.toml"; \
	restore_link "$(ALACRITTY_DIR)/selenized-dark.toml"; \
	rm -f "$(ALACRITTY_DIR)/theme-active.generated.toml" "$(ALACRITTY_DIR)/.theme-sync.pid"; \
	restore_link "$(TMUX_DIR)/tmux.conf"; \
	restore_link "$(TMUX_DIR)/conf"; \
	restore_link "$(TMUX_DIR)/bin"; \
	restore_link "$(GIT_DIR)/config"; \
	restore_link "$(GIT_DIR)/work"; \
	restore_link "$(GIT_DIR)/personal"; \
	restore_link "$(PECO_DIR)/config.json"; \
	restore_link "$(SSH_DIR)/config"; \
	restore_link "$(VIMRC)"; \
	printf 'uninstall complete\n'
