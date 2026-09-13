#!/bin/bash

set -euo pipefail

shell_init_source='[ -f ~/.config/shell/init.sh ] && source ~/.config/shell/init.sh'
block_start='# BEGIN ZOUZONGHUA DOTFILES'
block_end='# END ZOUZONGHUA DOTFILES'
legacy_block_start='# BEGIN DOTFILES'
legacy_block_end='# END DOTFILES'

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
	email="$(git config -f "$identity_file" user.email || true)"
	signingkey="$(git config -f "$identity_file" user.signingkey || true)"

	if [[ -z "$email" || -z "$signingkey" ]]; then
		printf 'warning: incomplete Git identity: %s\n' "$identity_file" >&2
		return 1
	fi

	public_key_file="$(expand_path "$signingkey")"
	if [[ ! -s "$public_key_file" ]]; then
		printf 'warning: public signing key not found: %s\n' "$public_key_file" >&2
		return 1
	fi

	key_content="$(cat "$public_key_file")"
	printf '%s %s\n' "$email" "$key_content"
}

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
	if [[ ! -e "$file" && ! -w "$(dirname "$file")" ]]; then
		printf 'error: shell rc parent is not writable: %s\n' "$(dirname "$file")" >&2
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
		printf 'error: refusing to manage modified dotfiles block in %s\n' "$file" >&2
		return 1
	fi
	if [[ "$legacy_present" -eq 1 && "$(block_content "$file" "$legacy_block_start" "$legacy_block_end")" != "$shell_init_source" ]]; then
		printf 'error: refusing to manage unrecognized legacy block in %s\n' "$file" >&2
		return 1
	fi
}

ensure_block() {
	file="$1"
	content="$2"
	touch "$file"

	if [[ "$(head -n 1 "$file")" == "$block_start" ]]; then
		return 0
	fi

	tmp_file="$(mktemp)"
	printf '%s\n%s\n%s\n' "$block_start" "$content" "$block_end" > "$tmp_file"
	if grep -Fqx "$block_start" "$file"; then
		old_start="$block_start"
		old_end="$block_end"
	elif grep -Fqx "$legacy_block_start" "$file"; then
		old_start="$legacy_block_start"
		old_end="$legacy_block_end"
	else
		cat "$file" >> "$tmp_file"
		cat "$tmp_file" > "$file"
		rm -f "$tmp_file"
		return 0
	fi

	awk -v start="$old_start" -v end="$old_end" '
		$0 == start { skip = 1; next }
		$0 == end   { skip = 0; next }
		!skip       { print }
	' "$file" >> "$tmp_file"
	cat "$tmp_file" > "$file"
	rm -f "$tmp_file"
}

setup_git_signing() {
	check_only="${1-}"
	identities=(
		"${HOME}/.config/git/personal.identity"
		"${HOME}/.config/git/work.identity"
	)
	tmp_file="$(mktemp)"
	complete=1
	found=0

	for identity_file in "${identities[@]}"; do
		[[ -f "$identity_file" ]] || continue
		found=1
		if ! generate_allowed_signer "$identity_file" >> "$tmp_file"; then
			complete=0
		fi
	done

	if [[ "$found" -eq 0 ]]; then
		rm -f "$tmp_file"
		return 0
	fi

	if [[ "$complete" -eq 0 || ! -s "$tmp_file" ]]; then
		printf 'error: allowed_signers could not be generated completely\n' >&2
		rm -f "$tmp_file"
		return 1
	fi

	awk '!seen[$0]++' "$tmp_file" > "${tmp_file}.unique"
	mv "${tmp_file}.unique" "$tmp_file"
	target="${HOME}/.config/git/allowed_signers"
	state_dir="${HOME}/.local/state/dotfiles"
	state_file="${state_dir}/allowed_signers.generated"

	if [[ -e "$target" || -L "$target" ]]; then
		if cmp -s "$tmp_file" "$target"; then
			if [[ "$check_only" != "--check" && -f "$state_file" ]]; then
				install -m 600 "$tmp_file" "$state_file"
			fi
			rm -f "$tmp_file"
			return 0
		fi
		if [[ ! -f "$state_file" ]] || ! cmp -s "$target" "$state_file"; then
			printf 'error: refusing to overwrite existing %s\n' "$target" >&2
			printf 'remove or reconcile it explicitly, then rerun setup\n' >&2
			rm -f "$tmp_file"
			return 1
		fi
	fi

	if [[ "$check_only" == "--check" ]]; then
		rm -f "$tmp_file"
		return 0
	fi

	mkdir -p "$state_dir"
	chmod 700 "$state_dir"
	install -m 600 "$tmp_file" "$target"
	install -m 600 "$tmp_file" "$state_file"
	rm -f "$tmp_file"
}

setup_ssh_permissions() {
	if [[ -d "${HOME}/.ssh" ]]; then
		chmod 700 "${HOME}/.ssh"
	fi

	for config_file in "${HOME}/.ssh/config" "${HOME}/.ssh/config.local"; do
		if [[ -f "$config_file" ]]; then
			chmod 600 "$config_file"
		fi
	done
}

setup_shell_init() {
	[[ -f "${HOME}/.config/shell/init.sh" ]] || return 0

	for rc in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
		validate_block "$rc"
	done
	for rc in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
		ensure_block "$rc" "$shell_init_source"
	done
}

if [[ "${1-}" == "--check" ]]; then
	setup_git_signing --check
	for rc in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
		validate_block "$rc"
	done
	exit 0
fi

setup_git_signing
setup_ssh_permissions
setup_shell_init
