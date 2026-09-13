#!/bin/bash

set -euo pipefail

shell_init_source='[ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh'
block_start='# BEGIN ZOUZONGHUA DOTFILES'
block_end='# END ZOUZONGHUA DOTFILES'
legacy_block_start='# BEGIN DOTFILES'
legacy_block_end='# END DOTFILES'
allowed_signers="${HOME}/.config/git/allowed_signers"
state_dir="${HOME}/.local/state/dotfiles"
state_file="${state_dir}/allowed_signers.generated"

validate_block_pair() {
	file="$1"
	start="$2"
	end="$3"
	start_count="$(grep -Fxc "$start" "$file" || true)"
	end_count="$(grep -Fxc "$end" "$file" || true)"

	if [[ "$start_count" -eq 0 && "$end_count" -eq 0 ]]; then
		return 1
	fi
	if [[ "$start_count" -ne 1 || "$end_count" -ne 1 ]]; then
		printf 'error: malformed dotfiles block in %s\n' "$file" >&2
		return 2
	fi

	start_line="$(grep -Fn "$start" "$file" | cut -d: -f1)"
	end_line="$(grep -Fn "$end" "$file" | cut -d: -f1)"
	if [[ "$start_line" -ge "$end_line" ]]; then
		printf 'error: malformed dotfiles block in %s\n' "$file" >&2
		return 2
	fi
}

block_content() {
	file="$1"
	start="$2"
	end="$3"
	awk -v start="$start" -v end="$end" '
		$0 == start { capture = 1; next }
		$0 == end   { exit }
		capture     { print }
	' "$file"
}

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

	new_present=0
	legacy_present=0
	if validate_block_pair "$file" "$block_start" "$block_end"; then
		new_present=1
	elif [[ "$?" -eq 2 ]]; then
		return 1
	fi
	if validate_block_pair "$file" "$legacy_block_start" "$legacy_block_end"; then
		legacy_present=1
	elif [[ "$?" -eq 2 ]]; then
		return 1
	fi

	if [[ "$new_present" -eq 1 && "$legacy_present" -eq 1 ]]; then
		printf 'error: multiple dotfiles block formats in %s\n' "$file" >&2
		return 1
	fi
	if [[ "$new_present" -eq 1 && "$(block_content "$file" "$block_start" "$block_end")" != "$shell_init_source" ]]; then
		printf 'error: refusing to remove modified dotfiles block in %s\n' "$file" >&2
		return 1
	fi
	if [[ "$legacy_present" -eq 1 && "$(block_content "$file" "$legacy_block_start" "$legacy_block_end")" != "$shell_init_source" ]]; then
		printf 'error: refusing to remove unrecognized legacy block in %s\n' "$file" >&2
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

	if grep -Fqx "$block_start" "$file"; then
		start="$block_start"
		end="$block_end"
	elif grep -Fqx "$legacy_block_start" "$file"; then
		start="$legacy_block_start"
		end="$legacy_block_end"
	else
		return 0
	fi

	tmp_file="$(mktemp)"
	awk -v start="$start" -v end="$end" '
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
