#!/bin/bash

set -euo pipefail

shell_init_source='[ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh'
allowed_signers="${HOME}/.config/git/allowed_signers"

cleanup_line() {
	file="$1"
	comment="$2"
	line="$3"

	[[ -f "$file" ]] || return 0

	tmp="${file}.tmp"
	awk -v comment="$comment" -v line="$line" '
		prev == comment && $0 == line { prev = ""; next }
		prev != ""                    { print prev }
		                              { prev = $0 }
		END                           { if (prev != "") print prev }
	' "$file" > "$tmp"
	mv "$tmp" "$file"
}

cleanup_line "${HOME}/.zshrc" '# shell init' "$shell_init_source"
cleanup_line "${HOME}/.bashrc" '# shell init' "$shell_init_source"
rm -f "$allowed_signers"

printf 'uninstall complete\n'
