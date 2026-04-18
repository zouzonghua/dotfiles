#!/bin/bash

set -euo pipefail

output_file="$1"
shift

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

generate_entry() {
	identity_file="$1"

	[[ -f "$identity_file" ]] || return 0

	email="$(awk '$1 == "email" && $2 == "=" { print $3; exit }' "$identity_file")"
	signingkey="$(awk '$1 == "signingkey" && $2 == "=" { print $3; exit }' "$identity_file")"

	[[ -n "$email" ]] || return 0
	[[ -n "$signingkey" ]] || return 0

	public_key_file="$(expand_path "$signingkey")"
	[[ -f "$public_key_file" ]] || return 0

	key_type="$(awk '{ print $1; exit }' "$public_key_file")"
	key_value="$(awk '{ print $2; exit }' "$public_key_file")"

	[[ -n "$key_type" ]] || return 0
	[[ -n "$key_value" ]] || return 0

	printf '%s %s %s\n' "$email" "$key_type" "$key_value"
}

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

for identity_file in "$@"; do
	generate_entry "$identity_file"
done | awk '!seen[$0]++' > "$tmp_file"

mv "$tmp_file" "$output_file"
