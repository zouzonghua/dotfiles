SHELL := /bin/bash

DOTFILES := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

GHOSTTY_BIN := $(firstword $(wildcard /Applications/Ghostty.app/Contents/MacOS/ghostty) $(shell command -v ghostty 2>/dev/null))
GHOSTTY_DIR := $(HOME)/.config/ghostty
HAMMERSPOON_DIR := $(HOME)/.hammerspoon
HAMMERSPOON_SPOONS_DIR := $(HAMMERSPOON_DIR)/Spoons
PAPERWM_SPOON := $(HAMMERSPOON_DIR)/Spoons/PaperWM.spoon
SPACEINDICATOR_SPOON := $(HAMMERSPOON_DIR)/Spoons/SpaceIndicator.spoon
GIT_DIR := $(HOME)/.config/git
PECO_DIR := $(HOME)/.config/peco
SHELL_DIR := $(HOME)/.config/shell
TMUX_DIR := $(HOME)/.config/tmux
SSH_DIR := $(HOME)/.ssh
VIMRC := $(HOME)/.vimrc

GHOSTTY_FILES := config
GIT_FILES := config work.identity personal.identity personal.devcontainer work.devcontainer
PECO_FILES := config.json
SHELL_FILES := init.sh aliases.sh prompt.sh history.sh
TMUX_FILES := tmux.conf conf bin
SSH_FILES := config devcontainer
SSH_CHECK_HOST := github-personal

.PHONY: ghostty hammerspoon git peco tmux ssh shell vim check uninstall all

all: ghostty hammerspoon git peco tmux ssh shell vim

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

define link_files
$(foreach file,$(3),$(call link_file,$(1)/$(file),$(2)/$(file)))
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

define print_check
	@printf '%-32s' 'check $(1)'
endef

define print_check_ok
	@printf '[ok]\n'
endef

define print_check_skip
	@printf '[skip]\n'
endef

define run_check
	@printf '%-32s' 'check $(1)'; \
	tmp=$$(mktemp); \
	if { $(2); } > /dev/null 2>"$$tmp"; then \
		printf '[ok]\n'; \
		rm -f "$$tmp"; \
	else \
		printf '[err]\n'; \
		cat "$$tmp" >&2; \
		rm -f "$$tmp"; \
		exit 1; \
	fi
endef

ghostty:
	@mkdir -p $(GHOSTTY_DIR)
	$(call link_files,$(DOTFILES)/ghostty,$(GHOSTTY_DIR),$(GHOSTTY_FILES))
	@if [ "$(EXPLICIT_GOALS)" = "ghostty" ]; then printf 'ghostty setup complete\n'; fi

hammerspoon:
	@mkdir -p $(HAMMERSPOON_DIR) $(HAMMERSPOON_SPOONS_DIR)
	$(call link_file,$(DOTFILES)/hammerspoon/init.lua,$(HAMMERSPOON_DIR)/init.lua)
	$(call spoon_hint,PaperWM.spoon,$(PAPERWM_SPOON),https://github.com/mogenson/PaperWM.spoon.git)
	$(call spoon_hint,SpaceIndicator.spoon,$(SPACEINDICATOR_SPOON),https://github.com/zouzonghua/SpaceIndicator.spoon.git)
	@if [ "$(EXPLICIT_GOALS)" = "hammerspoon" ]; then printf 'hammerspoon setup complete\n'; fi

git:
	@mkdir -p $(GIT_DIR)
	$(call link_files,$(DOTFILES)/git,$(GIT_DIR),$(GIT_FILES))
	@if [ "$(EXPLICIT_GOALS)" = "git" ]; then printf 'git setup complete\n'; fi

peco:
	@mkdir -p $(PECO_DIR)
	$(call link_files,$(DOTFILES)/peco,$(PECO_DIR),$(PECO_FILES))
	@if [ "$(EXPLICIT_GOALS)" = "peco" ]; then printf 'peco setup complete\n'; fi

tmux:
	@mkdir -p $(TMUX_DIR)
	$(call link_files,$(DOTFILES)/tmux,$(TMUX_DIR),$(TMUX_FILES))
	@if [ "$(EXPLICIT_GOALS)" = "tmux" ]; then \
		printf 'tmux setup complete\n'; \
		printf 'reload tmux with: tmux source-file ~/.config/tmux/tmux.conf\n'; \
	fi

ssh:
	@mkdir -p $(SSH_DIR)
	$(call link_files,$(DOTFILES)/ssh,$(SSH_DIR),$(SSH_FILES))
	$(call chmod_files,$(SSH_DIR),$(SSH_FILES))
	@if [ "$(EXPLICIT_GOALS)" = "ssh" ]; then printf 'ssh setup complete\n'; fi

shell:
	@mkdir -p $(SHELL_DIR)
	$(call link_files,$(DOTFILES)/shell,$(SHELL_DIR),$(SHELL_FILES))
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
	@if [ -n "$(GHOSTTY_BIN)" ]; then \
		printf '%-32s' 'check ghostty config'; \
		tmp=$$(mktemp); \
		if { "$(GHOSTTY_BIN)" +validate-config --config-file="$(DOTFILES)/ghostty/config"; } > /dev/null 2>"$$tmp"; then \
			printf '[ok]\n'; \
			rm -f "$$tmp"; \
		else \
			printf '[err]\n'; \
			cat "$$tmp" >&2; \
			rm -f "$$tmp"; \
			exit 1; \
		fi; \
	else \
		printf '%-32s[skip]\n' 'check ghostty config'; \
	fi
	$(call run_check,ssh config,ssh -T -F $(DOTFILES)/ssh/config -G $(SSH_CHECK_HOST))
	$(call run_check,ssh devcontainer,ssh -T -F $(DOTFILES)/ssh/devcontainer -G $(SSH_CHECK_HOST))
	$(call run_check,shell scripts,bash -n $(DOTFILES)/shell/*.sh)
	$(call run_check,tmux scripts,bash -n $(DOTFILES)/tmux/bin/*.sh)
	$(call run_check,tmux config,for file in $(DOTFILES)/tmux/conf/*.conf $(DOTFILES)/tmux/tmux.conf; do tmux -f /dev/null source-file -n "$$file"; done)

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
	for file in $(SHELL_FILES); do restore_link "$(SHELL_DIR)/$$file"; done; \
	for file in $(GHOSTTY_FILES); do restore_link "$(GHOSTTY_DIR)/$$file"; done; \
	restore_link "$(HAMMERSPOON_DIR)/init.lua"; \
	for file in $(TMUX_FILES); do restore_link "$(TMUX_DIR)/$$file"; done; \
	for file in $(GIT_FILES); do restore_link "$(GIT_DIR)/$$file"; done; \
	for file in $(PECO_FILES); do restore_link "$(PECO_DIR)/$$file"; done; \
	for file in $(SSH_FILES); do restore_link "$(SSH_DIR)/$$file"; done; \
	restore_link "$(VIMRC)"; \
	printf 'uninstall complete\n'
