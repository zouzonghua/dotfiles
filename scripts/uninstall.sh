#!/bin/bash

set -euo pipefail

shell_init_source="$1"
shell_dir="$2"
ghostty_dir="$3"
kitty_dir="$4"
tmux_dir="$5"
git_dir="$6"
peco_dir="$7"
ssh_dir="$8"
vimrc="$9"
aerospace_config="${10}"

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

restore_link() {
	path="$1"

	if [[ -L "$path" ]]; then
		rm -f "$path"
	fi
	if [[ -e "$path.backup" ]]; then
		mv "$path.backup" "$path"
	fi
}

restore_files() {
	dir="$1"
	shift

	for file in "$@"; do
		restore_link "${dir}/${file}"
	done
}

cleanup_line "${HOME}/.zshrc" '# shell init' "$shell_init_source"
cleanup_line "${HOME}/.bashrc" '# shell init' "$shell_init_source"

restore_files "$shell_dir" init.sh aliases.sh prompt.sh history.sh
restore_files "$ghostty_dir" config
restore_files "$kitty_dir" kitty.conf
restore_files "$tmux_dir" tmux.conf conf bin
restore_files "$git_dir" config work.identity personal.identity personal.devcontainer work.devcontainer
restore_link "${git_dir}/allowed_signers"
restore_files "$peco_dir" config.json
restore_files "$ssh_dir" config devcontainer
restore_link "$vimrc"
restore_link "$aerospace_config"

printf 'uninstall complete\n'
