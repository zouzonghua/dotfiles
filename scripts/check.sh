#!/bin/bash

set -euo pipefail

missing=0

check_required() {
	command_name="$1"

	if command -v "$command_name" > /dev/null 2>&1; then
		printf '%-24s[%s]\n' "$command_name" "OK"
		return 0
	fi

	printf '%-24s[%s]\n' "$command_name" "FAIL"
	missing=1
}

check_optional() {
	command_name="$1"

	if command -v "$command_name" > /dev/null 2>&1; then
		printf '%-24s[%s]\n' "$command_name" "OK"
	else
		printf '%-24s[%s]\n' "$command_name" "SKIP"
	fi
}

check_required stow
check_required bash
check_required ssh

check_optional git
check_optional kitty
check_optional peco
check_optional tmux

if [[ "$(uname -s)" == "Darwin" ]]; then
	check_optional aerospace
fi

exit "$missing"
