#!/bin/bash

set -euo pipefail

shell_init_source='[ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh'
block_start='# BEGIN DOTFILES'
block_end='# END DOTFILES'

expand_path() {
	path="$1"
	if [[ "$path" == "~" ]]; then
		printf '%s\n' "$HOME"
	elif [[ "$path" == "~/"* ]]; then
		printf '%s/%s\n' "$HOME" "${path#"~/"}"
	else
		printf '%s\n' "$path"
	fi
}

generate_allowed_signer() {
	identity_file="$1"

	[[ -f "$identity_file" ]] || return 0

	# Use git config to parse the identity file robustly
	email="$(git config -f "$identity_file" user.email || true)"
	signingkey="$(git config -f "$identity_file" user.signingkey || true)"

	[[ -n "$email" ]] || return 0
	[[ -n "$signingkey" ]] || return 0

	public_key_file="$(expand_path "$signingkey")"
	[[ -f "$public_key_file" ]] || return 0

	key_content="$(cat "$public_key_file")"
	[[ -n "$key_content" ]] || return 0

	printf '%s %s\n' "$email" "$key_content"
}

ensure_block() {
	file="$1"
	content="$2"

	touch "$file"

	# Use awk for atomic block update. 
	# Compatible with both BSD awk (macOS) and GNU awk (Linux).
	if grep -Fqx "$block_start" "$file" && grep -Fqx "$block_end" "$file"; then
		# Update existing block
		tmp_file="$(mktemp)"
		awk -v start="$block_start" -v end="$block_end" -v content="$content" '
			$0 == start { print; print content; skip = 1; next }
			$0 == end   { skip = 0; print; next }
			!skip       { print }
		' "$file" > "$tmp_file"
		mv "$tmp_file" "$file"
	else
		# Append new block
		printf '\n%s\n%s\n%s\n' "$block_start" "$content" "$block_end" >> "$file"
	fi
}

setup_git_signing() {
	[[ -f "${HOME}/.config/git/personal.identity" || -f "${HOME}/.config/git/work.identity" ]] || return 0

	tmp_file="$(mktemp)"
	trap 'rm -f "$tmp_file"' EXIT

	{
		generate_allowed_signer "${HOME}/.config/git/personal.identity"
		generate_allowed_signer "${HOME}/.config/git/work.identity"
	} | awk '!seen[$0]++' > "$tmp_file"

	# Skip overwrite when generation produced nothing — preserves prior valid file.
	[[ -s "$tmp_file" ]] || return 0

	target="${HOME}/.config/git/allowed_signers"
	[[ -f "$target" ]] && cp -p "$target" "${target}.bak"
	mv "$tmp_file" "$target"
}

setup_ssh_permissions() {
	# Ensure .ssh directory exists with correct permissions
	if [[ -d "${HOME}/.ssh" ]]; then
		chmod 700 "${HOME}/.ssh"
	fi

	for file in "${HOME}/.ssh/config" "${HOME}/.ssh/devcontainer"; do
		if [[ -f "$file" ]]; then
			chmod 600 "$file"
		fi
	done
}

setup_shell_init() {
	[[ -f "${HOME}/.config/shell/init.sh" ]] || return 0

	# Inject into both zsh and bash if they exist, ensuring robustness
	for rc in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
		if [[ -f "$rc" ]]; then
			ensure_block "$rc" "$shell_init_source"
		fi
	done
}

setup_git_signing
setup_ssh_permissions
setup_shell_init
