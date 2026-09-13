#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib/shell-block.sh"

expand_path() {
	local path="$1"
	if [[ "$path" == "~" ]]; then
		printf '%s\n' "$HOME"
	elif [[ "$path" == "~/"* ]]; then
		printf '%s/%s\n' "$HOME" "${path#"~/"}"
	else
		printf '%s\n' "$path"
	fi
}

generate_allowed_signer() {
	local identity_file="$1"
	local email signingkey public_key_file key_content
	email="$(git config -f "$identity_file" user.email || true)"
	signingkey="$(git config -f "$identity_file" user.signingkey || true)"

	if [[ -z "$email" || -z "$signingkey" ]]; then
		printf 'warning: incomplete Git identity: %s\n' "$identity_file" >&2
		return 1
	fi

	public_key_file="$(expand_path "$signingkey")"
	if [[ ! -s "$public_key_file" ]]; then
		printf 'warning: public signing key not found: %s\n' "$public_key_file" >&2
		return 1
	fi

	key_content="$(cat "$public_key_file")"
	printf '%s %s\n' "$email" "$key_content"
}

ensure_block() {
	local file="$1"
	local content="$2"
	local tmp_file
	touch "$file"
	[[ "$(head -n 1 "$file")" == "$block_start" ]] && return 0

	tmp_file="$(mktemp)"
	printf '%s\n%s\n%s\n' "$block_start" "$content" "$block_end" > "$tmp_file"
	if grep -Fqx "$block_start" "$file"; then
		awk -v start="$block_start" -v end="$block_end" '
			$0 == start { skip = 1; next }
			$0 == end   { skip = 0; next }
			!skip       { print }
		' "$file" >> "$tmp_file"
	else
		cat "$file" >> "$tmp_file"
	fi
	cat "$tmp_file" > "$file"
	rm -f "$tmp_file"
}

setup_git_signing() {
	local check_only="${1-}"
	local -a identities=(
		"${HOME}/.config/git/personal.identity"
		"${HOME}/.config/git/work.identity"
	)
	local tmp_file identity_file target state_dir state_file
	local complete=1
	local found=0
	tmp_file="$(mktemp)"

	for identity_file in "${identities[@]}"; do
		[[ -f "$identity_file" ]] || continue
		found=1
		if ! generate_allowed_signer "$identity_file" >> "$tmp_file"; then
			complete=0
		fi
	done

	if [[ "$found" -eq 0 ]]; then
		rm -f "$tmp_file"
		return 0
	fi

	if [[ "$complete" -eq 0 || ! -s "$tmp_file" ]]; then
		printf 'error: allowed_signers could not be generated completely\n' >&2
		rm -f "$tmp_file"
		return 1
	fi

	awk '!seen[$0]++' "$tmp_file" > "${tmp_file}.unique"
	mv "${tmp_file}.unique" "$tmp_file"
	target="${HOME}/.config/git/allowed_signers"
	state_dir="${HOME}/.local/state/dotfiles"
	state_file="${state_dir}/allowed_signers.generated"

	if [[ -e "$target" || -L "$target" ]]; then
		if cmp -s "$tmp_file" "$target"; then
			if [[ "$check_only" != "--check" && -f "$state_file" ]]; then
				install -m 600 "$tmp_file" "$state_file"
			fi
			rm -f "$tmp_file"
			return 0
		fi
		if [[ ! -f "$state_file" ]] || ! cmp -s "$target" "$state_file"; then
			printf 'error: refusing to overwrite existing %s\n' "$target" >&2
			printf 'remove or reconcile it explicitly, then rerun setup\n' >&2
			rm -f "$tmp_file"
			return 1
		fi
	fi

	if [[ "$check_only" == "--check" ]]; then
		rm -f "$tmp_file"
		return 0
	fi

	mkdir -p "$state_dir"
	chmod 700 "$state_dir"
	install -m 600 "$tmp_file" "$target"
	install -m 600 "$tmp_file" "$state_file"
	rm -f "$tmp_file"
}

setup_ssh_permissions() {
	local config_file
	if [[ -d "${HOME}/.ssh" ]]; then
		chmod 700 "${HOME}/.ssh"
	fi

	for config_file in "${HOME}/.ssh/config" "${HOME}/.ssh/config.local"; do
		if [[ -f "$config_file" ]]; then
			chmod 600 "$config_file"
		fi
	done
}

setup_shell_init() {
	local rc
	[[ -f "${HOME}/.config/shell/init.sh" ]] || return 0

	for rc in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
		validate_block "$rc" --create
	done
	for rc in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
		ensure_block "$rc" "$shell_init_source"
	done
}

check_only=0
if [[ "${1-}" == "--check" ]]; then
	check_only=1
	shift
fi

packages=("$@")

should_setup() {
	local target="$1"
	local package
	[[ "${#packages[@]}" -eq 0 ]] && return 0
	for package in "${packages[@]}"; do
		[[ "$package" == "$target" ]] && return 0
	done
	return 1
}

if [[ "$check_only" -eq 1 ]]; then
	should_setup git && setup_git_signing --check
	if should_setup shell; then
		for rc in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
			validate_block "$rc" --create
		done
	fi
	exit 0
fi

should_setup git && setup_git_signing
should_setup ssh && setup_ssh_permissions
should_setup shell && setup_shell_init
exit 0
