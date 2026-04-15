#!/bin/bash

set -euo pipefail

shell_init_source="$1"

ensure_line() {
	file="$1"
	comment="$2"
	line="$3"

	touch "$file"
	if ! grep -Fqx "$line" "$file"; then
		printf '\n%s\n%s\n' "$comment" "$line" >> "$file"
	fi
}

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
