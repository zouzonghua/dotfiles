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

expect_make_failure() {
	local home="$1"
	shift
	if HOME="$home" make -s --no-print-directory -C "$repo_root" "$@" >/dev/null 2>&1; then
		printf 'error: command unexpectedly succeeded: make %s\n' "$*" >&2
		exit 1
	fi
}

# Optional version failures must warn; required version failures must fail.
fake_bin="${tmp_dir}/fake-bin"
mkdir -p "$fake_bin"
printf '%s\n' '#!/bin/sh' "printf 'NVIM v0.11.4\\n'" > "${fake_bin}/nvim"
chmod +x "${fake_bin}/nvim"
PATH="${fake_bin}:$PATH" bash "${repo_root}/scripts/check.sh" > "${tmp_dir}/nvim-check.out"
grep -Fq 'nvim >= 0.12            [WARN]' "${tmp_dir}/nvim-check.out"

printf '%s\n' '#!/bin/sh' "printf 'git version 2.36.0\\n'" > "${fake_bin}/git"
chmod +x "${fake_bin}/git"
if PATH="${fake_bin}:$PATH" bash "${repo_root}/scripts/check.sh" git > "${tmp_dir}/git-check.out"; then
	printf 'error: unsupported Git version was accepted\n' >&2
	exit 1
fi
grep -Fq 'git >= 2.37             [FAIL]' "${tmp_dir}/git-check.out"

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
[[ "$(tail -n 3 "${full_home}/.bashrc")" == "$(printf '%s\n%s\n%s' '# BEGIN ZOUZONGHUA DOTFILES' '[ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh' '# END ZOUZONGHUA DOTFILES')" ]]
[[ "$(tail -n 3 "${full_home}/.zshrc")" == "$(printf '%s\n%s\n%s' '# BEGIN ZOUZONGHUA DOTFILES' '[ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh' '# END ZOUZONGHUA DOTFILES')" ]]
allowed_signers="${full_home}/.config/git/allowed_signers"
signer_state="${full_home}/.local/state/dotfiles/allowed_signers.generated"
grep -Fq 'zouzonghua.cn@gmail.com' "$allowed_signers"
grep -Fq 'zonghuazou@ddmarketinghub.com' "$allowed_signers"
find "$allowed_signers" -perm 0600 -print -quit | grep -q .
find "$signer_state" -perm 0600 -print -quit | grep -q .
run_make "$full_home" PROFILE=server install
run_make "$full_home" PROFILE=server uninstall
cmp -s "${full_home}/.bashrc" "${tmp_dir}/bashrc.before"
cmp -s "${full_home}/.zshrc" "${tmp_dir}/zshrc.before"
[[ ! -e "$allowed_signers" ]]
[[ ! -e "$signer_state" ]]
[[ -z "$(find "$full_home" -type l -print -quit)" ]]

# Stow conflicts must fail without modifying user data or creating partial links.
conflict_home="${tmp_dir}/conflict-home"
mkdir -p "${conflict_home}/.config/tmux"
printf 'user tmux config\n' > "${conflict_home}/.config/tmux/tmux.conf"
cp "${conflict_home}/.config/tmux/tmux.conf" "${tmp_dir}/tmux.conf.before"
expect_make_failure "$conflict_home" tmux
cmp -s "${conflict_home}/.config/tmux/tmux.conf" "${tmp_dir}/tmux.conf.before"
[[ -z "$(find "$conflict_home" -type l -print -quit)" ]]

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
expect_make_failure "$scoped_home" shell

# Modified managed blocks must never be overwritten or removed.
modified_home="${tmp_dir}/modified-home"
mkdir -p "$modified_home"
printf '%s\n%s\n%s\n' \
	'# BEGIN ZOUZONGHUA DOTFILES' \
	'echo user-modification' \
	'# END ZOUZONGHUA DOTFILES' > "${modified_home}/.bashrc"
: > "${modified_home}/.zshrc"
cp "${modified_home}/.bashrc" "${tmp_dir}/modified-bashrc.before"
if HOME="$modified_home" bash "${repo_root}/scripts/setup.sh" --check shell >/dev/null 2>&1; then
	printf 'error: modified Shell block was accepted by setup\n' >&2
	exit 1
fi
if HOME="$modified_home" bash "${repo_root}/scripts/uninstall.sh" --check >/dev/null 2>&1; then
	printf 'error: modified Shell block was accepted by uninstall\n' >&2
	exit 1
fi
cmp -s "${modified_home}/.bashrc" "${tmp_dir}/modified-bashrc.before"

# User-modified allowed_signers must survive uninstall.
signing_home="${tmp_dir}/signing-home"
mkdir -p "${signing_home}/.ssh"
printf 'ssh-ed25519 AAAATEST personal\n' > "${signing_home}/.ssh/id_ed25519_personal.pub"
printf 'ssh-ed25519 AAAATEST work\n' > "${signing_home}/.ssh/id_ed25519_work.pub"
run_make "$signing_home" git
printf '# user modification\n' >> "${signing_home}/.config/git/allowed_signers"
cp "${signing_home}/.config/git/allowed_signers" "${tmp_dir}/modified-signers.before"
run_make "$signing_home" uninstall
cmp -s "${signing_home}/.config/git/allowed_signers" "${tmp_dir}/modified-signers.before"
[[ ! -e "${signing_home}/.local/state/dotfiles/allowed_signers.generated" ]]

# Installed tmux configuration must load successfully.
tmux_socket="dotfiles-test-$$"
HOME="$scoped_home" tmux -L "$tmux_socket" -f "${scoped_home}/.config/tmux/tmux.conf" new-session -d -s dotfiles-test
HOME="$scoped_home" tmux -L "$tmux_socket" kill-server

printf 'all tests passed\n'
