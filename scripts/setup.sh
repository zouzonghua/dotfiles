#!/bin/bash

set -euo pipefail

shell_init_source='[ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh'

ensure_line() {
	file="$1"
	comment="$2"
	line="$3"

	touch "$file"
	if ! grep -Fqx "$line" "$file"; then
		printf '\n%s\n%s\n' "$comment" "$line" >> "$file"
	fi
}

if [[ -f "${HOME}/.config/git/personal.identity" || -f "${HOME}/.config/git/work.identity" ]]; then
	bash scripts/generate-allowed-signers.sh "${HOME}/.config/git/allowed_signers" \
		"${HOME}/.config/git/personal.identity" \
		"${HOME}/.config/git/work.identity"
fi

for file in "${HOME}/.ssh/config" "${HOME}/.ssh/devcontainer"; do
	if [[ -f "$file" ]]; then
		chmod 600 "$file"
	fi
done

if [[ -f "${HOME}/.config/shell/init.sh" ]]; then
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
fi
