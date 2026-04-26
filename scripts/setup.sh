#!/bin/bash

set -euo pipefail

shell_init_source='[ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh'

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

	email="$(awk '$1 == "email" && $2 == "=" { print $3; exit }' "$identity_file")"
	signingkey="$(awk '$1 == "signingkey" && $2 == "=" { print $3; exit }' "$identity_file")"

	[[ -n "$email" ]] || return 0
	[[ -n "$signingkey" ]] || return 0

	public_key_file="$(expand_path "$signingkey")"
	[[ -f "$public_key_file" ]] || return 0

	key_type="$(awk '{ print $1; exit }' "$public_key_file")"
	key_value="$(awk '{ print $2; exit }' "$public_key_file")"

	[[ -n "$key_type" ]] || return 0
	[[ -n "$key_value" ]] || return 0

	printf '%s %s %s\n' "$email" "$key_type" "$key_value"
}

ensure_line() {
	file="$1"
	comment="$2"
	line="$3"

	touch "$file"
	if ! grep -Fqx "$line" "$file"; then
		printf '\n%s\n%s\n' "$comment" "$line" >> "$file"
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

	mv "$tmp_file" "${HOME}/.config/git/allowed_signers"
}

setup_ssh_permissions() {
	for file in "${HOME}/.ssh/config" "${HOME}/.ssh/devcontainer"; do
		if [[ -f "$file" ]]; then
			chmod 600 "$file"
		fi
	done
}

setup_shell_init() {
	[[ -f "${HOME}/.config/shell/init.sh" ]] || return 0

	case "${SHELL##*/}" in
		zsh)
			ensure_line "${HOME}/.zshrc" '# shell init' "$shell_init_source"
			;;
		bash)
			ensure_line "${HOME}/.bashrc" '# shell init' "$shell_init_source"
			;;
		*)
			echo "skip rc injection for unsupported shell: ${SHELL}"
			;;
	esac
}

setup_git_signing
setup_ssh_permissions
setup_shell_init
