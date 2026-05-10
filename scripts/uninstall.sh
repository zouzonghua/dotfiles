#!/bin/bash

set -euo pipefail

block_start='# BEGIN DOTFILES'
block_end='# END DOTFILES'
allowed_signers="${HOME}/.config/git/allowed_signers"

cleanup_block() {
	file="$1"

	[[ -f "$file" ]] || return 0

	tmp_file="$(mktemp)"
	awk -v start="$block_start" -v end="$block_end" '
		$0 == start { skip = 1; next }
		$0 == end   { skip = 0; next }
		!skip       { print }
	' "$file" > "$tmp_file"
	
	# Optional: Remove trailing empty lines or fix redundant spacing
	mv "$tmp_file" "$file"
}

cleanup_block "${HOME}/.zshrc"
cleanup_block "${HOME}/.bashrc"
rm -f "$allowed_signers" "${allowed_signers}.bak"

printf 'uninstall complete\n'
