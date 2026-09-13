#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$script_dir")"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

run_make() {
	local home="$1"
	shift
	if ! HOME="$home" make -s --no-print-directory -C "$repo_root" "$@" > "${tmp_dir}/make.log" 2>&1; then
		cat "${tmp_dir}/make.log" >&2
		return 1
	fi
}

# Full install must be repeatable and uninstall must restore rc files exactly.
full_home="${tmp_dir}/full-home"
mkdir -p "${full_home}/.ssh"
printf 'ssh-ed25519 AAAATEST personal\n' > "${full_home}/.ssh/id_ed25519_personal.pub"
printf 'ssh-ed25519 AAAATEST work\n' > "${full_home}/.ssh/id_ed25519_work.pub"
printf 'without-newline' > "${full_home}/.bashrc"
printf 'with-newline\n' > "${full_home}/.zshrc"
cp "${full_home}/.bashrc" "${tmp_dir}/bashrc.before"
cp "${full_home}/.zshrc" "${tmp_dir}/zshrc.before"

run_make "$full_home" PROFILE=server dry-run
run_make "$full_home" PROFILE=server install
run_make "$full_home" PROFILE=server install
run_make "$full_home" PROFILE=server uninstall
cmp -s "${full_home}/.bashrc" "${tmp_dir}/bashrc.before"
cmp -s "${full_home}/.zshrc" "${tmp_dir}/zshrc.before"
[[ -z "$(find "$full_home" -type l -print -quit)" ]]

# A single package must not trigger unrelated Shell or SSH setup.
scoped_home="${tmp_dir}/scoped-home"
mkdir -p "${scoped_home}/.config/shell" "${scoped_home}/.ssh"
: > "${scoped_home}/.config/shell/init.sh"
printf '%s\n%s\n%s\n' \
	'# END ZOUZONGHUA DOTFILES' \
	'# BEGIN ZOUZONGHUA DOTFILES' \
	'[ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh' > "${scoped_home}/.bashrc"
: > "${scoped_home}/.zshrc"
printf 'LocalForward 8080 localhost:8080\n' > "${scoped_home}/.ssh/config.local"
chmod 644 "${scoped_home}/.ssh/config.local"
cp "${scoped_home}/.bashrc" "${tmp_dir}/scoped-bashrc.before"

run_make "$scoped_home" tmux
cmp -s "${scoped_home}/.bashrc" "${tmp_dir}/scoped-bashrc.before"
find "${scoped_home}/.ssh/config.local" -perm 0644 -print -quit | grep -q .
if HOME="$scoped_home" make -s --no-print-directory -C "$repo_root" shell >/dev/null 2>&1; then
	printf 'error: malformed Shell block was accepted\n' >&2
	exit 1
fi

# Installed tmux configuration must load successfully.
tmux_socket="dotfiles-test-$$"
HOME="$scoped_home" tmux -L "$tmux_socket" -f "${scoped_home}/.config/tmux/tmux.conf" new-session -d -s dotfiles-test
HOME="$scoped_home" tmux -L "$tmux_socket" kill-server

printf 'all tests passed\n'
