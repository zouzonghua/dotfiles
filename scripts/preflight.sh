#!/bin/bash

set -euo pipefail

if [[ "$#" -eq 0 ]]; then
	printf 'usage: %s <package>...\n' "$0" >&2
	exit 2
fi

command -v stow >/dev/null 2>&1 || {
	printf 'stow is required\n' >&2
	exit 1
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for package in "$@"; do
	if [[ "$package" == "git" ]]; then
		bash "${script_dir}/check.sh" git
	fi
done
bash "${script_dir}/setup.sh" --check "$@"

for package in "$@"; do
	if [[ "$package" == "git" ]] &&
		[[ -e "${HOME}/.config/git/allowed_signers" || -L "${HOME}/.config/git/allowed_signers" ]] &&
		[[ ! -f "${HOME}/.config/git/personal.identity" && ! -f "${HOME}/.config/git/work.identity" ]] &&
		[[ ! -f "${HOME}/.local/state/dotfiles/allowed_signers.generated" ]]; then
		printf 'error: refusing to overwrite unowned %s\n' "${HOME}/.config/git/allowed_signers" >&2
		exit 1
	fi
done

# Validate the complete Stow transaction before changing anything under HOME.
stow --simulate --verbose --restow --no-folding -t "$HOME" "$@"
