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

check_min_version() {
	label="$1"
	current="$2"
	required="$3"

	if awk -v current="$current" -v required="$required" 'BEGIN {
		n = split(current, c, "."); split(required, r, ".")
		for (i = 1; i <= 3; i++) {
			cv = i <= n ? c[i] + 0 : 0
			rv = r[i] + 0
			if (cv > rv) exit 0
			if (cv < rv) exit 1
		}
		exit 0
	}'; then
		printf '%-24s[%s]\n' "$label >= $required" "OK"
	else
		printf '%-24s[%s]\n' "$label >= $required" "FAIL"
		missing=1
	fi
}

check_required stow
check_required bash
check_required ssh
check_required git
check_required awk

if command -v git >/dev/null 2>&1; then
	check_min_version git "$(git --version | awk '{ print $3 }')" 2.37
fi
if command -v nvim >/dev/null 2>&1; then
	nvim_version="$(nvim --version | awk 'NR == 1 { sub(/^v/, "", $2); print $2 }')"
	if awk -v current="$nvim_version" 'BEGIN { split(current, v, "."); exit !((v[1] + 0) > 0 || (v[2] + 0) >= 12) }'; then
		printf '%-24s[%s]\n' "nvim >= 0.12" "OK"
	else
		printf '%-24s[%s]\n' "nvim >= 0.12" "WARN"
	fi
else
	check_optional nvim
fi

check_optional tmux
check_optional kitty
check_optional npx

if [[ "$(uname -s)" == "Darwin" ]]; then
	check_optional aerospace
fi

exit "$missing"
