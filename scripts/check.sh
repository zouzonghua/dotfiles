#!/bin/bash

set -euo pipefail

dotfiles_dir="$1"
ghostty_bin="${2:-}"
ssh_check_host="$3"

print_status() {
	label="$1"
	status="$2"
	printf '%-32s[%s]\n' "check ${label}" "$status"
}

run_check() {
	label="$1"
	shift

	tmp="$(mktemp)"
	if "$@" > /dev/null 2>"$tmp"; then
		print_status "$label" "OK"
		rm -f "$tmp"
	else
		print_status "$label" "FAIL"
		cat "$tmp" >&2
		rm -f "$tmp"
		exit 1
	fi
}

run_check_shell() {
	label="$1"
	command="$2"

	tmp="$(mktemp)"
	if bash -lc "$command" > /dev/null 2>"$tmp"; then
		print_status "$label" "OK"
		rm -f "$tmp"
	else
		print_status "$label" "FAIL"
		cat "$tmp" >&2
		rm -f "$tmp"
		exit 1
	fi
}

if [[ -n "$ghostty_bin" ]]; then
	run_check "ghostty config" "$ghostty_bin" +validate-config --config-file="${dotfiles_dir}/ghostty/config"
else
	print_status "ghostty config" "SKIP"
fi

run_check "ssh config" ssh -T -F "${dotfiles_dir}/ssh/config" -G "$ssh_check_host"
run_check "ssh devcontainer" ssh -T -F "${dotfiles_dir}/ssh/devcontainer" -G "$ssh_check_host"
run_check_shell "shell scripts" "bash -n '${dotfiles_dir}'/shell/*.sh"
run_check_shell "tmux scripts" "bash -n '${dotfiles_dir}'/tmux/bin/*.sh"
run_check_shell "tmux config" "for file in '${dotfiles_dir}'/tmux/conf/*.conf '${dotfiles_dir}'/tmux/tmux.conf; do tmux -f /dev/null source-file -n \"\$file\"; done"
