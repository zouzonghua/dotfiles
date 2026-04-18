#!/bin/bash

set -euo pipefail

mode="${1:-report}"
dotfiles_dir="$2"
ghostty_bin="${3:-}"
kitty_bin="${4:-}"
aerospace_bin="${5:-}"
ssh_check_host="$6"
make_bin="${7:-make}"

print_status() {
	label="$1"
	status="$2"
	printf '%-32s[%s]\n' "check ${label}" "$status"
}

print_skip() {
	label="$1"
	reason="$2"
	printf '%-32s[%s]\n' "check ${label}" "SKIP"
	printf '  %s\n' "$reason"
}

print_install_status() {
	label="$1"
	status="$2"
	printf '%-32s[%s]\n' "install ${label}" "$status"
}

print_install_skip() {
	label="$1"
	reason="$2"
	printf '%-32s[%s]\n' "install ${label}" "SKIP"
	printf '  %s\n' "$reason"
}

command_exists() {
	command -v "$1" > /dev/null 2>&1
}

selected_targets=()

add_target() {
	selected_targets+=("$1")
}

has_target() {
	target="$1"
	for selected in "${selected_targets[@]}"; do
		if [[ "$selected" == "$target" ]]; then
			return 0
		fi
	done
	return 1
}

require_command() {
	label="$1"
	command_name="$2"

	if command_exists "$command_name"; then
		print_status "$label installed" "OK"
		return 0
	fi

	print_status "$label installed" "FAIL"
	printf 'missing required command: %s\n' "$command_name" >&2
	return 1
}

optional_command() {
	label="$1"
	command_name="$2"

	if command_exists "$command_name"; then
		print_status "$label installed" "OK"
		return 0
	fi

	print_skip "$label installed" "missing optional command: $command_name"
	return 1
}

run_check() {
	label="$1"
	shift

	tmp="$(mktemp)"
	if "$@" > /dev/null 2>"$tmp"; then
		print_status "$label" "OK"
		rm -f "$tmp"
		return 0
	fi

	print_status "$label" "FAIL"
	cat "$tmp" >&2
	rm -f "$tmp"
	return 1
}

run_check_shell() {
	label="$1"
	command="$2"

	tmp="$(mktemp)"
	if bash -lc "$command" > /dev/null 2>"$tmp"; then
		print_status "$label" "OK"
		rm -f "$tmp"
		return 0
	fi

	print_status "$label" "FAIL"
	cat "$tmp" >&2
	rm -f "$tmp"
	return 1
}

check_ghostty() {
	if [[ -n "$ghostty_bin" ]]; then
		print_status "ghostty installed" "OK"
		add_target "install-ghostty"
	else
		print_skip "ghostty installed" "ghostty binary not found"
		if [[ "$mode" == "install-ok" ]]; then
			print_install_skip "ghostty" "ghostty is not installed"
		fi
	fi
}

check_kitty() {
	if [[ -n "$kitty_bin" ]]; then
		print_status "kitty installed" "OK"
		if run_check "kitty config" "$kitty_bin" +runpy 'from kitty.config import load_config; import sys; load_config(*sys.argv[1:])' "${dotfiles_dir}/kitty/kitty.conf"; then
			add_target "install-kitty"
		elif [[ "$mode" == "install-ok" ]]; then
			print_install_skip "kitty" "kitty config check failed"
		fi
	else
		print_skip "kitty installed" "kitty binary not found"
		print_skip "kitty config" "kitty is not installed"
		if [[ "$mode" == "install-ok" ]]; then
			print_install_skip "kitty" "kitty is not installed"
		fi
	fi
}

check_aerospace() {
	if [[ -n "$aerospace_bin" ]]; then
		print_status "aerospace installed" "OK"
		add_target "install-aerospace"
	else
		print_skip "aerospace installed" "aerospace binary not found"
		if [[ "$mode" == "install-ok" ]]; then
			print_install_skip "aerospace" "aerospace is not installed"
		fi
	fi
}

check_ssh() {
	if require_command "ssh" ssh && run_check "ssh config" ssh -T -F "${dotfiles_dir}/ssh/config" -G "$ssh_check_host" && run_check "ssh devcontainer" ssh -T -F "${dotfiles_dir}/ssh/devcontainer" -G "$ssh_check_host"; then
		add_target "install-ssh"
	elif [[ "$mode" == "install-ok" ]]; then
		print_install_skip "ssh" "ssh checks did not pass"
	fi
}

check_shell() {
	if require_command "bash" bash && run_check_shell "shell scripts" "bash -n '${dotfiles_dir}'/shell/*.sh"; then
		add_target "install-shell"
	elif [[ "$mode" == "install-ok" ]]; then
		print_install_skip "shell" "shell checks did not pass"
	fi
}

check_tmux() {
	tmux_ready=0

	if require_command "bash" bash && run_check_shell "tmux scripts" "bash -n '${dotfiles_dir}'/tmux/bin/*.sh"; then
		if optional_command "tmux" tmux && run_check_shell "tmux config" "for file in '${dotfiles_dir}'/tmux/conf/*.conf '${dotfiles_dir}/tmux/tmux.conf'; do tmux -f /dev/null source-file -n \"\$file\"; done"; then
			tmux_ready=1
		fi
	fi

	if [[ "$tmux_ready" -eq 1 ]]; then
		add_target "install-tmux"
	elif [[ "$mode" == "install-ok" ]]; then
		print_install_skip "tmux" "tmux checks did not pass"
	fi
}

check_always_installable() {
	add_target "install-git"
	add_target "install-peco"
	add_target "install-vim"
}

run_checks_for_mode() {
	case "$mode" in
		report)
			check_ghostty
			check_kitty
			check_aerospace
			check_ssh
			check_shell
			check_tmux
			;;
		report-kitty)
			check_kitty
			;;
		report-ssh)
			check_ssh
			;;
		report-shell)
			check_shell
			;;
		report-tmux)
			check_tmux
			;;
		install-ok)
			check_ghostty
			check_kitty
			check_aerospace
			check_always_installable
			check_ssh
			check_shell
			check_tmux
			;;
		*)
			printf 'unknown check mode: %s\n' "$mode" >&2
			exit 1
			;;
	esac
}

run_checks_for_mode

if [[ "$mode" == "install-ok" ]]; then
	if has_target "install-git"; then print_install_status "git" "OK"; fi
	if has_target "install-peco"; then print_install_status "peco" "OK"; fi
	if has_target "install-vim"; then print_install_status "vim" "OK"; fi
	if has_target "install-ssh"; then print_install_status "ssh" "OK"; fi
	if has_target "install-shell"; then print_install_status "shell" "OK"; fi
	if has_target "install-tmux"; then print_install_status "tmux" "OK"; fi
	if has_target "install-ghostty"; then print_install_status "ghostty" "OK"; fi
	if has_target "install-kitty"; then print_install_status "kitty" "OK"; fi
	if has_target "install-aerospace"; then print_install_status "aerospace" "OK"; fi
	"$make_bin" -C "$dotfiles_dir" "${selected_targets[@]}"
fi
