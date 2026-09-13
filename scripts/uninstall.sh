#!/bin/bash

set -euo pipefail

shell_init_source='[ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh'
block_start='# BEGIN ZOUZONGHUA DOTFILES'
block_end='# END ZOUZONGHUA DOTFILES'
allowed_signers="${HOME}/.config/git/allowed_signers"
state_dir="${HOME}/.local/state/dotfiles"
state_file="${state_dir}/allowed_signers.generated"

validate_block() {
	file="$1"
	if [[ -L "$file" && ! -e "$file" ]]; then
		printf 'error: shell rc is a dangling link: %s\n' "$file" >&2
		return 1
	fi
	if [[ -e "$file" && ! -f "$file" ]]; then
		printf 'error: shell rc is not a regular file: %s\n' "$file" >&2
		return 1
	fi
	if [[ -f "$file" && ! -w "$file" ]]; then
		printf 'error: shell rc is not writable: %s\n' "$file" >&2
		return 1
	fi
	[[ -f "$file" ]] || return 0

	start_count="$(grep -Fxc "$block_start" "$file" || true)"
	end_count="$(grep -Fxc "$block_end" "$file" || true)"
	if [[ "$start_count" -eq 0 && "$end_count" -eq 0 ]]; then
		return 0
	fi
	if [[ "$start_count" -ne 1 || "$end_count" -ne 1 ]]; then
		printf 'error: malformed dotfiles block in %s\n' "$file" >&2
		return 1
	fi

	block="$(awk -v start="$block_start" -v end="$block_end" '
		$0 == start { capture = 1; next }
		$0 == end   { capture = 0; exit }
		capture     { print }
	' "$file")"
	if [[ "$block" != "$shell_init_source" ]]; then
		printf 'error: refusing to remove modified dotfiles block in %s\n' "$file" >&2
		return 1
	fi
}

cleanup_block() {
	file="$1"
	[[ -f "$file" ]] || return 0

	if [[ "$(head -n 1 "$file")" == "$block_start" ]]; then
		block_bytes="$(printf '%s\n%s\n%s\n' "$block_start" "$shell_init_source" "$block_end" | wc -c | tr -d ' ')"
		tmp_file="$(mktemp)"
		dd if="$file" of="$tmp_file" bs=1 skip="$block_bytes" 2>/dev/null
		cat "$tmp_file" > "$file"
		rm -f "$tmp_file"
		return 0
	fi

	grep -Fqx "$block_start" "$file" || return 0

	tmp_file="$(mktemp)"
	awk -v start="$block_start" -v end="$block_end" '
		$0 == start { skip = 1; next }
		$0 == end   { skip = 0; next }
		!skip       { print }
	' "$file" > "$tmp_file"
	cat "$tmp_file" > "$file"
	rm -f "$tmp_file"
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

printf 'uninstall cleanup complete\n'
