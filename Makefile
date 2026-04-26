UNAME_S := $(shell uname -s)
PACKAGES_CORE := git kitty peco shell ssh tmux vim
PACKAGES_DARWIN := aerospace
PACKAGES := $(PACKAGES_CORE)

ifeq ($(UNAME_S),Darwin)
PACKAGES += $(PACKAGES_DARWIN)
endif

STOW := stow --no-folding -t "$(HOME)"

.PHONY: install uninstall setup check $(PACKAGES_CORE) $(PACKAGES_DARWIN)

install: check
	$(STOW) $(PACKAGES)
	$(MAKE) setup

$(PACKAGES_CORE) $(PACKAGES_DARWIN):
	$(STOW) $@
	$(MAKE) setup

setup:
	@bash scripts/setup.sh

check:
	@bash scripts/check.sh

uninstall:
	$(STOW) -D $(PACKAGES_CORE) $(PACKAGES_DARWIN)
	@bash scripts/uninstall.sh
