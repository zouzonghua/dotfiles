UNAME_S := $(shell uname -s)
PROFILE ?= server

ifeq ($(UNAME_S),Darwin)
PROFILE := desktop
endif

PACKAGES_CLI := git shell ssh tmux vim nvim gemini codex pi
PACKAGES_GUI := kitty
PACKAGES_DARWIN := aerospace
PACKAGES := $(PACKAGES_CLI)

ifeq ($(PROFILE),desktop)
PACKAGES += $(PACKAGES_GUI)
endif

ifeq ($(UNAME_S),Darwin)
PACKAGES += $(PACKAGES_DARWIN)
endif

STOW := stow --no-folding -t "$(HOME)"

.PHONY: install desktop dry-run uninstall setup check $(PACKAGES_CLI) $(PACKAGES_GUI) $(PACKAGES_DARWIN)

.DEFAULT_GOAL := help

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install    Install; fail safely on conflicts"
	@echo "  desktop    Install all CLI + GUI packages"
	@echo "  dry-run    Validate installation without changing HOME"
	@echo "  setup      Run post-install configuration (Git, SSH, Shell)"
	@echo "  check      Verify required dependencies"
	@echo "  uninstall  Remove symlinks and cleanup configurations"
	@echo "  <package>  Install a specific package (e.g., make tmux)"
	@echo ""
	@echo "Profiles:"
	@echo "  PROFILE=server (default on Linux)"
	@echo "  PROFILE=desktop (default on macOS)"

install: check
	@bash scripts/preflight.sh $(PACKAGES)
	$(STOW) --restow $(PACKAGES)
	$(MAKE) setup

desktop:
	$(MAKE) install PROFILE=desktop

dry-run: check
	@bash scripts/preflight.sh $(PACKAGES)

$(PACKAGES_CLI) $(PACKAGES_GUI) $(PACKAGES_DARWIN): check
	@bash scripts/preflight.sh $@
	$(STOW) --restow $@
	$(MAKE) setup

setup:
	@bash scripts/setup.sh

check:
	@bash scripts/check.sh

uninstall: check
	@bash scripts/uninstall.sh --check
	$(STOW) -D $(PACKAGES_CLI) $(PACKAGES_GUI) $(PACKAGES_DARWIN)
	@bash scripts/uninstall.sh
