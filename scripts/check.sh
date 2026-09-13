#!/bin/bash

set -euo pipefail

missing=0

check_required() {
	local command_name="$1"

	if command -v "$command_name" > /dev/null 2>&1; then
		printf '%-24s[%s]\n' "$command_name" "OK"
		return 0
	fi

	printf '%-24s[%s]\n' "$command_name" "FAIL"
	missing=1
}

check_optional() {
	local command_name="$1"

	if command -v "$command_name" > /dev/null 2>&1; then
		printf '%-24s[%s]\n' "$command_name" "OK"
	else
		printf '%-24s[%s]\n' "$command_name" "SKIP"
	fi
}

check_min_version() {
	local label="$1"
	local current="$2"
	local required="$3"
	local failure_status="${4-FAIL}"

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
		printf '%-24s[%s]\n' "$label >= $required" "$failure_status"
		if [[ "$failure_status" == "FAIL" ]]; then
			missing=1
		fi
	fi
}

check_required stow
check_required bash

if [[ "${1-}" == "git" ]]; then
	check_required git
	check_required awk
	if command -v git >/dev/null 2>&1; then
		check_min_version git "$(git --version | awk '{ print $3 }')" 2.37
	fi
	exit "$missing"
fi

check_required ssh
check_required git
check_required awk

if command -v git >/dev/null 2>&1; then
	check_min_version git "$(git --version | awk '{ print $3 }')" 2.37
fi
if command -v nvim >/dev/null 2>&1; then
	nvim_version="$(nvim --version | awk 'NR == 1 { sub(/^v/, "", $2); print $2 }')"
	check_min_version nvim "$nvim_version" 0.12 WARN
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
