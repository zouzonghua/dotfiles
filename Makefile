UNAME_S := $(shell uname -s)
PROFILE ?= server

ifeq ($(UNAME_S),Darwin)
PROFILE := desktop
endif

PACKAGES_CLI := git peco shell ssh tmux vim
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

.PHONY: install desktop uninstall setup check $(PACKAGES_CLI) $(PACKAGES_GUI) $(PACKAGES_DARWIN)

install: check
	$(STOW) $(PACKAGES)
	$(MAKE) setup

desktop:
	$(MAKE) install PROFILE=desktop

$(PACKAGES_CLI) $(PACKAGES_GUI) $(PACKAGES_DARWIN):
	$(STOW) $@
	$(MAKE) setup

setup:
	@bash scripts/setup.sh

check:
	@bash scripts/check.sh

uninstall:
	$(STOW) -D $(PACKAGES_CLI) $(PACKAGES_GUI) $(PACKAGES_DARWIN)
	@bash scripts/uninstall.sh
