#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/lib/shell-block.sh"
allowed_signers="${HOME}/.config/git/allowed_signers"
state_dir="${HOME}/.local/state/dotfiles"
state_file="${state_dir}/allowed_signers.generated"

cleanup_block() {
	local file="$1"
	local tmp_file state_file last_byte
	[[ -f "$file" ]] || return 0

	state_file="${state_dir}/$(basename "$file").missing-final-newline"
	grep -Fqx "$block_start" "$file" || return 0

	tmp_file="$(mktemp)"
	awk -v start="$block_start" -v end="$block_end" '
		$0 == start { skip = 1; next }
		$0 == end   { skip = 0; next }
		!skip       { print }
	' "$file" > "$tmp_file"
	cat "$tmp_file" > "$file"
	rm -f "$tmp_file"
	if [[ -f "$state_file" && -s "$file" ]]; then
		last_byte="$(tail -c 1 "$file" | od -An -tx1 | tr -d ' ')"
		[[ "$last_byte" == "0a" ]] && truncate -s -1 "$file"
	fi
	rm -f "$state_file"
}

cleanup_allowed_signers() {
	[[ -f "$state_file" ]] || return 0

	if [[ -f "$allowed_signers" ]] && cmp -s "$allowed_signers" "$state_file"; then
		rm -f "$allowed_signers"
	elif [[ -e "$allowed_signers" || -L "$allowed_signers" ]]; then
		printf 'warning: preserving modified %s\n' "$allowed_signers" >&2
	fi

	rm -f "$state_file"
	rmdir "$state_dir" 2>/dev/null || true
}

for rc in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
	validate_block "$rc"
done

if [[ "${1-}" == "--check" ]]; then
	exit 0
fi

cleanup_block "${HOME}/.zshrc"
cleanup_block "${HOME}/.bashrc"
cleanup_allowed_signers
rmdir "$state_dir" 2>/dev/null || true

printf 'uninstall cleanup complete\n'
