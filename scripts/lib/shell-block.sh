#!/bin/bash

shell_init_source='[ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh'
block_start='# BEGIN ZOUZONGHUA DOTFILES'
block_end='# END ZOUZONGHUA DOTFILES'

validate_block() {
	local file="$1"
	local mode="${2-}"
	local start_count end_count start_line end_line block

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
	if [[ "$mode" == "--create" && ! -e "$file" && ! -w "$(dirname "$file")" ]]; then
		printf 'error: shell rc parent is not writable: %s\n' "$(dirname "$file")" >&2
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
	start_line="$(grep -Fn "$block_start" "$file" | cut -d: -f1)"
	end_line="$(grep -Fn "$block_end" "$file" | cut -d: -f1)"
	if [[ "$start_line" -ge "$end_line" ]]; then
		printf 'error: malformed dotfiles block in %s\n' "$file" >&2
		return 1
	fi

	block="$(awk -v start="$block_start" -v end="$block_end" '
		$0 == start { capture = 1; next }
		$0 == end   { capture = 0; exit }
		capture     { print }
	' "$file")"
	if [[ "$block" != "$shell_init_source" ]]; then
		printf 'error: refusing to modify managed dotfiles block in %s\n' "$file" >&2
		return 1
	fi
}
